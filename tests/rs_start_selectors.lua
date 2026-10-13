local f=assert(io.open('lib/menu_main.lua'));local source=f:read('*a');f:close()
local fragment=assert(source:match('(  local function nativeStartUnscoped.-)  local originalStart, originalOption'))
local checks=0
local positions={}
for _,platform in ipairs({"Windows","iOS"})do
for _,version in ipairs({'ruby','sapphire'})do
 for theme=1,2 do for alignment=1,3 do for selector=1,4 do
  local nativeBoxes,arrows,marks,labels=0,0,0,0
  local selectedY
  local shader='indexed';local shaderStack={}
  local G={push=function()shaderStack[#shaderStack+1]=shader end,pop=function()shader=table.remove(shaderStack)end,setShader=function(v)shader=v end,getColor=function()return 1,1,1,1 end,setColor=function()end,rectangle=function(_,x,y)marks=marks+1;selectedY=selectedY or y end}
  local data={window={left=20,top=1,width=8},textX=0,textY=1,rowPitch=16,drawCursor=function()nativeBoxes=nativeBoxes+1 end}
  local Start={_data=data,ENTRIES={{label='POKEDEX'},{label='POKEMON'}},cursor=2,contentTemplate=function()return {left=20,top=1,w=8}end}
  local Window={CURSOR_WIDTH=8,optionHeight=function()return 16 end,template=function(l,t,w)return {left=l,top=t,w=w}end,
   cursorPx=function(x,y)arrows=arrows+1;selectedY=y end,printPx=function()labels=labels+1 end}
  local F={STDPAL={{1,1,1,1},{0,0,0,1},{.5,.5,.5,1},{1,0,0,1}},COLOR={NORMAL={fg={0,0,0,1}}},measure=function(s)return #s*6 end}
  local function native()
   local d=Start._data;local t=Start.contentTemplate()
   for i,e in ipairs(Start.ENTRIES)do
    local y=t.top*8+d.textY+(i-1)*d.rowPitch
    if i==Start.cursor then if d.drawCursor then d.drawCursor(t.left*8,y)else Window.cursorPx(t.left*8,y)end end
    Window.printPx(e.label,t.left*8+d.textX,y)
   end
  end
  local env=setmetatable({mod={exports={}},love={graphics=G,system={getOS=function()return platform end}},Start=Start,Window=Window,FrlgFont=F,Theme={enabled=function()return theme==2 end},
   emeraldLayout={window={left=20,top=1,width=8},textX=8,textY=1,rowPitch=16},active=function()return true end,
   setting=function(k)return k=='startSelector' and selector or alignment end,originalNativeStartDraw=native,unpack=unpack or table.unpack},{__index=_G})
  local run=assert(load(fragment..' return drawStartJustified','rs selectors','t',env))()
  run();assert(shader=='indexed','selector restores inherited palette shader');assert(nativeBoxes==0,version..' bypassed custom selector')
  assert(labels==2 and Start._data==data and data.drawCursor~=nil,'state restored')
  if selector==3 then assert(arrows==1,'arrow rendered')else assert(arrows==0 and marks>0,'custom selector rendered')end
  local key=version..theme..alignment..selector
  if platform=="Windows" then positions[key]=selectedY else assert(selectedY==positions[key],"iOS START selector shares the label anchor");checks=checks+1 end
  checks=checks+3
 end end end
end
end
print('PASS '..checks..' Ruby/Sapphire selector routing, alignment and state checks')
