Menu Customizer 3.2.14
Fix overlapping Emerald battle letters by clipping glyph atlas cells to their actual widths, matching the native Emerald renderer. Use matching font widths when spacing GB battle HUD text. Draw command panels as two adjacent frames rather than stacking a second frame over a full-width border.

Keeps the Gen 1/2 generation boundary fix and KIM1025 positioning. Original normal/narrow fonts remain available in dialogue and move selection.

Validation: Windows LOVE checks portable normal/narrow rendered text pixel-for-pixel against the native Emerald font; cached Gen 1/2 safety, Gen 3 rendering and offline fonts pass. All eleven games boot with KIM1025. Menu, font ownership and move layout regressions pass in Lua 5.3/LuaJIT. Rendered move screen inspected; live gameplay was not exercised.

Restart after updating.

Menu Customizer 3.2.13
Fix Gen 1/2 crashes when Emerald extraction assets are present. Gen 1/2 use the bundled original Emerald normal/narrow battle fonts for dialogue, commands and move selection, without loading Gen 3 engine modules. Gen 3 retains its native Emerald renderer. Generation-native GB HUDs and KIM1025 positioning remain in use. Restart after updating.

Menu Customizer 3.2.12
Fixes unreadable Emerald battle text using Emerald's actual normal and narrow battle fonts and renderer.

- Dialogue and command menus render complete strings at Emerald's native line spacing, avoiding the Game Boy fixed-glyph path that broke the text.
- Move selection uses the actual Emerald battle fonts for move names, PP, type information and cursors, across battle styles when MENU FONT is EMERALD.
- Bundle original Emerald battle glyph masks and widths so the font works without an Emerald extraction.
- Keep the actual battle font isolated from the selected menu adapter, preserve selected borders and retain the iOS selector correction.

Restart after updating. Choose MENU FONT > EMERALD.

Validation: all 11 games boot with KIM1025; menu/layout and font ownership regressions pass in Lua 5.3 and LuaJIT. Windows LOVE rendering checks dialogue and moves with and without Emerald cache files, verifies bundled normal/narrow mask pixels exactly match the Emerald extraction, and compares the native move panel pixel-for-pixel. Gameplay input was not exercised.

Menu Customizer 3.2.11
Move START selectors down two logical pixels on iOS. Battle UI now uses MENU FONT, including native and Emerald battle layouts and KIM1025 move panels. Emerald uses proportional measurements, readable contrast and uniform scaling; full-size panels use larger glyphs while native panels retain their row spacing. Existing Ruby/Sapphire custom selector routing is retained. Restart after updating.

Menu Customizer 3.2.9
Inset battle dialogue two pixels from the left border.

Menu Customizer 3.2.8
Center customized battle command labels and their cursors in each column. Raise dialogue and command rows for balanced vertical padding.

Menu Customizer 3.2.7
Remove fractional background seams; inset PP and center type details inside the move selector.

Menu Customizer 3.2.6
Move selector: composite borders at screen scale; match battle opacity; vertically center complete move names in four invisible cells.

Menu Customizer 3.2.5
Battle borders now share the dialogue reference thickness and repeat spacing.
Command width and move layout scaling no longer stretch or crowd border tiles.

Menu Customizer 3.2.4
For Gen1Recomp 0.3.54+ (0.3 series)
GitHub: Bentley734/Menu-Customizer

SUPPORTED GAMES
Red, Blue, Yellow, Gold, Silver, Crystal, FireRed, LeafGreen, Ruby,
Sapphire and Emerald.

INSTALL
Replace the previous Menu Customizer / Gen3Transparency / Widescreen FireRed
installation with this ZIP. Do not enable multiple copies. The internal ID
remains gen3transparency so the existing installation and settings carry over.

ALL-GAME BORDER PICKER
Open OPTION > MENUS > MENU BORDER.
DEFAULT follows the current game's normal frame setting.
Every supported game can use all 47 borders:
  FR/LG, Emerald and Ruby/Sapphire frames, with identical artwork listed once
  R/B/Y (unique original Game Boy border; different from every G/S/C frame)
  G/S/C 01-08
Shared GBA entries show all source games in their labels. Red/Blue/Yellow
share one frame, and Gold/Silver/Crystal share eight selectable frames.
Twelve duplicate entries were removed. Existing saved border choices migrate
to the same artwork, including selections that previously named a duplicate.
Unused cartridge graphics are not listed.

Game Boy frames are converted from their six corner/edge tiles into the same
nine-tile atlas used by GBA. The two generations' different window bounds are
adapted when drawing, preserving 8x8 corners and repeating edge tiles.
Original colors and crisp nearest-neighbor pixels are retained. A GBA border
can be used on GB/GBC, and a GB/GBC border can be used on GBA.
No additional game import is needed to use another game's border artwork.
Existing FR/LG and Emerald choice numbers are unchanged on upgrade.

MENU CUSTOMIZATION
OPTION > MENUS contains START, OPTION, SAVE and OTHER pages.
Positions: DEFAULT, LEFT, RIGHT, TOP LEFT, TOP RIGHT, BOTTOM LEFT,
BOTTOM RIGHT, CENTER, TOP CENTER and BOTTOM CENTER.
Scale: 50%-150%. X/Y offsets: -128 to +128 pixels.
Opacity: 65%-100%. SAVE uses OTHER opacity, as in the previous version.
START text alignment: LEFT, CENTER or RIGHT.
START selectors: POKEBALL, UNDERLINE, ARROW or DOTS.
Also includes HIDE START MODS, background dim, control hints,
transitions and position preview.
Changes take effect immediately and are saved to the engine's options.

GENERATION-SPECIFIC BEHAVIOR
Gen 3 retains the existing screen-space menu renderer and live overworld,
including its compatible WildFollowers animation support. Ruby and Sapphire
use the shared RSE menu path. Custom borders replace standard/fixed-standard
and user-framed windows; bespoke bag/battle artwork remains native.

Gen 1/2 use native input states and a separate transparent menu canvas over
the live map. Their menus, nested options pages and save prompts keep normal
input/update ownership. NPCs continue animating while menus are open; Gen 2
also advances its map tile animation. Player movement and field scripts are
not advanced by this ambient pass. Battle and mod-manager screens retain
their native rendering. Borders apply to mirrored menu windows rather than
to ordinary overworld dialogue. Gold's optional description panel moves
with START and is kept on screen. START hides beneath SAVE.

The GB/GBC MENUS settings page has a compact scrolling layout appropriate
for 160x144; use A to open a page, left/right to change values, and B to return.
Position previews outline a visible menu's bounds when its settings change.

RELOADS / GAME SWITCHING
Installers reuse the drawing wrappers and refresh their current settings and
assets. Switching game profiles does not duplicate the MENUS group or picker.
An inactive/unloaded installation stops applying its menu/border overrides.

ARTWORK SOURCES
Existing FR/LG and Emerald images are retained from the supplied 2.1.0 ZIP.
Additional native frame artwork comes from the pret game source projects:
https://github.com/pret/pokered (gfx/font/font_extra.png)
https://github.com/pret/pokeyellow (matching Gen 1 border graphics)
https://github.com/pret/pokegold (gfx/frames/1.png through 8.png)
https://github.com/pret/pokecrystal (matching Gen 2 frame graphics)
https://github.com/pret/pokeruby (graphics/text_window/1.png through 20.png)
Ruby/Sapphire RGB colors are normalized to the cartridge's 5-bit palette.

VALIDATION
Validated against Gen1Recomp v0.3.54 source. The real mod loader successfully
loads all eleven game profiles. Automated behavior checks exercise all 47
atlases, all three Gen 3 frame paths, default fallback, picker wrapping,
settings persistence, GB/GBC menu navigation, position/scale bounds, live NPC
updates, battle exclusion, unloading and repeated profile switches.
Native GB/GBC START and settings layouts were rasterized with cartridge fonts
and inspected. ROM-backed gameplay and live GPU testing remain pending.


3.1.0: EMERALD PRESENTATION AND GEN 2 SELECTORS
OPTION > MENUS > MENU STYLE now offers NATIVE or EMERALD. EMERALD is the
new default. DEFAULT border uses Emerald 01 while this style is enabled;
an explicitly chosen border is retained. Native restores cartridge text
and its default frame without discarding positioning or selector settings.

The shared presentation uses Emerald's extracted normal/small Latin glyph
masks and frame across the in-game START, Bag/Pack, party, Pokedex, Options,
Save, trainer and navigation menu groups. GBA START uses the native Emerald
window, row pitch and text offsets. GB/GBC adapts the artwork to its 8px text
rows and tile-grid geometry. Accented Latin text is supported. Other scripts
and cartridge-specific text/control glyphs retain their native renderer.

This is a shared visual-theme port, not replacement implementations of
Emerald's Bag, party, Pokedex or navigation screens. Their generation-specific
layouts, data, actions, special prompts and input stacks remain native.

Gen 2 palette printing now moves label glyphs and their opaque paper together.
Selectors draw after the text and reserve their own space. Long labels fit
inside the panel rather than covering the selector or border. Palette printing
works after switching from Gen 1 to Gen 2, and selectors survive mod reloads.
Positioning measures transformed panel bounds for all groups; DEFAULT scale
changes preserve the native panel anchor, while offsets clamp at screen edges.

Validation: 286 native GBC palette/layout checks, including all four selectors,
three alignments, long labels, ten positions in all four groups, theme/reload
behavior and the main screen groups. All Lua compiles under LuaJIT and Lua 5.3.
A LOVE GPU preview checks selector visibility and panel positioning. This is
not a live gameplay pass through every menu in all eleven cartridges.

Artwork provenance: assets/emerald normal/small foreground and shadow PNGs
are lossless conversions of the locally imported Emerald Latin font sheets;
width tables are the imported native metrics. Original border atlases retain
their previous provenance. No third-party follower implementation is used.


3.1.1: GB/GBC BOOT FIX
The Emerald theme uses bundled glyph mapping data and no longer requires a
Gen 3 engine module on Gen 1/2. The published 3.1.0 ZIP reproduces the exact
cross-generation Loader error on Red, Blue, Yellow, Gold, Silver and Crystal.
3.1.1 loads through the actual 0.3.58 Loader/Sandbox on all six. Selector and
layout checks are rerun under LuaJIT and Lua 5.3.

3.1.2: GB/GBC menus now render the bundled Emerald font on a doubled surface. Uniform glyph scaling and proportional pen advances preserve the original pixels and proportions; compressed POKeGEAR and Pokemon ligatures use themed glyphs.

3.1.3: Gen 2 START item descriptions are hidden so selection cannot shift menu docking. Confirmation prompts remain available.

3.1.4: START labels in Gen 1/2 use full native Emerald glyph size and advances. Dense eight-pixel-row screens retain their compact font layout.

3.1.5: Space glyphs are blank and protected against unsupported native character aliases. Gen 1/2 trainer cards retain their native opaque background fills.

3.1.6: Gen 2 Options submenu links omit the redundant OPEN value and colon. Main labels and the cursor follow the selected justification; actual setting values remain visible.

3.1.7: The main Gen 2 Options page contains navigation labels only. Direct settings open native detail pages with the original control and BACK; the parent and detail pages share option storage. Main labels keep selected justification.

3.1.8: Main Options and MENUS navigation use full START-sized Emerald text and selected justification. MENUS settings open separate detail pages; navigation has no OPEN/value lines.

3.1.26: Native opaque screen backgrounds survive menu compositing, including Pack, Controls and Codebreaker lists.

GEN 1/2 MENU DIMENSIONS
OPTION > MENUS > START / OPTION / SAVE / OTHER now includes WIDTH and HEIGHT.
WIDTH: 70-130%; HEIGHT: 80-130%; both adjust in 5% steps and default to 100%.
These adjust frame geometry and row spacing while glyphs retain uniform proportions.
SCALE still changes the entire menu uniformly. Long START labels scroll when needed.


3.1.27: Enlarged Gen 1 party pages are captured without cropping. Empty transferred nicknames display species names without editing saved records.

3.1.29: Battle party, bag and summary screens retain their native full-size rendering at every overworld zoom level. Field snapshots are only restored outside battle.

3.1.28: Mirrored Gen 1/2 menus keep the engine UI at its classic size. Opening an enlarged party page now preserves the overworld camera zoom and displays the menu at the normal window scale. The full-page capture and empty-nickname fixes from 3.1.27 are retained.

3.2.0: Battle UI Customizer 1.0.8 is now built into Menu Customizer.
Open OPTIONS > MENUS > BATTLE UI. BATTLE UI offers VANILLA, EMERALD, or MENU BORDER.
MENU BORDER uses the border selected in the parent MENUS page for battle commands, dialogue and moves.
Battle opacity, width and alignment remain independent from overworld menu settings.
Existing Battle UI Customizer settings migrate automatically. An installed standalone Battle UI Customizer is made inactive while this merged mod is enabled; it is no longer needed.
The polished Gen 1 move renderer (full panel bounds, bold names, two-line wrapping and Emerald spacing) now belongs here. Native GB/GBC move menus also use this renderer.
For KIM1025's fullscreen battle menu, use KIM1025 1.7.26 or later, which delegates styling to this mod. Without Menu Customizer, KIM uses its pre-redesign fallback.
Fully restart after updating. Saved games and downloaded assets are unaffected.
Validation: eleven-game loader/settings migration fixtures with and without the legacy mod; existing menu and KIM regressions; real LOVE palette/opacity tests and all border atlases.

3.2.1: GB/GBC apostrophe ligatures use the selected Emerald font, size and advance. Cartridge-padded stat fields retain their right edge with proportional text for every menu border.

3.2.2: Battle MENU BORDER now repeats original 8px tiles along edges and interiors instead of stretching them. Corners retain their size; partial final tiles are cropped.

3.2.3: MENU STYLE is now MENU FONT. Choices: NATIVE, EMERALD, EMERALD COMPACT, EMERALD BOLD and EMERALD CLEAN. Existing values keep their selection. GB/GBC battle dialogue is raised four native pixels; borders and continue arrows retain their positions. Menu fonts also apply to the merged battle renderer.


3.2.4: Restore the 3.2.2 menu-font baseline and remove COMPACT, BOLD and CLEAN.
MENU FONT has NATIVE and EMERALD. Former extra selections resolve to EMERALD.
BATTLE UI > EMERALD now reads the player's imported Emerald font sheets,
widths, metrics, window templates, palettes, textbox and healthbox graphics.
The native normal/narrow fonts, selector arrow and single-line TYPE/name are
rendered by the ported engine presentation code. The chosen MENU BORDER is
retained. Native pixels keep uniform proportions when adapting a viewport.
Generation 1/2 battle records are adapted for presentation only; battle rules,
PP, damage, save records and input navigation are unchanged. KIM1025 1.7.26+
already delegates its move panel here, so no KIM update is required.
Import Pokemon Emerald through Gen1Recomp before enabling this battle style.
Reimport Emerald if its cache predates native narrow-font extraction. The
native battle renderer is retained when the required Emerald cache is absent.
The other battle styles retain their previous implementation.
Fully restart after updating.

Based on the Pokemon Gen 1 Recompilation Project by BOIS CLUB GAMES, LLC
(https://github.com/bryanthaboi/gen1recomp)
Renderer sources and their license are included in lib/emerald_engine and
LICENSE.MD. Mod source is distributed under that license.
