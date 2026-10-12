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
