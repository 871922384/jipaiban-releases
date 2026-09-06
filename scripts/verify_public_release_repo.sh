#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "== public release repository safety =="
if find . -path './.git' -prune -o -type f \( -name '*.ipa' -o -name '*.apk' -o -name '*.aab' -o -name '*.xcarchive' -o -name '*.mobileprovision' -o -name '*.p12' -o -name '*.p8' -o -name '*.pem' -o -name '.env' \) -print -quit | grep -q .; then
  echo "release repo safety failed: binary or signing material found in Git tree" >&2
  exit 1
fi

if rg -n --hidden --glob '!.git/**' --glob '!AGENTS.md' --glob '!skills/**' --glob '!scripts/verify_public_release_repo.sh' -- \
  '-----BEGIN (RSA|EC|OPENSSH|PRIVATE) KEY-----|gh[pousr]_[A-Za-z0-9_]{20,}|github_pat_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9_-]{20,}|eyJ[A-Za-z0-9_-]{30,}\.[A-Za-z0-9_-]{20,}|101\.35\.44\.197' .; then
  echo "release repo safety failed: secret or private infrastructure literal found" >&2
  exit 1
fi

test -f docs/index.html
test -f docs/images/week-edit.png
test -f docs/images/month-edit.png
test -f docs/images/statistics.png
test -f docs/images/import-schedule.png
rg -q 'rexmacbook-air\.tail3e5479\.ts\.net/i' docs/index.html
rg -q 'IPA 不上传|IPA.*GitHub' docs/index.html
echo "ok: no installable binaries, secrets, or private infrastructure literals"
echo "ok: product page and real screenshot assets are present"
