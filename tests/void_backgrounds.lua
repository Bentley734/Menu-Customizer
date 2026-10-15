local api=testLoader.exports.gen3transparency;local V=assert(api.voidBackgrounds)
local game={options=testOptions,mods=testLoader,writeOptions=function()end}
local opened;local rows=V.rows(function(_,r)opened=r end)
assert(#rows==2 and rows[1].value()=='NATIVE'and rows[2].value()=='NATIVE')
rows[1].step(game,1);assert(V.choice(false)==1 and V.choice(true)==0)
rows[2].step(game,-1);assert(V.choice(true)==#api.selectorPalette.backgroundNames)
rows[1].activate(game);assert(opened[1].label=='SPECIAL')
local cases={{{3,2,8,6}},{{-3,-5,10,10},{7,0,10,10}},{{0,0,20,20}},{{40,40,3,3}},{{3,2,8,6},{9,2,8,6},{5,4,4,4}}}
for _,bodies in ipairs(cases)do
 local rectangles=V.subtract(20,15,bodies)
 for y=0,14 do for x=0,19 do
  local blocked=false;for _,b in ipairs(bodies)do if x>=b[1]and x<b[1]+b[3]and y>=b[2]and y<b[2]+b[4]then blocked=true end end
  local count=0;for _,r in ipairs(rectangles)do if x>=r[1]and x<r[1]+r[3]and y>=r[2]and y<r[2]+r[4]then count=count+1 end end
  assert(count==(blocked and 0 or 1),'Void mask covers map or leaves gaps')
 end end
end
assert(V.outdoor({tileset='OVERWORLD'},1)and not V.outdoor({tileset='MART'},1))
assert(V.outdoor({environment='ROUTE'},2)and not V.outdoor({environment='INDOOR'},2))
local root=api.customization.rows(function()end);local organize=assert(loadfile(sourceRoot..'/lib/menu_organization.lua'))();local pages=organize(root,function()end)
local seen=0;for _,p in ipairs(pages)do if p.label=='BACKGROUNDS'then for _,r in ipairs(p.children)do if r.id:find('VoidBackgroundColor')then seen=seen+1;assert(not r.label:find('BACKGROUND'))end end end end
assert(seen==2)
local global=api.customization.globalValues('allBackgroundColor',5);assert(global.indoorVoidBackgroundColor==5 and global.outdoorVoidBackgroundColor==5)
rows[1].step(game,-1);assert(V.choice(false)==0,'Native fill not restored')
assert(api.customization.globalValues('allBackgroundColor',5).indoorVoidBackgroundColor==nil)
print('PASS independent native/background settings, picker navigation, map/neighbor masks and category labels')
