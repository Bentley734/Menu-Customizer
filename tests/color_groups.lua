local mod={exports={},options={get=function()end},save={get=function()end},read=function(_,p)local f=assert(io.open(p,'rb'));local s=f:read('*a');f:close();return s end}
local P=assert(loadfile('lib/battle_text_palette.lua'))()(mod)
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
for _,kind in ipairs({'text','shadow','background','menuBackground'})do
 local groups,names=P.groups(kind);local found={};local total=0
 for _,g in ipairs(groups)do
  check(#g.ids>0,'no empty hue pages')
  for _,n in ipairs(g.ids)do
   check(n>=0 and n<#names and not found[n],'each saved ID appears once')
   found[n]=g.label;total=total+1
  end
 end
 check(total==#names,'no colours omitted')
 check(found[#names-1]=='ANIMATED' and found[#names-2]=='ANIMATED' and found[#names-3]=='ANIMATED','animated modes grouped together')
 if kind=='text' then check(found[0]=='NEUTRALS' and found[2]=='BLUES' and found[3]=='GREENS' and found[4]=='REDS' and found[5]=='PURPLES','base hues correct')end
 if kind=='background' then check(found[5]=='BLUES' and found[6]=='GREENS','pale blue and green retain their base hue')end
 if kind=='shadow' or kind=='menuBackground' then check(found[0]=='SPECIAL','NONE or inherited background available')end
 local current=0;local title,page;local context={sentinel=true};local saved
 local row={id='probe',label='COLOR',step=function()end}
 P.picker(row,kind,function()return current end,function(ctx,n)check(ctx==context,'selection retains caller context');current=n;saved=n;return false end,function(t,r)title,page=t,r end,kind=='menuBackground' and 'USE MENU' or nil)
 check(row.activate and row.step,'picker retains directional compatibility')
 row.activate(context);check(title=='COLOR' and #page==#groups,'root opens colour families')
 for _,group in ipairs(page)do
  group.activate(context)
  for _,shade in ipairs(page)do
   local n=tonumber(shade.id:match(':color:(%d+)$'));saved=nil
   shade.activate(context);check(saved==n and shade.selected() and shade.value()=='SELECTED','shade uses its original saved ID')
  end
 end
 if kind=='menuBackground' then
  row.activate(context);page[1].activate(context);check(page[1].label=='USE MENU','Start background retains inherited choice')
 end
end
for _,kind in ipairs({'menu','battle','name'})do
 local page;local rows=P.effects.rows(kind,function()end,function(_,r)page=r end)
 for _,index in ipairs({3,4,5,6,7,8,9})do
  check(rows[index].activate~=nil,'alternation, glow and double shadow get grouped pickers')
  rows[index].activate({});check(page and #page>1,'effect chooser opens hue groups')
 end
end
print('PASS '..checks..' complete colour group coverage, saved-ID selection and all text-effect chooser checks')
