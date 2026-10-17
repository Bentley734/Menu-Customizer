local version,enabled,style='emerald',true,3;local nativeHp,nativeXp=0,0;local rects={}
local C={drawHpBar=function()nativeHp=nativeHp+1 end,drawExpBar=function()nativeXp=nativeXp+1 end,hpColor=function()return'green'end,
 scaledHpFraction=function(hp,max,n)return hp<=0 and 0 or math.max(1,math.floor(hp*n/max))end}
local G={push=function()end,pop=function()end,setShader=function()end,setColor=function()end,rectangle=function(_,x,y,w,h)rects[#rects+1]={x=x,y=y,w=w,h=h}end}
local F={draw=function()end};local env=setmetatable({love={graphics=G},require=function(name)
 if name=='src.core.GameVersion'then return{get=function()return version end}end
 if name=='src.ui.game3.battle_chrome'then return C end
 if name=='src.ui.game3.frlg_font'then return F end
 error(name)
end},{__index=_G})
local mod={exports={},options={get=function()return nil end}};local ui={setting=function()return style end,palette={colors=function()return{}end}}
local f=assert(io.open('lib/emerald_battle_theme.lua'));local source=f:read('*a');f:close()
assert(load(source,'Emerald gauges','t',env))()(mod,ui,function()return enabled end)
for _,hp in ipairs({0,1,50,100})do
 rects={};C.drawHpBar(174,88,hp,100)
 assert(#rects==(hp==0 and 2 or 3),'HP fill visibility')
 for _,r in ipairs(rects)do assert(r.x+r.w<=232,'HP overlaps right border')end
 if hp==1 then assert(rects[3].w==1,'Living HP must retain one pixel')end
end
for _,ratio in ipairs({0,.5,1})do rects={};C.drawExpBar(158,104,ratio);assert(#rects==(ratio==0 and 2 or 3));for _,r in ipairs(rects)do assert(r.y+r.h<=107,'XP overlaps lower border')end end
version='firered';C.drawHpBar(0,0,1,1);C.drawExpBar(0,0,1);assert(nativeHp==1 and nativeXp==1)
version='emerald';style=1;C.drawHpBar(0,0,1,1);assert(nativeHp==2,'Native style changed')
print('PASS Emerald HP/XP fill, minimum HP, panel clearance and native fallback')

