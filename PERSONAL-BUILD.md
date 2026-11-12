# 远程连接：RustDesk 自建版

此源码基于官方 RustDesk 1.5.1 和该版本固定的 hbb_common 提交，已在 Rust 公共配置层内置：

- ID 服务器：`nas.hk-beautyshop.cn:21116`
- 中继服务器：`nas.hk-beautyshop.cn:21117`
- Key：`GevVI6bnGZ79VB8CAJ9InRZ3o566YJDQZW5mTOCGri4=`
- API 服务器：空

这些配置随各平台二进制一起编译，首次打开无需输入服务器配置。网络设置在该个人版本中固定。完整端保留原有授权流程；顾客版使用下面的逐次点击确认流程。

## 完整端与顾客版

完整端供服务人员使用，保留原有控制和被控功能。顾客版提供 Windows x64、Intel Mac 和 Apple 芯片 Mac：

- 顾客打开软件，把本机 ID（连接码）提供给服务人员。
- 服务人员使用完整端输入 ID 发起连接，顾客点击“接受”后才能控制，无需提供密码。
- 顾客版隐藏主动连接面板，底层拒绝向 ID、IP、域名发起远控、文件传输、隧道等连接。
- 会话中的“切换控制方向”也被拒绝；锁屏密码登录不绕过顾客确认。
- “点击接受”模式随程序编译并锁定，已有配置中的密码模式不会替换它。
- 应用名为 `RustDeskCustomer`，使用独立配置和进程通信名称，避免唤起已经运行的普通版；Windows 免安装包也使用独立解压目录，Mac 使用独立应用标识。

在 Actions 中手动启动 **Build customer incoming-only RustDesk clients**。其工作流为 `.github/workflows/customer-build.yml`，编译时设置 `RUSTDESK_NAS_EDITION=customer`；完整端不设置这个变量。顾客版产物名称包含 `Customer`，文件名包含 `customer`，分发时应保留这个标记。仅被控限制适用于该顾客版程序。

软件内的键鼠、剪贴板、文件传输、音频等权限保留原版默认开启状态，顾客可以调整，没有强制锁定为全部开放。Windows 的管理员/UAC 授权以及 Mac 的屏幕录制、辅助功能仍由设备用户决定；安装包不能预先授予这些系统权限。

修改位于 `libs/hbb_common/src/config.rs`，包括默认服务器列表、服务器公钥和运行时网络选项覆盖。自动检查更新与自动更新已关闭，升级时应重新构建个人版本。

Android 的 applicationId 为 `cn.hkbeautyshop.rustdesk`，可以与官方客户端并存。

## 编译

`.github/workflows/personal-build.yml` 提供手动启动的 GitHub Actions 构建。源代码提交到你自己的仓库后，在 Actions 中选择 **Build personal RustDesk NAS clients** 并启动。

目标包括 Windows x64 EXE、Android 各架构及通用 APK、macOS Intel DMG、Linux x64 DEB/AppImage。安装包仅保存为 Actions artifacts，不发布公开 Release，保留 7 天。Apple 芯片完整端不在本次构建范围；Apple 芯片顾客版使用下面的独立流程。

Apple 芯片顾客版使用 `.github/workflows/customer-apple-silicon.yml`，在 Actions 启动 **Build Apple Silicon customer RustDesk client**。它使用标准 `macos-15` M1 构建机，启用上游 ARM 版的 ScreenCaptureKit，最低 macOS 12.3，并在原生 ARM 环境运行同样的顾客限制测试。已有 Windows 和 Intel Mac 流程保留。打包后使用 **Check built Mac package**，选择 `customer`、`aarch64` 和对应构建运行编号，检查实际 ARM 应用启动和点击确认模式。该平台现已编译并通过这些检查，结果见下方记录。

此目录已经将 hbb_common 固定版本作为普通源文件放入，不依赖保留上游 Git 子模块索引。

原版 Windows/macOS 签名证书不属于此个人构建。macOS 系统首次运行可能需要在系统设置中允许打开个人构建的应用。Android 使用个人固定签名密钥，通过以下仓库 Secrets 配置；所有架构及后续版本共用该签名，可直接升级安装：

- `ANDROID_SIGNING_KEY`：keystore 文件的 Base64
- `ANDROID_ALIAS`
- `ANDROID_KEY_STORE_PASSWORD`
- `ANDROID_KEY_PASSWORD`

未配置这些 Secrets 时，上游流程生成调试签名 APK，适合临时测试。正式自用时应保留个人签名密钥的备份，避免更换签名后无法覆盖安装。

## 本次“远程连接”构建与验证

完整端 Windows x64、Android 通用 APK、Intel Mac、Linux x64 DEB/AppImage，以及顾客版 Windows x64、Intel Mac、Apple 芯片 Mac 均已重新构建并核验，共八个分发文件。所有包使用新的墨蓝双窗口图标；显示名为“远程连接”或“远程连接（顾客版）”，账号和在线地址簿入口关闭。

| 原生目标 | 构建记录 | 实际打包程序检查 |
| --- | --- | --- |
| Windows 完整端 | [42583324215](https://github.com/553421138/rustdesk-nas-client/actions/runs/42583324215) | EXE 内置配置、EXE/MSI 图标、中文产品名与快捷方式、内部升级和打印机身份 |
| Windows 顾客版 | [42584685346](https://github.com/553421138/rustdesk-nas-client/actions/runs/42584685346) | 同上，并核验顾客限制标记及独立身份 |
| Intel Mac 完整端 | [42579669169](https://github.com/553421138/rustdesk-nas-client/actions/runs/42579669169) | 原生启动、全新配置、中文名称、实际公共同步接口、ICNS 及签名 |
| Intel Mac 顾客版 | [42579672367](https://github.com/553421138/rustdesk-nas-client/actions/runs/42579672367) | 同上，并核验保存密码模式无法替换点击接受 |
| Apple 芯片顾客版 | [42579676006](https://github.com/553421138/rustdesk-nas-client/actions/runs/42579676006) | 原生 ARM 启动、全新配置、中文名称、实际公共同步接口、ICNS、签名及点击接受 |

五个桌面目标均通过三项显示名称、账号/地址簿开关和 Mac 快捷键路由回归测试；三个顾客目标另各通过两项连接限制测试。Mac 的原生安装包检查运行号记录在 `remote-connect-verification.json`。

Android 和 Linux 的原生核心来自 [42576659128](https://github.com/553421138/rustdesk-nas-client/actions/runs/42576659128)，源码 `ab4e38ad864d6c5a0b9e37e393ccf5752d29c208`。Android 通用包在 [42581751492](https://github.com/553421138/rustdesk-nas-client/actions/runs/42581751492) 使用该次的三个原生库和桥接文件重新包装，AppImage 在 [42581753354](https://github.com/553421138/rustdesk-nas-client/actions/runs/42581753354) 从同一次已核验 DEB 包装；两次包装的源码为 `9ff4b7645010593fc2b7d13515631acd76216815`。后续非对应平台改动和下载修复没有替换这批原生库，各包的实际原生与包装提交分别记录，未将后续文档提交冒充为原生构建提交。

Android 已核验固定签名、三种架构内置服务器配置、中文启动器名称和五种尺寸的实际图标。Linux 已运行全新配置 CLI、读取实际动态库的显示名和账号开关，并通过配置的公网域名向服务器注册；AppImage 核心与已核验 DEB 完全相同。Linux 注册测试使用 Docker 网络，并非独立外部设备。

Mac 的 `Control + ←/→` 已通过路由及松键配对自动测试；真实 Mac 的 Mission Control 快捷键、跨网画面和键鼠、系统权限以及顾客接受弹窗仍需实际试连。Mac 采用临时签名，未使用开发者签名或公证。完整校验值、各包对应源码、构建与测试证据见 `remote-connect-verification.json`。

## 前一批 RustDesk NAS 构建与验证

完整端 Windows x64、Android、Intel Mac、Linux x64 均已编译完成，对应源码提交为 [`b38e428a6d48309600c13e538bef8591f1f98a6b`](https://github.com/553421138/rustdesk-nas-client/tree/b38e428a6d48309600c13e538bef8591f1f98a6b)。[完整端构建记录](https://github.com/553421138/rustdesk-nas-client/actions/runs/42546516007)中的上述平台任务均成功；运行总状态显示取消，是因为取消了暂缓的 Apple 芯片 Mac 任务。

已核验 Windows 便携包核心中的内置配置、Android 的固定签名及三个架构的内置配置、Linux 在全新配置下读取服务器设置并成功注册。AppImage 中的核心与已测试的 DEB 相同。Intel Mac 的实际打包程序已在全新配置下启动，并读取到内置服务器地址、中继和公钥，见 [Mac 安装包启动检查](https://github.com/553421138/rustdesk-nas-client/actions/runs/42552758534)。

[外网端口检查](https://github.com/553421138/rustdesk-nas-client/actions/runs/42554192533)已从 GitHub 外部构建机确认 TCP 21115、21116、21117 可达，并收到 UDP 21116 的 RustDesk 协议回应。

顾客版 Windows x64 和 Intel Mac 已完成[编译、原生限制测试与打包](https://github.com/553421138/rustdesk-nas-client/actions/runs/42550744536)，对应源码为 [`c2c7479f28f3d673b0088b1ebf79040d619b9fc7`](https://github.com/553421138/rustdesk-nas-client/tree/c2c7479f28f3d673b0088b1ebf79040d619b9fc7)。

Windows 顾客版的 EXE 和 MSI 已核验内置配置、主动连接限制标记和独立应用身份。Intel Mac 顾客版已核验应用标识、Intel 架构和 DMG 完整性；[实际安装包启动检查](https://github.com/553421138/rustdesk-nas-client/actions/runs/42558973698)确认全新配置下的服务器、公钥和点击确认模式正确，保存密码模式也无法替换点击确认。

Apple 芯片 Mac 顾客版也已完成[原生 ARM 编译、两项限制测试与打包](https://github.com/553421138/rustdesk-nas-client/actions/runs/42560144179)，对应源码为 [`7f8a5024f20759c262fcd990e05e48a8bf0e6ebd`](https://github.com/553421138/rustdesk-nas-client/tree/7f8a5024f20759c262fcd990e05e48a8bf0e6ebd)，最低 macOS 12.3。DMG 完整性、ARM64 核心及独立应用标识已核验；[实际 ARM 安装包启动检查](https://github.com/553421138/rustdesk-nas-client/actions/runs/42563946712)确认启动程序和核心均为原生 ARM 架构，全新配置下的服务器、公钥和点击确认模式正确，保存密码模式也无法替换点击确认。

真实设备上的画面、键盘鼠标、系统权限和逐次点击接受仍需实际试连。

顾客工作流在 Windows 和 macOS 上运行 `nas_customer_tests`，验证各类主动连接被拒绝，以及保存的密码模式无法替换点击确认。本次 Windows、Intel Mac 和 Apple 芯片 Mac 的该步骤均已通过；重新构建时以新的 Actions 结果为准。

## 前一批配置与顾客限制的改动范围

已对照固定版本的上游源码检查所有现有文件改动，运行路径只改动以下四处：

- `libs/hbb_common/src/config.rs`：为两种版本固定服务器、公钥和更新设置；顾客版另使用独立应用身份、强制点击确认和仅被控标志。这是让客户端无需填写配置，以及不复用普通版配置/进程所必需的。
- `src/client.rs`：顾客版在任何主动连接、IPC 或角色切换例外之前拒绝请求，防止绕过界面限制；完整端继续执行原有逻辑。
- `src/server/connection.rs`：顾客版忽略切换控制方向请求，关闭锁屏密码免确认例外，保证每次由顾客接受；完整端继续执行原有逻辑。
- `flutter/android/app/build.gradle`：仅更换 Android applicationId，让个人签名应用可与官方应用并存；原有 JNI/Flutter 接口不变。

已有构建辅助文件的必要改动也已逐项核对：`.github/workflows/bridge.yml` 只保留本次各平台使用的 Flutter 桥接生成任务；`.github/workflows/third-party-RustDeskTempTopMostWindow.yml` 去掉必填输入的默认值，由调用方明确提供 Windows 构建参数。两者限制任务时长和产物保留期，减少公共构建资源占用；保留上游排版以缩小对照差异，恢复排版前后的解析结果相同。

其余修改为新增的构建和安装包检查工作流、说明、版本清单和两项顾客行为回归测试；未加入其他功能或整理既有实现。Apple 芯片顾客版复用上述运行路径，只增加 ARM 构建流程和 Mac 安装包检查的架构选择。未设置顾客编译变量时，顾客专用分支不生效。

`personal-build.json` 记录内置的公开网络配置和源码摘要。本源码目录不包含服务器私钥、远程控制密码或 API 凭据。

## 远程连接定制更新

三个工作流均设置 `RUSTDESK_NAS_DISPLAY_NAME=远程连接`。完整端显示为“远程连接”，顾客版显示为“远程连接（顾客版）”。该定制构建关闭账号和在线地址簿入口，最近连接、收藏、局域网发现继续使用。内部 RustDesk / RustDeskCustomer 名称、配置路径、URI 和应用标识用于延续已有安装。

Mac 控制端保留本机 Control + ←/→ 给系统切换 Spaces，左右箭头不发送到远端。Control 本身仍可用于远端复制等组合键。仅该定制 Mac 构建启用此处理，不改动其他平台的键盘路径或模拟松键路径。Mac 需启用 Mission Control 的“向左/向右移动一个空间”快捷键并创建多个桌面；真实键盘和屏幕操作需实机试连验证。

正式图标采用双窗口连接、墨蓝与暖白的矢量设计，源文件、概念图和导出说明见 `res/branding/README.md`。图标里不含文字。Mac 通过本地化名称保留稳定的应用包路径，资源修改后重新签名。

本次现有文件及运行路径的必要改动（新逻辑放在独立模块）：

- `.github/workflows/check-macos-package.yml`：对实际 DMG 增加可选的中文名称、图标、签名和账号开关检查，读取真实动态库的公共同步接口；原有包检查保留。
- `.github/workflows/customer-apple-silicon.yml`：ARM 顾客构建传入定制名称、运行原生回归测试，并在打包前写入本地化名称和重新签名。
- `.github/workflows/customer-build.yml`：Windows 与 Intel Mac 顾客构建传入定制名称、运行原生回归测试，并完成平台名称和图标包装。
- `.github/workflows/personal-build.yml`：各完整端构建传入定制名称；Windows 与 Intel Mac 运行原生回归测试，并完成平台名称和图标包装。
- `appimage/AppImageBuilder-x86_64.yml`：AppImage 桌面入口显示新名称，可执行路径保留。
- `flutter/android/app/src/main/AndroidManifest.xml`：Android 启动器、输入服务显示中文名称。
- `flutter/android/app/src/main/res/mipmap-hdpi/ic_launcher.png`：替换该平台实际使用的应用、通知或托盘图标；只修改静态显示资源。
- `flutter/android/app/src/main/res/mipmap-hdpi/ic_launcher_foreground.png`：替换该平台实际使用的应用、通知或托盘图标；只修改静态显示资源。
- `flutter/android/app/src/main/res/mipmap-hdpi/ic_launcher_round.png`：替换该平台实际使用的应用、通知或托盘图标；只修改静态显示资源。
- `flutter/android/app/src/main/res/mipmap-hdpi/ic_stat_logo.png`：替换该平台实际使用的应用、通知或托盘图标；只修改静态显示资源。
- `flutter/android/app/src/main/res/mipmap-mdpi/ic_launcher.png`：替换该平台实际使用的应用、通知或托盘图标；只修改静态显示资源。
- `flutter/android/app/src/main/res/mipmap-mdpi/ic_launcher_foreground.png`：替换该平台实际使用的应用、通知或托盘图标；只修改静态显示资源。
- `flutter/android/app/src/main/res/mipmap-mdpi/ic_launcher_round.png`：替换该平台实际使用的应用、通知或托盘图标；只修改静态显示资源。
- `flutter/android/app/src/main/res/mipmap-mdpi/ic_stat_logo.png`：替换该平台实际使用的应用、通知或托盘图标；只修改静态显示资源。
- `flutter/android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`：替换该平台实际使用的应用、通知或托盘图标；只修改静态显示资源。
- `flutter/android/app/src/main/res/mipmap-xhdpi/ic_launcher_foreground.png`：替换该平台实际使用的应用、通知或托盘图标；只修改静态显示资源。
- `flutter/android/app/src/main/res/mipmap-xhdpi/ic_launcher_round.png`：替换该平台实际使用的应用、通知或托盘图标；只修改静态显示资源。
- `flutter/android/app/src/main/res/mipmap-xhdpi/ic_stat_logo.png`：替换该平台实际使用的应用、通知或托盘图标；只修改静态显示资源。
- `flutter/android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`：替换该平台实际使用的应用、通知或托盘图标；只修改静态显示资源。
- `flutter/android/app/src/main/res/mipmap-xxhdpi/ic_launcher_foreground.png`：替换该平台实际使用的应用、通知或托盘图标；只修改静态显示资源。
- `flutter/android/app/src/main/res/mipmap-xxhdpi/ic_launcher_round.png`：替换该平台实际使用的应用、通知或托盘图标；只修改静态显示资源。
- `flutter/android/app/src/main/res/mipmap-xxhdpi/ic_stat_logo.png`：替换该平台实际使用的应用、通知或托盘图标；只修改静态显示资源。
- `flutter/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`：替换该平台实际使用的应用、通知或托盘图标；只修改静态显示资源。
- `flutter/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_foreground.png`：替换该平台实际使用的应用、通知或托盘图标；只修改静态显示资源。
- `flutter/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_round.png`：替换该平台实际使用的应用、通知或托盘图标；只修改静态显示资源。
- `flutter/android/app/src/main/res/mipmap-xxxhdpi/ic_stat_logo.png`：替换该平台实际使用的应用、通知或托盘图标；只修改静态显示资源。
- `flutter/android/app/src/main/res/values/ic_launcher_background.xml`：Android 自适应图标使用墨蓝底色。
- `flutter/android/app/src/main/res/values/strings.xml`：Android 系统应用名称使用新品牌。
- `flutter/lib/common.dart`：只修改窗口标题 getter，打印机筛选仍使用原内部身份。
- `flutter/lib/desktop/pages/desktop_home_page.dart`：更新提示使用新显示接口。
- `flutter/lib/main.dart`：主应用标题使用新显示接口。
- `flutter/lib/mobile/pages/home_page.dart`：移动主页名称使用新显示接口。
- `flutter/lib/web/bridge.dart`：为新增显示接口手写 Web 包装，Web 保留原有名称。
- `flutter/macos/Runner/AppIcon.icns`：替换该平台实际使用的应用、通知或托盘图标；只修改静态显示资源。
- `flutter/windows/runner/Runner.rc`：Windows 产品属性显示中文名称。
- `flutter/windows/runner/resources/app_icon.ico`：替换该平台实际使用的应用、通知或托盘图标；只修改静态显示资源。
- `libs/hbb_common/src/config.rs`：在共享账号、地址簿开关处固定关闭定制构建的账号功能。
- `libs/portable/build.rs`：Windows 便携启动器文件属性显示新名称。
- `personal-build.json`：记录定制参数与配置源码摘要，保留前一批包的构建记录。
- `res/128x128.png`：替换该平台实际使用的应用、通知或托盘图标；只修改静态显示资源。
- `res/128x128@2x.png`：替换该平台实际使用的应用、通知或托盘图标；只修改静态显示资源。
- `res/32x32.png`：替换该平台实际使用的应用、通知或托盘图标；只修改静态显示资源。
- `res/64x64.png`：替换该平台实际使用的应用、通知或托盘图标；只修改静态显示资源。
- `res/icon.ico`：替换该平台实际使用的应用、通知或托盘图标；只修改静态显示资源。
- `res/icon.png`：替换该平台实际使用的应用、通知或托盘图标；只修改静态显示资源。
- `res/mac-icon.png`：替换该平台实际使用的应用、通知或托盘图标；只修改静态显示资源。
- `res/mac-tray-dark-x2.png`：替换该平台实际使用的应用、通知或托盘图标；只修改静态显示资源。
- `res/msi/Package/Components/Folders.wxs`：开始菜单使用显示名，安装和配置目录保留内部身份。
- `res/msi/Package/Components/RustDesk.wxs`：托盘快捷方式清理匹配显示名，打印机参数保留内部名，防止改名破坏设备识别。
- `res/msi/Package/Package.wxs`：安装程序产品名使用显示名称。
- `res/msi/preprocess.py`：独立显示名称和中文代码页，保留内部产品名和升级标识。
- `res/rustdesk-link.desktop`：Linux URI 桌面入口显示新名称。
- `res/rustdesk.desktop`：Linux 桌面入口显示新名称。
- `res/scalable.svg`：替换该平台实际使用的应用、通知或托盘图标；只修改静态显示资源。
- `res/tray-icon.ico`：替换该平台实际使用的应用、通知或托盘图标；只修改静态显示资源。
- `src/flutter.rs`：原生 Windows 窗口标题和同版本窗口查找使用可见名称。
- `src/flutter_ffi.rs`：增加只用于显示名称的接口，原内部身份接口保留。
- `src/keyboard.rs`：Mac 抓键和 Flutter 键盘入口添加 Spaces 过滤，向本机保留 Control 事件。
- `src/lang.rs`：定制构建的提示使用新名称，保留上游署名例外。
- `src/lib.rs`：注册独立的定制显示模块。
- `src/tray.rs`：托盘提示显示新名称，内部托盘标识保留。

新增三项回归测试：显示名称与内部身份/账号开关，以及两项快捷键路由和松键配对行为。此前两项顾客连接限制测试保留，并继续在 Windows、Intel Mac 和 ARM Mac 原生运行。未在本机生成桥接代码，新增 FFI 的原生绑定由现有 CI 生成，Web 包装已手写补全。未设置定制编译变量时，运行时代码仍走原有路径；静态名称和图标资源属于该源码分支的品牌替换。

本说明文件 `PERSONAL-BUILD.md` 本身仅补充本次功能、验证与必要改动范围。

- `src/core_main.rs`：Windows URI 唤起查找与新窗口标题一致的显示名；配置、服务和 URI 身份保持不变。
- `src/platform/windows/msi_registry.rs`：识别新安装包的中文显示名，同时继续接受旧安装名称，防止改名影响卸载入口和安装状态判断。
- `res/msi/CustomActions/RemotePrinter.cpp` 与 `res/msi/Package/Package.wxs`：打印机升级检测从独立的内部名称属性读取原有设备身份，避免用中文显示名查找旧打印机。

Mac 安装包检查在可选品牌核验中读取实际 dylib 的公共同步接口，核对中文名称、内部身份、账号和地址簿开关。新增的 `res/branding/verify_library.py` 只使用 Python 标准库读取既有 FFI，不增加生产接口或应用依赖。Linux 包也使用同一读取方式核验。

AppImage 配方同时保留中文桌面显示名和固定的构建文件名，防止改名改变产物匹配路径。新增 `.github/workflows/package-appimage.yml` 可使用已完成构建的 DEB 单独打包并记录对应运行号，无需重复编译其他平台；使用相同的 AppRun 源码和打包命令。

Mac 的托盘图标读取路径跳过通用彩色 PNG，使用已编译的单色模板，防止新 PNG 覆盖模板后显示成实心方块。该改动仅针对定制 Mac 分支；Windows、Linux 和原版构建路径不变。完整端与顾客版构建工作流增加可选 `mac-only` 输入，默认仍构建全部平台，用于只重编 Intel Mac；ARM 顾客版继续使用独立工作流。

Android 包装重试：`flutter/android/build.gradle` 在保留现有仓库的同时优先加入 Maven Central，避免 Kotlin 编译依赖绕到 JCenter 失效链接而收到 504。新增 `.github/workflows/package-android.yml` 可从同一次源构建的 bridge 和三个已编译 Android 库重新生成并签名通用 APK；不重新编译 Rust 库。此调整只改变依赖下载及包装流程。

Android 通用包与 AppImage 包装工作流通过 GitHub Release API 预取官方 Gradle 8.11.1 和 AppRun v2.0.0 hooks，再用固定 SHA-256 核对，以绕过普通发布下载链接持续返回 504。Gradle 仅在包装任务的临时工作区使用本地校验过的 ZIP；应用源码和 Gradle 版本不变。AppRun 主程序仍使用此前已固定源码和校验值的构建方式。

Windows 顾客版工作流为 USB 虚拟显示驱动使用相同的官方 GitHub Release API 下载及固定 SHA-256，修复完整编译后普通下载链接返回 504 的阻塞。增加可选 `windows-only` 输入以只重试该平台，默认构建范围不变；顾客版运行时代码不变。

Windows MSI 的 `Package/@Codepage` 显式引用已生成的 `SummaryCodepage`，使中文名称使用 936，避免 WiX UI 本地化资源先加载的 1252 覆盖数据库编码；原版仍为 1252。两个 Windows 工作流从 Release API 预取被固定 vcpkg 版本要求的 Ninja 文件，由 vcpkg 自身固定 SHA-512 再次核对。完整端同样增加 `windows-only` 重试输入。Windows 打包前保留已通过测试的编译载荷，后续 MSI 包装重试可以复用，避免因工具下载或 MSI 错误丢失已编译结果。

Windows 顾客版的 vcpkg 工具预取同时包含其实际要求的 CMake 4.4.0，使用同样的官方 Release API，下载后由 vcpkg 的工具校验值核验。此修改只处理构建机依赖下载。

## 关闭定制版本更新与 Windows 维护脚本

补齐此前漏掉的更新配置路径：启动检查更新使用 `LocalConfig` 的 `enable-check-update`，原先将此键放在服务的 `OVERWRITE_SETTINGS` 中，不能覆盖界面本地配置。现在在定制构建的 `OVERWRITE_LOCAL_SETTINGS` 中固定为 `N`，同时从程序中阻止官方更新查询、更新包下载和后台更新调度，隐藏更新提示及开关。此修改同时适用于完整端和顾客版，需要重新编译后进入二进制；已有安装包没有因此发生变化。

本次既有文件及运行路径的必要改动：

- `libs/hbb_common/src/config.rs`：仅在定制构建中锁定本地检查更新选项，修复上述配置层放错的问题。
- `src/nas_customization.rs`：增加由现有定制编译变量判定的禁更策略；不引入运行时状态。
- `src/common.rs`：更新查询返回空结果并清除缓存地址；通过既有同步内置选项接口向界面暴露禁更标志，无需新增 FFI 或重新生成桥接代码。
- `src/updater.rs`：定制版本不启动 Windows/macOS 更新调度；手动检查和 macOS root 更新入口也被禁用，防止服务配置或手动调用绕过。
- `src/updater/download.rs`：定制版本拒绝取得官方更新包，包括已有更新进度页或缓存路径，避免通过下载入口覆盖程序。
- `flutter/lib/common.dart`：读取既有同步接口中的禁更标志，在注册更新事件和计时器前退出。
- `flutter/lib/desktop/pages/desktop_home_page.dart`：隐藏定制版本的更新卡片和升级入口。
- `flutter/lib/desktop/pages/desktop_setting_page.dart`：隐藏定制版本的检查更新、自动升级复选框。
- 本说明文件：记录原因、改动范围与验证限制。

未设置定制名称编译变量、也不是顾客版时，所有新增分支均不生效；上游原有更新实现保持。没有调整安装、卸载、服务器协议、远控授权或输入处理路径。

新增 `res/nas/Disable-Updates.bat` 和 `Repair-Customer-Service.bat`，共用 `Windows-Maintenance.ps1`。前者为当前 Windows 用户及服务配置关闭更新；后者修复已安装的定制顾客版服务、恢复本项目服务器配置、每次点击确认及对应程序防火墙规则，并关闭更新。两个脚本均在修改前备份涉及的配置文件，保留设备 ID、密码等其他字段。说明见 `res/nas/README.md`。

此批次正重新编译全部八个分发包，并执行原生包检查。最终结果以分发包内的验证记录为准。脚本不能从既有二进制中移除更新入口，不能把已被官方程序覆盖的版本恢复为顾客版；这类情况需重新安装定制版本。


## 2026-11-12 更新批次

定制版本通过既有 `hide-server-settings` 内置选项隐藏桌面和 Android 的自建服务器设置入口；桌面底部的自建服务器引导也隐藏。服务器地址和公钥仍编译在程序中。必要运行路径改动仅为 `src/common.rs` 返回该既有选项以及 `flutter/lib/desktop/pages/connection_page.dart` 隐藏引导，账号、远控授权和连接协议不变。

在现有 `nas_customization_tests` 中补充两项回归检查：旧配置试图重新开启更新时仍返回关闭，界面得到禁更及隐藏服务器设置标记；手动官方更新被拒绝且启动查询不留下更新地址。使用已有 CI 的原生 Rust 测试入口执行。Windows 包检查修正为读取服务实际使用的 LocalService 配置，并解析 Windows PowerShell 5 维护脚本。Mac 原生安装包检查通过既有同步 FFI 读取禁更与隐藏服务器设置标记。个人构建流程复用已验证的 Gradle 和 AppRun 官方下载及哈希校验方式，避免包装阶段再次使用失效链接。

顾客版橙色问题：旧 Windows 便携包与 MSI 在全新原生环境均可完成真实服务器注册；这不能证明用户现有机器已恢复。维护脚本用于修复已有安装的配置与服务，不删除 ID、收藏或历史记录。

Android 的 `flutter/lib/mobile/pages/settings_page.dart` 与 `connection_page.dart` 同样隐藏检查更新开关和下载新版本卡片，与既有后端禁更策略一致。个人 Windows 构建同步预取被固定 vcpkg 要求的 CMake 4.4.0，避免与顾客版相同的工具下载阻塞。
