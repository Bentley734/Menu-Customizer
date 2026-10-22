local workspace=assert(os.getenv('HDB_WORKSPACE')):gsub('\\','/')
local project=assert(os.getenv('HDB_PROJECT'),'Set HDB_PROJECT to the HD Dynamic Battlefields source'):gsub('\\','/')
local menuSource=assert(os.getenv('MENU_SOURCE'),'Set MENU_SOURCE to the Menu Customizer source'):gsub('\\','/')
local runtimeVersion=os.getenv('HDB_RUNTIME_VERSION')or'0.3.95'
local gameVersion=os.getenv('HDB_GAME_VERSION')or'red'
assert(gameVersion=='red'or gameVersion=='blue'or gameVersion=='yellow','Unsupported fixture game')
local engine=os.getenv('SHADOW_ENGINE')or(workspace..'/.work/hd-battlefields-latest/v'..runtimeVersion..'/engine')
local output=assert(os.getenv('SHADOW_OUT'),'Set SHADOW_OUT to an existing scratch directory')
local expectClipped=os.getenv('SHADOW_EXPECT_CLIPPED')=='1'

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
 local battle=Battle.newWild(game,'SQUIRTLE',5);game.battle=battle
 battle.phase='menu';battle.player.name='Charmander';battle.enemy.name='Squirtle';battle.introSlide=0;battle.introBalls=false;battle.current={};battle.shown={require('src.render.Font').encode('CHARMANDER grew'),require('src.render.Font').encode('to level 10!')};game.stack.states={battle}
 local Json=require('src.link.Json')
 local SaveData=require('src.core.SaveData')
 local options=SaveData.defaultOptions()
 options.mods={['hd-dynamic-battlefields']=true}
 options.mods.gen3transparency=true
 options.modOptions={['hd-dynamic-battlefields']={enabled=true,aspect=os.getenv('SHADOW_ART_ASPECT')or'16:9',environment='grassland',selection='fixed',timeMode='day',weatherMode='clear',animation='off'}}
 options.modOptions.gen3transparency={menuTheme=2,battle_style=3,battleBorderChoice=13,battle_background_color=5,battle_opacity=75,arrowSelector=tonumber(os.getenv('SELECTOR_STYLE'))or 2,battleCommandsSelector=tonumber(os.getenv('SELECTOR_STYLE'))or 2,performanceMode=1,battle_text_color=4,battle_shadow_color=1,battle_name_color=4,battle_name_shadow_color=1,battlePromptTextColor=4,battlePromptTextShadowColor=1,battlePromptJustify=1,battlePromptSize=1,battleTextCase=3,textCase=3}
 local originalOptions=SaveData.loadOptions;SaveData.loadOptions=function()return options end
 local prefix='mods/hd-dynamic-battlefields/'
 local disk={}
 local function source(p)
  local file
  if p:sub(1,#prefix)==prefix then file=project..'/'..p:sub(#prefix+1)
  elseif p:match('^mods/gen3transparency/') then local rel=p:match('^mods/gen3transparency/(.+)$');file=menuSource..'/'..rel end
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
 love.window.setMode(tonumber(os.getenv('SHADOW_WIDTH'))or 1280,tonumber(os.getenv('SHADOW_HEIGHT'))or 720,{resizable=false,vsync=0})
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
 local api=loader.exports.gen3transparency
 local theme=api.gbMenus.theme
 local original=theme.draw;local traces={};local replay=false;local depth=0
 theme.draw=function(text,x,y,opts)
  local name=tostring(text):lower()
  local wanted=name=='squirtle'or name=='charmander'or name=='what will'or name=='charmander do?'
  if wanted and not G.getCanvas()and not replay and depth==0 then
   local ax,ay=G.transformPoint(x,y);local bx,by=G.transformPoint(x+1,y);local cx,cy=G.transformPoint(x,y+1)
   assert(math.abs((bx-ax)-(cy-ay))<.00001 and math.abs((bx-ax)-math.floor(bx-ax+.5))<.00001,'Final glyph pixels must remain square and integer-scaled');local sx,sy=G.getScissor()
   traces[#traces+1]={text=text,x=ax,y=ay,unitX=bx-ax,unitY=cy-ay,scissor={G.getScissor()},opts=opts}
  end
  depth=depth+1;local r={original(text,x,y,opts)};depth=depth-1
  return(unpack or table.unpack)(r)
 end
 G.setCanvas();G.origin();G.setScissor();G.clear(.9,.9,.9,1)
 Game.draw(game)
 local capture
 G.captureScreenshot(function(img)capture=img;write('battle.png',img:encode('png'):getString())end);G.present();assert(capture)
 assert(#traces>=4,'Missing final names or prompt lines')
 local checks={};local failures=0;local matches=0
 for i,t in ipairs(traces)do
  local canvas=G.newCanvas(G.getWidth(),G.getHeight(),{dpiscale=1})
  G.push('all');G.setCanvas(canvas);G.origin();G.setShader();G.setScissor();G.clear(0,0,0,0);G.setBlendMode('alpha','alphamultiply')
  G.translate(t.x,t.y);G.scale(t.unitX,t.unitY)
  replay=true;original(t.text,0,0,t.opts);replay=false
  G.pop()
  local image=canvas:newImageData();write('reference-'..i..'.png',image:encode('png'):getString())
  local missing,expected=0,0
  local left=math.max(0,math.floor(t.x-t.unitX+.0001));local right=math.ceil(t.x)-1
  local top=math.max(0,math.floor(t.y));local bottom=math.min(capture:getHeight()-1,math.ceil(t.y+16*t.unitY)-1)
  for y=top,bottom do for x=left,right do
   local r,g,b,a=image:getPixel(x,y)
   if a>.99 and r<.01 and g<.01 and b<.01 then
    expected=expected+1
    local rr,gg,bb=capture:getPixel(x,y)
    if rr>.01 or gg>.01 or bb>.01 then missing=missing+1 end
   end
  end end
  checks[#checks+1]={text=t.text,x=t.x,y=t.y,unitX=t.unitX,unitY=t.unitY,scissor=t.scissor,expectedLeftShadow=expected,missing=missing}
  if expected>0 then matches=matches+1;if missing>0 then failures=failures+1 end end
 end
 write('checks.json',Json.encode(checks))
 write('result.txt',('shadow-bearing labels=%d; clipped labels=%d; mode=%s'):format(matches,failures,expectClipped and'before'or'after'))
 assert(matches>=4,'No left-shadow mask in all expected labels')
 if not expectClipped then assert(failures==0,'First-letter shadows are clipped')else assert(failures>=3,'Fixture did not reproduce reported clipping')end
 if not expectClipped then
  local Font=require('src.render.Font')
  local owner={player={},enemy={}}
  local function occluded(cover)
   local native=G.newCanvas(160,144,{dpiscale=1})
   G.push('all');G.setCanvas(native);G.origin();G.setShader();G.setScissor();G.clear(0,0,0,0)
   api.battleHudOwner=owner;api.battleHudScope=true;api.battleFontScope=true
   Font.draw('Charmander',80,56)
   api.battleHudOwner=nil;api.battleHudScope=nil;api.battleFontScope=nil
   if cover then api.battleNameSurface.occlude(72,48,8,24)end
   G.setColor(.1,.6,.9,1);G.rectangle('fill',72,48,8,24);G.pop()
   G.setCanvas();G.origin();G.setShader();G.setScissor();G.clear(.9,.9,.9,1);G.setColor(1,1,1,1)
   G.draw(native,0,0,0,4,4)
   local pic;G.captureScreenshot(function(img)pic=img;write(cover and'occlusion-covered.png'or'occlusion-control.png',img:encode('png'):getString())end);G.present();assert(pic)
   local black,cyan=0,0
   for y=220,267 do for x=317,319 do local r,g,b=pic:getPixel(x,y)
    if r<.01 and g<.01 and b<.01 then black=black+1 end
    if math.abs(r-.1)<.01 and math.abs(g-.6)<.01 and math.abs(b-.9)<.01 then cyan=cyan+1 end
   end end
   return black,cyan
  end
  local control=occluded(false);local clipped,cyan=occluded(true)
  assert(control>0,'Occlusion control must paint the new left-shadow overhang')
  assert(clipped==0 and cyan==144,'Opaque child cover must still hide the entire left-shadow overhang')
  write('occlusion.txt',('PASS shadow control=%d pixels; covered=%d; preserved cover=%d'):format(control,clipped,cyan))
 end
 end,debug.traceback)
 if not ok then write('error.txt',err);print(err)end
 love.event.quit(ok and 0 or 1)
end
