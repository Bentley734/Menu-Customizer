-- Rasterize HUD names once they reach the actual window, never in GB tiles.
return function(mod)
 if mod.generation~=1 then return end
 local G=love.graphics;local queues=setmetatable({},{__mode='k'});local replay=false
 local screenCovers={}
 local M={};local covers=setmetatable({},{__mode='k'})
 function M.occlude(x,y,w,h)
  local source=G.getCanvas();if not source or replay then return end
  local ax,ay=G.transformPoint(x,y);local bx,by=G.transformPoint(x+w,y+h)
  covers[source]=covers[source]or{};covers[source][#covers[source]+1]={x=ax,y=ay,w=bx-ax,h=by-ay}
 end
 local function visible(item)
  local owner=item.owner;if not owner then return true end
  local mon=owner[item.side]
  if mon~=item.mon or not mon or mon.fainted or owner.fieldCleared then return false end
  if owner.statusHUDVisible and not owner:statusHUDVisible()then return false end
  if item.side=='player'and(owner.showPlayerBack or owner.safari or owner.demo)then return false end
  if item.side=='enemy'and(owner.showEnemyTrainer or owner.enemySendingOut or owner.enemyHudPending)then return false end
  return true
 end
 local function pixelSize(item)
  local e=mod.exports;local theme=e.gbMenus.theme;local r=item.rect
  local dpi=G.getDPIScale and G.getDPIScale()or 1
  local width=theme.measure(item.text,{battle=true,font='normal'})or 1
  local unit=math.max(1,math.floor(math.min(r.w*dpi/math.max(1,width),r.h*dpi/16)))
  return dpi,unit
 end
 local function render(item,clip)
  if not visible(item)then return end
  local e=mod.exports;local theme=e.gbMenus.theme;local r=item.rect
  local dpi,unit=pixelSize(item)
  local priorName,priorBattle,aspect=e.battleNameScope,e.battleFontScope,e.fontAspect
  e.battleNameScope,e.battleFontScope,e.fontAspect=true,true,nil
  G.push('all');G.origin();G.setShader();G.setScissor();if clip then G.setScissor(clip.x,clip.y,clip.w,clip.h)end;G.setBlendMode('alpha','alphamultiply')
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
  local owner=e.battleHudOwner;local side=y==0 and'enemy'or'player'
  q[tostring(x)..':'..tostring(y)]={text=display,owner=owner,side=side,mon=owner and owner[side],rect={x=ax,y=ay,w=bx-ax,h=by-ay}}
  return(e.gbMenus.theme.measure(display,{battle=true,font='normal'})or 0)*.75
 end
 local clear=G.clear
 G.clear=function(...)local c=G.getCanvas();if c then queues[c]=nil;covers[c]=nil else screenCovers={}end;return clear(...)end
 local draw=G.draw
 G.draw=function(source,...)
  local q=not replay and queues[source];local a={...};local out={draw(source,...)}
  if (q or covers[source])and type(a[1])=='number'and(a[3]or 0)==0 then
   local target=G.getCanvas();local x,y,sx,sy=a[1],a[2]or 0,a[4]or 1,a[5]or a[4]or 1
   local mapped={}
   for _,r in ipairs(covers[source]or{})do
    local ax,ay=G.transformPoint(x+(r.x-(a[6]or 0))*sx,y+(r.y-(a[7]or 0))*sy)
    local bx,by=G.transformPoint(x+(r.x+r.w-(a[6]or 0))*sx,y+(r.y+r.h-(a[7]or 0))*sy)
    mapped[#mapped+1]={x=ax,y=ay,w=bx-ax,h=by-ay}
   end
   local dest=target and(covers[target]or{})or screenCovers
   if target then covers[target]=dest end
   for _,r in ipairs(mapped)do dest[#dest+1]=r end
   for key,item in pairs(q or{})do local r=item.rect
    local ax,ay=G.transformPoint(x+(r.x-(a[6]or 0))*sx,y+(r.y-(a[7]or 0))*sy)
    local bx,by=G.transformPoint(x+(r.x+r.w-(a[6]or 0))*sx,y+(r.y+r.h-(a[7]or 0))*sy)
    local nextItem={text=item.text,owner=item.owner,side=item.side,mon=item.mon,rect={x=ax,y=ay,w=bx-ax,h=by-ay}}
    if target then queues[target]=queues[target]or{};queues[target][key]=nextItem
    else
     -- The shadow/outline extends one font pixel left of the glyph anchor.
     -- Expand its ink bounds before subtracting child windows, so those
     -- windows still occlude the entire shadow as well as the foreground.
     local dpi,unit=pixelSize(nextItem)
     local painted=nextItem.rect
     local left=math.min(painted.x,math.floor(painted.x*dpi+.5)/dpi-unit/dpi)
     local clips={{x=left,y=painted.y,w=painted.x+painted.w-left,h=painted.h}}
     for _,c in ipairs(screenCovers)do local nextClips={}
      for _,p in ipairs(clips)do
       local l,t=math.max(p.x,c.x),math.max(p.y,c.y);local rr,bb=math.min(p.x+p.w,c.x+c.w),math.min(p.y+p.h,c.y+c.h)
       if l>=rr or t>=bb then nextClips[#nextClips+1]=p
       else
        local function add(x,y,w,h)if w>0 and h>0 then nextClips[#nextClips+1]={x=x,y=y,w=w,h=h}end end
        add(p.x,p.y,p.w,t-p.y);add(p.x,bb,p.w,p.y+p.h-bb);add(p.x,t,l-p.x,bb-t);add(rr,t,p.x+p.w-rr,bb-t)
       end
      end
      clips=nextClips
     end
     replay=true;for _,clip in ipairs(clips)do render(nextItem,clip)end;replay=false
    end
   end
  end
  return(unpack or table.unpack)(out)
 end
 local F=require('src.render.Font');local box=F.drawBox
 F.drawBox=function(tx,ty,tw,th,...)M.occlude(tx*8,ty*8,tw*8,th*8);return box(tx,ty,tw,th,...)end
 mod.exports.battleNameSurface=M
end
