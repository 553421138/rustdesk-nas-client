# 远程连接图标

两个错位圆角窗口通过自然弧线连接，墨蓝底、暖白图形，图标中不放文字。

- 正式矢量应用图标：`app-icon.svg`（1024 × 1024，透明外边距）。
- 系统单色图形：`symbol.svg`，用于 Android 自适应前景、通知和 Mac 菜单栏模板。
- `concept-reference.png`：使用 imagegen 内置工具生成的方向参考。正式资源是重新绘制的矢量几何图形，使用确定的圆角、线宽和间距；未采用生成过程中的透明抠图。
- 导出：安装 `rsvg-convert` 和 Pillow 后，在仓库根目录运行 `python3 res/branding/export_icons.py`。脚本只导出尺寸和格式，正式设计源文件为 SVG。
- 完整端显示“远程连接”，顾客版显示“远程连接（顾客版）”。

概念图采用内置 imagegen 模式，最终提示词如下（参考第一版概念图，透明背景）：

> Use case: style-transfer for a production app icon. Refine this remote connection icon to be significantly more elegant and understated. Preserve the idea of two connected displays and a single centered rounded-square application tile with genuine transparent space outside it. Simplify the symbol: two offset rounded screen outlines with refined medium-weight lines and one short seamless connecting stroke; remove the bulky literal chain links and reduce the monitor stands to the minimum. Lots of breathing room around a compact, carefully balanced mark, approximately 58% of the tile width. Mature restrained palette: muted deep slate blue with a very subtle tonal shift, warm near-white symbol. Flat, precise, refined utility-app design, visually quiet, recognisable at small size. No bright electric blue, no white glow, no bevel, no shine, no ornament, no typography, no letters, no watermark, no border or surrounding mockup. Clean smooth silhouette with no stray pixels or rough edges. The result must be ONE square application icon.
