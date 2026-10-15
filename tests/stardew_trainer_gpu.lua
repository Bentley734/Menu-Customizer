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


  local J=api.jumpWave;local now=0;local timer=love.timer.getTime;love.timer.getTime=function()return now end
  api.customization.write(game,{stardewEnabled=1,jumpWaveEnabled=0,jumpWaveSpeed=100,arrowSelector=2})
  assert(J.enabled()and not J.classicEnabled(),'Stardew requires old Jump Wave toggle')
  local owner={};J.select(owner,1,'A B é');local started=J.started
  now=.1125;J.select(owner,1,'a b é');assert(J.started==started,'Same selection restarted')
  local marks={};local function printer(c,x,y)G.setColor(1,1,1,1);local _,_,_,a=G.getColor();marks[#marks+1]={c,x,y,a}end
  local width=J.draw(printer,function(c)return c==' 'and 4 or 8 end,'A B é',10,20)
  assert(width==32 and #marks==5,'UTF-8 split or spaces changed advance')
  assert(marks[1][3]==15 and marks[3][3]==25 and marks[5][3]==15,'Letters do not alternate in opposite directions')
  assert(marks[2][2]==18 and marks[2][3]==20 and marks[4][2]==30,'Spaces moved or consumed bounce phase')
  assert(marks[1][4]==1,'Stardew text should remain fully visible')
  api.customization.write(game,{stardewJumps=1})
  assert(J.bounce(.45,1,J.jumps(),100)==0 and J.bounce(5,1,J.jumps(),100)==0,'One jump did not settle')
  api.customization.write(game,{stardewJumps=4})
  assert(J.bounce(.5625,1,J.jumps(),100)==5 and J.bounce(1.8,1,J.jumps(),100)==0,'Jump count ignored')
  now=5;marks={};J.draw(printer,function()return 8 end,'A',0,0);assert(marks[1][4]==1 and marks[1][3]==0,'Text did not return to its original visible location')
  now=6;J.select(owner,2,'B');assert(J.started==6,'New selection did not restart')
  local color=G.setColor;local ok=pcall(J.draw,function()error('test')end,function()return 8 end,'A',0,0);assert(not ok and G.setColor==color and not J.active,'Wave error leaked graphics state')
  local selectors;for _,page in ipairs(api.gbMenus.rows)do if page.label=='SELECTORS'then selectors=page.children end end
  assert(selectors,'Actual Selectors page missing')
  local found=false;for _,row in ipairs(selectors)do if row.id=='wide_stardewSelector'then found=row.label=='STARDEW';row.step(game)end end
  assert(api.arrowSelectors.names[14]=='STARDEW'and api.gbMenus.selectors.names[14]=='STARDEW','Stardew cursor style missing')
  local count=0;for _,row in ipairs(selectors)do if row.id=='wide_stardewSelector'then count=count+1 end end;assert(count==1,'Duplicate Stardew toggle')
  assert(found and not J.alternating(),'Stardew toggle missing or cannot disable');assert(api.gbMenus.mod.options:get('arrowSelector')==2,'Stardew changed companion marker')
  api.customization.write(game,{arrowSelector=14});assert(J.alternating()and J.enabled(),'Standalone Stardew style does not enable animation')
  api.customization.write(game,{arrowSelector=2})
  local E=api.selectorPalette.effects;local scope=api.textScopes
  api.customization.write(game,{menu_fx_stardew=1,menu_fx_stardew_jumps=2,party_fx_stardew=0})
  scope.with('party',function()assert(E.stardewGet('menu','stardew',0)==0,'Party inherited menu Stardew')end)
  local colors={_kind='menu',fg={1,1,1,1},shadow={0,0,0,0}}
  local observed={}
  local function effectsDraw()
   E.sequence('menu',function()
    E.glyph(colors,0,0,function()local _,y=G.transformPoint(0,0);observed[#observed+1]=y end)
    E.ink(colors,true)
    E.glyph(colors,10,0,function()local _,y=G.transformPoint(0,0);observed[#observed+1]=y end)
   end,'Test',0,0)
  end
  now=10;effectsDraw();observed={};now=10.1125;effectsDraw()
  assert(observed[1]==-5 and observed[2]==5,'Text-effect glyphs did not alternate across a space')
  for i=2,10 do now=10+i*.1;effectsDraw()end
  observed={};now=11.1;effectsDraw();assert(observed[1]==0 and observed[2]==0,'Text effect did not settle at baseline')
  local global=api.allFonts.values('menu_fx_stardew_jumps',7)
  assert(global.party_fx_stardew_jumps==7 and global.battleCommands_fx_stardew_jumps==7,'All Fonts Stardew did not reach individual scopes')
  local textRows=scope.rows(function()end);local party=false
  for _,row in ipairs(textRows)do if row.id=='fx_party_fx_stardew'then party=true end end
  assert(party,'Party text Stardew option missing')
  api.customization.write(game,{battle_fx_stardew=1,battle_fx_stardew_jumps=2,battleHudHPColor=6,battleHudHPShadowColor=0})
  local hpCanvas=G.newCanvas(160,144);G.setCanvas(hpCanvas);G.origin();G.clear(0,0,0,1)
  local F=require('src.render.Font');api.battleHudScope=true;api.battleFontScope=true
  now=20;F.draw('20',104,80)
  local hudDraw=G.draw;local positions={}
  G.draw=function(image,quad,x,y,...)
   if image.typeOf and image:typeOf('Image')and type(x)=='number'then local _,py=G.transformPoint(x,y);positions[#positions+1]=py end
   return hudDraw(image,quad,x,y,...)
  end
  now=20.1125;F.draw('20',104,80);G.draw=hudDraw
  api.battleHudScope=nil;api.battleFontScope=nil;G.setCanvas()
  assert(positions[1]==75 and positions[2]==85,'Native HP digits bypass Stardew text customization')
  love.timer.getTime=timer
  local B=require('src.battle.BattleState');local pixels=love.image.newImageData(8,8);pixels:mapPixel(function()return 1,0,0,1 end);local image=G.newImage(pixels)
  local fake={data={},showPlayerBack=true,playerBackPic=image,picImage=function()return image end,picOffset=function()return 0 end,bottomUIVisible=function()return true end}
  local target=G.newCanvas(160,144);G.setCanvas(target);G.origin();G.setScissor(0,0,160,96)
  local draw=G.draw;local records={};G.draw=function(img,x,y,...)if img==image then local _,_,_,h=G.getScissor();records[#records+1]={x,y,h}end;return draw(img,x,y,...)end
  api.customization.write(game,{battle_style=1});B.drawPicsLayer(fake,0,0,0,'player')
  local ds;for id,e in ipairs(api.borderCatalog.entries)do if e.dsFrame then ds=id;break end end
  api.customization.write(game,{battle_style=3,battleBorderChoice=ds});B.drawPicsLayer(fake,0,0,0,'player')
  G.draw=draw;G.setCanvas();G.setScissor()
  assert(#records==2 and records[2][1]==records[1][1]and records[2][2]==records[1][2]+2,'Trainer back did not move down exactly 2px only for Gen4 frame')
  assert(records[1][3]==96 and records[2][3]==98,'Trainer feet remain clipped above visible border')
  write(version..'-result.txt','PASS Stardew alternating UTF-8/space bounce, configured jump count and baseline restoration, marker combination and scoped 2px Gen4 trainer placement\n')
 end,debug.traceback)
 if not ok then write(version..'-result.txt','FAIL '..tostring(err))end
 love.event.quit(ok and 0 or 1)
end
