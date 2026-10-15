-- Standalone: the title menu remains visible beneath ContinueInfo.
local settings={allFontAlign=2,menuJustify=2};local printed={}
love={graphics={}}
local F={width=function(s)return #s*8 end,draw=function(s,x,y)printed[#printed+1]={s,x,y}end,drawBox=function()end,drawCode=function(id,x,y)printed[#printed+1]={id,x,y}end}
local Menu={draw=function(self)F.drawBox(0,0,13,10);F.draw('CONTINUE',16,16);F.draw('OPTION',16,48);F.drawCode(0xED,8,16)end}
require=function(path)if path=='src.render.Font'then return F elseif path=='src.ui.Menu'then return Menu else return{}end end
local mod={generation=1,exports={menuSurfaces={enabled=function()return true end}},options={get=function(_,k)return settings[k]end}}
local A=assert(loadfile(sourceRoot..'/lib/all_fonts.lua'))()(mod);A.install()
local menu={titleUiBox={0,0,12,9},items={}};local top=menu
menu.game={stack={top=function()return top end}}
for _,align in ipairs({1,2,3})do
 settings.menuJustify=align;printed={};top=menu;Menu.draw(menu)
 local before={printed[1][2],printed[2][2],printed[3][2]}
 assert(printed[3][2]==printed[1][2]-8,'Selector did not follow aligned label')
 top={titleUiBox={4,7,15,9},save={},title={}};printed={};Menu.draw(menu)
 assert(printed[1][2]==before[1]and printed[2][2]==before[2],'Continue overlay reset justification')
 top=menu;printed={};Menu.draw(menu)
 assert(printed[1][2]==before[1]and printed[2][2]==before[2],'Closing Continue changed justification')
end
print('PASS title menu left/center/right alignment before, during and after Continue overlay')
