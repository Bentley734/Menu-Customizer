local native,painted,enabled=0,0,true
local Bg={draw=function(...)native=native+1;return 'native',... end}
local provider={apiVersion=1,enabled=function()return enabled end,draw=function()painted=painted+1;return true end}
local mod={generation=3,exports={},options={get=function()return 0 end},find=function(_,id)
 if id=='hd-dynamic-battlefields'then return{exports={battlefieldScenery=provider}}end
end}
local env=setmetatable({require=function(name)
 if name=='src.core.game3.battle.bg'then return Bg end
 error(name)
end},{__index=_G})
local f=assert(io.open('lib/battlefield_background.lua'));local source=f:read('*a');f:close()
local api=assert(load(source,'provider handoff','t',env))()(mod);api.install()
local value,arg=Bg.draw(23);assert(value=='native'and arg==23 and native==1 and painted==0)
enabled=false;Bg.draw(24);assert(native==2 and painted==0)
print('PASS Gen3 scenery ownership, native arguments/return and disabled fallback')
