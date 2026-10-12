-- Compare frame bounds against the original GB command/dialogue rectangles.
local function read(path)local f=assert(io.open(path));local s=f:read('*a');f:close();return s end
local source=read('lib/battle_ui.lua')
local placement=assert(source:match('(  local function placement%(x,w,total%).-)  local placementDepth'))
local painters=assert(source:match('(  local function frameGeometry%(mode,rect%).-)  local function persist'))
local checks=0
local function check(value,why)checks=checks+1;assert(value,why)end
local function near(a,b)return math.abs(a-b)<1e-6 end
local state={style=3,menu_align=2,menu_stretch=0}
local mod={generation=1}
local transform={x=0,y=0,sx=1,sy=1};local stack={};local draws,composites={},{}
local G={}
function G.push()stack[#stack+1]=transform;transform={x=transform.x,y=transform.y,sx=transform.sx,sy=transform.sy}end
function G.pop()transform=table.remove(stack)end
function G.origin()transform={x=0,y=0,sx=1,sy=1}end
function G.translate(x,y)transform.x=transform.x+x*transform.sx;transform.y=transform.y+y*transform.sy end
function G.scale(x,y)transform.sx=transform.sx*x;transform.sy=transform.sy*y end
function G.setShader()end
function G.setScissor()end
local function record(kind,x,y,w,h)
 draws[#draws+1]={kind=kind,x=transform.x+x*transform.sx,y=transform.y+y*transform.sy,w=w*transform.sx,h=h*transform.sy}
end
local movesCalled=0
local env=setmetatable({mod=mod,G=G,setting=function(k,d)return state[k] or d end,
 panel=function(x,y,w,h)record('selected',x,y,w,h)end,
 gbFrame=function(x,y,w,h)record('native',x*8,y*8,w*8,h*8)end,
 compose=function(fn,w,h)composites[#composites+1]={w=w,h=h};return fn()end,
 api={moveScreen={frames=function(rect,viewport)movesCalled=movesCalled+1;return rect end}}},{__index=_G})
local geometry,frames=assert(load(placement..painters..'return frameGeometry,frames','battle frame helpers','t',env))()
local cases={
 {generation=1,nativeWidth=160,nativeHeight=48,x=32,y=96,w=800,h=240,commandFraction=96/160},
 {generation=1,nativeWidth=304,nativeHeight=40,wide=true,x=136,y=496,w=774,h=232,commandFraction=144/304},
 {generation=2,nativeWidth=192,nativeHeight=48,x=7,y=10,w=960,h=192,commandFraction=96/192},
 {generation=3,nativeWidth=240,nativeHeight=48,x=0,y=112,w=960,h=192,commandFraction=.5},
}
for _,rect in ipairs(cases)do
 mod.generation=rect.generation
 for _,style in ipairs({1,2,3})do state.style=style
  for _,stretch in ipairs({0,1})do state.menu_stretch=stretch
   for align=0,2 do state.menu_align=align
    draws={};local r=frames('menu',rect,{dpiX=3,dpiY=2})
    local width=stretch==1 and rect.w or rect.w*rect.commandFraction
    local x=rect.x+(rect.w-width)*align/2
    check(near(r.x,x) and near(r.y,rect.y),'original command top-left')
    check(near(r.w,width) and near(r.h,rect.h),'original command full height')
    check(#draws==1,'one command frame; no extra left prompt border')
    local d=draws[1]
    check(near(d.x,x) and near(d.y,rect.y) and near(d.w,width) and near(d.h,rect.h),'painted command frame fills legacy bounds')
    check(d.kind==(style==1 and 'native' or 'selected'),'original selected/native border routing')
    draws={};r=frames('none',rect)
    check(#draws==1,'one dialogue frame')
    d=draws[1]
    check(near(d.x,rect.x) and near(d.y,rect.y) and near(d.w,rect.w) and near(d.h,rect.h),'dialogue fills full source band; no aspect-fit shrink')
    check(#stack==0,'graphics transform restored')
   end
  end
 end
end
local rect={x=1,y=2,w=336,h=64}
check(frames('moves',rect)==rect and movesCalled==1,'moves use independently fitted legacy frames')
check(near(transform.x,0) and near(transform.y,0) and near(transform.sx,1) and near(transform.sy,1),'frame pass restores caller transform')
print('PASS: '..checks..' original battle frame geometry checks')
