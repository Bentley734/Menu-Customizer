# Menu Customizer 3.2.13

Fix Gen 1/2 crashes with Emerald assets installed. Use bundled original Emerald battle fonts for GB dialogue, commands and move selection without loading Gen 3 engine modules. Keep the native Emerald renderer for Gen 3 and generation-native GB HUDs/KIM1025 positioning.

Validated: reproduce the previous cross-generation failure for all six GB games; cached-asset rendering checks pass for Gen 1/2, native Gen 3 rendering and offline fonts pass in Windows LOVE; all eleven games boot with KIM1025; Lua 5.3/LuaJIT font, move layout and compilation checks pass. Live gameplay was not exercised.

Restart after updating.
