return function(mod)
 if mod.generation>=3 then return end
 local Class=require('src.ui.QuarantineReport');local Font=require('src.render.Font');local G=love.graphics
 local function active()local s=mod.exports.menuSurfaces;return s and s.enabled()end
 local draw,maxOffset=Class.draw,Class.maxOffset
 Class.maxOffset=function(self)if active()then return math.max(0,#self.lines-5)end;return maxOffset(self)end
 Class.draw=function(self,...)
  if not active()then return draw(self,...)end
  Font.drawBox(0,0,20,18);G.setColor(0,0,0,1)
  local function line(text,y)
   local width=Font.width(text);local align=tonumber(mod.options:get('loadReportJustify'))or 2
   local x=align==1 and 8 or align==3 and 152-width or(160-width)/2
   Font.draw(text,math.max(8,math.floor(x)),y)
  end
  line('LOAD REPORT',16)
  local count=math.min(5,#self.lines-self.offset);local top=76-(count-1)*8
  for i=1,count do line(self.lines[self.offset+i],top+(i-1)*16)end
  line('A:CONTINUE',120)
  if self.offset<self:maxOffset()then Font.drawCode(require('src.ui.Theme').moreArrow,144,120)end
 end
 local Screens=require('src.ui.Screens');local push=Screens.push
 Screens.push=function(game,id,...)
  if id=='QuarantineReport'and active()and mod.options:get('loadReportEnabled')==0 then return end
  return push(game,id,...)
 end
end
