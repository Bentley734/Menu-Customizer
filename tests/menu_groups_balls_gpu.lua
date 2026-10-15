local root=assert(os.getenv('MENU_WORKSPACE')):gsub('\\','/')
local version=os.getenv('MENU_GAME')or'firered'
local out=root..'/.work/battle-font-layout/gpu'
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
   local original=G.draw;local trace={}
   G.draw=function(image,quad,...)
    if image.getWidth and image:getWidth()==256 and image:getHeight()==512 and #trace<100 then local x,y=G.transformPoint(0,0);local ex,ey=G.transformPoint(1,1);local qx,qy,qw,qh=quad:getViewport();trace[#trace+1]=table.concat({x,y,ex-x,ey-y,qx,qy,qw,qh},',')end
    return original(image,quad,...)
   end
   local canvas=G.newCanvas(1728,1296);G.setCanvas(canvas);G.origin();G.clear(.15,.2,.25,1)
   G.push('all');G.translate(0,0);G.scale(GV.generation()<3 and 4 or 3.5)
   fn();G.pop();loader.hooks:call('render.hud',function()end,game,{width=1728,height=1296,dpiX=1,dpiY=1});G.setCanvas();G.draw=original;write(version..'-'..name..'.trace',table.concat(trace,'\n'));write(version..'-'..name..'.png',canvas:newImageData():encode('png'):getString())
  end
  local organize=assert(loadstring(assert(fs.read('mods/menu/lib/menu_organization.lua'))))()
  local pages=organize({{id='wide_startOffsetX',label='START OFFSET X'},{id='wide_optionScale',label='OPTIONS SCALE'},{id='battle:opacity',label='BATTLE OPACITY'},{id='wide_otherOpacity',label='OTHER OPACITY'}},function()end)
  for _,p in ipairs(pages)do if p.label=='POSITION'or p.label=='TRANSPARENCY'then
   assert(#p.children==2 and p.children[1].children and p.children[2].children,'Settings were not grouped by menu')
  end end
  local B=require('src.battle.BattleState');api.customization.write(game,{battleEmptySlotColor=3})
  local src=G.newCanvas(160,144);G.setCanvas(src);G.origin();G.clear(0,0,0,0)
  local party={{hp=20},nil,nil,nil,nil,nil}
  B.drawBallRow({},party,64,16,-8);B.drawBallRow({},party,88,80,8)
  api.customization.write(game,{battleHudFrameColor=4})
  api.battleHudScope=true;require('src.render.HudTiles').tile(0x76,32,32);require('src.render.HudTiles').tile(0x6D,48,32);require('src.render.HudTiles').tile(0x73,64,32);api.battleHudScope=nil
  G.setCanvas();local before=src:newImageData()
  local r,g,b,a=before:getPixel(51,32);assert(a>.9 and r>.4 and g<.2,'Restored HP-cap stroke did not use frame color')
  local _,_,_,cap=before:getPixel(48,35);assert(cap>.9,'Functional HP gauge cap was removed')
  local _,_,_,side=before:getPixel(67,32);assert(side>.9,'Customizable HUD side was not restored')
  local target=G.newCanvas(160,144);G.setCanvas(target);G.origin();G.clear(1,1,1,1)
  local pals={};for i=0,3 do pals[i]={{1,1,1},{.8,.6,.2},{.4,.2,.1},{0,0,0}}end
  local owner={sgbBattlePals=function()return pals end,activeBgp=function()return nil end}
  B.drawZonePass(owner,src,0,0);G.setShader();G.setCanvas()
  local pixels=target:newImageData()
  for _,pos in ipairs({{64,16},{88,80}})do local x,y=pos[1],pos[2]
   local r,g,b=pixels:getPixel(x+3,y+1);assert(r>.7 and g<.2,'Party ball red lost during palette compositing')
   local r,g,b=pixels:getPixel(x+3,y+6);assert(r>.9 and g>.9 and b>.9,'Party ball white lost during palette compositing')
  end
  local red=0
  for y=32,39 do for x=32,71 do local r,g,b,a=before:getPixel(x,y)
   if a>.1 then local rr,gg,bb=pixels:getPixel(x,y);assert(math.abs(r-rr)<.01 and math.abs(g-gg)<.01 and math.abs(b-bb)<.01,'Status frame recolored');if r>.4 and g<.2 then red=red+1 end end
  end end
  assert(red>0,'Status frame test did not draw colored frame ink')
  write(version..'-party-balls-final.png',pixels:encode('png'):getString())
  local gradient
  for i=0,#api.selectorPalette.names-1 do if api.selectorPalette.color('text',i).animation=='GRADIENT'then gradient=i;break end end
  assert(gradient,'No animated frame gradient found')
  api.customization.write(game,{battleHudFrameColor=gradient})
  G.setCanvas(src);G.origin();G.clear(0,0,0,0);api.battleHudScope=true
  require('src.render.HudTiles').tile(0x6D,48,32);require('src.render.HudTiles').tile(0x73,48,40);api.battleHudScope=nil;G.setCanvas()
  local joined=src:newImageData();local r,g,b=joined:getPixel(51,39);local rr,gg,bb=joined:getPixel(51,40)
  assert(math.abs(r-rr)<.04 and math.abs(g-gg)<.04 and math.abs(b-bb)<.04,'Animated gradient jumps at the restored frame joint')
  assert(not M.current and not api.previewScope,'surface scope leaked')
  write(version..'-result.txt','PASS grouped position/transparency menus and both party ball rows after native palette compositing\n')
 end,debug.traceback)
 if not ok then write(version..'-result.txt','FAIL '..tostring(err))end
 love.event.quit(ok and 0 or 1)
end
