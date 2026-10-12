local settings={};local mod={exports={},options={get=function(_,k)return settings[k]end},save={get=function()end},read=function(_,p)local f=assert(io.open(p,'rb'));local s=f:read('*a');f:close();return s end}
local P=assert(loadfile('lib/battle_text_palette.lua'))()(mod);local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
local G=P.gradients
for _,list in ipairs({P.names,P.shadowNames,P.backgroundNames,P.menuBackgroundNames})do
 for _,name in ipairs(list)do check(name~='RGB','RGB remains in chooser')end
end
for _,entry in ipairs(G.entries)do
 local a,b=G.sample(entry.key,0),G.sample(entry.key,1)
 for channel=1,3 do check(a[channel]==b[channel],'cycle does not close')end
 for i=0,400 do
  local c=G.sample(entry.key,i/400);local before=G.sample(entry.key,i/400-.0001)
  for j=1,3 do check(c[j]>=0 and c[j]<=1 and math.abs(c[j]-before[j])<.002,'palette clips or jumps')end
 end
 for _,kind in ipairs({'text','shadow','background'})do
  local names=kind=='text' and P.names or kind=='shadow' and P.shadowNames or P.backgroundNames
  local id;for i,name in ipairs(names)do if name==entry.name then id=i-1;break end end
  check(id~=nil and P.color(kind,id).gradient==entry.key,'palette not shared by chooser')
 end
end
local oldRGB=27+#assert(loadfile('lib/color_swatches.lua'))()
-- Foreground has 27 original static colours; old RGB slot migrates in place.
check(P.names[oldRGB+1]=='AURORA','old RGB ID was shifted')
check(P.names[oldRGB+2]=='ROTATING' and P.names[oldRGB+3]=='ANIMATED GRADIENT','existing animation IDs shifted')
for i,name in ipairs(P.backgroundNames)do if name=='AURORA' then settings.battle_background_color=i-1 end end
check(P.background().gradient=='aurora' and P.background()._kind=='battle','animated background metadata lost')
local catalog=assert(loadfile('lib/border_catalog.lua'))()
check(catalog.entries[61].animation=='gradient' and #catalog.entries==76,'old border ID shifted or themes missing')
for n=62,67 do check(catalog.entries[n].animation~='gradient','themed border missing')end
print('PASS '..checks..' gradient continuity, colour bounds, shared choosers and saved-ID checks')
