local api=testLoader.exports.gen3transparency;local S=assert(api.textScopes);local C=api.customization
local game={options=testOptions,mods=testLoader,data=testData,save={player={name='RED'}},writeOptions=function()end}
C.write(game,api.allFonts.values('textCase',1))
C.write(game,{martTextCase=3,pcTextCase=2,dialogueTextCase=0,battleTextCase=3})
assert(S.with('mart',function()return C.text("DON'T GO")end)=="Don't Go")
assert(S.with('pc',function()return C.text("DON'T GO")end)=="don't go")
assert(S.with('party',function()return C.text('HELLO WORLD')end)=='Hello world')
assert(S.with('battle',function()return C.text('HELLO WORLD')end)=='Hello World')
assert(not S.current)
assert(not pcall(S.with,'party',function()error('probe')end)and not S.current)
if api.gbMenus then local Box=require('src.render.TextBox');local box=Box.new(game,"DON'T GO",function()end);assert(box.pages[1][1]=="DON'T GO",'Independent dialogue mode missed encoded text')end
local P=api.selectorPalette;C.write(game,{introTextColor=2,gameFreakTextColor=4})
local c=api.gbMenus;if c then c.introScope=true end
local normal=P.colors('intro').fg;api.gameFreakTextScope=true;local freak=P.colors('intro').fg;api.gameFreakTextScope=nil
assert(freak==P.color('text',4)and normal~=freak,'Game Freak color leaks into intro text')
if c then c.introScope=nil end
local raw=C.rows(function()end);for _,r in ipairs(api.menuSurfaces.rows(function()end))do raw[#raw+1]=r end
local roots=assert(loadfile(sourceRoot..'/lib/menu_organization.lua'))()(raw,function()end)
local layout=roots[1].children[1];assert(layout.label=='FONT AND LAYOUT')
local found={}
for _,r in ipairs(layout.children)do
 if r.children then if r.id~='wide_allFonts'then found[r.label]=r end
 else assert(r.id=='wide_textCase'or r.id=='wide_controlsLegend'or r.id:find('^wide_all'),'Menu setting remains in global layout page')end
end
for _,s in ipairs(S.scopes)do assert(found[s[2]],'Missing menu category '..s[2])end
C.write(game,api.allFonts.values('textCase',3));for _,s in ipairs(S.scopes)do assert(S.mode(s[1])==3)end
print('PASS independent menu cases, encoded dialogue, Game Freak color isolation, global fanout and scoped layout submenus')
