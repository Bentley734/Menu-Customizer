# Menu Customizer 3.2.2

Fixes stretched textures when battle UI uses MENU BORDER. Battle dialogue, command and move panels now repeat the original 8-pixel border tiles, just like the regular menus. Corners remain unscaled; panels with partial tile dimensions crop the final tile instead of stretching it.

The selected border, battle opacity, panel placement, Emerald style and text fixes are retained.

Validation: tiled-border tests cover every border atlas, command/dialogue/move panel sizes, fractional bounds, corner count, repeated edge cells, cached partial quads and graphics-state recovery. Existing 752 menu/font/layout checks pass. Real LOVE renders every custom atlas with dialogue text. Eleven-game merged loader/settings fixtures pass. Full live ROM gameplay was not exercised.

Update Menu Customizer and fully restart. No KIM1025 or asset download is needed.

Download: https://github.com/Bentley734/Menu-Customizer/releases/latest
