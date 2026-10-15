local api=testLoader.exports.gen3transparency;local P=api.selectorPalette;local B=api.battlefieldBackground
assert(#P.pokemonBackgrounds.forestEntries==10)
for i,e in ipairs(P.pokemonBackgrounds.forestEntries)do
 assert(e.style==150+i and api.borderCatalog.entries[#api.borderCatalog.entries-10+i].label==e.name)
 assert(P.color('background',#P.backgroundNames-11+i).pokemon==e.key)
end
local gen=require('src.core.GameVersion').generation();local rows=B.rows(function()end)
if gen==2 then assert(#rows==0)else assert(#rows==1)end
assert(B.choice()==0 and B.draw(0,0,160,144)==false)
if #rows>0 then
 local game={options=testOptions,mods=testLoader,writeOptions=function()end}
 rows[1].step(game,-1);assert(B.choice()==#P.backgroundNames)
 assert(api.customization.globalValues('allBackgroundColor',5).battlefieldBackgroundColor==5)
 rows[1].step(game,1);assert(B.choice()==0,'Native field not restored')
end
print('PASS ten matching green choices, battlefield picker, native/default restoration and enabled global backgrounds')
