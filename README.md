# Menu Customizer 3.2.93

Show single-choice border families as directly selectable entries instead of one-item submenus. Rename surviving Pokemon borders: Lucario Aura Trails, Charizard Ember Flow, Blastoise Tidal Waves, Mewtwo Psychic Dance, Gengar Shadow Eyes and Lapras Pokeball Orbits. Preserve numeric IDs and saved selections, previews and multi-choice border groups.

Validation: LuaJIT/Lua 5.3 compilation and preview regression checks. Restart after installing.

# Menu Customizer 3.2.92

Left-align ordinary options values in the native shared value column so short and long values start uniformly. Preserve cartridge choice layout, selector positions and Continue summary spacing.

Validation: LuaJIT/Lua 5.3 compilation and preview regressions. Restart after installing.

# Menu Customizer 3.2.91

Center cartridge choice markers beside option text using a two-pixel downward offset, between the previous too-high and too-low positions. Leave ordinary row selectors unchanged.

Validation: selector dispatch, selected-color and preview checks; full compilation under LuaJIT and Lua 5.3. Restart after installing.

# Menu Customizer 3.2.90

Remove the extra four-pixel row-centering offset from cartridge choice markers so they align with Text Speed and Button Mode text. Ordinary row selectors remain unchanged.

Validation: all choice styles and selected-color checks, preview regressions and full compilation under LuaJIT and Lua 5.3. Restart after installing.

# Menu Customizer 3.2.89

Right-align ordinary settings values, including selector names, OPEN labels and percentages, using the active font width and matching the window inset. Preserve multi-choice cartridge control layout and choice markers. Apply to Gen 3 options and GB native options value rows.

Validation: full compilation under LuaJIT and Lua 5.3 and existing preview regression checks. Live gameplay was not exercised. Restart after installing.

# Menu Customizer 3.2.88

Match Continue details right inset to the four-pixel left inset. Position the player name beside PLAYER with a six-pixel gap, and place TIME and BADGES six pixels before their right-aligned values. Measure active fonts and values when positioning; preserve child-menu layout.

Validation: full compilation under LuaJIT and Lua 5.3 and existing preview regression checks. Live gameplay was not exercised. Restart after installing.

# Menu Customizer 3.2.87

Add SELECTORS > CHOICE SELECTOR with an independent choice style and selected text color. Emerald cartridge choices, including Text Speed and Button Mode, support all 13 existing selector styles plus TEXT COLOR (the default). Replace the fixed underline with the configured style. Ordinary menu arrows retain their own setting.

Validation: all selector styles dispatch independently and selected text color follows all values, preview regressions and full LuaJIT/Lua 5.3 compilation. Live gameplay was not exercised. Restart after installing.

# Menu Customizer 3.2.86

Inset RSE main-menu option labels and left-column Continue details by four logical pixels from the interior border. Preserve right-aligned details and child-menu layout.

Validation: both Lua runtimes compile and existing preview regressions pass. Restart after installing.

# Menu Customizer 3.2.85

Underline the active Emerald cartridge-option choice with a contrasting marker, so custom text palettes cannot hide which Text Speed or Button Mode value is selected. Apply to all visible cartridge choice rows.

Validation: marker follows all three values; preview regressions and full compilation under LuaJIT and Lua 5.3. Live gameplay was not exercised. Restart after installing.

# Menu Customizer 3.2.84

Keep settings labels and selected-choice indicators on saved values while live previews temporarily restyle the current options window. Prevent background previews from making other background options appear changed. Applies to GB and Gen 3 menus. Restore all wrapped callbacks and preview state after drawing errors.

Validation: independent saved background values/labels during previews, selection indicators, error restoration, existing preview/case regressions and full compilation under LuaJIT and Lua 5.3. Live gameplay was not exercised. Restart after installing.

# Menu Customizer 3.2.83

Remove font paper from RSE Continue/main-menu captions, preserving foreground and shadows and restoring the printer on errors.

Validated transparent caption options and restoration under both Lua runtimes, full compilation, and installed-engine options integration checks. Live gameplay was not exercised. Install alongside 1025Dex 1.2.53 and restart.

# Menu Customizer 3.2.82

Fix Emerald OPTIONS integration: forward native cartridge-row metadata so Text Speed and Button Mode retain their native controls; read Emerald's actual page state to draw custom selectors and highlights on all settings pages, including BACK.

Suppress the original options canvas only during gameplay's screen-space replay. Keep the title/main-menu OPTIONS canvas visible instead of producing a black screen.

Validation: actual Emerald input-handler checks for Text Speed and Button Mode, selector and BACK placement, render-guard checks, preview restoration regressions, and full compilation under LuaJIT and Lua 5.3. Live gameplay was not exercised. Restart after installing.

# Menu Customizer 3.2.81

Draw the title-screen Ash illustration once through the final-resolution sprite pass. Remove its low-resolution underlay, which can leave dark speckles and stair-stepped edges showing through the artwork's alpha. Retain linear image filtering and use straight-alpha blending for the fallback renderer.

Restart to load the update.

# Menu Customizer 3.2.80

Give native GB intro/title customization a dedicated INTRO / START SCREEN submenu and independent presentation settings.

- Independent intro font, size, foreground color, shadow color, effects/presets/transparency/speed and capitalization. Intro and title text, Game Freak artwork and stars use the intro text settings instead of MENU settings. Background selection remains independent.
- Add TITLE TRAINER: VANILLA or ASH ARTWORK, using the supplied transparent Ash illustration with preserved proportions and final-resolution UI replay.
- Add TITLE LOGO: VANILLA or HIGH RESOLUTION, retaining the supplied Pokemon logo as the high-resolution choice.
- Preserve native Pokemon/trainer sprite protection and avoid repainting the title trainer during sprite replay when Ash is selected.

Validation: Lua source compilation and focused shared-settings checks under LuaJIT and Lua 5.3. Live gameplay was not restarted. Restart to load the update.

# Menu Customizer 3.2.79

Keep native Gen 1 options-card selection highlights within the card's 16-pixel interior rather than covering the entire 32-pixel row pitch. Use an 8-pixel highlight for the unframed BACK footer, preventing the highlight from extending below the screen and revealing the overworld.

Restart to load the fix.

# Menu Customizer 3.2.78

Use the selected menu text foreground color for the GAME FREAK splash lettering and emblem, matching the falling stars while custom intro backgrounds are active. Keep white paper transparent and preserve the full-color Pokemon title logo.

Restart to load the update.

# Menu Customizer 3.2.77

Remove white paper from the native GAME FREAK emblem above the splash lettering and tint the falling/shooting star artwork with the selected menu font foreground color while custom intro backgrounds are active. Pokemon and trainer white-detail preservation remains active.

Restart to load the update.

# Menu Customizer 3.2.76

Remove the white paper between GAME FREAK splash-screen letters. Exclude the native lettering asset from the portrait exterior-mask override so it uses the original transparent text palette. Pokemon and trainer white-detail preservation remains active.

Restart to load the fix.

# Menu Customizer 3.2.75

Render intro/title Emerald glyphs at whole source-pixel scales instead of fractional 0.5/0.75 scales on the native canvas. Snap text anchors to whole pixels, preserve uniform glyph proportions and baseline alignment, and cap long captions at the largest whole scale fitting the screen width.

The high-resolution logo is preserved. Restart to load the text fix.

# Menu Customizer 3.2.74

Replace the native title-screen Pokemon logo with the user-provided high-resolution color PNG. Crop transparent margins, preserve its aspect ratio and alpha, and fit it to the existing logo area. Replay it through the final-resolution UI sprite pass for sharper rendering instead of relying on the low-resolution game canvas.

Restart the game to load the update.

# Menu Customizer 3.2.73

Add INTRO / START SCREEN FONT (USE MENU, NATIVE, EMERALD) and INTRO / START TEXT SIZE (NORMAL, LARGE, EXTRA LARGE) under TEXT for native Gen 1/Gen 2 boot screens.

Boot text now participates in the shared menu text colors, shadows, effects and decapitalization settings. Render Gen 1 version labels and copyright/studio captions through the selected font when Emerald is enabled. Preserve the Pokemon logo as artwork and retain the separate sprite-white preservation/background-removal paths.

Restart the game to load the update.

# Menu Customizer 3.2.72

Fix intro sprite white details while keeping logo and text paper transparent.

- Restore white-key removal for decorative/logo/font images only; protect Pokemon and trainer drawing.
- Override the native boot sprite palette loader within the active intro draw so it no longer discards every white sprite pixel.
- Build and cache exterior-paper masks from native source assets: white regions connected to the image edge become transparent while enclosed white sprite details stay opaque. Apply this to Gengar/Nidorino intro frames and native trainer palette images, including replay layers.
- Restore temporary image references and sprite-loader hooks after drawing.

Validation: Lua source compilation. Restart the game to load the update.

# Menu Customizer 3.2.71

Preserve white Pokemon and trainer sprite details with custom intro backgrounds. Remove the global white-key image shader; replace only explicit white screen fills and clears, leaving sprite images intact.

Restart the game to load the fix.

# Menu Customizer 3.2.70

Add INTRO / START SCREEN BACKGROUND under BACKGROUNDS for native Gen 1/Gen 2 boot screens. DEFAULT keeps original rendering; any existing static or animated background replaces white screen paper during the intro movie, title/start screen and professor introduction.

White native image paper is keyed transparent so the selected background shows behind the artwork. Native screen state, input and music remain controlled by the game. Restart to load the update.

# Menu Customizer 3.2.69

Simplify Pokemon border choices and add eight matching psychedelic animated wallpapers and borders.

- Keep only Lapras Pokeball Orbits, Gengar Psychic Eyes, Mewtwo Leaf Dance, Charizard Ember Flow, Blastoise Tidal Waves and Lucario Volt Trails in their respective families.
- Remove Rainy Route, Sacred Lattice, Vision Field and Third Eye from the background pickers.
- Add Solar Fractal, Emerald Mandala, Amethyst Prism, Chromatic Lotus, Infinite Star Gates, Molten Honeycomb, Neon Chrysalis and Cosmic Rosette. Find wallpapers under TRIPPY and borders under OTHER ANIMATED DESIGNS. Each uses continuous animated procedural patterns, inspired by the available kaleidoscope reference, with frame motion following the closed perimeter through corners.
- Keep retired numeric slots for save compatibility; old removed Pokemon frame selections render their family's retained frame. Existing selection IDs do not shift.

Validation: Lua source compilation and a GPU render of all eight new wallpapers. Four referenced image attachment paths were unavailable; the visible orange/green fractal image was used as inspiration.

Restart the game to load the update.

# Menu Customizer 3.2.68

Customize the Gen 1 CONTINUE save-summary panel with SAVE SUMMARY FONT, SAVE SUMMARY BACKGROUND and SAVE SUMMARY BORDER. Find these in TEXT, BACKGROUNDS and BORDERS respectively. Font offers USE MENU, NATIVE and EMERALD; background and border can inherit the shared menu choices.

Apply selected styling directly to the boot save-summary window and preserve its colors through the Gen 1 palette pass.

Testing skipped at the user's request. Restart the game to load the update.

# Menu Customizer 3.2.67

Remove the Hoenn Forest, Sootopolis, Volcano and Sky Pillar theme presets. The eleven Pokemon character theme presets remain available. Existing applied settings and individual backgrounds are preserved.

Restart the game to load the updated theme list.

# Menu Customizer 3.2.66

Make customization visible inside the options window, add text case controls and coordinated Pokemon theme presets.

- Hover/focus color, background, border and theme choices to preview them in the open window. Draw-only option overrides restore after rendering, including errors; A applies a picker choice and B leaves the saved selection intact.
- Preview scoped text colors, shadows and effects through the menu sample; setting adjustments update the current window without leaving the menu.
- Paint the GB options selection highlight after opaque glyph paper, with raised-font baseline alignment, full row pitch and menu-scale compensation.
- Add TEXT DECAPITALIZATION: ORIGINAL, SENTENCE CASE or LOWERCASE. Apply at font drawing/measurement boundaries while preserving encoded control tags and game text data.
- Place SETTINGS STORAGE at the bottom of the main Menu Customizer menu; add POKEMON THEMES above it.
- Add fifteen matching theme presets: Pikachu, Bulbasaur, Charmander, Squirtle, Mew, Gengar, Eevee, Jigglypuff, Dragonair, Umbreon, Snorlax, Hoenn Forest, Sootopolis, Volcano and Sky Pillar. Themes set shared fonts, palettes, borders, backgrounds, selectors, effects, opacity and transitions together; applying a theme updates the active settings profile.

Validation: focused preview restoration/control-tag/text-case checks under LuaJIT and Lua 5.3; source compilation and existing selector/font regressions; native startup/menu navigation across eleven games. No live gameplay session was restarted.

Restart the game to load the update.

# Menu Customizer 3.2.65

Add 30 Pokemon background choices: 15 still and 15 animated, inspired by the workspace background references, anime atmosphere and Generation 3 locations. Use existing bundled Pokemon artwork and new pixel-scene shaders to keep the download and creation cost small.

Find them under BACKGROUNDS, your background setting, POKEMON STILL or POKEMON ANIMATED.

Designs: Petalburg Fireflies, Slateport Sunset, Mt Chimney Embers, Meteor Falls, Fortree Canopy, Sootopolis Lagoon, Shoal Cave Snow, Sky Pillar Clouds, Safari Berry Grove, Littleroot Picnic, Lavender Lanterns, Moonlit Rooftops, Cerulean Bubbles, Contest Ribbons and Pokemon Postcards. Each design has separate still and animated choices. Still choices freeze both scenery and Pokemon artwork; animated choices add character animation and scene-specific motion. Saved background IDs remain stable.

Testing skipped at the user's request. Restart the game to load the update.

# Menu Customizer 3.2.64

Style the Gen 1 opening CONTINUE / NEW GAME / OPTION / EXIT GAME menu with the existing MENU FONT, MENU BACKGROUND and OTHER BORDER settings (OTHER BORDER defaults to the shared menu border).

Give its arrow selector a one-logical-pixel gap before the label. Enable the full menu font and preserve the chosen frame/background colors on the opening screen, which has no overworld HUD underneath it.

Restart the game to load the update.

# Menu Customizer 3.2.63

Align selected-row highlights with the raised Emerald menu font. The highlight now starts above the full label instead of halfway through it, compensates for menu height scaling, and covers both lines in detail rows. Apply the same alignment to the START highlight selector.

Restart the game to load the update.

# Menu Customizer 3.2.62

Move Gen 1 Pokedex entry behavior to KIM1025 1.7.38.

Menu Customizer now supplies screen/font classification and shared border/background settings only. It no longer wraps entry drawing, sprite orientation, measurements or pagination. This removes the competing sprite draw hook; install KIM1025 1.7.38 to retain the entry improvements.

RAINY ROUTE and existing settings remain available. Restart after installing both updates.

# Menu Customizer 3.2.61

Add RAINY ROUTE to the ANIMATED background choices, using the user-provided rainy Pokemon scene.

- Preserve all 159 frames and the original 20 fps loop.
- Fit each background with a centered cover crop, preserving its aspect ratio and nearest-neighbor pixel rendering.
- Bundle the animation locally and load its atlas pages on demand. Existing background selections keep their saved IDs.

Tests skipped at the user's request. Restart the game, then choose BACKGROUNDS, the desired background setting, ANIMATED, RAINY ROUTE.

# Menu Customizer 3.2.60

Improve Gen 1 Pokedex entry presentation, including 1025Dex statistics and information pages.

- Add POKEDEX BORDER under BORDERS; USE MENU follows the default border. Apply the selected frame to both entry panels and to the stats/information pages.
- Inset descriptions four more logical pixels while preserving measured wrapping and pagination.
- Replace GR./GEW. with Height/Weight and display feet/inches and pounds, rounded to the nearest inch and tenth of a pound. Keep labels and values inside the upper panel.
- Match the stats sprite direction to the main entry and inset stats/information text to clear the new frame.

Validation: focused LuaJIT/Lua 5.3 regressions and 26 GPU checks covering native entry rendering, wrapping, unit conversion, stats sprite direction and padding. The running game was left open; restart to load the update.

# Menu Customizer 3.2.59

Use the menu font on Gen 1 Pokedex list and entry screens, and fit entry descriptions inside their box.

- Recognize standalone Pokedex entries as menu screens, including starter/capture entries opened without the list underneath.
- Wrap description text using the selected font's measured width, with three lines per page and padding inside the lower box. Split long words safely and add as many description pages as needed.
- Keep description pagination independent of 1025Dex stats, forms and additional information pages. A/DOWN advances overflowing descriptions; UP returns to previous description pages. DOWN after the final description reaches the existing stats page; B closes normally.
- Preserve ownership checks and original description data. Avoid duplicating the native printer's final period.

Validation: 48 pagination/navigation/font-context checks under LuaJIT and Lua 5.3; 21 GPU checks using the actual native entry renderer with native/Emerald fonts; existing menu regressions and startup checks across eleven games. The running game was left open.

Restart the game after installation to load the fix.

# Menu Customizer 3.2.58

Make Gen 1/2 YES/NO text match the dialogue font and size instead of the compact menu font.

- YES/NO selects the dialogue font face, scale and ink baseline while retaining its configured menu text/background colors.
- Gen 1 choice letters use the same final-resolution rendering as dialogue, preserving complete glyph masks and square integer pixels. Mixed dialogue/choice rendering keeps their colors independent.
- Preserve dialogue text size when menu width/height resizing is enabled. Restore all font and palette scopes after drawing.

Validation: 153 real GPU checks, including exact YES/NO/dialogue pixel-size equality with nonuniform menu resizing, and native/Emerald font, RGB and selector regressions. LuaJIT and Lua 5.3 regression checks; startup/category navigation across all eleven games with current KIM1025 source. GPU checks use isolated render fixtures; the running game was left open.

Restart the game after installation to load the fix.

# Menu Customizer 3.2.57

Organize customization by type and add dialogue alignment, selector colors, and effect transparency.

- Seven categories: TEXT, BORDERS, BACKGROUNDS, TRANSITIONS, SELECTORS, POSITION, TRANSPARENCY. Battle controls follow the same categories on all eleven games.
- Dialogue alignment: LEFT (default), CENTER, RIGHT. Retain the full line's alignment while typing, vertically center the two-line block between the borders, and add horizontal padding. Keep custom font sizes and whole square pixels stable across pages.
- Starter picture and YES/NO windows use the menu background and text palette, independently of dialogue colors.
- Move battle command and move selection markers one logical pixel left.
- Add a shared UNDERLINE / DOTS COLOR picker. Both styles are available under ARROW SELECTOR, alongside NONE for a transparent highlight without a marker. START SELECTOR adds HIGHLIGHT, using the existing HIGHLIGHT INTENSITY setting.
- Rename the general transition control MISC TRANSITIONS.
- Remove GLOW and DOUBLE SHADOW controls and rendering, including legacy saved effects.
- Independent 0–100% HIGHLIGHT, OUTLINE, SHADOW transparency for menu, battle and Pokemon-name text, in 5% steps.
- Preserve existing saved selector, palette and border IDs.

Validation: 4,251 real GPU checks for dialogue placement, integer glyph geometry, RGB preservation, selector ownership, preview/YES-NO palettes, and effect alpha. LuaJIT and Lua 5.3 regressions; actual startup and category navigation for all eleven games with current KIM1025 source. GPU checks use isolated render fixtures; the running gameplay session was left open.

Restart the game after installation to load the update.

# Menu Customizer 3.2.56

Fix Gen 1 field dialogue backgrounds and fonts, and duplicate menu selectors.

- Preserve the complete dialogue window's RGB colors through Gen 1's indexed palette compositor, including its animated paper and glyphs. Previously only border strips bypassed palette conversion.
- Defer Gen 1 field dialogue glyphs until final screen/effects resolution. Keep complete Emerald glyph masks on square integer pixels instead of reducing them into the native canvas first.
- Use the correct alpha blend mode for direct glyph rendering, including native font masks.
- Remove the settings page's extra inline selector. The shared label-aligned selector draws it once.

Validation: 126 real GPU checks through the actual frame/palette compositor, covering native and Emerald faces, border on/off, animated background RGB preservation, glyph transparency and integer geometry, and selector ownership; 54 existing selector/font GPU checks; LuaJIT/Lua 5.3 regressions and startup checks for all eleven games with current KIM source.

Restart the game after installation. Gameplay was left running.

# Menu Customizer 3.2.55

Restore missing field dialogue when the renderer uses its intermediate present/effects canvas. Deferred letters now draw into window-sized canvases before processing, as well as directly to the screen. Keep the fixed chosen font size, two-line pagination, integer glyph pixels, continuous animated borders and highlight controls from 3.2.54.

Validation: actual GPU reproduction of the intermediate-canvas path, verified visible dialogue pixels; existing font/selector GPU checks and LuaJIT/Lua 5.3 regressions; startup with the latest KIM source across eleven games. Restart the game after installing.

# Menu Customizer 3.2.54

- Animated borders now follow one closed rounded path. Patterns flow around all four corners and the loop closes without restarting on each edge. Animated frames use one solid strip instead of separate atlas corner pieces.
- Custom-size field dialogue retains the chosen size across messages. Long text wraps into two-line pages instead of shrinking to fit the current string. Long plain names can wrap at UTF-8 glyph boundaries.
- Large and Extra Large dialogue boxes grow upward by a fixed amount for their selected size, keeping both lines inside the borders.
- Multiline Emerald dialogue uses the same glyph face and line spacing on every page. Prompt end positions follow the final line.
- Retain the selector visibility and highlight intensity controls from 3.2.53.

Validation: 2,520 real GPU checks for arc length, loop closure, thickness and solid corners across all 16 animated families; 1,439 GPU checks for stable custom font sizes, horizontal/vertical bounds, wrapping, pagination and text preservation; previous selector GPU regression; LuaJIT/Lua 5.3 rendering regressions; startup checks for all eleven games.

Restart the game after installation. Gameplay was left running.

# Menu Customizer 3.2.53

Built from the actual 3.2.52 release package, retaining its backgrounds, borders, organization and saved settings. The repository source now includes the complete release contents.

- Draw a visible settings-menu selector for all ten Arrow Selector choices, including the default arrow. Keep Start Selector independent.
- Add MENUS > MENU SELECTOR > HIGHLIGHT INTENSITY, adjustable from 0% to 100% in 5% steps (default 25%).
- Raise field dialogue letters by three logical pixels. Defer them until the UI reaches its final screen size, preserving complete glyph masks with uniform square integer pixels at fractional zoom.
- Snap Large and Extra Large battle text to integer framebuffer pixels.
- Fix the inherited 3.2.52 Gen 1/2 startup failure caused by loading a Gen 3 font module.

Validation: real LOVE GPU raster tests for all selectors, highlight opacity and Normal/Large/Extra Large typography; LuaJIT and Lua 5.3 selector, level-label, battle-font and menu-scaling regressions; sandbox boot with KIM for all eleven games; actual settings-row persistence and 0–100% bounds.

Restart the game after installing. Live gameplay was not restarted during installation.

# Menu Customizer 3.2.36

Six original psychedelic backgrounds inspired by visionary art and TOOL: VISION FIELD, SACRED LATTICE, ENERGY ANATOMY, THIRD EYE, INTERBEING and LATERAL SPIRAL.
Layered eyes, sacred geometry, flowing energy lines and spirals in subdued purple, teal and gold. Choose TRIPPY in the menu, Start menu or battle background chooser. COLOR SPEED controls motion; existing choices retain their IDs.

Testing was explicitly skipped at the user's request to conserve usage. Restart the game after updating.

# Menu Customizer 3.2.35

Eight new Start menu selectors: STAR, HEART, LIGHTNING, CRESCENT, DIAMOND, FLAME, PSYCHIC EYE and SPIRAL.
Colourful pixel icons for Gen 1-3, with existing selector IDs preserved. Choose them in START SELECTOR / SELECTOR.

Testing was explicitly skipped at the user's request to conserve usage. Restart the game after updating.

# Menu Customizer 3.2.34

Eight trippy animated borders: ACID RIBBONS, PLASMA BEADS, KALEIDO GEMS, MOLTEN DREAM, NEON CIRCUIT, WORMHOLE, CHECKER MELT and AURORA BRAID.
Available for menus and battle UI frames, with purple, blue, green and pastel palettes. COLOR SPEED controls motion. Existing saved border choices retain their IDs.

Testing was explicitly skipped at the user's request to conserve usage. Restart the game after updating.

# Menu Customizer 3.2.33

Eight animated abstract backgrounds in the new TRIPPY background group: ACID SPIRAL, LIQUID AURORA, KALEIDO DREAM, NEON GRID, PLASMA CLOUD, LIQUID CHROME, COSMIC TUNNEL and DREAM WAVES.
Available for menu, Start menu and battle paper. COLOR SPEED controls their motion. Existing saved choices retain their IDs. Most pair with light text; pastel DREAM WAVES pairs with dark text.

Testing was explicitly skipped at the user's request to conserve usage. Restart the game after updating.

# Menu Customizer 3.2.32

Twelve new menu transitions: VORTEX, ORBIT, RUBBER ZOOM, PENDULUM, SPIRAL IRIS, RIPPLE BLOOM, KALEIDOSCOPE, DIAMOND PORTAL, VENETIAN DREAM, STARDUST DISSOLVE, ZIGZAG PORTAL and CHECKER PHASE.
Spinning entrances, orbiting motion, springy zooms and patterned reveals. Existing saved transition choices keep their IDs. Zooms preserve the menu aspect ratio; effects settle into the normal menu.

Testing was explicitly skipped at the user's request to conserve usage. Restart the game after updating.

# Menu Customizer 3.2.31

Three new menu transitions: POKEBALL BOUNCE (a settling bounce), SURF WAVE (a gentle sideways wave), and TELEPORT (a spinning zoom).
Existing saved transition choices keep their IDs. New zooms preserve the menu aspect ratio.

Testing was explicitly skipped at the user's request to conserve usage. Restart the game after updating.

# Menu Customizer 3.2.30

Add 14 animated Pokémon background choices for menu paper, the separate Start menu background, and battle UI paper. Find them in the new POKEMON group in each background chooser. Existing saved colours, gradients and font choices keep their IDs and appearance.

- Favorites first: MEW STARDUST, MEW PSYCHIC TIDE, MEW NEBULA, CHARMANDER EMBERS and CHARMANDER CAMPFIRE.
- Also includes PIKACHU SPARKS, SQUIRTLE LAGOON, BULBASAUR GARDEN, GENGAR HAUNT, EEVEE COZY, JIGGLYPUFF LULLABY, DRAGONAIR DREAM, UMBREON MOONLIGHT and SNORLAX SNOOZE.
- Gently animated Pokémon stamps, drifting particles and matching motifs: stars, psychic ripples, tail-flame embers, lightning, bubbles, leaves, ghost eyes, paws, musical notes, moonlit ribbons, golden rings and rising Zs. Sprite artwork retains its aspect ratio and transparent padding is excluded.
- Existing COLOR SPEED controls the paper animation; menu and battle speed settings stay independent. Light themes pair with dark text; Nebula, Campfire, Haunt and Moonlight pair with light text. Text colours remain your choice.
- Self-contained bundled animation sheets reused unchanged from the existing KIM HD sprite assets. No helper, external mod, ROM font, or additional asset download is needed for these backgrounds.
- Keep the selected border separate from the paper. Preserve pixelated Gen 3 animated frames, integer menu fonts, HP/levels, battle sprite positions and the inherited/separate Start background choice.

Validation: 411,883 actual LOVE checks for all 14 distinct animations, matching-text contrast, chooser reachability/order, background scope, animation speed, physical DPI, protected border pixels and shader state. 44,284 existing border/effect graphics checks and 25,768 Ruby/Sapphire graphics checks pass, as do Lua 5.3/LuaJIT palette/font/geometry/chooser suites and all 11 game startup/settings routes with KIM1025. Real rendered previews included. Live ROM gameplay was not exercised.

Restart the game after updating. Compatible with KIM1025 1.7.35.

![Animated Mew and Charmander backgrounds](pokemon-backgrounds-preview.gif)

![All 14 Pokemon backgrounds](pokemon-backgrounds-preview.png)

# Menu Customizer 3.2.29

Fix missing/thinned menu letter strokes in Gen 3 with either Emerald or vanilla fonts. Draw menu text at the final window resolution using a uniform integer physical-pixel scale and a pixel-aligned origin, instead of shrinking glyphs inside the native menu canvas before enlarging them.

- Apply to Start, Options and Save menus in Ruby, Sapphire, Emerald, FireRed and LeafGreen. Preserve native measurements, text colours/effects, clipping, opacity and transitions.
- Keep menu frames, backgrounds and animated borders on their existing native-resolution surface. In particular, retain the pixelated Gen 3 animated border look.
- Restore font hooks and graphics state on failures; recreate the final surface when the window or DPI changes. Existing Gen 1/2 menu and battle renderers retain their paths, including vanilla HP/levels and KIM sprite positioning.

Validation: 2,974 actual LOVE graphics checks, including exact reference-font image comparisons across five Gen 3 games, both font modes, 80/100/150% menu size, 1047x699, 1808x1080, 2560x1299, 5120x1440 and a 3x-DPI mobile canvas. Real Emerald Options screen rendered and inspected; nine animated border variants match the previous native-canvas output byte for byte; glyph/clipping, transitions and error restoration checked. Existing Lua 5.3/LuaJIT regression suites, all 11 game startup/settings routes, and 25,768 Ruby/Sapphire graphics checks pass. Live ROM gameplay was not exercised.

Restart the game after updating. KIM1025 1.7.35 remains compatible.

# Menu Customizer 3.2.28

Render Emerald Pokémon names directly at the final KIM HUD size instead of enlarging fractional pixels from the HUD capture. Repeated letters now use identical square pixel blocks.

- Both player and enemy names use one uniform integer scale and a physical-pixel-aligned origin. HUD size and high-DPI scaling determine the closest crisp font size.
- Preserve the name anchors and native level/HP rendering. Keep name colours, alternating colours, gradients, shadows, glow, double shadow and HUD opacity in the final pass.
- Unsupported scripts, the cartridge font, disabled Menu Customizer, the native Emerald healthbox style and very small HUD sizes retain their existing rendering path. The Gen 3 font aspect correction remains unchanged.
- Use KIM1025 1.7.35 for the cooperative final-window name pass. Older KIM versions continue working through the existing capture fallback.

Validation: 887,570 actual LOVE checks through KIM's production HUD capture and composition, matching native Emerald glyphs at 1047×699, 2560×1299, 5120×1440 and a 3× DPI mobile canvas, each with 60/80/100% HUD sizes; repeated T glyphs identical; HP fills/numbers unchanged; fallback and error-state restoration checked. Existing Lua 5.3/LuaJIT suites, all 11 game startup/settings routes, KIM regressions and 34,247 final battle composition checks pass. Live ROM gameplay was not exercised.

Restart after updating both mods.

# Menu Customizer 3.2.27

Add animated Pokémon-inspired frames and a coordinated collection of smooth gradient colours for text and backgrounds.

- Six new animated borders: Rolling Poké Balls, Lightning, Water Ripple, Ghost Wisps, Shooting Stars, and Living Vines. They move around a continuous frame without separate tile seams.
- Nine curated gradient borders: Aurora, Amethyst Tide, Mint Lagoon, Dream Mist, Deep Space, Moonlit Forest, Cotton Candy, Sunset Dream, and Golden Hour. The existing rainbow border is now named Rainbow Flow.
- The same nine palettes are available under Animated in every text, background, shadow, glow, double-shadow, and alternating-colour chooser. Purple/blue/green combinations range from deep jewel tones to soft pastels, with pink and warm sunset alternatives.
- Remove the abrupt RGB chooser. Existing RGB selections become Aurora in place; static colours, Rotating, Animated Gradient, border IDs, and the existing colour-family submenus retain their saved meanings.
- Menu Text Effects → Color Speed controls border motion. Each text scope retains its own Color Speed for its text and background effects. Frame animations preserve the separately selected paper/background and existing frame geometry.

Validation: Lua 5.3/LuaJIT syntax and existing regressions; 11,733 smooth-gradient and saved-ID checks and 2,635 grouped-chooser checks per runtime; 44,284 actual LOVE border/palette graphics checks, including distinct effects, speed equivalence and paper isolation; 25,768 font/paper graphics checks and 34,247 KIM1025 battle composition checks. Startup/settings tested in all 11 Gen 1–3 games with KIM1025 1.7.34. Live ROM gameplay was not exercised.

Restart after installing. Open Menus → Menu Border for the frames, or open a colour chooser → Animated for the new gradients.

# Menu Customizer 3.2.26

Add an animated rainbow-gradient border, group all colour choosers by base hue, and remove separate tile joins from the battle frame renderer.

- Menus → Border → Animated Gradient adds a continuously moving rainbow bevel. The interior keeps the selected menu/Start/battle background. Menu Text Effects → Color Speed controls the border's cycle speed.
- Open any colour setting, choose a family, then select a shade. Neutrals, reds, oranges, yellows, greens, cyans, blues, purples, pinks, browns and animated modes have separate pages. Default/inherited backgrounds and disabled shadows remain under Special. Standard colours appear first, followed by additional shades. The selected shade is marked.
- Covers menu text, menu/Start backgrounds, battle text/backgrounds, Pokémon names, all shadows, glow, double shadow and each of the five alternating colours. All saved colour values and border IDs retain their meanings.
- Render each frame with one quad and padded source cells, eliminating the geometry joins and neighbouring atlas samples that can form thin seams under scaling. Preserve the original frame bounds, interior, sprites and fonts; native HP remains unchanged.

Validation: Lua 5.3/LuaJIT regressions plus 2,539 grouped-picker checks per runtime; startup and real submenu persistence for all 11 supported games with KIM1025 1.7.34; 34,965 border/gradient GPU checks including fractional scales; 34,247 final composition checks against the original frame geometry and independent Emerald glyphs; 25,768 existing font/paper-effect graphics checks. Live ROM gameplay was not exercised.

Restart the game after installing.

# Menu Customizer 3.2.25

Move the Windows Emerald-font Start selector down one pixel from 3.2.24 (now two pixels above the original anchor).

- Add 12 Pokémon-themed borders: Poké Ball, Great Ball, Ultra Ball, Master Ball, Pikachu, Charizard, Squirtle, Bulbasaur, Gengar, Umbreon, Eevee and Mew. Choose them under Menus → Border. Crisp 8px tile motifs work in menus and battle panels with any selected background.
- Rename all 47 existing non-default borders with short colour/pattern labels. Rename the 170 town/border colour swatches to readable colour names. Numbers distinguish similar shades. All saved colour values and border selections retain their original IDs and artwork.
- Default border lookup uses asset paths, independent of display names. Preserve iOS, native-font and Gen 3 selector placement.

Validation: Lua 5.3/LuaJIT regression suites; startup and settings integration for 11 games with KIM1025 1.7.34; 34,365 real GPU border/paper/default-frame checks; byte comparison of all existing border artwork and saved colour RGB values against 3.2.24. Previewed the new frames on black backgrounds.

Restart the game to load the update.

# Menu Customizer 3.2.24

Move the Windows Gen 1/2 Start-menu selector up three logical pixels when using the Emerald font, aligning it with the menu labels. All four selector styles use the corrected anchor at every menu scale.

Preserve the existing iOS placement, native-font placement, options-menu selectors and Gen 3 layouts. The text effects and vanilla HP rendering from 3.2.23 are unchanged.

Validation: Lua 5.3 and LuaJIT regression suites, including 2,480 GB/GBC layout and selector checks across platforms, font styles, menu contexts and scales. Restart the game after installing.

# Menu Customizer 3.2.23

Add five-colour text alternation, animated colours, glow and double shadows, and improve dialogue and battle text styling.

- Menus → Menu Text Effects, and Menus → Battle UI → Battle Text Effects / Name Text Effects: choose alternation Off, By Letter or By Word; cycle two to five independently chosen colours. Each group has its own Glow Color, Double Shadow and Color Speed (25–200%). None disables either extra layer.
- Layer order is double shadow, down-left shadow, up-right glow, foreground. Existing main shadow selectors remain independent. Effects are draw-only and preserve input, typewriter timing and saves.
- RGB, Rotating and Animated Gradient are available in every text, name, shadow, glow, double-shadow and background chooser, including the separate Start background. Battle background animation uses Battle Text Effects' Color Speed; menu and Start backgrounds use Menu Text Effects' Color Speed.
- Add 155 RGB swatches sampled directly from every packaged border, plus 15 conventional town-colour swatches including Viridian, Pewter, Cerulean, Vermilion, Lavender, Celadon, Saffron, Fuchsia, Cinnabar and Indigo. Choosers cycle neutrals, then reds through the rainbow, then animated modes. Existing stored numeric selections retain their meaning.
- Increase GB/GBC field and pre/post-battle dialogue from the compact half-size face to 75%, with matching pagination and a baseline that clears the border. Gen 3 field/pre/post-battle dialogue uses the selected font and styling scope too.
- Compensate text glyphs for nonuniform transforms, including the final menu canvas blit, to keep their proportions across window shapes. Preserve frame placement and sprite positioning.
- HP labels and numbers retain their vanilla font and appearance, along with native level digits and status icons. PP follows the chosen battle text font, colours and effects, including at low PP. Pokémon name styling stays independent.

Validation: Lua 5.3 and LuaJIT suites including 842 new effect/palette/layer/aspect/persistence checks; startup and settings integration for 11 games with KIM1025 1.7.34; 25,768 GPU checks using actual Emerald font masks, cached RS artwork, animated paper and font samples; 86 composed Gen 1 battle rendering checks. Live ROM gameplay was not exercised.

Restart the game after installing. KIM1025 1.7.34 remains compatible and does not need a new release for this update.

## Previous release notes

# Menu Customizer 3.2.22

Add menu backgrounds, expanded colour palettes and retro/Pokémon transitions; remove Emerald's duplicate panel layout.

- Menus → Menu Background customizes menu paper. Menus → Start → Start Background has its own chooser, defaulting to Use Menu. Default retains original menu paper; explicit White and all other shades are available.
- Expand all text, name, shadow and background colour palettes without changing existing saved colour indices. New shades include Light Blue, Sky Blue, Cyan, Teal, Light Green, Mint, Lime, Forest, Yellow, Gold, Orange, Peach, Pink, Rose, Lavender, Indigo, Silver and Brown.
- Add Retro Pop, CRT Power, Link Cable, Pokeball Iris, Tile Wipe and Psychic Swirl alongside Instant, Fade and Slide/Fade. Transitions are brief, draw-only, and settle at the exact original layout. Changing the transition previews it again.
- Emerald's battle UI uses one owner for its dialogue, command/prompt and move/PP panels, avoiding native baked chrome beneath the replacement. Preserve panel geometry, fonts and colours.

Install KIM1025 1.7.34 alongside this release to suppress its extra full-width battle backing when Menu Customizer owns the panels. Restart after updating both.

Validation: actual RS menu paper and readable white-on-black rendering, independent Start/menu background persistence across 11 games, old palette-index compatibility, all nine transition endpoints pixel-identical with visible mid-animation effects, split Emerald panel ownership, Lua 5.3/LuaJIT regressions and 86 composed rendering checks. Live ROM gameplay was not exercised.

## Previous release notes

# Menu Customizer 3.2.21

Add independent battle Pokémon name colours.

- Menus → Battle UI → Pokemon Name Color selects Black, Charcoal, Blue, Green, Red, Purple or White independently of dialogue and command colours. Black is the default.
- Pokemon Name Shadow independently selects the existing shadow palette, including None (default).
- Apply to player and enemy names across Gen 1–3, including the native Ruby/Sapphire healthbox font and the Emerald presentation. Preserve fonts, size, clipping and placement.
- Keep level numbers, HP text, gender symbols, status text and Safari counters on their existing rendering paths. Numeric nicknames do not recolour an identical level number.

Restart after updating. Keep KIM1025 1.7.33 installed.

Validation: actual GB name routing and scope restoration, private Emerald healthbox routing, native Ruby/Sapphire name pixel checks with numeric nicknames and unchanged level/HP pixels, independent persistence across 11 games, Lua 5.3/LuaJIT suites and 86 composed rendering checks. Live ROM gameplay was not exercised.

## Previous release notes

# Menu Customizer 3.2.20

Add independent text shadow colours and let battle backgrounds reach the actual frame.

- Menus → Menu Text Shadow and Menus → Battle UI → Battle Text Shadow offer None, Black, Charcoal, Grey, Light Grey, Blue, Green, Red, Purple and White. None is the default, removing the old automatic grey shadow.
- Apply the choices to native and Emerald menu fonts, dialogue, battle commands and moves. Keep foreground colours independent and persist each shadow choice.
- Remove the white and pale-grey paper connected to the interior of the selected battle border. Composite the selected background through those pixels while preserving coloured frame pixels and disconnected outer highlights. Ordinary menu border atlases stay intact.
- Keep existing frame geometry, positioning, opacity and background choices.

Restart after updating. Keep KIM1025 1.7.33 installed.

Validation: real native and Emerald glyph shadow pixel checks, None removes shadow pixels, actual battle dialogue and RS printer checks, interior-rim removal with coloured-border preservation, connected-paper/disconnected-highlight checks, separate chooser persistence in all 11 games, Lua 5.3/LuaJIT regression suites, 86 composed rendering checks. Live ROM gameplay was not exercised.

## Previous release notes

# Menu Customizer 3.2.19

Apply battle text colours to dialogue, add independent menu text colours and selectable battle box backgrounds.

- Battle Text Color now reaches the separate dialogue rendering pass and native glyph printers, including Ruby/Sapphire. Retain reveal timing, native glyph metrics, message controls and healthbox colours.
- Menus → Menu Text Color independently selects Black, Charcoal, Blue, Green, Red, Purple or White for menu text and field dialogue. Support both native and Emerald menu fonts.
- Menus → Battle UI → Battle Background offers White (default), Black, Charcoal, Navy, Cream, Pale Blue, Pale Green or Plum. Preserve the selected border artwork, pane geometry and opacity.
- Choose White battle text with Black, Navy or Plum backgrounds for high contrast. Text and background choices are independent and persist across restarts.

Keep KIM1025 1.7.33 installed and restart after updating.

Validation: actual dialogue function and production hook pixel checks, actual Ruby native glyph printer, black box/white text rendering, pixel-for-pixel border preservation, separate menu/battle colours, all chooser persistence/wrapping, Lua 5.3 and LuaJIT regression suites, 86 composed rendering checks and startup/configuration runs across 11 games. Live ROM gameplay was not exercised.

## Previous release notes

# Menu Customizer 3.2.18

Fix Ruby/Sapphire selector colours, Options side bars and clipped battle names.

- Use fixed true-colour Pokeball selector pixels instead of Ruby/Sapphire's mutable primary-colour font palette; restore shader state after drawing.
- Route Ruby/Sapphire to their actual RS Options module, including reloads and a fallback for older engines. Replay it on a transparent canvas and suspend inherited palette shaders for composition.
- Preserve explicit native indexed font requests, so the original RS healthbox text fits its eight-pixel strips. Other menus retain the selected font.
- Keep existing borders, Gen 1/2 rendering and other Gen 3 option routing.

Restart after updating. Use KIM1025 1.7.32 for fullscreen HD backgrounds and native RS KIM settings integration.

Validation: real Ruby/Sapphire cached font pixel comparisons; actual RS Options rendering with transparent side regions; selector colours under a hostile inherited shader; native settings routing/persistence checks; eleven-game startup checks and Lua 5.3/LuaJIT regressions. These are renderer tests; live ROM gameplay was not exercised.

## 3.2.18

Add BATTLE TEXT COLOR to the Battle UI submenu, defaulting to black.

- Seven choices: Black, Charcoal, Blue, Green, Red, Purple and White. Persist the choice across restarts.
- Prevent Ruby/Sapphire dialogue palette and font control codes from overriding the selected battle text colour. Preserve message timing, native healthbox fonts and other UI palettes.
- Apply the selected palette to the Emerald battle presentation in Gen 1–3, keeping existing border and move layouts.

Install KIM1025 1.7.33 alongside this update for extended Gen 3 battle backgrounds and trainer alignment. Restart the game after updating.

Validation: Lua 5.3/LuaJIT regression suites, colour persistence and error restoration, 22 startup/configuration runs across 11 games, 86 composed GPU checks and 144 Ruby/Sapphire/background/trainer GPU checks using actual cached artwork. Live ROM gameplay was not exercised.
