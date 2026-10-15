local api=testLoader.exports.gen3transparency;local A=api.animationSpeeds;local P=api.selectorPalette
local game={options=testOptions,mods=testLoader,writeOptions=function()end};local groups=A.rows(function()end)
assert(#groups==3 and #groups[1].children>50 and #groups[2].children>5 and #groups[3].children>20)
local saved=testOptions.modOptions.gen3transparency;local timer=love.timer.getTime;love.timer.getTime=function()return 10 end
local b=P.color('background',#P.backgroundNames-1);local t
for i=0,#P.names-1 do if P.color('text',i).animation then t=P.color('text',i);break end end
assert(b._speedGroup=='background'and t._speedGroup=='text')
local original=P.effects.resolve(b,'menu').phase
saved['animationSpeed_background_'..b._speedId]=0
assert(P.effects.resolve(b,'menu').phase==0 and P.effects.resolve(t,'menu').phase>0)
saved['animationSpeed_background_'..b._speedId]=200
assert(P.effects.resolve(b,'menu').phase==original*2)
local first=groups[3].children[1];local old=first.value();first.step(game,1);assert(first.value()~=old)
assert(P.effects.resolve(b,'menu').phase==original*2)
local rows=api.customization.rows(function()end);local root=assert(loadfile(sourceRoot..'/lib/menu_organization.lua'))()(rows,function()end)
local counts={};for _,r in ipairs(root)do for _,c in ipairs(r.children or{})do if c.id:find('wide_animationSpeeds_',1,true)then counts[r.label]=true end end end
assert(counts.TEXT and counts.BORDERS and counts.BACKGROUNDS)
api.customization.write(game,api.allFonts.values('textCase',1))
assert(api.customization.text("yes i think i'm ready, i've arrived and i'll go.")=="Yes I think I'm ready, I've arrived and I'll go.")
assert(api.customization.text('this is hawaii and iris.')=='This is hawaii and iris.')
love.timer.getTime=timer
print('PASS independent design speeds, pause/double rate, separate categories and sentence-case I contractions')
