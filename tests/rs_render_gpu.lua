local w=assert(os.getenv('BATTLE_UI_WORKSPACE'))..'/'
local cache=assert(os.getenv('POKEMON_CACHE_ROOT'))..'/'
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
    write(w..'.work/rs-render-fix/'..version..'-name-'..name..'.png',actual:newImageData():encode('png'):getString())
   end
  end
  local ball=assert(source:match('(  local ballPixels.-)  local function drawStartJustified'))
  local cursor=compile(ball..'return drawBallCursor',setmetatable({FrlgFont=F},{__index=_G}))
  local shader=G.newShader([[vec4 effect(vec4 color,Image tex,vec2 tc,vec2 sc){return vec4(0.0,1.0,0.0,1.0);}]])
  local c=G.newCanvas(24,24);G.setCanvas(c);G.origin();G.clear();G.setShader(shader);cursor(8,4)
  check(G.getShader()==shader,'selector shader not restored');G.setShader();G.setCanvas()
  local rr,gg,bb=c:newImageData():getPixel(10,8)
  check(rr>.8 and gg<.1 and bb<.1,'selector red uses mutable RS palette')
  write(w..'.work/rs-render-fix/selector.png',c:newImageData():encode('png'):getString())
  local option={isOpen=function()return true end};local start={},{}
  local apiSource=assert(source:match('(  local canvas\n.-)  Display.present = function'))
  local fx={scale=function()return 1 end,offset=function()return 0,0 end,record=function()end,motion=function(_,x,y)return x,y,1 end}
  local env=setmetatable({Display={fit=function(ww,hh)local s=math.min(ww/240,hh/160);return s,(ww-240*s)/2,(hh-160*s)/2,nil,nil,s end},FX=fx,Option=option,Start=start,Save={},opacityChoices={[1]=100},setting=function()return 1 end},{__index=_G})
  env.mod=mod;env.FrlgFont=F
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
  write(w..'.work/rs-render-fix/options-transparent.png',d:encode('png'):getString())

  -- Run the actual RS Options draw, including its nested canvas/fade shader.
  local catalog=assert(loadstring(mod:read('lib/border_catalog.lua')))()
  local borders=assert(loadstring(mod:read('lib/menu_borders.lua')))()({generation=1,assets=mod.assets},function(k)return k=='menuBorder'and 6 or 2 end,catalog,function()return true end)
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
   write(w..'.work/rs-render-fix/'..version..'-options.png',dd:encode('png'):getString())
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
   write(w..'.work/rs-render-fix/background-'..ww..'x'..hh..'.png',data:encode('png'):getString())
  end
  write(w..'.work/rs-render-fix/result.txt','PASS '..checks..' Ruby/Sapphire font, palette, transparent options and fullscreen background GPU checks')
 end,debug.traceback)
 if not ok then write(w..'.work/rs-render-fix/result.txt',err)end
 love.event.quit()
end
