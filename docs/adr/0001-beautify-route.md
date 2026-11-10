# 0001 - 美化路线：留在 KDE、底座演进、整体转 Material You、外观层红线

---
状态：accepted（2026-11-10 访谈定案）
落点：草稿。终审后迁入 `cachyos-kde-material-you` 仓库 docs/adr/。

## 语境与决定

本机为 CachyOS + KDE Plasma 6 + Wayland。参考项目 Nyxuri 面向 Niri/MangoWM + Quickshell，两者架构不兼容。Nyxuri 的推广视频最初吸引了用户。访谈钉死四项根决策：

1. **路线 A（留在 KDE）**：不装 Niri、不换 WM。把 Nyxuri 的元素与机制移植进 KDE Plasma 6。
2. **底座演进**：以本机已有的 `cachyos-kde-macos-style`（CachyOS + Plasma 6 美化脚本仓库）为底座吸收 Nyxuri 元素。不另起炉灶，不推倒重来。
3. **视觉整体转 Material You**：放弃原 macOS 玻璃拟态观感定位。色板与组件语言全面 Material You 化（动态取色 + M3 圆角药丸语言）。底座保留工程能力（脚本框架、备份回滚、面板 ID 动态生成），不保留视觉。
4. **外观层红线**：只动主题、配色、面板、Dock、终端、输入法外观。不换 WM，不动会话，全程可回滚。

## 考虑过的选项

- 路线 B（Niri 会话并存跑完整 Nyxuri）/ 路线 C（整体切换）：否决。本机日用，要求稳定可回滚。Nyxuri Shell 自述实验性，暂不推荐日用。
- 玻璃 + Monet 混合（保 macOS 观感只换色板）：否决。用户明确要整体 Material You。
- 另起炉灶 / 推倒重来：否决。底座已验证、同环境，演进成本最低。

## 后果

- 仓库 fork 自 takekeyf/cachyos-kde-macos-style（原作者仓库）到 GitHub 账号 anrenlx2025，并更名 `cachyos-kde-material-you`（Q12 定案）。落实方式见 ADR-0002。
- fcitx5 全部资产（fcitx5-rime 插件、NyxMellow 皮肤）永久出局。系统输入法定死 IBus + ibus-libpinyin，中文整句体验优先于皮肤生态（用户约束，见 GLOSSARY「系统输入法」）。IBus 候选框跟随 GTK 主题。Monet 取色覆盖 GTK 后，输入法外观顺带受益。
- WhiteSur 全系主题退役，仅存于回滚脚本（Q8 定案）。视觉验收基准 = Nyxuri 官方演示视频整体观感（Q7 定案）。
- 桌面形态 Nyxuri 化：顶部 Material Bar 与灵动岛上位（Q9 定案）。实现载体与分期见 ADR-0002。
