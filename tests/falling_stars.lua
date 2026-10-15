local api=testLoader.exports.gen3transparency;local stars=api.gameFreakLogo
assert(#stars.starPositions(133)==0)
assert(#stars.starPositions(134)==4 and stars.starPositions(134)[1].y==89)
assert(#stars.starPositions(206)==16)
assert(stars.starPositions(278)[1].y==137,'Stars froze at the old wave cap')
assert(stars.starPositions(281)[1].y==138,'Stars stopped falling')
assert(#stars.starPositions(299)==12,'Offscreen wave did not expire')
assert(#stars.starPositions(371)==0,'Offscreen stars remained')
local found
for _,row in ipairs(api.textScopes.rows(function()end))do if row.id=='wide_gameFreakStarsColor'then found=row end end
assert(found and found.value()=='NATIVE')
local game={options=testOptions,mods=testLoader,writeOptions=function()end}
found.step(game,1);assert(testOptions.modOptions.gen3transparency.gameFreakStarsColor==1)
assert(api.customization.values('allTextColor',4).gameFreakStarsColor==4)
print('PASS falling star spawn, continued movement, screen exit, independent color and global colors')
