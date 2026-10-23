local root=assert(os.getenv('MENU_WORKSPACE')):gsub('\\','/')..'/'
local out=root..'.work/menu-33525-gpu/'
local function read(p)local f=assert(io.open(root..'MenuCustomizer/'..p,'rb'));local s=f:read('*a');f:close();return s end
local function write(p,s)local f=assert(io.open(out..p,'wb'));f:write(s);f:close()end
function love.load()
 local ok,err=xpcall(function()
  local G=love.graphics;local mod={exports={},read=function(_,p)return read(p)end}
  local F={draw=function()end,drawGlyph=function()end,measure=function()return 0 end}
  local save={isOpen=function()return true end};local top={id='save'};local clock=1
  love.timer.getTime=function()return clock end
  local FX=assert(loadstring(read('lib/menu_fx.lua')))(){mod=mod,setting=function(k)return k=='menuTransition'and 2 or k:match('Scale$')and 100 or 0 end,Battle={isActive=function()return false end},Stack={has=function()return true end}}
  FX.beginFrame(top);FX.motion('save',0,0,1);clock=2
  FX.beginFrame(top);FX.beginFrame(top);FX.beginFrame(top)
  local _,_,alpha=FX.motion('save',0,0,1);assert(alpha==1,'SAVE fade restarted after missed presentation')
  local env=setmetatable({mod=mod,FrlgFont=F,Save=save,Start={},Option={},menuPalette=nil,
   Display={fit=function()return 2,0,0,nil,nil,2 end},FX={scale=function()return 1 end,offset=function()return 0,0 end,record=function()end,motion=function(_,x,y)return x,y,1,1 end},
   setting=function()return 1 end,opacityChoices={100}}, {__index=_G})
  local source=read('lib/menu_main.lua'):gsub('\r\n','\n')
  local fn=assert(loadstring(assert(source:match('(  local canvas\n.-)  Display.present = function'))..'return drawAt'));setfenv(fn,env)
  local drawAt=fn();local target=G.newCanvas(480,320)
  local function draw()
   G.setColor(.1,.25,.4,1);G.rectangle('fill',8,8,120,64)
   G.setColor(1,1,1,1);G.rectangle('fill',16,16,64,8)
   G.setColor(.2,.8,.4,1);G.rectangle('fill',0,112,240,48)
  end
  local expected
  for i=1,12 do
   G.setCanvas(target);G.origin();G.setShader();G.setScissor();G.clear(0,0,0,1)
   -- Alternate renderer leftovers to reproduce the old partial/blank replay.
   if i%2==0 then G.setScissor(70,70,8,8);G.setColor(.2,.1,.1,.05);G.setBlendMode('add')end
   drawAt(save,draw,1,'otherOpacity',480,320)
   local x=G.getScissor();assert(i%2~=0 or x==70,'caller clip was not restored')
   G.setCanvas();local bytes=target:newImageData():getString()
   expected=expected or bytes;assert(expected==bytes,'SAVE pixels flickered between native renderer states')
  end
  write('save-stability.txt','PASS 12 identical SAVE frames across alternating native clips/colors/blend modes; fade survives skipped presentation frames\n')
 end,debug.traceback)
 if not ok then write('save-stability.txt','FAIL '..tostring(err))end
 love.event.quit(ok and 0 or 1)
end
