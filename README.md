# 极排班

医护排班应用。本仓库**只放成品安装包**，不含源码。

[最新下载](https://github.com/871922384/jipaiban-releases/releases/latest)

## 怎么装

1. 打开 [Releases](https://github.com/871922384/jipaiban-releases/releases/latest)
2. 按系统下载：
   - **Android**：`.apk`
   - **iOS**：`.ipa`（需按该版本说明安装，或走 App Store / TestFlight）
3. Android 允许安装未知来源后打开 APK。

网页与接口：https://jipaiban.junshian.cn

## 智能体

把极排班接到 WorkBuddy / Claude / Cursor / Grok：用户打开 [连接页](https://jipaiban.junshian.cn/agent/connect) 生成配对码，智能体按 [`skills/jipaiban/SKILL.md`](skills/jipaiban/SKILL.md) 兑权并调用托管 MCP。

把该目录装进客户端的 skills 路径即可，例如：

```bash
git clone --depth 1 https://github.com/871922384/jipaiban-releases.git
cp -R jipaiban-releases/skills/jipaiban ~/.grok/skills/jipaiban
```

不要把配对码或 token 写进 URL。

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
