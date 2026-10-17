# Menu Customizer 3.35.10 — Android border shader fix

Fix Android's `borderRepeat: no matching overloaded function found` shader compilation error. Ten animated-border expressions passed integer literals to a function declared with a float parameter. Use explicit float literals, preserving the animation values while satisfying strict GLSL ES overload rules.

This is shared Menu Customizer border code across generations. Hoennto's draw wrapper appears in the error stack because it calls the normal game renderer; no Hoennto code change is needed.

Validation: reproduced the reported borderRepeat error by compiling the complete generated shader as ESSL 1.00 with Khronos glslang 16.6.0. The corrected complete shader passes the same strict compilation. Actual border compilation/drawing passes under the official v0.3.89 desktop runtime with Red, Gold and Emerald; each captured shader also passes ESSL 1.00. No physical Android device test was performed.

Update Menu Customizer and restart the game. Saves, settings and Hoennto are preserved.
