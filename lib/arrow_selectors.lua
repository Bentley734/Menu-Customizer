-- Non-START selection arrows share one independent setting. Fit artwork in
-- the native eight-pixel cursor column, retaining a pixel gap on each side.
return function(mod,icons,setting,active)
 local M={names={'ARROW','POKEBALL','STAR','HEART','LIGHTNING','CRESCENT','DIAMOND','FLAME','PSYCHIC EYE','SPIRAL','UNDERLINE','DOTS','NONE','STARDEW'},ids={3,1,5,6,7,8,9,10,11,12,2,4,0,14}}
 local G=love.graphics
 local ball={'..1111..','.122221.','12222221','11144111','13344331','13333331','.133331.','..1111..'}
 local colors={{0,0,0,1},{.85,.12,.12,1},{1,1,1,1},{.5,.5,.5,1}}
 function M.id()return M.ids[setting('arrowSelector')] or 3 end
 function M.draw(x,y,height,opts)
  local startArrow=opts and opts._startArrow
  local id=opts and opts._selectorStyle and M.ids[opts._selectorStyle]or startArrow and 3 or M.id()
  if not active() or mod.exports.startSelectorScope and not startArrow then return false end
  if opts and opts.colors and opts.colors.fg and opts.colors.fg[4]==0 then return false end
  if id==14 then return true end
  if id==0 then
   -- OPTIONS already paints the complete selected row. Other native cursors
   -- own this compact row highlight when no marker is requested.
   if not(opts and opts._selectionHighlight)then
    G.push('all');G.setShader();G.setColor(.25,.65,1,(setting('selectionHighlight')or 25)/100)
    G.rectangle('fill',x,y,opts and opts._selectorWidth and opts._selectorWidth+8 or 48,height or 8);G.pop()
   end
   return true
  end
  -- One source pixel stays one logical pixel: never discard rows or columns.
  G.push('all');G.setShader();G.translate(x,y+((height or 8)>8 and 4 or 0))
  if id==3 then
   -- The themed atlas has no reliable selector cell. Draw explicit pixels.
   local arrow={'1.....','11....','111...','1111..','11111.','1111..','111...','11....'}
   G.setColor(1,1,1,1)
   for row,s in ipairs(arrow)do for col=1,6 do if s:sub(col,col)=='1'then
    G.rectangle('fill',col-2,row-2,3,3)
   end end end
   G.setColor(0,0,0,1)
   for row,s in ipairs(arrow)do for col=1,6 do if s:sub(col,col)=='1'then
    G.rectangle('fill',col-1,row-1,1,1)
   end end end
  elseif id==1 then
   for row,s in ipairs(ball)do for col=1,8 do
    local c=colors[tonumber(s:sub(col,col))]
    if c then G.setColor(unpack(c));G.rectangle('fill',col-1,row-1,1,1)end
   end end
  elseif id==2 or id==4 then
   local palette=mod.exports.selectorPalette
   local c=palette and palette.color('text',setting('selectorColor'))or {0,0,0,1}
   local inset=opts and opts._selectorInset or 0;local width=opts and opts._selectorWidth or 8
   local function marker()
    if id==2 then G.rectangle('fill',inset,width>8 and 9 or 7,width,1)
    elseif opts and opts._selectorWidth then G.rectangle('fill',inset-4,3,2,2);G.rectangle('fill',inset+width+2,3,2,2)
    else G.rectangle('fill',3,3,2,2)end
   end
   if palette then palette.paint(c,marker)else G.setColor(unpack(c));marker()end
  else icons.draw(id,0,0)end
  G.pop();return true
 end
 return M
end
