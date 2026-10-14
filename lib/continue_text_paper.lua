-- Main-menu captions are composited over custom frames, without font paper.
return function(active)
 local ok,M=pcall(require,'src.ui.game3.rse.main_menu_rse')
 if not(ok and type(M.draw)=='function')or M._customTextPaper then return end
 M._customTextPaper=true;local draw=M.draw;local F=require('src.ui.game3.frlg_font')
 local details=M._drawContinue
 if type(details)=='function'then
  M._drawContinue=function(self,x,y,c,...)
   if not active()then return details(self,x,y,c,...)end
   local Rom=require('src.core.game3.rom_text');local original=F.draw;local info=self.info or {}
   local player=Rom.plain('gText_ContinueMenuPlayer')
   local time=string.format('%d:%02d',info.hours or 0,info.minutes or 0)
   local badges=tostring(info.badges or 0);local edge=x+208-4
   F.draw=function(text,px,py,opts,...)
    if py==y+17 then
     if px==x+100-F.measure(info.name or '')then
      px=math.min(x+4+F.measure(player)+6,x+104-F.measure(text))
     elseif px==x+108 then px=edge-F.measure(time)-6-F.measure(text)
     elseif px==x+208-F.measure(time)then px=edge-F.measure(text)end
    elseif py==y+33 then
     if px==x+108 then px=edge-F.measure(badges)-6-F.measure(text)
     elseif px==x+208-F.measure(badges)then px=edge-F.measure(text)end
    end
    return original(text,px,py,opts,...)
   end
   local result={pcall(details,self,x,y,c,...)};F.draw=original
   if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
  end
 end
 M.draw=function(self,...)
  if not active()then return draw(self,...)end
  local original=F.draw
  F.draw=function(text,x,y,opts,...)
   local copy={};for k,v in pairs(opts or {})do copy[k]=v end
   copy.colors={};for k,v in pairs(opts and opts.colors or {})do copy.colors[k]=v end
   copy.colors.bg={0,0,0,0}
   if self.state~='options' and self.state~='mystery_gift' and M.windowFor then
    for i in ipairs(self.items or {})do
     local window=M.windowFor(self.menuType,i)
     if window and x==window.left*8 then x=x+4;break end
    end
   end
   return original(text,x,y,copy,...)
  end
  local result={pcall(draw,self,...)};F.draw=original
  if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
 end
end
