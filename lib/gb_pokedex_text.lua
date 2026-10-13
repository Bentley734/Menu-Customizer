-- Keep description pagination separate from 1025Dex's stats/form pages.
return function(Font,current)
 local M={}
 function M.pages(text,width,rows)
  local pages={};local lines={};local line=''
  local function finishLine()if line~=''then lines[#lines+1]=line;line=''end end
  local function finishPage()
   finishLine();for i=1,#lines,rows do local page={};for j=i,math.min(#lines,i+rows-1)do page[#page+1]=lines[j]end;pages[#pages+1]=page end;lines={}
  end
  for chunk in (tostring(text or '')..'\f'):gmatch('(.-)\f')do
   for word in chunk:gsub('[\n\v]',' '):gmatch('%S+')do
    if line~=''and Font.width(line..' '..word)>width then finishLine()end
    if Font.width(word)>width then
     finishLine();local pos=1
     while pos<=#word do
      local last=word:sub(pos,pos)=='<'and word:find('>',pos,true)
      local glyph=last and word:sub(pos,last)or word:match('[%z\1-\127\194-\244][\128-\191]*',pos)
      if not glyph then glyph=word:sub(pos,pos)end
      if line~=''and Font.width(line..glyph)>width then finishLine()end
      line=line..glyph;pos=pos+#glyph
     end
    else line=line==''and word or line..' '..word end
   end
   finishPage()
  end
  return pages
 end
 local Entry=require('src.ui.DexEntryMenu');Entry.screenId='DexEntryMenu'
 require('src.ui.PokedexMenu').screenId='PokedexMenu'
 Entry._menuCustomizerDexCurrent=current
 if Entry._menuCustomizerDexText then return M end
 Entry._menuCustomizerDexText=true
 local reading
 function M.measurements(e)
  local inches=math.floor((e.heightM and e.heightM/0.0254 or (e.heightFt or 0)*12+(e.heightIn or 0))+.5)
  local pounds=e.weightKg and e.weightKg*2.2046226218 or (e.weight or 0)/10
  return string.format("%d'%02d\"",math.floor(inches/12),inches%12),string.format('%.1f lb',pounds)
 end
 -- Scope the presentation around the native and 1025Dex renderers together.
 -- Every temporary hook is restored, including when an underlying mod fails.
 local presenting=false
 local function present(game,def,sprite,owned,page,fn,...)
  local C=Entry._menuCustomizerDexCurrent();local G=love and love.graphics
  if presenting or not(C and C.live()and G and C.borders)then return fn(...)end
  presenting=true
  local fontDraw,rect,imageDraw=Font.draw,G.rectangle,G.draw
  local oldScope=C.drawScope;C.drawScope=true
  local fx=game.data.field and game.data.field.overworldFx
  local frame=fx and fx.pokedexFrame;if fx then fx.pokedexFrame=nil end
  local e=def.dexEntry or {};local height,weight=M.measurements(e)
  local visible=owned or game.save and game.save.pokedex and game.save.pokedex.owned[def.id]
  local painted=false
  G.rectangle=function(mode,x,y,w,h,...)
   if not painted and mode=='fill'and x==0 and y==0 and w==160 and h==144 then
    painted=true
    if page==1 then C.borders.drawPixels(0,0,160,80,nil,'pokedex');C.borders.drawPixels(0,72,160,72,nil,'pokedex')
    else C.borders.drawPixels(0,0,160,144,nil,'pokedex')end
    return
   end
   return rect(mode,x,y,w,h,...)
  end
  Font.draw=function(text,x,y,...)
   if page==1 then
    -- Replace both cartridge unit layouts with readable English labels.
    if y==48 or y==64 and x>=72 then
     if x==72 then
      local label,value=y==48 and 'Height'or 'Weight',y==48 and height or weight
      fontDraw(label,72,y-8,...);return fontDraw(visible and value or '?',72,y,...)
     end
     return
    end
    if x==8 and y>=88 then x=12 end
   else
    x=math.max(12,math.min(x,148-Font.width(text)))
    if y>=72 then y=72+math.floor((y-72)*.875)else y=math.max(12,y)end
   end
   return fontDraw(text,x,y,...)
  end
  G.draw=function(image,x,y,...)
   if page==2 and sprite and image==sprite and type(x)=='number'then
    -- The native entry mirrors its front image; stats must use the same pose.
    return imageDraw(image,x+sprite:getWidth(),y,0,-1,1)
   end
   return imageDraw(image,x,y,...)
  end
  local result={pcall(fn,...)}
  Font.draw,G.rectangle,G.draw=fontDraw,rect,imageDraw
  if fx then fx.pokedexFrame=frame end
  C.drawScope=oldScope;presenting=false
  if not result[1]then error(result[2],0)end
  return (unpack or table.unpack)(result,2)
 end
 local function layout(game,def,forceOwned)
  local C=Entry._menuCustomizerDexCurrent();local e=def and def.dexEntry
  local source=e and game and game.data and game.data.text and game.data.text[e.text]
  local owned=forceOwned or game and game.save and game.save.pokedex and game.save.pokedex.owned and def and game.save.pokedex.owned[def.id]
  if not(C and C.live()and source and owned)then return nil end
  local old=C.drawScope;C.drawScope=true
  -- Leave room for the cartridge printer's final full stop and text outline.
  local ok,pages=pcall(M.pages,source:gsub('%.%s*$',''),136,3);C.drawScope=old
  if not ok then error(pages,0)end;return pages
 end
 local new,draw,update,render=Entry.new,Entry.draw,Entry.update,Entry.render
 Entry.new=function(...)
  local self=new(...);local pages=layout(self.game,self.def,self.forceOwned)
  if pages then self._dexDescriptionPage=1;self._dexDescriptionCount=#pages;self.pageCount=1 end
  return self
 end
 Entry.render=function(game,def,sprite,owned,trueColor,page,state)
  local pages=layout(game,def,owned)
  if not pages then return render(game,def,sprite,owned,trueColor,page,state)end
  local chunks={};for _,lines in ipairs(pages)do chunks[#chunks+1]=table.concat(lines,'\n')end
  local e=def.dexEntry;local source=game.data.text[e.text]
  game.data.text[e.text]=table.concat(chunks,'\f')
  local index=reading and reading._dexDescriptionPage or page
  local result={pcall(present,game,def,sprite,owned,1,render,game,def,sprite,owned,trueColor,index,state)}
  game.data.text[e.text]=source
  if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
 end
 Entry.draw=function(self,...)
  local prior=reading;reading=self
  local pages=layout(self.game,self.def,self.forceOwned)
  if pages then self._dexDescriptionCount=#pages;self._dexDescriptionPage=math.max(1,math.min(self._dexDescriptionPage or 1,#pages));self.pageCount=1 end
  local result={pcall(present,self.game,self.def,self.sprite,self.forceOwned,self.page,draw,self,...)};reading=prior
  if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
 end
 Entry.update=function(self,...)
  local C=Entry._menuCustomizerDexCurrent()
  if C and C.live()and self.page==1 and (self.picDelay or 0)<=0 and not self:crying()then
   local input=self.game.input;local index=self._dexDescriptionPage or 1;local count=self._dexDescriptionCount or 1
   if (input:wasPressed('a')or input:wasPressed('down'))and index<count then self._dexDescriptionPage=index+1;return end
   if input:wasPressed('up')and index>1 then self._dexDescriptionPage=index-1;return end
  end
  local prior=self.page;local result={update(self,...)}
  if prior==2 and self.page==1 then self._dexDescriptionPage=self._dexDescriptionCount or 1 end
  return (unpack or table.unpack)(result)
 end
 return M
end
