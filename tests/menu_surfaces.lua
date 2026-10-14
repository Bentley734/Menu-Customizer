local loader,opts,data=testLoader,testOptions,testData
local mod=assert(loader.exports.gen3transparency)
local M=assert(mod.menuSurfaces)
local game={data=data,options=opts,mods=loader,writeOptions=function(self)self.writes=(self.writes or 0)+1 end}
game.stack={states={},push=function(self,state)self.states[#self.states+1]=state end,top=function(self)return self.states[#self.states]end}
local rows=M.rows(function(title,children,ctx)game.stack:push{title=title,rows=children}end)
assert(#rows==3 and rows[1].label=='POKE MART'and rows[2].label=='PC MENUS'and rows[3].label=='DIALOGUE BOXES')
local function find(scope,suffix)
 for _,r in ipairs(rows[scope].children)do if r.id=='surface_'..suffix then return r end end
 error('Missing setting: '..suffix)
end
local bucket=opts.modOptions.gen3transparency
local original=bucket.menuBackgroundColor
find(1,'martBackgroundColor').step(game,1)
assert(bucket.martCustom==1 and bucket.martBackgroundColor==1)
assert(bucket.menuBackgroundColor==original,'Mart setting altered global style')
M.with('mart',function()
 assert(M.resolve('menuBackgroundColor')==1)
 assert(mod.gbMenus and mod.gbMenus.mod.options:get('menuBackgroundColor')==1 or not mod.gbMenus)
 M.with('pc',function()assert(M.resolve('menuBackgroundColor')==nil,'Mart setting leaked into PC')end)
 assert(M.current=='mart')
end)
assert(not M.current and not mod.previewScope)
assert(not pcall(M.with,'mart',function()error('intentional draw failure')end))
assert(not M.current and not mod.previewScope,'Drawing failure leaked scope')
find(2,'pcTheme').step(game,1)
assert(bucket.pcCustom==1 and bucket.pcTheme~=nil and bucket.martBackgroundColor==1)
find(3,'dialogueJustify').step(game,1)
assert(bucket.dialogueJustify==2 and bucket.pcTheme~=nil)
local organized=assert(loadfile(sourceRoot..'/lib/menu_organization.lua'))()(rows,function()end)
assert(organized[1].id=='wide_surface_mart'and organized[2].id=='wide_surface_pc'and organized[3].id=='wide_surface_dialogue')
local gen=require('src.core.GameVersion').generation()
local rootRows
if gen==3 then
 local Rom=require('src.core.game3.rom_text');Rom.at=function()return'NATIVE'end;Rom.plain=function(s)return s end
 local Rows=require('src.ui.game3.option_rows');local ctx={game=game,options=opts}
 local built=Rows.build(ctx);local grouped=Rows.group(built,function(title,children)if title=='MENUS'then rootRows=children end end)
 for _,row in ipairs(grouped)do if row.id=='group.gen3transparency_menus'then row.activate(ctx)end end
else
 local Runtime=require('src.mods.Runtime')
 local root=Runtime.call('ui.options.rows',function(_,r)return r end,game,{})
 for _,row in ipairs(root)do if row.id=='wide_menus'then row.activate(game)end end
 rootRows=game.stack:top().rows
end
assert(rootRows and rootRows[1].label=='POKE MART'and rootRows[2].label=='PC MENUS'and rootRows[3].label=='DIALOGUE BOXES','Native options navigation omitted surface pages')
local called=0
local state=M.tag({items={{onSelect=function()called=called+1;assert(M.current=='mart')end}},draw=function()assert(M.current=='mart')end},'mart')
state.items[1].onSelect();state:draw();assert(called==1)
if gen<3 then
 local shop
 if gen==1 then shop=require('src.ui.ShopMenu').new(game,{},function()end)
 else shop=require('src.ui.gen2.MartMenu').new(game,{marts={lists={{}}},text={}})end
 assert(shop._menuCustomizerSurface=='mart'and shop._menuCustomizerGroup=='other')
 local world={map={id='PokeMart'},draw=function()end};game.world=world
 game.stack.states={world,shop}
 local context=assert(mod.gbMenus.context(game),'Mart is absent from GB compositor')
 assert(context.group=='other'and M.surface(context.states)=='mart')
else
 local Shop=require('src.ui.game3.shop_menu');local PC=require('src.ui.game3.pc_menu')
 assert(Shop._menuCustomizerSurfaceDraw and PC._menuCustomizerSurfaceDraw,'Native surface drawing was not wrapped')
end
find(1,'martReset').activate(game)
M.with('mart',function()assert(M.resolve('menuBackgroundColor')==nil)end)
assert(bucket.martCustom==0 and bucket.pcCustom==1,'Reset changed another profile')
find(1,'martCustom').step(game,1);assert(bucket.martCustom==1)
find(1,'martCustom').step(game,1);assert(bucket.martCustom==0,'USE MENU toggle did not disable custom styling')
local profiles=mod.settingsProfiles
profiles.switch(game)
find(1,'martBackgroundColor').step(game,1)
local document=opts.modOptions.gen3transparency._settingsProfiles
assert(document.shared.martBackgroundColor==1,'Per-game edit altered shared settings')
profiles.switch(game)
assert(opts.modOptions.gen3transparency.martBackgroundColor==1,'Shared profile did not restore surface settings')
local Runtime=require('src.mods.Runtime');local chain=Runtime.hooks.chains['ui.start_menu.items']
Runtime.hooks.chains['ui.start_menu.items']={}
M.with('mart',function()assert(M.current==nil,'Disabled mod retained a visual scope')end)
Runtime.hooks.chains['ui.start_menu.items']=chain
print('PASS independent Mart/PC/dialogue profiles, settings, callbacks, restoration and native menu integration: '..require('src.core.GameVersion').get())
