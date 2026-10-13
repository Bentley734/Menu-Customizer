local root=arg and arg[1]or'.'
unpack=table.unpack
local labels={};local badge=0
local F={draw=function(text,x,y,opts)labels[#labels+1]={text,x,y};return 1,x+#text*6,y end,measure=function(text)return #text*6 end}
local T={scroll=0,list=function()return {{id=1},{id=2}}end}
local Chrome={drawHmIcon=function()badge=badge+1 end}
local Items={tmNumber=function(id)return id==1 and 1 or 50 end,isHm=function(id)return id==1 end}
local Pokemon={moveFromTmItem=function(id)return id end,moveName=function(id)return id==1 and 'CUT'or'OVERHEAT'end}
T.draw=function()
 for i=1,2 do
  local y=10+(i-1)*16;local x=i==1 and 106 or 88
  for _,text in ipairs({'No',tostring(i),' ',Pokemon.moveName(i)})do local _,endX=F.draw(text,x,y,{small=true});assert(endX);x=endX end
  if i==1 then Chrome.drawHmIcon(88,y)else F.draw('x1',206,y,{small=true})end
 end
 return 'drawn'
end
package.loaded['src.ui.game3.tm_case']=T;package.loaded['src.ui.game3.frlg_font']=F
package.loaded['src.core.game3.items_data']=Items;package.loaded['src.core.game3.pokemon']=Pokemon;package.loaded['src.ui.game3.tm_case_chrome']=Chrome
local draw,b=F.draw,Chrome.drawHmIcon;local live=true
local install=assert(loadfile(root..'/lib/tm_case_labels.lua'))()
install({},function()return live end)
assert(T.draw()=='drawn');assert(labels[1][1]=='HM01 CUT'and labels[2][1]=='TM50 OVERHEAT'and labels[3][1]=='x1')
assert(#labels==3 and badge==0);assert(F.draw==draw and Chrome.drawHmIcon==b)
install({},function()return live end);labels={};T.draw();assert(#labels==3,'reload must not duplicate')
live=false;labels={};T.draw();assert(labels[1][1]=='No'and badge==1)
live=true;local old=T.list;T.list=function()error('original error')end
assert(not pcall(T.draw));assert(F.draw==draw);T.list=old
local f=assert(io.open(root..'/lib/menu_main.lua'));local s=f:read('*a');f:close()
local fragment=assert(s:match('(  if not FrlgFont%._menuCustomizerEmeraldWrapped then.-FrlgFont%._menuCustomizerEmeraldWrapped=true\n  end)'))
F._menuCustomizerEmerald={enabled=function()return true end,draw=function(text)return #text*6 end}
local env=setmetatable({FrlgFont=F,LevelText={normalize=function(t)return t end},mod={exports={arrowSelectors={draw=function()return false end}}}},{__index=_G})
assert(load(fragment,'font printer','t',env))()
local width,endX,endY=F.draw('CUT',88,10)
assert(width==18 and endX==106 and endY==10,'themed printer restores segmented draw cursor')
print('PASS TM/HM names, numbers, quantities, reload/disable handling and themed font end-position contract')
