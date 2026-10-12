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
