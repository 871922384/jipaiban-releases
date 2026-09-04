# 极排班成品发版流程

公开下载仓：https://github.com/871922384/jipaiban-releases  
源码仓保持私有。本仓 Git 树只放说明和发版脚本，包体只作为 GitHub Release 附件。

## 两条发版线，不要混

| 线 | 仓库 | 产物 | 入口 |
|---|---|---|---|
| 服务端 | `jipaiban-api` | 线上 API / 网站 / 管理端静态资源 | `deploy_systemd_release.sh`、`admin_release.sh` |
| 客户端成品 | `jipaiban-ios`、`ji_paiban` 打包装，本仓发布 | 可下载的 IPA / APK / AAB | `./scripts/publish-release.sh` |

「发版」如果是上服务器，走服务端线。如果是给别人下载安装包，走本仓。不要把 debug 包、源码、证书发到本仓。

## 成品标准

可以发到本仓的文件必须同时满足：

- 扩展名只有 `.ipa`、`.apk`、`.aab`
- 文件名不含 `debug`、`unsigned`、`dirty`、`dev`
- 已在源码仓完成对应平台的正式构建（iOS 走 `agent_release.sh` / App Store 通道；Android 走 Flutter release 签名包）
- 能在真机装上并打开，连得上 https://jipaiban.junshian.cn
- 版本号与 tag 一致：`v主版本.次版本.补丁`，例如 `v1.2.0`

不要发：半成品、失败构建、本机 debug、未签名包、xcarchive、密钥、描述文件。

## 版本号

- tag：`vX.Y.Z`
- 同一 tag 只对应一次公开发布
- 漏传文件：给**同一个** Release 追加附件，不要改 tag 指向、不要删历史 Release
- 修包：升补丁号，例如 `v1.2.0` → `v1.2.1`

## 步骤

1. 源码仓 `main` 干净，该合的已合。
2. 若本次改了接口：先在 `jipaiban-api` 部署并冒烟，再打客户端包。
3. 在客户端源码仓打 **release** 包，记下绝对路径。
4. 真机安装一次：能登录、能看到班表。
5. 按 `docs/release-notes-template.md` 写说明，保存为临时文件（不要把密钥写进去）。
6. 发布：

```bash
cd /Users/rex/code/jipaiban-releases
./scripts/publish-release.sh \
  --tag v1.2.0 \
  --title "极排班 v1.2.0" \
  --notes-file /tmp/jipaiban-v1.2.0-notes.md \
  --ipa /绝对路径/极排班.ipa \
  --apk /绝对路径/jipaiban.apk
```

不确定时先加 `--dry-run`，再去掉重跑。

7. 不登录 GitHub 打开这些地址，确认能下：
   - https://github.com/871922384/jipaiban-releases/releases/latest
   - 该版本的 IPA / APK 直链
8. 回复里写：tag、附件、公开下载链接、源码仓 commit（内部记录，不要写进公开说明里的密钥或内网地址）。

## 谁做什么

- 打 iOS 包：`/Users/rex/code/jipaiban-ios`
- 打 Android 包：`/Users/rex/code/ji_paiban`
- 发到公开仓：本仓库 `scripts/publish-release.sh`
- 上 API / 管理端：`/Users/rex/code/jipaiban-api`，与本仓无关
