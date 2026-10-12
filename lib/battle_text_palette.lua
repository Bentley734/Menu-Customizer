-- Battle-only palette. Literal colours never inherit a ROM's mutable STDPAL.
return function(mod)
  local M={names={'BLACK','CHARCOAL','BLUE','GREEN','RED','PURPLE','WHITE'}}
  local foreground={{0,0,0,1},{.18,.18,.18,1},{.05,.18,.55,1},{.05,.35,.12,1},{.6,.05,.05,1},{.4,.1,.5,1},{1,1,1,1}}
  function M.colors()
    local n=tonumber(mod.options:get('battle_text_color') or mod.save:get('battle_text_color')) or 0
    n=math.max(0,math.min(#foreground-1,math.floor(n)))
    return {fg=foreground[n+1],shadow=n==6 and {.25,.25,.25,1} or {.72,.72,.72,1},bg={0,0,0,0}}
  end
  function M.clean(text)
    if type(text)~='string' then return text end
    -- Remove only palette/font controls; retain pauses, line breaks and variables.
    return (text:gsub('\252[\001\002\003\006].',''):gsub('\252\004...',''):gsub('\252\007',''))
  end
  function M.scope(fn,...)
    local F=require('src.ui.game3.frlg_font')
    local draw=F.draw
    F.draw=function(text,x,y,opts,...)
      if y<112 then return draw(text,x,y,opts,...) end
      local copy={};for k,v in pairs(opts or {})do copy[k]=v end
      copy.colors=M.colors();copy.color=nil;copy.shadow=nil
      return draw(M.clean(text),x,y,copy,...)
    end
    local result={pcall(fn,...)};F.draw=draw
    if not result[1]then error(result[2],0)end
    return (unpack or table.unpack)(result,2)
  end
  return M
end
