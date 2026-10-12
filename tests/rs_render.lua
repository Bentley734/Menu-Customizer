local source=assert(io.open('lib/menu_main.lua')):read('*a')
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
local route=assert(source:match('(  local function optionForVersion.-)  local Option ='))
local modules={['src.ui.game3.rs.option_menu']={},['src.ui.game3.rse.option_menu']={},['src.ui.game3.option_menu']={}}
local env=setmetatable({require=function(n)return assert(modules[n])end},{__index=_G})
local choose=assert(load(route..'return optionForVersion','actual option route','t',env))()
for _,v in ipairs({'ruby','sapphire'})do check(choose(v)==modules['src.ui.game3.rs.option_menu'],'RS actual options owner');end
check(choose('emerald')==modules['src.ui.game3.rse.option_menu'],'Emerald option owner retained')
check(choose('firered')==modules['src.ui.game3.option_menu'],'FRLG option owner retained')
modules['src.ui.game3.rs.option_menu']=nil
check(choose('ruby')==modules['src.ui.game3.rse.option_menu'],'old engine fallback')
local wrapped=assert(source:match('(  if not FrlgFont%._menuCustomizerEmeraldWrapped then.-)  local originalNativeStartDraw'))
local native,themed=0,0
local F={draw=function()native=native+1;return 'native' end,measure=function()native=native+1;return 8 end,drawGlyph=function()native=native+1 end}
F._menuCustomizerEmerald={enabled=function()return true end,draw=function()themed=themed+1 end,measure=function()themed=themed+1;return 16 end,glyph=function()themed=themed+1;return true end}
assert(load(wrapped,'font adapter','t',setmetatable({FrlgFont=F},{__index=_G})))()
for _,name in ipairs({'WURMPLE','TORCHIC'})do
 F.draw(name,0,0,{font='native_4'});check(F.measure(name,{font='native_4'})==8,'native width');F.drawGlyph(1,0,0,{font='native_4'})
end
check(native==6 and themed==0,'native indexed faces bypass Emerald substitution')
F.draw('OPTION',0,0,{});check(themed==1,'menu font substitution still enabled')
print('PASS '..checks..' RS route and native-font ownership checks')
