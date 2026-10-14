local w=assert(os.getenv('BATTLE_UI_WORKSPACE'))..'/'
local a=assert(os.getenv('POKEMON_CACHE_ROOT'))..'/'
local out=assert(os.getenv('HEALTHBOX_FIXTURE'))..'/'
local function read(p)local f=io.open(p,'rb');if not f then return end;local s=f:read('*a');f:close();return s end
local function write(p,s)local f=assert(io.open(out..p,'wb'));f:write(s);f:close()end
package.path=w..'.tools/engine-0358/?.lua;'..w..'.tools/engine-0358/?/init.lua;'..package.path
function love.load()
 local ok,err=xpcall(function()
  local G=love.graphics;local fsread=love.filesystem.read
  love.filesystem.read=function(p)return read(w..'.tools/engine-0358/'..p)or fsread(p)end
  require('src.core.GameVersion').set('emerald')
  local Blob=require('src.import.CacheBlob')
  package.loaded['src.import.CacheFs']={readAt=function(p)local s=read(a..p);return s and Blob.decode(p,s)end}
  local mod={generation=3,exports={},read=function(_,p)return read(w..'MenuCustomizer/'..p)end}
  local port=assert(loadstring(mod:read('lib/emerald_native.lua')))()(mod);assert(port.ready())
  local opacity=50
  local compose=assert(loadstring(mod:read('lib/battle_compositor.lua')))()(G,function()return opacity end)
  local layers=assert(loadstring(mod:read('lib/healthbox_layers.lua')))()(G,mod,function(fn,...)return compose(fn,240,160,0,0,...)end)
  mod.exports.battleUi={healthboxLayers=layers}
  local bg={.1,.3,.6,1}
  for _,gender in ipairs({'M','F'})do
   local b={name='A',mon={gender=gender,level=5,hp=17,maxHp=20},expRatio=.3}
   local function render(alpha,layered)
    opacity=alpha;local c=G.newCanvas(240,160);G.setCanvas(c);G.origin();G.clear(unpack(bg))
    if layered then port.healthbox.draw('player',b)else mod.exports.battleUi=nil;port.healthbox.draw('player',b);mod.exports.battleUi={healthboxLayers=layers}end
    G.setCanvas();return c:newImageData()
   end
   local full=render(100,true);local half=render(50,true);local zero=render(0,true)
   local original=render(100,false)
   assert(full:getString()==original:getString(),'100% changes native healthbox')
   write(gender..'-100.png',full:encode('png'):getString());write(gender..'-50.png',half:encode('png'):getString());write(gender..'-0.png',zero:encode('png'):getString())
   -- HP number paper must blend identically to adjacent panel paper.
   local x,y=180,110
   local r,g,bb=half:getPixel(x,y);local rr,gg,bbb=full:getPixel(x,y)
   assert(math.abs(r-(rr+bg[1])/2)<.015 and math.abs(g-(gg+bg[2])/2)<.015 and math.abs(bb-(bbb+bg[3])/2)<.015,'HP paper opacity')
   local zr,zg,zb=zero:getPixel(x,y);assert(math.abs(zr-bg[1])<.01 and math.abs(zg-bg[2])<.01 and math.abs(zb-bg[3])<.01,'HP paper zero opacity')
   for yy=106,113 do for xx=136,199 do
    local r,g,b=half:getPixel(xx,yy);local fr,fg,fb=full:getPixel(xx,yy)
    assert(math.abs(r-(fr+bg[1])/2)<.015 and math.abs(g-(fg+bg[2])/2)<.015 and math.abs(b-(fb+bg[3])/2)<.015,'EXP strip ignores opacity')
    local r,g,b=zero:getPixel(xx,yy)
    assert(math.abs(r-bg[1])<.01 and math.abs(g-bg[2])<.01 and math.abs(b-bg[3])<.01,'EXP strip remains at zero opacity')
   end end
   -- Removed baked Lv ink must not leave a second symbol beside the name.
   for yy=84,88 do for xx=168,175 do
    local rr,gg,bb=zero:getPixel(xx,yy)
    assert(math.abs(rr-bg[1])<.01 and math.abs(gg-bg[2])<.01 and math.abs(bb-bg[3])<.01,'placeholder artifact at '..xx..','..yy)
   end end
  end
  local raw=assert(package.loaded['src.import.CacheFs'].readAt('emerald/data/generated/gba/pokemon/battle/healthbox_player.rgba'))
  write('sheet.png',love.image.newImageData(128,64,'rgba8',raw):encode('png'):getString())
 end,debug.traceback)
 write('result.txt',ok and 'PASS' or err);love.event.quit(ok and 0 or 1)
end


