-- Main-menu captions are composited over custom frames, without font paper.
return function(active)
 local ok,M=pcall(require,'src.ui.game3.rse.main_menu_rse')
 if not(ok and type(M.draw)=='function')or M._customTextPaper then return end
 M._customTextPaper=true;local draw=M.draw;local F=require('src.ui.game3.frlg_font')
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
