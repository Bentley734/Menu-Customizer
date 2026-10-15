-- Bounded labels, fixed numeric columns and error cleanup.
local output={};local fail=false
local F={width=function(s)return #s*6 end,drawBox=function()end,draw=function(s,x,y)if fail then error('font failure')end;output[#output+1]={s,x,y}end}
local Menu={draw=function(self)F.drawBox(0,0,20,10);F.draw('MENU',16,16)end}
local List={draw=function(self)F.draw('POTION',16,16);F.draw('123',134,16)end}
local mod={generation=1,exports={customization={},menuSurfaces={enabled=function()return true end}},options={get=function(_,k)if k=='allFontAlign'then return 3 end;return nil end}}
local env=setmetatable({love={graphics={}},require=function(n)if n=='src.render.Font'then return F elseif n=='src.ui.Menu'then return Menu elseif n=='src.ui.ListMenu'then return List end end},{__index=_G})
local f=assert(io.open('lib/all_fonts.lua'));local text=f:read('*a');f:close()
local api=assert(load(text,'all font layout','t',env))()(mod);api.install()
local self={items={{label='POTION',right='123'}}};self.game={stack={top=function()return self end}}
List.draw(self);assert(output[1][2]+F.width('POTION')<output[2][2],'label overlaps reserved number column');assert(output[2][2]==134,'number moved')
output={};Menu.draw(self);assert(output[1][2]>16,'right alignment not applied')
self.game.stack.top=function()return{}end;output={};Menu.draw(self);assert(output[1][2]==16,'partly covered parent must retain native layout')
self.game.stack.top=function()return self end;fail=true;assert(not pcall(Menu.draw,self));fail=false
output={};F.draw('OUTSIDE',16,16);assert(output[1][2]==16,'failed draw leaked alignment scope')
print('PASS all-font cell bounds, numeric anchors, covered menus and error cleanup')
