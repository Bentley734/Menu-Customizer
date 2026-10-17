local calls={};local glyphs=0;local colors={_effects=true}
local F={CHAR_LV_2=0x105,draw=function(text,x,y,opts)calls[#calls+1]={text=text,x=x,colors=opts.colors}end,
 drawGlyph=function()glyphs=glyphs+1 end,advance=function()return 9 end,measure=function(text)return text=='Lv'and 8 or 5 end}
local oldAdvance=F.advance;local G={rectangle=function()end,draw=function()end}
local mod={generation=3,exports={battleUi={setting=function()return 3 end,palette={colors=function()return colors end}}},options={get=function()return 1 end}}
local env=setmetatable({require=function()return{get=function()return'emerald'end}end},{__index=_G})
local f=assert(io.open('lib/healthbox_layers.lua'));local source=f:read('*a');f:close()
local layers=assert(load(source,'healthbox layers','t',env))()(G,mod,function(fn)return fn()end)
layers(F,{},function()
 local advance=F.advance(F.CHAR_LV_2,{small=true});assert(advance==8)
 F.drawGlyph(F.CHAR_LV_2,10,20,{small=true});F.draw('7',10+advance,20,{small=true})
end)
assert(#calls==2 and calls[1].text=='Lv'and calls[2].x==18 and calls[1].colors==colors)
assert(glyphs==0 and F.advance==oldAdvance and not mod.exports.healthboxBackground,'Native Lv glyph or scope leaked')
print('PASS themed Lv label, matching digit advance, palette and hook restoration')
