# RustDesk NAS 个人内置版

此源码基于官方 RustDesk 1.5.1 和该版本固定的 hbb_common 提交，已在 Rust 公共配置层内置：

- ID 服务器：`nas.hk-beautyshop.cn:21116`
- 中继服务器：`nas.hk-beautyshop.cn:21117`
- Key：`GevVI6bnGZ79VB8CAJ9InRZ3o566YJDQZW5mTOCGri4=`
- API 服务器：空

这些配置随各平台二进制一起编译，首次打开无需输入服务器配置。网络设置在该个人版本中固定；远程控制密码和设备授权沿用原版流程。

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

`personal-build.json` 记录内置的公开网络配置和源码摘要。本源码目录不包含服务器私钥、远程控制密码或 API 凭据。
