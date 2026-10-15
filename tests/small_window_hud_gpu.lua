-- Actual KIM capture/final HUD code, real Blue character map, Emerald masks,
-- and an independent native Emerald font reference. Set BATTLE_UI_WORKSPACE.
local root=(os.getenv('BATTLE_UI_WORKSPACE') or 'C:/Users/LSDMTHC/Desktop/Hoennto')..'/'
local output=root..'.work/small-window/'
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
  local settings={menuTheme=2};local mod={id='gen3transparency',generation=3,exports={},options={get=function(_,k)return settings[k]end},save={get=function()end},read=function(_,p)return read(root..'.work/move-effects-audit/git-Menu-Customizer/'..p)end,assets={image=function(_,p)return image(root..'.work/move-effects-audit/git-Menu-Customizer/'..p)end}}
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
  local production=read(root..'.work/move-effects-audit/git-KIM1025/kim1025/main.lua')

  local function make(source)
   local env=setmetatable({love=love,mod=kim,menuBattleUi=function()return ui end,
    touchBattleOrientation=function()return dpiX>1 and 'landscape' or nil end,
    mobilePortraitStageRectPx=function()end,battleWorldMetrics=function()end,mobileScreenPositionLiftPx=function()return 0 end,
    battleUiViewportRect=function()return 0,0,width,height end,
    sizedBattleCanvas=function(c,w,h)if not c or c:getWidth()~=w or c:getHeight()~=h then c=G.newCanvas(w,h,{dpiscale=1});c:setFilter('nearest','nearest')end;return c end,
   },{__index=_G})
   return compile(extract(source,'  local function battleHudGeometry(','  -- Native-resolution fullscreen battlers.')..extract(source,'  local function captureBattleHud(','  local function captureBattleText(')..'return drawBattleHud,captureBattleHud,battleHudGeometry',env)
  end
  local drawNew,captureNew,geometry=make(production)
  local function render(fn)
   local c=G.newCanvas(width,height,{dpiscale=dpiX});c:setFilter('nearest','nearest')
   G.push('all');G.setCanvas(c);G.origin();G.clear(0,0,0,0)
   check(fn(battle,{dpiX=dpiX,dpiY=dpiY}),'HUD not drawn');G.pop();return c
  end
  for _,size in ipairs({{480,360,1},{320,288,1},{640,480,1},{960,720,1},{1728,1260,1},{390,844,3}})do
   width,height,dpiX=size[1],size[2],size[3];dpiY=dpiX
   for _,percent in ipairs({60,80,100})do
    kimSettings.battleHudSize=percent
    for _,n in ipairs({'RATTATA','SQUIRTLE','CHARMANDER'})do
     name=n;local c=render(drawNew);local actual=c:newImageData()
     local geo=geometry(width*dpiX,height*dpiY);local hs=geo.hudScale
     local bands={enemy={x=geo.enemyBandX/dpiX,y=(geo.enemyBandY-4*hs)/dpiY,sourceY=0},player={x=geo.playerBandX/dpiX,y=geo.playerBandY/dpiY,sourceY=104},scaleX=hs/dpiX,scaleY=hs/dpiY,dpiX=dpiX,dpiY=dpiY,width=width}
     local queue={entries={{text=name,x=16,y=4,side='enemy'},{text=name,x=160,y=116,side='player'}}}
     ui.hudNames.layout(queue,bands)
     for _,p in ipairs(bands.names)do
      check(p.unit>=2,'readable name minimum lost')
      check(p.y+13*p.unit/dpiY<p.levelY,'name overlaps level')
      local expected=G.newCanvas(width,height,{dpiscale=dpiX})
      G.push('all');G.setCanvas(expected);G.origin();G.clear(0,0,0,0)
      G.translate(math.floor(p.x*dpiX+.5)/dpiX,math.floor(p.y*dpiY+.5)/dpiY);G.scale(p.unit/dpiX,p.unit/dpiY)
      referenceFont.draw(name,0,0,{colors={fg={0,0,0,1},shadow={0,0,0,0},bg={0,0,0,0}}});G.pop()
      local ref=expected:newImageData()
      local x0=math.floor(p.x*dpiX+.5);local y0=math.floor(p.y*dpiY+.5)
      for y=math.max(0,y0),math.min(actual:getHeight()-1,y0+15*p.unit)do
       for x=math.max(0,x0),math.min(actual:getWidth()-1,x0+referenceFont.measure(name)*p.unit-1)do
        local r,g,b,a=ref:getPixel(x,y)
        if a>0 then local rr,gg,bb,aa=actual:getPixel(x,y);check(r==rr and g==gg and b==bb and a==aa,'HUD name pixel mismatch')end
       end
      end
     end
     if width==480 and percent==100 and name=='SQUIRTLE'then write('small-hud.png',actual:encode('png'):getString())end
    end
   end
  end
  write('result.txt','PASS '..checks..' real KIM small-window HUD, level clearance and atlas pixel checks')
 end,debug.traceback)
 if not ok then write('result.txt','FAIL '..err)end
 love.event.quit(ok and 0 or 1)
end
