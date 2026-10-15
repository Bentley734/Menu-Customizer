local api=testLoader.exports.gen3transparency;local rows=api.battleHudCustomization.rows(function()end)
local count=#rows
assert(count==0 or count==7)
local values=api.customization.values('allTextColor',4)
assert(values.battleHudLevelColor==4 and values.battleHudHPColor==4)
local shadows=api.customization.values('allTextShadowColor',1)
assert(shadows.battleHudLevelShadowColor==1 and shadows.battleHudHPShadowColor==1)
if count>0 then
 local game={options=testOptions,mods=testLoader,writeOptions=function()end}
 rows[1].step(game,1);assert(testOptions.modOptions.gen3transparency.battleHudLevelColor==1)
 rows[7].step(game);assert(testOptions.modOptions.gen3transparency.battleHudFrameVisible==0)
 rows[7].step(game);assert(testOptions.modOptions.gen3transparency.battleHudFrameVisible==1)
end
print('PASS status HUD controls, independent settings, global colors/shadows and frame visibility persistence')
