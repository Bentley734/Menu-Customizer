# Menu Customizer 3.35.5 — FR/LG text sizing and battlefield compatibility

Fix oversized and clipped FireRed/LeafGreen text by keeping their fixed native text cells independent of the legacy battle font magnification. Add FR/LG TEXT SIZE: NORMAL or SMALL under Text → Font and Layout → All Fonts, and on the existing battle settings page. SMALL uses the actual FR/LG small font atlas, with matching measurement and wrapping; no fractional text scaling is introduced. Native font uses the FR/LG font.

Let HD Dynamic Battlefields own its Gen3 terrain and final-window background pass instead of painting its scenery twice into the native UI canvas. Preserve the existing background picker when the provider is disabled.

Validation on official gen1recomp v0.3.89: FireRed and LeafGreen battle rendering with the scenery provider disabled/enabled, default and saved user settings, landscape/ultrawide/portrait windows, and National Dex with optional G9/HD sprite mods. Rendered native/Emerald dialogue, party and populated bag screens at both sizes. Ruby, Sapphire and Emerald dialogue, shop and PC comparison images were byte-identical before/after (nine comparisons). Native font sizing/reload/isolation checks and all LuaJIT source compilation passed. These are isolated rendering checks, not a full gameplay playthrough.

Restart the game after updating. Existing saves and user options are preserved.
