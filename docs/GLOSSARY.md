# 术语表（草稿）

> 状态：访谈已完成共识待终审。终审后迁入 `cachyos-kde-material-you` 仓库。
> 本表只收领域术语，不收实现细节。

| 术语 | 定义 |
|---|---|
| **Nyxuri** | 本项目参考的开源项目。它在 Arch 系发行版上提供插件化桌面配置，目标 WM 为 Niri/MangoWM。Shell 基于自研 Quickshell（QML/Qt6），仍处实验阶段。招牌是全局 Monet 取色、Material Bar 与灵动岛。它不兼容本机 KDE Plasma，只能借鉴元素与机制。 |
| **Monet 取色** | 从壁纸取色并生成 Material You 风格色板的动态配色机制。色板铺开到 Shell、GTK、终端等处。Nyxuri 正把 matugen 退役，改为 Shell 内生取色。 |
| **Material You / M3** | Google Material Design 3 设计语言：动态取色、大圆角、药丸形组件。本项目视觉方向的唯一依归（ADR-0001）。 |
| **底座** | cachyos-kde-macos-style：本机已有的 CachyOS + KDE Plasma 6 美化脚本仓库。已定案为演进底座（ADR-0001）。它保留工程能力（脚本框架、备份回滚、面板 ID 动态生成）。视觉定位从 macOS 玻璃拟态整体转 Material You。fork 后更名 `cachyos-kde-material-you`（ADR-0002）。 |
| **系统输入法** | 本机固定输入法：IBus + ibus-libpinyin。不可更换为 fcitx5，中文整句体验优先。Nyxuri 的 fcitx5-rime 插件与 NyxMellow 皮肤出局。IBus 候选框跟随 GTK 主题，取色覆盖 GTK 后顺带受益。 |
| **外观层红线** | 变更边界约束（ADR-0001）。只动主题、配色、面板、Dock、终端、输入法外观。不换 WM，不动会话，全程可回滚。 |
| **灵动岛（Island）** | 桌面顶部悬浮的胶囊形信息组件（媒体控制、通知等）。Nyxuri B 卷以 end4 灵动岛与 iNiR Material Bar 双源融合实现。本体零 niri 依赖。 |
| **Bar** | 桌面顶部状态栏。Nyxuri 的 Bar 以 iNiR 原生 Material Bar 为源，支持 3-Lane 自由布局。 |
| **闸门** | 二期灵动岛试跑承担的判定职能。存活度差则触发三期降级裁决（ADR-0002）。 |
