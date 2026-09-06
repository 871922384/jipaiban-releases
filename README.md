# 极排班

医护排班应用。本仓库**只放成品安装包**，不含源码。

[最新下载](https://github.com/871922384/jipaiban-releases/releases/latest)

[产品页与测试版入口](https://871922384.github.io/jipaiban-releases/)

测试版安装入口需要批准的测试网络访问权限：
https://rexmacbook-air.tail3e5479.ts.net/i

IPA 不上传到 GitHub 文件树，也不作为公开 Release 附件；公开仓只维护产品说明、真实界面图片和访问入口。

## 怎么装

1. **iOS 测试版**：在已获批准的测试网络中打开[固定测试入口](https://rexmacbook-air.tail3e5479.ts.net/i)。
2. **公开成品**：只有经过维护者明确批准的版本才会出现在 [Releases](https://github.com/871922384/jipaiban-releases/releases/latest)。
3. 当前版本不上传 IPA 到 GitHub 文件树或公开 Release；需要公开下载时，必须单独走发布审批。

网页与接口：https://jipaiban.junshian.cn

## 给智能体的公开入口

极排班提供一份可直接读取的公开技能，适用于 WorkBuddy、Claude、Cursor、Grok、Codex 以及其他支持 skills / 远程 MCP 的 Agent。

从[智能体快速接入页](https://github.com/871922384/jipaiban-releases/blob/main/docs/agent.md)开始，里面有三步接入、Guest 与医院账号的能力边界，以及安全规则：

1. 导入 [`skills/jipaiban/`](https://github.com/871922384/jipaiban-releases/tree/main/skills/jipaiban) 目录。
2. 将 `https://jipaiban.junshian.cn/mcp` 添加为远程 MCP。
3. 按 `initialize → tools/list → whoami` 确认身份后再操作班表。

用户只在要保住班表或绑定医院账号时打开[连接页](https://jipaiban.junshian.cn/agent/connect)。不要把配对码或 token 写进 URL；不要向用户索要手机号、验证码或密码。

## 说明

- 包体只作为 Release 附件，不会出现在 Git 文件树里。
- 源码不公开。
- 商店上架后仍以商店为准；这里方便直接下载。

## 维护者

发版流程：[`docs/release-process.md`](docs/release-process.md)  
说明模板：[`docs/release-notes-template.md`](docs/release-notes-template.md)

```bash
./scripts/publish-release.sh \
  --tag v1.0.0 \
  --title "极排班 v1.0.0" \
  --notes-file docs/release-notes-template.md \
  --ipa /path/to/JiPaiban.ipa \
  --apk /path/to/jipaiban.apk
```

不确定时先加 `--dry-run`。
