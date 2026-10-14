-- Replace white boot-screen paper while preserving native state/input flow.
return function(mod,palette,active)
 local G=love.graphics
 for _,path in ipairs({'src.ui.IntroMovie','src.ui.YellowIntro','src.ui.TitleState','src.ui.OakSpeech','src.ui.gen2.TitleState','src.ui.gen2.OakSpeech','src.ui.gen2.GoldSilverIntro','src.ui.gen2.CrystalIntro'})do
  local ok,Class=pcall(require,path)
  if ok and type(Class.draw)=='function'and not Class._customBootPaper then
   Class._customBootPaper=true;local draw=Class.draw
   Class.draw=function(self,...)
    local n=tonumber(mod.options:get('introBackgroundColor')or mod.save:get('introBackgroundColor'))or 0
    if not active()or n<=0 then return draw(self,...)end
    local color=palette.color('background',n-1)
    local rectangle,imageDraw,clear=G.rectangle,G.draw,G.clear
    local function paper(x,y,w,h)
     palette.paint(color,rectangle,'fill',x,y,w,h)
    end
    G.push('all');G.setShader();G.setColor(1,1,1,1);paper(0,0,160,144);G.pop()
    G.rectangle=function(mode,x,y,w,h,...)
     local r,g,b=G.getColor()
     if mode=='fill'and r>.985 and g>.985 and b>.985 then return paper(x,y,w,h)end
     return rectangle(mode,x,y,w,h,...)
    end
    G.clear=function(r,g,b,a,...)
     if type(r)=='number'and r>.985 and g>.985 and b>.985 then clear(0,0,0,0);return paper(0,0,160,144)end
     return clear(r,g,b,a,...)
    end
    local result={pcall(draw,self,...)};G.rectangle,G.draw,G.clear=rectangle,imageDraw,clear
    local P=require('src.render.PaletteFX');if P.markTrueColor then P.markTrueColor(0,0,160,144)end
    if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
   end
  end
 end
end
