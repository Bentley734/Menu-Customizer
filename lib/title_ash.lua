return function(mod,active)
 local ok,Title=pcall(require,'src.ui.TitleState');if not ok or Title._customAshArtwork then return end
 Title._customAshArtwork=true;local draw=Title.draw;local ash
 Title.draw=function(self,...)
  if not(active()and tonumber(mod.options:get('introTrainer'))==1 and self.player)then return draw(self,...)end
  local G=love.graphics;local P=require('src.render.PaletteFX');local imageDraw=G.draw;local redraw=P.markUiSpriteRedraw
  if not ash then ash=assert(mod.assets:image('assets/title-ash.png'));ash:setFilter('linear','linear')end
  local pw,ph=self.player:getDimensions();local w,h=ash:getDimensions();local scale=56/h;local shown=false
  local function player(image,x,y)
   if not image or not image.getDimensions then return false end
   local iw,ih=image:getDimensions();return iw==pw and ih==ph and x and x>=82 and x<=114 and y and y>=64 and y<=136
  end
  G.draw=function(image,a,b,c,...)
   local x,y=type(a)=='number'and a or b,type(a)=='number'and b or c
   if player(image,x,y)then
    if not shown then
     shown=true;local ax,ay=82,80
     -- Render once at final resolution. A low-resolution underlay leaves
     -- dark pixels showing through semi-transparent illustration edges.
     if redraw then redraw(ash,nil,ax,ay,{sx=scale,sy=scale})
     else
      G.push('all');G.setShader();G.setBlendMode('alpha','alphamultiply');G.setColor(1,1,1,1)
      imageDraw(ash,ax,ay,0,scale,scale);G.pop()
     end
    end
    return
   end
   return imageDraw(image,a,b,c,...)
  end
  if redraw then P.markUiSpriteRedraw=function(image,quad,x,y,opts)if player(image,x,y)then return end;return redraw(image,quad,x,y,opts)end end
  local result={pcall(draw,self,...)};G.draw=imageDraw;P.markUiSpriteRedraw=redraw
  if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
 end
end
