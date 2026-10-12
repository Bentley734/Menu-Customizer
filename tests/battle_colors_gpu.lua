local w=(os.getenv('BATTLE_UI_WORKSPACE') or 'C:/Users/LSDMTHC/Desktop/Hoennto'):gsub('/$','')..'/'
local cache='C:/Users/LSDMTHC/AppData/Roaming/pokemon-love2d/'
local function read(p)local f=io.open(p,'rb');if not f then return end;local s=f:read('*a');f:close();return s end
local function write(p,s)local f=assert(io.open(p,'wb'));f:write(s);f:close()end
package.path=w..'.tools/engine-0358/?.lua;'..package.path
function love.load()
 local ok,err=xpcall(function()
  local G=love.graphics;local checks=0
  local function check(v,s)checks=checks+1;assert(v,s)end
  local game='ruby'
  local Blob=require('src.import.CacheBlob')
  local function cached(p)local s=read(cache..game..'/'..p);return s and Blob.decode(p,s)end
  package.loaded['src.import.CacheFs']={readActive=cached,read=cached,readAt=function(p)local s=read(cache..p);return s and Blob.decode(p,s)end}
  local fontSpec=require('src.core.game3.profiles.rs.font')
  package.loaded['src.core.game3.profile']={forSession=function()return {id=game,font=fontSpec}end,active=function()return {id=game}end}
  local GV=require('src.core.GameVersion')
  local F=require('src.ui.game3.frlg_font')
  local originalDraw,originalMeasure,originalGlyph=F.draw,F.measure,F.drawGlyph
  local mod={generation=3,exports={},read=function(_,p)return read(w..'MenuCustomizer/'..p)end,
   assets={image=function(_,p)return G.newImage(love.filesystem.newFileData(assert(read(w..'MenuCustomizer/'..p)),p))end}}
  local theme=assert(loadstring(mod:read('lib/emerald_theme.lua')))()(mod,function()return true end)
  F._menuCustomizerEmerald=theme
  local source=mod:read('lib/menu_main.lua'):gsub('\r\n','\n')
  local function compile(s,env)local f=assert(loadstring(s));setfenv(f,env);return f()end
  local fs=assert(source:match('(  if not FrlgFont%._menuCustomizerEmeraldWrapped then.-)  local originalNativeStartDraw'))
  compile(fs,setmetatable({FrlgFont=F},{__index=_G}))
  local function target(fn)local c=G.newCanvas(128,32,{dpiscale=1});G.push('all');G.setCanvas(c);G.origin();G.clear(1,1,1,1);G.setScissor(0,8,120,8);fn();G.pop();return c end
  for _,version in ipairs({'ruby','sapphire'})do
   game=version;GV.set(game);F.invalidate()
   for _,name in ipairs({'WURMPLE','TORCHIC','ELECTRIKE'})do
    local opts={font='native_4',textMode=0,colors={fg={.29,.29,.29,1},shadow={.84,.84,.81,1},bg={0,0,0,0}}}
    local actual=target(function()F.draw(name,0,0,opts)end)
    local ref=target(function()originalDraw(name,0,0,opts)end)
    check(actual:newImageData():getString()==ref:newImageData():getString(),version..' native healthbox name changed')
    check(F.measure(name,opts)==originalMeasure(name,opts),version..' native widths changed')
    write(w..'.work/retro-menus-fix/'..version..'-name-'..name..'.png',actual:newImageData():encode('png'):getString())
   end
  end
  local ball=assert(source:match('(  local ballPixels.-)  local function drawStartJustified'))
  local cursor=compile(ball..'return drawBallCursor',setmetatable({FrlgFont=F},{__index=_G}))
  local shader=G.newShader([[vec4 effect(vec4 color,Image tex,vec2 tc,vec2 sc){return vec4(0.0,1.0,0.0,1.0);}]])
  local c=G.newCanvas(24,24);G.setCanvas(c);G.origin();G.clear();G.setShader(shader);cursor(8,4)
  check(G.getShader()==shader,'selector shader not restored');G.setShader();G.setCanvas()
  local rr,gg,bb=c:newImageData():getPixel(10,8)
  check(rr>.8 and gg<.1 and bb<.1,'selector red uses mutable RS palette')
  write(w..'.work/retro-menus-fix/selector.png',c:newImageData():encode('png'):getString())
  local option={isOpen=function()return true end};local start={},{}
  local apiSource=assert(source:match('(  local canvas\n.-)  Display.present = function'))
  local fx={scale=function()return 1 end,offset=function()return 0,0 end,record=function()end,motion=function(_,x,y)return x,y,1 end}
  local env=setmetatable({Display={fit=function(ww,hh)local s=math.min(ww/240,hh/160);return s,(ww-240*s)/2,(hh-160*s)/2,nil,nil,s end},FX=fx,Option=option,Start=start,Save={},opacityChoices={[1]=100},setting=function()return 1 end},{__index=_G})
  env.mod=mod;local apiEnv=env
  local drawAt=compile(apiSource..'return drawAt',env)
  local innerCanvas=G.newCanvas(240,160)
  local function rsOptions()
   G.push('all');G.setCanvas(innerCanvas);G.origin();G.clear(0,0,0,1)
   G.setColor(1,1,1,1);G.rectangle('fill',16,8,208,24);G.rectangle('fill',16,40,208,112)
   G.pop();G.setColor(1,1,1,1);G.draw(innerCanvas)
  end
  local result=G.newCanvas(1047,699);G.setCanvas(result);G.origin();G.clear(.2,.5,.2,1);G.setShader(shader)
  drawAt(option,rsOptions,8,'optionOpacity',1047,699)
  G.setShader();G.setCanvas()
  local d=result:newImageData();local r,g,b=d:getPixel(50,400)
  check(math.abs(r-.2)<.01 and math.abs(g-.5)<.01,'options side pixels cover field')
  write(w..'.work/retro-menus-fix/options-transparent.png',d:encode('png'):getString())

  -- Run the actual RS Options draw, including its nested canvas/fade shader.
  local catalog=assert(loadstring(mod:read('lib/border_catalog.lua')))()
  local borders=assert(loadstring(mod:read('lib/menu_borders.lua')))()({generation=1,assets=mod.assets,exports=mod.exports,read=mod.read},function(k)return k=='menuBorder'and 6 or 2 end,catalog,function()return true end)
  local function color555(v)v=v or 0;return{(v%32)/31,(math.floor(v/32)%32)/31,(math.floor(v/1024)%32)/31,1}end
  local kit={color555=color555,manifest=function(key)local text=cached('data/generated/gba/'..key..'/manifest.lua');return text and assert(loadstring(text))()end}
  local modules={['src.ui.game3.stack']={},['src.core.game3.options']={},['src.core.game3.profile']=package.loaded['src.core.game3.profile'],
   ['src.ui.game3.frlg_font']=F,['src.core.game3.pal_fade']={},['src.ui.game3.rse.scene_kit']=kit,['src.ui.game3.option_rows']={},
   ['src.ui.game3.shaderfx_menu']={isOpen=function()return false end},['src.ui.game3.chrome']={userFrame=function(_,tx,ty,tw,th)borders.drawPixels((tx-1)*8,(ty-1)*8,(tw+2)*8,(th+2)*8)end}}
  for _,version in ipairs({'ruby','sapphire'})do
   game=version;GV.set(game);F.invalidate()
   local rs=compile(assert(read(w..'.tools/engine-0358/src/ui/game3/rs/option_menu.lua')),setmetatable({require=function(n)return assert(modules[n],n)end},{__index=_G}))
   rs.open=true;rs._state='input';rs._pal={slots={[0]={y=0}}};rs._pending={frameType=0};rs._k=0
   rs._data=assert(kit.manifest('rse/menus')).option
   rs._pages={{title='OPTION',top=false,rows={{label='SPEED',value=function()return '4 OPTIONS'end},{label='VIDEO',value=function()return '7 OPTIONS'end},{label='GRAPHICS',value=function()return '4 OPTIONS'end},{label='AUDIO',value=function()return '3 OPTIONS'end},{label='EXTRAS',value=function()return 'OPEN'end}},index=1,scroll=0}}
   env.Option=rs
   local out=G.newCanvas(1047,699);G.setCanvas(out);G.origin();G.clear(.2,.5,.2,1)
   drawAt(rs,rs.draw,8,'optionOpacity',1047,699);G.setCanvas()
   local dd=out:newImageData();local r,g,b=dd:getPixel(50,400)
   check(math.abs(r-.2)<.01 and math.abs(g-.5)<.01,version..' real Options still has side bars')
   write(w..'.work/retro-menus-fix/'..version..'-options.png',dd:encode('png'):getString())
  end
  local kim=assert(read(w..'.work/latest-sprite-fix/current-source/kim1025/lib/gen3_frlg.lua'))
  local a=assert(kim:find('  local FRLG_PLATFORM_PLAYER',1,true));local b=assert(kim:find('  -- Game3 renders the FRLG battle into',a,true))
  local router=assert(loadstring(assert(read(w..'.work/latest-sprite-fix/current-source/kim1025/data/hd_battle_backgrounds.lua'))))()
  local draw,geometry=compile(kim:sub(a,b-1)..'return drawFrlgHdBackground,frlgHdGeometry',setmetatable({hdArenaRouter=router,packagedBackgroundFrames={}},{__index=_G}))
  local arena=G.newImage(love.filesystem.newFileData(assert(read(cache..'mod_cache/kim1025/kim_assets/files/assets/battle/backgrounds/hd/grass_day.png')),'grass.png'))
  local geo=assert(geometry({file='grass_day'}))
  for _,size in ipairs({{1047,699},{1920,1080},{5120,1440},{390,844}})do
   local ww,hh=size[1],size[2];local s=math.min(ww/240,hh/160);local ox,oy=(ww-240*s)/2,(hh-160*s)/2
   local canvas=G.newCanvas(ww,hh);G.setCanvas(canvas);G.origin();G.clear(.92,.94,.96,1)
   check(draw(arena,ox,oy,s,s,geo,{x=0,y=0,w=ww,h=hh}),'HD background unavailable');G.setCanvas()
   local data=canvas:newImageData()
   for _,pos in ipairs({{0,0},{ww-1,0},{0,hh-1},{ww-1,hh-1}})do local r,g,b,a=data:getPixel(pos[1],pos[2]);check(a==1 and (math.abs(r-.92)>.005 or math.abs(g-.94)>.005 or math.abs(b-.96)>.005),'HD frame still visible at edge')end
   write(w..'.work/retro-menus-fix/background-'..ww..'x'..hh..'.png',data:encode('png'):getString())
  end

  -- Exercise the actual selector with canonical art present, then resize.
  local aspect=assert(loadstring(assert(read(w..'.work/latest-sprite-fix/current-source/kim1025/data/aspect_battle_backgrounds.lua'))))()
  local frames,loaded={},{}
  local function atlas(p)
    if not loaded[p] then
      local bytes=read(cache..'mod_cache/kim1025/kim1025_assets/files/'..p) or read(cache..'mod_cache/kim1025/kim_assets/files/'..p)
      if bytes then loaded[p]=G.newImage(love.filesystem.newFileData(bytes,p))end
    end
    return loaded[p]
  end
  local ww,hh=1920,1080
  local env=setmetatable({frlgBackdrop=function()return {file='grass_day'}end,hdBgImageCache={},aspectArena=aspect,
    atlas=atlas,packagedBackgroundFrames=frames,hdArenaRouter=router,
    love={graphics={getDimensions=function()return ww,hh end}}},{__index=_G})
  local start=assert(kim:find('  local function frlgBackdropImage',1,true))
  local get=compile(kim:sub(start,b-1)..'return frlgBackdropImage',env)
  local drawExtended,geoExtended=compile(kim:sub(a,b-1)..'return drawFrlgHdBackground,frlgHdGeometry',setmetatable({hdArenaRouter=router,packagedBackgroundFrames=frames},{__index=_G}))
  for _,size in ipairs({{1920,1080},{5120,1440},{1047,699}})do
    ww,hh=size[1],size[2]
    local selected=get({},{});check(selected==atlas(aspect.path('grass_day',ww,hh)),'canonical art overrides extension')
    check(frames[selected]==aspect.frame(ww,hh),'resize frame metadata')
    local s=math.min(ww/240,hh/160);local c=G.newCanvas(ww,hh)
    G.setCanvas(c);G.origin();G.clear(1,0,1,1)
    drawExtended(selected,(ww-240*s)/2,(hh-160*s)/2,s,s,geoExtended({file='grass_day'}),{x=0,y=0,w=ww,h=hh});G.setCanvas()
    local d=c:newImageData()
    for _,p in ipairs({{0,0},{ww-1,0},{0,hh-1},{ww-1,hh-1}})do local rr,gg,bb,aa=d:getPixel(p[1],p[2]);check(aa==1 and gg>0,'extension does not fill viewport')end
    write(w..'.work/retro-menus-fix/extended-'..ww..'x'..hh..'.png',d:encode('png'):getString())
  end
  local Align=assert(loadstring(assert(read(w..'.work/latest-sprite-fix/current-source/kim1025/lib/gen3_trainer_align.lua'))))()
  local P=require('src.core.game3.trainer_pic')
  for _,version in ipairs({'ruby','sapphire','emerald','firered','leafgreen'})do
    game=version;P.install({read=function(_,p)return cached(p)end})
    for gender=0,1 do
      local e=assert(P.back(gender),version..' trainer cache missing')
      for frame=0,e.frames-1 do
        local q=G.newQuad(0,frame*64,64,64,e.w,e.h)
        local c=G.newCanvas(240,160);G.setCanvas(c);G.origin();G.clear()
        Align.scope(function()G.setColor(1,1,1,1);G.draw(e.image,q,48,48)end)
        check(G.getCanvas()==c,'trainer readback lost native battle target');G.setCanvas()
        local d=c:newImageData();local bottom=0
        for yy=159,0,-1 do for xx=0,239 do if select(4,d:getPixel(xx,yy))>0 then bottom=yy+1;break end end;if bottom>0 then break end end
        check(bottom==115,version..' trainer visible base is '..bottom)
      end
    end
  end
  game='ruby';F.invalidate()
  local palette=assert(loadstring(assert(read(w..'MenuCustomizer/lib/battle_text_palette.lua'))))()({options={get=function()end},save={get=function()end}})
  local c=G.newCanvas(240,160);G.setCanvas(c);G.origin();G.clear(1,1,1,1)
  palette.scope(function()F.draw('Wild '..string.char(252,1,1)..'ZIGZAGOON appeared!',8,120,{colors={fg={1,1,1,1},shadow={.5,.5,.5,1}}})end);G.setCanvas()
  local d=c:newImageData();local black=0
  for yy=112,159 do for xx=0,239 do local rr,gg,bb=d:getPixel(xx,yy);if rr<.01 and gg<.01 and bb<.01 then black=black+1 end end end
  check(black>30,'Ruby dialogue still white');write(w..'.work/retro-menus-fix/black-dialogue.png',d:encode('png'):getString())

  local choices={battle_text_color=2,menuTextColor=4,battle_background_color=1}
  local colourMod={options={get=function(_,k)return choices[k]end},save={get=function()end},exports={},
    assets=mod.assets,read=mod.read}
  local Palette=assert(loadstring(colourMod:read('lib/battle_text_palette.lua')))()(colourMod)
  -- Install the actual production dialogue hook, independently of Ui.draw.
  local Message={open=true,_frame='battle',_revealed=100,currentPage=function()return 'Wild HOOTHOOT appeared!'end}
  local messageSource=assert(read(w..'.tools/engine-0358/src/ui/game3/message.lua'))
  local ds=assert(messageSource:find('function Message.drawText()',1,true))
  compile(messageSource:sub(ds),setmetatable({Message=Message,rsPrinter=function()end,FrlgFont=F,
    Chrome={arrowSpec=function()end},Display={TILE=8}},{__index=_G}))
  local ui=assert(colourMod:read('lib/battle_ui.lua'))
  local hook=assert(ui:match("(    local Message=require%('src.ui.game3.message'%).-)%s+local C = require"))
  compile(hook,setmetatable({require=function(n)if n=='src.ui.game3.message'then return Message end;return require(n)end,
    enabled=function()return true end,textPalette=Palette,battleFont={scope=function(f,...)return f(...)end}},{__index=_G}))
  local c=G.newCanvas(240,160);G.setCanvas(c);G.origin();G.clear(1,1,1,1);Message.drawText();G.setCanvas()
  local data=c:newImageData();local blue=0
  for yy=112,159 do for xx=0,239 do local rr,gg,bb=data:getPixel(xx,yy);if bb>.45 and rr<.15 and gg<.3 then blue=blue+1 end end end
  check(blue>30,'actual dialogue bypasses chosen colour');write(w..'.work/retro-menus-fix/blue-dialogue.png',data:encode('png'):getString())
  -- Real RS printer retains native glyph metrics but changes its opaque ink.
  local RS=require('src.ui.game3.rs.field_auto_scroll_message')
  local state=RS.prepare({fieldWindow={template='gMenuTextWindowTemplate',fontNum=3,textMode=2,left=2,top=15,lineLength=26,autoScroll=true},nativeBytes={187,188,189,255},text='ABC'})
  RS.open(state);for i=1,50 do RS.tick()end
  choices.battle_text_color=6
  G.setCanvas(c);G.origin();G.clear(0,0,0,1);Palette.scope(RS.drawText);G.setCanvas()
  data=c:newImageData();local white=0
  for yy=120,135 do for xx=16,223 do local rr,gg,bb=data:getPixel(xx,yy);if rr>.99 and gg>.99 and bb>.99 then white=white+1 end end end
  check(white>10 and white<1000,'RS native glyphs/paper bypass colour settings');RS.close()
  write(w..'.work/retro-menus-fix/native-white-on-black.png',data:encode('png'):getString())
  local borderSource=assert(colourMod:read('lib/menu_borders.lua'))
  local border=assert(loadstring(borderSource))()(colourMod,function(k)return k=='menuBorder' and 6 or k=='menuTheme' and 2 or 0 end,catalog,function()return true end)
  colourMod.exports.battleUi={backgroundColor=function()return Palette.background()end}
  local base=G.newCanvas(240,160);G.setCanvas(base);G.origin();G.clear();border.drawPixels(0,112,240,48);G.setCanvas()
  G.setCanvas(c);G.origin();G.clear();border.drawBattlePixels(0,112,240,48);G.setCanvas()
  local reference=base:newImageData();data=c:newImageData()
  local rr,gg,bb=data:getPixel(120,135);check(rr==0 and gg==0 and bb==0,'black battle interior')
  for yy=112,159 do for xx=0,239 do
    if xx<8 or xx>=232 or yy<120 or yy>=152 then
      local r1,g1,b1,a1=reference:getPixel(xx,yy);local r2,g2,b2,a2=data:getPixel(xx,yy)
      if math.min(r1,g1,b1)<=.75 or math.max(r1,g1,b1)-math.min(r1,g1,b1)>=.05 or a1==0 then check(r1==r2 and g1==g2 and b1==b2 and a1==a2,'paper mask changes coloured border pixels')end
    end
  end end
  G.setCanvas(c);G.setColor(1,1,1,1);Palette.scope(function()F.draw('Wild HOOTHOOT appeared!',10,122,{})end);G.setCanvas()
  write(w..'.work/retro-menus-fix/black-battle-box.png',c:newImageData():encode('png'):getString())
  choices.battle_text_color=0
  G.setCanvas(c);G.origin();G.clear(1,1,1,1);Palette.menuScope(function()F.draw('OPTIONS',16,20,{})end);G.setCanvas()
  data=c:newImageData();local red=0
  for yy=20,35 do for xx=0,239 do local rr,gg,bb=data:getPixel(xx,yy);if rr>.5 and gg<.1 and bb<.1 then red=red+1 end end end
  check(red>10,'menu colour is not independent');check(Palette.colors().fg[1]==0,'menu overwrote battle choice')

  -- Prove that the inner rim joins the chosen paper, rather than remaining white.
  local referenceData=base:newImageData();local blackData=c:newImageData();local removed=0
  for yy=112,159 do for xx=0,239 do
    if xx<8 or xx>=232 or yy<120 or yy>=152 then
      local r1,g1,b1,a1=referenceData:getPixel(xx,yy);local r2,g2,b2,a2=blackData:getPixel(xx,yy)
      if math.min(r1,g1,b1)>.97 and a1>0 and r2==0 and g2==0 and b2==0 and a2>0 then removed=removed+1 end
    end
  end end
  -- c was reused for menu text above, so render the border anew.
  G.setCanvas(c);G.origin();G.clear();border.drawBattlePixels(0,112,240,48);G.setCanvas()
  blackData=c:newImageData();removed=0
  for yy=112,159 do for xx=0,239 do
    if xx<8 or xx>=232 or yy<120 or yy>=152 then
      local r1,g1,b1,a1=referenceData:getPixel(xx,yy);local r2,g2,b2,a2=blackData:getPixel(xx,yy)
      if math.min(r1,g1,b1)>.97 and a1>0 and r2==0 and g2==0 and b2==0 and a2>0 then removed=removed+1 end
    end
  end end
  check(removed>100,'white inner rim remains')
  choices.battle_text_color=6;choices.battle_shadow_color=7
  G.setCanvas(c);G.origin();Palette.scope(function()F.draw('Wild HOOTHOOT appeared!',10,122,{})end);G.setCanvas()
  local colored=c:newImageData();local redShadow=0
  for yy=120,150 do for xx=8,231 do local rr,gg,bb=colored:getPixel(xx,yy);if rr>.5 and gg<.1 and bb<.1 then redShadow=redShadow+1 end end end
  check(redShadow>10,'battle shadow colour ignored')
  write(w..'.work/retro-menus-fix/black-box-red-shadow.png',colored:encode('png'):getString())
  choices.menuTextColor=6;choices.menuTextShadowColor=5
  G.setCanvas(c);G.origin();G.clear(0,0,0,1);Palette.menuScope(function()F.draw('OPTIONS',16,20,{})end);G.setCanvas()
  colored=c:newImageData();local blueShadow=0
  for yy=20,40 do for xx=0,239 do local rr,gg,bb=colored:getPixel(xx,yy);if bb>.45 and rr<.15 and gg<.3 then blueShadow=blueShadow+1 end end end
  check(blueShadow>10,'independent menu shadow ignored')
  local png=assert(Blob.decode('assets/generated/fonts/font.png',assert(read(cache..'red/assets/generated/fonts/font.png'))))
  local nativeImage=G.newImage(love.filesystem.newFileData(png,'font.png'))
  local q=G.newQuad(0,0,8,8,nativeImage:getDimensions())
  G.setCanvas(c);G.origin();G.clear(0,0,0,1)
  Palette.nativeMenuGlyph(function(_,x,y)G.draw(nativeImage,q,x,y)end,0x80,16,20)
  G.setCanvas();colored=c:newImageData();blueShadow=0
  for yy=20,40 do for xx=0,239 do local rr,gg,bb=colored:getPixel(xx,yy);if bb>.45 and rr<.15 and gg<.3 then blueShadow=blueShadow+1 end end end
  check(blueShadow>0,'native GB menu shadow ignored')
  choices.menuTextShadowColor=0
  G.setCanvas(c);G.origin();G.clear(0,0,0,1);Palette.nativeMenuGlyph(function(_,x,y)G.draw(nativeImage,q,x,y)end,0x80,16,20);G.setCanvas()
  colored=c:newImageData();blueShadow=0
  for yy=20,40 do for xx=0,239 do local rr,gg,bb=colored:getPixel(xx,yy);if bb>.45 and rr<.15 and gg<.3 then blueShadow=blueShadow+1 end end end
  check(blueShadow==0,'None leaves native shadow pixels')

  choices.battle_name_color=4;choices.battle_name_shadow_color=8
  choices.battle_text_color=2;choices.battle_shadow_color=0
  local hbSource=assert(read(w..'.tools/engine-0358/src/core/game3/battle/healthbox.lua'))
  local ra=assert(hbSource:find('local function draw_rs_row',1,true))
  local rb=assert(hbSource:find('local function healthbox_gender',ra,true))
  local na=assert(hbSource:find('local function draw_name_gender',1,true))
  local nb=assert(hbSource:find('-- pokefirered/src/battle_interface.c:759',na,true))
  local nativeColors={fg={.3,.3,.3,1},shadow={.8,.8,.8,1},bg={1,1,1,1}}
  local nameDraw=compile(hbSource:sub(ra,rb-1)..hbSource:sub(na,nb-1)..'return draw_name_gender',setmetatable({FrlgFont=F,
    rs_layout=function()return true end,TEXT_Y=3,rs_text_colors=function(gender)return gender and F.COLOR.MALE or nativeColors end,
    BattleChrome={drawElementTile=function()end},small_opts=function(colors)return {small=true,colors=colors}end},{__index=_G}))
  local uiSource=assert(colourMod:read('lib/battle_ui.lua'))
  local wrapper=assert(uiSource:match("(    local Healthbox=require%('src.core.game3.battle.healthbox'%).-)%s+local Message=require"))
  for _,version in ipairs({'ruby','sapphire'})do
    game=version;GV.set(game);F.invalidate()
    for _,nickname in ipairs({'TORCHIC','5'})do
      local H={draw=function()
        nameDraw(nickname,'M',16,3)
        F.draw('5',88,0,{font='native_4',textMode=0,colors=nativeColors})
        F.draw('19/19',80,24,{font='native_4',textMode=0,colors=nativeColors})
      end}
      local ref=G.newCanvas(128,48);G.setCanvas(ref);G.origin();G.clear(1,1,1,1);H.draw();G.setCanvas()
      compile(wrapper,setmetatable({require=function(n)if n=='src.core.game3.battle.healthbox'then return H elseif n=='src.core.game3.battle'then return {_st={}}end;return require(n)end,
        enabled=function()return true end,textPalette=Palette},{__index=_G}))
      local actual=G.newCanvas(128,48);G.setCanvas(actual);G.origin();G.clear(1,1,1,1);H.draw('player');G.setCanvas()
      local ad,rd=actual:newImageData(),ref:newImageData();local red=0
      for yy=0,47 do for xx=0,127 do
        local r1,g1,b1,a1=rd:getPixel(xx,yy);local r2,g2,b2,a2=ad:getPixel(xx,yy)
        if xx>=16 and xx<72 and yy>=8 and yy<16 then
          if r2>.5 and g2<.1 and b2<.1 then red=red+1 end
        else check(r1==r2 and g1==g2 and b1==b2 and a1==a2,version..' name colour alters levels or HP')end
      end end
      check(red>0,version..' name colour missing for '..nickname)
      write(w..'.work/retro-menus-fix/'..version..'-name-'..nickname..'.png',ad:encode('png'):getString())
    end
  end
  choices.menuTextColor=3
  G.setCanvas(c);G.origin();G.clear(0,0,0,1)
  Palette.nativeNameGlyph(function(_,x,y)G.draw(nativeImage,q,x,y)end,0x80,16,20);G.setCanvas()
  local d=c:newImageData();local red=0
  for yy=20,35 do for xx=16,30 do local rr,gg,bb=d:getPixel(xx,yy);if rr>.5 and gg<.1 and bb<.1 then red=red+1 end end end
  check(red>0,'native GB name colour inherits menu colour')

  local T=assert(loadstring(colourMod:read('lib/menu_transitions.lua')))()
  choices.menuBackgroundColor=2;choices.startMenuBackgroundColor=10
  choices.menuTextColor=6;choices.menuTextShadowColor=0
  local bgKind='start'
  colourMod.exports.menuBackground=function()return Palette.menuBackground(bgKind)end
  mod.exports.menuBackground=colourMod.exports.menuBackground
  G.setCanvas(c);G.origin();G.clear(0,0,0,0);border.draw(1,1,20,10);G.setCanvas()
  local startData=c:newImageData();local r1,g1,b1=startData:getPixel(80,40)
  check(math.abs(r1-.4)<.01 and math.abs(g1-.7)<.01 and b1==1,'start light blue paper missing')
  bgKind='other';G.setCanvas(c);G.origin();G.clear(0,0,0,0);border.draw(1,1,20,10);G.setCanvas()
  local menuData=c:newImageData();local rr,gg,bb=menuData:getPixel(80,40)
  check(rr==0 and gg==0 and bb==0,'general menu background not independent')
  local env=apiEnv;env.menuPalette=Palette;env.Transitions=T
  local style,progress=1,1
  env.setting=function(k)return k=='menuTransition' and style or 1 end
  fx.motion=function(_,x,y)return x,y,1,progress end
  env.mod=colourMod
  local baseline
  local grid=G.newCanvas(960,780);G.setCanvas(grid);G.clear(.07,.07,.1,1);G.setCanvas()
  for st=1,#T.names do
    style=st;progress=1
    local target=G.newCanvas(1047,699);G.setCanvas(target);G.origin();G.clear(.2,.5,.2,1)
    drawAt(env.Option,env.Option.draw,8,'optionOpacity',1047,699);G.setCanvas()
    local bytes=target:newImageData():getString()
    baseline=baseline or bytes;check(bytes==baseline,'transition changes settled layout '..st)
    if st==1 then
      local d=target:newImageData();local rr,gg,bb=d:getPixel(512,400)
      check(rr==0 and gg==0 and bb==0,'real RS menu paper not black')
      local ink=0
      for yy=100,550 do for xx=180,800 do local r,g,b=d:getPixel(xx,yy);if math.min(r,g,b)>.3 and math.max(r,g,b)-math.min(r,g,b)<.02 then ink=ink+1 end end end
      check(ink>50,'white menu text missing on black')
      write(w..'.work/retro-menus-fix/black-options.png',d:encode('png'):getString())
    end
    if st>=4 then
      progress=.5;G.setCanvas(target);G.origin();G.clear(.2,.5,.2,1)
      drawAt(env.Option,env.Option.draw,8,'optionOpacity',1047,699);G.setCanvas()
      check(target:newImageData():getString()~=baseline,'retro transition has no mid-animation effect '..st)
      G.setCanvas(grid);G.origin();G.setShader();G.setColor(1,1,1,1)
      local slot=st-4;local x=slot%2*480;local y=math.floor(slot/2)*260
      G.draw(target,x,y+25,0,480/1047,230/699);G.print(T.names[st],x+12,y+5);G.setCanvas()
    end
  end
  write(w..'.work/retro-menus-fix/transitions.png',grid:newImageData():encode('png'):getString())
  local uiText=assert(colourMod:read('lib/battle_ui.lua'))
  local start=assert(uiText:find('    local function drawGen3Panels',1,true));local ending=assert(uiText:find('    mod.exports.drawGen3Panels',start,true))
  colourMod.exports.battleUi={backgroundColor=function()return Palette.background()end}
  colourMod.exports.menuBackground=function()end;mod.exports.menuBackground=function()end
  local panes=0
  local B={drawBattlePixels=function(...)panes=panes+1;return border.drawBattlePixels(...)end}
  local own=compile(uiText:sub(start,ending-1)..'return drawGen3Panels',setmetatable({mod={exports={borders=B}},
    setting=function(k,d)return k=='style' and 2 or d end,placed=function(f)return f()end,faded=function(f)return f()end},{__index=_G}))
  for _,mode in ipairs({'menu','moves','none'})do
    panes=0;G.setCanvas(c);G.origin();G.clear();own(mode);G.setCanvas()
    check(panes==(mode=='none' and 1 or 2),'Emerald duplicate panel owner')
    write(w..'.work/retro-menus-fix/emerald-'..mode..'.png',c:newImageData():encode('png'):getString())
  end
  write(w..'.work/retro-menus-fix/result.txt','PASS '..checks..' Ruby/Sapphire font, palette, transparent options and fullscreen background GPU checks')
 end,debug.traceback)
 if not ok then write(w..'.work/retro-menus-fix/result.txt',err)end
 love.event.quit()
end
