-- KIM's native HUD retains its original texture. Defer only supported names
-- so their Emerald pixels reach the final window without a 1.5px capture.
return function(mod,palette,active)
 local G=love.graphics;local M={}
 local function theme()
  local C=require('src.render.Font')._menuCustomizerGB
  return C and C.mod==mod and C.theme
 end
 function M.enabled(battle,layout)
  if mod.generation~=1 or not active() or not layout then return false end
  local T=theme();local ui=mod.exports.battleUi
  if not T or not ui or not ui.emeraldFont() or ui.setting('style',1)==2 then return false end
  local physical=math.min(layout.scaleX*(layout.dpiX or 1),layout.scaleY*(layout.dpiY or 1))*.75
  return physical>0
 end
 function M.record(queue,text,x,y,side)
  local T=theme();local width=T and T.measure(text,{battle=true})
  if not width then return nil end -- Native fallback for unsupported scripts.
  local px,py=G.transformPoint(x,y-2)
  queue.entries[#queue.entries+1]={text=text,x=px,y=py,side=side}
  return width*.75
 end
 -- Reserve a complete name row above the native level/status row.
 function M.layout(queue,bands)
  local T=theme();if not T then return bands end
  local dx,dy=bands.dpiX or 1,bands.dpiY or 1
  local width=bands.width or(bands.player and bands.player.x+160*bands.scaleX)
  local unit=math.max(2,math.floor(.75*math.min(bands.scaleX*dx,bands.scaleY*dy)+.5))
  local result={}
  for _,entry in ipairs(queue.entries)do
   local band=bands[entry.side]
   local pixels=unit;local textWidth=T.measure(entry.text,{battle=true})or 0
   if width then pixels=math.max(1,math.min(pixels,math.floor((width*dx-4)/math.max(1,textWidth))))end
   local x=band.x+entry.x*bands.scaleX/2
   local originalY=band.y+(entry.y-band.sourceY)*bands.scaleY/2
   local levelY=originalY+10*bands.scaleY
   local y=math.min(originalY,levelY-13*pixels/dy-2/dy)
   -- If the top edge leaves no room, move the entire HUD body with the name.
   local shift=math.max(0,2/dy-(y+2*pixels/dy))
   band.y=band.y+shift;y=y+shift
   local fonts=mod.exports.allFonts
   if fonts and mod.options:get('allFontAlign')~=nil then
    local left=band.x+(entry.side=='player'and 80 or 8)*bands.scaleX
    x=fonts.align(left,80*bands.scaleX,textWidth*pixels/dx,'battle')
   end
   if width then x=math.max(2/dx,math.min(width-2/dx-textWidth*pixels/dx,x))end
   result[#result+1]={text=entry.text,x=x,y=y,unit=pixels,levelY=levelY+shift,side=entry.side}
  end
  bands.names=result;return bands
 end
 function M.draw(queue,bands)
  local T=theme();if not T then return false end
  if not bands.names then M.layout(queue,bands)end
  local dx,dy=bands.dpiX or 1,bands.dpiY or 1
  local prior=mod.exports.fontAspect;mod.exports.fontAspect={dx,dy}
  G.push('all')
  local ok,err=pcall(function()
   G.origin();G.setShader();G.setScissor()
   for _,entry in ipairs(bands.names)do
    G.push('all');G.translate(math.floor(entry.x*dx+.5)/dx,math.floor(entry.y*dy+.5)/dy);G.scale(entry.unit/dx,entry.unit/dy)
    local colors=palette.colors('name');colors._opacity=bands.opacity or 1
    local result={pcall(T.draw,entry.text,0,0,{battle=true,colors=colors})};G.pop()
    if not result[1]then error(result[2],0)end
   end
  end)
  G.pop();mod.exports.fontAspect=prior
  if not ok then error(err,0)end;return true
 end
 return M
end
