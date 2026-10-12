package.path='./?.lua;./?/init.lua;'..package.path
love=require('tests.love_stub')
local GV=require('src.core.GameVersion'); GV.set(arg[1])
if arg[2]=='cached' then
  require('src.import.CacheFs').readAt=function(path)
    if path:match('/manifest.lua$') then return 'return {textboxW=256,textboxH=512}' end
    if path:match('/textbox.rgba$') then return string.rep('\0',256*512*4) end
    if path:match('/healthbox_player.rgba$') then return string.rep('\0',128*64*4) end
    if path:match('/healthbox_enemy.rgba$') then return string.rep('\0',128*32*4) end
  end
end
local fs={}
function fs.getInfo(p)
  if p=='mods' or p=='mods/menu' or p=='mods/battle' or p=='mods/kim' then return {type='directory'} end
  if files[p] then return {type='file'} end
end
function fs.getDirectoryItems(p) if p=='mods' then return arg[3]=='legacy' and {'kim','menu','battle'} or {'kim','menu'} end; return {} end
function fs.read(p) return files[p] end
function fs.write(p,v) files[p]=v; return true end
function fs.createDirectory() return true end
function fs.load(p) return (loadstring or load)(files[p] or '') end
local Loader=require('src.mods.Loader')
local loader=Loader.new({fs=fs,generation=GV.generation(),version=arg[1],dev=false})
local opts={modOptions={battleuicustomizer={style=2,opacity=30,menu_stretch=1,menu_align=1}}}
require('src.core.SaveData').loadOptions=function()return opts end
local data={pokemon={},moves={},items={},maps={},tilesets={}}
loader:load(data)
assert(loader.mods.gen3transparency.state=='loaded',table.concat(loader.errors,'\n'))
assert(loader.mods.kim1025.state=='loaded',table.concat(loader.errors,'\n'))
print('PASS sandbox boot with KIM1025: '..arg[1])
local Runtime=require('src.mods.Runtime')
local game={data=data,options=opts,mods=loader,writeOptions=function(self) self.writes=(self.writes or 0)+1 end}
local rows=Runtime.call('ui.options.rows',function(_,r) return r end,game,{})
local E=assert(loader.exports.gen3transparency.battleUi)
assert(E.setting('style',1)==2 and E.setting('opacity',100)==30,'legacy settings migrated')
assert(E.setting('menu_stretch',0)==1 and E.setting('menu_align',2)==1,'placement migrated')
for _,entry in ipairs(Runtime.hooks.chains['ui.options.rows'] or {})do assert(entry.owner~='battleuicustomizer','legacy renderer inert')end
assert(loader.exports.gen3transparency.borders and loader.exports.gen3transparency.effects or GV.generation()~=3)
local controls=E.rows({});assert(#controls==5)
assert(controls[5].value()=='BLACK','default battle colour')
controls[5].step(game,1);assert(controls[5].value()=='CHARCOAL','colour step')
assert(game.options.modOptions.gen3transparency.battle_text_color==1,'colour persisted')
local style,opacity,stretch,align=unpack(controls)
assert(style.value()=='EMERALD')
style.step(game,1);assert(style.value()=='MENU BORDER')
style.step(game,1);assert(style.value()=='VANILLA')
style.step(game,-1);assert(style.value()=='MENU BORDER')
assert(game.options.modOptions.gen3transparency.battle_style==3)
assert(game.options.modOptions.battleuicustomizer.style==2,'legacy options untouched')
assert(game.options.modOptions.gen3transparency.battle_opacity==30,'other battle settings preserved')
opacity.step(game,1);assert(opacity.value()=='40%')
local ok=pcall(E.faded,function()error('probe')end);assert(not ok,'compositor propagates error')
-- Exercise the actual nested Menu Customizer settings page.
if GV.generation()~=3 then
 game.stack={states={},push=function(self,p)self.states[#self.states+1]=p end,top=function(self)return self.states[#self.states]end,pop=function(self)table.remove(self.states)end}
 local menus
 for _,r in ipairs(rows)do if r.id=='wide_menus' then menus=r end end
 assert(menus);menus.activate(game)
 local parent=game.stack:top();local battleRow
 for _,r in ipairs(parent.rows)do if r.label=='BATTLE UI' then battleRow=r end end
 assert(battleRow);battleRow.activate(game)
 assert(game.stack:top().title=='BATTLE UI' and #game.stack:top().rows==5)
else
 local RomText=require('src.core.game3.rom_text');RomText.at=function(n,i)return n..i end
 local Rows=require('src.ui.game3.option_rows')
 local built=Rows.build({game=game,options=game.options})
 local title,page
 local grouped=Rows.group(built,function(t,p)title,page=t,p end)
 local menus
 for _,r in ipairs(grouped)do if r.label=='MENUS' then menus=r end end
 assert(menus,'menus group exists');menus.activate({game=game})
 local battleRow
 for _,r in ipairs(page)do if r.id=='wide_battle_ui' then battleRow=r end end
 assert(battleRow,'battle submenu inside menus');battleRow.activate()
 assert(title=='BATTLE UI' and #page==5)
end
-- Border style is live; a changed atlas is used on the next draw.
local borders=loader.exports.gen3transparency.borders
local img={setFilter=function()end,getDimensions=function()return 24,24 end}
local selections={}
borders.atlas=function(n)selections[#selections+1]=n;return {image=img,quads={}}end
E.panel(0,96,160,48,false);assert(#selections==1,'custom selected border')
style.step(game,-1);E.panel(0,96,160,48,false);assert(#selections==1,'Emerald stays independent')
if GV.generation()==3 then
 local C=require('src.ui.game3.battle_chrome');style.step(game,1)
 C.drawPanel('menu');C.drawPanel('moves');C.drawPanel('message')
 assert(#selections>=5,'commands moves and messages use selected border')
end
assert(#loader.errors==0,table.concat(loader.errors,'\n'))
print('PASS merged settings, migration, nested page, styles, single owner: '..arg[1]..'/'..arg[3])


