local api=testLoader.exports.gen3transparency;local J=api.jumpWave
assert(J.offset(1,4,.11)==3 and J.offset(2,4,.11)==0)
assert(J.offset(2,4,.33)==3 and J.offset(1,4,.33)==0)
local clock=love.timer.getTime;local tick=0;love.timer.getTime=function()return tick end
local owner={};J.select(owner,1,'CONTINUE');tick=.11
local game={options=testOptions,mods=testLoader,writeOptions=function()end};api.customization.write(game,{textCase=1})
local text,y={},{};local width=J.draw(function(c,x,py)text[#text+1]=api.customization.text(c);y[#y+1]=py end,function()return 8 end,'CONTINUE',10,20)
assert(table.concat(text)=='Continue'and width==64 and y[1]==17 and y[2]==20)
assert(not J.active);assert(not pcall(J.draw,function()error('test')end,function()return 8 end,'A',0,0));assert(not J.active)
love.timer.getTime=clock
print('PASS sequential single-letter hops, spacing, sentence case and error restoration')

api.customization.write(game,{jumpWaveEnabled=1,arrowSelector=2,jumpWaveSpeed=200})
assert(J.enabled()and J.offset(1,4,.055)==3)
assert(api.arrowSelectors==nil or api.arrowSelectors.id()==1,'Jump Wave replaced selected marker')
api.customization.write(game,{jumpWaveEnabled=0});assert(not J.enabled())
api.customization.write(game,{jumpWaveSpeed=50});assert(J.offset(1,4,.22)==3)
print('PASS independent toggle, combined marker and 50%/200% wave speeds')

love.timer.getTime=function()return tick end
api.customization.write(game,{jumpWaveSpeed=100})
tick=10;J.select(owner,2,'SAME');assert(J.started==10)
tick=10.11;J.select(owner,2,'SAME');assert(J.started==10)
J.select(owner,3,'SAME');assert(J.started==10.11,'Duplicate label did not restart on row change')
tick=11;J.select({},3,'SAME');assert(J.started==11,'New page did not restart')
love.timer.getTime=clock
print('PASS selection, duplicate-label and page changes restart wave; redraws preserve phase')
