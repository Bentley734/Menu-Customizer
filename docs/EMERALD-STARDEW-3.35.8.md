# Menu Customizer 3.35.8 — Stardew submenus and Emerald battle themes

Group Stardew enable, jump count, speed and height controls under STARDEW submenus in their existing text/selector categories, including All Fonts. Keep independent text scopes and every saved setting key.

Emerald's MENU BORDER battle style now applies the chosen border and background to its healthboxes as well as command/move panels. Remove native placeholder/background rectangles behind HP values so the selected panel background stays visible. Keep custom healthboxes inside the viewport and separate double-battle rows.

Draw HP and XP gauges separately from the panel: preserve native HP rounding and its minimum visible pixel, keep XP off the lower border, and add HP/XP outline/fill colour controls in the existing battle text-colour categories. The HP label uses a small font so it clears names and gauges. Native battle style remains available; these new gauge/healthbox changes are scoped to Emerald with MENU BORDER selected.

Validation on official runtime v0.3.89: rendered Emerald command/move screens, both font choices, thin/thick borders and double healthboxes; FireRed and Ruby rendering smoke checks; complete generated Stardew navigation trees; focused HP/XP empty/partial/full/minimum-HP bounds, native fallback, grouping/callback preservation, prior FR/LG sizing/dialogue and Start-centering checks. All LuaJIT sources compile. These are isolated engine/rendering checks, not a complete gameplay playthrough.

Restart after updating. Saves and settings are preserved.
