-- Actual KIM capture/final HUD code, real Blue character map, Emerald masks,
-- and an independent native Emerald font reference. Set BATTLE_UI_WORKSPACE.
local root=(os.getenv('BATTLE_UI_WORKSPACE') or 'C:/Users/LSDMTHC/Desktop/Hoennto')..'/'
local output=root..'.work/name-pixel-fix/'
local function read(path)local f=assert(io.open(path,'rb'));local s=f:read('*a');f:close();return s end
local function write(path,s)local f=assert(io.open(output..path,'wb'));f:write(s);f:close()end
local function extract(s,a,b)local first=assert(s:find(a,1,true));return s:sub(first,assert(s:find(b,first+#a,true))-1)end
local function compile(s,env)local f=assert(loadstring(s));setfenv(f,env);return f()end
package.path=root..'.tools/engine-0358/?.lua;'..package.path
function love.load()
 local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
 local ok,err=xpcall(function()
  local G=love.graphics;G.setDefaultFilter('nearest','nearest')
  local oldRead=love.filesystem.read;love.filesystem.read=function(p)local f=io.open(root..'.tools/engine-0358/'..p,'rb');if not f then return oldRead(p)end;local s=f:read('*a');f:close();return s end
  local cache=(os.getenv('APPDATA') or 'C:/Users/LSDMTHC/AppData/Roaming')..'/pokemon-love2d/'
  local Blob=require('src.import.CacheBlob');package.loaded['src.import.CacheFs']={readAt=function(p)local f=io.open(cache..p,'rb');if not f then return end;local s=f:read('*a');f:close();return Blob.decode(p,s)end}
  local GV=require('src.core.GameVersion');GV.set('ruby')
  local function image(path)local i=G.newImage(love.filesystem.newFileData(read(path),'font.png'));i:setFilter('nearest','nearest');return i end
  local settings={menuTheme=2};local mod={id='gen3transparency',generation=3,exports={},options={get=function(_,k)return settings[k]end},save={get=function()end},read=function(_,p)return read(root..'MenuCustomizer/'..p)end,assets={image=function(_,p)return image(root..'MenuCustomizer/'..p)end}}
  local Sandbox=require('src.mods.Sandbox')
  local native=assert(Sandbox.compile(mod:read('lib/emerald_native.lua'),'@native-reference',Sandbox.envFor({modId=mod.id,permissions={engine_internals=true}})))()(mod)
  check(native.ready(),'independent native Emerald cache missing')
  local referenceFont=native.battleFont
  GV.set('blue');mod.generation=1
  local Assets=require('src.render.Assets');Assets.register=function()end;Assets.image=function(p)return image(cache..'blue/'..p)end
  local F=require('src.render.Font');F.load({font=assert(loadstring(read(cache..'blue/data/generated/font.lua')))()})
  local active=true
  local P=assert(loadstring(mod:read('lib/battle_text_palette.lua')))()(mod)
  local T=assert(loadstring(mod:read('lib/emerald_theme.lua')))()(mod,function()return mod.exports.battleFontScope and settings.menuTheme==2 end)
  T.gbScale=function()return mod.exports.battleFontScale or .5 end
  T.gbColors=function()return P.colors(mod.exports.battleNameScope and 'name' or 'battle')end
  F._menuCustomizerGB={mod=mod,theme=T,palette=P}
  local originalDraw,originalCode,originalAdvance=F.draw,F.drawCode,F.advanceOf
  F.advanceOf=function(id)return T.enabled() and T.gbAdvance(id) or originalAdvance(id)end
  F.drawCode=function(id,x,y,...)
   G.push('all');G.translate(x,y)
   if not (mod.exports.battleNameScope and T.enabled() and T.gbGlyph(id,0,0))then originalCode(id,0,0,...)end
   G.pop()
  end
  local gb=mod:read('lib/gb_menus.lua');local first=assert(gb:find('  local function label',1,true));local last=assert(gb:find('   if current and current.drawingParty',first,true))
  local label=compile(gb:sub(first,last-1)..'end return label',setmetatable({Font=F,mod=mod,menuPalette=P,unpack=unpack},{__index=_G}))
  F.draw=function(text,x,y,...)return label(text,x,y,originalDraw,...)end
  local ui={emeraldFont=function()return settings.menuTheme==2 end,setting=function(_,fallback)return fallback end}
  ui.hudNames=assert(loadstring(mod:read('lib/battle_hud_names.lua')))()(mod,P,function()return active end);mod.exports.battleUi=ui
  local wrapper=assert(loadstring(mod:read('lib/battle_font.lua')))()(mod);wrapper.active=function()return active end
  local name='RATTATA';local throwHud=false
  local battle={game={},drawHUDs=function(self)
   if throwHud then error('HUD error probe')end
   F.draw(name,8,0);F.draw(name,80,56)
   G.setColor(0,0,0,1);F.draw('10',40,8);F.draw('100',120,64);F.draw('309/309',88,80)
   G.setColor(.2,.92,.32,1);G.rectangle('fill',32,17,48,3);G.rectangle('fill',96,73,48,3)
  end,colorMode=function()return true end}
  wrapper.wrapHud(battle,'drawHUDs')
  local kimSettings={battleHudSize=100,battleHudOpacity=100}
  local kim={find=function()return {exports={battleUi=ui}}end,options={get=function(_,k)return kimSettings[k]end},_kantoInMotionNativeMobileGen1=function()return false end}
  local width,height,dpiX,dpiY=2560,1299,1,1
  local production=read(root..'.work/latest-sprite-fix/current-source/kim1025/main.lua')
  local prior=read(output..'baseline-kim.lua')
  local function make(source)
   local env=setmetatable({love=love,mod=kim,menuBattleUi=function()return ui end,
    touchBattleOrientation=function()return dpiX>1 and 'landscape' or nil end,
    mobilePortraitStageRectPx=function()end,battleWorldMetrics=function()end,mobileScreenPositionLiftPx=function()return 0 end,
    battleUiViewportRect=function()return 0,0,width,height end,
    sizedBattleCanvas=function(c,w,h)if not c or c:getWidth()~=w or c:getHeight()~=h then c=G.newCanvas(w,h,{dpiscale=1});c:setFilter('nearest','nearest')end;return c end,
   },{__index=_G})
   return compile(extract(source,'  local function battleHudGeometry(','  -- Native-resolution fullscreen battlers.')..extract(source,'  local function captureBattleHud(','  local function captureBattleText(')..'return drawBattleHud,captureBattleHud,battleHudGeometry',env)
  end
  local drawOld=make(prior);local drawNew,captureNew,geometry=make(production)
  local function render(fn)
   local c=G.newCanvas(width,height,{dpiscale=dpiX});c:setFilter('nearest','nearest')
   G.push('all');G.setCanvas(c);G.origin();G.clear(0,0,0,0)
   check(fn(battle,{dpiX=dpiX,dpiY=dpiY}),'HUD not drawn');G.pop();return c
  end
  local function expectedNames()
   local c=G.newCanvas(math.floor(width*dpiX),math.floor(height*dpiY),{dpiscale=1})
   local geo=geometry(width*dpiX,height*dpiY);local hs=geo.hudScale
   local unit=math.max(1,math.floor(.75*hs+.5))
   local positions={{geo.enemyBandX+8*hs,geo.enemyBandY-2*hs},{geo.playerBandX+80*hs,geo.playerBandY+6*hs}}
   G.push('all');G.setCanvas(c);G.origin();G.clear(0,0,0,0)
   for _,p in ipairs(positions)do
    G.push('all');G.translate(math.floor(p[1]+.5),math.floor(p[2]+.5));G.scale(unit,unit)
    referenceFont.draw(name,0,0,{colors={fg={0,0,0,1},shadow={0,0,0,0},bg={0,0,0,0}}});G.pop()
   end
   G.pop();return c,positions,unit,geo
  end
  local reproduced=false
  for _,size in ipairs({{1047,699,1},{2560,1299,1},{5120,1440,1},{390,844,3}})do
   width,height,dpiX=size[1],size[2],size[3];dpiY=dpiX
   for _,percent in ipairs({60,80,100})do
    kimSettings.battleHudSize=percent
    local old,new=render(drawOld),render(drawNew)
    local ref,positions,unit,geo=expectedNames();local actual,expected=new:newImageData(),ref:newImageData()
    for _,p in ipairs(positions)do
     local x0,y0=math.floor(p[1]+.5),math.floor(p[2]+.5)
     for y=math.max(0,y0),y0+15*unit do for x=math.max(0,x0),x0+referenceFont.measure(name)*unit-1 do
      local ar,ag,ab,aa=actual:getPixel(x,y);local er,eg,eb,ea=expected:getPixel(x,y)
      -- The font's ink must match the native atlas exactly at a square integer rung.
      if ea>0 then check(ar==er and ag==eg and ab==eb and aa==ea,'native name pixel differs at '..x..','..y)end
     end end
    end
    -- Every HP fill/number remains byte-identical to the prior KIM path.
    local before=old:newImageData()
    for _,rect in ipairs({{geo.enemyBandX+30*geo.hudScale,geo.enemyBandY+15*geo.hudScale,52*geo.hudScale,9*geo.hudScale},{geo.playerBandX+87*geo.hudScale,geo.playerBandY+23*geo.hudScale,66*geo.hudScale,18*geo.hudScale}})do
     for y=math.max(0,math.ceil(rect[2])),math.min(actual:getHeight()-1,math.floor(rect[2]+rect[4]-1)) do for x=math.max(0,math.ceil(rect[1])),math.min(actual:getWidth()-1,math.floor(rect[1]+rect[3]-1))do
      local r,g,b,a=actual:getPixel(x,y);local rr,gg,bb,aa=before:getPixel(x,y)
      check(r==rr and g==gg and b==bb and a==aa,'native HP changed')
     end end
    end
    if width==2560 and percent==80 then
     write('before.png',old:newImageData():encode('png'):getString());write('after.png',new:newImageData():encode('png'):getString())
     reproduced=old:newImageData():getString()~=new:newImageData():getString()
    end
    check(mod.exports.fontAspect==nil and mod.exports.battleHudNames==nil and battle._kimHudNames==nil,'name capture state leaked')
   end
  end
  check(reproduced,'reported fractional capture problem was not reproduced')
  width,height,dpiX,dpiY=2560,1299,1,1;kimSettings.battleHudSize=80
  name='TTT';local c=render(drawNew);local _,positions,unit=expectedNames();local data=c:newImageData();local p=positions[1]
  local startX,startY=math.floor(p[1]+.5),math.floor(p[2]+.5);local advance=referenceFont.measure('T')*unit
  for y=math.max(0,startY),startY+15*unit do for x=0,advance-1 do
   local r,g,b,a=data:getPixel(startX+x,y)
   for i=1,2 do local rr,gg,bb,aa=data:getPixel(startX+x+i*advance,y);check(r==rr and g==gg and b==bb and a==aa,'repeated Ts have different pixels')end
  end end
  active=false;check(render(drawNew):newImageData():getString()==render(drawOld):newImageData():getString(),'disabled menu fallback changed');active=true
  settings.menuTheme=1;check(render(drawNew):newImageData():getString()==render(drawOld):newImageData():getString(),'vanilla font fallback changed');settings.menuTheme=2
  local priorNames={sentinel=true};battle._kimHudNames=priorNames;throwHud=true
  local layer=captureNew(battle,0,{scaleX=8,scaleY=8,dpiX=1,dpiY=1})
  check(layer==nil and battle._kimHudNames==priorNames and mod.exports.battleHudNames==nil,'capture error leaked queue state')
  battle._kimHudNames=nil;throwHud=false
  local priorAspect={2,1};mod.exports.fontAspect=priorAspect;local original=T.draw;T.draw=function()error('font error probe')end
  local depth=G.getStackDepth();check(not pcall(ui.hudNames.draw,{entries={{text='TTT',x=16,y=4,side='enemy'}}},{enemy={x=0,y=0,sourceY=0},scaleX=8,scaleY=8,dpiX=1,dpiY=1}), 'font error must propagate')
  check(G.getStackDepth()==depth and mod.exports.fontAspect==priorAspect,'font error leaked graphics/aspect state');T.draw=original;mod.exports.fontAspect=nil
  write('result.txt','PASS '..checks..' final KIM/name pixel, repeated-T, native HP, DPI, fallback and state-restoration checks\n')
 end,debug.traceback)
 if not ok then write('result.txt','FAIL '..err)end
 love.event.quit(ok and 0 or 1)
end
