#!/usr/bin/env bash
# plasma-apply-colorscheme 交替双方案 hook。
# matugen 渲染产物同时落 MaterialYouA.colors 与 MaterialYouB.colors。
# 每次应用与上次相反的方案名，规避同名方案重复 apply 不刷新。
set -euo pipefail

schemes_dir="${XDG_DATA_HOME:-$HOME/.local/share}/color-schemes"
state_file="${XDG_CACHE_HOME:-$HOME/.cache}/materialyou/plasma-last-scheme"
rendered="$schemes_dir/.materialyou-rendered.colors"

mkdir -p "$schemes_dir" "$(dirname "$state_file")"

if [[ ! -f "$rendered" ]]; then
    echo "Warning: rendered scheme not found at $rendered" >&2
    exit 0
fi

# 双文件同内容落盘
cat "$rendered" > "$schemes_dir/MaterialYouA.colors"
cat "$rendered" > "$schemes_dir/MaterialYouB.colors"

last=$(cat "$state_file" 2>/dev/null || echo "MaterialYouB")
if [[ "$last" == "MaterialYouA" ]]; then
    next="MaterialYouB"
else
    next="MaterialYouA"
fi

if command -v plasma-apply-colorscheme >/dev/null 2>&1; then
    plasma-apply-colorscheme "$next" >/dev/null 2>&1 || true
    echo "$next" > "$state_file"
else
    echo "Warning: plasma-apply-colorscheme not found" >&2
fi
