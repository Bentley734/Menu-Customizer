-- Fit battle controls at their final destination, after native canvas scaling.
return function(mod)
 local G=love.graphics;local pending=setmetatable({},{__mode='k'});local replay=false
 local M={}
 function M.defer(battle,rect)
  local source=G.getCanvas();if not source or replay then return false end
  if not mod.exports.battleUi.nativeEmerald.canPresent(battle)then return false end
  pending[source]={battle=battle,rect=rect};return true
 end
 local clear=G.clear
 G.clear=function(...)local source=G.getCanvas();if source then pending[source]=nil end;return clear(...)end
 local draw=G.draw
 G.draw=function(source,...)
  local item=not replay and pending[source];local args={...}
  if item and not mod.exports.battleUi.nativeEmerald.canPresent(item.battle)then item=nil end
  local out={draw(source,...)}
  if item and type(args[1])=='number'and(args[3]or 0)==0 then
   local x,y,sx,sy=args[1],args[2]or 0,args[4]or 1,args[5]or args[4]or 1
   local ox,oy=args[6]or 0,args[7]or 0;local r=item.rect
   local ax,ay=G.transformPoint(x+(r.x-ox)*sx,y+(r.y-oy)*sy)
   local bx,by=G.transformPoint(x+(r.x+r.w-ox)*sx,y+(r.y+r.h-oy)*sy)
   local rect={x=ax,y=ay,w=bx-ax,h=by-ay}
   local target=G.getCanvas()
   if target then pending[target]={battle=item.battle,rect=rect}
   else
    replay=true;G.push('all');G.origin();G.setShader();G.setScissor()
    local ui=mod.exports.battleUi
    local ok,err=pcall(function()
     if item.battle.phase=='moveSelect'then ui.moveScreen.draw(item.battle,rect,{})else ui.drawBottom(item.battle,rect,{})end
    end)
    G.pop();replay=false;if not ok then error(err,0)end
   end
  end
  return (unpack or table.unpack)(out)
 end
 mod.exports.battlePanelSurface=M;return M
end
