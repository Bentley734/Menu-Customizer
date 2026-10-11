local function read(p)local f=assert(io.open(p));local s=f:read('*a');f:close();return s end
local calls,depth,quads={},0,0
local G={push=function()depth=depth+1 end,pop=function()depth=depth-1 end,setShader=function()end,setColor=function()end}
G.newQuad=function(x,y,w,h)quads=quads+1;return {x=x,y=y,w=w,h=h}end
G.draw=function(image,q,x,y,rotation,sx,sy)
 assert(rotation==nil and sx==nil and sy==nil,'border tiles must never be scaled')
 calls[#calls+1]={q=q,x=x,y=y}
end
local selection=2
local catalog=assert(load(read('lib/border_catalog.lua')))()
local mod={generation=1,assets={image=function()return {setFilter=function()end,getDimensions=function()return 24,24 end}end}}
local env=setmetatable({love={graphics=G}},{__index=_G})
local M=assert(load(read('lib/menu_borders.lua'),'borders','t',env))()(mod,function(k)return k=='menuBorder' and selection or 1 end,catalog,function()return true end)
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
for n=2,#catalog.entries do
 selection=n
 for _,size in ipairs({{336,64},{224,64},{112,64},{120,48},{240,48},{129.5,47.25}})do
  local w,h=size[1],size[2];calls={}
  check(M.drawPixels(7,9,w,h),'draws selected border')
  local top=0;local corners={}
  for _,c in ipairs(calls)do
   check(c.q.w<=8 and c.q.h<=8,'tile source size preserved')
   check(c.x>=7 and c.y>=9 and c.x+c.q.w<=7+w+.00001 and c.y+c.q.h<=9+h+.00001,'partial tile clipped inside panel')
   if c.q.x==8 and c.q.y==0 then top=top+1 end
   if (c.q.x==0 or c.q.x==16) and (c.q.y==0 or c.q.y==16) then local key=c.q.x..':'..c.q.y;corners[key]=(corners[key] or 0)+1 end
  end
  check(top==math.ceil((w-16)/8),'top border repeats tiles')
  for _,key in ipairs({'0:0','16:0','0:16','16:16'})do check(corners[key]==1,'one unscaled corner '..key)end
  check(depth==0,'graphics restored')
 end
end
local before=quads;M.drawPixels(7,9,129.5,47.25);check(quads==before,'partial quads reused')
check(not M.drawPixels(0,0,0,48),'zero-width panel skipped')
G.draw=function()error('probe')end
check(not pcall(M.drawPixels,0,0,160,48) and depth==0,'draw errors restore graphics state')
print('PASS '..checks..' tiled border bounds, corner, repetition and state checks')
