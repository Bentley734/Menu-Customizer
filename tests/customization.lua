local root=arg[1]
local function read(path)local f=assert(io.open(root..'/'..path,'rb'));local s=f:read('*a');f:close();return s end
local function module(path)return assert(load(read('lib/'..path)))()end
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
local settings={menuTextShadowColor=1,menu_fx_highlight=1,menu_fx_outline=1,menu_fx_glow=1,menu_fx_double=1}
local mod={generation=3,exports={},options={get=function(_,k)return settings[k]end},save={get=function()end},read=function(_,p)return read(p)end}
local commands,color,stack={},{1,1,1,1},{}
local G={push=function()stack[#stack+1]=color end,pop=function()color=table.remove(stack)end,setColor=function(...)color={...}end,
 setShader=function()end,translate=function()end,transformPoint=function(x,y)return x,y end}
G.rectangle=function()commands[#commands+1]={kind='highlight',alpha=color[4]}end
love={graphics=G,timer={getTime=function()return 0 end}}
local P=module('battle_text_palette.lua')(mod);mod.exports.selectorPalette=P
local function glyph(dx,dy)commands[#commands+1]={kind=dx==0 and dy==0 and 'ink'or dx==-1 and dy==1 and 'shadow/outline'or 'outline',alpha=color[4],dx=dx,dy=dy}end
for _,kind in ipairs({'menu','battle','name'})do
 local specs=P.effects.specs(kind);local prefix=kind=='menu'and 'menu_fx_'or kind=='name'and 'battle_name_fx_'or 'battle_fx_'
 check(specs[prefix..'glow']==nil and specs[prefix..'double']==nil,'retired effects cannot be enabled')
 local rows=P.effects.rows(kind,function(_,key,n)settings[key]=n end,function()end)
 for _,key in ipairs({'highlight','outline','shadow'})do
  local found
  for _,r in ipairs(rows)do if r.id=='fx_'..prefix..key..'_transparency'then found=r end end
  check(found~=nil,'all scopes expose '..key..' transparency')
  found.step({},1);check(settings[prefix..key..'_transparency']==5,'transparency persists')
 end
end
settings.menu_fx_highlight_transparency=25;settings.menu_fx_outline_transparency=50;settings.menu_fx_shadow_transparency=75
commands={};P.effects.glyph(P.colors('menu'),0,0,glyph)
check(#commands==11,'one highlight, one shadow, eight outline neighbors and foreground; no glow/double')
check(commands[1].alpha==.75 and commands[2].alpha==.25 and commands[3].alpha==.5 and commands[11].alpha==1,'independent effect alpha')
settings.menu_fx_highlight_transparency=100;settings.menu_fx_outline_transparency=100;settings.menu_fx_shadow_transparency=100
commands={};P.effects.glyph(P.colors('menu'),0,0,glyph)
check(#commands==2 and commands[1].alpha==0 and commands[2].alpha==1,'fully transparent effects leave foreground untouched')
local icons=module('menu_selectors.lua');check(icons.names[13]=='HIGHLIGHT','START highlight appended without changing old indices')
local A=module('arrow_selectors.lua')(mod,icons,function(k)return settings[k]or 0 end,function()return true end)
settings.arrowSelector=13;commands={};check(A.id()==0 and A.draw(0,0,8,{_selectionHighlight=true}) and #commands==0,'NONE consumes native arrow without duplicating existing highlight')
commands={};A.draw(0,0,8);check(#commands==1,'NONE supplies a transparent native row highlight')
for _,n in ipairs({11,12})do settings.arrowSelector=n;commands={};check(A.draw(0,0,8) and #commands>0,'underline and dots work as Arrow Selectors')end
local opened={}
local entries={}
for _,id in ipairs({'menuTheme','dialogueJustify','menuBorder','menuBackgroundColor','scene_battle_in','menuTransition','startSelector','selectorColor','selectionHighlight','startPosition','optionOpacity','text_fx'})do entries[#entries+1]={id='wide_'..id,label=id}end
entries[#entries].children=P.effects.rows('menu',function()end,function()end)
local categories=module('menu_organization.lua')(entries,function(name,children)opened[name]=children end)
local order={'TEXT','BORDERS','BACKGROUNDS','TRANSITIONS','SELECTORS','POSITION','TRANSPARENCY'}
for i,r in ipairs(categories)do check(r.label==order[i],'category order');r.activate({})end
check(#categories==7 and #opened.SELECTORS==3,'exactly seven groups; selector color belongs to SELECTORS')
check(opened.TRANSITIONS[2].label=='MISC TRANSITIONS','miscellaneous transition label')
check(#opened.TRANSPARENCY==4,'effect transparency controls grouped with opacity')
-- Small windows use OPTIONS colors even when a dialogue scope surrounds them.
local F={draw=function()end,drawGlyph=function()end};package.loaded['src.ui.game3.frlg_font']=F
local seen=0
for _,name in ipairs({'src.ui.game3.mon_pic','src.ui.game3.choice'})do
 package.loaded[name]={draw=function()
  check(mod.exports.previewScope and mod.exports.menuPaperScope=='option' and not mod.exports.dialogueFontScope,'preview/choice owns OPTIONS palette scope')
  check(P.colors('menu').fg==P.color('text',2),'preview/choice text takes menu text color')
  seen=seen+1
 end}
end
settings.menuTextColor=2;settings.dialogueTextColor=4;mod.exports.dialogueFontScope=true
module('preview_windows.lua')(mod,P,function()return true end)
for _,name in ipairs({'src.ui.game3.mon_pic','src.ui.game3.choice'})do package.loaded[name].draw()end
check(seen==2 and mod.exports.dialogueFontScope and not mod.exports.previewScope,'nested scopes restored')
package.loaded['src.ui.game3.choice']._menuCustomizerPreview.active=function()return true end
local original=package.loaded['src.ui.game3.choice']._menuCustomizerPreviewDraw
-- Exercise the original wrapper's failure path through a palette exception.
local saved=P.menuScope;P.menuScope=function()error('probe')end
check(not pcall(package.loaded['src.ui.game3.choice'].draw) and not mod.exports.previewScope and mod.exports.dialogueFontScope,'preview scope restores after error');P.menuScope=saved
-- Execute the actual GB textbox wrapper against retained full-page lines.
local Font={width=function(s)return #s*8 end,advanceOf=function()return 8 end}
local C={mod=mod,live=function()return true end,setting=function(k)return settings[k]or 1 end,palette={withText=function(_,fn)return fn()end}}
Font._menuCustomizerGB=C
local drawn={};Font.drawCode=function(id,x,y)drawn[#drawn+1]={id,x,y}end
local TextBox={draw=function(self)
 for i,line in ipairs(self.shown)do for j,id in ipairs(line)do Font.drawCode(id,self.textX+(j-1)*8,i==1 and self.line1Y or self.line2Y)end end
end}
local fragment=assert(read('lib/gb_menus.lua'):match('( if not TextBox%._menuCustomizerDialogueDraw then.-)%s+if mod.generation==2'))
local env=setmetatable({Font=Font,TextBox=TextBox,unpack=unpack or table.unpack},{__index=_G})
assert(load(fragment,'GB dialogue wrapper','t',env))()
local box={textX=8,line1Y=112,line2Y=128,boxTx=0,boxTy=12,boxTw=20,boxTh=6,shown={{65},{66}},shownSource={1,2},pages={{'ABCD','AB'}},pageIndex=1}
for _,align in ipairs({1,2,3})do
 settings.dialogueJustify=align;settings.dialogueTheme=1;drawn={};TextBox.draw(box)
 local slack=136-32;local shift=align==2 and math.floor(slack/2)or align==3 and slack or 0
 check(drawn[1][2]==12+shift,'GB horizontal alignment uses complete line during typing')
 check(drawn[1][3]==108 and drawn[2][3]==124,'GB two-line ink vertically centered')
 check(box.textX==8 and box.line1Y==112 and box.line2Y==128,'GB original layout restored')
end
print('PASS '..checks..' customization category, transparency, selector, preview and dialogue checks')
