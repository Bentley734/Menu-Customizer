local read=function(p)local f=assert(io.open(p));local s=f:read('*a');f:close();return s end
local organize=assert(load(read('lib/menu_organization.lua')))()
local step=function()return'saved'end
local input={id='fx_battleCommands_fx_highlight_transparency',label='BATTLE HIGHLIGHT TRANSPARENCY',value=function()return'100%'end,step=step}
local result=organize({input},function()end)
local found
local function search(rows)for _,r in ipairs(rows)do if r.id==input.id then found=r end;if r.children then search(r.children)end end end
search(result)
assert(found and found.label=='HIGHLIGHT OPACITY' and found.step==step and found.value()=='100%')
assert(input.label=='BATTLE HIGHLIGHT TRANSPARENCY','source rows remain untouched')
local drawn={};local G={}
for _,k in ipairs({'setColor','push','pop','setShader','rectangle'})do G[k]=function()end end
local F={measure=function(s)return #s*6 end,drawGlyph=function()end,draw=function(s,x,y)drawn[#drawn+1]={s=s,x=x,y=y}end}
local original=F.draw
local mod={exports={customization={withRows=function(_,_,fn,...)return fn(...)end}}}
local env=setmetatable({love={graphics=G}},{__index=_G})
local factory=assert(load(read('lib/option_selection.lua'),'options','t',env))()
for _,version in ipairs({'firered','leafgreen','emerald'})do
 local y=version=='emerald'and 41 or 58;local vx=version=='emerald'and 120 or 146
 local menu={_pages={{rows={found},index=1}}}
 local wrapped=factory(mod,F,function()return 0 end,function()return true end,version).wrap(menu,function()
  F.draw(found.label,24,y);F.draw(found.value(),vx,y)
 end)
 drawn={};wrapped()
 assert(drawn[2].x+F.measure(drawn[2].s)==216,'values align to right inset')
 assert(drawn[1].x+F.measure(drawn[1].s)+8<=drawn[2].x,'titles and values keep separation')
 assert(F.draw==original,'font wrapper restored')
end
print('PASS concise submenu labels, callbacks, source preservation, FRLG/Emerald column spacing')
