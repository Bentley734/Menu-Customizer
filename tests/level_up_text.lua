-- Stat text uses the GB dialogue conversion; HUD capture yields to child stats.
local source=assert(io.open('lib/level_up_panels.lua')):read('*a')
local sx,stack,draws=1,{},{}
local G={push=function()stack[#stack+1]=sx end,pop=function()sx=table.remove(stack)end,translate=function()end,scale=function(x)sx=sx*x end}
local Font={drawBox=function()end,draw=function()end}
local Box={draw=function()end};local hudCalls=0
local Battle={StatBox=Box,drawHUDs=function()hudCalls=hudCalls+1 end}
local active=true
local mod={generation=1,exports={borders={drawPixels=function()end}}}
local ui={fontSizing={factor=function()return 1 end},setting=function()return 3 end,backgroundColor=function()return{}end,palette={colors=function()return{}end}}
local font={scope=function(fn)return fn()end,selected={measure=function(s)return #s*12 end,draw=function(s)draws[#draws+1]={text=s,scale=sx}end}}
local env=setmetatable({love={graphics=G},require=function(n)if n=='src.render.Font'then return Font else return Battle end end},{__index=_G})
local api=assert(load(source,'level up text','t',env))()(mod,ui,font,function()end,function(fn)fn()end,function()return active end)
api.render({{'ATTACK','13'},{'DEFENSE','12'},{'SPEED','16'},{'SPECIAL','12'}},{x=72,y=16,w=88,h=80},function()end)
assert(#draws==8 and math.abs(draws[1].scale-2/3)<1e-6,'GB stats must use dialogue conversion, not oversized 1.5x native font')
assert(sx==1 and #stack==0,'stat drawing restores transform')
local top=setmetatable({},Box);local battle={game={stack={top=function()return top end}}}
Battle.drawHUDs(battle);assert(hudCalls==0,'HUD must not cover stat window')
battle._kantoInMotionHudCapture=true;Battle.drawHUDs(battle);assert(hudCalls==0,'KIM HUD capture must also yield')
top={};Battle.drawHUDs(battle);assert(hudCalls==1,'ordinary battle HUD retained')
top=setmetatable({},Box);active=false;Battle.drawHUDs(battle);assert(hudCalls==2,'disabled customizer retains native HUD')
print('PASS: stat text dialogue scale and native/KIM HUD layering')
