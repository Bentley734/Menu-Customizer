-- Scope selected menu glyphs to battle rendering and restore on every exit.
return function(mod)
  local unpack=unpack or table.unpack
  local api={}
  function api.scope(fn,...)
    if api.active and not api.active()then return fn(...)end
    local prior=mod.exports.battleFontScope
    mod.exports.battleFontScope=true
    local result={pcall(fn,...)}
    mod.exports.battleFontScope=prior
    if not result[1]then error(result[2],0)end
    return unpack(result,2)
  end
  function api.wrap(target,key,scale)
    local original=target and target[key]
    if type(original)~='function'then return end
    target[key]=function(...)
      local prior=mod.exports.battleFontScale
      mod.exports.battleFontScale=scale or prior
      local result={pcall(api.scope,original,...)}
      mod.exports.battleFontScale=prior
      if not result[1]then error(result[2],0)end
      return unpack(result,2)
    end
  end
  local selected
  if mod.generation==3 then
    local F=require('src.ui.game3.frlg_font')
    local draw,measure,glyph=F.draw,F.measure,F.drawGlyph
    selected={draw=draw,measure=measure,drawGlyph=glyph,CHAR_SELECTOR_ARROW=F.CHAR_SELECTOR_ARROW}
  else
    local F=require('src.render.Font')
    local theme=F._menuCustomizerGB and F._menuCustomizerGB.theme
    local function emerald()return theme and tonumber(mod.options:get('menuTheme') or mod.save:get('menuTheme') or 2)==2 end
    selected={CHAR_SELECTOR_ARROW=0xEF}
    function selected.draw(text,x,y,opts)
      if emerald()then return theme.draw(text,x,y,opts)end
      local G=love.graphics;G.push('all');G.translate(x,y);G.scale(1.5,1.5)
      local result={pcall(F.draw,text,0,0)};G.pop()
      if not result[1]then error(result[2],0)end;return unpack(result,2)
    end
    function selected.measure(text,opts)
      if emerald()then return theme.measure(text,opts)end
      return F.width(text)*1.5
    end
    function selected.drawGlyph(id,x,y,opts)
      if emerald()then return theme.glyph(id,x,y,opts)end
      local G=love.graphics;G.push('all');G.translate(x,y);G.scale(1.5,1.5)
      local result={pcall(F.drawCode,id==0xEF and 0xED or id,0,0)};G.pop()
      if not result[1]then error(result[2],0)end
    end
  end
  function api.isEmerald()return tonumber(mod.options:get("menuTheme") or mod.save:get("menuTheme") or 2)==2 end
  api.selected=selected
  return api
end
