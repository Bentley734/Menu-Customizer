local api=testLoader.exports.gen3transparency;local A=api.allFonts;local C=api.customization;local P=api.selectorPalette
local game={options=testOptions,mods=testLoader,writeOptions=function(self)self.writes=(self.writes or 0)+1 end}
local bucket=testOptions.modOptions.gen3transparency or{};testOptions.modOptions.gen3transparency=bucket;testLoader.modOptions.gen3transparency=bucket
local page;A.row(function(_,rows)page=rows end).activate(game)
local function find(id)for _,r in ipairs(page)do if r.id==id then return r end end;error(id)end
bucket.pcCustom=1;bucket.martCustom=1;bucket.pcTheme=1;bucket.martTheme=2;bucket.menuTheme=2
find('wide_allFontTheme').step(game,-1)
for _,k in ipairs({'menuTheme','dialogueTheme','introTheme','saveSummaryTheme','pcTheme','martTheme'})do assert(bucket[k]==1,'native font missed '..k)end
find('wide_allFontTheme').step(game,1)
for _,k in ipairs({'menuTheme','dialogueTheme','introTheme','saveSummaryTheme','pcTheme','martTheme'})do assert(bucket[k]==2,'Emerald font missed '..k)end
local effects={'menu_fx_','intro_fx_','battle_fx_','battle_name_fx_','mart_fx_','pc_fx_'}
for _,prefix in ipairs(effects)do bucket[prefix..'preset']=3;bucket[prefix..'alternate']=1 end
C.write(game,A.values('allTextColor',6))
for _,k in ipairs({'menuTextColor','dialogueTextColor','introTextColor','pcTextColor','martTextColor','battle_text_color','battle_name_color'})do assert(bucket[k]==6,'color missed '..k)end
for _,prefix in ipairs(effects)do assert(bucket[prefix..'preset']==0 and bucket[prefix..'alternate']==0,'stale effects override global color')end
C.write(game,A.values('allTextShadowColor',1));C.write(game,A.values('allShadowOpacity',40))
for _,prefix in ipairs(effects)do assert(bucket[prefix..'shadow_transparency']==60)end
for _,n in ipairs({1,2,3})do
 C.write(game,A.values('allFontAlign',n))
 for _,scope in ipairs({'start','dialogue','mart','pc','battle','option','other'})do assert(bucket[scope..'Justify']==n)end
 local expected=({10,40,70})[n];assert(A.align(10,100,40,'mart')==expected)
 assert(A.align(10,20,40,'mart')==10,'oversized text must retain safe anchor')
end
C.write(game,A.values('menu_fx_outline',1));for _,prefix in ipairs(effects)do assert(bucket[prefix..'outline']==1)end
C.write(game,A.values('textCase',2));assert(bucket.textCase==2 and bucket.introTextCase==2)
-- The organizer must retain one group instead of flattening the font page.
local raw=C.rows(function()end);local roots=assert(loadfile(sourceRoot..'/lib/menu_organization.lua'))()(raw,function()end)
local fonts=roots[1].children[1].children[1]
assert(roots[1].label=='TEXT'and roots[1].children[1].label=='FONT AND LAYOUT')
assert(fonts.id=='wide_allFonts'and fonts.children and #fonts.children==(api.frlgTextSize and api.frlgTextSize.active()and 8 or 7))
assert(game.writes>0 and not C.preview and not api.menuSurfaces.current)
print('PASS all-font styles, colors, shadows, alignment, effects, case, persistence and navigation')
