-- Defer field letters until the actual UI canvas reaches the framebuffer.
-- This also covers flat presentation and fractional world/UI zoom.
return function(mod,Message,Font,active)
 local G=love.graphics
 local text=assert(load(assert(mod:read('lib/menu_text_surface.lua'))))()(mod,Font)
 local M={queues={}}
 function M.setMod(nextMod)
  mod=nextMod;text=assert(load(assert(mod:read('lib/menu_text_surface.lua'))))()(mod,Font)
 end
 function M.beginFrame()M.queues={}end
 local originalText=Message.drawText
 Message.drawText=function(...)
  if not active()or not Message.open or Message._frame=='battle' or Message._frame=='braille' then return originalText(...)end
  local source=G.getCanvas()
  if not source then return originalText(...)end
  local args={...};local unpack=unpack or table.unpack
  G.push('all');G.translate(0,-3)
  local ok,queue=pcall(text.capture,function()return originalText(unpack(args))end,true)
  G.pop()
  if not ok then error(queue,0)end
  M.queues[source]=queue
 end
 local originalDraw=G.draw;local replaying=false
 G.draw=function(source,...)
  local result={originalDraw(source,...)}
  local queue=not replaying and M.queues[source]
  if queue and not G.getCanvas()then
   local x,y,rotation,sx,sy,ox,oy=...
   if type(x)=='number' and (rotation or 0)==0 then
    sx=sx or 1;sy=sy or sx
    local prior=mod.exports.dialogueFontScope;mod.exports.dialogueFontScope=true
    replaying=true
    local ok,err=pcall(text.draw,queue,x-(ox or 0)*sx,y-(oy or 0)*sy,sx,sy,G.getDPIScale())
    replaying=false;mod.exports.dialogueFontScope=prior
    if not ok then error(err,0)end
   end
  end
  return (unpack or table.unpack)(result)
 end
 return M
end
