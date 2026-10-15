-- Screen classification; KIM1025 owns entry layout and sprite presentation.
return function(Font,current,mod)
 require('src.ui.DexEntryMenu').screenId='DexEntryMenu'
 require('src.ui.PokedexMenu').screenId='PokedexMenu'
 -- Cooperate with KIM's existing pagination without replacing its sprite/layout ownership.
 mod.events:on('mods.loaded',function(event)
  local e=event.loader and event.loader.exports and event.loader.exports.kim1025
  local pages=e and e.pokedexPresentation
  if pages and not pages._menuCustomizerInsets then
   pages._menuCustomizerInsets=true;local original=pages.pages
   pages.pages=function(text,width,rows)
    local C=current()
    if C and C.live()then local il,ir,ds=C.borders.insets('pokedex',160,72);if ds then width=math.min(width,160-il-ir)end end
    return original(text,width,rows)
   end
  end
 end)
 -- Standalone entry formatting, also available when KIM1025 is disabled.
 local Entry=require('src.ui.DexEntryMenu');local standalone={};mod.exports.pokedexText=standalone
 function standalone.measurements(e)
  local inches=math.floor((e.heightM and e.heightM/0.0254 or(e.heightFt or 0)*12+(e.heightIn or 0))+.5)
  local pounds=e.weightKg and e.weightKg*2.2046226218 or(e.weight or 0)/10
  return string.format("%d'%02d\"",math.floor(inches/12),inches%12),string.format('%.1f lb',pounds)
 end
 function standalone.pages(text,width)
  local lines,line={},''
  for word in tostring(text):gsub('[\n\v\f]',' '):gmatch('%S+')do
   if line~=''and Font.width(line..' '..word)>width then lines[#lines+1]=line;line=''end
   if Font.width(word)>width then
    for c in word:gmatch('[%z\1-\127\194-\244][\128-\191]*')do
     if line~=''and Font.width(line..c)>width then lines[#lines+1]=line;line=''end;line=line..c
    end
   else line=line==''and word or line..' '..word end
  end
  if line~=''then lines[#lines+1]=line end
  local pages={};for i=1,#lines,3 do local page={};for j=i,math.min(i+2,#lines)do page[#page+1]=lines[j]end;pages[#pages+1]=page end
  return pages
 end
 local function layout(game,def,owned)
  local C=current();local e=def and def.dexEntry
  if Entry._kimDexPresentation or not(C and C.live()and e and owned and game.data.text and game.data.text[e.text])then return end
  local il,ir=C.borders.insets('pokedex',160,72);il,ir=math.max(10,il),math.max(10,ir)
  local scope=C.drawScope;C.drawScope=true
  local ok,pages=pcall(standalone.pages,game.data.text[e.text]:gsub('%.%s*$',''),160-il-ir-2);C.drawScope=scope
  if not ok then error(pages,0)end
  return pages,il,ir
 end
 local new,draw,render=Entry.new,Entry.draw,Entry.render
 Entry.new=function(...)
  local self=new(...);local pages=layout(self.game,self.def,self.forceOwned or self.game.save.pokedex and self.game.save.pokedex.owned[self.def.id])
  if pages then self.pageCount=math.max(1,#pages)end;return self
 end
 Entry.draw=function(self,...)
  local pages=layout(self.game,self.def,self.forceOwned or self.game.save.pokedex and self.game.save.pokedex.owned[self.def.id])
  if pages then self.pageCount=math.max(1,#pages);self.page=math.min(self.page,self.pageCount)end
  return draw(self,...)
 end
 Entry.render=function(game,def,sprite,owned,trueColor,page,state)
  local pages,il,ir=layout(game,def,owned)
  if not pages then return render(game,def,sprite,owned,trueColor,page,state)end
  local e=def.dexEntry;local source=game.data.text[e.text];local chunks={}
  for _,lines in ipairs(pages)do chunks[#chunks+1]=table.concat(lines,'\n')end
  game.data.text[e.text]=table.concat(chunks,'\f')
  local height,weight=standalone.measurements(e);local printer=Font.draw
  Font.draw=function(text,x,y,...)
   if (y==48 or y==64)and x>=72 then
    if x==72 then printer(y==48 and'Height'or'Weight',72,y-8,...);return printer(y==48 and height or weight,72,y,...)end
    return
   end
   if x==8 and y>=88 then
    x=mod.exports.allFonts.align(il,160-il-ir,Font.width(text),'pokedex')
   end
   return printer(text,x,y,...)
  end
  local result={pcall(render,game,def,sprite,owned,trueColor,page,state)}
  Font.draw=printer;game.data.text[e.text]=source
  if not result[1]then error(result[2],0)end;return(unpack or table.unpack)(result,2)
 end
 local Hud=require('src.render.HudTiles')
 local original=Hud.statusTile
 Hud.statusTile=function(code,x,y,...)
  local C=current()
  -- The summary's number marker is artwork, rather than Font text.
  if code==0x74 and C and C.drawScope and C.theme.enabled()then
   return Font.draw('No',x,y)
  end
  return original(code,x,y,...)
 end
end
