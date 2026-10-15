local api=testLoader.exports.gen3transparency
local game={options=testOptions,mods=testLoader,writeOptions=function()end}
local C=api.customization;local M=api.moveSelectProfile
C.write(game,{moveSelectCustom=1,moveSelectTextColor=4,moveSelectLayout=1,moveSelectOpacity=65,battle_text_color=0,battle_move_layout=0})
local mod=api.gbMenus and api.gbMenus.mod
if mod then
 assert(mod.options:get('battle_text_color')==0)
 M.with(function()assert(mod.options:get('battle_text_color')==4 and mod.options:get('battle_move_layout')==1 and mod.options:get('battle_opacity')==65)end)
 assert(mod.options:get('battle_move_layout')==0 and not M.active)
end
local rows=M.rows(function()end);local style
for _,row in ipairs(rows)do if row.id=='wide_moveSelectCustom'then style=row end end
assert(style);style.step(game,1)
assert(testOptions.modOptions.gen3transparency.moveSelectCustom==0,'Cannot return to inherited style')
print('PASS move-select profile isolation, layout/opacity overrides and inherited style reset')
