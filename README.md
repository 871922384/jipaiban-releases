# 极排班

医护排班应用。本仓库**只放成品安装包**，不含源码。

下载地址：[Releases](https://github.com/871922384/jipaiban-releases/releases)

## 怎么装

1. 打开 [Releases](https://github.com/871922384/jipaiban-releases/releases/latest)
2. 按系统下载对应文件：
   - **Android**：`.apk`（或商店上架后的 `.aab` 不在此下载）
   - **iOS**：`.ipa`（需已加入设备描述文件 / 企业签，或走 App Store）
3. Android 允许安装未知来源后点开 APK。iOS 用电脑安装，或按该版本说明里的安装方式。

网页版与接口：https://jipaiban.junshian.cn

## 说明

- Git 仓库里没有 IPA / APK，包体只作为 Release 附件。
- 源码不公开。
- 对外正式通道仍是应用商店；这里方便直接下载使用。

## 维护者发版

```bash
./scripts/publish-release.sh \
  --tag v1.0.0 \
  --title "极排班 v1.0.0" \
  --notes-file notes.md \
  --ipa /path/to/JiPaiban.ipa \
  --apk /path/to/jipaiban.apk
```

至少提供 `--ipa` 或 `--apk` 之一。不要把包体 `git add` 进仓库。
