return function(mod)
  assert(load(assert(mod:read('lib/settings_profiles.lua')),'@menu-customizer/settings_profiles.lua'))()(mod)
  assert(load(assert(mod:read('lib/customization_live.lua'))))()(mod)
  assert(load(assert(mod:read('lib/menu_main.lua')),'@menu-customizer/menu_main.lua'))()(mod)
  mod.exports.customization.installText()
  assert(load(assert(mod:read('lib/battle_ui.lua')),'@menu-customizer/battle_ui.lua'))()(mod)
end
