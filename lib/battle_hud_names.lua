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
  return physical>=1
 end
 function M.record(queue,text,x,y,side)
  local T=theme();local width=T and T.measure(text,{battle=true})
  if not width then return nil end -- Native fallback for unsupported scripts.
  local px,py=G.transformPoint(x,y-2)
  queue.entries[#queue.entries+1]={text=text,x=px,y=py,side=side}
  return width*.75
 end
 function M.draw(queue,bands)
  local T=theme();if not T then return false end
  local dx,dy=bands.dpiX or 1,bands.dpiY or 1
  local unit=math.max(1,math.floor(.75*math.min(bands.scaleX*dx,bands.scaleY*dy)+.5))
  local prior=mod.exports.fontAspect;mod.exports.fontAspect={dx,dy}
  G.push('all')
  local ok,err=pcall(function()
   G.origin();G.setShader();G.setScissor()
   for _,entry in ipairs(queue.entries)do
    local band=bands[entry.side]
    local x=band.x+entry.x*bands.scaleX/2
    local y=band.y+(entry.y-band.sourceY)*bands.scaleY/2
    G.push('all');G.translate(math.floor(x*dx+.5)/dx,math.floor(y*dy+.5)/dy);G.scale(unit/dx,unit/dy)
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
