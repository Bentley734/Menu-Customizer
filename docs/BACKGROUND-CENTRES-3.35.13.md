# Menu Customizer 3.35.13 — Per-box background centres

Anchor animated backgrounds to the centre of each owning box/menu instead of screen coordinates or a fixed reference point. Whole-panel, tiled, thin and Gen4-style frame renderers share one complete panel area, so background pieces remain continuous. Gradient, abstract, fire, forest, black and Pokemon-pattern backgrounds follow their owner when it moves or changes size. Preserve animation speed/settings; foreground text gradients keep their existing coordinate behavior.

Also move Emerald's HP label up one logical pixel and its HP values down two, as requested. Keep healthbox dimensions and the prior name/gender/level offset.

Validation on official runtime v0.3.89: reproduced the old screen-anchoring failure against v3.35.12; Red, Gold and Emerald each pass 24 GPU translation comparisons across eight background families and three frame renderers, plus resized-centre checks. Complete generated border shaders pass strict ESSL 1.00 compilation, retaining the Android shader fix. Emerald command/move rendering verifies the final HP offsets. All LuaJIT sources compile. No physical Android device or complete gameplay playthrough was tested.

Restart after updating. Saves and options are preserved.
