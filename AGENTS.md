# jipaiban-releases Agent Notes

This is the **public product-release** repo for 极排班.

## Role

- Public GitHub repository so anyone can download binaries without signing in.
- Git tree: docs and `scripts/publish-release.sh` only.
- Binaries: GitHub Release assets only.
- Source stays in private repos. Server deploy stays in `jipaiban-api`.

## Process

Follow `docs/release-process.md`. Notes from `docs/release-notes-template.md`.

```bash
./scripts/publish-release.sh --tag vX.Y.Z --title "极排班 vX.Y.Z" --notes-file <file> --ipa <ipa> --apk <apk>
```

Use `--dry-run` before a real publish.

## Hard rules

- Never commit source, secrets, keystores, provisioning profiles, `.env`, IPA, APK, AAB, or xcarchive.
- Never publish debug / unsigned / dirty / dev artifacts.
- Tags are `vMAJOR.MINOR.PATCH`. Do not retarget a published tag.
- If asked to 发版 a client installable, build in `jipaiban-ios` or `ji_paiban` first, then publish the finished file here.
- If asked to 发版 the API or admin site, do not use this repo.
