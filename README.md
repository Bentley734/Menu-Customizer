# Menu Customizer 3.2.14

Fix overlapping Emerald battle letters by clipping glyph atlas cells to their actual widths, matching the native Emerald renderer. Use matching font widths when spacing GB battle HUD text. Draw command panels as two adjacent frames rather than stacking a second frame over a full-width border.

Keeps the Gen 1/2 generation boundary fix and KIM1025 positioning. Original normal/narrow fonts remain available in dialogue and move selection.

Validation: Windows LOVE checks portable normal/narrow rendered text pixel-for-pixel against the native Emerald font; cached Gen 1/2 safety, Gen 3 rendering and offline fonts pass. All eleven games boot with KIM1025. Menu, font ownership and move layout regressions pass in Lua 5.3/LuaJIT. Rendered move screen inspected; live gameplay was not exercised.

Restart after updating.
