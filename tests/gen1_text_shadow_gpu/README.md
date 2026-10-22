# Gen 1 text-shadow GPU regression

Exercises the complete G1R 0.3.95 `Game.draw`/Renderer/StateStack pipeline with
Menu Customizer and HD Dynamic Battlefields. It uses the locally imported Red,
Blue or Yellow cache, an in-memory game/options/mod cache, and a real LÖVE GPU.
No player saves or persisted options are written.

Set `HDB_WORKSPACE`, `HDB_PROJECT`, `MENU_SOURCE`, `HDB_RUNTIME_VERSION=0.3.95`,
`HDB_GAME_VERSION` (`red`, `blue`, or `yellow`), and `SHADOW_OUT` (an existing scratch
directory), then launch this test directory with LÖVE. Optional `SHADOW_ENGINE`
selects an unpacked engine directly; `SHADOW_WIDTH`/`SHADOW_HEIGHT` choose the
window size. The default is 1280x720. `HDB_ASSET_SOURCE` can provide the unchanged
bundled artwork when the HDB source checkout is sparse.

The fixture selects Emerald glyphs, red foregrounds, black shadows, and a
left-aligned two-line command prompt. For each of Squirtle, Charmander, What will,
and Charmander do?, it renders the same font without clipping to form an exact
reference mask. Every black shadow pixel one font pixel left of the first glyph
must appear in the final game frame. Glyph pixels must remain square and
integer-scaled. `checks.json` records every anchor, scale, scissor and mask count.

A separate native HUD surface case verifies that an opaque cover adjoining the
name's left edge still wins: the control paints 63 shadow pixels in that area;
the cover preserves all 144 cover pixels and permits no shadow overpaint.

To reproduce the original bug, point `MENU_SOURCE` at version 3.35.23 and set
`SHADOW_EXPECT_CLIPPED=1`. It expects at least three clipped labels and skips the
new-overhang control, while retaining its screenshots and measurements.

The verified fixed matrix is Red at 1280x720, 480x360, 1279x799 and 2436x1410,
plus Blue and Yellow at 1279x799. All four first-letter masks and the opaque-cover
check pass. A before/after image comparison additionally confirmed unchanged
anchors/scales and an identical foreground red-pixel mask (8,272 pixels).
These are focused native rendering fixtures, not a complete gameplay playthrough
or a physical Android GPU test.
