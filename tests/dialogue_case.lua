local api=testLoader.exports.gen3transparency;local C=api.customization
local game={options=testOptions,mods=testLoader,data=testData,save={player={name='RED'}},writeOptions=function()end}
if api.gbMenus then
 local Box=require('src.render.TextBox');local Font=require('src.render.Font')
 local function text(box)local lines={};for _,page in ipairs(box.pages)do for _,line in ipairs(page)do lines[#lines+1]=line end end;return table.concat(lines,' ')end
 C.write(game,api.allFonts.values('textCase',1))
 assert(text(Box.new(game,"DON'T GO YET!",function()end))=="Don't go yet!",'Native dialogue bypassed sentence case')
 C.write(game,api.allFonts.values('textCase',3))
 assert(text(Box.new(game,"DON'T GO YET!",function()end))=="Don't Go Yet!",'Native dialogue bypassed Title Case')
end
print('PASS actual dialogue construction in sentence and title case; contraction GPU coverage is in dialogue_case_gpu.lua')
