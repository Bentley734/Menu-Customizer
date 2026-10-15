local api=testLoader.exports.gen3transparency;local P=api.selectorPalette
local backgrounds=P.pokemonBackgrounds
assert(#backgrounds.blackEntries==50)
local names={}
for i=21,40 do
 local e=backgrounds.blackEntries[i];assert(e.style==80+i and e.key=='black_art_'..i and not names[e.name]);names[e.name]=true
 assert(e.baseA[1]<.01 and e.baseA[2]<.01 and e.baseA[3]<.01)
 local id=#P.backgroundNames-50+i-1
 assert(P.color('background',id).pokemon==e.key)
 local values=api.customization.globalValues('allBackgroundColor',id+1)
 assert(values.menuBackgroundColor==id+1 and values.battle_background_color==id)
end
assert(api.borderCatalog.entries[#api.borderCatalog.entries-10].label=='BLACK SNORLAX DREAMS','Background additions changed border IDs')
print('PASS twenty appended black backgrounds, matching palettes and global background propagation')
