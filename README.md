# Menu Customizer 3.2.11

Fixes START selector alignment on iOS and makes battle UI honor MENU FONT.

- Move START selectors down two logical pixels on iOS.
- Use selected NATIVE or EMERALD fonts in battle UI, Emerald layouts and KIM1025 move panels.
- Use proportional Emerald measurements, readable contrast and larger full-size move-panel glyphs. Preserve native row spacing and restore font state after errors.
- Retain the local Ruby/Sapphire selector routing fix.

Restart after updating.

Validation: sandbox boots across all 11 games with KIM1025 and optional legacy Battle UI Customizer; selector, font ownership, state restoration, scaling, move layout and border tests pass in Lua 5.3 and LuaJIT. Windows LOVE rendering passes 560 real-font glyph/bounds checks at desktop, ultrawide and portrait sizes. iOS was checked using platform-specific rendering tests, not on an iPhone.
