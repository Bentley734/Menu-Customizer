testLoader.events:emit('mods.loaded',{data={pokemon={{name='PIKACHU'},{name='CHARMANDER'},{name='BULBASAUR'}}}})
local C=testLoader.exports.gen3transparency.customization
local g={options=testOptions,mods=testLoader,writeOptions=function()end}
C.write(g,{textCase=1})
assert(C.text("HELLO PIKACHU! PROFESSOR OAK'S HERE.")=="Hello Pikachu! Professor oak's here.")
assert(C.text("A CHARMANDER AND BULBASAUR.")=="A Charmander and Bulbasaur.")
assert(C.text("BILL MET MISTY AND GIOVANNI.")=="Bill met Misty and Giovanni.")
assert(C.text("I'M READY. DON'T GO!")=="I'm ready. Don't go!")
assert(C.text("<RED>PIKACHU{DONE}")=="<RED>Pikachu{DONE}")
assert(C.text('MY POKEMON AND POKÉMON ARE HERE.')=='My Pokemon and Pokémon are here.')
testLoader.events:emit('game.ready',{game={save={player={name='ASH KETCHUM'},rivalName='GARY OAK'}}})
assert(C.text('HELLO ASH KETCHUM AND GARY OAK!')=='Hello Ash ketchum and Gary oak!')
C.write(g,{textCase=2});assert(C.text('PIKACHU AND OAK')=='pikachu and oak')
C.write(g,{textCase=3});assert(C.text('PIKACHU AND OAK')=='Pikachu And Oak')
print('PASS Sentence Case preserves species and character names, tags, contractions; other case modes unchanged')

-- Real save schema: rival lives under player.rival, not rivalName.
testLoader.events:emit('game.ready',{game={save={player={name='ALICE',rival='BOB'}}}})
for _,mode in ipairs({1,3})do
 C.write(g,{textCase=mode});assert(C.text('ALICE MET BOB')==(mode==1 and 'Alice met Bob'or'Alice Met Bob'))
end
C.write(g,{textCase=0});assert(C.text('ALICE MET BOB')=='ALICE MET BOB')
C.write(g,{textCase=2});assert(C.text('ALICE MET BOB')=='alice met bob')
print('PASS actual player.rival schema, Sentence/Title Case names, vanilla unchanged')
