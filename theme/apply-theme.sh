#!/usr/bin/env bash
# Material You 取色入口：壁纸/纯色 → matugen → 全链生效
# （Plasma 配色、GTK、kitty、starship、btop、palette.toml）
# 用法：
#   apply-theme.sh                    # 自动读当前 Plasma 壁纸
#   apply-theme.sh --image <路径>     # 指定壁纸
#   apply-theme.sh --color '#RRGGBB'  # 指定源色
#   apply-theme.sh --mode dark|light  # 强制深浅（默认按壁纸亮度自动）
set -euo pipefail

mode=""
image_path=""
source_color=""

usage() {
    printf 'Usage: %s [--image PATH | --color HEX] [--mode dark|light]\n' "$0" >&2
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --image) image_path=$2; shift 2 ;;
        --color) source_color=$2; shift 2 ;;
        --mode) mode=$2; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) usage; exit 2 ;;
    esac
done

if [[ -n "$image_path" && -n "$source_color" ]]; then usage; exit 2; fi

# 未指定源时读当前 Plasma 壁纸
if [[ -z "$image_path" && -z "$source_color" ]]; then
    appletsrc="${XDG_CONFIG_HOME:-$HOME/.config}/plasma-org.kde.plasma.desktop-appletsrc"
    uri=$(sed -n 's/^Image=//p' "$appletsrc" 2>/dev/null | tail -n 1 || true)
    image_path=${uri#file://}
    image_path=${image_path//%20/ }
    image_path=${image_path//%23/#}
    image_path=${image_path//%25/%}
    if [[ -z "$image_path" || ! -f "$image_path" ]]; then
        echo "未找到当前壁纸（$appletsrc 无 Image 或文件不存在），请用 --image 指定" >&2
        exit 1
    fi
fi

# 深浅模式：显式参数 > 壁纸亮度自动判定（M3 惯例：亮壁纸配 light，暗壁纸配 dark）
if [[ -z "$mode" ]]; then
    if [[ -n "$image_path" ]] && command -v magick >/dev/null 2>&1; then
        brightness=$(magick "$image_path" -auto-orient -resize 64x64\! \
            -colorspace Gray -format '%[fx:mean]' info: 2>/dev/null || echo 0.5)
        if awk -v v="$brightness" -v l=0.55 'BEGIN { exit !(v >= l) }'; then
            mode=light
        else
            mode=dark
        fi
    else
        mode=dark
    fi
fi
if [[ "$mode" != dark && "$mode" != light ]]; then usage; exit 2; fi

command -v matugen >/dev/null 2>&1 || { echo "matugen 未安装（paru -S matugen）" >&2; exit 1; }

echo "源: ${image_path:-color $source_color} | 模式: $mode"
if [[ -n "$image_path" ]]; then
    matugen --mode "$mode" --prefer saturation image "$image_path" -q
else
    matugen --mode "$mode" color hex "$source_color" -q
fi
echo "取色链完成：Plasma/GTK/kitty/starship/btop/palette 已更新"
