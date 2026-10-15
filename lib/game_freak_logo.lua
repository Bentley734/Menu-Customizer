-- Color/shadow the splash emblem and wordmark, never copyright credits.
return function(mod)
 local M={};mod.exports.gameFreakLogo=M
 local G=love.graphics;local masks=setmetatable({},{__mode='k'});local shader;local draw=G.draw
 function M.mask(image,paper)
  if masks[image]then return masks[image]end
  if not shader then shader=G.newShader([[extern bool whitePaper;vec4 effect(vec4 c,Image tex,vec2 uv,vec2 p){vec4 s=Texel(tex,uv);float a=s.a*(whitePaper?1.0-min(s.r,min(s.g,s.b)):1.0);return vec4(1.0,1.0,1.0,a);}]])end
  local w,h=image:getDimensions();local mask=G.newCanvas(w,h);local previous=G.getCanvas()
  G.push('all');G.setCanvas(mask);G.origin();G.setScissor();G.clear(0,0,0,0);G.setBlendMode('replace','premultiplied');G.setColor(1,1,1,1);shader:send('whitePaper',paper);G.setShader(shader)
  local ok,err=pcall(draw,image,0,0);G.setCanvas(previous);G.pop();if not ok then error(err,0)end
  mask:setFilter('linear','linear');masks[image]=mask;return mask
 end
 function M.draw(image,paper,x,y,r,sx,sy,ox,oy)
  if mod.exports.menuSurfaces and not mod.exports.menuSurfaces.enabled()then return false end
  if mod.options:get('gameFreakTextColor')==nil and mod.options:get('gameFreakTextShadowColor')==nil then return false end
  local P=mod.exports.selectorPalette;local mask=M.mask(image,paper);local prior=mod.exports.gameFreakLogoScope;mod.exports.gameFreakLogoScope=true
  local colors=P.colors('intro');mod.exports.gameFreakLogoScope=prior
  local fg=P.effects.resolve(colors.fg,'intro');local shadow=P.effects.resolve(colors.shadow,'intro');local _,_,_,alpha=G.getColor()
  sx=sx or 1;sy=sy or sx
  G.push('all');G.setShader();G.setBlendMode('alpha','alphamultiply')
  local ok,err=pcall(function()
   if (shadow[4]or 0)>0 then G.setColor(shadow[1],shadow[2],shadow[3],(shadow[4]or 1)*alpha);draw(mask,x+sx,y+sy,r,sx,sy,ox,oy)end
   G.setColor(fg[1],fg[2],fg[3],(fg[4]or 1)*alpha);draw(mask,x,y,r,sx,sy,ox,oy)
  end)
  G.pop();if not ok then error(err,0)end
  local FX=require('src.render.PaletteFX');local iw,ih=image:getDimensions()
  if FX.markTrueColor then FX.markTrueColor(x,y,iw*sx,ih*sy)end
  return true
 end
 function M.install()
  if mod.generation~=1 then return end
  local Class=require('src.ui.IntroMovie');local original=Class.draw;local sprite=Class.drawObp0
  if sprite then Class.drawObp0=function(self,image,path,x,y,...)
   if image and(image==self.logo or image==self.gfText)and M.draw(image,true,x,y)then return end
   return sprite(self,image,path,x,y,...)
  end end
  Class.draw=function(self,...)
   local imageDraw=G.draw
   G.draw=function(image,...)
    if image and image==self.studioLogo and M.draw(image,false,...)then return end
    return imageDraw(image,...)
   end
   local result={pcall(original,self,...)};G.draw=imageDraw
   if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
  end
 end
 return M
end
