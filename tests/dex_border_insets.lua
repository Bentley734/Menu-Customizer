local api=testLoader.exports.gen3transparency
local K=testLoader.exports.kim1025.pokedexPresentation
assert(K and K._menuCustomizerInsets,'KIM pagination adapter missing')
local game={options=testOptions,mods=testLoader,writeOptions=function()end}
local border;for id,e in ipairs(api.borderCatalog.entries)do if e.dsFrame then border=id;break end end
api.customization.write(game,{menuBorder=border,pokedexBorderChoice=border})
local c=api.gbMenus;c.drawScope=true;c.drawingDex=true
local F=require('src.render.Font');local il,ir=c.borders.insets('pokedex',160,72)
local pages=K.pages('AFTER BIRTH ITS BACK SWELLS AND HARDENS INTO A SHELL. POWERFULLY SPRAYS FOAM FROM ITS MOUTH.',136,3)
for _,page in ipairs(pages)do for _,line in ipairs(page)do assert(F.width(line)<=160-il-ir)end end
print('PASS loaded KIM pagination honors Gen IV interior width')
