-- Replace white boot-screen paper while preserving native state/input flow.
return function(mod,palette,active)
 local G=love.graphics;local keyShader;local starShader;local pending=false;local wideArea={0,0,160,144}
 local function backgroundColor()
  local n=tonumber(mod.options:get('introBackgroundColor')or mod.save:get('introBackgroundColor'))or 0
  return n>0 and palette.color('background',n-1)or nil
 end
 local function extendedPaper(color,fn,...)
  local prior=palette.effects.paperArea;palette.effects.paperArea=wideArea
  local result={pcall(palette.paint,color,fn,...)};palette.effects.paperArea=prior
  if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
 end
 mod.hooks:wrap('render.letterbox',function(next,ctx)
  local result=next(ctx);local boot=pending;pending=false
  if not(boot and active())then return result end
  local sx=ctx.scale/(ctx.dpiX or 1);local sy=ctx.scale/(ctx.dpiY or 1)
  if sx<=0 or sy<=0 then return result end
  local x,y=-ctx.ox/sx,-ctx.oy/sy
  local w,h=ctx.ww/sx,ctx.wh/sy
  wideArea={x,y,w,h}
  G.push('all');G.origin();G.setShader();G.setScissor();G.translate(ctx.ox,ctx.oy);G.scale(sx,sy)
  local color=backgroundColor()
  if color then extendedPaper(color,G.rectangle,'fill',x,y,w,h)
  else G.setColor(1,1,1,1);G.rectangle('fill',x,y,w,h)end
  G.pop();return result
 end)
 local portrait=assert(load(assert(mod:read('lib/boot_sprite_paper.lua'))))()()
 for _,path in ipairs({'src.ui.IntroMovie','src.ui.YellowIntro','src.ui.TitleState','src.ui.OakSpeech','src.ui.gen2.TitleState','src.ui.gen2.OakSpeech','src.ui.gen2.GoldSilverIntro','src.ui.gen2.CrystalIntro'})do
  local ok,Class=pcall(require,path)
  if ok and type(Class.draw)=='function'and not Class._customBootPaper then
   Class._customBootPaper=true;local draw=Class.draw
   Class.draw=function(self,...)
    local n=tonumber(mod.options:get('introBackgroundColor')or mod.save:get('introBackgroundColor'))or 0
    if not active()then return draw(self,...)end
    pending=true
    local SR=require('src.render.SpriteRenderer');local obp=SR.obpImage
    local protected={};local swapped={};local stars={}
    for _,field in ipairs({'smallStar','smallStarBlink','bigStar','studioLogo','logo','gfText'})do if self[field]and (field~='logo'or path=='src.ui.IntroMovie')then stars[self[field]]=true end end
    local function protect(image)if image then protected[image]=true end end
    for _,field in ipairs({'player','pic','yellowPikachu','yellowBubble','walkSheet'})do protect(self[field])end
    if self.currentSprite then local image=self:currentSprite();protect(image)end
    for _,pair in ipairs({{'nidoFrames','nidoPaths'},{'gengarFrames','gengarPaths'}})do
     local frames,paths=self[pair[1]],self[pair[2]]
     if n>0 and frames and paths then for i,file in pairs(paths)do
      local ok,image=pcall(portrait,file)
      if ok then swapped[#swapped+1]={frames,i,frames[i]};frames[i]=image;protect(image)end
     end end
    end
    SR.obpImage=function(path,colors,group)
     -- GAME FREAK lettering is decorative tile text, not a portrait.
     if path==self.gfTextPath or path==self.logoPath then local image=obp(path,colors,group);stars[image]=true;return image end
     if path==self.bigStarPath then local image=obp(path,colors,group);stars[image]=true;return image end
     if n<=0 then return obp(path,colors,group)end
     local ok,image=pcall(portrait,path,colors,group)
     if not ok then image=obp(path,colors,group)end;protect(image);return image
    end
    local color=n>0 and palette.color('background',n-1)or nil
    local rectangle,imageDraw,clear=G.rectangle,G.draw,G.clear
    local function paper(x,y,w,h)
     -- The full-window pass owns customized paper; this canvas is foreground only.
     if color then return end
     return rectangle('fill',x,y,w,h)
    end
    if not keyShader then keyShader=G.newShader([[vec4 effect(vec4 c,Image tex,vec2 uv,vec2 p){vec4 v=Texel(tex,uv);if(min(v.r,min(v.g,v.b))>.985)v.a=0.0;return v*c;}]])end
    G.push('all');G.setShader();G.setColor(1,1,1,1)
    if color then clear(0,0,0,0)else paper(0,0,160,144)end
    G.pop()
    G.rectangle=function(mode,x,y,w,h,...)
     local r,g,b=G.getColor()
     -- Game Freak splash bars are decorative masks, not foreground artwork.
     if path=='src.ui.IntroMovie' and self.phase==2 and mode=='fill'
       and x==0 and w==160 and h==32 and (y==0 or y==112) then return end
     if mode=='fill'and r>.985 and g>.985 and b>.985 then return paper(x,y,w,h)end
     return rectangle(mode,x,y,w,h,...)
    end
    G.clear=function(r,g,b,a,...)
     if type(r)=='number'and r>.985 and g>.985 and b>.985 then clear(0,0,0,0);return paper(0,0,160,144)end
     return clear(r,g,b,a,...)
    end
    G.draw=function(image,...)
     if stars[image]then
      if not starShader then starShader=G.newShader([[vec4 effect(vec4 c,Image tex,vec2 uv,vec2 p){vec4 v=Texel(tex,uv);if(min(v.r,min(v.g,v.b))>.985)v.a=0.0;return vec4(c.rgb,v.a*c.a);}]])end
      local tint=palette.effects.resolve(palette.colors('intro').fg,'intro')
      G.push('all');G.setShader(starShader);G.setColor((unpack or table.unpack)(tint))
      local result={pcall(imageDraw,image,...)};G.pop()
      if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
     end
     if n<=0 or protected[image]or G.getShader()then return imageDraw(image,...)end
     G.push('all');G.setShader(keyShader);local result={pcall(imageDraw,image,...)};G.pop()
     if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
    end
    local result={pcall(draw,self,...)};
    SR.obpImage=obp;for _,slot in ipairs(swapped)do slot[1][slot[2]]=slot[3]end
    G.rectangle,G.draw,G.clear=rectangle,imageDraw,clear
    local P=require('src.render.PaletteFX');if P.markTrueColor then P.markTrueColor(0,0,160,144)end
    if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
   end
  end
 end
end
