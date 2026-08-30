# CachyOS KDE macOS-style desktop

一套面向 **CachyOS + KDE Plasma 6** 的可重复桌面美化脚本。目标是获得 macOS 风格的圆角玻璃 Dock 与顶部状态栏，同时保留 CachyOS 标志、启动画面和系统辨识度。

本仓库只处理桌面外观与常用归档工具，**不包含 HKC 扬声器或任何音频修复**。

## 效果与设计原则

- 底部：居中、内容自适应、圆角悬浮 Dock。
- 顶部：居中状态栏，常显 Wi-Fi、蓝牙、音量、电池、亮度和时间。
- 上下栏均使用“窗口避让”：最大化窗口占用边缘时隐藏，鼠标移至屏幕边缘可唤出。
- 明亮壁纸自动使用深色玻璃和浅色文字；暗色壁纸自动使用浅色玻璃和深色文字。
- Kickoff 启动器固定使用 `/usr/share/icons/cachyos.svg`，不显示苹果标志。
- 登录后的 Plasma 启动画面使用 `CachyOS-Nord`；不修改 GRUB、Limine、Plymouth 或内核。
- 安装前自动备份；面板 ID 和 Applet ID 运行时动态生成，不复制某台机器的私有 ID。

## 支持范围

已在以下环境验证：

- CachyOS x86_64
- KDE Plasma 6.7.x
- Wayland 会话
- 单屏笔记本布局

脚本也允许 `ID_LIKE=arch` 的系统运行，但布局与软件包名称主要按 CachyOS/Arch 设计。多显示器环境安装后可能需要在 Plasma 面板编辑模式中指定目标屏幕。

## 一键安装

安装应在已登录的 KDE 图形桌面中执行，不要切换到 root，也不要用 `sudo ./install.sh`：

```bash
git clone https://github.com/takekeyf/cachyos-kde-macos-style.git
cd cachyos-kde-macos-style
chmod +x install.sh restore.sh
./install.sh
```

脚本只在安装 CachyOS/Arch 官方软件包时请求 sudo。上游主题安装在当前用户目录。

如果还希望从“系统设置 → 壁纸”中移除系统自带壁纸：

```bash
./install.sh --remove-default-wallpapers
```

该选项会先备份 `/usr/share/wallpapers`。默认不启用，因为删除系统内容不应成为普通美化安装的隐含行为；相关软件包升级后也可能重新安装壁纸。

## 安装内容

### 官方仓库软件包

通过 `pacman -S --needed` 安装：

| 软件包 | 用途 |
|---|---|
| `kvantum` | Qt/KDE SVG 应用样式引擎 |
| `imagemagick` | 低开销采样壁纸平均亮度 |
| `papirus-icon-theme` | 备选图标主题 |
| `qogir-icon-theme` | 备选圆润图标主题 |
| `ark` | KDE 压缩文件管理器 |
| `7zip` | 7z 及加密 7z/ZIP 支持 |
| `unrar` | RAR 与加密 RAR 解压支持 |
| `unzip` | ZIP 解压支持 |
| `git` | 获取主题上游源码 |

### 用户级上游主题

安装脚本直接克隆作者 Vinceliuice 的官方仓库：

- [WhiteSur-kde](https://github.com/vinceliuice/WhiteSur-kde)
- [WhiteSur-icon-theme](https://github.com/vinceliuice/WhiteSur-icon-theme)
- [Tela-circle-icon-theme](https://github.com/vinceliuice/Tela-circle-icon-theme)

WhiteSur 图标使用 `--alternative --kde-plasma` 安装，避免在通用启动图标中引入 Apple 标志。Tela Circle 使用 `-c standard`，生成：

- `Tela-circle`
- `Tela-circle-light`
- `Tela-circle-dark`

Papirus、Qogir、Tela Circle 都只作为可选图标安装。默认应用图标为 `WhiteSur`，可在“系统设置 → 颜色和主题 → 图标”中切换比较。

## 修改的配置

### KDE 与 Kvantum

脚本通过 KDE 配置工具写入以下键：

| 文件 / 配置组 | 键 | 值 |
|---|---|---|
| `~/.config/kdeglobals` / `KDE` | `LookAndFeelPackage` | `com.github.vinceliuice.WhiteSur` |
| `~/.config/kdeglobals` / `KDE` | `widgetStyle` | `kvantum` |
| `~/.config/kdeglobals` / `Icons` | `Theme` | `WhiteSur` |
| `~/.config/kdeglobals` / `General` | `ColorScheme` | `WhiteSur` |
| `~/.config/ksplashrc` / `KSplash` | `Theme` | `CachyOS-Nord` |
| `~/.config/kwinrc` / `Plugins` | `blurEnabled` | `true` |
| Kvantum | 当前主题 | `WhiteSur` |
| `~/.config/plasmarc` / `Theme` | `name` | 由壁纸在 `WhiteSur-alt` 与 `WhiteSur-dark` 之间自动选择 |

这里有三个容易混淆的层次：

1. `kdeglobals/Icons/Theme` 控制应用和文件图标。
2. `plasmarc/Theme/name` 控制 Panel、托盘、文字等 Plasma 桌面控件。
3. Kvantum 控制 Qt 应用内部控件外观。

后续维护时不要为了改变 Dock 明暗而切换全局 Look-and-Feel，否则 Plasma 可能重新创建默认面板并覆盖本仓库布局。

### 底部 Dock

安装时删除现有 Panel（配置已提前备份），动态创建一个新面板：

- 位置：底部
- 高度：64
- 对齐：居中
- 长度：适应内容
- 悬浮：启用
- 背景：半透明
- 可见性：Dodge Windows / 窗口避让
- Applet 顺序：Kickoff、虚拟桌面、仅图标任务管理器、边距分隔器
- Kickoff 图标：`/usr/share/icons/cachyos.svg`
- 默认固定项：系统设置、首选文件管理器、Konsole、Spectacle

脚本不会固定 Chrome，因为新设备不一定安装；可在安装后自行固定浏览器。

### 顶部状态栏

动态创建第二个面板：

- 位置：顶部
- 高度：38
- 对齐：居中
- 长度：适应内容
- 悬浮：启用
- 背景：半透明
- 可见性：Dodge Windows / 窗口避让
- Applet：系统托盘、数字时钟
- 托盘常显项：网络、蓝牙、音量、电池、亮度

不同设备缺少蓝牙或电池时，Plasma 会忽略相应不可用项目，不需要改脚本。

## 壁纸明暗自动适配

安装以下用户级文件：

```text
~/.local/bin/adaptive-plasma-panels
~/.config/systemd/user/adaptive-plasma-panels.service
~/.config/systemd/user/adaptive-plasma-panels.path
```

`.path` 单元监控：

```text
~/.config/plasma-org.kde.plasma.desktop-appletsrc
```

壁纸改变后，脚本将当前图片缩小到 `64×64` 并转换为灰度，计算 `0.0–1.0` 的平均亮度：

- 亮度 `>= 0.55`：`WhiteSur-dark`，深色玻璃 + 浅色文字。
- 亮度 `< 0.55`：`WhiteSur-alt`，浅色玻璃 + 深色文字。

临时修改阈值可编辑 service 或在环境中设置 `ADAPTIVE_PANEL_THRESHOLD`。查看运行状态：

```bash
systemctl --user status adaptive-plasma-panels.path
journalctl --user -u adaptive-plasma-panels.service -n 30 --no-pager
kreadconfig6 --file plasmarc --group Theme --key name
```

停用或重新启用：

```bash
systemctl --user disable --now adaptive-plasma-panels.path
systemctl --user enable --now adaptive-plasma-panels.path
```

当前实现读取 Plasma 配置中的最后一个 `Image=`，适合单屏和所有桌面使用同一壁纸的情况。多屏分别使用不同壁纸时，应将脚本扩展为逐 containment 分析；当前只会用最后一项决定所有 Panel 的主题。

## 备份和恢复

每次安装都会创建带时间戳的备份：

```text
~/.local/state/cachyos-kde-macos-style/backups/YYYYMMDD-HHMMSS/
```

最新备份位置记录在：

```text
~/.local/state/cachyos-kde-macos-style/latest-backup
```

恢复最近一次安装前的 Plasma 配置：

```bash
./restore.sh
```

也可以指定某次备份：

```bash
./restore.sh ~/.local/state/cachyos-kde-macos-style/backups/20260830-190000
```

恢复脚本会停用自动明暗监听、恢复用户配置并重启 Plasma Shell。它不会卸载软件包或主题，因为这些资源可能已被其它配置使用。

## CachyOS / Plasma 升级后的维护说明

升级后优先检查，不要立刻删除或覆盖整个 `~/.config`：

```bash
plasmashell --version
systemctl --user status plasma-plasmashell.service
systemctl --user status adaptive-plasma-panels.path
kreadconfig6 --file plasmarc --group Theme --key name
kreadconfig6 --file kdeglobals --group Icons --key Theme
rg -n 'plugin=org.kde.panel|plugin=org.kde.plasma.systemtray|AppletOrder=' \
  ~/.config/plasma-org.kde.plasma.desktop-appletsrc
rg -n -A8 '\[PlasmaViews\]\[Panel ' ~/.config/plasmashellrc
journalctl --user -u adaptive-plasma-panels.service -b --no-pager
```

常见升级影响：

- **主题仍在但面板变回默认布局**：Look-and-Feel 被重新应用并重置了 Layout。重新运行 `./install.sh`，或只执行 `assets/configure-layout.js`。
- **面板存在但没有玻璃/文字对比错误**：检查 `WhiteSur-alt`、`WhiteSur-dark` 是否仍在 `~/.local/share/plasma/desktoptheme`，再查看自适应服务日志。
- **顶部托盘缺项目**：Plasma 插件 ID 可能更名。当前 ID 写在 `assets/configure-layout.js` 的 `trayItems` 中。
- **CachyOS 图标不显示**：检查 `/usr/share/icons/cachyos.svg`；若发行版路径变化，修改布局脚本中的 Kickoff `icon`。
- **Kvantum 外观失效**：检查 `kdeglobals` 的 `widgetStyle=kvantum` 以及 `~/.config/Kvantum/kvantum.kvconfig`。
- **系统壁纸重新出现**：系统包升级会恢复其拥有的文件。仅在确实需要时重新运行 `./install.sh --remove-default-wallpapers`。
- **上游安装参数变化**：本仓库没有复制第三方主题源码。检查三个上游仓库的最新 README/`install.sh --help` 后再更新本仓库参数。

### 给后续 AI 的上下文

如果由其它 AI 继续维护，请先阅读本 README 和以下文件：

1. `install.sh`：包、上游来源、备份与执行顺序。
2. `assets/configure-layout.js`：所有 Panel/Applet 布局，不依赖固定 ID。
3. `files/adaptive-plasma-panels`：明暗判定和主题映射。
4. `restore.sh`：回滚边界。

维护原则：

- 先读取当前状态，再修改；不要假设面板 ID 是 46/91。
- 不运行全局 Look-and-Feel 的“重置布局”选项。
- 不把用户壁纸、活动 UUID、屏幕 UUID、历史记录或机器专属路径提交到仓库。
- 修改重要 Plasma 配置前创建时间戳备份。
- 系统级变更优先使用 CachyOS/Arch 官方包。
- 不覆盖 `/usr` 中主题文件；第三方主题安装在用户目录。
- 音频修复属于另一个项目，不能并入本仓库。

## 手动验证清单

安装完成后验证：

1. 底部 Dock 居中、圆角、半透明，Kickoff 为 CachyOS 图标。
2. 顶部栏居中，Wi-Fi、蓝牙、音量、电池、亮度和时钟可用。
3. 最大化窗口时上下栏避让，移动鼠标到边缘可唤出。
4. 换一张明显明亮和明显暗色的壁纸，`plasmarc` 在两个 WhiteSur Plasma 主题间切换。
5. 登录后启动画面为 CachyOS-Nord，不出现 Apple 标志。
6. Ark 能打开带密码的 ZIP、RAR 和 7z。
7. 耳机、HDMI、蓝牙音频和麦克风不应受影响；本项目不修改音频配置。

## License

本仓库脚本和文档使用 MIT License。WhiteSur、Tela Circle、Papirus、Qogir 等第三方项目遵循各自许可证，本仓库不重新分发它们的素材。
