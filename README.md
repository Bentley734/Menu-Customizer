# Menu Customizer 3.2.0

Menu Customizer now includes the latest Battle UI Customizer 1.0.8. Open OPTIONS > MENUS > BATTLE UI for three styles: VANILLA, EMERALD, and MENU BORDER. MENU BORDER follows the border selected in the parent MENUS page for battle commands, dialogue and move selection. Battle opacity, width and alignment remain independent.

Existing standalone Battle UI settings migrate automatically. If the old Battle UI Customizer remains installed, its rendering hooks become inactive while the merged mod is enabled, preventing overlapping panels. It is no longer needed.

The recent Gen 1 fullscreen move-menu redesign now lives here: shared battle/dialogue bounds, matching borders, bold move names, two-line wrapping and Emerald grid spacing. Native GB/GBC move menus also use the merged renderer. KIM1025 1.7.26 reverts its own visual changes and delegates to this renderer.

Validation: all eleven games boot with KIM1025, with and without the legacy battle mod (22 fixtures). Saved-setting migration, nested settings navigation and style changes pass. Existing Menu Customizer regressions pass under LuaJIT and Lua 5.3; battle scaling and move-screen checks pass. Real LOVE rendering passes 258 palette/opacity cases and 416 glyph/bounds/atlas checks, including every border atlas. Full live ROM gameplay was not exercised.

Update Menu Customizer and KIM1025, then fully restart. Existing saves and downloaded assets are retained.

Download: https://github.com/Bentley734/Menu-Customizer/releases/latest
