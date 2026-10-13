unpack=table.unpack
local root=arg and arg[1] or '.'
local function path(p)return root..'/'..p end
local function read(p)local f=assert(io.open(p));local s=f:read('*a');f:close();return s end
local checks=0
local function check(ok,msg)checks=checks+1;assert(ok,msg)end
local Levels=assert(loadfile(path('lib/level_text.lua')))()
for _,n in ipairs({1,8,28,99,100})do
 check(Levels.normalize('{LV_2}'..n)=='Lv'..n,'level tag resolves to real text')
 check(Levels.normalize('<LV_2>'..n)=='Lv'..n,'angle-tag level resolves')
end
check(Levels.normalize('LV_2')=='LV_2','literal nickname stays unchanged')
local source=read(path('lib/menu_main.lua'))
local fragment=assert(source:match('(  if not FrlgFont%._menuCustomizerEmeraldWrapped then.-FrlgFont%._menuCustomizerEmeraldWrapped=true\n  end)'))
local themed=false;local drawn,measured
local F={CHAR_SELECTOR_ARROW=0xEF,draw=function(text,x,y,opts)drawn=text;return 1,x+#text*5,y end,measure=function(text)measured=text;return #text*5 end,drawGlyph=function()end}
F._menuCustomizerEmerald={enabled=function()return themed end,draw=F.draw,measure=F.measure,glyph=function()return true end}
local mod={exports={arrowSelectors={draw=function()return false end}}}
assert(load(fragment,'level renderer','t',setmetatable({FrlgFont=F,mod=mod,LevelText=Levels},{__index=_G})))()
for _,mode in ipairs({false,true})do themed=mode
 for _,small in ipairs({false,true})do for _,n in ipairs({1,28,100})do
  local text='{LV_2}'..n;local opts={small=small,maxWidth=32}
  F.draw(text,0,0,opts);local width=F.measure(text,opts)
  check(drawn=='Lv'..n and measured==drawn,'draw and measurement use the same complete level')
  check(width<=32,'levels through 100 fit the party column')
 end end
end
-- Every selector uses all original source pixels at an integer 1:1 scale.
local calls={};local tx,ty=0,0;local stack={}
local G={}
function G.push()stack[#stack+1]={tx,ty}end
function G.pop()local p=table.remove(stack);tx,ty=p[1],p[2]end
function G.translate(x,y)tx=tx+x;ty=ty+y end
function G.setShader()end
function G.setColor()end
function G.rectangle(_,x,y,w,h)calls[#calls+1]={tx+x,ty+y,w,h}end
love={graphics=G}
local icons=assert(loadfile(path('lib/menu_selectors.lua')))()
local choice=2
local api=assert(loadfile(path('lib/arrow_selectors.lua')))()(mod,icons,function()return choice end,function()return true end)
for id=3,10 do choice=id
 calls={};icons.draw(api.id(),0,0);local original=calls
 calls={};api.draw(20,30,8)
 check(#calls==#original,'no source pixels omitted')
 for i,p in ipairs(calls)do
  check(p[1]-20==original[i][1] and p[2]-30==original[i][2],'source shape preserved')
  check(p[3]==1 and p[4]==1 and p[1]%1==0 and p[2]%1==0,'integer pixel geometry')
 end
end
choice=2;calls={};api.draw(8,8,8)
local a,b,c,d=math.huge,math.huge,-math.huge,-math.huge
for _,p in ipairs(calls)do a=math.min(a,p[1]);b=math.min(b,p[2]);c=math.max(c,p[1]);d=math.max(d,p[2])end
check(a==8 and b==8 and c==15 and d==15,'full 8x8 ball in native category row')
check((b+d)/2==8+7*.5,'native category selector centers on half-size letter ink')
mod.exports.startSelectorScope=true;calls={};check(not api.draw(8,8,8)and #calls==0,'START remains independent')
print('PASS '..checks..' selector pixel/position and Pokemon level draw/measurement checks. No artwork or preset tests run.')
