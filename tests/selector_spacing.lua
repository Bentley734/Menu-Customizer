local function read(p)local f=assert(io.open(p));local s=f:read('*a');f:close();return s end
local x,y,stack,rects=0,0,{},{}
local G={setShader=function()end,setColor=function()end}
function G.push()stack[#stack+1]={x,y}end
function G.pop()x,y=unpack(table.remove(stack))end
function G.translate(a,b)x,y=x+a,y+b end
function G.rectangle(_,a,b,w,h)rects[#rects+1]={x+a,y+b,w,h}end
local gap=0;local style=1
local martGap
local setting=function(k)if k=='martSelectorSpacing'and martGap then return martGap elseif k=='arrowSelector'then return style elseif k:find('Spacing')then return gap elseif k=='selectionHighlight'then return 25 end end
local env=setmetatable({love={graphics=G}},{__index=_G})
local mod={exports={}}
local A=assert(load(read('lib/arrow_selectors.lua'),'selector','t',env))()(mod,{draw=function()G.rectangle('fill',0,0,8,8)end},setting,function()return true end)
local function draw(n,g,opts)style,gap=n,g;rects={};assert(A.draw(50,20,8,opts or{_selectorWidth=30}));assert(#stack==0);return rects end
for n,id in ipairs(A.ids)do
 local base=draw(n,0)
 for g=-4,4 do
  local out=draw(n,g);assert(#out==#base)
  for i,r in ipairs(out)do
   if id==2 then assert(r[1]==base[i][1]and r[2]==base[i][2]+g)
   elseif id==4 then assert(r[1]==base[i][1]+(i==1 and -g or g)and r[2]==base[i][2])
   elseif id~=0 and id~=14 then assert(r[1]==base[i][1]-g and r[2]==base[i][2])
   else assert(r[1]==base[i][1]and r[2]==base[i][2])end
  end
 end
end
local base=draw(1,0,{_startArrow=true})
local out=draw(1,4,{_startArrow=true});assert(out[1][1]==base[1][1]-4)
print('PASS all selector styles across all nine gap values; start arrows, underlines, paired dots and marker-free modes')

mod.exports.menuSurfaces={current='mart'};martGap=0
local baseline=draw(1,-4)[1][1];martGap=3
local first=draw(1,-4);assert(first[1][1]==baseline-3,'Mart uses its independent 3px gap')
mod.exports.menuSurfaces.current='pc'
first=draw(1,-4);assert(first[1][1]==baseline+4,'other menus retain their own gap')
print('PASS Poke Mart spacing is isolated from other menus')
