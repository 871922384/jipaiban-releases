# 贡献说明

这是极排班的**公开成品仓**，不接受源码、功能补丁或把 IPA/APK 直接提交进 Git。公开智能体技能在 [`skills/jipaiban/`](skills/jipaiban/SKILL.md)，不要往里面写密钥、配对码或未公开接口。

- 下载安装包：用 [Releases](https://github.com/871922384/jipaiban-releases/releases)
- 产品页与测试入口：[GitHub Pages](https://871922384.github.io/jipaiban-releases/)
- 问题反馈：在本仓提 Issue，说明机型、系统版本和安装包版本
- 源码与线上服务不在本仓维护

提交前请运行 `./scripts/verify_public_release_repo.sh`。门禁会拒绝 IPA/APK/AAB、签名材料、密钥和生产内网信息进入本仓。
