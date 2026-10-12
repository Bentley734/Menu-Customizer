# Menu Customizer 3.2.12

Fixes unreadable Emerald battle text using Emerald's actual normal and narrow battle fonts and renderer.

- Dialogue and command menus render complete strings at Emerald's native line spacing, avoiding the Game Boy fixed-glyph path that broke the text.
- Move selection uses the actual Emerald battle fonts for move names, PP, type information and cursors, across battle styles when MENU FONT is EMERALD.
- Bundle original Emerald battle glyph masks and widths so the font works without an Emerald extraction.
- Keep the actual battle font isolated from the selected menu adapter, preserve selected borders and retain the iOS selector correction.

Restart after updating. Choose MENU FONT > EMERALD.

Validation: all 11 games boot with KIM1025; menu/layout and font ownership regressions pass in Lua 5.3 and LuaJIT. Windows LOVE rendering checks dialogue and moves with and without Emerald cache files, verifies bundled normal/narrow mask pixels exactly match the Emerald extraction, and compares the native move panel pixel-for-pixel. Gameplay input was not exercised.
