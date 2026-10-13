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

v3.2.52
OTHER > GENERAL > SETTINGS STORAGE switches between SHARED (default) and PER GAME. Each game starts from the shared configuration; subsequent menu, border, dialogue, font, battle and transition changes stay in that game’s profile. Switching modes retains both shared and per-game configurations. Profiles are stored with mod options, independent of progress saves.

v3.2.51
Organized the main menu as START, BATTLE, OPTION, SAVE, OTHER, DIALOGUE, BORDERS, TRANSITIONS, MENU SELECTOR. Shared appearance and general controls live under OTHER. Added independent start, battle, option, save, other and dialogue borders, with USE MENU inheritance. Fixed dialogue OFF/ON cycling and native frame interception. Added independent dialogue font, font color, shadow and background controls. Choosing a battle border enables the custom border battle UI. Saved settings retain their IDs.

v3.2.50
MENU TEXT EFFECTS now groups ALTERNATE, COLOR COUNT, and COLOR 1–5 in an ALTERNATE submenu. Existing saved settings are preserved.

v3.2.49
Suppress native palette fades and embedded battle wipe layers when custom transitions are selected. Correct warp fade direction and leave Gen 3 world canvases intact. Native timing and callbacks remain unchanged; transitions still precede ShaderFX.

v3.2.48
Custom building and battle transitions now composite before recomp ShaderFX, preserving full-window coverage and DPI scaling.

Menu Customizer 3.2.47

MENU TEXT EFFECTS, BATTLE TEXT EFFECTS and NAME TEXT EFFECTS now each have HIGHLIGHT, HIGHLIGHT COLOR, OUTLINE and OUTLINE COLOR. Both effects default OFF. Highlight draws a colored backing behind letters; outline draws a one-pixel border in all eight directions. Both use the complete font-color picker, including animated gradients and rotating colors, controlled by COLOR SPEED. Text opacity and aspect scaling apply to the added effects. New effects were not tested in-game.

Menu Customizer 3.2.46

OPTION > MENUS > SCENE TRANSITIONS: separate BUILDING ENTER, BUILDING EXIT, BATTLE ENTER and BATTLE EXIT pickers. Each has VANILLA, 24 custom visual effects and RANDOM. Buildings use EXIT to cover the departing area and ENTER to reveal the destination. Covers apply to the whole game surface, including widescreen.

Fades, directional wipes, double doors, curtains, iris shapes, Pokeball closure, tile/checker wipes, blinds, Surf waves, lightning, psychic spirals, stardust, pixel rain, leaf scatter, CRT shutters, ripples and battle claws. Native map/battle callbacks and input locks remain engine-owned. Gen 1 can add the reveal phase that vanilla normally skips when BUILDING ENTER is customized. New transitions have not been tested in-game.

Menu Customizer 3.2.45

BATTLE UI > BATTLE FONT SIZE: NORMAL, LARGE (150%), EXTRA LARGE (200%). Battle text renderers share uniform physical-pixel scaling, including native and Emerald fonts, commands, dialogue, moves and HUD text. Explicit field width limits fit long labels uniformly. Text outside battle and battle sprites are unaffected. Bottom text panels grow upward in large modes to provide room for larger lines. Commands and PP/type fields use left-aligned anchors.

Menu Customizer 3.2.44

Restore the themed font printer end-position return values. TM Case entries display explicit TM/HM numbers and move names (HM01 CUT, etc.), using the current engine item-to-move lookup. Only label rendering changes; TM/HM compatibility and teaching remain untouched.

Menu Customizer 3.2.43

Pokemon backgrounds: POKEMON > BACKGROUND DESIGN > Pokemon. Repeated STARFALL, DREAM CURRENT and MOON GARDEN designs share submenus, with original paper grouped under CLASSIC PAPER.
Menu borders: choose a design family, then the Pokemon. Existing numeric selections and artwork retain their IDs.

30 additional Pokemon-inspired animated pixel-emblem backgrounds and 30 additional animated borders, using 30 previously unused Pokemon: Raichu, Sandshrew, both Nidoran, Clefairy, Vulpix, Ninetales, Zubat, Oddish, Paras, Venonat, Diglett, Psyduck, Growlithe, Poliwag, Abra, Machop, Geodude, Ponyta, Slowpoke, Magnemite, Farfetchd, Doduo, Seel, Grimer, Shellder, Krabby, Voltorb, Cubone and Lapras. Font presets remain separate.

New menu grouping and artwork were not tested, retaining the requested testing limit. Restart after updating.

Menu Customizer 3.2.42

Native options category cards use left-aligned titles and centered subtitles (OPEN, option counts, and values). Card titles no longer inherit START text justification.

Menu Customizer 3.2.41

Full 8x8 selector artwork, with no fractional or sampled shrinking. Native category cards reserve a gap and use their own small-font baseline. START placement is unchanged. Pokemon level tags render as Lv plus the complete level instead of printing LV_2.

30 new animated Pokemon backgrounds in the POKEMON background group.
30 new independently selectable animated Pokemon borders in MENU BORDER.
20 separate alternating font color presets in MENU TEXT EFFECTS / battle text effects > COLOR PRESET. Choose CUSTOM for manual colors; presets alternate by letter, or by word when ALTERNATE is set to BY WORD. Existing saved choices retain their IDs.

Only selector geometry and level rendering/measurement were tested, as requested. New artwork/presets were not tested. Restart after updating.

Menu Customizer 3.2.40

Restore 3.2.38 selector artwork, dimensions and horizontal placement. Only move non-START selectors upward: full-size OPTIONS markers retain their original 8x8 pixels, and compact markers retain their original 6x6 pixels. The confirmed START alignment is unchanged. Restart after updating.

Menu Customizer 3.2.38

OPTION > MENUS > ARROW SELECTOR replaces non-START selection arrows with a Pokeball or any of the eight icon selectors. ARROW preserves the original appearance. START SELECTOR remains independent. Compact replacements fit the native cursor column with a one-pixel gap, including narrow lists, confirmations and battle selections. Restart the game after updating.

Menu Customizer 3.2.37

Fix iOS START selector vertical alignment for Gen 1-3, including all new icon selectors. Gen 1/2 Emerald-themed START markers now use the raised text anchor; Gen 3 START no longer adds the erroneous two-pixel iOS offset. Restart the game after updating.

Menu Customizer 3.2.36

Six original psychedelic backgrounds inspired by visionary art and TOOL: VISION FIELD, SACRED LATTICE, ENERGY ANATOMY, THIRD EYE, INTERBEING and LATERAL SPIRAL.
Layered eyes, sacred geometry, flowing energy lines and spirals in subdued purple, teal and gold. Choose TRIPPY in the menu, Start menu or battle background chooser. COLOR SPEED controls motion; existing choices retain their IDs.

Testing was explicitly skipped at the user's request to conserve usage. Restart the game after updating.

Menu Customizer 3.2.36

Eight new Start menu selectors: STAR, HEART, LIGHTNING, CRESCENT, DIAMOND, FLAME, PSYCHIC EYE and SPIRAL.
Colourful pixel icons for Gen 1-3, with existing selector IDs preserved. Choose them in START SELECTOR / SELECTOR.

Testing was explicitly skipped at the user's request to conserve usage. Restart the game after updating.

Menu Customizer 3.2.36

Eight trippy animated borders: ACID RIBBONS, PLASMA BEADS, KALEIDO GEMS, MOLTEN DREAM, NEON CIRCUIT, WORMHOLE, CHECKER MELT and AURORA BRAID.
Available for menus and battle UI frames, with purple, blue, green and pastel palettes. COLOR SPEED controls motion. Existing saved border choices retain their IDs.

Testing was explicitly skipped at the user's request to conserve usage. Restart the game after updating.

Menu Customizer 3.2.36

Eight animated abstract backgrounds in the new TRIPPY background group: ACID SPIRAL, LIQUID AURORA, KALEIDO DREAM, NEON GRID, PLASMA CLOUD, LIQUID CHROME, COSMIC TUNNEL and DREAM WAVES.
Available for menu, Start menu and battle paper. COLOR SPEED controls their motion. Existing saved choices retain their IDs. Most pair with light text; pastel DREAM WAVES pairs with dark text.

Testing was explicitly skipped at the user's request to conserve usage. Restart the game after updating.

Menu Customizer 3.2.36

Twelve new menu transitions: VORTEX, ORBIT, RUBBER ZOOM, PENDULUM, SPIRAL IRIS, RIPPLE BLOOM, KALEIDOSCOPE, DIAMOND PORTAL, VENETIAN DREAM, STARDUST DISSOLVE, ZIGZAG PORTAL and CHECKER PHASE.
Spinning entrances, orbiting motion, springy zooms and patterned reveals. Existing saved transition choices keep their IDs. Zooms preserve the menu aspect ratio; effects settle into the normal menu.

Testing was explicitly skipped at the user's request to conserve usage. Restart the game after updating.

Menu Customizer 3.2.36

Three new menu transitions: POKEBALL BOUNCE (a settling bounce), SURF WAVE (a gentle sideways wave), and TELEPORT (a spinning zoom).
Existing saved transition choices keep their IDs. New zooms preserve the menu aspect ratio.

Testing was explicitly skipped at the user's request to conserve usage. Restart the game after updating.

Menu Customizer 3.2.36

Add 14 animated Pokémon background choices for menu paper, the separate Start menu background, and battle UI paper. Find them in the new POKEMON group in each background chooser. Existing saved colours, gradients and font choices keep their IDs and appearance.

- Favorites first: MEW STARDUST, MEW PSYCHIC TIDE, MEW NEBULA, CHARMANDER EMBERS and CHARMANDER CAMPFIRE.
- Also includes PIKACHU SPARKS, SQUIRTLE LAGOON, BULBASAUR GARDEN, GENGAR HAUNT, EEVEE COZY, JIGGLYPUFF LULLABY, DRAGONAIR DREAM, UMBREON MOONLIGHT and SNORLAX SNOOZE.
- Gently animated Pokémon stamps, drifting particles and matching motifs: stars, psychic ripples, tail-flame embers, lightning, bubbles, leaves, ghost eyes, paws, musical notes, moonlit ribbons, golden rings and rising Zs. Sprite artwork retains its aspect ratio and transparent padding is excluded.
- Existing COLOR SPEED controls the paper animation; menu and battle speed settings stay independent. Light themes pair with dark text; Nebula, Campfire, Haunt and Moonlight pair with light text. Text colours remain your choice.
- Self-contained bundled animation sheets reused unchanged from the existing KIM HD sprite assets. No helper, external mod, ROM font, or additional asset download is needed for these backgrounds.
- Keep the selected border separate from the paper. Preserve pixelated Gen 3 animated frames, integer menu fonts, HP/levels, battle sprite positions and the inherited/separate Start background choice.

Validation: 411,883 actual LOVE checks for all 14 distinct animations, matching-text contrast, chooser reachability/order, background scope, animation speed, physical DPI, protected border pixels and shader state. 44,284 existing border/effect graphics checks and 25,768 Ruby/Sapphire graphics checks pass, as do Lua 5.3/LuaJIT palette/font/geometry/chooser suites and all 11 game startup/settings routes with KIM1025. Real rendered previews included. Live ROM gameplay was not exercised.

Restart the game after updating. Compatible with KIM1025 1.7.35.

Menu Customizer 3.2.29

Fix missing/thinned menu letter strokes in Gen 3 with either Emerald or vanilla fonts. Draw menu text at the final window resolution using a uniform integer physical-pixel scale and a pixel-aligned origin, instead of shrinking glyphs inside the native menu canvas before enlarging them.

- Apply to Start, Options and Save menus in Ruby, Sapphire, Emerald, FireRed and LeafGreen. Preserve native measurements, text colours/effects, clipping, opacity and transitions.
- Keep menu frames, backgrounds and animated borders on their existing native-resolution surface. In particular, retain the pixelated Gen 3 animated border look.
- Restore font hooks and graphics state on failures; recreate the final surface when the window or DPI changes. Existing Gen 1/2 menu and battle renderers retain their paths, including vanilla HP/levels and KIM sprite positioning.

Validation: 2,974 actual LOVE graphics checks, including exact reference-font image comparisons across five Gen 3 games, both font modes, 80/100/150% menu size, 1047x699, 1808x1080, 2560x1299, 5120x1440 and a 3x-DPI mobile canvas. Real Emerald Options screen rendered and inspected; nine animated border variants match the previous native-canvas output byte for byte; glyph/clipping, transitions and error restoration checked. Existing Lua 5.3/LuaJIT regression suites, all 11 game startup/settings routes, and 25,768 Ruby/Sapphire graphics checks pass. Live ROM gameplay was not exercised.

Restart the game after updating. KIM1025 1.7.35 remains compatible.

Menu Customizer 3.2.28

Render Emerald Pokémon names directly at the final KIM HUD size instead of enlarging fractional pixels from the HUD capture. Repeated letters now use identical square pixel blocks.

- Both player and enemy names use one uniform integer scale and a physical-pixel-aligned origin. HUD size and high-DPI scaling determine the closest crisp font size.
- Preserve the name anchors and native level/HP rendering. Keep name colours, alternating colours, gradients, shadows, glow, double shadow and HUD opacity in the final pass.
- Unsupported scripts, the cartridge font, disabled Menu Customizer, the native Emerald healthbox style and very small HUD sizes retain their existing rendering path. The Gen 3 font aspect correction remains unchanged.
- Use KIM1025 1.7.35 for the cooperative final-window name pass. Older KIM versions continue working through the existing capture fallback.

Validation: 887,570 actual LOVE checks through KIM's production HUD capture and composition, matching native Emerald glyphs at 1047×699, 2560×1299, 5120×1440 and a 3× DPI mobile canvas, each with 60/80/100% HUD sizes; repeated T glyphs identical; HP fills/numbers unchanged; fallback and error-state restoration checked. Existing Lua 5.3/LuaJIT suites, all 11 game startup/settings routes, KIM regressions and 34,247 final battle composition checks pass. Live ROM gameplay was not exercised.

Restart after updating both mods.

Menu Customizer 3.2.27

Add animated Pokémon-inspired frames and a coordinated collection of smooth gradient colours for text and backgrounds.

- Six new animated borders: Rolling Poké Balls, Lightning, Water Ripple, Ghost Wisps, Shooting Stars, and Living Vines. They move around a continuous frame without separate tile seams.
- Nine curated gradient borders: Aurora, Amethyst Tide, Mint Lagoon, Dream Mist, Deep Space, Moonlit Forest, Cotton Candy, Sunset Dream, and Golden Hour. The existing rainbow border is now named Rainbow Flow.
- The same nine palettes are available under Animated in every text, background, shadow, glow, double-shadow, and alternating-colour chooser. Purple/blue/green combinations range from deep jewel tones to soft pastels, with pink and warm sunset alternatives.
- Remove the abrupt RGB chooser. Existing RGB selections become Aurora in place; static colours, Rotating, Animated Gradient, border IDs, and the existing colour-family submenus retain their saved meanings.
- Menu Text Effects → Color Speed controls border motion. Each text scope retains its own Color Speed for its text and background effects. Frame animations preserve the separately selected paper/background and existing frame geometry.

Validation: Lua 5.3/LuaJIT syntax and existing regressions; 11,733 smooth-gradient and saved-ID checks and 2,635 grouped-chooser checks per runtime; 44,284 actual LOVE border/palette graphics checks, including distinct effects, speed equivalence and paper isolation; 25,768 font/paper graphics checks and 34,247 KIM1025 battle composition checks. Startup/settings tested in all 11 Gen 1–3 games with KIM1025 1.7.34. Live ROM gameplay was not exercised.

Restart after installing. Open Menus → Menu Border for the frames, or open a colour chooser → Animated for the new gradients.

Menu Customizer 3.2.26

Add an animated rainbow-gradient border, group all colour choosers by base hue, and remove separate tile joins from the battle frame renderer.

- Menus → Border → Animated Gradient adds a continuously moving rainbow bevel. The interior keeps the selected menu/Start/battle background. Menu Text Effects → Color Speed controls the border's cycle speed.
- Open any colour setting, choose a family, then select a shade. Neutrals, reds, oranges, yellows, greens, cyans, blues, purples, pinks, browns and animated modes have separate pages. Default/inherited backgrounds and disabled shadows remain under Special. Standard colours appear first, followed by additional shades. The selected shade is marked.
- Covers menu text, menu/Start backgrounds, battle text/backgrounds, Pokémon names, all shadows, glow, double shadow and each of the five alternating colours. All saved colour values and border IDs retain their meanings.
- Render each frame with one quad and padded source cells, eliminating the geometry joins and neighbouring atlas samples that can form thin seams under scaling. Preserve the original frame bounds, interior, sprites and fonts; native HP remains unchanged.

Validation: Lua 5.3/LuaJIT regressions plus 2,539 grouped-picker checks per runtime; startup and real submenu persistence for all 11 supported games with KIM1025 1.7.34; 34,965 border/gradient GPU checks including fractional scales; 34,247 final composition checks against the original frame geometry and independent Emerald glyphs; 25,768 existing font/paper-effect graphics checks. Live ROM gameplay was not exercised.

Restart the game after installing.

Menu Customizer 3.2.25

Move the Windows Emerald-font Start selector down one pixel from 3.2.24 (now two pixels above the original anchor).

- Add 12 Pokémon-themed borders: Poké Ball, Great Ball, Ultra Ball, Master Ball, Pikachu, Charizard, Squirtle, Bulbasaur, Gengar, Umbreon, Eevee and Mew. Choose them under Menus → Border. Crisp 8px tile motifs work in menus and battle panels with any selected background.
- Rename all 47 existing non-default borders with short colour/pattern labels. Rename the 170 town/border colour swatches to readable colour names. Numbers distinguish similar shades. All saved colour values and border selections retain their original IDs and artwork.
- Default border lookup uses asset paths, independent of display names. Preserve iOS, native-font and Gen 3 selector placement.

Validation: Lua 5.3/LuaJIT regression suites; startup and settings integration for 11 games with KIM1025 1.7.34; 34,365 real GPU border/paper/default-frame checks; byte comparison of all existing border artwork and saved colour RGB values against 3.2.24. Previewed the new frames on black backgrounds.

Restart the game to load the update.

Menu Customizer 3.2.23
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

Menu Customizer 3.2.22
Add menu backgrounds, expanded colour palettes and retro/Pokémon transitions; remove Emerald's duplicate panel layout.

- Menus → Menu Background customizes menu paper. Menus → Start → Start Background has its own chooser, defaulting to Use Menu. Default retains original menu paper; explicit White and all other shades are available.
- Expand all text, name, shadow and background colour palettes without changing existing saved colour indices. New shades include Light Blue, Sky Blue, Cyan, Teal, Light Green, Mint, Lime, Forest, Yellow, Gold, Orange, Peach, Pink, Rose, Lavender, Indigo, Silver and Brown.
- Add Retro Pop, CRT Power, Link Cable, Pokeball Iris, Tile Wipe and Psychic Swirl alongside Instant, Fade and Slide/Fade. Transitions are brief, draw-only, and settle at the exact original layout. Changing the transition previews it again.
- Emerald's battle UI uses one owner for its dialogue, command/prompt and move/PP panels, avoiding native baked chrome beneath the replacement. Preserve panel geometry, fonts and colours.

Install KIM1025 1.7.34 alongside this release to suppress its extra full-width battle backing when Menu Customizer owns the panels. Restart after updating both.

Validation: actual RS menu paper and readable white-on-black rendering, independent Start/menu background persistence across 11 games, old palette-index compatibility, all nine transition endpoints pixel-identical with visible mid-animation effects, split Emerald panel ownership, Lua 5.3/LuaJIT regressions and 86 composed rendering checks. Live ROM gameplay was not exercised.

Menu Customizer 3.2.21
Add independent battle Pokémon name colours.

- Menus → Battle UI → Pokemon Name Color selects Black, Charcoal, Blue, Green, Red, Purple or White independently of dialogue and command colours. Black is the default.
- Pokemon Name Shadow independently selects the existing shadow palette, including None (default).
- Apply to player and enemy names across Gen 1–3, including the native Ruby/Sapphire healthbox font and the Emerald presentation. Preserve fonts, size, clipping and placement.
- Keep level numbers, HP text, gender symbols, status text and Safari counters on their existing rendering paths. Numeric nicknames do not recolour an identical level number.

Restart after updating. Keep KIM1025 1.7.33 installed.

Validation: actual GB name routing and scope restoration, private Emerald healthbox routing, native Ruby/Sapphire name pixel checks with numeric nicknames and unchanged level/HP pixels, independent persistence across 11 games, Lua 5.3/LuaJIT suites and 86 composed rendering checks. Live ROM gameplay was not exercised.

Menu Customizer 3.2.20
Add independent text shadow colours and let battle backgrounds reach the actual frame.

- Menus → Menu Text Shadow and Menus → Battle UI → Battle Text Shadow offer None, Black, Charcoal, Grey, Light Grey, Blue, Green, Red, Purple and White. None is the default, removing the old automatic grey shadow.
- Apply the choices to native and Emerald menu fonts, dialogue, battle commands and moves. Keep foreground colours independent and persist each shadow choice.
- Remove the white and pale-grey paper connected to the interior of the selected battle border. Composite the selected background through those pixels while preserving coloured frame pixels and disconnected outer highlights. Ordinary menu border atlases stay intact.
- Keep existing frame geometry, positioning, opacity and background choices.

Restart after updating. Keep KIM1025 1.7.33 installed.

Validation: real native and Emerald glyph shadow pixel checks, None removes shadow pixels, actual battle dialogue and RS printer checks, interior-rim removal with coloured-border preservation, connected-paper/disconnected-highlight checks, separate chooser persistence in all 11 games, Lua 5.3/LuaJIT regression suites, 86 composed rendering checks. Live ROM gameplay was not exercised.

Menu Customizer 3.2.19
Apply battle text colours to dialogue, add independent menu text colours and selectable battle box backgrounds.

- Battle Text Color now reaches the separate dialogue rendering pass and native glyph printers, including Ruby/Sapphire. Retain reveal timing, native glyph metrics, message controls and healthbox colours.
- Menus → Menu Text Color independently selects Black, Charcoal, Blue, Green, Red, Purple or White for menu text and field dialogue. Support both native and Emerald menu fonts.
- Menus → Battle UI → Battle Background offers White (default), Black, Charcoal, Navy, Cream, Pale Blue, Pale Green or Plum. Preserve the selected border artwork, pane geometry and opacity.
- Choose White battle text with Black, Navy or Plum backgrounds for high contrast. Text and background choices are independent and persist across restarts.

Keep KIM1025 1.7.33 installed and restart after updating.

Validation: actual dialogue function and production hook pixel checks, actual Ruby native glyph printer, black box/white text rendering, pixel-for-pixel border preservation, separate menu/battle colours, all chooser persistence/wrapping, Lua 5.3 and LuaJIT regression suites, 86 composed rendering checks and startup/configuration runs across 11 games. Live ROM gameplay was not exercised.

Menu Customizer 3.2.18
Add BATTLE TEXT COLOR to the Battle UI submenu, defaulting to black.

- Seven choices: Black, Charcoal, Blue, Green, Red, Purple and White. Persist the choice across restarts.
- Prevent Ruby/Sapphire dialogue palette and font control codes from overriding the selected battle text colour. Preserve message timing, native healthbox fonts and other UI palettes.
- Apply the selected palette to the Emerald battle presentation in Gen 1–3, keeping existing border and move layouts.

Install KIM1025 1.7.33 alongside this update for extended Gen 3 battle backgrounds and trainer alignment. Restart the game after updating.

Validation: Lua 5.3/LuaJIT regression suites, colour persistence and error restoration, 22 startup/configuration runs across 11 games, 86 composed GPU checks and 144 Ruby/Sapphire/background/trainer GPU checks using actual cached artwork. Live ROM gameplay was not exercised.

Menu Customizer 3.2.17
Fix Ruby/Sapphire selector colours, Options side bars and clipped battle names.

- Use fixed true-colour Pokeball selector pixels instead of Ruby/Sapphire's mutable primary-colour font palette; restore shader state after drawing.
- Route Ruby/Sapphire to their actual RS Options module, including reloads and a fallback for older engines. Replay it on a transparent canvas and suspend inherited palette shaders for composition.
- Preserve explicit native indexed font requests, so the original RS healthbox text fits its eight-pixel strips. Other menus retain the selected font.
- Keep existing borders, Gen 1/2 rendering and other Gen 3 option routing.

Restart after updating. Use KIM1025 1.7.32 for fullscreen HD backgrounds and native RS KIM settings integration.

Validation: real Ruby/Sapphire cached font pixel comparisons; actual RS Options rendering with transparent side regions; selector colours under a hostile inherited shader; native settings routing/persistence checks; eleven-game startup checks and Lua 5.3/LuaJIT regressions. These are renderer tests; live ROM gameplay was not exercised.

Menu Customizer 3.2.16
Emerald command prompt, larger commands, centered move grid and larger Pokemon names.

- Show What will [Pokemon] do? on the left of the full selected frame, with larger FIGHT/BAG/POKEMON/RUN commands on the right.
- Center each move name in its own quarter and fit larger original Emerald narrow glyphs to the actual space. Keep complete type names, PP values, swap cursors and square pixel scaling.
- Enlarge captured Gen 1 Pokemon names by 50 percent while keeping level digits and the LV marker in the original game font.
- Preserve selected border artwork, opacity, Gen 1/2 engine isolation and Gen 3 compatibility.

Use KIM1025 1.7.31 alongside this version for the enlarged HUD name capture. Restart after updating.

Validation: Windows LOVE composed rendering at normal, 1080p and ultrawide sizes, original Emerald normal/narrow glyph pixel comparisons, original level-font pixel comparisons, focused prompt/grid/HUD scope tests in Lua 5.3/LuaJIT, all KIM regression suites and startup checks across eleven games. Live ROM gameplay was not exercised.

Menu Customizer 3.2.15
Restore battle borders to the 3.2.11 frame geometry while using the original Emerald battle fonts.

- Keep the selected border artwork, opacity, command placement and full move-panel bounds.
- Render original Emerald normal/narrow glyphs and palettes with uniform physical pixels, independently of frame scaling.
- Fit labels, cursors, PP and complete type names inside the restored frame interiors.
- Expose a final-window battle text presenter for KIM1025, avoiding the 160px Game Boy intermediate canvas.
- Retain Gen 1/2 generation isolation and Gen 3 support.

Update KIM1025 to 1.7.29 alongside this release for crisp Gen 1 fullscreen commands, dialogue and HUD text. Restart after updating.

Validation: pixel comparisons against 3.2.11 borders and native Emerald font rendering in the composed KIM path, plus cached Gen 1/2 safety, Gen 3/offline font checks, eleven-game startup checks and Lua/LuaJIT menu/layout regressions. Live game window capture timed out; gameplay was not verified.

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
