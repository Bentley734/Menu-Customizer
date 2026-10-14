return function(mod,active)
 local G=love.graphics;local logo
 for _,path in ipairs({'src.ui.TitleState','src.ui.gen2.TitleState'})do
  local ok,Class=pcall(require,path)
  if ok and type(Class.draw)=='function'and not Class._customHdLogo then
   Class._customHdLogo=true;local draw=Class.draw
   Class.draw=function(self,...)
    if not(active()and self.logo and mod.options:get('introLogo')~=0)then return draw(self,...)end
    if not logo then logo=assert(mod.assets:image('assets/pokemon-logo.png'));logo:setFilter('linear','linear')end
    local imageDraw=G.draw;local w,h=logo:getDimensions();local scale=128/w
    G.draw=function(image,x,y,...)
     if image~=self.logo then return imageDraw(image,x,y,...)end
     G.push('all');G.setShader();G.setColor(1,1,1,1)
     imageDraw(logo,16,y,0,scale,scale);G.pop()
     local P=require('src.render.PaletteFX')
     if P.markTrueColor then P.markTrueColor(16,y,128,h*scale)end
     if P.markUiSpriteRedraw then P.markUiSpriteRedraw(logo,nil,16,y,{sx=scale,sy=scale})end
    end
    local result={pcall(draw,self,...)};G.draw=imageDraw
    if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
   end
  end
 end
end
