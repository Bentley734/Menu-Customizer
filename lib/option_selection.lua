-- Cartridge OPTIONS highlights rows without printing a cursor. Supply one
-- for every settings page, including BACK, at the native row coordinates.
return function(mod,Font,setting,active,version)
 local G=love.graphics;local M={}
 function M.setMod(nextMod,nextVersion)mod,version=nextMod,nextVersion end
 function M.wrap(menu,draw)
  return function(...)
   local setColor=G.setColor
   if active()then G.setColor=function(r,g,b,a)
    if r==0 and g==0 and b==0 and (a==2/16 or a==4/16)then a=0 end
    return setColor(r,g,b,a)
   end end
   local pages=menu._pages or (menu._st and menu._st.pages);local page=pages and pages[#pages]
   local row=page and page.rows and page.rows[page.index or 1]
   local result={pcall(function(...)return mod.exports.customization.with(row,draw,...)end,...)};G.setColor=setColor
   if not result[1]then error(result[2],0)end
   if not active()then return (unpack or table.unpack)(result,2)end
   local pages=menu._pages or (menu._st and menu._st.pages);local page=pages and pages[#pages]
   if not page then return (unpack or table.unpack)(result,2)end
   local x,y,w,h=16,58,208,13
   if menu._data and menu._data.rows then
    x,y,w,h=24,menu._data.rows[1].y,192,16
   elseif version=='emerald' then x,y,w,h=16,41,208,16 end
   y=y+((page.index or 1)-(page.scroll or 0)-1)*h
   G.push('all');G.setShader()
   G.setColor(.25,.65,1,setting('selectionHighlight')/100)
   G.rectangle('fill',x,y,w,h)
   G.setColor(1,1,1,1)
   local row=page.rows and page.rows[page.index or 1]
   local label=row and (row.label or row.cart and row.cart.label) or 'BACK'
   Font.drawGlyph(Font.CHAR_SELECTOR_ARROW,x,y,{colors=Font.COLOR and Font.COLOR.NORMAL,
    _selectionHighlight=true,_selectorWidth=Font.measure and math.min(w-8,Font.measure(label))or 8,_selectorInset=8})
   G.pop()
   return (unpack or table.unpack)(result,2)
  end
 end
 return M
end
