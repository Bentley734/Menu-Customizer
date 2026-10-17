# Menu Customizer 3.35.14 — Performance Mode

Add PERFORMANCE MODE directly to Menu Customizer settings. It defaults to ON on Android and OFF on PC; an explicit choice is saved using the existing shared/per-game settings system.

Performance Mode renders box/menu backgrounds and borders at game resolution, then scales the completed panel with nearest-neighbor filtering. This reduces expensive effect shading at enlarged window sizes without stopping animations or changing their speed. Reuse up to 16 panel-sized targets to avoid repeated allocation. Preserve each caller's canvas, transform, clipping and blend state. OFF retains the existing full-resolution rendering for PC eye candy.

Animated font-color shaders now sample the glyph mask first and skip expensive color calculations for invisible pixels. Visible text colors and animation settings stay intact in both modes.

Validation: official v0.3.89 runtime GPU checks on Red, Gold and Emerald, Performance Mode ON/OFF, background translation/resize, defaults and overrides, scaled panel colors/alpha and target restoration; all LuaJIT sources compile and strict ESSL 1.00 border shader compilation passes. No physical Android device timing is available, so device-specific FPS improvement remains to be confirmed.

Restart after updating. Saves and existing customization choices are preserved.
