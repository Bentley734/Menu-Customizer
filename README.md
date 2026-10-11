# Menu Customizer 3.2.3

Renames MENU STYLE to MENU FONT and adds EMERALD COMPACT, EMERALD BOLD and EMERALD CLEAN alongside NATIVE and EMERALD. Compact uses the smaller extracted face, Bold strengthens the foreground strokes, and Clean removes the shadow. Existing saved selections remain compatible. The selected font is also used by the merged battle renderer.

Raises GB/GBC battle dialogue four native pixels to center the text block inside its border. Border geometry, line spacing and the continue-arrow position are retained. Nested text/glyph paths apply the shift once. Tiled border textures and contraction glyph fixes are retained.

Validation: 836 menu/font checks under LuaJIT and Lua 5.3, all mod Lua compilation, eleven-game merged loader/settings fixtures, real glyph previews for all four Emerald variants across every border, and 266 native palette/opacity/pixel cases including message centering and fixed continue-arrow placement. Full live ROM gameplay was not exercised.

Update Menu Customizer and fully restart. No KIM1025 or asset update is needed.

Download: https://github.com/Bentley734/Menu-Customizer/releases/latest
