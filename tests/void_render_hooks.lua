local source=assert(arg[1]);local rectangles={};local painting=false;local enabled=1;local marks=0
local G={push=function()end,pop=function()end,setColor=function()end,getCanvas=function()return{getDimensions=function()return 120,80 end}end,
 rectangle=function(_,x,y,w,h)if painting then rectangles[#rectangles+1]={x,y,w,h}end end}
love={graphics=G};package.loaded['src.mods.Runtime']={hooks={chains={['ui.start_menu.items']={{owner='gen3transparency'}}}}}
package.loaded['src.render.PaletteFX']={markTrueColor=function()marks=marks+1 end}
package.loaded['src.core.game3.dataset']={isOutdoorMapType=function(t)return t==1 end}
local function mod(g)return{id='gen3transparency',generation=g,options={get=function()return enabled end},exports={selectorPalette={color=function()return{0,0,0,1}end,paint=function(_,fn,...)painting=true;fn(...);painting=false end}}}end
local function check(blocked)
 for y=0,79 do for x=0,119 do
  local count=0;for _,r in ipairs(rectangles)do if x>=r[1]and x<r[1]+r[3]and y>=r[2]and y<r[2]+r[4]then count=count+1 end end
  assert((count>0)==not blocked(x,y),'Hook painted a map/neighbor or missed void')
 end end
end
local Tile={drawWindow=function()end};local World={drawWorld=function(self)self.map.renderer:drawWindow(-10,-10,120,80)end}
package.loaded['src.render.TileRenderer']=Tile;package.loaded['src.world.OverworldController']=World
local V=assert(loadfile(source..'/lib/void_backgrounds.lua'))()(mod(1));V.install()
local map={def={width=2,height=2,tileset='OVERWORLD'}};map.renderer=setmetatable({map=map},{__index=Tile})
World.drawWorld{map=map,neighbors={{map={def={width=1,height=2}},ox=64,oy=0}}}
check(function(x,y)return x>=10 and x<106 and y>=10 and y<74 end);assert(not V.world and marks>0)
rectangles={};enabled=0;World.drawWorld{map=map};assert(#rectangles==0);enabled=1
local W2={drawGround=function()end};package.loaded['src.world.gen2.World']=W2
V=assert(loadfile(source..'/lib/void_backgrounds.lua'))()(mod(2));V.install()
local function image(w,h)return{getDimensions=function()return w,h end}end
W2.drawGround({map={def={environment='TOWN'}},camera={x=-10,y=-10},mapImage=image(64,64),neighbors={{image=image(32,64),ox=64,oy=0}}},1)
check(function(x,y)return x>=10 and x<106 and y>=10 and y<74 end)
rectangles={};local F={draw=function()end,_nativeCamX=-5,_nativeCamY=-7,_viewW=120,_viewH=80}
package.loaded['src.core.game3.field_view']=F
package.loaded['src.core.game3.runtime']={getSession=function()return{map='room'}end}
package.loaded['src.core.game3.map']={worldMidAt=function(x,y)return 0,'general',not(x>=0 and x<4 and y>=0 and y<3)end}
V=assert(loadfile(source..'/lib/void_backgrounds.lua'))()(mod(3));V.install()
F.draw({data={maps={room={mapType=8}}}},120,80,{})
check(function(x,y)return x>=5 and x<69 and y>=7 and y<55 end)
rectangles={};F.draw({data={maps={room={mapType=8}}}},120,80,{actorsOnly=true});assert(#rectangles==0)
print('PASS all-generation render adapters, connected boundaries, partial metatiles, disabled/native and actor-only passes')
