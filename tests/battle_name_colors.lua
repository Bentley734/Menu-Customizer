local function read(p)local f=assert(io.open(p));local s=f:read('*a');f:close();return s end
local settings={battle_name_color=4,battle_text_color=2,menuTextColor=3}
local mod={options={get=function(_,k)return settings[k]end},save={get=function()end},exports={battleHudScope=true,battleFontScope=true,battleHudCapture=true}}
local palette=assert(loadfile('lib/battle_text_palette.lua'))()(mod)
local source=read('lib/gb_menus.lua');local start=assert(source:find('  local function label',1,true))
local finish=assert(source:find('   if current and current.drawingParty',start,true))
local Font={_menuCustomizerGB={mod=mod}}
local env=setmetatable({Font=Font,mod=mod},{__index=_G})
local label=assert(load(source:sub(start,finish-1)..'end return label','actual name label','t',env))()
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
for _,y in ipairs({0,56})do
 for _,name in ipairs({'NIDOKING','5'})do
  label(name,8,y,function()check(mod.exports.battleNameScope,'name palette scope')end)
  check(mod.exports.battleNameScope==nil,'name scope restored')
 end
end
for _,y in ipairs({8,18,64,80})do label('5',8,y,function()check(not mod.exports.battleNameScope,'levels/HP not names')end)end
check(not pcall(label,'NIDOKING',8,0,function()error('test')end) and mod.exports.battleNameScope==nil,'restore after error')
local a=assert(source:find(' C.theme.gbColors=function()',1,true));local b=assert(source:find(' Font._menuCustomizerGB=C',a,true))
local C={theme={}}
mod.exports.battleUi={nativeEmerald={presentationColors=function()return palette.colors()end}}
assert(load(source:sub(a,b-1),'actual name palette','t',setmetatable({C=C,mod=mod,menuPalette=palette},{__index=_G})))()
mod.exports.battleNameScope=true;check(C.theme.gbColors().fg[1]>.5,'names red')
mod.exports.battleNameScope=nil;check(C.theme.gbColors().fg[3]>.5,'dialogue stays blue')
local M={font={draw=function(_,_,_,opts)return opts.colors end},textPalette=palette}
M.healthbox={draw=function()return M.font.draw('TORCHIC',0,0,{colors=palette.colors()})end}
local private=read('lib/emerald_native.lua'):match('(    if M.healthbox then\n      local original=M.healthbox.draw.-)    if M.healthbox then M.healthbox.shouldShowCaughtMarker')
assert(load(assert(private),'actual private healthbox name','t',setmetatable({M=M},{__index=_G})))()
check(M.healthbox.draw().fg[1]>.5,'private Emerald healthbox names independent')
print('PASS '..checks..' actual GB name routing / private Emerald healthbox checks')
