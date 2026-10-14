-- Raise the title portraits and their palette/replay regions together.
return function(mod,active)
 local ok,Title=pcall(require,'src.ui.TitleState');if not ok or Title._customPortraitPosition then return end
 Title._customPortraitPosition=true;local draw=Title.draw
 Title.draw=function(self,...)
  if not active() or self.menuOpen then return draw(self,...)end
  local G=love.graphics;local P=require('src.render.PaletteFX')
  local imageDraw,replay,mark=G.draw,P.markUiSpriteRedraw,P.markTrueColor
  local current=self.currentSprite;local mon,bounds
  self.currentSprite=function(state,...)
   local sprite,color=current(state,...);mon=sprite;return sprite,color
  end
  local function trainer(image,x,y)
   if x==82 and y==80 then return true end
   if not self.player or not image or not image.getDimensions then return false end
   local w,h=image:getDimensions();local pw,ph=self.player:getDimensions()
   return w==pw and h==ph and x and x>=82 and x<=114 and y and y>=64 and y<=144
  end
  G.draw=function(image,a,b,c,...)
   local plain=type(a)=='number';local x,y=plain and a or b,plain and b or c
   if image==mon and mon then
    local w,h=mon:getDimensions();bounds={x,y,w,h}
    if self.scrollPhase=='in' or self.scrollPhase=='out' then
     mod.exports.titleScrollPortrait={image=mon,state=self,width=w,height=h,y=y-5}
     return
    end
    if plain then return imageDraw(image,a,b-5,c,...)else return imageDraw(image,a,b,c-5,...)end
   elseif trainer(image,x,y)then
    if plain then return imageDraw(image,a,b-5,c,...)else return imageDraw(image,a,b,c-5,...)end
   end
   return imageDraw(image,a,b,c,...)
  end
  if replay then P.markUiSpriteRedraw=function(image,quad,x,y,opts)
   if image==mon and (self.scrollPhase=='in' or self.scrollPhase=='out')then return end
   if image==mon or trainer(image,x,y)then y=y-5 end
   return replay(image,quad,x,y,opts)
  end end
  if mark then P.markTrueColor=function(x,y,w,h,...)
   if bounds and x>=bounds[1] and y>=bounds[2] and x+w<=bounds[1]+bounds[3] and y+h<=bounds[2]+bounds[4]then y=y-5 end
   return mark(x,y,w,h,...)
  end end
  local result={pcall(draw,self,...)}
  G.draw=imageDraw;P.markUiSpriteRedraw=replay;P.markTrueColor=mark;self.currentSprite=current
  if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
 end
end
