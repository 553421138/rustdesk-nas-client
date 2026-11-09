# RustDesk NAS 个人内置版

此源码基于官方 RustDesk 1.5.1 和该版本固定的 hbb_common 提交，已在 Rust 公共配置层内置：

- ID 服务器：`nas.hk-beautyshop.cn:21116`
- 中继服务器：`nas.hk-beautyshop.cn:21117`
- Key：`GevVI6bnGZ79VB8CAJ9InRZ3o566YJDQZW5mTOCGri4=`
- API 服务器：空

这些配置随各平台二进制一起编译，首次打开无需输入服务器配置。网络设置在该个人版本中固定；远程控制密码和设备授权沿用原版流程。

## 完整端与顾客版

完整端供服务人员使用，保留原有控制和被控功能。顾客版仅提供 Windows x64 和 Intel Mac：

- 顾客打开软件，把本机 ID（连接码）提供给服务人员。
- 服务人员使用完整端输入 ID 发起连接，顾客点击“接受”后才能控制，无需提供密码。
- 顾客版隐藏主动连接面板，底层拒绝向 ID、IP、域名发起远控、文件传输、隧道等连接。
- 会话中的“切换控制方向”也被拒绝；锁屏密码登录不绕过顾客确认。
- “点击接受”模式随程序编译并锁定，已有配置中的密码模式不会替换它。
- 应用名为 `RustDeskCustomer`，使用独立配置和进程通信名称，避免唤起已经运行的普通版；Windows 免安装包也使用独立解压目录，Mac 使用独立应用标识。

在 Actions 中手动启动 **Build customer incoming-only RustDesk clients**。其工作流为 `.github/workflows/customer-build.yml`，编译时设置 `RUSTDESK_NAS_EDITION=customer`；完整端不设置这个变量。顾客版产物名称包含 `Customer`，文件名包含 `customer`，分发时应保留这个标记。仅被控限制适用于该顾客版程序。

Mac 首次使用仍需由设备用户在系统设置中允许屏幕录制和辅助功能；这些系统权限无法由安装包预先授予。

修改位于 `libs/hbb_common/src/config.rs`，包括默认服务器列表、服务器公钥和运行时网络选项覆盖。自动检查更新与自动更新已关闭，升级时应重新构建个人版本。

Android 的 applicationId 为 `cn.hkbeautyshop.rustdesk`，可以与官方客户端并存。

## 编译

`.github/workflows/personal-build.yml` 提供手动启动的 GitHub Actions 构建。源代码提交到你自己的仓库后，在 Actions 中选择 **Build personal RustDesk NAS clients** 并启动。

目标包括 Windows x64 EXE、Android 各架构及通用 APK、macOS Intel DMG、Linux x64 DEB/AppImage。安装包仅保存为 Actions artifacts，不发布公开 Release，保留 7 天。Apple 芯片 Mac 版本暂缓。

此目录已经将 hbb_common 固定版本作为普通源文件放入，不依赖保留上游 Git 子模块索引。

原版 Windows/macOS 签名证书不属于此个人构建。macOS 系统首次运行可能需要在系统设置中允许打开个人构建的应用。Android 使用个人固定签名密钥，通过以下仓库 Secrets 配置；所有架构及后续版本共用该签名，可直接升级安装：

- `ANDROID_SIGNING_KEY`：keystore 文件的 Base64
- `ANDROID_ALIAS`
- `ANDROID_KEY_STORE_PASSWORD`
- `ANDROID_KEY_PASSWORD`

未配置这些 Secrets 时，上游流程生成调试签名 APK，适合临时测试。正式自用时应保留个人签名密钥的备份，避免更换签名后无法覆盖安装。

**当前状态：源码和工作流已准备；尚未完成平台编译或真机运行验证。**

顾客工作流还会在 Windows 和 macOS 上运行 `nas_customer_tests`，验证各类主动连接被拒绝，以及保存的密码模式无法替换点击确认。平台编译、测试与打包结果以对应 Actions 运行为准。

新增顾客功能涉及的现有运行路径：`libs/hbb_common/src/config.rs` 提供编译版本判断、强制点击确认和仅被控标志；`src/client.rs` 在建立任何主动连接前拒绝顾客端；`src/server/connection.rs` 禁止顾客端处理控制方向切换，并关闭锁屏密码免确认例外。未设置顾客编译变量时保留完整端原有路径。其余修改仅涉及构建工作流、说明和版本清单。

`personal-build.json` 记录内置的公开网络配置和源码摘要。本源码目录不包含服务器私钥、远程控制密码或 API 凭据。
