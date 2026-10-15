-- Standalone regression: run in an isolated Lua environment.
local rectangles={};local hook;local R;local state
local function noop()end
love={graphics={}}
local G=love.graphics;local color={1,1,1,1}
for _,k in ipairs({'push','pop','origin','setShader','setScissor','translate','scale','setBlendMode','clear','draw'})do G[k]=noop end
G.getColor=function()return unpack(color)end;G.setColor=function(...)color={...}end
G.getCanvas=function()return false end;G.newShader=function()return {}end
G.rectangle=function(mode,x,y,w,h)rectangles[#rectangles+1]={x=x,y=y,w=w,h=h}end
local clip,drawnGengarY,drawnNidoY
local intro={drawFight=function(self)drawnGengarY,drawnNidoY=self.gengarY,self.nidoY;if self.fail then error('test failure')end end,replayObjLayer=function()require('src.render.PaletteFX').markUiSpriteRedraw(false,nil,0,0,{clip={0,32,160,80}})end,draw=function()G.setColor(0,0,0,1);G.rectangle('fill',0,0,160,32);G.rectangle('fill',0,112,160,32)end}
local renderer={frameRects=function()return R end,endFrame=function()hook(function()end,{ww=1000,wh=800,scale=6,dpiX=1,dpiY=1,ox=20,oy=-32})end}
local modules={['src.render.Renderer']=renderer,['src.ui.IntroMovie']=intro,['src.render.SpriteRenderer']={obpImage=noop},['src.render.Font']={draw=noop,drawCode=noop},['src.render.PaletteFX']={markTrueColor=noop,markUiSpriteRedraw=function(_,q,x,y,opts)clip=opts.clip end}}
require=function(k)return modules[k]or{}end
local barMode=0
local mod={options={get=function(_,key)return key=='introBattleBars'and barMode or 0 end},save={get=noop},exports={},hooks={wrap=function(_,name,fn)hook=fn end},read=function()return 'return function()return function()end end'end}
local palette={effects={},paint=function(c,fn,...)return fn(...)end}
assert(loadfile(sourceRoot..'/lib/intro_background.lua'))()(mod,palette,function()return true end)
for _,case in ipairs({{Uy=3,uoy=180},{Uy=6,uoy=0},{Uy=2,uoy=50}})do
 R=case;rectangles={};intro.draw({phase=3});renderer.endFrame(renderer)
 local top,bottom=rectangles[#rectangles-1],rectangles[#rectangles]
 assert(top.h==case.uoy+32*case.Uy,'Top mask used world zoom')
 assert(bottom.y==case.uoy+112*case.Uy,'Bottom mask covered the UI actors')
 assert(bottom.h==800-bottom.y)
end
barMode=1;R={Uy=3,uoy=180};rectangles={};intro.draw({phase=3});renderer.endFrame(renderer)
assert(rectangles[#rectangles-1].h==204 and rectangles[#rectangles].y==588,'Edge bars did not move to 8/136')
barMode=2;rectangles={};intro.draw({phase=3});renderer.endFrame(renderer)
assert(#rectangles==2,'Hidden bars still rendered a cinematic mask')
for mode=0,2 do
 barMode=mode;intro.replayObjLayer({})
 assert(clip[2]==(mode==0 and 32 or mode==1 and 8 or 0))
 assert(clip[4]==(mode==0 and 80 or mode==1 and 128 or 144),'Sprite replay still clipped full sprites')
end
local movie={gengarY=56,nidoY=72,gengarPose=1,gengarFrames={{getHeight=function()return 56 end}}}
for mode=0,2 do
 barMode=mode;intro.drawFight(movie)
 local offset=mode==0 and 0 or mode==1 and 24 or 32
 assert(drawnGengarY==56+offset and drawnNidoY==72+offset,'Intro actors did not move together to their new floor')
 assert(movie.gengarY==56 and movie.nidoY==72,'Drawing modified animation state')
end
movie.fail=true;assert(not pcall(intro.drawFight,movie));assert(movie.gengarY==56 and movie.nidoY==72,'Error leaked actor offset')
print('PASS intro bar modes, sprite clipping, shared floor offset and state restoration')
