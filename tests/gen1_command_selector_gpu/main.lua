local workspace=assert(os.getenv('HDB_WORKSPACE')):gsub('\\','/')
local project=(os.getenv('HDB_PROJECT')or(workspace..'/HD-Dynamic-Battlefields')):gsub('\\','/')
local runtimeVersion=os.getenv('HDB_RUNTIME_VERSION')or'0.3.88'
local gameVersion=os.getenv('HDB_GAME_VERSION')or'red'
assert(gameVersion=='red'or gameVersion=='blue'or gameVersion=='yellow','Unsupported fixture game')
local engine=workspace..'/.work/hd-battlefields-latest/v'..runtimeVersion..'/engine'
local output=workspace..'/.work/gen1-command-selector-fixture'
if gameVersion~='red'then output=output..'/'..gameVersion end
local function write(name,bytes)local f=assert(io.open(output..'/'..name,'wb'));f:write(bytes);f:close()end
function love.load()
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
 local game={data=data,save={player={name='PROBE',id=1},inventory={badges={}},party={Pokemon.new(data,'SQUIRTLE',10)},options={battleLayout='classic'},pokedex={seen={},owned={}}}}
 game.stack={top=function()return game.battle end}
 local Battle=require('src.battle.BattleState')
 local battle=Battle.newWild(game,'RATTATA',7);game.battle=battle
 battle.phase='menu';battle.introSlide=0;battle.introBalls=false
 local Json=require('src.link.Json')
 local SaveData=require('src.core.SaveData')
 local options=SaveData.defaultOptions()
 options.mods={['hd-dynamic-battlefields']=true}
 local withDex=os.getenv('HDB_1025')=='1'
 if withDex then options.mods['1025dex']=true end
 options.mods.gen3transparency=true
 options.modOptions={['hd-dynamic-battlefields']={enabled=false,selection='fixed',timeMode='day',weatherMode='clear',animation='off'}}
 options.modOptions.gen3transparency={menuTheme=tonumber(os.getenv('SELECTOR_FONT'))or 1,battle_style=3,arrowSelector=tonumber(os.getenv('SELECTOR_STYLE'))or 2,battleCommandsSelector=tonumber(os.getenv('SELECTOR_STYLE'))or 2,performanceMode=1}
 local originalOptions=SaveData.loadOptions;SaveData.loadOptions=function()return options end
 local prefix='mods/hd-dynamic-battlefields/'
 local disk={}
 local function source(p)
  local file
  if p:sub(1,#prefix)==prefix then file=project..'/'..p:sub(#prefix+1)
  elseif p:sub(1,13)=='mods/1025dex/'then file=workspace..'/.work/hd-frlg-compat/1025Dex/extracted/1025dex/'..p:sub(14)
  elseif p:match('^mods/gen3transparency/') then file=workspace..'/.work/menu-gen3-font-fix/'..p:match('^mods/gen3transparency/(.+)$')end
  if not file then return end
  local f=io.open(file,'rb');if not f then return end
  local b=f:read('*a');f:close();return b
 end
 local fs={}
 function fs.read(p)return disk[p]or source(p)end
 function fs.write(p,b)disk[p]=b;return true end
 function fs.getInfo(p)
  if p=='mods'or p=='mods/hd-dynamic-battlefields'or p=='mods/gen3transparency'or p=='mods/1025dex'then return{type='directory'}end
  local b=fs.read(p);if b then return{type='file',size=#b}end
 end
 function fs.getDirectoryItems(p)if p=='mods'then return {'hd-dynamic-battlefields','gen3transparency'}end;return{}end
 function fs.load(p)return assert(loadstring(assert(fs.read(p)),'@'..p))end
 function fs.createDirectory()return true end
 function fs.remove(p)disk[p]=nil;return true end
 love.window.setMode(1280,720,{resizable=false,vsync=0})
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
 local staleMapProbe=os.getenv('HDB_STALE_SAVED_MAP')=='1'
 local previousOverworld=game.overworld
 if staleMapProbe then
  game.overworld={map={id='ROUTE_1'}}
  game.save.player.map='CELADON_MART_1F'
 end

 assert(loader.mods.gen3transparency.state=='loaded',table.concat(loader.errors,'\n'))
 local api=loader.exports.gen3transparency;local arrows=api.arrowSelectors
 local original=arrows.draw;local records={};local active
 local rectangle=G.rectangle
 G.rectangle=function(...)
  if active then active.rectangles=active.rectangles+1 end
  return rectangle(...)
 end
 arrows.draw=function(x,y,h,opts)
  local r={index=battle.menuIndex,rectangles=0,alpha=opts and opts.colors and opts.colors.fg and opts.colors.fg[4],command=opts and opts._battleCommand}
  active=r;local result=original(x,y,h,opts);active=nil;r.result=result
  records[#records+1]=r;return result
 end
 for index=1,4 do
  battle.menuIndex=index;battle.phase='menu'
  local canvas=G.newCanvas(1280,720,{dpiscale=1});G.setCanvas(canvas);G.origin();G.clear(0,0,0,0)
  if os.getenv('SELECTOR_FONT')=='2'then assert(api.battleUi.drawBottom(battle,{x=0,y=480,w=1280,h=240},{dpiX=1,dpiY=1}))else G.translate(240,0);G.scale(5,5);battle:drawTextArea()end
  G.setCanvas()
  G.origin();G.clear(0,0,0,1);G.setColor(1,1,1,1);G.draw(canvas,0,0)
  local captured=false
  G.captureScreenshot(function(image)write('command-'..index..'.png',image:encode('png'):getString());captured=true end)
  G.present();assert(captured,'Missing final-window capture');canvas:release()
 end
 G.rectangle=rectangle;arrows.draw=original
 write('selector-records.json',Json.encode(records))
 for _,r in ipairs(records)do assert(r.result and r.rectangles>0,'Missing Gen 1 command selector pixels: '..Json.encode(r))end
 assert(#records>=4,'Missing selector calls')
 write('result.txt','PASS native Gen 1 command menu selectors at all four positions')
 end,debug.traceback)
 if not ok then write('error.txt',err);print(err)end
 love.event.quit(ok and 0 or 1)
end
