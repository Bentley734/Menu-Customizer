local root=assert(os.getenv('MENU_WORKSPACE')):gsub('\\','/')
local version=os.getenv('MENU_GAME')or'firered'
local out=root..'/.work/battle-font-layout/gpu'
local source=os.getenv('MENU_SOURCE')or root..'/MenuCustomizer'
local engine=root..'/.work/moves-abilities/engine-0385'
local cache=assert(os.getenv('APPDATA')):gsub('\\','/')..'/pokemon-love2d'
local function read(p)local f=io.open(p,'rb');if not f then return end;local s=f:read('*a');f:close();return s end
local function write(p,s)local f=assert(io.open(out..'/'..p,'wb'));f:write(s);f:close()end
function love.load()
 local ok,err=xpcall(function()
  package.path=engine..'/?.lua;'..package.path
  local readFs,infoFs,loadFs=love.filesystem.read,love.filesystem.getInfo,love.filesystem.load
  local function host(p)if p:find('mods/menu/',1,true)==1 then return source..'/'..p:sub(11)end;return cache..'/'..version..'/'..p end
  love.filesystem.read=function(p,...)return read(host(p))or readFs(p,...)end
  love.filesystem.getInfo=function(p,...)local b=read(host(p));if b then return{type='file',size=#b}end;return infoFs(p,...)end
  love.filesystem.load=function(p,...)local b=read(host(p));if b then return loadstring(b,'@'..p)end;return loadFs(p,...)end
  local image=love.graphics.newImage
  love.graphics.newImage=function(p,...)if type(p)=='string'then local b=read(host(p));if b then p=love.filesystem.newFileData(b,p)end end;return image(p,...)end
  local GV=require('src.core.GameVersion');GV.set(version)
  local Blob=require('src.import.CacheBlob')
  local function cached(p)return Blob.decode(p,read(cache..'/'..version..'/'..p))end
  package.loaded['src.import.CacheFs']={loadActive=function(p)local b=cached(p);if b then return assert(loadstring(b))()end end,readActive=cached,read=cached,readAt=function(p)return cached(p)or Blob.decode(p,read(cache..'/'..p))end}
  local data=require('src.core.Data');data:load();if GV.generation()<3 then require('src.render.Font').load(data)end
  if GV.generation()==3 then
   local cv={read=function(_,p)return cached(p)end};require('src.core.game3.dataset').cache=function()return cv end
   local P=require('src.core.game3.pokemon');P.install(cv);require('src.core.game3.battle.moves').loadRomPack(cv)
  end
  local fs={}
  function fs.getInfo(p)if p=='mods'or p=='mods/menu'then return{type='directory'}end;if read(source..'/'..p:gsub('^mods/menu/',''))then return{type='file'}end end
  function fs.getDirectoryItems(p)if p=='mods'then return{'menu'}end;return{}end
  function fs.read(p)return read(source..'/'..p:gsub('^mods/menu/',''))end
  function fs.write()return true end;function fs.createDirectory()return true end
  function fs.load(p)return loadstring(fs.read(p))end
  local options={modOptions={gen3transparency={menuTheme=tonumber(os.getenv('MENU_FONT_THEME'))or 2,menuTransition=1,controlsLegend=3,opacityFormat=2,
   battle_style=3,battle_opacity=75,battle_background_color=5,battle_text_color=0,battle_font_size=0,battleBorderChoice=13,martCustom=1,martTheme=2,martBorderChoice=13,martBackgroundColor=10,martTextColor=0,martTextShadowColor=0,
   pcCustom=1,pcTheme=2,pcBorderChoice=13,pcBackgroundColor=6,pcTextColor=0,pcTextShadowColor=0,
   dialogueTheme=2,dialogueBorderChoice=13,dialogueBorder=1,dialogueBackgroundColor=10,dialogueTextColor=0}}}
  require('src.core.SaveData').loadOptions=function()return options end
  local Loader=require('src.mods.Loader');local loader=Loader.new{fs=fs,generation=GV.generation(),version=version,dev=false};loader:load(data)
  assert(loader.mods.gen3transparency.state=='loaded',table.concat(loader.errors,'\n'))
  local api=loader.exports.gen3transparency;local M=api.menuSurfaces
  local G=love.graphics;local game={data=data,options=options,mods=loader,save={money=9000,player={money=9000},inventory={},bagOrder={}},writeOptions=function()end}
  game.stack={states={},push=function(self,s)self.states[#self.states+1]=s end,pop=function(self)return table.remove(self.states)end,top=function(self)return self.states[#self.states]end}
  local function capture(name,fn)
   local canvas=G.newCanvas(1728,1296);G.setCanvas(canvas);G.origin();G.clear(.15,.2,.25,1)
   G.push('all');G.translate(0,0);G.scale(GV.generation()<3 and 4 or 3.5)
   fn();G.pop();loader.hooks:call('render.hud',function()end,game,{width=1728,height=1296,dpiX=1,dpiY=1});G.setCanvas();write(version..'-'..name..'.png',canvas:newImageData():encode('png'):getString())
  end
  local battle={activeMon=function()return{name='SQUIRTLE'}end,phase='menu',menuIndex=2,moveIndex=2,player={name='SQUIRTLE',curMoves={{id='tackle',pp=25},{id='tailwhip',pp=30},{id='watergun',pp=25},{id='withdraw',pp=40}}},data={moves={tackle={name='TACKLE',pp=35,type='NORMAL'},tailwhip={name='TAIL WHIP',pp=30,type='NORMAL'},watergun={name='WATER GUN',pp=25,type='WATER'},withdraw={name='WITHDRAW',pp=40,type='WATER'}}}}
  local rect={x=160,y=880,w=1408,h=416}
  for size=0,2 do
   options.modOptions.gen3transparency.battle_font_size=size
   battle.phase='menu'
   capture('commands-size'..size,function()api.battleUi.drawBottom(battle,rect,{dpiX=1,dpiY=1})end)
   battle.phase='moveSelect'
   capture('moves-size'..size,function()api.battleUi.moveScreen.draw(battle,rect,{dpiX=1,dpiY=1})end)
  end
  local old={maxHp=100,atk=100,def=90,spa=88,spd=87,spe=120}
  local new={maxHp=103,atk=102,def=93,spa=89,spd=90,spe=122}
  if GV.generation()==3 then
   local Growth=require('src.ui.game3.stat_growth');local calls=0
   Growth.open({},old,new,function()calls=calls+1 end)
   for size=0,2 do options.modOptions.gen3transparency.battle_font_size=size;capture('stats-size'..size,Growth.draw);assert(Growth._page==1 and calls==0)end
   Growth.handleInput({wasPressed=function(_,key)return key=='a'end});assert(Growth._page==2 and calls==0)
   capture('stats-totals',Growth.draw);Growth.handleInput({wasPressed=function(_,key)return key=='a'end});assert(not Growth.isOpen()and calls==1)
  else
   local stats={attack=123,defense=234,speed=345,special=456,specialAttack=567,specialDefense=678}
   local draw
   if GV.generation()==1 then
    local Box=require('src.battle.BattleState').StatBox;local box=Box.new(game,{stats=stats});draw=function()box:draw()end
   else
    local B=require('src.ui.gen2.BattleState');draw=function()B.drawStatsBox({game={data={pokemon={}}}},{stats=stats})end
   end
   for size=0,2 do options.modOptions.gen3transparency.battle_font_size=size;capture('stats-size'..size,draw)end
   assert(stats.attack==123 and stats.specialDefense==678)
  end
  assert(not M.current and not api.previewScope,'surface scope leaked')
  write(version..'-result.txt','PASS native level-up panels, battle styles and font sizes, real values, page advancement and callback count\n')
 end,debug.traceback)
 if not ok then write(version..'-result.txt','FAIL '..tostring(err))end
 love.event.quit(ok and 0 or 1)
end
