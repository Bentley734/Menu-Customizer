local root=assert(os.getenv('MENU_WORKSPACE')):gsub('\\','/')
local version=os.getenv('MENU_GAME')or'firered'
local out=root..'/.work/void-backgrounds/gpu'
local source=os.getenv('MENU_SOURCE')or(root..'/.work/move-effects-audit/git-Menu-Customizer')
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
  local options={modOptions={gen3transparency={menuTheme=1,menuTransition=1,controlsLegend=3,opacityFormat=2,
   martCustom=1,martTheme=2,martBorderChoice=13,martBackgroundColor=10,martTextColor=0,martTextShadowColor=0,
   pcCustom=1,pcTheme=2,pcBorderChoice=13,pcBackgroundColor=6,pcTextColor=0,pcTextShadowColor=0,
   dialogueTheme=2,dialogueBorderChoice=13,dialogueBorder=1,dialogueBackgroundColor=10,dialogueTextColor=0}}}
  require('src.core.SaveData').loadOptions=function()return options end
  local Loader=require('src.mods.Loader');local loader=Loader.new{fs=fs,generation=GV.generation(),version=version,dev=false};loader:load(data)
  assert(loader.mods.gen3transparency.state=='loaded',table.concat(loader.errors,'\n'))
  local api=loader.exports.gen3transparency;local M=api.menuSurfaces
  local G=love.graphics;local game={data=data,options=options,mods=loader,save={money=9000,player={money=9000},inventory={},bagOrder={}},writeOptions=function()end}
  game.stack={states={},push=function(self,s)self.states[#self.states+1]=s end,pop=function(self)return table.remove(self.states)end,top=function(self)return self.states[#self.states]end}

  local V=api.voidBackgrounds;local bucket=options.modOptions.gen3transparency
  local choice;for i,name in ipairs(api.selectorPalette.backgroundNames)do if name=='BLACK SPIRAL UNDERTOW'then choice=i end end;assert(choice)
  bucket.indoorVoidBackgroundColor=choice;bucket.outdoorVoidBackgroundColor=choice
  local imageData=love.image.newImageData(64,64);imageData:mapPixel(function()return .1,.75,.25,1 end);local mapImage=G.newImage(imageData)
  local canvas=G.newCanvas(320,180)
  for _,phase in ipairs({0,2})do
   love.timer.getTime=function()return phase end
   G.setCanvas(canvas);G.origin();G.clear(.3,.3,.3,1)
   if GV.generation()==1 then
    local Tile=require('src.render.TileRenderer')
    local map={def={width=2,height=2,tileset='MART'}}
    local neighbor={map={def={width=2,height=2}},ox=64,oy=0}
    V.world={map=map,neighbors={neighbor}}
    local renderer=setmetatable({map=map,winBatch=mapImage,ensureWindow=function()end,drawAnimated=function()end},{__index=Tile})
    renderer:drawWindow(-120,-60,320,180)
    local other=setmetatable({map=neighbor.map,winBatch=mapImage,ensureWindow=function()end,drawAnimated=function()end},{__index=Tile})
    other:drawWindow(-184,-60,320,180);V.world=nil
   elseif GV.generation()==2 then
    local Border=require('src.world.gen2.BorderFill');Border.voidFill='black'
    local World=require('src.world.gen2.World')
    local state={map={def={environment='INDOOR'}},camera={x=-120,y=-60},mapImage=mapImage,neighbors={{image=mapImage,ox=64,oy=0}},drawAnimCells=function()end}
    World.drawGround(state,1)
   else
    G.setColor(1,1,1,1);G.draw(mapImage,120,60);G.draw(mapImage,184,60)
    V.paint(choice,320,180,V.subtract(320,180,{{120,60,64,64},{184,60,64,64}}))
   end
   G.setCanvas();write(version..'-void-'..phase..'.png',canvas:newImageData():encode('png'):getString())
  end
  write(version..'-result.txt','PASS graphics void mask and animated palette')
 end,debug.traceback)
 if not ok then write(version..'-result.txt','FAIL '..tostring(err))end
 love.event.quit(ok and 0 or 1)
end
