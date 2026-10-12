local choice
local mod={options={get=function()return choice end},save={get=function()end}}
local M=assert(loadfile('lib/battle_text_palette.lua'))()(mod)
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
check(M.colors().fg[1]==0 and M.colors().fg[2]==0 and M.colors().fg[3]==0,'default black')
for i=0,#M.names-1 do choice=i;check(M.colors().fg[4]==1,'opaque palette choice')end
choice=0
local text='Wild '..string.char(252,1,1)..'ZIGZAGOON'..string.char(252,3,3)..' appeared!'
check(M.clean(text)=='Wild ZIGZAGOON appeared!','Ruby embedded palette override removed')
check(M.clean('A'..string.char(252,8,20)..'B')=='A'..string.char(252,8,20)..'B','timing preserved')
local recorded
local F={draw=function(t,x,y,o)recorded={t=t,o=o}end}
package.loaded['src.ui.game3.frlg_font']=F
local original=F.draw;local opts={colors={fg={1,1,1,1}},font='normal',maxWidth=200}
M.scope(function()F.draw(text,8,120,opts)end)
check(recorded.t=='Wild ZIGZAGOON appeared!' and recorded.o.colors.fg[1]==0,'dialogue uses black')
check(recorded.o.maxWidth==200 and opts.colors.fg[1]==1,'caller options retained without mutation')
M.scope(function()F.draw(text,8,20,opts)end)
check(recorded.t==text and recorded.o==opts,'healthbox palette untouched')
check(F.draw==original,'restored after success')
check(not pcall(M.scope,function()error('test')end) and F.draw==original,'restored after error')
print('PASS '..checks..' battle text palette checks')
