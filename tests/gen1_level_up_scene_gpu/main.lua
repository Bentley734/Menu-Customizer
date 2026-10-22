local workspace=assert(os.getenv('HDB_WORKSPACE')):gsub('\\','/')
local project=assert(os.getenv('HDB_PROJECT'),'Set HDB_PROJECT to the HD Dynamic Battlefields source'):gsub('\\','/')
local menuSource=assert(os.getenv('MENU_SOURCE'),'Set MENU_SOURCE to the Menu Customizer source'):gsub('\\','/')
local runtimeVersion=os.getenv('HDB_RUNTIME_VERSION')or'0.3.95'
local gameVersion=os.getenv('HDB_GAME_VERSION')or'red'
assert(gameVersion=='red'or gameVersion=='blue'or gameVersion=='yellow','Unsupported fixture game')
local engine=os.getenv('LEVELUP_ENGINE')or(workspace..'/.work/hd-battlefields-latest/v'..runtimeVersion..'/engine')
local output=assert(os.getenv('LEVELUP_OUT'),'Set LEVELUP_OUT to an existing scratch directory')

local function write(name,bytes)local f=assert(io.open(output..'/'..name,'wb'));f:write(bytes);f:close()end
function love.load()
 write("error.txt","")
 local ok,err=xpcall(function()
 package.path=engine..'/?.lua;'..package.path
 assert(require('src.core.Version').engine==runtimeVersion)
 local cache=assert(os.getenv('APPDATA')):gsub('\\','/')..'/pokemon-love2d/'..gameVersion..'/'
 local function hostRead(path)
  local f=io.open(cache..path,'rb');if not f then return end
  local bytes=f:read('*a');f:close();return bytes
 end
 local fs=love.filesystem;local G=love.graphics
 G.setDefaultFilter('nearest','nearest')
 love.math.setRandomSeed(12345)
 local oldRead,oldInfo,oldLoad=fs.read,fs.getInfo,fs.load
 local oldImage,oldPixels=G.newImage,love.image.newImageData
 fs.read=function(p,...)return hostRead(p)or oldRead(p,...)end
 fs.getInfo=function(p,...)local b=hostRead(p);if b then return{type='file',size=#b}end;return oldInfo(p,...)end
 fs.load=function(p,...)local b=hostRead(p);if b then return loadstring(b,'@'..p)end;return oldLoad(p,...)end
 G.newImage=function(p,...)if type(p)=='string'then local b=hostRead(p);if b then p=fs.newFileData(b,p)end end;return oldImage(p,...)end
 love.image.newImageData=function(p,...)if type(p)=='string'then local b=hostRead(p);if b then p=fs.newFileData(b,p)end end;return oldPixels(p,...)end
 require('src.core.GameVersion').set(gameVersion)
 local Blob=require('src.import.CacheBlob')
 local function cached(p)return Blob.decode(p,hostRead(p))end
 package.loaded['src.import.CacheFs']={loadActive=function(p)local b=cached(p);if b then return assert(loadstring(b))()end end,
  readActive=cached,read=cached,readAt=function(p)return cached(p)end}
 local data=require('src.core.Data');data:load();require('src.render.Font').load(data)
 local Pokemon=require('src.pokemon.Pokemon')
 local game={data=data,save={player={name='PROBE',id=1},inventory={badges={}},party={Pokemon.new(data,'CHARMANDER',10)},options={battleLayout='classic'},pokedex={seen={},owned={}}}}
 local Stack=require('src.core.StateStack');game.stack=setmetatable({states={}},{__index=Stack})
 local Battle=require('src.battle.BattleState')
 local battle=Battle.newWild(game,'BULBASAUR',7);game.battle=battle
 battle.phase='messages';battle.introSlide=0;battle.introBalls=false;battle.current={};battle.shown={require('src.render.Font').encode('CHARMANDER grew'),require('src.render.Font').encode('to level 10!')};game.stack.states={battle}
 local Json=require('src.link.Json')
 local SaveData=require('src.core.SaveData')
 local options=SaveData.defaultOptions()
 options.mods={['hd-dynamic-battlefields']=true}
 options.mods.gen3transparency=true
 options.modOptions={['hd-dynamic-battlefields']={enabled=true,aspect=os.getenv('LEVELUP_ART_ASPECT')or'16:9',environment='grassland',selection='fixed',timeMode='day',weatherMode='clear',animation='off'}}
 options.modOptions.gen3transparency={menuTheme=tonumber(os.getenv('SELECTOR_FONT'))or 2,battle_style=3,battleBorderChoice=13,battle_background_color=5,battle_opacity=75,arrowSelector=tonumber(os.getenv('SELECTOR_STYLE'))or 2,battleCommandsSelector=tonumber(os.getenv('SELECTOR_STYLE'))or 2,performanceMode=1}
 local originalOptions=SaveData.loadOptions;SaveData.loadOptions=function()return options end
 local prefix='mods/hd-dynamic-battlefields/'
 local disk={}
 local function source(p)
  local file
  if p:sub(1,#prefix)==prefix then file=project..'/'..p:sub(#prefix+1)
  elseif p:match('^mods/gen3transparency/') then file=menuSource..'/'..p:match('^mods/gen3transparency/(.+)$')end
  if not file then return end
  local f=io.open(file,'rb');if not f and p:match('^mods/hd%-dynamic%-battlefields/assets/')then f=io.open((os.getenv('HDB_ASSET_SOURCE')or(workspace..'/HD-Dynamic-Battlefields'))..'/'..p:sub(#prefix+1),'rb')end;if not f then return end
  local b=f:read('*a');f:close();return b
 end
 local fs={}
 function fs.read(p)return disk[p]or source(p)end
 function fs.write(p,b)disk[p]=b;return true end
 function fs.getInfo(p)
  if p=='mods'or p=='mods/hd-dynamic-battlefields'or p=='mods/gen3transparency'then return{type='directory'}end
  local b=fs.read(p);if b then return{type='file',size=#b}end
 end
 function fs.getDirectoryItems(p)if p=='mods'then return {'hd-dynamic-battlefields','gen3transparency'}end;return{}end
 function fs.load(p)return assert(loadstring(assert(fs.read(p)),'@'..p))end
 function fs.createDirectory()return true end
 function fs.remove(p)disk[p]=nil;return true end
 love.window.setMode(tonumber(os.getenv('LEVELUP_WIDTH'))or 1280,tonumber(os.getenv('LEVELUP_HEIGHT'))or 720,{resizable=false,vsync=0})
 local G=love.graphics;local originalImage=G.newImage
 G.newImage=function(path,...)
  if type(path)=='string'then local b=source(path);if b then path=love.filesystem.newFileData(b,path)end end
  return originalImage(path,...)
 end
 local Loader=require('src.mods.Loader')
 local loader=Loader.new{fs=fs,generation=1,version=gameVersion,dev=false};loader.game=game
 loader:load(game.data)
 assert(loader.mods['hd-dynamic-battlefields'].state=='loaded',table.concat(loader.errors,'\n'))
 game.mods=loader;game.save.version=gameVersion;game.save.meta={playthroughId='hd-probe'};game.save.player.map='ROUTE_1'
 assert(game.data.maps.ROUTE_1,'Automatic map ID is not in the actual imported map table')

 assert(loader.mods.gen3transparency.state=='loaded',table.concat(loader.errors,'\n'))


 local Game=require('src.core.Game');local Renderer=require('src.render.Renderer');Renderer:init()
 game.options=options;game.save.options=options;game.input={wasPressed=function()return false end}
 local G=love.graphics;local captures={};local records={};local active
 local nativeHud=Battle.drawHUDs;Battle.drawHUDs=function(self,...)if active then active.huds=active.huds+1 end;return nativeHud(self,...)end
 local activeBattler;local nativeDraw=G.draw
 G.draw=function(...)if active and activeBattler then local side=activeBattler.isPlayer and 'player' or 'enemy';active[side]=active[side]+1 end;return nativeDraw(...)end
 local nativePic=Battle.drawBattlerPic;Battle.drawBattlerPic=function(self,mon,...)local prior=activeBattler;activeBattler=mon;local result={nativePic(self,mon,...)};activeBattler=prior;return(unpack or table.unpack)(result)end
 local function capture(name)
  local rec={huds=0,player=0,enemy=0};active=rec
  G.setCanvas();G.origin();G.setScissor();G.clear(0,0,0,1)
  Game.draw(game);active=nil
  if name=='party'or name=='bag'then assert(loader.exports['hd-dynamic-battlefields'].battlefieldScenery.draw(0,0,G.getWidth(),G.getHeight())==false,'Child screen unexpectedly accepted HD scenery')end
  rec.diagnostics=loader.exports['hd-dynamic-battlefields'].diagnostics();records[name]=rec;write('records.json',Json.encode(records))
  local done=false
  G.captureScreenshot(function(img)write(name..'.png',img:encode('png'):getString());captures[name]=img;done=true end)
  G.present();assert(done,'No screenshot')
 end
 local function sampleSame(a,b)
  for _,point in ipairs({{.01,.03},{.03,.35},{.05,.7},{.1,.5},{.98,.98}})do
   local x,y=math.floor(a:getWidth()*point[1]),math.floor(a:getHeight()*point[2])
   local r,g,b1,alpha=a:getPixel(x,y);local rr,gg,bb,aa=b:getPixel(x,y)
   assert(math.abs(r-rr)<.0001 and math.abs(g-gg)<.0001 and math.abs(b1-bb)<.0001 and math.abs(alpha-aa)<.0001,'Battle scenery disappeared or changed beneath stats')
  end
 end
 capture('battle')
 local callbacks=0
 local box=Battle.StatBox.new(game,game.save.party[1],function()callbacks=callbacks+1 end)
 game.stack.states={battle,box}
 capture('stats')
 assert(records.stats.huds>0,'Native HUD draw suppressed while stats open')
 assert(records.stats.enemy>0,'Visible opponent disappeared while stats open')
 assert(records.stats.diagnostics.status~='native fallback','Scenery rejected transparent StatBox overlay')
 assert(records.stats.diagnostics.composition==records.battle.diagnostics.composition,'Stats changed active scenery')
 sampleSame(captures.battle,captures.stats)
 assert(game.stack:top()==box and callbacks==0,'draw consumed stats state')
 game.input.wasPressed=function(_,key)return key=='a'end
 box:update();assert(game.stack:top()==battle and callbacks==1,'A did not dismiss exactly once')
 capture('dismissed');sampleSame(captures.battle,captures.dismissed)
 battle.enemy.fainted=true;battle.enemy.shownHP=0;battle.enemy.mon.hp=0
 capture('fainted-battle')
 game.stack.states={battle,box};capture('fainted-stats')
 assert(records['fainted-stats'].enemy==0,'Native fainted opponent was forced back onto the battlefield')
 assert(battle.enemy.fainted and battle.enemy.mon.hp==0,'Stats changed fainted battle state')
 assert(records['fainted-stats'].diagnostics.status~='native fallback','Fainted stats lost HD scenery')
 sampleSame(captures['fainted-battle'],captures['fainted-stats'])
 local Party=require('src.ui.PartyMenu');local party=Party.new(game,{battle=battle})
 game.stack.states={battle,party};capture('party')
 assert(records.party.diagnostics.status=='native fallback','Opaque party screen drew HD battlefield')
 local Bag=require('src.ui.BagMenu');local bag=Bag.new(game,{battle=battle})
 game.stack.states={battle,bag};capture('bag')
 assert(records.bag.diagnostics.status=='native fallback','Bag screen drew HD battlefield')
 game.stack.states={battle,box};capture('returned-stats')
 assert(records['returned-stats'].diagnostics.status~='native fallback','HD scenery failed to return after child menu')
 write('records.json',Json.encode(records))
 write('result.txt','PASS native full Game/Renderer/StateStack: HD scene, HUDs, opponent visibility, native fainting, A dismissal, party/bag exclusions and return to stats')
 end,debug.traceback)
 if not ok then write('error.txt',err);print(err)end
 love.event.quit(ok and 0 or 1)
end
