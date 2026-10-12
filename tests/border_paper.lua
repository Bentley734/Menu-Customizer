local mask=assert(loadfile('lib/border_paper.lua'))()
local p={};for y=0,23 do for x=0,23 do p[y*24+x+1]={0,.2,.8,1}end end
local function put(x,y,c)p[y*24+x+1]=c end
for y=6,17 do for x=6,17 do put(x,y,{1,1,1,1})end end
put(0,0,{1,1,1,1});put(2,2,{.98,.98,.98,1});put(5,5,{1,1,1,0})
put(6,6,{.84,.84,.81,1})
local data={getDimensions=function()return 24,24 end,getPixel=function(_,x,y)return (unpack or table.unpack)(p[y*24+x+1])end}
local actual=mask(data);local count=0
for y=0,23 do for x=0,23 do
 assert((actual[y*24+x+1] or false)==(x>=6 and x<=17 and y>=6 and y<=17),'paper connectivity')
 if actual[y*24+x+1]then count=count+1 end
end end
assert(count==144,'all inner paper trimmed')
print('PASS 577 interior paper / border highlight checks')
