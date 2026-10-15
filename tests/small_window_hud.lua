local source=assert(io.open('lib/battle_hud_names.lua')):read('*a')
local mod={generation=1,exports={},options={}}
local theme={measure=function(s)return #s*6 end,draw=function()end}
local F={_menuCustomizerGB={mod=mod,theme=theme}}
local G={};for _,k in ipairs({'push','pop','origin','setShader','setScissor','translate','scale'})do G[k]=function()end end
local env=setmetatable({love={graphics=G},require=function()return F end},{__index=_G})
local M=assert(load(source,'small HUD','t',env))()(mod,{colors=function()return{}end},function()return true end)
local checks=0
for _,width in ipairs({320,480,640,960,1728})do
 for _,hs in ipairs({.6,1,1.2,1.6,2,2.4,3.2,4,6})do
  for _,name in ipairs({'RATTATA','SQUIRTLE','CHARMANDER','FERALIGATR'})do
   local q={entries={{text=name,x=16,y=4,side='enemy'},{text=name,x=160,y=116,side='player'}}}
   local bands={enemy={x=0,y=-4*hs,sourceY=0},player={x=width-160*hs,y=100,sourceY=104},scaleX=hs,scaleY=hs,dpiX=1,dpiY=1,width=width}
   M.layout(q,bands)
   for _,e in ipairs(bands.names)do
    assert(e.unit>=2 and e.unit==math.floor(e.unit),'small window name must retain readable integer pixels')
    assert(e.y+13*e.unit<=e.levelY-1,'name and shadow must clear level text')
    assert(e.y+2*e.unit>=1,'name must remain visible above HUD')
    assert(e.x>=1 and e.x+#name*6*e.unit<=width-1,'name must remain inside window')
    checks=checks+4
   end
  end
 end
end
print('PASS '..checks..' small-window name size, level clearance and bounds checks')
