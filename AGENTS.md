# jipaiban-releases Agent Notes

This repository is the **product-release** repo for 极排班.

- This GitHub repository is public so testers and users can download binaries without signing in.
- Source of truth for code remains the private product repos (`jipaiban-api`, `jipaiban-admin`, `jipaiban-ios`, `ji_paiban`, `scheduling_wechat`). Do not copy source here.
- This repo publishes finished installable artifacts only, via GitHub Releases.
- Never commit application source, secrets, keystores, provisioning profiles, or `.env` files here.
- Never `git add` IPA / APK / AAB / xcarchive. Attach them with `./scripts/publish-release.sh`.
- Do not treat this repo as a deploy target for the production API. Server release stays in `jipaiban-api`.
- If asked to "发版" a client build, produce the artifact in the client source repo first, then publish the finished file here.
