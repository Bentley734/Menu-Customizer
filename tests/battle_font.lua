local source=assert(io.open('lib/battle_font.lua')):read('*a')
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
for generation=1,3 do
 local exports={};local choice=2;local native,emerald=0,0
 local theme={draw=function()emerald=emerald+1 end,measure=function()return 30 end,glyph=function()emerald=emerald+1;return true end}
 local F={_menuCustomizerGB={theme=theme},width=function()return 40 end,draw=function()native=native+1 end,drawCode=function()native=native+1 end,measure=function()return 40 end,drawGlyph=function()native=native+1 end,CHAR_SELECTOR_ARROW=239}
 local mod={generation=generation,exports=exports,options={get=function()return choice end},save={get=function()end}}
 local env=setmetatable({require=function()return F end,love={graphics={push=function()end,pop=function()end,translate=function()end,scale=function()end}}},{__index=_G})
 local api=assert(load(source,'battle font','t',env))()(mod)
 api.scope(function()
  check(exports.battleFontScope==true,'font scope active')
  api.scope(function()check(exports.battleFontScope==true,'nested font scope')end)
  check(exports.battleFontScope==true,'outer scope restored')
  if generation<3 then
   api.selected.draw('SURF',0,0);check(emerald==1,'Emerald source selected')
   check(api.selected.measure('SURF')==30,'Emerald measurement matches rendering')
   choice=1;api.selected.draw('SURF',0,0);check(native==1,'native source selected')
   check(api.selected.measure('SURF')==60,'native measured at matching scale')
  end
 end)
 check(exports.battleFontScope==nil,'scope restored')
 check(not pcall(api.scope,function()error('expected')end),'draw error forwarded')
 check(exports.battleFontScope==nil,'scope restored after error')
 local target={draw=function()
  check(exports.battleFontScale==.75,'HD font uses explicit scale')
  error('expected wrapped error')
 end}
 api.wrap(target,'draw',.75)
 check(not pcall(target.draw),'wrapped draw error forwarded')
 check(exports.battleFontScale==nil and exports.battleFontScope==nil,'wrapped scale/scope restore after error')
 api.active=function()return false end
 api.scope(function()check(exports.battleFontScope==nil,'disabled mod leaves font alone')end)
end
print('PASS '..checks..' selected battle font, measurements, nested scope and error restoration checks')

-- Selected native Gen3 fonts must retain their active-ROM face and profile.
local file=assert(io.open('lib/emerald_native.lua'));local nativeSource=file:read('*a');file:close()
local a=assert(nativeSource:find('  function M.scope(',1,true));local z=assert(nativeSource:find('  local gbMap,gbSignature',a,true))
local originalFace=function()return 'native' end
local originalDraw=function()end
local F={face=originalFace,draw=originalDraw,measure=function()end,drawGlyph=function()end}
local originalProfile={font='native-font',ui='native-ui'}
local profileFn=function()return originalProfile end
local P={forSession=profileFn};local C={drawPanel=function()end}
local M={ready=function()return true end,selectedFont={},font={face=function()return 'emerald'end,draw=function()end,measure=function()end,drawGlyph=function()end},chrome={},profile={font='emerald-font',ui='emerald-ui'}}
local env=setmetatable({M=M,mod={exports={}},require=function(name)return name=='src.core.game3.profile'and P or name=='src.ui.game3.frlg_font'and F or C end},{__index=_G})
assert(load(nativeSource:sub(a,z-1),'native font isolation','t',env))()
check(not pcall(M.scope,function()
 check(F.face==originalFace,'native face retained inside Emerald chrome scope')
 check(P.forSession().font=='native-font','native font profile retained')
 check(P.forSession().ui=='emerald-ui','Emerald chrome profile retained')
 error('expected')
end),'private scope forwards error')
check(F.draw==originalDraw and F.face==originalFace and P.forSession==profileFn,'private font/profile restored after error')
print('PASS selected Gen3 font ownership and restoration')
