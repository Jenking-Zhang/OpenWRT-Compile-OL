#!/bin/bash
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE"
REPO_OWNER="__REPO__"
BRANCH="__BRANCH__"
SHORT="__SHORT__"

OVERRIDE=""
TAG=""
while [ $# -gt 0 ]; do
  case "$1" in
    --force) OVERRIDE="$2"; shift 2 ;;
    *) TAG="$1"; shift ;;
  esac
done

if [ ! -f .config ]; then
  echo "ERROR: .config not found in $HERE"
  exit 1
fi

TARGET=$(grep -m1 -oP '^CONFIG_TARGET_\K[^=_]+(?==y)' .config || echo "")
SUBTARGET=$(grep -m1 -oP "^CONFIG_TARGET_${TARGET}_\K[^=_]+(?==y)" .config || echo "")
if [ -z "$TARGET" ] || [ -z "$SUBTARGET" ]; then
  echo "ERROR: failed to parse TARGET/SUBTARGET from .config"
  head -20 .config
  exit 1
fi

if [ -n "$OVERRIDE" ]; then
  NAME="$OVERRIDE"
elif [ -n "$TAG" ]; then
  NAME="${TARGET}-${SUBTARGET}-${SHORT}-${BRANCH}-${TAG}.config"
else
  NAME="${TARGET}-${SUBTARGET}-${SHORT}-${BRANCH}.config"
fi

echo "TARGET=$TARGET SUBTARGET=$SUBTARGET"
echo "SOURCE=$REPO_OWNER @ $BRANCH"
echo "TAG=${TAG:-<none>}"
echo "-> myconfig/$NAME"
mkdir -p ../myconfig
cp -f .config "../myconfig/$NAME"
echo "DONE"
