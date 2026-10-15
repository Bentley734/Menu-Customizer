local root=assert(os.getenv('MENU_WORKSPACE')):gsub('\\','/')
local version=os.getenv('MENU_GAME')or'firered'
local out=root..'/.work/jump-wave/gpu'
local source=root..'/.work/move-effects-audit/git-Menu-Customizer'
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

  local G=love.graphics;local P=api.selectorPalette
  api.customization.write(game,{gameFreakTextColor=4,gameFreakTextShadowColor=0,introTextColor=2,intro_fx_preset=0,intro_fx_alternate=0,menu_fx_preset=0,menu_fx_alternate=0})
  local data=love.image.newImageData(8,8);data:mapPixel(function(x,y)if x>=2 and x<=5 and y>=2 and y<=5 then return 0,0,0,1 end;return 1,1,1,1 end)
  local image=G.newImage(data);local canvas=G.newCanvas(32,32);G.setCanvas(canvas);G.clear(0,0,0,1)
  assert(api.gameFreakLogo.draw(image,true,4,4));G.setCanvas()
  local pixels=canvas:newImageData();local r,g,b=pixels:getPixel(7,7);assert(r>g*3 and r>b*3,'Emblem did not use its own red color')
  local r,g,b=pixels:getPixel(4,4);assert(r==0 and g==0 and b==0,'Emblem white paper became an opaque box')
  assert(not api.gameFreakLogoScope)
  local Menu=require('src.ui.Menu')
  local menu=Menu.new(game,{{label='CONTINUE'},{label='NEW GAME'},{label='OPTION'},{label='EXIT GAME'}},{tx=0,ty=0,tw=13,th=10})
  menu.titleUiBox={0,0,12,9}
  local overlay={titleUiBox={4,7,15,9},save={},title={}}
  local target=G.newCanvas(160,144);local clock=love.timer.getTime;local tick=.11;love.timer.getTime=function()return tick end
  for _,mode in ipairs({1,2})do
   for align=1,3 do
    api.customization.write(game,{jumpWaveEnabled=1,jumpWaveSpeed=150,arrowSelector=2,menuTheme=mode,introTheme=mode,allFontAlign=align,menuJustify=align,introFontSize=0})
    local function frame(top)
     game.stack.states={menu};if top then game.stack.states[2]=top end
     G.setCanvas(target);G.origin();G.clear(0,0,0,0);menu:draw();G.setCanvas()
     return target:newImageData():getString()
    end
    tick=.11;local before=frame();assert(before==frame(overlay),'Continue changed underlying title menu pixels')
    assert(before==frame(),'Closing Continue changed underlying title menu pixels');tick=.33;assert(before~=frame(),'Jump Wave did not animate the selected label')
   end
  end
  write(version..'-right-aligned.png',target:newImageData():encode('png'):getString())
  love.timer.getTime=clock
  write(version..'-result.txt','PASS GPU retained title alignment: native/Emerald, left/center/right, open/close Continue')
 end,debug.traceback)
 if not ok then write(version..'-result.txt','FAIL '..tostring(err))end
 love.event.quit(ok and 0 or 1)
end
