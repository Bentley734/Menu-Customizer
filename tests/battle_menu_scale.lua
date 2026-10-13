-- Execute the actual snapshot wrapper and native uiScale with headless graphics.
local root, engine = arg[1], arg[2]
local function read(path)local f=assert(io.open(path,'rb'));local s=f:read('*a');f:close();return s end
love={graphics={},timer={getTime=function()return 0 end}}
local g=love.graphics
for _,name in ipairs({'push','pop','setCanvas','origin','clear','setColor','draw'})do g[name]=function()end end
function g.newCanvas(w,h)return {getWidth=function()return w end,getHeight=function()return h end,setFilter=function()end}end
package.loaded['src.render.GameViewport']={setTarget=function()end}
local Zoom={offset=-2}
local Renderer={fitScale=function()return 4 end}
local native=read(engine..'/src/render/Renderer.lua')
local scale=assert(native:match('(function Renderer:uiScale%(%)%s.-)\nend'))..'\nend'
assert(load('local Renderer,Zoom=...; '..scale))(Renderer,Zoom)
local observed, fail
Renderer.endFrame=function(self)
 observed={scale=self:uiScale(),world=self.worldActive,canvas=self.worldCanvas}
 if fail then error('test compositor failure')end
 return 'presented'
end
local top={id='party',hideBelow=true}
local battleActive=true
local enabled=true
local Stack={top=function()return top end,has=function()return false end}
local Runtime={_game={},isActive=function()return false end}
local Battle={isActive=function()return battleActive end}
local original=read(root..'/lib/menu_main.lua')
local first=assert(original:find('  local originalBlitCanvas = Renderer.blitCanvas',1,true))
local last=assert(original:find('  Renderer.blitCanvas = function',first,true))
local chunk='local Renderer,Stack,Runtime,Battle,FX,active,mod=...; '..original:sub(first,last-1)..'\nreturn cacheField'
local cache=assert(load(chunk))(Renderer,Stack,Runtime,Battle,{active=false},function()return enabled end,{log={warn=function()end}})
local field=g.newCanvas(480,320)
cache(field)
local checks=0
local function check(ok,msg)checks=checks+1;assert(ok,msg)end
for _,screen in ipairs({'party','bag','summary'})do
 top.id=screen
 for zoom=-4,2 do
  Zoom.offset=zoom
  Renderer.worldActive=false;Renderer.worldCanvas=field;Renderer.uiCentered=false;Renderer.uiWorldHold=false
  check(Renderer:endFrame()=='presented','native result retained')
  check(observed.scale==4,screen..' stays 960x640 during battle at zoom '..zoom)
  check(not observed.world,'battle never restores field')
 end
end
battleActive=false;Zoom.offset=-2;Renderer.worldActive=false
Renderer:endFrame()
check(observed.world and observed.scale==2,'ordinary menu snapshot still follows field zoom')
check(Renderer.worldActive==false and Renderer.worldCanvas==field,'temporary field state restored')
fail=true
check(not pcall(Renderer.endFrame,Renderer),'compositor error propagated')
check(Renderer.worldActive==false and Renderer.worldCanvas==field,'field state restored after error')
fail=false;enabled=false;battleActive=true
Renderer:endFrame()
check(not observed.world and observed.scale==4,'disabled mod leaves native battle scaling')
print('PASS Gen3 battle menu scaling: '..checks..' checks')
