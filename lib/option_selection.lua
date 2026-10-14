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
   local printer=Font.draw
   if active()and version=='emerald'and menu._st and page then
    local Options=require('src.core.game3.options');local Rom=require('src.core.game3.rom_text')
    local values=Options.block(menu._st.ctx.options);local chosen={}
    for slot=1,menu.VISIBLE or 7 do
     local entry=page.rows[(page.scroll or 0)+slot];local cart=entry and entry.cart
     if cart and cart.choices then
      local key=cart.choices[(tonumber(values[cart.key])or 0)+1]
      if key then chosen[41+(slot-1)*16]=tostring(Rom.plain(key)):gsub('{COLOR[^}]*}',''):gsub('{SHADOW[^}]*}',''):gsub('{HIGHLIGHT[^}]*}',''):gsub('\252[\1\2\3].',''):gsub('\252\4...','')end
     end
    end
    Font.draw=function(text,x,y,opts,...)
     local selected=x>=120 and chosen[y]==text
     local style=setting('choiceSelector')or 14
     if selected and style==14 then
      local copy={};for k,v in pairs(opts or {})do copy[k]=v end
      copy._choiceColor=setting('choiceSelectorColor')or 0;opts=copy
     end
     local result={printer(text,x,y,opts,...)}
     if selected and style~=14 then
      local width=Font.measure(text,opts)
      mod.exports.arrowSelectors.draw(x-9,y,16,{_selectorStyle=style,_selectorInset=9,_selectorWidth=width})
     end
     return (unpack or table.unpack)(result)
    end
   end
   if active()and page then
    local aligned=Font.draw;local columns={};local valueX,edge,y0,pitch=146,216,58,13
    if version=='emerald'then valueX,edge,y0,pitch=120,216,41,16
    elseif menu._data and menu._data.rows then
     local first=menu._data.rows[1];valueX=first.choices[1].x;edge=216;y0=first.y;pitch=16
    end
    for slot=1,menu.VISIBLE or 7 do
     local entry=page.rows[(page.scroll or 0)+slot]
     if entry and entry.value and not entry.cart then columns[y0+(slot-1)*pitch]=true end
    end
    Font.draw=function(text,x,y,opts,...)
     if x==valueX and columns[y]then x=edge-Font.measure(text,opts)end
     return aligned(text,x,y,opts,...)
    end
   end
   local result={pcall(function(...)return mod.exports.customization.withRows(row,page and page.rows,draw,...)end,...)};G.setColor=setColor;Font.draw=printer
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
