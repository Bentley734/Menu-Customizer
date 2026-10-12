-- Actual LOVE raster tests through the production Gen 3 menu compositor.
local root=(os.getenv('BATTLE_UI_WORKSPACE') or 'C:/Users/LSDMTHC/Desktop/Hoennto'):gsub('/$','')..'/'
local output=root..'.work/menu-integer-text/'
local cache='C:/Users/LSDMTHC/AppData/Roaming/pokemon-love2d/'
local function read(p)local f=io.open(p,'rb');if not f then return end;local s=f:read('*a');f:close();return s end
local function write(p,s)local f=assert(io.open(p,'wb'));f:write(s);f:close()end
local function compile(s,env)local f=assert(loadstring(s));setfenv(f,env);return f()end
package.path=root..'.tools/engine-0358/?.lua;'..package.path
function love.load()
 local ok,err=xpcall(function()
  local G=love.graphics;local checks=0
  local function check(v,s)checks=checks+1;assert(v,s)end
  local game='emerald';local Blob=require('src.import.CacheBlob')
  local function cached(p)local s=read(cache..game..'/'..p);return s and Blob.decode(p,s)end
  package.loaded['src.import.CacheFs']={readActive=cached,read=cached,readAt=function(p)local s=read(cache..p);return s and Blob.decode(p,s)end}
  local profiles={ruby='rs',sapphire='rs',emerald='emerald'}
  local function fontSpec(version)
   if profiles[version]then return require('src.core.game3.profiles.'..profiles[version]..'.font')end
   return {module='src.ui.game3.frlg_font',widths='data/generated/gba/chrome/fonts/latin_widths.lua',smallWidths='data/generated/gba/chrome/fonts/latin_small_widths.lua'}
  end
  local spec
  package.loaded['src.core.game3.profile']={forSession=function()return{id=game,font=spec}end,active=function()return{id=game}end}
  local GV=require('src.core.GameVersion');GV.set(game)
  local F=require('src.ui.game3.frlg_font');local nativeDraw=F.draw
  local choices={menuTextColor=0,menuTextShadowColor=0,menuTheme=2}
  local mod={generation=3,exports={},options={get=function(_,k)return choices[k]end},save={get=function()end},
   read=function(_,p)return read(root..'MenuCustomizer/'..p)end,
   assets={image=function(_,p)return G.newImage(love.filesystem.newFileData(assert(read(root..'MenuCustomizer/'..p)),p))end}}
  local P=assert(loadstring(mod:read('lib/battle_text_palette.lua')))()(mod)
  local T=assert(loadstring(mod:read('lib/emerald_theme.lua')))()(mod,function()return choices.menuTheme==2 end)
  T.palette=P;T.menuOptions=P.menuOptions;F._menuCustomizerEmerald=T
  local source=mod:read('lib/menu_main.lua'):gsub('\r\n','\n')
  compile(assert(source:match('(  if not FrlgFont%._menuCustomizerEmeraldWrapped then.-)  local originalNativeStartDraw')),setmetatable({FrlgFont=F},{__index=_G}))
  local option={isOpen=function()return true end};local start={};local factor=1;local progress=1;local transition=1
  local fx={scale=function()return factor end,offset=function()return 0,0 end,record=function()end,motion=function(_,x,y)return x,y,1,progress end}
  local env=setmetatable({mod=mod,FrlgFont=F,menuPalette=P,Display={fit=function(ww,hh)local s=math.min(ww/240,hh/160);return s,(ww-240*s)/2,(hh-160*s)/2,nil,nil,s end},
   FX=fx,Option=option,Start=start,Save={},opacityChoices={[1]=100},setting=function(k)return k=='menuTransition' and transition or 1 end,
   Transitions=assert(loadstring(mod:read('lib/menu_transitions.lua')))()}, {__index=_G})
  local drawAt=compile(assert(source:match('(  local canvas\n.-)  Display.present = function'))..'return drawAt',env)
  local function target(ww,hh,dpi,fn)
   local c=G.newCanvas(ww,hh,{dpiscale=dpi});c:setFilter('nearest','nearest')
   G.push('all');G.setCanvas(c);G.origin();G.setScissor();G.setShader();G.clear(0,0,0,0);fn();G.pop();return c
  end
  local function layout(ww,hh,dpi)
   local s=math.min(ww/240,hh/160);local f=math.min(factor,(ww-16)/(240*s),(hh-16)/(160*s))
   local sx,sy=s*f*.94,s*f;return (ww-240*sx)/2,(hh-160*sy)/2,sx,sy,math.max(1,math.floor(math.min(sx,sy)*dpi+.00001))
  end
  local labels={{'TTT RATTATA',24,41},{'4 OPTIONS',120,57},{'BATTLE OPTIONS',24,73}}
  local opts={colors={fg={0,0,0,1},shadow={0,0,0,0},bg={0,0,0,0}}}
  local function textOnly()for _,v in ipairs(labels)do F.draw(v[1],v[2],v[3],{})end end
  local reference=assert(loadstring(mod:read('lib/emerald_theme.lua')))()(mod,function()return true end)
  for _,version in ipairs({'ruby','sapphire','emerald','firered','leafgreen'})do
   game=version;GV.set(game);spec=fontSpec(game);F.invalidate()
   for _,theme in ipairs({1,2})do
    choices.menuTheme=theme
    for _,size in ipairs({{1047,699,1},{1808,1080,1},{2560,1299,1},{5120,1440,1},{390,844,3}})do
     local ww,hh,dpi=unpack(size)
     for _,f in ipairs({.8,1,1.5})do
      factor=f
      local actual=target(ww,hh,dpi,function()drawAt(option,textOnly,8,'optionOpacity',ww,hh)end)
      local x,y,sx,sy,unit=layout(ww,hh,dpi)
      local expected=target(ww,hh,dpi,function()
       for _,v in ipairs(labels)do
        G.push('all');G.translate(math.floor((x+v[2]*sx)*dpi+.5)/dpi,math.floor((y+v[3]*sy)*dpi+.5)/dpi);G.scale(unit/dpi,unit/dpi)
        if theme==2 then reference.draw(v[1],0,0,opts)else nativeDraw(v[1],0,0,opts)end;G.pop()
       end
      end)
      check(actual:newImageData():getString()==expected:newImageData():getString(),version..' font '..theme..' '..ww..'x'..hh..' dpi '..dpi..' size '..f..' has missing or fractional pixels')
      actual:release();expected:release()
     end
    end
   end
  end
  -- Glyph-only arrows and clipped text use the same integer/DPI path.
  local surface=assert(loadstring(mod:read('lib/menu_text_surface.lua')))()(mod,F)
  for _,theme in ipairs({1,2})do
   choices.menuTheme=theme
   local queued=target(240,160,1,function()surface.queue=surface.capture(function()
    G.setScissor(20,40,100,16);F.draw('TTT TTT',24,41,{maxWidth=40,limitChars=6})
    G.setScissor();F.drawGlyph(F.CHAR_SELECTOR_ARROW,16,41,{})
   end)end)
   local c=target(1047,699,1,function()surface.draw(surface.queue,0,0,4.101,4.363,1)end)
   local bounds=c:newImageData();local ink=0
   for yy=0,698 do for xx=0,1046 do local _,_,_,a=bounds:getPixel(xx,yy);if a>0 then ink=ink+1;check(xx<493 and yy>=164 and yy<245,'clipped glyph escaped its pane')end end end
   check(ink>100,'native glyph/text disappeared');c:release();queued:release()
  end
  -- Atlas art and procedural borders must still use the native 240x160 surface.
  factor=1;choices.menuTheme=2;game='emerald';GV.set(game);spec=fontSpec(game);F.invalidate()
  local clock=2;local oldClock=love.timer.getTime;love.timer.getTime=function()return clock end
  local catalog=assert(loadstring(mod:read('lib/border_catalog.lua')))();local borderIndex=64
  mod.exports.menuBackground=function()return P.menuBackground('other')end
  local B=assert(loadstring(mod:read('lib/menu_borders.lua')))()(mod,function(k)return k=='menuBorder'and borderIndex or 2 end,catalog,function()return true end)
  local function art()G.setColor(1,1,1,1);B.drawPixels(8,0,224,32);B.drawPixels(8,32,224,128)end
  for _,id in ipairs({61,62,63,64,65,66,67,68,76})do
   borderIndex=id;local ww,hh=1808,1080;local x,y,sx,sy=layout(ww,hh,1)
   local low=target(240,160,1,art)
   local expected=target(ww,hh,1,function()G.setBlendMode('alpha','premultiplied');G.setColor(1,1,1,1);G.draw(low,x,y,0,sx,sy)end)
   local actual=target(ww,hh,1,function()drawAt(option,art,8,'optionOpacity',ww,hh)end)
   check(actual:newImageData():getString()==expected:newImageData():getString(),'pixelated border changed '..id)
   low:release();expected:release();actual:release()
  end
  -- Render the real Emerald Options screen in both themes, matching the report.
  local function color555(v)v=v or 0;return{(v%32)/31,(math.floor(v/32)%32)/31,(math.floor(v/1024)%32)/31,1}end
  local kit={color555=color555,manifest=function(key)local text=cached('data/generated/gba/'..key..'/manifest.lua');return text and assert(loadstring(text))()end,
   userFrame=function(tx,ty,tw,th)B.drawPixels((tx-1)*8,(ty-1)*8,(tw+2)*8,(th+2)*8)end}
  local modules={['src.ui.game3.stack']={},['src.core.game3.options']={block=function()return{frameType=0}end},['src.ui.game3.option_rows']={},['src.core.game3.rom_text']={plain=function()return'CANCEL'end},
   ['src.ui.game3.frlg_font']=F,['src.ui.game3.chrome']={},['src.ui.game3.rse.scene_kit']=kit,['src.ui.game3.screens']={openFlag=function()return function()return true end end},
   ['src.ui.game3.shaderfx_menu']={isOpen=function()return false end},['src.ui.game3.rse.bag_chrome']={drawArrow=function()end}}
  local real=compile(assert(read(root..'.tools/engine-0358/src/ui/game3/rse/option_menu.lua')),setmetatable({require=function(n)return assert(modules[n],n)end},{__index=_G}))
  real._st.ctx={options={}};real._st.pages={{title='OPTION',rows={{label='SPEED',value=function()return'4 OPTIONS'end},{label='VIDEO',value=function()return'7 OPTIONS'end},
   {label='GRAPHICS',value=function()return'4 OPTIONS'end},{label='AUDIO',value=function()return'4 OPTIONS'end},{label='PERFORMANCE',value=function()return'HIGH'end},
   {label='BATTLE OPTIONS',value=function()return'2 OPTIONS'end},{label='EXTRAS',value=function()return'4 OPTIONS'end}},index=1,scroll=0}}
  env.Option=real;borderIndex=64
  choices.menuTextColor=5;choices.menuBackgroundColor=1
  for _,theme in ipairs({1,2})do
   choices.menuTheme=theme
   local c=target(1808,1080,1,function()drawAt(real,real.draw,8,'optionOpacity',1808,1080)end)
   write(output..'emerald-options-'..theme..'.png',c:newImageData():encode('png'):getString());c:release()
  end
  -- Real compositor retains transitions, graphics target, and state on failure.
  for style=1,9 do transition=style;progress=.5
   local c=target(1047,699,1,function()drawAt(real,real.draw,8,'optionOpacity',1047,699)end)
   check(c:newImageData():getString()~=string.rep('\0',1047*699*4),'empty transition '..style);c:release()
  end
  transition=1;progress=1
  local S=assert(loadstring(mod:read('lib/menu_text_surface.lua')))()(mod,F)
  local beforeDraw,beforeGlyph=F.draw,F.drawGlyph;local depth=G.getStackDepth()
  check(not pcall(S.capture,function()F.draw('TTT',0,0);error('capture probe')end),'capture error swallowed')
  check(F.draw==beforeDraw and F.drawGlyph==beforeGlyph and G.getStackDepth()==depth,'capture state leaked')
  local oldAspect={2,1};mod.exports.fontAspect=oldAspect
  local queue={{draw=function()error('render probe')end,text='TTT',anchor={0,0},horizontal={1,0},vertical={0,1},opts={},clip={},color={1,1,1,1}}}
  check(not pcall(S.draw,queue,0,0,4,4,1),'render error swallowed')
  check(G.getStackDepth()==depth and mod.exports.fontAspect==oldAspect,'render state leaked');mod.exports.fontAspect=nil
  love.timer.getTime=oldClock
  write(output..'result.txt','PASS '..checks..' native/Emerald integer font, DPI, real Options, pixelated border, transition and restoration checks\n')
 end,debug.traceback)
 if not ok then write(output..'result.txt','FAIL '..err)end
 love.event.quit(ok and 0 or 1)
end
