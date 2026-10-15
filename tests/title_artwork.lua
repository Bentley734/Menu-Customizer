local source=assert(arg[1]);local draws,replays={},{}
local function image(w,h)return{getDimensions=function()return w,h end,setFilter=function()end}end
local native=image(128,48);local hd=image(1000,400);local trainer=image(32,56);local ash=image(100,120)
local options={introLogo=1,introTrainer=1,introFontSize=0};local fail=false
local G={draw=function(...)draws[#draws+1]={...}end,push=function()end,pop=function()end,setShader=function()end,setColor=function()end,setBlendMode=function()end,newQuad=function(...)return{...}end}
local P={markUiSpriteRedraw=function(...)replays[#replays+1]={...}end}
local nativeReplay=P.markUiSpriteRedraw;local nativeDraw=G.draw
local Class={draw=function(self)G.draw(self.logo,16,8);if fail then error('probe')end end}
package.loaded['src.ui.TitleState']=Class;package.loaded['src.ui.gen2.TitleState']={draw=Class.draw};package.loaded['src.render.PaletteFX']=P
love={graphics=G,image={newImageData=function()return{getDimensions=function()return 100,120 end,getPixel=function()return 1,1,1,1 end,release=function()end}end},filesystem={newFileData=function(s)return s end}}
local mod={options={get=function(_,k)return options[k]end},save={get=function()end},assets={image=function(_,p)return p:find('ash')and ash or hd end},read=function()return''end}
assert(loadfile(source..'/lib/title_logo.lua'))()(mod,function()return true end)
local state={logo=native};Class.draw(state)
assert(#draws==0 and #replays==1 and replays[1][1]==hd,'HD logo must bypass pixel canvas')
options.introLogo=0;draws={};replays={};Class.draw(state);assert(#draws==1 and draws[1][1]==native and #replays==0)
options.introLogo=1;options.introFontSize=1;draws={};replays={};Class.draw(state);assert(replays[1][4]==1)
fail=true;assert(not pcall(Class.draw,state));assert(G.draw==nativeDraw and P.markUiSpriteRedraw==nativeReplay);fail=false
-- Ash replaces native trainer quads and their queued redraws exactly once.
Class._customAshArtwork=nil
Class.draw=function(self)G.draw(self.player,{},82,80);P.markUiSpriteRedraw(self.player,{},82,80);G.draw(self.player,{},90,88)end
assert(loadfile(source..'/lib/title_ash.lua'))()(mod,function()return true end)
draws={};replays={};Class.draw{player=trainer}
assert(#draws==0 and #replays==1 and replays[1][1]==ash,'Ash must replace all native trainer parts')
options.introTrainer=0;draws={};replays={};Class.draw{player=trainer};assert(#draws==2 and draws[1][1]==trainer)
assert(G.draw==nativeDraw and P.markUiSpriteRedraw==nativeReplay)
print('PASS final-resolution-only logo, native toggle, raised placement, error cleanup and Ash quad replacement')
