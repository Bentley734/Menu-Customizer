# Gen 1 level-up scene regression

Runs the actual imported game data, native BattleState/StatBox/StateStack, Game
rendering, Menu Customizer, and HD Dynamic Battlefields on a real LÖVE GPU. It
uses an isolated in-memory save/options/mod cache and never writes player saves.
Requires a locally imported Red, Blue, or Yellow cache under G1R's usual save
directory, G1R 0.3.95, and both updated mod sources.

Set these environment variables before launching this directory with LÖVE:

- `HDB_WORKSPACE`: workspace containing `.work/hd-battlefields-latest/v0.3.95/engine`,
  or also set `LEVELUP_ENGINE` to a different unpacked engine path.
- `HDB_RUNTIME_VERSION`: `0.3.95`.
- `HDB_GAME_VERSION`: `red`, `blue`, or `yellow`.
- `HDB_PROJECT`: HD Dynamic Battlefields source directory.
- `MENU_SOURCE`: Menu Customizer source directory.
- `LEVELUP_OUT`: existing scratch directory for screenshots/results.
- `SELECTOR_FONT`: `1` or `2` to exercise the two font theme paths.
- `LEVELUP_WIDTH` / `LEVELUP_HEIGHT`: optional client size (default 1280 / 720).
- `HDB_ASSET_SOURCE`: optional artwork-bearing HDB checkout when testing a sparse
  code checkout. Only missing `assets/` reads fall back to this path.

The fixture selects the bundled grassland artwork and locks its available 16:9
art version, independent of client shape. This lets compact 480x360 rendering be
tested without installing unrelated aspect packs. `LEVELUP_ART_ASPECT` can override
that choice when the corresponding artwork is available.

Assertions cover full scene/HUD retention while the transparent native StatBox
is open; alive/fainted opponent painting; unchanged composition identity and
sampled scenery pixels; A dismissal and callback count; native party/bag screen
exclusions; and returning to the stat overlay. Eight window captures, a JSON
record, and `result.txt` are written to the scratch directory. `error.txt` is
empty on success. These focused rendering checks do not claim a gameplay
playthrough or physical Android GPU validation.
