#!/usr/bin/env bash
set -euo pipefail

state_root="${XDG_STATE_HOME:-$HOME/.local/state}/cachyos-kde-macos-style"
backup_dir="${1:-}"

if [[ -z "$backup_dir" && -r "$state_root/latest-backup" ]]; then
    backup_dir=$(<"$state_root/latest-backup")
fi

if [[ -z "$backup_dir" || ! -d "$backup_dir/config" ]]; then
    echo "Backup not found. Pass a backup directory as the first argument." >&2
    exit 1
fi

echo "This restores Plasma configuration from:"
echo "  $backup_dir"
read -r -p "Continue? [y/N] " answer
[[ "$answer" == [yY] ]] || exit 0

systemctl --user disable --now adaptive-plasma-panels.path 2>/dev/null || true
cp -a "$backup_dir/config/." "$HOME/.config/"

if [[ -e "$backup_dir/adaptive/existed" ]]; then
    [[ -e "$backup_dir/adaptive/adaptive-plasma-panels" ]] && \
        install -Dm700 "$backup_dir/adaptive/adaptive-plasma-panels" \
        "$HOME/.local/bin/adaptive-plasma-panels"
    [[ -e "$backup_dir/adaptive/adaptive-plasma-panels.service" ]] && \
        install -Dm644 "$backup_dir/adaptive/adaptive-plasma-panels.service" \
        "$HOME/.config/systemd/user/adaptive-plasma-panels.service"
    [[ -e "$backup_dir/adaptive/adaptive-plasma-panels.path" ]] && \
        install -Dm644 "$backup_dir/adaptive/adaptive-plasma-panels.path" \
        "$HOME/.config/systemd/user/adaptive-plasma-panels.path"
else
    rm -f -- \
        "$HOME/.local/bin/adaptive-plasma-panels" \
        "$HOME/.config/systemd/user/adaptive-plasma-panels.service" \
        "$HOME/.config/systemd/user/adaptive-plasma-panels.path"
fi

if [[ -d "$backup_dir/system-wallpapers" ]]; then
    echo "A system-wallpaper backup exists. Restore it manually only if desired:"
    echo "  sudo cp -a '$backup_dir/system-wallpapers/.' /usr/share/wallpapers/"
fi

systemctl --user daemon-reload
if [[ -e "$backup_dir/adaptive/existed" &&
      -e "$HOME/.config/systemd/user/adaptive-plasma-panels.path" ]]; then
    systemctl --user enable --now adaptive-plasma-panels.path
fi
systemctl --user restart plasma-plasmashell.service
echo "Plasma configuration restored. Installed packages/themes were intentionally retained."
