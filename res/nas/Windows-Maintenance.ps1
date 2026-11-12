param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('DisableUpdates', 'RepairCustomer')]
    [string]$Action
)

$ErrorActionPreference = 'Stop'
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host 'Right-click the BAT file and choose Run as administrator.' -ForegroundColor Yellow
    exit 1
}

$backupSuffix = '.before-maintenance-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [Guid]::NewGuid().ToString('N').Substring(0, 8) + '.bak'
$encoding = New-Object Text.UTF8Encoding($false)

function Set-Options([string]$Path, [hashtable]$Values) {
    $text = ''
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        Copy-Item -LiteralPath $Path -Destination ($Path + $backupSuffix)
        $text = [IO.File]::ReadAllText($Path)
    } else {
        New-Item -ItemType Directory -Path (Split-Path $Path) -Force | Out-Null
    }
    $section = [regex]::Match($text, '(?m)^[ \t]*\[options\][ \t]*(?:\r?\n|$)')
    if ($section.Success) {
        $start = $section.Index + $section.Length
        $next = [regex]::Match($text.Substring($start), '(?m)^[ \t]*\[')
        $end = if ($next.Success) { $start + $next.Index } else { $text.Length }
        $prefix = $text.Substring(0, $start)
        $body = $text.Substring($start, $end - $start)
        $suffix = $text.Substring($end)
    } else {
        $prefix = $text.TrimEnd("`r", "`n") + "`r`n[options]`r`n"
        $body = ''
        $suffix = ''
    }
    foreach ($key in $Values.Keys) {
        $escaped = [regex]::Escape($key)
        $pattern = '(?m)^[ \t]*(?:"' + $escaped + '"|''' + $escaped + '''|' + $escaped + ')[ \t]*=[^\r\n]*(?:\r?\n|$)'
        $body = [regex]::Replace($body, $pattern, '')
        if ($body.Length -gt 0 -and -not $body.EndsWith("`n")) { $body += "`r`n" }
        $body += $key + ' = "' + $Values[$key] + '"' + "`r`n"
    }
    if (-not $prefix.EndsWith("`n")) { $prefix += "`r`n" }
    [IO.File]::WriteAllText($Path, $prefix + $body + $suffix, $encoding)
    Write-Host "Updated: $Path"
}

function Find-App([string]$Name) {
    $service = Get-CimInstance Win32_Service -Filter "Name='$Name'"
    $binary = Join-Path $env:ProgramFiles "$Name\$Name.exe"
    if ($service) {
        $match = [regex]::Match($service.PathName, '^\s*(?:"([^"]+\.exe)"|(\S+\.exe))(?:\s|$)')
        if ($match.Success) {
            $candidate = if ($match.Groups[1].Success) { $match.Groups[1].Value } else { $match.Groups[2].Value }
            if ([IO.Path]::GetFileName($candidate) -ieq "$Name.exe") { $binary = $candidate }
        }
    }
    $roots = @(
        (Join-Path $env:APPDATA "$Name\config"),
        (Join-Path $env:WINDIR "ServiceProfiles\LocalService\AppData\Roaming\$Name\config")
    )
    $legacyRoot = Join-Path $env:WINDIR "System32\config\systemprofile\AppData\Roaming\$Name\config"
    if (Test-Path -LiteralPath $legacyRoot) { $roots += $legacyRoot }
    $installed = Test-Path -LiteralPath $binary -PathType Leaf
    $configured = @($roots | Where-Object { Test-Path -LiteralPath $_ }).Count -gt 0
    if (-not ($service -or $installed -or $configured)) { return $null }
    [pscustomobject]@{ Name = $Name; Binary = $binary; Installed = $installed; Service = $service; Roots = $roots }
}

$names = if ($Action -eq 'RepairCustomer') { @('RustDeskCustomer') } else { @('RustDesk', 'RustDeskCustomer') }
$apps = @($names | ForEach-Object { Find-App $_ } | Where-Object { $null -ne $_ })
if ($apps.Count -eq 0) {
    Write-Host 'No RemoteConnect installation or configuration found for this Windows user.' -ForegroundColor Red
    exit 1
}
if ($Action -eq 'RepairCustomer') {
    $app = $apps[0]
    $library = Join-Path (Split-Path $app.Binary) 'librustdesk.dll'
    if (-not $app.Installed -or -not (Test-Path -LiteralPath $library -PathType Leaf)) {
        Write-Host 'Reinstall the custom Customer MSI first. The installed Customer executable is missing.' -ForegroundColor Red
        exit 1
    }
    if (-not [Text.Encoding]::ASCII.GetString([IO.File]::ReadAllBytes($library)).Contains('Incoming only mode (customer edition)')) {
        Write-Host 'This is not the incoming-only Customer build. Reinstall the custom Customer MSI first.' -ForegroundColor Red
        exit 1
    }
}

try {
    foreach ($app in $apps) {
        $wasRunning = $app.Service -and $app.Service.State -eq 'Running'
        $session = [Diagnostics.Process]::GetCurrentProcess().SessionId
        $uiProcesses = @(Get-Process -Name $app.Name -ErrorAction SilentlyContinue | Where-Object { $_.SessionId -eq $session })
        $restartBinary = if ($app.Installed) { $app.Binary } else { $uiProcesses | Select-Object -First 1 -ExpandProperty Path }
        $restoreService = $false
        try {
            if ($wasRunning) {
                $restoreService = $true
                Stop-Service -Name $app.Name -Force
                (Get-Service -Name $app.Name).WaitForStatus('Stopped', [TimeSpan]::FromSeconds(20))
            }
            Get-Process -Name $app.Name -ErrorAction SilentlyContinue | Stop-Process -Force
            foreach ($root in $app.Roots) {
                if (-not $app.Service -and -not $app.Installed -and -not (Test-Path -LiteralPath $root)) { continue }
                $options = @{ 'allow-auto-update' = 'N' }
                if ($Action -eq 'RepairCustomer') {
                    $options['stop-service'] = 'N'
                    $options['approve-mode'] = 'click'
                    $options['custom-rendezvous-server'] = 'nas.hk-beautyshop.cn:21116'
                    $options['relay-server'] = 'nas.hk-beautyshop.cn:21117'
                    $options['key'] = 'GevVI6bnGZ79VB8CAJ9InRZ3o566YJDQZW5mTOCGri4='
                    $options['api-server'] = ''
                }
                Set-Options (Join-Path $root ($app.Name + '2.toml')) $options
                Set-Options (Join-Path $root ($app.Name + '_local.toml')) @{ 'enable-check-update' = 'N' }
            }
            if ($Action -eq 'RepairCustomer') {
                $command = '"' + $app.Binary + '" --service'
                if ($app.Service) {
                    $result = Invoke-CimMethod -InputObject $app.Service -MethodName Change -Arguments @{ PathName = $command; StartMode = 'Automatic' }
                    if ($result.ReturnValue -ne 0) { throw "Service registration failed: $($result.ReturnValue)" }
                } else {
                    New-Service -Name $app.Name -BinaryPathName $command -StartupType Automatic -DisplayName 'RemoteConnect Customer Service' | Out-Null
                }
                foreach ($direction in @('Inbound', 'Outbound')) {
                    $rule = "RemoteConnect-Customer-Repair-$direction"
                    if (Get-NetFirewallRule -Name $rule -ErrorAction SilentlyContinue) {
                        Remove-NetFirewallRule -Name $rule
                    }
                    New-NetFirewallRule -Name $rule -DisplayName $rule -Program $app.Binary -Direction $direction -Action Allow -Profile Any | Out-Null
                }
                $restoreService = $true
            }
        } finally {
            if ($restoreService) { Start-Service -Name $app.Name }
            if ($uiProcesses.Count -gt 0 -and $restartBinary) { Start-Process -FilePath $restartBinary -WorkingDirectory (Split-Path $restartBinary) }
        }
    }
    Write-Host 'Done. Automatic updating and startup update checks are disabled.' -ForegroundColor Green
    Write-Host "Previous config files were backed up beside the originals with suffix: $backupSuffix"
    if ($Action -eq 'RepairCustomer') { Write-Host 'Customer service restarted. Open the app to try connecting.' }
    exit 0
} catch {
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host 'The operation did not finish. Check the error and the backup files before retrying.' -ForegroundColor Yellow
    exit 1
}
