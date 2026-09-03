# 极排班 · 发版仓库

本仓库**只发布成品**，不存放源码。

源码仍在私有仓库：

- 后端 / 网站契约：`jipaiban-api`
- 管理端：`jipaiban-admin`
- iOS：`jipaiban-ios`
- Flutter（Android / Harmony）：`ji_paiban`
- 微信小程序：`scheduling_wechat`

成品只通过 [GitHub Releases](https://github.com/871922384/jipaiban-releases/releases) 发布：IPA、APK、AAB、安装说明。Git 树上没有包体。

## 安装

- **App Store / TestFlight**：正式对外通道。
- **本仓库 Release**：内部或已授权测试包。从 Releases 下载对应平台文件，不要把包体提交进 Git。
- **iOS 企业/Ad Hoc OTA**：继续走各客户端仓库现有的本机/Tailscale OTA，不把未签名或无法公开下载的包当作通用安装源。

## 发一版

在已登录 `gh` 的机器上：

```bash
./scripts/publish-release.sh \
  --tag v1.0.0 \
  --title "极排班 v1.0.0" \
  --notes-file notes.md \
  --ipa /path/to/JiPaiban.ipa \
  --apk /path/to/jipaiban.apk
```

至少提供 `--ipa` 或 `--apk` 之一。脚本只创建 GitHub Release 并上传附件，不会 `git add` 任何包体。

## 规则

- 不提交源码、密钥、证书、dSYM 之外的调试符号仓库、`.env`
- 不把半成品、失败构建、本地 debug 包发成 Release
- 每个 tag 对应一次可安装成品；需要补文件就给同一 Release 追加资产，不要改历史 tag 指向
