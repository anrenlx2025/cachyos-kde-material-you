# CachyOS KDE Material You

一套面向 **CachyOS + KDE Plasma 6（Wayland）** 的 Material You 动态取色桌面美化。
换一张壁纸，**Plasma 配色方案、GTK 应用、kitty 终端、Starship 提示符、btop 全部随壁纸变色**。

> 本仓库 fork 自 [takekeyf/cachyos-kde-macos-style](https://github.com/takekeyf/cachyos-kde-macos-style)
> 并按 Material You 方向重塑（原 macOS 玻璃风定位退役，见 [docs/adr/0001](docs/adr/0001-beautify-route.md)）。
> 设计参考 [Nyxuri](https://github.com/ech678/Nyxuri)（Niri + Quickshell 的插件化桌面配置系统）。
> 原仓库的面板布局能力（`install.sh` + `assets/configure-layout.js`）保留可用。

## 效果

- 壁纸 → matugen 取色（M3 tonal-spot，50 token 色板）→ 全家桶联动：
  - **Plasma**：生成色彩方案并即时应用（`plasma-apply-colorscheme`，双方案名交替规避不刷新）
  - **GTK 3/4**：`gtk.css` 动态渲染（IBus 候选框等 GTK 应用顺跟随）
  - **kitty**：终端 16 色 + 光标 + 选区随壁纸（热重载，无需重启）
  - **Starship**：palette 块动态注入（Pawlette 排版主配置保留）
  - **btop**：主题色板跟随
  - `~/.cache/materialyou/palette.toml`：单一色板出口，供下游工具取色
- 深浅模式自动判定：壁纸亮度 ≥0.55 走 light，否则 dark（也可 `--mode` 强制）
- **换壁纸全自动**：systemd path 监听 Plasma 壁纸配置，变化即重取色（无需手动）
- 全程可回滚：部署前自动备份；kitty 用户私有配置放 `__custom__.conf` 永不被覆盖

## 安装

依赖（`paru -S --needed`）：`matugen jq kitty starship btop adw-gtk-theme imagemagick`

```bash
git clone https://github.com/anrenlx2025/cachyos-kde-material-you.git
cd cachyos-kde-material-you
./install.sh              # 底座：面板布局等（原仓库能力，可选）
bash theme/install.sh     # 取色链：模板 + matugen 配置 + 终端配置部署
bash theme/apply-theme.sh # 立即取色一次
cp files/material-you-theme.{service,path} ~/.config/systemd/user/
systemctl --user daemon-reload && systemctl --user enable --now material-you-theme.path
```

## 手动取色

```bash
theme/apply-theme.sh                     # 读当前壁纸
theme/apply-theme.sh --image <图片路径>   # 指定壁纸
theme/apply-theme.sh --color '#556677'   # 指定源色
theme/apply-theme.sh --mode light        # 强制浅色
```

## 路线图

三期推进（详见 [docs/PLAN.md](docs/PLAN.md)）：

- **一期（当前）**：matugen 取色全链 + 终端动态主题 + KDE 色彩方案 ✅
- **二期**：Quickshell 灵动岛试跑（Nyxuri DynamicIsland 移植，KWin layer-shell 已实证支持）
- **三期**：Material Bar 上位（Nyxuri barM3 套件，替换默认顶栏）

决策记录见 [docs/adr/](docs/adr/)，术语表见 [docs/GLOSSARY.md](docs/GLOSSARY.md)。

## 已知边界

- 输入法固定 IBus + ibus-libpinyin（中文体验优先，不引入 fcitx5 皮肤生态）
- 不换 WM、不动会话、不动登录管理器（外观层红线，见 ADR-0001）
- Nyxuri 部署引擎完整剥离接管尚未完成（一期以 install.sh 内置备份过渡，见 PLAN 进度标注）
