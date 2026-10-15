local api=testLoader.exports.gen3transparency;local M=api.menuSurfaces
local game={options=testOptions,mods=testLoader,save={},writeOptions=function()end}
api.customization.write(game,{modsCustom=1,modsTheme=2,modsBackgroundColor=5,modsTextColor=4,modsJustify=3,modsTextCase=1,menuTextColor=0})
M.with('mods',function()
 assert(api.textScopes.currentScope()=='mods')
 assert(M.resolve('menuTheme')==2 and M.resolve('menuTextColor')==4)
 local child=require('src.ui.Menu').new(game,{{label='CHILD'}},{})
 if api.gbMenus then assert(child._menuCustomizerSurface=='mods','Child mod menu did not inherit profile')end
end)
assert(M.current==nil and M.resolve('menuTextColor')==nil)
local rows=M.rows(function()end);local found
for _,r in ipairs(rows)do if r.id=='wide_surface_mods'then found=r end end
assert(found and #found.children>=9,'Missing Mod Menus controls')
if api.gbMenus then
 local manager=require('src.mods.ManagerState').new(game)
 assert(manager._menuCustomizerSurface=='mods')
end
print('PASS separate Mod Menus profile, child inheritance, control rows and scope restoration')
