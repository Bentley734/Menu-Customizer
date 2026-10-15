-- Replace white boot-screen paper while preserving native state/input flow.
return function(mod,palette,active)
 local G=love.graphics;local keyShader;local starShader;local pending=false;local pendingBars;local finalBars;local frameRects;local pendingFight;local wideArea={0,0,160,144}
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
  local result=next(ctx);local boot,bars,fighters=pending,pendingBars,pendingFight;pending=false;pendingBars=nil;pendingFight=nil
  local portrait=mod.exports.titleScrollPortrait;mod.exports.titleScrollPortrait=nil
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
  if bars then
   -- Intro actors belong to the UI canvas. World zoom and UI scaling can
   -- differ, so the cinematic band must follow the same UI transform.
   local uy=frameRects and frameRects.Uy or sy
   local uoy=frameRects and frameRects.uoy or ctx.oy
   finalBars={color=bars,width=ctx.ww,height=ctx.wh,top=uoy+(bars.bandTop or 32)*uy,bottom=uoy+(bars.bandBottom or 112)*uy}
   G.origin();G.setShader();G.setColor((unpack or table.unpack)(bars))
   if (bars[4]or 1)>=1 then
    G.rectangle('fill',0,0,ctx.ww,math.max(0,finalBars.top))
    G.rectangle('fill',0,finalBars.bottom,ctx.ww,math.max(0,ctx.wh-finalBars.bottom))
   end
  end
  G.pop()
  if fighters then
   local R=frameRects;local ux,uy=R and R.Ux or sx,R and R.Uy or sy
   local ox,oy=R and R.uox or ctx.ox,R and R.uoy or ctx.oy
   local factor=fighters.factor;local floor=fighters.floor
   G.push('all');G.origin();G.setShader();G.setBlendMode('alpha','alphamultiply')
   local top=fighters.mode==0 and 32 or fighters.mode==1 and 8 or 0
   G.setScissor(0,math.max(0,oy+top*uy),ctx.ww,math.max(0,(floor-top)*uy))
   for _,actor in ipairs(fighters)do
    G.setColor((unpack or table.unpack)(actor.color))
    G.draw(actor.image,ox+(80+(actor.x-80)*factor)*ux,oy+(floor+(actor.y-floor)*factor)*uy,0,ux*factor,uy*factor)
   end
   G.pop()
  end
  if portrait then
   local R=frameRects
   local ux,uy=R and R.Ux or sx,R and R.Uy or sy
   local ox,oy=R and R.uox or ctx.ox,R and R.uoy or ctx.oy
   local home=40+math.floor((56-portrait.width)/2)
   local right=(ctx.ww-ox)/ux+1;local left=-ox/ux-portrait.width-1
   local state=portrait.state;local offset=state.monOffset or 0;local px
   if state.scrollPhase=='in' then
    local t=math.max(0,math.min(1,offset/110));px=home+(right-home)*t
   else
    local t=math.max(0,math.min(1,-offset/93));px=home+(left-home)*t
   end
   G.push('all');G.origin();G.setShader();G.setScissor();G.setColor(1,1,1,1)
   G.setBlendMode('alpha','alphamultiply');G.translate(ox,oy);G.scale(ux,uy)
   G.draw(portrait.image,px,portrait.y);G.pop()
  end
  return result
 end)
 -- Sprite replay happens after the letterbox pass. Apply cinematic masks last
 -- so the canvas and final-resolution replay obey the same visible band.
 local Renderer=require('src.render.Renderer');local endFrame=Renderer.endFrame
 Renderer.endFrame=function(self,...)
  frameRects=self:frameRects()
  finalBars=nil
  local result={pcall(endFrame,self,...)}
  local bars=finalBars;finalBars=nil
  if result[1] and bars and active()then
   G.push('all');G.origin();G.setShader();G.setScissor();G.setBlendMode('alpha','alphamultiply')
   G.setColor((unpack or table.unpack)(bars.color))
   G.rectangle('fill',0,0,bars.width,math.max(0,bars.top))
   G.rectangle('fill',0,bars.bottom,bars.width,math.max(0,bars.height-bars.bottom))
   G.pop()
  end
  if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
 end
 local portrait=assert(load(assert(mod:read('lib/boot_sprite_paper.lua'))))()()
 for _,path in ipairs({'src.ui.IntroMovie','src.ui.YellowIntro','src.ui.TitleState','src.ui.OakSpeech','src.ui.gen2.TitleState','src.ui.gen2.OakSpeech','src.ui.gen2.GoldSilverIntro','src.ui.gen2.CrystalIntro'})do
  local ok,Class=pcall(require,path)
  if ok and type(Class.draw)=='function'and not Class._customBootPaper then
   Class._customBootPaper=true;local draw=Class.draw
   if path=='src.ui.IntroMovie'and Class.drawFight then
    local fight=Class.drawFight
    Class.drawFight=function(self,...)
     local mode=tonumber(mod.options:get('introBattleBars'))or 0
     local image=self.gengarFrames and self.gengarFrames[self.gengarPose]
     if not active()or not image then return fight(self,...)end
     local width,height=160,90;if G.getDimensions then width,height=G.getDimensions()end
     local factor=math.min(1.6,math.max(1,math.sqrt((width/math.max(1,height))/(16/9))))
     if mode==0 and factor<=1 then return fight(self,...)end
     local gengarY,nidoY=self.gengarY,self.nidoY
     local floor=mode==0 and 112 or mode==1 and 136 or 144
     local offset=math.max(0,floor-(gengarY+image:getHeight()))
     self.gengarY,self.nidoY=gengarY+offset,nidoY+offset
     local printer,replay=G.draw,self.replayObjLayer
     if factor>1 then
      local queue={factor=factor,floor=floor,mode=mode};pendingFight=queue
      G.draw=function(actor,x,y,...)queue[#queue+1]={image=actor,x=x,y=y,color={G.getColor()}}end
      self.replayObjLayer=function()end
     end
     local result={pcall(fight,self,...)};self.gengarY,self.nidoY=gengarY,nidoY
     G.draw=printer;self.replayObjLayer=replay
     if not result[1]then pendingFight=nil end
     if not result[1]then error(result[2],0)end;return(unpack or table.unpack)(result,2)
    end
   end
   if path=='src.ui.IntroMovie'and Class.replayObjLayer then
    local replay=Class.replayObjLayer
    Class.replayObjLayer=function(self,...)
     local mode=tonumber(mod.options:get('introBattleBars'))or 0
     if not active()or mode==0 then return replay(self,...)end
     local FX=require('src.render.PaletteFX');local mark=FX.markUiSpriteRedraw
     FX.markUiSpriteRedraw=function(image,quad,x,y,opts)
      local copy={};for k,v in pairs(opts or{})do copy[k]=v end
      copy.clip=mode==1 and{0,8,160,128}or{0,0,160,144}
      return mark(image,quad,x,y,copy)
     end
     local result={pcall(replay,self,...)};FX.markUiSpriteRedraw=mark
     if not result[1]then error(result[2],0)end;return(unpack or table.unpack)(result,2)
    end
   end
   Class.draw=function(self,...)
    local n=tonumber(mod.options:get('introBackgroundColor')or mod.save:get('introBackgroundColor'))or 0
    if not active()then return draw(self,...)end
    pending=true;pendingBars=nil
    local SR=require('src.render.SpriteRenderer');local obp=SR.obpImage
    local protected={};local swapped={};local stars={};local actorColors={}
    local colorize=path=='src.ui.IntroMovie'and mod.options:get('introBattleSprites')==1
    if colorize then
     for _,spec in ipairs({{'gengarPaths',{{255,255,255},{160,112,208},{88,56,136},{0,0,0}}},
       {'nidoPaths',{{255,255,255},{208,168,224},{144,96,168},{0,0,0}}}})do
      for _,file in pairs(self[spec[1]]or{})do actorColors[file]={colors=spec[2],group='intro_'..spec[1]..'_color'}end
     end
    end
    for _,field in ipairs({'smallStar','smallStarBlink','bigStar','studioLogo','logo','gfText'})do if self[field]and (field~='logo'or path=='src.ui.IntroMovie')then stars[self[field]]=true end end
    local function protect(image)if image then protected[image]=true end end
    for _,field in ipairs({'player','pic','yellowPikachu','yellowBubble','walkSheet'})do protect(self[field])end
    if self.currentSprite then local image=self:currentSprite();protect(image)end
    for _,pair in ipairs({{'nidoFrames','nidoPaths'},{'gengarFrames','gengarPaths'}})do
     local frames,paths=self[pair[1]],self[pair[2]]
     if (n>0 or colorize)and frames and paths then for i,file in pairs(paths)do
      local tint=actorColors[file]
      local ok,image=pcall(portrait,file,tint and tint.colors,tint and tint.group)
      if ok then swapped[#swapped+1]={frames,i,frames[i]};frames[i]=image;protect(image)end
     end end
    end
    SR.obpImage=function(path,colors,group)
     -- GAME FREAK lettering is decorative tile text, not a portrait.
     if path==self.gfTextPath or path==self.logoPath then local image=obp(path,colors,group);stars[image]=true;return image end
     if path==self.bigStarPath then local image=obp(path,colors,group);stars[image]=true;return image end
     local tint=actorColors[path]
     if tint then local image=portrait(path,tint.colors,tint.group);protect(image);return image end
     if n<=0 then return obp(path,colors,group)end
     local ok,image=pcall(portrait,path,colors,group)
     if not ok then image=obp(path,colors,group)end;protect(image);return image
    end
    local color=n>0 and palette.color('background',n-1)or nil
    local fadeStep=self.fadeStep
    local fade=path=='src.ui.IntroMovie'and(color or colorize)and self.phase==3 and fadeStep
    -- Font atlas masks contain white ink. Never apply the paper key shader
    -- while the font renderer is emitting glyphs.
    local Font=require('src.render.Font');local textDepth=0
    local fontDraw,fontCode=Font.draw,Font.drawCode
    local function textCall(printer,...)
     textDepth=textDepth+1;local result={pcall(printer,...)};textDepth=textDepth-1
     if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
    end
    Font.draw=function(...)return textCall(fontDraw,...)end
    Font.drawCode=function(...)return textCall(fontCode,...)end
    local rectangle,imageDraw,clear=G.rectangle,G.draw,G.clear
    local bootCanvas=G.getCanvas()
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
     local r,g,b,a=G.getColor()
     if path=='src.ui.IntroMovie' and self.phase==3 and mode=='fill'
       and x==0 and w==160 and h==32 and (y==0 or y==112)then
      local mode=tonumber(mod.options:get('introBattleBars'))or 0
      if mode==2 then return end
      pendingBars={r,g,b,a,bandTop=mode==1 and 8 or 32,bandBottom=mode==1 and 136 or 112}
      if fade then return end
      if mode==1 then return rectangle('fill',0,y==0 and 0 or 136,160,8)end
     end
     -- Game Freak splash bars are decorative masks, not foreground artwork.
     if path=='src.ui.IntroMovie' and self.phase==2 and mode=='fill'
       and x==0 and w==160 and h==32 and (y==0 or y==112) then return end
     if mode=='fill'and r>.985 and g>.985 and b>.985 and G.getCanvas()==bootCanvas
       and x==0 and w==160 and ((y==0 and h==144)or(h==32 and(y==0 or y==112)))then return paper(x,y,w,h)end
     return rectangle(mode,x,y,w,h,...)
    end
    G.clear=function(r,g,b,a,...)
     if G.getCanvas()==bootCanvas and type(r)=='number'and r>.985 and g>.985 and b>.985 then clear(0,0,0,0);return paper(0,0,160,144)end
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
     if textDepth>0 or n<=0 or protected[image]or G.getShader()then return imageDraw(image,...)end
     G.push('all');G.setShader(keyShader);local result={pcall(imageDraw,image,...)};G.pop()
     if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
    end
    -- Fade the original foreground into custom paper, rather than remapping
    -- sprite colors toward opaque white. Keep native timing and hold intact.
    local setColor=G.setColor;local replay=self.replayObjLayer
    if fade then
     local opacity=1-math.max(0,math.min(1,fadeStep/3))
     self.fadeStep=nil
     G.setColor=function(r,g,b,a)
      if type(r)=='table'then return setColor(r[1],r[2],r[3],(r[4]or 1)*opacity)end
      return setColor(r,g,b,(a or 1)*opacity)
     end
     -- Native palette replay would redraw opaque actors over our fade.
     self.replayObjLayer=function()end
    end
    local result={pcall(draw,self,...)};
    if fade then self.fadeStep=fadeStep;self.replayObjLayer=replay;G.setColor=setColor end
    SR.obpImage=obp;for _,slot in ipairs(swapped)do slot[1][slot[2]]=slot[3]end
    G.rectangle,G.draw,G.clear=rectangle,imageDraw,clear
    Font.draw,Font.drawCode=fontDraw,fontCode
    local P=require('src.render.PaletteFX');if P.markTrueColor then P.markTrueColor(0,0,160,144)end
    if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
   end
  end
 end
end
