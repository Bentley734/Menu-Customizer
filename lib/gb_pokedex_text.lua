-- Screen classification; KIM1025 owns entry layout and sprite presentation.
return function(Font,current)
 require('src.ui.DexEntryMenu').screenId='DexEntryMenu'
 require('src.ui.PokedexMenu').screenId='PokedexMenu'
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
