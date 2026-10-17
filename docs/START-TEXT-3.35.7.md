# Menu Customizer 3.35.7 — Start alignment and accented text effects

Center Start labels using their actual integer-scaled pixel width, including fractional window fits. Keep each selected label's letter spacing on that same pixel grid.

Fix native text effects treating valid accented UTF-8 as cartridge control bytes. Pokémon, Pokédex and Pokégear now use per-letter effects, including Stardew. Preserve the fallback for native control strings and malformed encoded text.

Validation: real Start-menu presentation in Emerald (Native and Emerald fonts), Ruby and FireRed on official runtime v0.3.89; accented-label per-letter GPU checks, raw/control fallback, and centered-label assertions at four integer/fractional window fits. Animation snapshots cover active motion and return to baseline. All LuaJIT sources compile. No complete gameplay playthrough was performed.

Restart after updating. Panel sizes, saves and options are preserved.
