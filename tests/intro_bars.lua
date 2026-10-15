-- Standalone regression: run in an isolated Lua environment.
local rectangles={};local hook;local R;local state
local function noop()end
love={graphics={}}
local G=love.graphics;local color={1,1,1,1}
for _,k in ipairs({'push','pop','origin','setShader','setScissor','translate','scale','setBlendMode','clear','draw'})do G[k]=noop end
G.getColor=function()return unpack(color)end;G.setColor=function(...)color={...}end
G.getCanvas=function()return false end;G.newShader=function()return {}end
G.rectangle=function(mode,x,y,w,h)rectangles[#rectangles+1]={x=x,y=y,w=w,h=h}end
local intro={draw=function()G.setColor(0,0,0,1);G.rectangle('fill',0,0,160,32);G.rectangle('fill',0,112,160,32)end}
local renderer={frameRects=function()return R end,endFrame=function()hook(function()end,{ww=1000,wh=800,scale=6,dpiX=1,dpiY=1,ox=20,oy=-32})end}
local modules={['src.render.Renderer']=renderer,['src.ui.IntroMovie']=intro,['src.render.SpriteRenderer']={obpImage=noop},['src.render.Font']={draw=noop,drawCode=noop},['src.render.PaletteFX']={markTrueColor=noop}}
require=function(k)return modules[k]or{}end
local mod={options={get=function()return 0 end},save={get=noop},exports={},hooks={wrap=function(_,name,fn)hook=fn end},read=function()return 'return function()return function()end end'end}
local palette={effects={},paint=function(c,fn,...)return fn(...)end}
assert(loadfile(sourceRoot..'/lib/intro_background.lua'))()(mod,palette,function()return true end)
for _,case in ipairs({{Uy=3,uoy=180},{Uy=6,uoy=0},{Uy=2,uoy=50}})do
 R=case;rectangles={};intro.draw({phase=3});renderer.endFrame(renderer)
 local top,bottom=rectangles[#rectangles-1],rectangles[#rectangles]
 assert(top.h==case.uoy+32*case.Uy,'Top mask used world zoom')
 assert(bottom.y==case.uoy+112*case.Uy,'Bottom mask covered the UI actors')
 assert(bottom.h==800-bottom.y)
end
print('PASS intro bars follow UI actor coordinates at independent world/UI zoom levels')
