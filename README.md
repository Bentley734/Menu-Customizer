# Menu Customizer 3.2.1

Fixes the mismatched apostrophe endings in GB/GBC dialogue using the Emerald font. The cartridge stores endings such as apostrophe-t as a single glyph; all seven compressed endings now use the same Emerald face, scale, baseline and measured advance as the surrounding text. Native font fallback remains available when the Emerald theme is disabled.

Also fixes right alignment of cartridge-padded numeric/stat fields when using proportional Emerald text, including three-digit values. This alignment is independent of the selected menu border. Existing menu and battle styles are retained.

Validation: 752 menu/font/layout checks pass under LuaJIT and Lua 5.3; all Lua files compile. Real LOVE rendering verifies the actual extracted Blue contraction glyphs with every custom border. Eleven-game merged loader/settings fixtures also pass. Full live ROM gameplay was not exercised.

Update Menu Customizer and fully restart. No KIM1025 or asset update is needed.

Download: https://github.com/Bentley734/Menu-Customizer/releases/latest
