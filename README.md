# Menu Customizer 3.2.15

Restore battle borders to the 3.2.11 frame geometry while using the original Emerald battle fonts.

- Keep the selected border artwork, opacity, command placement and full move-panel bounds.
- Render original Emerald normal/narrow glyphs and palettes with uniform physical pixels, independently of frame scaling.
- Fit labels, cursors, PP and complete type names inside the restored frame interiors.
- Expose a final-window battle text presenter for KIM1025, avoiding the 160px Game Boy intermediate canvas.
- Retain Gen 1/2 generation isolation and Gen 3 support.

Update KIM1025 to 1.7.29 alongside this release for crisp Gen 1 fullscreen commands, dialogue and HUD text. Restart after updating.

Validation: pixel comparisons against 3.2.11 borders and native Emerald font rendering in the composed KIM path, plus cached Gen 1/2 safety, Gen 3/offline font checks, eleven-game startup checks and Lua/LuaJIT menu/layout regressions. Live game window capture timed out; gameplay was not verified.
