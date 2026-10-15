local create=assert(loadfile((root or '.')..'/lib/battlefield_background.lua'))()
local provider,choice=nil,0
local mod={exports={},options={get=function()return choice end},find=function(_,id)
 assert(id=='hd-dynamic-battlefields');return provider and{exports={battlefieldScenery=provider}}end}
local M=create(mod)
assert(not M.available())
local calls=0
provider={apiVersion=1,enabled=function()return true end,draw=function(x,y,w,h)
 assert(x==0 and y==0 and w==1920 and h==1080);calls=calls+1;return true end}
assert(M.available());assert(M.draw(0,0,1920,1080));assert(calls==1)
provider.draw=function()error('failed asset')end
assert(not M.draw(0,0,1920,1080),'Failed provider must fall back')
provider.enabled=function()return false end;assert(not M.available())
provider.apiVersion=99;assert(not M.available())
print('PASS optional scenery dispatch, disable/version gates and failed-provider fallback; no UI changes')
