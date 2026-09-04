#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

TAG=""
TITLE=""
NOTES_FILE=""
NOTES=""
IPA=""
APK=""
AAB=""
DRAFT=0
DRY_RUN=0
REPO="${RELEASE_REPO:-871922384/jipaiban-releases}"
TAG_RE='^v[0-9]+\.[0-9]+\.[0-9]+$'
BAD_NAME_RE='(debug|unsigned|dirty|dev)'

usage() {
  cat <<'EOF'
Usage:
  ./scripts/publish-release.sh --tag vX.Y.Z --title "..." --notes-file FILE
    [--ipa PATH] [--apk PATH] [--aab PATH] [--draft] [--dry-run]

Creates a GitHub Release and uploads finished artifacts. Does not commit binaries.
See docs/release-process.md.
EOF
}

die() {
  echo "publish-release failed: $*" >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tag) TAG="${2:-}"; shift 2 ;;
    --title) TITLE="${2:-}"; shift 2 ;;
    --notes-file) NOTES_FILE="${2:-}"; shift 2 ;;
    --notes) NOTES="${2:-}"; shift 2 ;;
    --ipa) IPA="${2:-}"; shift 2 ;;
    --apk) APK="${2:-}"; shift 2 ;;
    --aab) AAB="${2:-}"; shift 2 ;;
    --draft) DRAFT=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --repo) REPO="${2:-}"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *) die "unknown argument: $1" ;;
  esac
done

[[ -n "$TAG" ]] || die "--tag is required"
[[ "$TAG" =~ $TAG_RE ]] || die "--tag must look like v1.2.0"
[[ -n "$TITLE" ]] || TITLE="极排班 $TAG"
[[ -n "$IPA" || -n "$APK" || -n "$AAB" ]] || die "provide at least one of --ipa, --apk, or --aab"

if [[ -n "$NOTES_FILE" ]]; then
  [[ -f "$NOTES_FILE" ]] || die "notes file not found: $NOTES_FILE"
  NOTES="$(cat "$NOTES_FILE")"
fi
if [[ "$DRAFT" -eq 0 && -z "$NOTES" ]]; then
  die "non-draft releases require --notes-file or --notes (see docs/release-notes-template.md)"
fi
[[ -n "$NOTES" ]] || NOTES="极排班成品发布 ${TAG}。"

assets=()
for path in "$IPA" "$APK" "$AAB"; do
  [[ -z "$path" ]] && continue
  [[ -f "$path" ]] || die "artifact not found: $path"
  base="$(basename "$path")"
  case "$path" in
    *.ipa|*.apk|*.aab) ;;
    *) die "refusing non-product artifact: $path" ;;
  esac
  if printf '%s' "$base" | grep -Ei "$BAD_NAME_RE" >/dev/null; then
    die "refusing unfinished artifact name: $base"
  fi
  assets+=("$path")
done

command -v gh >/dev/null || die "gh is required"
if [[ "$DRY_RUN" -eq 0 ]]; then
  gh auth status >/dev/null 2>&1 || die "gh is not authenticated"
  if gh release view "$TAG" --repo "$REPO" >/dev/null 2>&1; then
    die "release $TAG already exists on $REPO"
  fi
fi

echo "Publishing $TAG to $REPO"
echo "Title: $TITLE"
echo "Draft: $DRAFT"
echo "Assets:"
printf '  %s\n' "${assets[@]}"

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "Dry run only. No GitHub Release created."
  exit 0
fi

args=(release create "$TAG" --repo "$REPO" --title "$TITLE" --notes "$NOTES")
if [[ "$DRAFT" -eq 1 ]]; then
  args+=(--draft)
fi
args+=("${assets[@]}")

gh "${args[@]}"
echo "Release published: https://github.com/${REPO}/releases/tag/${TAG}"
echo "Latest: https://github.com/${REPO}/releases/latest"
for path in "${assets[@]}"; do
  echo "  https://github.com/${REPO}/releases/download/${TAG}/$(basename "$path")"
done
