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
  local result={pcall(render,game,def,sprite,owned,trueColor,index,state)}
  game.data.text[e.text]=source
  if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
 end
 Entry.draw=function(self,...)
  local prior=reading;reading=self
  local pages=layout(self.game,self.def,self.forceOwned)
  if pages then self._dexDescriptionCount=#pages;self._dexDescriptionPage=math.max(1,math.min(self._dexDescriptionPage or 1,#pages));self.pageCount=1 end
  local result={pcall(draw,self,...)};reading=prior
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
