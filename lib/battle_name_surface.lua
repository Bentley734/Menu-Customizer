-- Rasterize HUD names once they reach the actual window, never in GB tiles.
return function(mod)
 if mod.generation~=1 then return end
 local G=love.graphics;local queues=setmetatable({},{__mode='k'});local replay=false
 local M={}
 local function render(item)
  local e=mod.exports;local theme=e.gbMenus.theme;local r=item.rect
  local dpi=G.getDPIScale and G.getDPIScale()or 1
  local width=theme.measure(item.text,{battle=true,font='normal'})or 1
  local unit=math.max(1,math.floor(math.min(r.w*dpi/math.max(1,width),r.h*dpi/16)))
  local priorName,priorBattle,aspect=e.battleNameScope,e.battleFontScope,e.fontAspect
  e.battleNameScope,e.battleFontScope,e.fontAspect=true,true,nil
  G.push('all');G.origin();G.setShader();G.setScissor();G.setBlendMode('alpha','alphamultiply')
  G.translate(math.floor(r.x*dpi+.5)/dpi,math.floor(r.y*dpi+.5)/dpi);G.scale(unit/dpi,unit/dpi)
  local ok,err=pcall(e.battleFontSizing.unscaled,function()theme.draw(item.text,0,0,{battle=true,font='normal',colors=e.selectorPalette.colors('name')})end)
  G.pop();e.battleNameScope,e.battleFontScope,e.fontAspect=priorName,priorBattle,aspect
  if not ok then error(err,0)end
 end
 function M.capture(text,x,y)
  local source=G.getCanvas();if not source or replay then return nil end
  local e=mod.exports;local display=e.customization.text(text)
  local width=math.max(48,(y==0 and 88 or 152)-x)
  local ax,ay=G.transformPoint(x,y-1);local bx,by=G.transformPoint(x+width,y+11)
  local q=queues[source]or{};queues[source]=q
  q[tostring(x)..':'..tostring(y)]={text=display,rect={x=ax,y=ay,w=bx-ax,h=by-ay}}
  return(e.gbMenus.theme.measure(display,{battle=true,font='normal'})or 0)*.75
 end
 local clear=G.clear
 G.clear=function(...)local c=G.getCanvas();if c then queues[c]=nil end;return clear(...)end
 local draw=G.draw
 G.draw=function(source,...)
  local q=not replay and queues[source];local a={...};local out={draw(source,...)}
  if q and type(a[1])=='number'and(a[3]or 0)==0 then
   local target=G.getCanvas();local x,y,sx,sy=a[1],a[2]or 0,a[4]or 1,a[5]or a[4]or 1
   for key,item in pairs(q)do local r=item.rect
    local ax,ay=G.transformPoint(x+(r.x-(a[6]or 0))*sx,y+(r.y-(a[7]or 0))*sy)
    local bx,by=G.transformPoint(x+(r.x+r.w-(a[6]or 0))*sx,y+(r.y+r.h-(a[7]or 0))*sy)
    local nextItem={text=item.text,rect={x=ax,y=ay,w=bx-ax,h=by-ay}}
    if target then queues[target]=queues[target]or{};queues[target][key]=nextItem
    else replay=true;render(nextItem);replay=false end
   end
  end
  return(unpack or table.unpack)(out)
 end
 mod.exports.battleNameSurface=M
end
