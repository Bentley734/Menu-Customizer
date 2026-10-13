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
 local function factor()
  local n=tonumber(mod.options:get('battle_font_size')or mod.save:get('battle_font_size'))or 0
  return ({1,1.5,2})[math.max(0,math.min(2,math.floor(n)))+1]
 end
 if Font.wrap then
  local Chrome=require('src.ui.game3.chrome');local window=Chrome.dialogueWindow
  Chrome.dialogueWindow=function(...)
   local x,y,w,h=window(...);local f=active()and factor()or 1
   if f>1 then
    local pitch=math.max(16,Font.linePitch and Font.linePitch()or 16)
    local rows=math.ceil((2*pitch*f+4)/8)
    y,h=math.max(1,y+h-rows),rows
   end
   return x,y,w,h
  end
  local show=Message.show
  Message.show=function(...)
   local result=show(...)
   if active()and Message._frame~='battle' and Message._frame~='braille' and Message._pages then
    local oldFixed,oldScope=mod.exports.dialogueFixedSize,mod.exports.dialogueFontScope
    mod.exports.dialogueFixedSize,mod.exports.dialogueFontScope=true,true
    local ok,pages=pcall(function()
     local out={};local _,_,w=Chrome.dialogueWindow()
     for _,page in ipairs(Message._pages)do
      local limit=w*8-12
      -- Native word wrapping leaves unusually long names unbroken. Split
      -- plain UTF-8 words at glyph boundaries, preserving control sequences.
      page=page:gsub('%S+',function(word)
       if word:find('[<>{}]')or word:find('\252',1,true)or Font.measure(word)<=limit then return word end
       local parts,current={},''
       for c in word:gmatch('[%z\1-\127\194-\244][\128-\191]*')do
        if current~=''and Font.measure(current..c)>limit then parts[#parts+1]=current;current=''end
        current=current..c
       end
       parts[#parts+1]=current;return table.concat(parts,'\n')
      end)
      local lines={};for line in (Font.wrap(page,limit)..'\n'):gmatch('(.-)\n')do lines[#lines+1]=line end
      for i=1,#lines,2 do out[#out+1]=lines[i]..(lines[i+1]and '\n'..lines[i+1]or '')end
     end
     return out
    end)
    mod.exports.dialogueFixedSize,mod.exports.dialogueFontScope=oldFixed,oldScope
    if not ok then error(pages,0)end
    Message._pages,Message._page=pages,1
    Message._total=Font.countChars(pages[1]or '')
    Message._revealed=Message._waiting and Message._total or 0
   end
   return result
  end
 end
 local originalText=Message.drawText
 Message.drawText=function(...)
  if not active()or not Message.open or Message._frame=='battle' or Message._frame=='braille' then return originalText(...)end
  local source=G.getCanvas()
  if not source then return originalText(...)end
  local args={...};local unpack=unpack or table.unpack
  G.push('all')
  local prior,priorScope=mod.exports.dialogueFixedSize,mod.exports.dialogueFontScope;mod.exports.dialogueFixedSize,mod.exports.dialogueFontScope=true,true
  local originalDrawText,draw=Font.draw,Font.draw
  local alignedDraw=function(page,x,y,opts,...)
   local Chrome=require('src.ui.game3.chrome');local left,top,width,height=Chrome.dialogueWindow()
   local f=factor();local pitch=math.max(16,Font.linePitch and Font.linePitch()or 16)*f
   local alignment=tonumber(mod.options:get('dialogueJustify')or mod.save:get('dialogueJustify'))or 1
   local inner=width*8-12;local baseX=left*8+6
   -- Reserve two lines even during typing, keeping page changes stationary.
   local baseY=top*8+math.floor((height*8-(pitch+11*f))/2)-2*f
   local limit=opts and opts.limitChars;local count,lastX,lastY=0,baseX,baseY
   local row=0
   for line in (page..'\n'):gmatch('(.-)\n')do
    local w=Font.measure(line);local slack=math.max(0,inner-w)
    local dx=alignment==2 and math.floor(slack/2)or alignment==3 and slack or 0
    local copy={};for k,v in pairs(opts or {})do copy[k]=v end
    copy.maxWidth=inner;copy._fixedSize=true;copy.limitChars=limit and math.max(0,limit-count)or nil
    local n,ex,ey=draw(line,baseX+dx,baseY+row*pitch,copy,...)
    count=count+(n or 0);lastX,lastY=ex or baseX+dx,ey or baseY+row*pitch
    if limit and count>=limit then break end
    row=row+1
   end
   return count,lastX,lastY
  end
  local ok,queue=pcall(text.capture,function()
   draw=Font.draw;Font.draw=alignedDraw
   return originalText(unpack(args))
  end,true)
  Font.draw=originalDrawText
  mod.exports.dialogueFixedSize,mod.exports.dialogueFontScope=prior,priorScope
  G.pop()
  if not ok then error(queue,0)end
  M.queues[source]=queue
 end
 local originalDraw=G.draw;local replaying=false
 G.draw=function(source,...)
  local result={originalDraw(source,...)}
  local queue=not replaying and M.queues[source]
  local target=G.getCanvas()
  -- Renderer can assemble the window in presentCanvas/uiLayerCanvas before
  -- applying screen effects. These are already final-resolution surfaces.
  local final=not target or target:getWidth()>=G.getWidth() and target:getHeight()>=G.getHeight()
  if queue and final then
   local x,y,rotation,sx,sy,ox,oy=...
   if type(x)=='number' and (rotation or 0)==0 then
    sx=sx or 1;sy=sy or sx
    local prior,fixed=mod.exports.dialogueFontScope,mod.exports.dialogueFixedSize
    mod.exports.dialogueFontScope,mod.exports.dialogueFixedSize=true,true
    replaying=true
    local dpi=target and target:getDPIScale()or G.getDPIScale()
    local ok,err=pcall(text.draw,queue,x-(ox or 0)*sx,y-(oy or 0)*sy,sx,sy,dpi)
    replaying=false;mod.exports.dialogueFontScope,mod.exports.dialogueFixedSize=prior,fixed
    if not ok then error(err,0)end
   end
  end
  return (unpack or table.unpack)(result)
 end
 return M
end
