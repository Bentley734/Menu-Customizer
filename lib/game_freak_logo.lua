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
 -- Keep each original wave moving after the cartridge's 48-step cap.
 local waves={{40,56,80,112},{48,64,88,104},{44,68,76,92},{52,84,100,108}}
 function M.starPositions(timer)
  local positions={};if timer<134 then return positions end
  local moves=math.floor((timer-134)/3)+1
  for w,xs in ipairs(waves)do
   local step=moves-(w-1)*8;local y=88+step
   if step>0 and y<144 then for _,x in ipairs(xs)do positions[#positions+1]={x=x,y=y,lit=moves%2==1}end end
  end
  return positions
 end
 function M.drawStars(self)
  local P=mod.exports.selectorPalette;local choice=tonumber(mod.options:get('gameFreakStarsColor'))
  local FX=require('src.render.PaletteFX')
  G.push('all');G.setShader();G.setColor(1,1,1,1)
  local ok,err=pcall(function()
   for _,star in ipairs(M.starPositions(self.timer))do
    local image=star.lit and(self.smallStarBlink or self.smallStar)or self.smallStar
    if choice then
     local mask=image and M.mask(image,true)
     P.effects.paint(P.color('text',choice),'intro',function()
      if mask then draw(mask,star.x,star.y)else G.rectangle('fill',star.x+3,star.y+1,2,2)end
     end)
     if FX.markTrueColor then local w,h=8,8;if image then w,h=image:getDimensions()end;FX.markTrueColor(star.x,star.y,w,h)end
    elseif image then G.setColor(1,1,1,1);draw(image,star.x,star.y)
    else G.setColor(0,0,0,1);G.rectangle('fill',star.x+3,star.y+1,2,2)end
   end
  end)
  G.pop();if not ok then error(err,0)end
 end
 function M.install()
  if mod.generation~=1 then return end
  local Class=require('src.ui.IntroMovie');local original=Class.draw;local sprite=Class.drawObp0
  local splash=Class.drawSplash
  Class.drawSplash=function(self,...)
   if mod.exports.menuSurfaces and not mod.exports.menuSurfaces.enabled()then return splash(self,...)end
   local printer,rectangle=G.draw,G.rectangle
   -- Remove only native falling stars; preserve the shooting star and logo.
   G.draw=function(image,...)
    if image and(image==self.smallStar or image==self.smallStarBlink)then return end
    return printer(image,...)
   end
   G.rectangle=function(mode,x,y,w,h,...)
    if mode=='fill'and w==2 and h==2 and y>=90 then return end
    return rectangle(mode,x,y,w,h,...)
   end
   local result={pcall(splash,self,...)};G.draw,G.rectangle=printer,rectangle
   if not result[1]then error(result[2],0)end
   -- Paint after the cartridge bars so the stars can leave the visible scene.
   M.drawStars(self)
   return(unpack or table.unpack)(result,2)
  end
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
