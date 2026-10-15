local api=testLoader.exports.gen3transparency
local C=api.customization;local gb=api.gbMenus
if not gb then return end
local g={options=testOptions,mods=testLoader,save={player={name='ALICE',rival='BOB'}},data={},writeOptions=function()end}
local T=require('src.render.TextBox')
gb.dialogueScope=true
for _,mode in ipairs({1,3})do
 C.write(g,{textCase=mode,dialogueTextCase=mode})
 local out=T.substitute(g,'HELLO {PLAYER}! {RIVAL} IS HERE.')
 assert(out==(mode==1 and'Hello Alice! Bob is here.'or'Hello Alice! Bob Is Here.'),out)
end
C.write(g,{textCase=0,dialogueTextCase=0})
assert(T.substitute(g,'HELLO {PLAYER}! {RIVAL} IS HERE.')=='HELLO ALICE! BOB IS HERE.')
gb.dialogueScope=nil
print('PASS real dialogue token expansion: Sentence/Title Case names, vanilla unchanged')
