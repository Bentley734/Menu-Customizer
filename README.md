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
