-- Original Emerald glyphs, fitted to the selected frame's actual interior.
return function(G)
 local M={}
 local function inner(rect,x,w)
  local edge=8*rect.h/48
  return {x=rect.x+x+edge,y=rect.y+edge,w=math.max(1,w-2*edge),h=math.max(1,rect.h-2*edge)}
 end
 local function scale(rect,width,height,viewport)
  local dx,dy=tonumber(viewport and viewport.dpiX)or 1,tonumber(viewport and viewport.dpiY)or 1
  if dx<=0 then dx=1 end;if dy<=0 then dy=1 end
  local p=math.min(rect.w*dx/math.max(1,width),rect.h*dy/height)
  if p>=1 then p=math.floor(p)end
  return p/dx,p/dy,dx,dy
 end
 local function at(rect,sx,sy,dx,dy,x,y,fn)
  G.push('all');G.origin();G.setShader()
  G.setScissor(rect.x,rect.y,rect.w,rect.h)
  G.translate(math.floor(x*dx+.5)/dx,math.floor(y*dy+.5)/dy);G.scale(sx,sy)
  local ok,err=pcall(fn);G.pop();if not ok then error(err,0)end
 end
 local function label(F,s,rect,sx,sy,dx,dy,font,colors,cursor,centerName)
  local width=F.measure(s,{font=font})or 0
  local x=rect.x+8*sx
  if centerName then x=rect.x+(rect.w-width*sx)/2 end
  local y=rect.y+(rect.h-16*sy)/2
  at(rect,sx,sy,dx,dy,x,y,function()
   F.draw(s,0,0,{font=font,colors=colors})
   if cursor then F.drawGlyph(F.CHAR_SELECTOR_ARROW,-9,0,{colors=colors})end
  end)
 end
 function M.commands(F,battle,generation,rect,custom,colors,viewport)
  custom.frames('none',rect,viewport)
  local pane=inner(rect,0,rect.w)
  local promptWidth=pane.w*.40
  local commandWidth=pane.w-promptWidth
  local commands={'FIGHT','BAG','POKéMON','RUN'}
  local width=0;for _,s in ipairs(commands)do width=math.max(width,F.measure(s,{font='normal'})or 0)end
  local cell={w=commandWidth/2,h=pane.h/2}
  local sx,sy,dx,dy=scale(cell,width+8,18*(custom.fontSizing and custom.fontSizing.factor()or 1),viewport)
  for i,s in ipairs(commands)do
   local c={x=pane.x+promptWidth+(i-1)%2*cell.w,y=pane.y+math.floor((i-1)/2)*cell.h,w=cell.w,h=cell.h}
   label(F,s,c,sx,sy,dx,dy,'normal',colors,i==(battle.menuIndex or 1))
  end
  local p=battle.player
  local mon=generation==2 and battle:activeMon('player')or p and p.mon
  local name=p and p.name or mon and(mon.nickname or mon.name)or 'POKéMON'
  local first,last='What will',name..' do?'
  local left={x=pane.x,y=pane.y,w=promptWidth-4*sx,h=pane.h}
  local px,py,pdx,pdy=scale(left,math.max(F.measure(first)or 0,F.measure(last)or 0)+8,36*(custom.fontSizing and custom.fontSizing.factor()or 1),viewport)
  local x=left.x+4*px;local y=left.y+(left.h-32*py)/2
  at(left,px,py,pdx,pdy,x,y,function()
   F.draw(first,0,0,{colors=colors});F.draw(last,0,16,{colors=colors})
  end)
  return true
 end
 function M.moves(F,battle,rect,custom,colors,typeName,viewport)
  custom.frames('moves',rect,viewport)
  local pane=inner(rect,0,rect.w*2/3)
  local cell={w=pane.w/2,h=pane.h/2}
  local names={};local width=0
  for i=1,4 do
   local move=battle.player and battle.player.curMoves and battle.player.curMoves[i]
   local def=move and battle.data.moves[move.id]
   names[i]=def and def.name or '-'
   width=math.max(width,F.measure(names[i],{font='narrow'})or 0)
  end
  local sx,sy,dx,dy=scale(cell,width+16,18*(custom.fontSizing and custom.fontSizing.factor()or 1),viewport)
  for i,s in ipairs(names)do
   local c={x=pane.x+(i-1)%2*cell.w,y=pane.y+math.floor((i-1)/2)*cell.h,w=cell.w,h=cell.h}
   label(F,s,c,sx,sy,dx,dy,'narrow',colors(),i==(battle.moveIndex or 1)or i==battle.moveSwapIndex,true)
  end
  local move=battle.player and battle.player.curMoves and battle.player.curMoves[battle.moveIndex or 1]
  local def=move and battle.data.moves[move.id]
  if def then
   local base=tonumber(def.pp)or 0
   local maximum=move.maxPp or base+(move.ppUps or 0)*math.floor(base/5)
   local pp=string.format('%2d/%2d',move.pp or 0,maximum)
   local kind=typeName(def.type,battle.data)
   local right=inner(rect,rect.w*2/3,rect.w/3)
   local typeW=(F.measure('TYPE/',{font='narrow'})or 0)+(F.measure(kind)or 0)
   local ppW=(F.measure('PP',{font='narrow'})or 0)+8+(F.measure(pp)or 0)
   local rsx,rsy,rdx,rdy=scale(right,math.max(typeW,ppW)+8,36*(custom.fontSizing and custom.fontSizing.factor()or 1),viewport)
   for row=0,1 do
    local w=row==0 and ppW or typeW
    local x=right.x+4*rsx
    local y=right.y+row*right.h/2+(right.h/2-16*rsy)/2
    at(right,rsx,rsy,rdx,rdy,x,y,function()
     local prefix=row==0 and 'PP' or 'TYPE/'
     local c=row==0 and colors(move.pp or 0,maximum)or colors()
     F.draw(prefix,0,0,{font='narrow',colors=c})
     F.draw(row==0 and pp or kind,(F.measure(prefix,{font='narrow'})or 0)+(row==0 and 8 or 0),0,{colors=c})
    end)
   end
  end
  return true
 end
 return M
end
