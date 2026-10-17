# Menu Customizer 3.35.6 — Restore the second dialogue line

Fix field dialogue stopping after its first line when using the Emerald font. The deferred printer treated the font renderer's pixel-width return value as a character count, exhausting the typewriter budget before the second line. Count text tokens and newline separators independently of the renderer. Preserve the current panel dimensions, font size and integer scaling.

Validation: reproduced the starter-choice prompt with the actual finite reveal count, then verified both lines in FireRed and LeafGreen using Native/Emerald fonts and Normal/Small text sizes, including portrait rendering on official runtime v0.3.89. Focused checks cover partial typing, newline boundaries and fully revealed pages with both renderer return conventions. All LuaJIT sources compile. No complete gameplay playthrough was performed.

Restart after updating. Saves and options are preserved.
