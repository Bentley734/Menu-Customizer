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
  local _,breaks=s:gsub('\n','')
  local y=rect.y+(rect.h-16*(breaks+1)*sy)/2
  at(rect,sx,sy,dx,dy,x,y,function()
   F.draw(s,0,0,{font=font,colors=colors})
   if cursor then F.drawGlyph(F.CHAR_SELECTOR_ARROW,-10,0,{colors=colors})end
  end)
 end
 local function commands(F,battle,generation,rect,custom,colors,viewport)
  custom.frames('none',rect,viewport)
  local pane=inner(rect,0,rect.w)
  local commands=generation<3 and {'FIGHT','POKéMON','BAG','RUN'}or{'FIGHT','BAG','POKéMON','RUN'}
  local commandOptions=mod.exports.battleCommands
  local commandFont=commandOptions and commandOptions.get('Font',1)==2 and'narrow'or'normal'
  local width=0;for _,text in ipairs(commands)do width=math.max(width,F.measure(text,{font=commandFont})or 0)end
  local p=battle.player
  local mon=generation==2 and battle:activeMon('player')or p and p.mon
  local name=p and p.name or mon and(mon.nickname or mon.name)or 'POKéMON'
  local first,last='What will',name..' do?'
  local prompt=mod.exports.battlePrompt
  local promptFont=prompt and prompt.get('Font',1)==2 and'narrow'or'normal'
  local promptInk=math.max(F.measure(first,{font=promptFont})or 0,F.measure(last,{font=promptFont})or 0)
  -- Allocate by measured text, including the complete selector reservation.
  local originalPromptWidth=pane.w*.34
  local promptWidth=pane.w*.4
  local cell={w=(pane.w-promptWidth)/2,h=pane.h/2}
  local dx,dy=tonumber(viewport and viewport.dpiX)or 1,tonumber(viewport and viewport.dpiY)or 1
  local commandPixels=math.max(1,math.floor(math.min(cell.w*dx/(width+12),cell.h*dy/16)))
  local basePixels=math.max(1,math.floor(math.min(originalPromptWidth*dx/(promptInk+4),pane.h*dy/32)))
  local promptPixels=basePixels*(prompt and prompt.get('Size',2)or 2)
  local promptLines={first,last}
  if promptInk*promptPixels>promptWidth*dx then promptLines={first,name,'do?'}end
  local maxInk=0;for _,text in ipairs(promptLines)do maxInk=math.max(maxInk,F.measure(text,{font=promptFont})or 0)end
  promptPixels=math.max(1,math.min(promptPixels,math.floor(promptWidth*dx/math.max(1,maxInk)),math.floor(pane.h*dy/(#promptLines*11))))
  if commandOptions and commandOptions.get('Size',2)==2 then
   commandPixels=math.max(1,math.min(math.max(commandPixels,promptPixels),math.floor(cell.w*dx/(width+10)),math.floor(cell.h*dy/12)))
  end
  local sx,sy=commandPixels/dx,commandPixels/dy
  local px,py,pdx,pdy=promptPixels/dx,promptPixels/dy,dx,dy
  for i,s in ipairs(commands)do
   local c={x=pane.x+promptWidth+(i-1)%2*cell.w,y=pane.y+math.floor((i-1)/2)*cell.h,w=cell.w,h=cell.h}
   local ink=F.measure(s,{font=commandFont})or 0
   local reserve=10*sx;local slack=math.max(0,c.w-reserve-ink*sx)
   local align=commandOptions and commandOptions.get('Justify',2)or 2
   local x=c.x+reserve+(align==2 and slack/2 or align==3 and slack or 0)
   local y=c.y+(c.h-12*sy)/2-2*sy
   local inkColors=commandOptions and commandOptions.colors(colors)or colors
   at(c,sx,sy,dx,dy,x,y,function()
    F.draw(s,0,0,{font=commandFont,colors=inkColors})
    if i==(battle.menuIndex or 1)then
     local selectorColors={};for k,v in pairs(inkColors)do selectorColors[k]=v end
     local color=commandOptions and commandOptions.get('SelectorColor',-1)or -1
     if color>=0 then selectorColors.fg=mod.exports.selectorPalette.color('text',color)end
     F.drawGlyph(F.CHAR_SELECTOR_ARROW,-10,0,{colors=selectorColors,_selectorStyle=commandOptions and commandOptions.get('Selector',mod.options:get('arrowSelector')or 1)})
    end
   end)
  end
  local left={x=pane.x,y=pane.y,w=promptWidth,h=pane.h}
  local blockHeight=#promptLines*11*py
  local x=left.x;local y=left.y+(left.h-blockHeight)/2-2*py
  at(left,px,py,pdx,pdy,x,y,function()
   for i,text in ipairs(promptLines)do
    local ink=F.measure(text,{font=promptFont})or 0
    local align=prompt and prompt.get('Justify',2)or 2
    local gap=math.max(0,left.w/px-ink)
    local tx=align==2 and gap/2 or align==3 and gap or 0
    F.draw(text,math.floor(tx+.5),(i-1)*11,{font=promptFont,colors=prompt and prompt.colors(colors)or colors})
   end
  end)
  return true
 end
 local function moves(F,battle,rect,custom,colors,typeName,viewport)
  custom.frames('none',rect,viewport)
  local interior=inner(rect,0,rect.w)
  local pane={x=interior.x,y=interior.y,w=interior.w*.72,h=interior.h}
  local list=custom.setting('move_layout',0)==1
  local columns=list and 1 or 2
  local rowCount=list and 4 or 2
  local cell={w=pane.w/columns,h=pane.h/rowCount}
  local names,lines={},{};local rowLines={};for i=1,rowCount do rowLines[i]=1 end
  local function measure(s)return F.measure(s,{font='narrow'})or 0 end
  local nominal=math.max(1,math.floor(math.min(pane.h/64,cell.w/50)))
  local budget=math.max(16,cell.w/nominal-14)
  local function wrap(s)
   if measure(s)<=budget then return s,1 end
   local best,score
   for pos in s:gmatch('() ')do
    local a,b=s:sub(1,pos-1),s:sub(pos+1)
    local n=math.max(measure(a),measure(b))
    if not score or n<score then best={a,b};score=n end
   end
   if not best then
    local chars={};for c in s:gmatch('[%z\1-\127\194-\244][\128-\191]*')do chars[#chars+1]=c end
    local half=math.ceil(#chars/2);best={table.concat(chars,'',1,half),table.concat(chars,'',half+1)}
   end
   return best[1]..'\n'..best[2],2
  end
  local width=0
  for i=1,4 do
   local move=battle.player and battle.player.curMoves and battle.player.curMoves[i]
   local def=move and battle.data.moves[move.id]
   names[i],lines[i]=wrap(def and def.name or '-')
   local row=math.floor((i-1)/columns)+1;rowLines[row]=math.max(rowLines[row],lines[i])
   width=math.max(width,measure(names[i]))
  end
  local totalLines=0;for _,n in ipairs(rowLines)do totalLines=totalLines+n end
  local heights,tops={},{};local top=pane.y
  for row,n in ipairs(rowLines)do tops[row]=top;heights[row]=pane.h*n/totalLines;top=top+heights[row]end
  local priorFactor=factor;factor=math.min(factor,1)
  local sx,sy,dx,dy=scale({w=cell.w,h=pane.h/totalLines},width+12,16,viewport);factor=priorFactor
  if list then
   local pixels=math.max(1,math.floor(math.min(sx*dx*2,cell.w*dx/(width+12),pane.h*dy/(10*totalLines))))
   sx,sy=pixels/dx,pixels/dy
  end
  for i,s in ipairs(names)do
   local row=math.floor((i-1)/columns)+1
   local c={x=pane.x+(i-1)%columns*cell.w,y=tops[row],w=cell.w,h=heights[row]}
   if list then
    local x=mod.exports.allFonts.align(c.x+12*sx,c.w-12*sx,measure(s)*sx,'battle',2)
    local y=c.y+(c.h-10*sy)/2-3*sy
    at(c,sx,sy,dx,dy,x,y,function()
     F.draw(s,0,0,{font='narrow',colors=colors()})
     if i==(battle.moveIndex or 1)or i==battle.moveSwapIndex then F.drawGlyph(F.CHAR_SELECTOR_ARROW,-10,0,{colors=colors()})end
    end)
   else label(F,s,c,sx,sy,dx,dy,'narrow',colors(),i==(battle.moveIndex or 1)or i==battle.moveSwapIndex,true)end
  end
  local move=battle.player and battle.player.curMoves and battle.player.curMoves[battle.moveIndex or 1]
  local def=move and battle.data.moves[move.id]
  if def then
   local base=tonumber(def.pp)or 0
   local maximum=move.maxPp or base+(move.ppUps or 0)*math.floor(base/5)
   local pp=string.format('%2d/%2d',move.pp or 0,maximum)
   local kind=typeName(def.type,battle.data)
   local gap=4*rect.h/48
   local right={x=interior.x+interior.w*.72+gap,y=interior.y,w=interior.w*.28-gap,h=interior.h}
   local lines={'PP',pp:gsub('%s+',''),'TYPE',kind}
   local widest=0;for _,text in ipairs(lines)do widest=math.max(widest,F.measure(text,{font='narrow'})or 0)end
   local rsx,rsy,rdx,rdy=scale(right,widest+4,64,viewport)
   if list then local pixels=math.max(1,math.floor(math.min(rsx*rdx*2,right.w*rdx/(widest+4),right.h*rdy/40)));rsx,rsy=pixels/rdx,pixels/rdy end
   for row,text in ipairs(lines)do
    local w=F.measure(text,{font='narrow'})or 0
    local x=right.x+(right.w-w*rsx)/2
    local fonts=mod and mod.exports.allFonts;if fonts then x=fonts.align(right.x,right.w,w*rsx,'battle',2)end
    local y=right.y+(row-1)*right.h/4+(right.h/4-(list and 10 or 16)*rsy)/2-(list and 3*rsy or 0)
    at(right,rsx,rsy,rdx,rdy,x,y,function()
     F.draw(text,0,0,{font='narrow',colors=row==2 and colors(move.pp or 0,maximum)or colors()})
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
