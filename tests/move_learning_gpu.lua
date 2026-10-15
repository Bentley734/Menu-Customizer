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

  local F=require('src.render.Font');local Learn=require('src.ui.MoveLearnMenu');local Choice=require('src.ui.ChoiceBox');local Text=require('src.render.TextBox')
  local P=api.moveLearningProfile;local mod=api.gbMenus.mod
  local ds;for id,e in ipairs(api.borderCatalog.entries)do if e.dsFrame then ds=id;break end end
  api.customization.write(game,{moveLearningCustom=1,moveLearningTheme=2,moveLearningBorderChoice=ds,moveLearningTextColor=4,moveLearningBackgroundColor=1,moveLearningJustify=2,moveLearningTextCase=3})
  local normal=mod.options:get('dialogueTextColor')
  P.with(function()assert(mod.options:get('dialogueTextColor')==4);assert(mod.options:get('optionBorderChoice')==ds);assert(api.textScopes.currentScope()=='moveLearning')end)
  assert(not P.active and mod.options:get('dialogueTextColor')==normal,'Move learning settings leaked')
  local mon={nickname='SQUIRTLE',species=7,moves={{id='TACKLE',pp=30},{id='TAIL_WHIP',pp=30},{id='WATER_GUN',pp=20},{id='WITHDRAW',pp=40}}}
  game.data.moves.TACKLE={name='TACKLE',pp=35};game.data.moves.TAIL_WHIP={name='TAIL WHIP',pp=30};game.data.moves.WATER_GUN={name='WATER GUN',pp=25};game.data.moves.WITHDRAW={name='WITHDRAW',pp=40};game.data.moves.RAPID_SPIN={name='RAPID SPIN',pp=40}
  local learn=Learn.new(game,mon,'RAPID_SPIN',function()end);game.stack.states={learn}
  local text=Text.new(game,'Delete an older move to make room for Rapid Spin?')
  assert(text._menuCustomizerLearning,'Learning text did not retain its profile')
  local choice=Choice.new(game,function()end);game.stack.states={learn,text,choice}
  local cover;local occlude=api.battleNameSurface.occlude
  api.battleNameSurface.occlude=function(x,y,w,h)cover={x=x,y=y,w=w,h=h};return occlude(x,y,w,h)end
  local native=G.newCanvas(160,144);G.setCanvas(native);G.origin();G.clear(0,0,0,1)
  local owner={player=mon,enemy={}};api.battleHudOwner=owner;api.battleHudScope=true;api.battleFontScope=true
  F.draw('SQUIRTLE',80,56);api.battleHudOwner=nil;api.battleHudScope=nil;api.battleFontScope=nil
  choice:draw();assert(cover,'Choice window did not occlude names')
  local theme=api.gbMenus.theme;local glyph=theme.glyph;local count=0
  theme.glyph=function(id,x,y,opts)
   if api.battleNameScope then
    local sx,sy,sw,sh=G.getScissor();assert(sx,'Name ignored its child-window clip')
    local l,t=math.max(sx,cover.x*5),math.max(sy,cover.y*5);local rr,bb=math.min(sx+sw,(cover.x+cover.w)*5),math.min(sy+sh,(cover.y+cover.h)*5)
    assert(l>=rr or t>=bb,'Name was drawn over the Yes/No box');count=count+1
   end
   return glyph(id,x,y,opts)
  end
  local intermediate=G.newCanvas(1000,800);G.setCanvas(intermediate);G.origin();G.clear(0,0,0,1);G.setColor(1,1,1,1);G.draw(native,0,0,0,2.5,2.5)
  G.setCanvas();G.origin();G.clear(.12,.15,.18,1);G.draw(intermediate,0,0,0,2,2)
  assert(count>0,'Visible portion of name disappeared')
  local hud=G.newCanvas(160,144);G.setCanvas(hud);G.origin();G.clear(0,0,0,0)
  api.battleHudOwner=owner;api.battleHudScope=true;api.battleFontScope=true
  F.draw('SQUIRTLE',80,56);api.battleHudOwner=nil;api.battleHudScope=nil;api.battleFontScope=nil
  G.setCanvas();G.origin();G.draw(hud,0,0,0,5,5)
  assert(count>0,'Late HUD pass hid the whole name')
  game.stack.states={learn};learn.selecting=true
  api.gbMenus.dialogueText.beginFrame()
  local list=G.newCanvas(160,144);G.setCanvas(list);G.origin();G.clear(0,0,0,0);learn:draw()
  local target=G.newCanvas(1728,1296);G.setCanvas(target);G.origin();G.clear(.12,.15,.18,1);G.setColor(1,1,1,1);G.draw(list,0,0,0,6,6);G.setCanvas()
  write(version..'-move-learning-forget-list.png',target:newImageData():encode('png'):getString())
  local organize=assert(loadstring(fs.read('mods/menu/lib/menu_organization.lua')))()
  local pages=organize(P.rows(function()end),function()end)
  local function check(rows,path)
   for _,row in ipairs(rows)do
    local here=path..'/'..row.label
    if row.children then check(row.children,here)
    elseif (row.id or''):find('moveLearning')and not row.id:find('TextCase')then assert(here:find('/BATTLE/MOVE LEARNING/'),'Learning setting outside Battle submenu: '..here)end
   end
  end
  check(pages,'')
  assert(not P.active,'Learning profile scope leaked after rendering')
  game.stack.states={}
  assert(not Text.new(game,'Ordinary dialogue')._menuCustomizerLearning,'Ordinary dialogue inherited move learning settings')
  local ok=pcall(P.with,function()error('scope restore probe')end);assert(not ok and not P.active)
  local row=P.rows(function()end)[1];row.step(game,1);assert(mod.options:get('moveLearningCustom')==0,'Cannot restore inherited style')
  write(version..'-result.txt','PASS move-learning profile isolation, tagged child dialogue, forget-list rendering and final-window name clipping behind Yes/No through intermediate canvases\n')
 end,debug.traceback)
 if not ok then write(version..'-result.txt','FAIL '..tostring(err))end
 love.event.quit(ok and 0 or 1)
end
