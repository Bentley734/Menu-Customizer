local root=assert(os.getenv('MENU_WORKSPACE')):gsub('\\','/')
local version=os.getenv('MENU_GAME')or'firered'
local out=root..'/.work/independent-speeds/gpu'
local source=os.getenv('MENU_SOURCE')or root..'/.work/move-effects-audit/git-Menu-Customizer'
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
  options.modOptions.gen3transparency.menuTextColor=6; options.modOptions.gen3transparency.allFontAlign=2; options.modOptions.gen3transparency.startJustify=2; options.modOptions.gen3transparency.selectorColor=200; options.modOptions.gen3transparency.startMenuBackgroundColor=372; require('src.core.SaveData').loadOptions=function()return options end
  local Loader=require('src.mods.Loader');local loader=Loader.new{fs=fs,generation=GV.generation(),version=version,dev=false};loader:load(data)
  assert(loader.mods.gen3transparency.state=='loaded',table.concat(loader.errors,'\n'))
  local api=loader.exports.gen3transparency;local M=api.menuSurfaces
  local G=love.graphics;local game={data=data,options=options,mods=loader,save={money=9000,player={money=9000},inventory={},bagOrder={}},writeOptions=function()end}
  game.stack={states={},push=function(self,s)self.states[#self.states+1]=s end,pop=function(self)return table.remove(self.states)end,top=function(self)return self.states[#self.states]end}

  local G=love.graphics;local P=api.selectorPalette
  api.customization.write(game,{gameFreakTextColor=4,gameFreakTextShadowColor=0,introTextColor=2,intro_fx_preset=0,intro_fx_alternate=0,menu_fx_preset=0,menu_fx_alternate=0})
  local data=love.image.newImageData(8,8);data:mapPixel(function(x,y)if x>=2 and x<=5 and y>=2 and y<=5 then return 0,0,0,1 end;return 1,1,1,1 end)
  local image=G.newImage(data);local canvas=G.newCanvas(32,32);G.setCanvas(canvas);G.clear(0,0,0,1)
  assert(api.gameFreakLogo.draw(image,true,4,4));G.setCanvas()
  local pixels=canvas:newImageData();local r,g,b=pixels:getPixel(7,7);assert(r>g*3 and r>b*3,'Emblem did not use its own red color')
  local r,g,b=pixels:getPixel(4,4);assert(r==0 and g==0 and b==0,'Emblem white paper became an opaque box')
  assert(not api.gameFreakLogoScope)
  if GV.generation()<3 then
   local Font=require('src.render.Font');local Start=require(GV.generation()==2 and 'src.ui.gen2.StartMenu'or'src.ui.StartMenu')
   game.save.flags={};game.save.party={};game.save.options=options
   local world={map={id='PokeMart'},draw=function()end};game.world=world
   for _,mode in ipairs({1,2})do
   for selector=0,13 do
    api.customization.write(game,{menuTheme=mode,startSelector=selector,startTextCase=3,menuTransition=1,controlsLegend=3})
    local start=Start.new(game);if GV.generation()==2 then start.screenId='Gen2StartMenu'end;game.stack.states={world,start}
    local selected=false;local old=api.gbMenus.drawSelector
    api.gbMenus.drawSelector=function(meta)if meta then assert(meta.selection,'Start selector lost its selected row');selected=true end;return old(meta)end
    local target=G.newCanvas(960,600);G.setCanvas(target);G.origin();G.clear(0,0,0,1)
    api.gbMenus.draw(game,{width=960,height=600,scale=4,gameX=160,gameY=12});G.setCanvas();api.gbMenus.drawSelector=old
    assert(selected,'Start menu selector drawing was skipped')
    write(version..'-start-'..mode..'-'..selector..'.png',target:newImageData():encode('png'):getString())
   end
  end
  end
  write(version..'-result.txt','PASS GPU emblem-only color/mask and native/Emerald start selectors')
 end,debug.traceback)
 if not ok then write(version..'-result.txt','FAIL '..tostring(err))end
 love.event.quit(ok and 0 or 1)
end
