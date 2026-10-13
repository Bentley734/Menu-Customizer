-- Non-START selection arrows share one independent setting. Fit artwork in
-- the native eight-pixel cursor column, retaining a pixel gap on each side.
return function(mod,icons,setting,active)
 local M={names={'ARROW','POKEBALL','STAR','HEART','LIGHTNING','CRESCENT','DIAMOND','FLAME','PSYCHIC EYE','SPIRAL'},ids={3,1,5,6,7,8,9,10,11,12}}
 local G=love.graphics
 local ball={'..1111..','.122221.','12222221','11144111','13344331','13333331','.133331.','..1111..'}
 local colors={{0,0,0,1},{.85,.12,.12,1},{1,1,1,1},{.5,.5,.5,1}}
 function M.id()return M.ids[setting('arrowSelector')] or 3 end
 function M.draw(x,y,height,opts)
  local startArrow=opts and opts._startArrow
  local id=startArrow and 3 or M.id()
  if not active() or mod.exports.startSelectorScope and not startArrow then return false end
  if opts and opts.colors and opts.colors.fg and opts.colors.fg[4]==0 then return false end
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
  else icons.draw(id,0,0)end
  G.pop();return true
 end
 return M
end
