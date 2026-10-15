local source=assert(arg[1]);local colors={};local G={setColor=function()end,draw=function()end}
love={graphics=G};local C={resizeX=1,resizeY=1,setting=function()return 0 end,theme={enabled=function()return true end}}
local mod={exports={},options={get=function()return 4 end}}
local F={_menuCustomizerGB=C,width=function()return 40 end,draw=function(text)colors[#colors+1]={text,mod.exports.gameFreakTextScope}end}
local Title={draw=function(self)self:drawCopyright(136);F.draw('RED VERSION',0,0)end,drawCopyright=function()end}
local Intro={draw=function(self)self:drawCopyright();self:drawObp0(self.gfText,'gf',48,88)end,drawCopyright=function()end,drawObp0=function()error('Native text bitmap was not replaced')end}
package.loaded['src.ui.IntroMovie']=Intro;package.loaded['src.ui.TitleState']=Title
for _,p in ipairs({'src.ui.YellowIntro','src.ui.OakSpeech','src.ui.gen2.TitleState','src.ui.gen2.OakSpeech','src.ui.gen2.GoldSilverIntro','src.ui.gen2.CrystalIntro'})do package.loaded[p]={}end
assert(loadfile(source..'/lib/intro_font.lua'))()(mod,F,function()return true end)
Title.draw(setmetatable({title={copyrightText='GAME FREAK inc.'}},{__index=Title}))
assert(colors[1][1]=='GAME FREAK inc.'and colors[1][2]and not colors[2][2])
Intro.draw(setmetatable({gfText={}},{__index=Intro}))
for _,c in ipairs(colors)do assert(not not c[2]==not not c[1]:upper():find('GAME FREAK',1,true))end
assert(not mod.exports.gameFreakTextScope and not C.introScope)
print('PASS Game Freak title/splash text color scope, native bitmap replacement and state cleanup')
