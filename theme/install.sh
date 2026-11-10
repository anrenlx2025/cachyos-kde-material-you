#!/usr/bin/env bash
# Material You 取色链部署器。
# 部署模板、matugen 配置、kitty/starship/fastfetch 基础配置。
# 覆盖前备份到 ~/.cache/materialyou/backups/。重复执行幂等。
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
templates_src="$script_dir/templates"
matugen_dir="${XDG_CONFIG_HOME:-$HOME/.config}/matugen"
backup_root="${XDG_CACHE_HOME:-$HOME/.cache}/materialyou/backups"

backup_file() {
    local target="$1"
    if [[ -e "$target" && ! -L "$target" ]]; then
        local stamp
        stamp=$(date +%Y%m%d-%H%M%S)
        mkdir -p "$backup_root/$stamp"
        cp -a "$target" "$backup_root/$stamp/"
        echo "已备份: $target -> $backup_root/$stamp/"
    fi
}

# --- 1. matugen 模板与配置 ---
mkdir -p "$matugen_dir/templates"
for f in "$templates_src"/*; do
    install -m 0644 "$f" "$matugen_dir/templates/$(basename "$f")"
done
install -m 0644 "$script_dir/matugen.toml" "$matugen_dir/config.toml"
echo "已部署 matugen 模板与配置"

# --- 2. kitty 基础配置 ---
kitty_dir="${XDG_CONFIG_HOME:-$HOME/.config}/kitty"
mkdir -p "$kitty_dir/themes"
backup_file "$kitty_dir/kitty.conf"
cat > "$kitty_dir/kitty.conf" <<'EOF'
# Material You kitty 配置（由 cachyos-kde-material-you 管理）
window_padding_width 5
hide_window_decorations yes
background_opacity 0.92
remember_window_size no
confirm_os_window_close 0
cursor_trail 1
cursor_shape block
shell_integration no-cursor

# 复制粘贴只走 kitty 默认路径（Ctrl+Shift+C/V），Ctrl+C/V 归终端程序
copy_on_select no

# 词删除与字号（Windows/浏览器习惯）
map ctrl+backspace send_text all \x17
map ctrl+delete send_text all \x1bd
map ctrl+equal change_font_size all +1.0
map ctrl+minus change_font_size all -1.0
map ctrl+0 change_font_size all 0
mouse_map ctrl+scroll_up change_font_size all +1.0
mouse_map ctrl+scroll_down change_font_size all -1.0

# 动态主题（matugen 渲染，勿手改）
include themes/materialyou.conf

# 用户私有配置挂载点（更新永不覆盖）
include __custom__.conf
EOF
if [[ ! -f "$kitty_dir/__custom__.conf" ]]; then
    printf '# 在此写你的 kitty 私有配置，更新不会覆盖本文件\n' > "$kitty_dir/__custom__.conf"
fi
echo "已部署 kitty 配置"

# --- 3. starship 主配置 ---
starship_cfg="${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"
if [[ ! -f "$starship_cfg" ]]; then
    install -m 0644 "$templates_src/starship.toml" "$starship_cfg"
    echo "已部署 starship 主配置"
else
    echo "starship 配置已存在，保留（palette 块由 hook 注入）"
fi

# --- 4. fastfetch 配置 ---
fastfetch_dir="${XDG_CONFIG_HOME:-$HOME/.config}/fastfetch"
if [[ -f "$script_dir/fastfetch.jsonc" ]]; then
    mkdir -p "$fastfetch_dir"
    backup_file "$fastfetch_dir/config.jsonc"
    install -m 0644 "$script_dir/fastfetch.jsonc" "$fastfetch_dir/config.jsonc"
    echo "已部署 fastfetch 配置"
fi

# --- 5. GTK 载体主题（adw-gtk-theme 中性底，gtk.css 叠加取色）---
for ini in "${XDG_CONFIG_HOME:-$HOME/.config}/gtk-3.0/settings.ini" "${XDG_CONFIG_HOME:-$HOME/.config}/gtk-4.0/settings.ini"; do
    mkdir -p "$(dirname "$ini")"
    touch "$ini"
done
if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk-theme' 2>/dev/null || true
fi
echo "已设置 GTK 载体主题（adw-gtk-theme）"

echo
echo "部署完成。运行取色：$script_dir/apply-theme.sh"
