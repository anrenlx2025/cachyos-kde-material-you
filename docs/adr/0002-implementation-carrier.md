# 0002 - 实施载体：三分期推进、kitty 迁移、fork 改名

---
状态：accepted（2026-11-10 访谈定案）
落点：草稿。终审后迁入 `cachyos-kde-material-you` 仓库 docs/adr/。

## 语境与决定

ADR-0001 定下路线后，Bar 与灵动岛的实现载体经外部调研加本机实证确定。本机 KWin 实证支持 zwlr_layer_shell_v1（v5），Quickshell 面板可运行。

1. **三分期推进**。风险递增，每期独立可回滚。
   - 一期「取色全链」：移植 matugen 取色链路。自写 KDE colorscheme 模板（.colors INI 加 plasma-apply-colorscheme hook，双方案名交替 apply 防不刷新）。配置部署交给 Nyxuri 部署引擎接管。纯用户态，零会话风险。
   - 二期「灵动岛试跑」：装 Quickshell（CachyOS 官方仓库 quickshell 0.3.2）。移植 Nyxuri DynamicIsland，本体零 niri 依赖。plasmashell 面板不动。失败即关，零残留。此期兼作闸门，实证 Nyxuri 组件在 KWin 的存活度。
   - 三期「Material Bar 上位」：移植 Bar M3 套件。NiriDriver（niri IPC，895 行）替换为 KWin 驱动，或裁掉依赖单元（bar 82 文件仅 5 个摸合成器投影）。通知改接 Plasma 通知。删除默认顶栏。
2. **dux-shell 不进主线**。只作参照物与 fallback（CachyOS 官方仓库一键装的 M3 Quickshell shell）。用户意图是「根据 Nyxuri 美化」。引入第三套 shell 徒增边界复杂度。
3. **终端装 kitty 并日用迁移**。Nyxuri 的动态取色模板链（透明形态、USR1 热重载、golden 验证）原生面向 kitty。Konsole 保留为 fallback。fish 配置与终端无关，迁移无成本。
4. **底座 fork 到 anrenlx2025 并改名 `cachyos-kde-material-you`**。fork 自 takekeyf/cachyos-kde-macos-style（原作者仓库）。名字即方向。

## 考虑过的选项

- 一期直接上 Bar 与灵动岛：否决。Quickshell 组件在 KWin 的存活度未经实证。先铺零风险取色链，最快兑现「全家变色」，同时建立回滚底座。
- dux-shell 作为一期 Bar 载体：否决。理由见决定第 2 条。
- 留 Konsole 只做取色同步：否决。放弃 Nyxuri 最成熟的终端资产不划算。

## 后果

- 一期结束即可验收「壁纸换色，Plasma 配色、GTK、kitty、Starship、btop、fastfetch 全家跟随」（对照 Nyxuri 演示视频）。
- 二期是闸门。灵动岛存活度差则三期降级：改用 dux-shell 或纯 Plasma 面板 M3 化。降级裁决记新 ADR。
- Nyxuri 部署引擎接管后，配置部署走 manifest 原子置换加 `__custom__` 保留，加 30 次快照。底座原 adaptive-plasma-panels 服务（壁纸亮度二值切深浅）与 M3 双模式色板在一期合并设计。初步方向：亮度阈值决定深浅模式，取色引擎输出双模式色板。
