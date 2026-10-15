local api=testLoader.exports.gen3transparency;local J=api.jumpWave
assert(J.offset(1,4,.11)==3 and J.offset(2,4,.11)==0)
assert(J.offset(2,4,.33)==3 and J.offset(1,4,.33)==0)
local clock=love.timer.getTime;love.timer.getTime=function()return .11 end
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
