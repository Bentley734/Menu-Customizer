return function(mod,active)
 local G=love.graphics;local logo
 for _,path in ipairs({'src.ui.TitleState','src.ui.gen2.TitleState'})do
  local ok,Class=pcall(require,path)
  if ok and type(Class.draw)=='function'and not Class._customHdLogo then
   Class._customHdLogo=true;local draw=Class.draw
   Class.draw=function(self,...)
    if not(active()and self.logo)then return draw(self,...)end
    if not logo then logo=assert(mod.assets:image('assets/pokemon-logo.png'));logo:setFilter('linear','linear')end
    local imageDraw=G.draw;local w,h=logo:getDimensions();local scale=128/w
    local raised=(tonumber(mod.options:get('introFontSize')or mod.save:get('introFontSize'))or 0)>0 and 7 or 0
    local P=require('src.render.PaletteFX');local replay=P.markUiSpriteRedraw
    if replay then P.markUiSpriteRedraw=function(image,quad,x,y,opts)
     if image==self.logo then y=y-raised end
     return replay(image,quad,x,y,opts)
    end end
    G.draw=function(image,x,y,...)
     if image~=self.logo then return imageDraw(image,x,y,...)end
     y=y-raised
     if tonumber(mod.options:get('introLogo')or mod.save:get('introLogo'))==0 then return imageDraw(image,x,y,...)end
     -- Queue the HD image only: the pixel-canvas underlay leaves a stepped
     -- silhouette visible through its antialiased transparent edge.
     if replay then replay(logo,nil,16,y,{sx=scale,sy=scale})
     else
      G.push('all');G.setShader();G.setColor(1,1,1,1)
      imageDraw(logo,16,y,0,scale,scale);G.pop()
     end
    end
    local result={pcall(draw,self,...)};G.draw=imageDraw;P.markUiSpriteRedraw=replay
    if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
   end
  end
 end
end
