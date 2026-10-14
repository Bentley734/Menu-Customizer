local function read(p)local f=assert(io.open(p,'rb'));local s=f:read('*a');f:close();return s end
local helper=assert((loadstring or load)(read('lib/native_move_rendering.lua')))()
local source=read('lib/battle_ui.lua')
local marker={};local game={stack={states={}}};local calls=0
local env=setmetatable({mod={generation=1,id='menu'},marker=marker,nativeMoveRendering=helper,
 require=function(n)if n=='src.mods.Runtime'then return {hooks={chains={['ui.options.rows']={{owner='menu',callback=marker}}}}}end;return require(n)end},{__index=_G})
local function compile(s)
 local f
 if setfenv then f=assert(loadstring(s));setfenv(f,env)
 else f=assert(load(s,'production native effect guard','t',env))end
 return f()
end
local a=assert(source:find('  local function enabled(state)',1,true))
local b=assert(source:find('  local compose=',a,true))
env.enabled=compile(source:sub(a,b-1)..'return enabled')
env.B={};env.method='drawTextArea'
env.draw=function(self,...)calls=calls+1;return self,... end
a=assert(source:find('    B[method]=function(self,...)',1,true))
b=assert(source:find('    if mod.generation==1 then',a,true))
compile(source:sub(a,b-1))
local checks=0
for _,state in ipairs({{animPlaying=true},{anim={}},{lockedBall={}},
 {fx={shakeX=-2}},{fx={shakeY=1}},{fx={shake=3}},{fx={flash=4}},
 {fx={wavy={}}},{fx={bgp={}}},{fx={bgpSeq={}}},
 {picFx={{ox=-8}}},{picFx={{oy=8}}},{picFx={{kind='blink'}}},
 {picFx={{fade=.5}}},{picFx={{hidden=true}}},{picFx={{minimized=true}}}})do
 assert(helper(state) and not env.enabled(state),'effect graphics must remain native')
 local before=calls;local result,argument=env.B.drawTextArea(state,'native-argument')
 assert(calls==before+1 and result==state and argument=='native-argument','custom text canvas must be bypassed')
 checks=checks+2
end
assert(not helper({fx={shakeX=0,shakeY=0,shake=0,flash=0},picFx={{ox=0,oy=0}}}))
assert(env.enabled({}), 'custom menus resume once native effects finish')
print('PASS: '..(checks+2)..' native effect guard/delegation/resume checks')
