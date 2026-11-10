# CachyOS KDE Material You 美化方案（终审稿）

> 依据：本目录 GLOSSARY.md（术语）、facts.md（事实底座）、docs/adr/（决策记录 0001/0002）。
> 本文是访谈共识的实施路线图。用户终审通过后开工。

## 目标

把 Nyxuri（Niri + Quickshell 的插件化桌面配置系统）的 Material You 体验移植到本机 CachyOS + KDE Plasma 6（Wayland）。

验收基准：Nyxuri 官方演示视频的整体观感（动态取色全家桶 + Material Bar + 灵动岛）。

## 边界（红线）

- 只动外观层。不换 WM。不动会话。不动登录管理器。
- 全程可回滚。每期有独立回滚路径。
- 输入法保持 IBus + ibus-libpinyin。不装 fcitx5。
- 截图仍用 Spectacle。锁屏仍用 kscreenlocker。

## 底座

- Fork `takekeyf/cachyos-kde-macos-style` 到 GitHub 账号 `anrenlx2025`。
- 改名为 `cachyos-kde-material-you`。重写 README 定位。
- 保留其工程骨架：布局脚本、备份回滚、面板 ID 动态生成。
- 退役其 macOS 视觉：WhiteSur 主题、玻璃拟态面板主题。
- 配置部署改由 Nyxuri 部署引擎接管（纯 Python 标库，零 pip 依赖）：
  - manifest 原子置换
  - `__custom__` 文件跨更新保留
  - 状态基线 carry（更新永不吞用户改动）
  - 30 次快照自动修剪 + 精确回滚

## 一期：取色全链（纯用户态，1~2 天）

> **进度（2026-11-10）**：交付 1~6 与深浅联动已完成并实机验收；壁纸监听由
> `files/material-you-theme.{path,service}` 承担。Nyuri 部署引擎完整剥离接管
> 未在本期完成：现以 `theme/install.sh` 内置备份过渡，引擎剥离移交下期收尾。

### 交付

1. Fork + 改名 + nyxuri 引擎接入底座仓库。
2. matugen 取色链路移植：
   - 取色脚本 `generate-matugen-colors.sh`（bash + jq，壁纸 → 50 token M3 JSON）
   - `colors.json` / `palette-modes.json` 双契约（当前模式 + dark/light 双模式）
   - 模板注册表（config.toml 声明 input/output/hook）
3. 自写 KDE colorscheme 模板（唯一缺口，约 30 行 INI）：
   - 50 token 映射到 .colors 格式
   - post_hook 调 `plasma-apply-colorscheme` 即时生效
   - 双方案名交替 apply，规避同名不刷新
4. 终端动态主题：
   - 装 kitty 并设为日用终端（Konsole 留 fallback）
   - 移植 kitty/btop/starship/fastfetch 模板与 apply hook（重载/include 行/marker 块替换）
   - fish 配置迁移（312 行，别名与函数即拿即用）
5. GTK 取色：gtk-3.0.css / gtk-4.0.css 模板（需 adw-gtk-theme）。IBus 候选框随 GTK 顺带取色。
6. 深浅模式联动：底座 adaptive 服务按壁纸亮度阈值决定 dark/light。取色引擎输出双模式色板。
7. `palette.toml` 单一色板出口 + ThemePalette.js 终端 16 色派生。

### 验收

- 换壁纸后：Plasma 配色、GTK 应用、kitty、Starship、btop、fastfetch 全部随壁纸变色。
- 深浅模式随壁纸亮度自动切换。
- `nyxuri` 引擎快照回滚演练一次成功。

### 回滚

- 引擎快照恢复 + restore.sh。无会话层变更，注销重登即还原。

## 二期：灵动岛试跑（闸门期）

### 交付

1. 装 Quickshell（CachyOS 官方仓库 quickshell 0.3.2）。
2. 移植 Nyxuri DynamicIsland（本体 0 个 niri 依赖）：
   - 7 Provider 优先级队列
   - 贝塞尔宽度形变（130~220px）
   - Badge 花瓣横排
   - 媒体控制（Mpris 树内服务）
3. plasmashell 默认面板不动。岛以独立 layer 悬浮运行。
4. 通知仲裁：岛内通知消费接 Plasma 通知（不自建 daemon）。

### 验收（闸门判定）

- 岛在 KWin 上稳定运行 3 天无崩溃。
- 切歌 hover 展开、通知强占、定时器等交互正常。
- 桌面无残留 layer、无事件循环泄漏（对照 Nyxuri R6 能耗基线方法）。

### 回滚

- 关闭 Quickshell 进程即消失。零残留。

### 闸门规则

- 存活度差 → 三期降级：改用 dux-shell 或纯 Plasma 面板 M3 化。降级裁决记新 ADR。

## 三期：Material Bar 上位

### 交付

1. 移植 Nyxuri barM3 套件（40+ 件）：
   - M3 嵌套药丸顶栏、3-Lane 布局、autoHide
   - 右键部件就地调色（BarGroupStylePopup）
2. NiriDriver（niri IPC，895 行）处置二选一：
   - 替换为 KWin 驱动（org_kde_plasma_window_management）
   - 裁掉依赖单元（bar 82 文件仅 5 个摸合成器投影）
3. Workspaces/ActiveWindow 单元换接 Plasma 虚拟桌面与窗口模型。
4. 删除 plasmashell 默认顶栏，Bar 承接状态栏职责（编辑模式删面板，plasmashell 保留管壁纸/桌面图标/通知/锁屏）。

### 验收

- 对照演示视频：顶部 M3 药丸 Bar 视觉与交互。
- 工作区切换、活动窗口标题、托盘、时钟功能齐全。
- 关闭 Quickshell 后可一键恢复 Plasma 原生面板（布局脚本重建）。

### 回滚

- 底座布局脚本重建 Plasma 原生面板。

## 明确不做

- fcitx5 及其皮肤（IBus 红线）。
- greeter/SDDM 改动（会话层红线）。
- Nyxuri 的 dock/launcher/lock/sidebars（KDE 有原生等效）。
- 整体替换 plasmashell（壁纸/桌面图标/通知/锁屏始终归 KDE）。
- niri/mango/portal 配置（WM 专属，出局）。

## 依赖安装清单（一期）

| 包 | 渠道 | 用途 |
|---|---|---|
| matugen | AUR（paru） | 取色引擎 |
| jq | 官方仓库 | JSON 组装 |
| kitty | 官方仓库 | 日用终端 |
| adw-gtk-theme | 官方仓库 | GTK 取色载体 |
| btop | 官方仓库 | 资源监视（若未装） |
| quickshell（二期） | 官方仓库 | 灵动岛宿主 |
