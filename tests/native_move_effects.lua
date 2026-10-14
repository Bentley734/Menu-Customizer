-- Exercise the production animation handoff without requiring OAM steps.
local f=assert(io.open('lib/emerald_engine/WideBattle.lua'))
local s=f:read('*a');f:close()
local a=assert(s:find('local function drawAnimationLayer(battle)',1,true))
local b=assert(s:find('-- The whole 304x144 composition',a,true))
local draw=assert((loadstring or load)(s:sub(a,b-1)..'\nreturn drawAnimationLayer'))()
local checks=0
for _,state in ipairs({{}, {animPlaying=true}, {lockedBall={}},
  {animPlaying=true,animPlayer={}},
  {animPlaying=true,animPlayer={steps={{sprites={}}},stepIndex=1}}}) do
  local calls=0
  local player=state.animPlayer
  state.drawAnimLayer=function(self,colorized)
    calls=calls+1;assert(self==state and colorized==false)
  end
  draw(state)
  assert(calls==1 and state.animPlayer==player)
  checks=checks+1
end
local nativeError='native effect failure'
local ok,err=pcall(draw,{drawAnimLayer=function()error(nativeError)end})
assert(not ok and tostring(err):find(nativeError,1,true))
assert(not s:find('animationOffset',1,true))
print('PASS: '..(checks+2)..' native animation delegation/state/error checks')
