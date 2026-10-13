-- Label display only: teaching and compatibility continue through the engine.
return function(mod,active)
 local T=require('src.ui.game3.tm_case')
 T._menuCustomizerLabels={mod=mod,active=active}
 if T._menuCustomizerLabelsWrapped then return end
 local F=require('src.ui.game3.frlg_font')
 local Items=require('src.core.game3.items_data')
 local Pokemon=require('src.core.game3.pokemon')
 local Chrome=require('src.ui.game3.tm_case_chrome')
 local draw=T.draw
 T.draw=function(...)
  local state=T._menuCustomizerLabels
  if not state.active()then return draw(...)end
  local rows=T.list();local shown={}
  local fontDraw,hmIcon=F.draw,Chrome.drawHmIcon
  F.draw=function(text,x,y,opts)
   local slot=type(y)=='number'and (y-10)/16+1
   local row=slot and slot==math.floor(slot)and slot>=1 and slot<=5 and rows[(T.scroll or 0)+slot]
   if row and type(x)=='number'and x>=88 and not(x==206 and opts and opts.small)then
    if not shown[slot]then
     local number=Items.tmNumber(row.id)
     local move=Pokemon.moveName(Pokemon.moveFromTmItem(row.id))
     if not number or not move then return fontDraw(text,x,y,opts)end
     local label=string.format(Items.isHm(row.id)and'HM%02d %s'or'TM%02d %s',number,move)
     local copy={};for k,v in pairs(opts or {})do copy[k]=v end
     copy.small=false;copy.maxWidth=116
     fontDraw(label,88,y,copy)
     shown[slot]=88+math.min(116,F.measure(label,copy))
    end
    return 1,shown[slot],y
   end
   return fontDraw(text,x,y,opts)
  end
  -- The explicit HM prefix replaces the tiny cartridge HM badge.
  Chrome.drawHmIcon=function()end
  local results={pcall(draw,...)}
  F.draw,Chrome.drawHmIcon=fontDraw,hmIcon
  if not results[1]then error(results[2],0)end
  return (unpack or table.unpack)(results,2)
 end
 T._menuCustomizerLabelsWrapped=true
end
