#!/bin/bash
# save-config.sh - 解析当前目录 .config, 按规范命名复制到 ../myconfig/
#
# 文件名规范: TARGET-SUBTARGET-SHORT_REPO-BRANCH[-TAG].config
# 例:        qualcommbe-ipq53xx-VIKINGYFY-owrt-stable.config
#
# 用法:
#   ./save-config.sh                       # 自动解析, 无 TAG
#   ./save-config.sh stable                # 带 TAG
#   ./save-config.sh --force custom.config # 强制指定输出文件名

set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE"

# === 仓库参数 (由 Clone Source step 通过 sed 注入) ===
REPO_OWNER="__REPO__"        # e.g. VIKINGYFY/immortalwrt
BRANCH="__BRANCH__"          # e.g. owrt, master, openwrt-25.12
SHORT="__SHORT__"            # e.g. VIKINGYFY

# === 参数解析 ===
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

# === 解析 TARGET / SUBTARGET ===
TARGET=$(grep -m1 -oP '^CONFIG_TARGET_\K[^=_]+(?==y)' .config || echo "")
SUBTARGET=$(grep -m1 -oP "^CONFIG_TARGET_${TARGET}_\K[^=_]+(?==y)" .config || echo "")

if [ -z "$TARGET" ] || [ -z "$SUBTARGET" ]; then
  echo "ERROR: failed to parse TARGET/SUBTARGET from .config"
  head -20 .config
  exit 1
fi

# === 拼接文件名 ===
if [ -n "$OVERRIDE" ]; then
  NAME="$OVERRIDE"
elif [ -n "$TAG" ]; then
  NAME="${TARGET}-${SUBTARGET}-${SHORT}-${BRANCH}-${TAG}.config"
else
  NAME="${TARGET}-${SUBTARGET}-${SHORT}-${BRANCH}.config"
fi

echo "TARGET=$TARGET  SUBTARGET=$SUBTARGET"
echo "SOURCE=$REPO_OWNER @ $BRANCH"
echo "TAG=${TAG:-<none>}"
echo "-> myconfig/$NAME"

mkdir -p ../myconfig
cp -f .config "../myconfig/$NAME"
echo "DONE"
