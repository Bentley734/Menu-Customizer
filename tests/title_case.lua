local api=testLoader.exports.gen3transparency;local C=api.customization
local game={options=testOptions,mods=testLoader,writeOptions=function()end}
C.write(game,api.allFonts.values('textCase',3))
assert(C.text('HELLO WORLD')=='Hello World')
assert(C.text("POKEMON'S TAIL-WHIP")=='Pokemon\'s Tail-Whip')
assert(C.text('POKÃ©MON CENTER')=='PokÃ©mon Center')
assert(C.text('HELLO <RED>WORLD{PLAYER} AGAIN')=='Hello <RED>World{PLAYER} Again')
assert(C.text('PO<RED>KEMON')=='Po<RED>kemon')
assert(C.text('ATTACK 123 / DEFENSE')=='Attack 123 / Defense')
assert(C.text(nil)==nil)
local rows=C.rows(function()end);local row=rows[1];assert(row.value()=='TITLE CASE')
row.step(game,1);assert(row.value()=='ORIGINAL');row.step(game,-1);assert(row.value()=='TITLE CASE')
local page;api.allFonts.row(function(_,r)page=r end).activate(game)
for _,r in ipairs(page)do if r.id=='wide_textCase'then assert(r.value()=='TITLE CASE');r.step(game,1);assert(r.value()=='ORIGINAL');r.step(game,-1);assert(r.value()=='TITLE CASE')end end
if api.gbMenus then api.gbMenus.introScope=true;assert(C.text('TITLE SCREEN')=='Title Screen');api.gbMenus.introScope=nil end
C.write(game,api.allFonts.values('textCase',2));assert(C.text('HELLO WORLD')=='hello world')
C.write(game,api.allFonts.values('textCase',1));assert(C.text('HELLO WORLD')=='Hello world')
C.write(game,api.allFonts.values('textCase',0));assert(C.text('HELLO WORLD')=='HELLO WORLD')
print('PASS title case, tags, apostrophes, hyphens, accented words, intro/global controls and existing modes')
