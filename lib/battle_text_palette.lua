-- Battle-only palette. Literal colours never inherit a ROM's mutable STDPAL.
return function(mod)
  local M={names={'BLACK','CHARCOAL','BLUE','GREEN','RED','PURPLE','WHITE'}}
  local foreground={{0,0,0,1},{.18,.18,.18,1},{.05,.18,.55,1},{.05,.35,.12,1},{.6,.05,.05,1},{.4,.1,.5,1},{1,1,1,1}}
  M.shadowNames={'NONE','BLACK','CHARCOAL','GREY','LIGHT GREY','BLUE','GREEN','RED','PURPLE','WHITE'}
  local shadows={{0,0,0,0},{0,0,0,1},{.18,.18,.18,1},{.5,.5,.5,1},{.72,.72,.72,1},foreground[3],foreground[4],foreground[5],foreground[6],foreground[7]}
  M.backgroundNames={'WHITE','BLACK','CHARCOAL','NAVY','CREAM','PALE BLUE','PALE GREEN','PLUM'}
  local backgrounds={{1,1,1,1},{0,0,0,1},{.12,.12,.14,1},{.04,.08,.18,1},{1,.96,.82,1},{.82,.91,1,1},{.84,.95,.85,1},{.18,.06,.22,1}}
  -- Append colours so existing saved numeric choices retain their meaning.
  M.names[#M.names+1]='LIGHT BLUE';foreground[#foreground+1]={0.4,0.7,1,1}
  M.shadowNames[#M.shadowNames+1]='LIGHT BLUE';shadows[#shadows+1]={0.4,0.7,1,1}
  M.names[#M.names+1]='SKY BLUE';foreground[#foreground+1]={0.6,0.84,1,1}
  M.shadowNames[#M.shadowNames+1]='SKY BLUE';shadows[#shadows+1]={0.6,0.84,1,1}
  M.names[#M.names+1]='CYAN';foreground[#foreground+1]={0.1,0.85,0.9,1}
  M.shadowNames[#M.shadowNames+1]='CYAN';shadows[#shadows+1]={0.1,0.85,0.9,1}
  M.names[#M.names+1]='TEAL';foreground[#foreground+1]={0.1,0.55,0.55,1}
  M.shadowNames[#M.shadowNames+1]='TEAL';shadows[#shadows+1]={0.1,0.55,0.55,1}
  M.names[#M.names+1]='LIGHT GREEN';foreground[#foreground+1]={0.5,0.85,0.4,1}
  M.shadowNames[#M.shadowNames+1]='LIGHT GREEN';shadows[#shadows+1]={0.5,0.85,0.4,1}
  M.names[#M.names+1]='MINT';foreground[#foreground+1]={0.65,0.95,0.75,1}
  M.shadowNames[#M.shadowNames+1]='MINT';shadows[#shadows+1]={0.65,0.95,0.75,1}
  M.names[#M.names+1]='LIME';foreground[#foreground+1]={0.7,0.9,0.15,1}
  M.shadowNames[#M.shadowNames+1]='LIME';shadows[#shadows+1]={0.7,0.9,0.15,1}
  M.names[#M.names+1]='FOREST';foreground[#foreground+1]={0.02,0.23,0.12,1}
  M.shadowNames[#M.shadowNames+1]='FOREST';shadows[#shadows+1]={0.02,0.23,0.12,1}
  M.names[#M.names+1]='YELLOW';foreground[#foreground+1]={1,0.88,0.2,1}
  M.shadowNames[#M.shadowNames+1]='YELLOW';shadows[#shadows+1]={1,0.88,0.2,1}
  M.names[#M.names+1]='GOLD';foreground[#foreground+1]={0.85,0.6,0.05,1}
  M.shadowNames[#M.shadowNames+1]='GOLD';shadows[#shadows+1]={0.85,0.6,0.05,1}
  M.names[#M.names+1]='ORANGE';foreground[#foreground+1]={1,0.45,0.1,1}
  M.shadowNames[#M.shadowNames+1]='ORANGE';shadows[#shadows+1]={1,0.45,0.1,1}
  M.names[#M.names+1]='PEACH';foreground[#foreground+1]={1,0.78,0.6,1}
  M.shadowNames[#M.shadowNames+1]='PEACH';shadows[#shadows+1]={1,0.78,0.6,1}
  M.names[#M.names+1]='PINK';foreground[#foreground+1]={1,0.5,0.72,1}
  M.shadowNames[#M.shadowNames+1]='PINK';shadows[#shadows+1]={1,0.5,0.72,1}
  M.names[#M.names+1]='ROSE';foreground[#foreground+1]={0.75,0.2,0.4,1}
  M.shadowNames[#M.shadowNames+1]='ROSE';shadows[#shadows+1]={0.75,0.2,0.4,1}
  M.names[#M.names+1]='LAVENDER';foreground[#foreground+1]={0.76,0.66,1,1}
  M.shadowNames[#M.shadowNames+1]='LAVENDER';shadows[#shadows+1]={0.76,0.66,1,1}
  M.names[#M.names+1]='INDIGO';foreground[#foreground+1]={0.22,0.15,0.55,1}
  M.shadowNames[#M.shadowNames+1]='INDIGO';shadows[#shadows+1]={0.22,0.15,0.55,1}
  M.names[#M.names+1]='SILVER';foreground[#foreground+1]={0.75,0.78,0.82,1}
  M.shadowNames[#M.shadowNames+1]='SILVER';shadows[#shadows+1]={0.75,0.78,0.82,1}
  M.names[#M.names+1]='BROWN';foreground[#foreground+1]={0.4,0.24,0.12,1}
  M.shadowNames[#M.shadowNames+1]='BROWN';shadows[#shadows+1]={0.4,0.24,0.12,1}
  M.names[#M.names+1]='NAVY';foreground[#foreground+1]={0.04,0.08,0.18,1}
  M.shadowNames[#M.shadowNames+1]='NAVY';shadows[#shadows+1]={0.04,0.08,0.18,1}
  M.names[#M.names+1]='CREAM';foreground[#foreground+1]={1,0.96,0.82,1}
  M.shadowNames[#M.shadowNames+1]='CREAM';shadows[#shadows+1]={1,0.96,0.82,1}
  M.backgroundNames[#M.backgroundNames+1]='BLUE';backgrounds[#backgrounds+1]={0.05,0.18,0.55,1}
  M.backgroundNames[#M.backgroundNames+1]='LIGHT BLUE';backgrounds[#backgrounds+1]={0.4,0.7,1,1}
  M.backgroundNames[#M.backgroundNames+1]='SKY BLUE';backgrounds[#backgrounds+1]={0.6,0.84,1,1}
  M.backgroundNames[#M.backgroundNames+1]='CYAN';backgrounds[#backgrounds+1]={0.1,0.85,0.9,1}
  M.backgroundNames[#M.backgroundNames+1]='TEAL';backgrounds[#backgrounds+1]={0.1,0.55,0.55,1}
  M.backgroundNames[#M.backgroundNames+1]='GREEN';backgrounds[#backgrounds+1]={0.05,0.35,0.12,1}
  M.backgroundNames[#M.backgroundNames+1]='LIGHT GREEN';backgrounds[#backgrounds+1]={0.5,0.85,0.4,1}
  M.backgroundNames[#M.backgroundNames+1]='MINT';backgrounds[#backgrounds+1]={0.65,0.95,0.75,1}
  M.backgroundNames[#M.backgroundNames+1]='LIME';backgrounds[#backgrounds+1]={0.7,0.9,0.15,1}
  M.backgroundNames[#M.backgroundNames+1]='FOREST';backgrounds[#backgrounds+1]={0.02,0.23,0.12,1}
  M.backgroundNames[#M.backgroundNames+1]='YELLOW';backgrounds[#backgrounds+1]={1,0.88,0.2,1}
  M.backgroundNames[#M.backgroundNames+1]='GOLD';backgrounds[#backgrounds+1]={0.85,0.6,0.05,1}
  M.backgroundNames[#M.backgroundNames+1]='ORANGE';backgrounds[#backgrounds+1]={1,0.45,0.1,1}
  M.backgroundNames[#M.backgroundNames+1]='PEACH';backgrounds[#backgrounds+1]={1,0.78,0.6,1}
  M.backgroundNames[#M.backgroundNames+1]='RED';backgrounds[#backgrounds+1]={0.6,0.05,0.05,1}
  M.backgroundNames[#M.backgroundNames+1]='PINK';backgrounds[#backgrounds+1]={1,0.5,0.72,1}
  M.backgroundNames[#M.backgroundNames+1]='ROSE';backgrounds[#backgrounds+1]={0.75,0.2,0.4,1}
  M.backgroundNames[#M.backgroundNames+1]='PURPLE';backgrounds[#backgrounds+1]={0.4,0.1,0.5,1}
  M.backgroundNames[#M.backgroundNames+1]='LAVENDER';backgrounds[#backgrounds+1]={0.76,0.66,1,1}
  M.backgroundNames[#M.backgroundNames+1]='INDIGO';backgrounds[#backgrounds+1]={0.22,0.15,0.55,1}
  M.backgroundNames[#M.backgroundNames+1]='SILVER';backgrounds[#backgrounds+1]={0.75,0.78,0.82,1}
  M.backgroundNames[#M.backgroundNames+1]='BROWN';backgrounds[#backgrounds+1]={0.4,0.24,0.12,1}
  function M.menuBackground(kind)
    local n=tonumber(mod.options:get('menuBackgroundColor') or mod.save:get('menuBackgroundColor')) or 0
    if kind=='start' then
      local start=tonumber(mod.options:get('startMenuBackgroundColor') or mod.save:get('startMenuBackgroundColor')) or 0
      if start>0 then n=start end
    end
    n=math.max(0,math.min(#backgrounds,math.floor(n)))
    return n>0 and backgrounds[n] or nil
  end
  M.menuBackgroundNames={'DEFAULT'}
  for _,name in ipairs(M.backgroundNames)do M.menuBackgroundNames[#M.menuBackgroundNames+1]=name end
  function M.tintFill(fn,mode,x,y,w,h,...)
    local G=love.graphics;local bg=mod.exports and mod.exports.menuBackground and mod.exports.menuBackground()
    if not bg or not G.getColor then return fn(mode,x,y,w,h,...)end
    local r,g,b,a=G.getColor()
    if bg and mode=='fill' and math.min(r,g,b)>.55 and math.max(r,g,b)-math.min(r,g,b)<.06 then
      local shade=(r+g+b)/3
      G.push('all');G.setColor(math.min(1,bg[1]*(.6+.4*shade)+.12*shade),math.min(1,bg[2]*(.6+.4*shade)+.12*shade),math.min(1,bg[3]*(.6+.4*shade)+.12*shade),a)
      local result={pcall(fn,mode,x,y,w,h,...)};G.pop()
      if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
    end
    return fn(mode,x,y,w,h,...)
  end
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
    if rectangle and kind=='menu' then
      G.rectangle=function(...)return M.tintFill(rectangle,...)end
    elseif rectangle and kind=='battle' then
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
  function M.menuOptions(opts)
    local copy={};for k,v in pairs(opts or {})do copy[k]=v end
    copy.colors=M.colors('menu');copy.color=nil;copy.shadow=nil
    return copy
  end
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
