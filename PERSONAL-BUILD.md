# RustDesk NAS 个人内置版

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

## 已完成的构建与验证

完整端 Windows x64、Android、Intel Mac、Linux x64 均已编译完成，对应源码提交为 [`b38e428a6d48309600c13e538bef8591f1f98a6b`](https://github.com/553421138/rustdesk-nas-client/tree/b38e428a6d48309600c13e538bef8591f1f98a6b)。[完整端构建记录](https://github.com/553421138/rustdesk-nas-client/actions/runs/42546516007)中的上述平台任务均成功；运行总状态显示取消，是因为取消了暂缓的 Apple 芯片 Mac 任务。

已核验 Windows 便携包核心中的内置配置、Android 的固定签名及三个架构的内置配置、Linux 在全新配置下读取服务器设置并成功注册。AppImage 中的核心与已测试的 DEB 相同。Intel Mac 的实际打包程序已在全新配置下启动，并读取到内置服务器地址、中继和公钥，见 [Mac 安装包启动检查](https://github.com/553421138/rustdesk-nas-client/actions/runs/42552758534)。

[外网端口检查](https://github.com/553421138/rustdesk-nas-client/actions/runs/42554192533)已从 GitHub 外部构建机确认 TCP 21115、21116、21117 可达，并收到 UDP 21116 的 RustDesk 协议回应。

顾客版 Windows x64 和 Intel Mac 已完成[编译、原生限制测试与打包](https://github.com/553421138/rustdesk-nas-client/actions/runs/42550744536)，对应源码为 [`c2c7479f28f3d673b0088b1ebf79040d619b9fc7`](https://github.com/553421138/rustdesk-nas-client/tree/c2c7479f28f3d673b0088b1ebf79040d619b9fc7)。

Windows 顾客版的 EXE 和 MSI 已核验内置配置、主动连接限制标记和独立应用身份。Intel Mac 顾客版已核验应用标识、Intel 架构和 DMG 完整性；[实际安装包启动检查](https://github.com/553421138/rustdesk-nas-client/actions/runs/42558973698)确认全新配置下的服务器、公钥和点击确认模式正确，保存密码模式也无法替换点击确认。

Apple 芯片 Mac 顾客版也已完成[原生 ARM 编译、两项限制测试与打包](https://github.com/553421138/rustdesk-nas-client/actions/runs/42560144179)，对应源码为 [`7f8a5024f20759c262fcd990e05e48a8bf0e6ebd`](https://github.com/553421138/rustdesk-nas-client/tree/7f8a5024f20759c262fcd990e05e48a8bf0e6ebd)，最低 macOS 12.3。DMG 完整性、ARM64 核心及独立应用标识已核验；[实际 ARM 安装包启动检查](https://github.com/553421138/rustdesk-nas-client/actions/runs/42563946712)确认启动程序和核心均为原生 ARM 架构，全新配置下的服务器、公钥和点击确认模式正确，保存密码模式也无法替换点击确认。

真实设备上的画面、键盘鼠标、系统权限和逐次点击接受仍需实际试连。

顾客工作流在 Windows 和 macOS 上运行 `nas_customer_tests`，验证各类主动连接被拒绝，以及保存的密码模式无法替换点击确认。本次 Windows、Intel Mac 和 Apple 芯片 Mac 的该步骤均已通过；重新构建时以新的 Actions 结果为准。

## 代码改动范围

已对照固定版本的上游源码检查所有现有文件改动，运行路径只改动以下四处：

- `libs/hbb_common/src/config.rs`：为两种版本固定服务器、公钥和更新设置；顾客版另使用独立应用身份、强制点击确认和仅被控标志。这是让客户端无需填写配置，以及不复用普通版配置/进程所必需的。
- `src/client.rs`：顾客版在任何主动连接、IPC 或角色切换例外之前拒绝请求，防止绕过界面限制；完整端继续执行原有逻辑。
- `src/server/connection.rs`：顾客版忽略切换控制方向请求，关闭锁屏密码免确认例外，保证每次由顾客接受；完整端继续执行原有逻辑。
- `flutter/android/app/build.gradle`：仅更换 Android applicationId，让个人签名应用可与官方应用并存；原有 JNI/Flutter 接口不变。

已有构建辅助文件的必要改动也已逐项核对：`.github/workflows/bridge.yml` 只保留本次各平台使用的 Flutter 桥接生成任务；`.github/workflows/third-party-RustDeskTempTopMostWindow.yml` 去掉必填输入的默认值，由调用方明确提供 Windows 构建参数。两者限制任务时长和产物保留期，减少公共构建资源占用；保留上游排版以缩小对照差异，恢复排版前后的解析结果相同。

其余修改为新增的构建和安装包检查工作流、说明、版本清单和两项顾客行为回归测试；未加入其他功能或整理既有实现。Apple 芯片顾客版复用上述运行路径，只增加 ARM 构建流程和 Mac 安装包检查的架构选择。未设置顾客编译变量时，顾客专用分支不生效。

`personal-build.json` 记录内置的公开网络配置和源码摘要。本源码目录不包含服务器私钥、远程控制密码或 API 凭据。
