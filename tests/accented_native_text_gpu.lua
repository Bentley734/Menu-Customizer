return function(api,F)
 local palette=api.selectorPalette
 for _,label in ipairs({'Pokémon','Pokédex','Pokégear','POKéMON','POKéDEX','POKéGEAR'})do
  local count=0;local original=palette.effects.glyph
  palette.effects.glyph=function(...)count=count+1;return original(...)end
  local ok,err=pcall(palette.nativeText,function()end,function()return 6 end,label,0,0,{colors=palette.colors('menu')})
  palette.effects.glyph=original
  assert(ok,err);assert(count==F.countChars(label),label..' was not split into letters')
 end
 for _,text in ipairs({'<FONT>','\252\1\2','\195'})do
  local count=0;local original=palette.effects.glyph
  palette.effects.glyph=function(...)count=count+1;return original(...)end
  palette.nativeText(function()end,function()return 6 end,text,0,0,{colors=palette.colors('menu')})
  palette.effects.glyph=original;assert(count==1,'Control/encoded text was split')
 end
 print('PASS Pokemon/Pokedex/Pokegear UTF-8 letter effects and encoded-text fallback')
end
