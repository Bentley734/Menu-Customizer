-- Scale complete strings about their own anchor, never individual axes alone.
return function(mod,enabled)
 local G=love.graphics;local M={depth=0,scopeDepth=0}
 local unpack=unpack or table.unpack
 function M.factor()
  if not enabled()or not(M.scopeDepth>0 or mod.exports.battleFontScope or mod.exports.dialogueFontScope)then return 1 end
  local n=tonumber(mod.options:get('battle_font_size')or mod.save:get('battle_font_size'))or 0
  return ({1,1.5,2})[math.max(0,math.min(2,math.floor(n)))+1]
 end
 local function fitted(f,text,opts,width)
  if not mod.exports.dialogueFixedSize and not(opts and opts._fixedSize) and type(opts)=='table'and opts.maxWidth and width and width>0 then f=math.min(f,opts.maxWidth/width)end
  return math.max(.01,f)
 end
 local function transform(x,y,f)
  local sx,sy=1,1
  if G.transformPoint then
   local a,b=G.transformPoint(0,0);local c,d=G.transformPoint(1,0);local e,h=G.transformPoint(0,1)
   sx=math.sqrt((c-a)^2+(d-b)^2);sy=math.sqrt((e-a)^2+(h-b)^2)
  end
  local dpi=mod.exports.fontAspect or {1,1};local dx,dy=dpi[1]or 1,dpi[2]or 1
  local p=math.min(sx*dx,sy*dy)*f
  -- Final-resolution text uses whole square framebuffer pixels. A 150%
  -- request must never alternate thick and thin columns at fractional zoom.
  local target=G.getCanvas and G.getCanvas()
  if not target or target:getWidth()>320 then
   local physical=target and target:getDPIScale() or (G.getDPIScale and G.getDPIScale() or 1)
   p=math.max(1,math.floor(p*physical+.00001))/physical
   local ax,ay=G.transformPoint(x,y)
   G.translate((math.floor(ax*physical+.5)/physical-ax)/math.max(.00001,sx),
    (math.floor(ay*physical+.5)/physical-ay)/math.max(.00001,sy))
  end
  G.translate(x,y);G.scale(p/math.max(.00001,sx*dx),p/math.max(.00001,sy*dy))
 end
 function M.decorate(font,drawKey,measureKey,glyphKey,isGB)
  if not font or not font[drawKey]then return end
  local tag='_menuCustomizerBattleSize_'..drawKey
  if font[tag]then font[tag].api=M;return end
  local state={api=M};font[tag]=state
  local draw,measure,glyph=font[drawKey],font[measureKey],font[glyphKey]
  local function rawWidth(api,text,opts,...)
   if not measure then return nil end
   api.depth=api.depth+1
   local result={pcall(measure,text,opts,...)};api.depth=api.depth-1
   if not result[1]then error(result[2],0)end
   return result[2]
  end
  if measure then font[measureKey]=function(text,opts,...)
   local api=state.api;local w=rawWidth(api,text,opts,...)
   if api.depth>0 or not w then return w end
   return w*fitted(api.factor(),text,opts,w)
  end end
  font[drawKey]=function(text,x,y,opts,...)
   local api=state.api;local f=api.factor()
   if f==1 or api.depth>0 then return draw(text,x,y,opts,...)end
   local w=rawWidth(api,text,opts);f=fitted(f,text,opts,w)
   local copy=opts
   if type(opts)=='table'then copy={};for k,v in pairs(opts)do copy[k]=v end
    if copy.maxWidth then copy.maxWidth=copy.maxWidth/f end
   end
   G.push('all');transform(x,y,f);api.depth=api.depth+1
   local args={...};local result={pcall(draw,text,0,0,copy,unpack(args))}
   api.depth=api.depth-1;G.pop()
   if not result[1]then error(result[2],0)end
   if isGB then return (result[2]or w or 0)*f end
   return result[2],x+(result[3]or w or 0)*f,y+(result[4]or 0)*f
  end
  if glyph then font[glyphKey]=function(id,x,y,opts,...)
   local api=state.api;local f=api.factor()
   -- Cartridge frame tiles belong to the panel, not the battle font.
   if isGB and id>=0x79 and id<=0x7E then return glyph(id,x,y,opts,...)end
   if f==1 or api.depth>0 then return glyph(id,x,y,opts,...)end
   G.push('all');transform(x,y,f);api.depth=api.depth+1
   local args={...};local result={pcall(glyph,id,0,0,opts,unpack(args))}
   api.depth=api.depth-1;G.pop()
   if not result[1]then error(result[2],0)end;return unpack(result,2)
  end end
 end
 function M.viewport(viewport,fn,...)
  local prior=mod.exports.fontAspect
  if viewport then mod.exports.fontAspect={viewport.dpiX or 1,viewport.dpiY or 1}end
  local result={pcall(fn,...)};mod.exports.fontAspect=prior
  if not result[1]then error(result[2],0)end;return unpack(result,2)
 end
 function M.scope(target,key)
  if not target or type(target[key])~='function'then return end
  target._menuCustomizerSizeScopes=target._menuCustomizerSizeScopes or {}
  local states=target._menuCustomizerSizeScopes
  if states[key]then states[key].api=M;return end
  local state={api=M};states[key]=state;local original=target[key]
  target[key]=function(...)
   local api=state.api;api.scopeDepth=api.scopeDepth+1
   local result={pcall(original,...)};api.scopeDepth=api.scopeDepth-1
   if not result[1]then error(result[2],0)end;return unpack(result,2)
  end
 end
 return M
end
