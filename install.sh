#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
state_root="${XDG_STATE_HOME:-$HOME/.local/state}/cachyos-kde-macos-style"
timestamp=$(date +%Y%m%d-%H%M%S)
backup_dir="$state_root/backups/$timestamp"
remove_wallpapers=false

usage() {
    cat <<'EOF'
Usage: ./install.sh [OPTIONS]

Options:
  --remove-default-wallpapers  Back up and remove wallpapers shown from /usr/share/wallpapers
  -h, --help                   Show this help

Run this as the desktop user, not as root. The script requests sudo only for
official repository packages and the optional system-wallpaper operation.
EOF
}

while (($#)); do
    case "$1" in
        --remove-default-wallpapers) remove_wallpapers=true ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
    esac
    shift
done

if ((EUID == 0)); then
    echo "Do not run this script as root." >&2
    exit 1
fi

if [[ ! -r /etc/os-release ]]; then
    echo "Cannot identify the operating system." >&2
    exit 1
fi

# shellcheck disable=SC1091
source /etc/os-release
if [[ "${ID:-}" != "cachyos" && "${ID_LIKE:-}" != *arch* ]]; then
    echo "This installer targets CachyOS/Arch Linux; detected ID=${ID:-unknown}." >&2
    exit 1
fi

required_commands=(git sudo pacman qdbus6 systemctl kwriteconfig6 kreadconfig6)
for command_name in "${required_commands[@]}"; do
    command -v "$command_name" >/dev/null || {
        echo "Missing required command: $command_name" >&2
        exit 1
    }
done

mkdir -p "$backup_dir/config" "$backup_dir/adaptive"
for item in \
    plasma-org.kde.plasma.desktop-appletsrc \
    plasmashellrc plasmarc kdeglobals ksplashrc kwinrc; do
    [[ -e "$HOME/.config/$item" ]] && cp -a "$HOME/.config/$item" "$backup_dir/config/"
done
[[ -d "$HOME/.config/Kvantum" ]] && cp -a "$HOME/.config/Kvantum" "$backup_dir/config/"
if [[ -e "$HOME/.local/bin/adaptive-plasma-panels" ||
      -e "$HOME/.config/systemd/user/adaptive-plasma-panels.service" ||
      -e "$HOME/.config/systemd/user/adaptive-plasma-panels.path" ]]; then
    touch "$backup_dir/adaptive/existed"
    [[ -e "$HOME/.local/bin/adaptive-plasma-panels" ]] && \
        cp -a "$HOME/.local/bin/adaptive-plasma-panels" "$backup_dir/adaptive/"
    [[ -e "$HOME/.config/systemd/user/adaptive-plasma-panels.service" ]] && \
        cp -a "$HOME/.config/systemd/user/adaptive-plasma-panels.service" "$backup_dir/adaptive/"
    [[ -e "$HOME/.config/systemd/user/adaptive-plasma-panels.path" ]] && \
        cp -a "$HOME/.config/systemd/user/adaptive-plasma-panels.path" "$backup_dir/adaptive/"
fi
printf '%s\n' "$backup_dir" > "$state_root/latest-backup"

echo "Backup: $backup_dir"
echo "Installing official CachyOS/Arch packages..."
sudo pacman -S --needed \
    git kvantum imagemagick ark 7zip unrar unzip \
    papirus-icon-theme qogir-icon-theme

work_dir=$(mktemp -d "${TMPDIR:-/tmp}/cachyos-kde-style.XXXXXX")
trap 'rm -rf -- "$work_dir"' EXIT

echo "Installing WhiteSur KDE theme from its upstream repository..."
git clone --depth 1 https://github.com/vinceliuice/WhiteSur-kde.git "$work_dir/WhiteSur-kde"
(cd "$work_dir/WhiteSur-kde" && ./install.sh)

echo "Installing WhiteSur icons without an Apple launcher logo..."
git clone --depth 1 https://github.com/vinceliuice/WhiteSur-icon-theme.git "$work_dir/WhiteSur-icons"
(cd "$work_dir/WhiteSur-icons" && ./install.sh --alternative --kde-plasma)

echo "Installing Tela Circle (standard, light and dark)..."
git clone --depth 1 https://github.com/vinceliuice/Tela-circle-icon-theme.git "$work_dir/Tela-circle"
(cd "$work_dir/Tela-circle" && ./install.sh -c standard)

echo "Applying the application and Plasma appearance..."
kwriteconfig6 --file kdeglobals --group KDE --key LookAndFeelPackage com.github.vinceliuice.WhiteSur
kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle kvantum
kwriteconfig6 --file kdeglobals --group Icons --key Theme WhiteSur
kwriteconfig6 --file kdeglobals --group General --key ColorScheme WhiteSur
kwriteconfig6 --file ksplashrc --group KSplash --key Theme CachyOS-Nord
kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled true
kvantummanager --set WhiteSur >/dev/null 2>&1 || true
plasma-apply-desktoptheme WhiteSur-alt >/dev/null

if [[ ! -r /usr/share/icons/cachyos.svg ]]; then
    echo "Warning: /usr/share/icons/cachyos.svg is missing; Kickoff may use a fallback icon." >&2
fi

echo "Replacing existing panels with the portable Dock and top bar layout..."
if ! qdbus6 org.kde.plasmashell /PlasmaShell >/dev/null 2>&1; then
    echo "Plasma Shell D-Bus service is unavailable. Run this inside a logged-in KDE session." >&2
    exit 1
fi
layout_script=$(<"$repo_dir/assets/configure-layout.js")
qdbus6 org.kde.plasmashell /PlasmaShell \
    org.kde.PlasmaShell.evaluateScript "$layout_script"

install -Dm700 "$repo_dir/files/adaptive-plasma-panels" \
    "$HOME/.local/bin/adaptive-plasma-panels"
install -Dm644 "$repo_dir/files/adaptive-plasma-panels.service" \
    "$HOME/.config/systemd/user/adaptive-plasma-panels.service"
install -Dm644 "$repo_dir/files/adaptive-plasma-panels.path" \
    "$HOME/.config/systemd/user/adaptive-plasma-panels.path"
systemctl --user daemon-reload
systemctl --user enable --now adaptive-plasma-panels.path
systemctl --user start adaptive-plasma-panels.service || true

if [[ "$remove_wallpapers" == true ]]; then
    echo "Backing up and removing system wallpapers..."
    if pacman -Q cachyos-wallpapers >/dev/null 2>&1; then
        sudo pacman -R cachyos-wallpapers
    fi
    if [[ -d /usr/share/wallpapers ]] && \
       find /usr/share/wallpapers -mindepth 1 -print -quit | grep -q .; then
        sudo mv -- /usr/share/wallpapers "$backup_dir/system-wallpapers"
        sudo install -d -m 755 /usr/share/wallpapers
        sudo chown -R -- "$USER:$(id -gn)" "$backup_dir/system-wallpapers"
    fi
fi

systemctl --user restart plasma-plasmashell.service
sleep 3

echo
echo "Installation complete."
echo "Backup: $backup_dir"
echo "Choose your own wallpaper in System Settings; panel contrast updates automatically."
echo "Use ./restore.sh to restore the previous Plasma configuration."
