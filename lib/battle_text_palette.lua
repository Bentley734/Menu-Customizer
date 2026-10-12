-- Battle-only palette. Literal colours never inherit a ROM's mutable STDPAL.
return function(mod)
  local M={names={'BLACK','CHARCOAL','BLUE','GREEN','RED','PURPLE','WHITE'}}
  local foreground={{0,0,0,1},{.18,.18,.18,1},{.05,.18,.55,1},{.05,.35,.12,1},{.6,.05,.05,1},{.4,.1,.5,1},{1,1,1,1}}
  M.shadowNames={'NONE','BLACK','CHARCOAL','GREY','LIGHT GREY','BLUE','GREEN','RED','PURPLE','WHITE'}
  local shadows={{0,0,0,0},{0,0,0,1},{.18,.18,.18,1},{.5,.5,.5,1},{.72,.72,.72,1},foreground[3],foreground[4],foreground[5],foreground[6],foreground[7]}
  M.backgroundNames={'WHITE','BLACK','CHARCOAL','NAVY','CREAM','PALE BLUE','PALE GREEN','PLUM'}
  local backgrounds={{1,1,1,1},{0,0,0,1},{.12,.12,.14,1},{.04,.08,.18,1},{1,.96,.82,1},{.82,.91,1,1},{.84,.95,.85,1},{.18,.06,.22,1}}
  function M.background()
    local n=tonumber(mod.options:get('battle_background_color') or mod.save:get('battle_background_color')) or 0
    return backgrounds[math.max(0,math.min(#backgrounds-1,math.floor(n)))+1]
  end
  function M.colors(kind)
    local key=kind=='menu' and 'menuTextColor' or kind=='name' and 'battle_name_color' or 'battle_text_color'
    local n=tonumber(mod.options:get(key) or mod.save:get(key)) or 0
    n=math.max(0,math.min(#foreground-1,math.floor(n)))
    local shadowKey=kind=='menu' and 'menuTextShadowColor' or kind=='name' and 'battle_name_shadow_color' or 'battle_shadow_color'
    local sh=tonumber(mod.options:get(shadowKey) or mod.save:get(shadowKey)) or 0
    sh=math.max(0,math.min(#shadows-1,math.floor(sh)))
    return {fg=foreground[n+1],shadow=shadows[sh+1],bg={0,0,0,0}}
  end
  function M.clean(text)
    if type(text)~='string' then return text end
    -- Remove only palette/font controls; retain pauses, line breaks and variables.
    return (text:gsub('\252[\001\002\003\006].',''):gsub('\252\004...',''):gsub('\252\007',''))
  end
  local function scope(fn,kind,all,...)
    local F=require('src.ui.game3.frlg_font')
    local draw,glyph=F.draw,F.drawGlyph
    local function options(opts)
      local copy={};for k,v in pairs(opts or {})do copy[k]=v end
      copy.colors=M.colors(kind);copy.color=nil;copy.shadow=nil
      return copy
    end
    F.draw=function(text,x,y,opts,...)
      if not all and y<112 then return draw(text,x,y,opts,...) end
      return draw(M.clean(text),x,y,options(opts),...)
    end
    F.drawGlyph=function(id,x,y,opts,...)
      if not all and y<112 then return glyph(id,x,y,opts,...) end
      return glyph(id,x,y,options(opts),...)
    end
    local G=love and love.graphics
    local rectangle=G and G.rectangle
    if rectangle and kind=='battle' then
      G.rectangle=function(mode,x,y,w,h,...)
        if mode=='fill' and x==16 and y>=112 and w==208 and h==16 then
          G.push('all');G.setColor((unpack or table.unpack)(M.background()))
          local result={pcall(rectangle,mode,x,y,w,h,...)};G.pop()
          if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
        end
        return rectangle(mode,x,y,w,h,...)
      end
    end
    local result={pcall(fn,...)};F.draw,F.drawGlyph=draw,glyph
    if rectangle then G.rectangle=rectangle end
    if not result[1]then error(result[2],0)end
    return (unpack or table.unpack)(result,2)
  end
  function M.scope(fn,...)return scope(fn,'battle',false,...)end
  function M.menuScope(fn,...)return scope(fn,'menu',true,...)end
  -- Healthbox renderers print the name first, then gender, level and HP.
  -- Limit this palette to that first text draw, including numeric nicknames.
  function M.nameScope(font,fn,...)
    local draw=font.draw;local used=false
    font.draw=function(text,x,y,opts,...)
      if used then return draw(text,x,y,opts,...)end
      used=true
      local copy={};for k,v in pairs(opts or {})do copy[k]=v end
      copy.colors=M.colors('name')
      copy.colors.bg=opts and opts.colors and opts.colors.bg or copy.colors.bg
      copy.color=nil;copy.shadow=nil
      return draw(text,x,y,copy,...)
    end
    local result={pcall(fn,...)};font.draw=draw
    if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
  end
  local inkShader
  local function nativeGlyph(kind,fn,id,...)
    local G=love.graphics
    G.push('all');G.setColor((unpack or table.unpack)(M.colors(kind).fg))
    if id<0x400000 and G.newShader then
      if not inkShader then inkShader=G.newShader([[vec4 effect(vec4 c,Image t,vec2 uv,vec2 p){vec4 s=Texel(t,uv);return vec4(c.rgb,c.a*s.a*(1.0-min(s.r,min(s.g,s.b))));}]])end
      G.setShader(inkShader)
    else G.setShader()end
    local result={pcall(function(...)
      local colors=M.colors(kind)
      if colors.shadow[4]>0 then
        G.push('all');G.translate(1,1);G.setColor((unpack or table.unpack)(colors.shadow))
        local painted={pcall(fn,id,...)};G.pop()
        if not painted[1]then error(painted[2],0)end
      end
      G.setColor((unpack or table.unpack)(colors.fg));return fn(id,...)
    end,...)};G.pop()
    if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
  end
  function M.nativeMenuGlyph(fn,id,...)return nativeGlyph('menu',fn,id,...)end
  function M.nativeNameGlyph(fn,id,...)return nativeGlyph('name',fn,id,...)end
  return M
end
