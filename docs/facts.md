# 环境事实盘点（2026-11-10 查证）

> 本文件是访谈过程中的事实底座，全部条目经本机查证，非推测。

## 本机环境

| 项 | 值 |
|---|---|
| 发行版 | CachyOS（ID_LIKE=arch，rolling） |
| 桌面 | KDE Plasma 6 + Wayland（plasmashell + kwin_wayland 运行中） |
| 输入法 | **IBus + ibus-libpinyin**（运行中，`XMODIFIERS=@im=ibus`）；fcitx5 未安装且用户明确不装 |
| 登录 shell | fish 4.9.3 |
| 已装应用 | fastfetch 2.70.0、zsh 5.9.2、fish |
| 未装应用 | kitty、starship、zed |
| 当前主题 | WhiteSur 系（macOS 风桌面主题 6 个变体） |
| 现有配色方案 | Breeze 系、CachyOSNord、CachyOSNordLightly、Emerald 系 |

## 底座仓库（cachyos-kde-macos-style）

- 位置：`/home/gzqk_admin/Documents/git/cachyos-kde-macos-style`，remote = `github.com/takekeyf/cachyos-kde-macos-style`，单 commit。
- 工程：`install.sh` / `restore.sh` / `assets/configure-layout.js`（经 `org.kde.PlasmaShell` DBus eval JS，运行时发现面板 ID，删旧建新：底部浮动 Dock + 顶部状态栏）/ `files/adaptive-plasma-panels*`（systemd path+service：ImageMagick 采样壁纸亮度，0.55 阈值切换 WhiteSur-alt/WhiteSur-dark 面板主题）。
- 关键判断：**壁纸→主题联动雏形已存在**（二值切换）；Monet 取色是它的连续化进化，演进路线自然。
- 身份待确认：takekeyf 是否用户本人的 GitHub 账号（决定直接演进 vs fork）。

## Nyxuri（参考项目）

- 位置：`/home/gzqk_admin/Documents/git/Nyxuri`（本访谈新克隆）。
- 定位：Arch + Niri/MangoWM + Quickshell 插件化桌面配置系统；GPL-3.0。
- 规模：518 QML + 154 Python + 63 JS；三卷路线图收口（插件市场化→架构重塑→散文化优雅化）。
- Shell 状态：**实验性，作者自述 BUG 多、暂不推荐日用**（README + shell/ROADMAP.md 双处声明）。
- Shell 插件域（12 个）：bar、desktopcards、dock、launcher、lock、notifications、regionselector、session、settings、sidebars、wallpaper。
- B 卷已交付：Bar & Island 双源融合（iNiR Material Bar + end4 灵动岛，3-Lane 布局，B0~B6 全绿）。
- 取色演进：matugen 正在退役，取色内生进 Shell（`shell/commons/WallpaperSource.js` + `plugins/wallpaper/` 色彩算法）。
- theme 插件模板清单：gtk-3.0.css、gtk-4.0.css、mango.conf、niri-glow-material-you.kdl、palette.toml——**无 KDE 模板**。
- 与 WM 无关的插件（KDE 下可直接用）：kitty、starship、fastfetch、fish、wallpapers、zed；WM 绑定：niri、mango、greeter（Noctalia）、noctalia（部分）、theme（模板面向 niri/mango/GTK）。
- 管理器（nyxuri CLI）：Python 标准库零依赖；`__custom__` 文件保留机制、预设（Forms）叠加、30 次备份快照、doctor 检查。

## 外部可行性调研（子代理 B，2026-11-10，联网交叉印证）

### Quickshell on KDE Plasma 6（KWin/Wayland）：有条件可行 ✅

- KWin 实现 wlr-layer-shell（Quickshell 核心依赖），官方文档+KDE 论坛开发者确认。
- **KDE Plasma 6 实跑先例**：end-4dots-kde（end-4 的 Quickshell 整套移植 KDE，活跃）、Caelestia KDE 重制版（作者明言 bar 是 quickshell）、punchi-dock-quickshell（明确要求 KDE Plasma/KWin Wayland）、Noctalia 官方文档设 KDE compositor 页（"Layer-shell bars and panels work"）。
- **条件与限制**：① 截图/录屏走 Spectacle（KWin 无 wlr-screencopy）；② 锁屏保留 kscreenlocker；③ 最省事路径 = 保留 plasmashell（壁纸/桌面图标/通知归属它）、删默认面板，Quickshell 出 bar/dock/岛——与 plasmashell 并存而非整体替换。
- 风险注记：Qt 版本冲突个例（noctalia #1440）；第三方 shell 崩溃可能波及会话体验（需熔断/守护）。

### matugen → KDE 动态取色：可行且有最成熟现成方案 ✅

- **kde-material-you-colors**（luisbocanegra，2022 至今活跃）：壁纸→M3 取色→生成明暗双 KDE 色彩方案→`plasma-apply-colorscheme` 即时生效；同步 Konsole/Kate/pywal；PyPI + AUR（`kde-material-you-colors`）+ KDE Store plasmoid 三渠道。**首选评估对象**。
- 自建链路（备选）：matugen 模板机制渲染 `.colors`（INI，约 30 行）到 `~/.local/share/color-schemes/` → `plasma-apply-colorscheme`；坑：同名方案重复 apply 不刷新，需**双方案名交替覆盖**。
- Plasma 6 内置"从壁纸取强调色"只动 accent color，不是完整色板，不满足需求。
- 组合先例：matugen + quickshell 动态取色在 r/hyprland 有实例，二者可组合。

## 本机工具链（2026-11-10 查证）

| 项 | 值 |
|---|---|
| AUR 助手 | paru 2.1.0 已装 |
| quickshell | **CachyOS 官方仓库收录**（cachyos-extra-v3/quickshell 0.3.2），pacman 直装无需 AUR |
| dux-shell | **CachyOS 官方仓库收录**（dux-shell 2.0.0，MIT，duxlabs-dev/dux-shell）：基于 Quickshell、Material 3 设计原则的完整桌面 shell，可选依赖 matugen（原生动态壁纸取色），取代 dms-shell（DankMaterialShell 后继），81MB |
| 含义 | Bar/灵动岛实现出现第三条路径：官方仓库一键装的现成 M3 shell（成熟度待评估），与"从 Nyxuri 搬组件"“自写 Quickshell"并列 |

## 冲突裁决：KWin layer-shell 支持（2026-11-10）

两个调研子代理结论冲突（A：KWin 不支持 layer-shell，Quickshell 不能跑；B：支持，能跑）。
**本机实证**：`wayland-info` 输出 `interface: 'zwlr_layer_shell_v1', version: 5` —— 本机当前 KDE Wayland 会话的 KWin **实现 layer-shell v1**。
**裁决**：B 正确；A 的外部生态断言否决（A 未联网）。A 的仓库内部结构盘点（依赖收口、文件级归属）仍采信。
**含义**：Nyxuri shell 组件（Bar/灵动岛）在本机有"直接跑/低成本改造"机会——灵动岛 0 直接 niri 依赖，bar 82 文件仅 5 个摸合成器投影，需把 NiriDriver（niri IPC，895 行，刻意收口单文件）换成 KWin 驱动或裁掉依赖单元。

## Nyxuri 资产盘点要点（子代理 A，2026-11-10）

### 直接可用（纯用户态，拿到 KDE 即用）
- **matugen 取色链路**：generate-matugen-colors.sh（bash+jq，壁纸→50 token M3 JSON）+ colors.json/palette-modes.json 双契约 + 模板注册表（config.toml 声明 input/output/hook）+ vendored kitty/btop/starship/gtk3/gtk4 模板（含 apply.sh：重载/include 行/marker 块替换）。
- **ThemePalette.js**（50 token→终端 ANSI 16 色+16 角色色板，golden 验证）+ Toml.js（QML 原生 TOML 读写）。
- **终端四件套**：kitty（含 transparent 形态+`__custom__` 槽）、starship 186 行、fastfetch 113 行、fish 312 行。
- **nyxuri 部署引擎**：纯 Python 3.11+ 标库零依赖，manifest 驱动原子部署；`__custom__` 保留机制、状态基线 carry（六分支判定，更新永不吞用户改动）、forms 形态系统（配置变体切换）、快照回滚（30 上限/精确恢复/--keep-custom）；432+ 项测试随行。与 WM 耦合仅 compositors.py 一处，可忽略。
- wallpapers 素材（lawson_fuji.webp + merge 生活区机制）。

### 需改造（有真实移植价值）
- **KDE colorscheme 模板（唯一缺口）**：仓库无 KDE .colors 模板；补一个 INI 模板 + `plasma-apply-colorscheme` post_hook（注意双方案名交替 apply 防不刷新）即可闭环，成本约半天～一天。
- **Bar M3 套件（40+ 件）+ DynamicIsland（7 Provider 优先级队列、贝塞尔形变、Badge 花瓣）**：layer-shell 可跑（本机实证），但需处理 NiriDriver 替换/裁剪（bar 82 文件仅 5 个摸合成器投影；岛 0 依赖）；通知需接 Plasma 通知而非自建 daemon。实验性状态风险自担。
- commons 层 M3 控件库（~30 件 + ui/ ~100 件原子控件）：纯 QtQuick 件可复用进任何 Qt 应用。

### 出局
fcitx5-rime（IBus 约束）、niri/mango/xdg-desktop-portal（WM 专属）、greeter（动会话层，违红线）、noctalia 工具（A 判 GtkLayerShell 不可跑——此断言存疑，Noctalia 官方有 KDE 支持页，待后续核验）、dock/launcher/lock/sidebars（KDE 有原生等效）。

### Top 5 移植建议（价值/成本比序）
1. matugen 取色链路 + 模板体系（自补 KDE .colors 模板）——全家变色的魔法源头，1~2 天全链路跑通
2. 终端动态主题四件套（kitty/starship/btop/fastfetch）——见效最快的炫酷
3. Bar M3 + 灵动岛（layer-shell 直跑 + NiriDriver 换 KWin 驱动）——视觉含金量最高，长期项
4. nyxuri 部署引擎（保留/形态/快照）——"全程可回滚"的工程底座
5. palette.toml 单一色板出口——全桌面色彩同源
