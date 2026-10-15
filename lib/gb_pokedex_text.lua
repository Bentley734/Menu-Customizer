-- Screen classification; KIM1025 owns entry layout and sprite presentation.
return function(Font,current,mod)
 require('src.ui.DexEntryMenu').screenId='DexEntryMenu'
 require('src.ui.PokedexMenu').screenId='PokedexMenu'
 -- Cooperate with KIM's existing pagination without replacing its sprite/layout ownership.
 mod.events:on('mods.loaded',function(event)
  local e=event.loader and event.loader.exports and event.loader.exports.kim1025
  local pages=e and e.pokedexPresentation
  if pages and not pages._menuCustomizerInsets then
   pages._menuCustomizerInsets=true;local original=pages.pages
   pages.pages=function(text,width,rows)
    local C=current()
    if C and C.live()then local il,ir,ds=C.borders.insets('pokedex',160,72);if ds then width=math.min(width,160-il-ir)end end
    return original(text,width,rows)
   end
  end
 end)
 local Hud=require('src.render.HudTiles')
 local original=Hud.statusTile
 Hud.statusTile=function(code,x,y,...)
  local C=current()
  -- The summary's number marker is artwork, rather than Font text.
  if code==0x74 and C and C.drawScope and C.theme.enabled()then
   return Font.draw('No',x,y)
  end
  return original(code,x,y,...)
 end
end
