-- Original Emerald glyphs, fitted to the selected frame's actual interior.
return function(G,mod)
 local M={}
 local function inner(rect,x,w)
  local edge=8*rect.h/48
  local left,right=edge,edge
  local borders=mod and mod.exports.borders
  if borders and mod.exports.battleUi and mod.exports.battleUi.setting('style',1)==3 then
   local il,ir,ds=borders.insets('battle',w/(rect.h/48),48)
   -- DS battle panels are drawn with square-pixel sides at height/48 scale.
   if ds then left,right=il*rect.h/48,ir*rect.h/48 end
  end
  return {x=rect.x+x+left,y=rect.y+edge,w=math.max(1,w-left-right),h=math.max(1,rect.h-2*edge)}
 end
 local factor=1
 local function scale(rect,width,height,viewport)
  local dx,dy=tonumber(viewport and viewport.dpiX)or 1,tonumber(viewport and viewport.dpiY)or 1
  if dx<=0 then dx=1 end;if dy<=0 then dy=1 end
  local normal=math.min(rect.w*dx/math.max(1,width),rect.h*dy/height)
  local p=math.min(normal*factor,rect.w*dx/math.max(1,width),rect.h*dy/(height>18 and 32 or 16))
  p=math.max(1,math.floor(p))
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
  local reserve=12*sx
  local x=rect.x+reserve
  local fonts=mod and mod.exports.allFonts
  if fonts then x=fonts.align(rect.x+reserve,rect.w-reserve,width*sx,'battle',centerName and 2 or 1)
  elseif centerName then x=rect.x+reserve+(rect.w-reserve-width*sx)/2 end
  local y=rect.y+(rect.h-16*sy)/2
  at(rect,sx,sy,dx,dy,x,y,function()
   F.draw(s,0,0,{font=font,colors=colors})
   if cursor then F.drawGlyph(F.CHAR_SELECTOR_ARROW,-10,0,{colors=colors})end
  end)
 end
 local function commands(F,battle,generation,rect,custom,colors,viewport)
  custom.frames('none',rect,viewport)
  local pane=inner(rect,0,rect.w)
  local promptWidth=pane.w*.36
  local commandWidth=pane.w-promptWidth
  local commands=generation<3 and {'FIGHT','POKéMON','BAG','RUN'}or{'FIGHT','BAG','POKéMON','RUN'}
  local width=0;for _,s in ipairs(commands)do width=math.max(width,F.measure(s,{font='normal'})or 0)end
  local cell={w=commandWidth/2,h=pane.h/2}
  local sx,sy,dx,dy=scale(cell,width+14,18,viewport)
  for i,s in ipairs(commands)do
   local c={x=pane.x+promptWidth+(i-1)%2*cell.w,y=pane.y+math.floor((i-1)/2)*cell.h,w=cell.w,h=cell.h}
   label(F,s,c,sx,sy,dx,dy,'normal',colors,i==(battle.menuIndex or 1))
  end
  local p=battle.player
  local mon=generation==2 and battle:activeMon('player')or p and p.mon
  local name=p and p.name or mon and(mon.nickname or mon.name)or 'POKéMON'
  local first,last='What will',name..' do?'
  local promptFont=pane.w<600 and 'narrow'or'normal'
  if pane.w<600 then first,last=name,'What now?'end
  local left={x=pane.x,y=pane.y,w=promptWidth,h=pane.h}
  local px,py,pdx,pdy=scale(left,math.max(F.measure(first,{font=promptFont})or 0,F.measure(last,{font=promptFont})or 0)+8,36,viewport)
  local x=left.x+4*px;local y=left.y+(left.h-32*py)/2
  at(left,px,py,pdx,pdy,x,y,function()
   local fonts=mod and mod.exports.allFonts
   local function prompt(text,y)
    local tx=fonts and fonts.align(0,left.w/px-8,F.measure(text,{font=promptFont})or 0,'battle')or 0
    F.draw(text,tx,y,{font=promptFont,colors=colors})
   end
   prompt(first,0);prompt(last,16)
  end)
  return true
 end
 local function moves(F,battle,rect,custom,colors,typeName,viewport)
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
  local sx,sy,dx,dy=scale(cell,width+14,18,viewport)
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
   local lines={'PP',pp:gsub('%s+',''),'TYPE',kind}
   local widest=0;for _,text in ipairs(lines)do widest=math.max(widest,F.measure(text,{font='normal'})or 0)end
   local rsx,rsy,rdx,rdy=scale(right,widest+4,64,viewport)
   for row,text in ipairs(lines)do
    local w=F.measure(text,{font='normal'})or 0
    local x=right.x+(right.w-w*rsx)/2
    local fonts=mod and mod.exports.allFonts;if fonts then x=fonts.align(right.x,right.w,w*rsx,'battle',2)end
    local y=right.y+(row-1)*right.h/4+(right.h/4-16*rsy)/2
    at(right,rsx,rsy,rdx,rdy,x,y,function()
     F.draw(text,0,0,{font='normal',colors=row==2 and colors(move.pp or 0,maximum)or colors()})
    end)
   end
  end
  return true
 end
 function M.dialogue(F,battle,generation,rect,custom,colors,viewport,decode)
  custom.frames('none',rect,viewport)
  local source=generation==2 and battle:messageLines()or battle.shown or{}
  local lines={};for i,line in ipairs(source)do lines[i]=decode and decode(line)or line end
  local pane=inner(rect,0,rect.w)
  factor=custom.fontSizing and custom.fontSizing.factor()or 1
  local function draw()
   local width=0
   for i,line in ipairs(lines)do if i<=2 then width=math.max(width,F.measure(line)or 0)end end
   local sx,sy,dx,dy=scale(pane,width+16,36,viewport)
   local gap=math.max(0,(pane.h-32*sy)/3)
   for i,line in ipairs(lines)do if i<=2 then
    local tx=pane.x+4*sx
    local fonts=mod and mod.exports.allFonts;if fonts then tx=fonts.align(tx,pane.w-12*sx,(F.measure(line)or 0)*sx,'battle')end
    at(pane,sx,sy,dx,dy,tx,pane.y+gap+(i-1)*(16*sy+gap),function()F.draw(line,0,0,{colors=colors})end)
   end end
   local arrow=generation==2 and battle:messageArrowVisible()or battle.msgWaiting or battle.msgPrompt
   if arrow then at(pane,sx,sy,dx,dy,pane.x+pane.w-8*sx,pane.y+pane.h-16*sy,function()F.drawGlyph(0x7A,0,0,{colors=colors})end)end
  end
  if custom.fontSizing and custom.fontSizing.unscaled then return custom.fontSizing.unscaled(draw)end
  return draw()
 end
 local function run(fn,F,battle,rect,custom,...)
  local args={...};factor=custom.fontSizing and custom.fontSizing.factor()or 1
  local function draw()return fn(F,battle,rect,custom,(unpack or table.unpack)(args))end
  if custom.fontSizing and custom.fontSizing.unscaled then return custom.fontSizing.unscaled(draw)end
  return draw()
 end
 function M.commands(F,battle,generation,rect,custom,colors,viewport)
  factor=custom.fontSizing and custom.fontSizing.factor()or 1
  local function draw()return commands(F,battle,generation,rect,custom,colors,viewport)end
  if custom.fontSizing and custom.fontSizing.unscaled then return custom.fontSizing.unscaled(draw)end
  return draw()
 end
 function M.moves(F,battle,rect,custom,colors,typeName,viewport)
  return run(moves,F,battle,rect,custom,colors,typeName,viewport)
 end
 return M
end
