local function read(p)local f=assert(io.open(p));local s=f:read('*a');f:close();return s end
local settings={menuBackgroundColor=2,startMenuBackgroundColor=10}
local mod={options={get=function(_,k)return settings[k]end},save={get=function()end}}
local P=assert(loadfile('lib/battle_text_palette.lua'))()(mod)
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
check(P.names[3]=='BLUE' and P.shadowNames[6]=='BLUE' and P.backgroundNames[6]=='PALE BLUE','old indices retained')
check(#P.names>=25 and #P.backgroundNames>=25,'expanded palettes')
check(P.menuBackground()[1]==0,'general menu black')
check(P.menuBackground('start')[3]==1 and P.menuBackground('start')[1]>.3,'independent light blue start')
settings.startMenuBackgroundColor=0;check(P.menuBackground('start')[1]==0,'start inherits menu')
settings.menuBackgroundColor=0;check(P.menuBackground()==nil,'native default retained')
local T=assert(loadfile('lib/menu_transitions.lua'))()
for style=1,#T.names do
 for _,p in ipairs({0,.25,.5,.75,1})do
  local t=T.sample(style,p,240,160)
  check(t.sx>0 and t.sy>0 and t.rotation==t.rotation,'finite positive transition')
  if p==1 then check(t.sx==1 and t.sy==1 and t.dx==0 and t.dy==0 and t.rotation==0 and t.mask==nil,'exact final layout')end
 end
end
-- Actual KIM ownership guard: no underlay when the customizer owns the panels.
local source=read(arg[1]..'/lib/gen3_frlg.lua')
local a=assert(source:find('  local function drawFullWidthPanelBacking',1,true))
local b=assert(source:find('  local function battlerAt',a,true))
local owned=true;local calls=0
local env=setmetatable({mod={find=function()return {exports={battleUi={ownsGen3Panels=function()return owned end}}}end},okChrome=true,
 BattleChrome={drawPanel=function()calls=calls+1 end},withNativeViewport=function(_,_,_,_,f)return f()end},{__index=_G})
local draw=assert(load(source:sub(a,b-1)..'return drawFullWidthPanelBacking','actual KIM underlay','t',env))()
check(draw(0,0,1,1)==false and calls==0,'duplicate full-width frame suppressed')
owned=false;check(draw(0,0,1,1)==true and calls==1,'standalone KIM fallback retained')
-- The actual Gen3 owner emits exactly the split panels, without native backing.
source=read('lib/battle_ui.lua')
a=assert(source:find('    local function drawGen3Panels',1,true));b=assert(source:find('    mod.exports.drawGen3Panels',a,true))
local panes={};local modeSettings={style=3,menu_stretch=0,menu_align=2}
local env2=setmetatable({mod={exports={borders={drawBattlePixels=function(x,y,w,h)panes[#panes+1]={x=x,w=w};return true end}}},
 setting=function(k,d)return modeSettings[k]or d end,faded=function(f)return f()end,placed=function(f)return f()end},{__index=_G})
local panels=assert(load(source:sub(a,b-1)..'return drawGen3Panels','actual owned panels','t',env2))()
panels('menu');check(#panes==2 and panes[1].x==0 and panes[2].x==120,'one prompt and one command panel')
panes={};panels('moves');check(#panes==2 and panes[1].w==160 and panes[2].w==80,'one move and one PP panel')
panes={};panels('none');check(#panes==1 and panes[1].w==240,'one dialogue panel')
print('PASS '..checks..' palette, background, transition and Emerald ownership checks')
