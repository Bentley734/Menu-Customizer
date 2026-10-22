-- Stat text draws after the complete battle, without suppressing either HUD.
local source=assert(io.open('lib/level_up_panels.lua')):read('*a')
local sx,stack,draws=1,{},{}
local G={push=function()stack[#stack+1]=sx end,pop=function()sx=table.remove(stack)end,translate=function()end,scale=function(x)sx=sx*x end}
local Font={drawBox=function()end,width=function(s)return #s*8 end,draw=function(s)draws[#draws+1]={text=s,scale=sx}end}
G.setScissor=function()end;G.setShader=function()end;G.origin=function()sx=1 end;G.transformPoint=function(x,y)return x*7.25,y*7.25 end
local Box={draw=function()end};local hudCalls=0
local order={}
local Battle={StatBox=Box,drawHUDs=function()hudCalls=hudCalls+1;order[#order+1]='hud' end}
local active=true;local factor=1;local callback;local frames={}
local mod={generation=1,hooks={wrap=function(_,name,fn,priority)assert(name=='render.hud'and priority>20000);callback=fn end},exports={borders={drawPixels=function(x,y,w,h)frames[#frames+1]={x,y,w,h}end,insets=function()return 8,8 end}}}
local ui={fontSizing={factor=function()return factor end},setting=function()return 3 end,backgroundColor=function()return{}end,palette={colors=function()return{}end}}
local font={scope=function(fn)return fn()end,selected={measure=function(s)return #s*12 end,draw=function(s)draws[#draws+1]={text=s,scale=sx}end}}
local env=setmetatable({love={graphics=G},require=function(n)if n=='src.render.Font'then return Font else return Battle end end},{__index=_G})
local api=assert(load(source,'level up text','t',env))()(mod,ui,font,function()end,function(fn)fn()end,function()return active end)
local rows={{'ATTACK','13'},{'DEFENSE','12'},{'SPEED','16'},{'SPECIAL','12'}}
local first
for _,size in ipairs({1,1.5,2})do
 factor=size;draws={}
 api.render(rows,{x=72,y=16,w=88,h=80},function()end)
 assert(#draws==0,'stat text must defer beyond native low-resolution canvas')
 assert(callback(function()return 'native result'end,{}, {width=1160,height=1044})=='native result')
 assert(#draws==8 and draws[1].scale==math.floor(draws[1].scale),'stat font pixels must have a whole final-frame scale')
 local frame=frames[#frames]
 if first then for i=1,4 do assert(first[i]==frame[i],'large text must not resize or move stat frame')end else first=frame end
 callback(function()end,{}, {width=1160,height=1044});assert(#draws==8,'stale stat popup must not draw on subsequent frames')
 assert(sx==1 and #stack==0,'stat drawing restores transform')
end
local top=setmetatable({},Box);local battle={game={stack={top=function()return top end}}}
Battle.drawHUDs(battle);assert(hudCalls==1,'underlying battle HUD stays visible during stats')
battle._kantoInMotionHudCapture=true;Battle.drawHUDs(battle);assert(hudCalls==2,'KIM capture keeps the complete underlying HUD')
top={};Battle.drawHUDs(battle);assert(hudCalls==3,'ordinary battle HUD retained')
top=setmetatable({},Box);order={};draws={}
api.render(rows,{x=72,y=16,w=88,h=80},function()end)
callback(function()Battle.drawHUDs(battle);order[#order+1]=#draws==0 and'before stats'or'after stats'end,{}, {width=1160,height=1044})
assert(order[1]=='hud' and order[2]=='before stats' and #draws==8,'stats overlay the finished HUD instead of clearing it')
active=false;Battle.drawHUDs(battle);assert(hudCalls==5,'disabled customizer retains native HUD')
print('PASS: stat text dialogue scale and complete native/KIM battle HUD beneath stats')
