local root=arg[1]
local checks=0
local function check(ok,msg) checks=checks+1;assert(ok,msg)end
local surface=1
local calls={};local t={x=0,y=0,sx=1,sy=1};local stack={}
local G={}
function G.push()stack[#stack+1]={x=t.x,y=t.y,sx=t.sx,sy=t.sy}end
function G.pop()t=table.remove(stack)end
function G.translate(x,y)t.x=t.x+x*t.sx;t.y=t.y+y*t.sy end
function G.scale(x,y)t.sx=t.sx*x;t.sy=t.sy*(y or x)end
function G.transformPoint(x,y)return t.x+x*t.sx,t.y+y*t.sy end
function G.origin()t={x=0,y=0,sx=1,sy=1}end
function G.rectangle(kind,x,y,w,h)calls[#calls+1]={kind=kind,x=(t.x+x*t.sx)/surface,y=(t.y+y*t.sy)/surface,w=w*t.sx/surface,h=h*t.sy/surface}end
function G.draw(image,q,x,y)calls[#calls+1]={kind='image',x=(t.x+(x or 0)*t.sx)/surface,y=(t.y+(y or 0)*t.sy)/surface}end
function G.newQuad(...)return {...}end
function G.newCanvas()return {setFilter=function()end}end
for _,name in ipairs({'setShader','setColor','setScissor','setBlendMode'})do G[name]=function()end end
G.clear=function(...)calls[#calls+1]={kind='clear',color={...}}end
G.setCanvas=function(c)surface=c and 2 or 1 end
G.getShader=function()end
love={graphics=G,timer={getTime=function()return 10 end}}
local spaceAlias=false
local Font={TTF_BASE=10000}
function Font.encode(text)if spaceAlias and text=='¥' then return {32} end;local tags={['<PO>']=0x70,['<KE>']=0x71,['<PK>']=0xE1,['<MN>']=0xE2,["'d"]=187,["'l"]=188,["'m"]=229,["'r"]=228,["'s"]=189,["'t"]=190,["'v"]=191};local out={};local i=1;while i<=#text do local tag=text:match('^<[^>]+>',i) or (tags[text:sub(i,i+1)] and text:sub(i,i+1));if tag and tags[tag] then out[#out+1]=tags[tag];i=i+#tag else out[#out+1]=text:byte(i);i=i+1 end end;return out end
function Font.advanceOf()return 8 end
function Font.width(text)local w=0;for _,c in ipairs(Font.encode(text))do w=w+Font.advanceOf(c)end;return w end
function Font.drawCode(c,x,y)assert(math.abs(t.sx-t.sy)<.00001,'rendered text must have uniform proportions');calls[#calls+1]={kind='glyph',code=c,x=(t.x+x*t.sx)/surface,y=(t.y+y*t.sy)/surface,w=8*t.sx/surface,h=8*t.sy/surface}end
function Font.draw(text,x,y)local pen=x;for _,c in ipairs(Font.encode(text))do Font.drawCode(c,pen,y);pen=pen+Font.advanceOf(c)end;return pen-x end
function Font.drawBox(x,y,w,h)G.rectangle('fill',x*8,y*8,w*8,h*8)end
package.loaded['src.render.Font']=Font
package.loaded['src.render.GameViewport']={}
local Palette={resolve=function(p)return p end,remap=function(p)return p end,available=function()return true end,useRaw=function()end,use=function()end}
package.loaded['src.render.GbcPalette']=Palette
package.path='./?.lua;./?/init.lua;'..package.path
local Renderer=require('src.render.Renderer')
Renderer.fitScale=function(self)
 return math.max(1,math.floor(math.min(960/(self.uiWidth or 160),600/(self.uiHeight or 144))))
end
Renderer.setUISize=function(self,w,h)self.uiWidth,self.uiHeight=w,h end
local Chrome=require('src.ui.gen2.Chrome')
require('src.ui.game3.frlg_font')
local Runtime={hooks={chains={}}};package.loaded['src.mods.Runtime']=Runtime
local values={menuTheme=1,menuTransition=1,controlsLegend=3}
local function read(path)local f=assert(io.open(path,'rb'));local s=f:read('*a');f:close();return s end
local mod={id='gen3transparency',path=root,generation=2,exports={},options={get=function(_,key)return values[key]end},
 save={get=function()end},assets={image=function(_,path)return {setFilter=function()end,getDimensions=function()return 24,24 end}end},
 hooks={wrap=function(_,key,cb)Runtime.hooks.chains[key]=Runtime.hooks.chains[key] or {};table.insert(Runtime.hooks.chains[key],{owner='gen3transparency',callback=cb})end},
 events={on=function()end},log={info=function()end}}
function mod:read(path)return read(root..'/'..path)end
local catalog=assert(load(mod:read('lib/border_catalog.lua')))()
mod.generation=1
assert(load(mod:read('lib/gb_menus.lua')))()(mod,catalog)
mod.generation=2
local C=assert(load(mod:read('lib/gb_menus.lua')))()(mod,catalog)
-- Independent global setting persists and covers native secondary arrows.
local arrowRow
for _,row in ipairs(C.rows)do if row.id=='wide_arrowSelector' then arrowRow=row end end
check(arrowRow~=nil and C.setting('arrowSelector')==1,'global arrow row defaults to native')
local arrowGame={options={},writeOptions=function()end}
C.persist(arrowGame,'arrowSelector',2)
check(arrowGame.options.modOptions.gen3transparency.arrowSelector==2,'global selector persists independently')
values.arrowSelector=2
check(C.arrows.id()==1,'global Pokeball uses its own setting')
for i=2,10 do
 values.arrowSelector=i;calls={};Font.drawCode(0xED,20,30)
 check(#calls>0 and calls[1].kind=='fill','secondary arrows use replacement artwork')
end
values.arrowSelector=1
local items={{label='POKEMON'},{label='POKEGEAR'},{label='LONG PLAYER NAME'},{label='MODS'}}
local list=Chrome.List.new({items=items,x=12,y=2,rows=4,spacing=2,index=1,palette=Chrome.DEFAULT_BOX_PALETTE})
local screen={screenId='Gen2StartMenu',items=items,list=list}
function screen:draw()Chrome.box(10,0,10,10);self.list:draw()end
local world={map={id='TEST'}}
local game={world=world,stack={states={world,screen},top=function(self)return self.states[#self.states]end}}
for selector=1,4 do for alignment=1,3 do for index=1,#items do
 values.startSelector=selector;values.startJustify=alignment;list.index=index
 calls={};C.draw(game,{width=960,height=600,scale=4,gameX=160,gameY=12})
 check(C.layouts.start.w==320 and C.layouts.start.h==320,'transformed label paper preserves native START bounds')
 local labels={};local markerAt
 for n,call in ipairs(calls)do
  if call.kind=='glyph' and call.code==items[index].label:byte(1) and math.abs(call.y-(16+(index-1)*16))<.01 then labels[#labels+1]={n=n,call=call}end
  if selector==3 and call.kind=='glyph' and call.code==0xED then markerAt=n end
 end
 check(#labels>0,'palette-rendered label is drawn')
 local selected
 for _,entry in ipairs(labels)do if entry.call.x>=96 and entry.call.x<152 then selected=entry;break end end
 check(selected~=nil,'aligned label stays within panel')
 if selector==3 then
  check(markerAt~=nil and markerAt>selected.n,'arrow drawn after opaque label paper')
  check(calls[markerAt].x+8<=selected.call.x,'arrow footprint stays before text')
 elseif selector==2 or selector==4 then
  local seen=false
  for n,call in ipairs(calls)do
   if n>selected.n and call.kind=='fill' and (call.h==1 or call.w==2 and call.h==2) then seen=true end
  end
  check(seen,'underline/dots drawn after label')
 end
end end end
-- Native renderer still works after a fresh mod instance changes generation.
local C2=assert(load(mod:read('lib/gb_menus.lua')))()(mod,catalog)
check(C2.drawSelector~=nil,'deferred selector survives reload')
values.menuTheme=2;C2.draw(game,{width=960,height=600,scale=4,gameX=160,gameY=12})
check(C2.theme.measure('POKEMON')>0,'native Emerald metrics available on Gen 2')
C2.drawScope=true
check(Font.width('POKEMON')==C2.theme.measure('POKEMON')/2,'GB pen and measure use proportional Emerald metrics')
check(Font.advanceOf(0x70)==C2.theme.measure('PO')/2,'PO compressed glyph uses Emerald advance')
check(Font.advanceOf(0x71)==C2.theme.measure('Ké')/2,'KE compressed glyph uses Emerald advance')
check(Font.advanceOf(0xE1)==C2.theme.measure('PK')/2,'PK ligature uses Emerald advance')
check(Font.advanceOf(0xE2)==C2.theme.measure('MN')/2,'MN ligature uses Emerald advance')
for _,suffix in ipairs({"'d","'l","'m","'r","'s","'t","'v"})do
 local c=Font.encode(suffix)[1]
 check(Font.advanceOf(c)==C2.theme.measure(suffix)/2,'contraction advance matches Emerald font '..suffix)
 calls={};Font.draw(suffix,8,16)
 local native=false;for _,call in ipairs(calls)do if call.kind=='glyph' then native=true end end
 check(not native,'contraction uses Emerald font '..suffix)
end

for border=1,#catalog.entries do
 values.menuBorder=border
 for _,field in ipairs({' 87','101','  9'})do
  do
   local placed
   Font._menuCustomizerLabel(field,128,40,function(t,x,y)placed={t=t,x=x,y=y}end)
   check(math.abs(placed.x+Font.width(placed.t)-(128+#field*8))<.0001,'numeric right edge remains aligned for border '..border)
   check(placed.y==40,'border selection preserves text baseline')
  end
 end
end
C2.drawingStart={}
check(Font.width('POKEMON')==C2.theme.measure('POKEMON'),'START uses full native Emerald font size')
C2.drawingStart=nil
C2.drawScope=false
check(Font.width('POKEMON')==56,'native font metrics restored outside menus')
-- Positioning and scaling use measured panel bounds for every menu group.
for _,group in ipairs({'start','option','save','other'})do
 for mode=1,10 do
  values[group..'Position']=mode;values[group..'Scale']=50
  values[group..'OffsetX']=0;values[group..'OffsetY']=0
  local x,y,w,h,scale=C2.layout(group,{x=80,y=16,w=80,h=80},{width=960,height=600,scale=4,gameX=160,gameY=12})
  check(x>=0 and y>=0 and x+w<=960 and y+h<=600,'docked scaled panel stays in bounds')
  if mode==1 then check(x==480 and y==76,'DEFAULT uses native anchor when scaling')end
  values[group..'OffsetX']=7;values[group..'OffsetY']=9
  local ox,oy=C2.layout(group,{x=80,y=16,w=80,h=80},{width=960,height=600,scale=4,gameX=160,gameY=12})
  check(ox==math.min(960-w,x+7) and oy==math.min(600-h,y+9),'offsets adjust actual panel')
 end
end
-- Exercise the real Gen 2 Options renderer, including its value branches.
for _,group in ipairs({'start','option','save','other'})do
 local resized={_menuCustomizerGroup=group,draw=function()Font.drawBox(2,2,10,10);Font.draw('TEST',24,32)end}
 local resizeGame={world=world,stack={states={world,resized},top=function()return resized end}}
 values.menuTheme=1;values[group..'Width']=120;values[group..'Height']=80
 values[group..'Scale']=100;values[group..'Position']=8;values[group..'OffsetX']=0;values[group..'OffsetY']=0
 calls={};C2.draw(resizeGame,{width=960,height=600,scale=4})
 check(math.abs(C2.layouts[group].w-384)<.001,'independent menu width changes panel geometry')
 check(math.abs(C2.layouts[group].h-256)<.001,'independent menu height changes panel geometry')
 local glyphs=0
 for _,call in ipairs(calls)do if call.kind=='glyph' then glyphs=glyphs+1;check(math.abs(call.w-call.h)<.001,'resizing preserves glyph proportions')end end
 check(glyphs==4,'resizing preserves complete menu text')
 values[group..'Width']=100;values[group..'Height']=100
end
values.menuTheme=2
local NativeOptions=require('src.ui.gen2.OptionsMenu')
local actions=0
local openValue=function()return 'OPEN' end
local optionRows={{label='MENUS',activate=function()actions=actions+1 end,value=openValue},{label='TEXT SPEED',values={1,2},key='speed',display={[1]='FAST',[2]='SLOW'}},{label='BACK',cancel=true}}
local optionsPage={screenId='Gen2OptionsMenu',isOpaque=true,index=1,scroll=0,game=game,options={speed=1},rows=optionRows,visible=NativeOptions.visible,draw=NativeOptions.drawPanel}
game.stack.states={world,optionsPage}
values.menuTheme=1
for align=1,3 do
 values.startJustify=align;calls={};C2.draw(game,{width=960,height=600,scale=4})
 local first,arrow,valueColon
 for _,call in ipairs(calls)do
  if call.kind=='glyph' and call.code==string.byte('M') and call.y==16 then first=call end
  if call.kind=='glyph' and call.code==0xED then arrow=call end
  if call.kind=='glyph' and call.code==string.byte(':') and call.y==24 then valueColon=true end
 end
 local expected=align==1 and 18 or align==2 and 65 or 112
 check(first and first.x==expected,'Options labels follow selected justification')
 check(arrow and arrow.x+8<=first.x,'Options cursor follows label justification')
 check(not valueColon,'OPEN submenu colon is absent')
 check(optionRows[1].value==openValue,'submenu value reader restored after drawing')
 local realValue=false;for _,call in ipairs(calls)do if call.kind=='glyph' and call.code==string.byte('F') and call.y==40 then realValue=true end end
 check(not realValue,'main Options page hides setting values')
end
check(#optionsPage.view==2,'main Options excludes BACK entry')
setmetatable(optionsPage,NativeOptions)
function game.stack:push(state)self.states[#self.states+1]=state end
function game.stack:pop()return table.remove(self.states)end
optionsPage.view[1].activate(game);check(actions==1,'existing submenu activation remains available')
optionsPage.view[2].activate(game)
local detail=game.stack:top()
check(detail.sub and detail.options==optionsPage.options,'setting opens detail page with shared option storage')
check(detail:visible()[1]==optionRows[2] and detail:visible()[2].cancel,'detail retains original control and BACK')
detail:cycle(detail:row(),1)
check(optionsPage.options.speed==2,'detail toggle updates parent options')
calls={};C2.draw(game,{width=960,height=600,scale=4})
local detailValue=false;for _,call in ipairs(calls)do if call.kind=='glyph' and call.code==string.byte('S') and call.y==32 then detailValue=true end end
check(detailValue,'detail page displays its setting value')
local colon=false;local largeValue=false
for _,call in ipairs(calls)do
 if call.kind=='glyph' and call.code==string.byte(':') then colon=true end
 if call.kind=='glyph' and call.code==string.byte('S') and call.y==32 and call.x>=88 then largeValue=true end
end
check(not colon,'Emerald submenu values omit the second-line colon')
check(largeValue,'submenu values sit below labels and align right')

detail:leave_();check(game.stack:top()==optionsPage,'BACK returns to clean main Options page')
values.menuTheme=2
-- Save summary values share an edge and time is one proportional string.
local savedPrint=Chrome._menuCustomizerSavePrint
local summaryCalls={}
Chrome._menuCustomizerSavePrint=function(text,x,y)summaryCalls[#summaryCalls+1]={text=text,x=x,y=y}end
values.menuTheme=2;C2.drawScope=true;C2.drawingSave=true
Chrome.print(' 0',17,4);Chrome.print('  3',16,6)
Chrome.print(' 12',13,8);Chrome.print(':',16,8);Chrome.print('05',17,8)
check(#summaryCalls==3,'save summary combines time fragments into one print')
check(summaryCalls[3].text=='12:05','save time removes padding and retains zero-padded minutes')
for _,v in ipairs(summaryCalls)do check(math.abs(v.x*8+Font.width(v.text)-152)<.001,'save summary value is right aligned')end
values.menuTheme=2;C2.drawScope=false;C2.drawingSave=nil;C2.saveHours=nil;Chrome._menuCustomizerSavePrint=savedPrint

-- Gen 1 prints directly through Font rather than the Gen 2 Chrome path.
values.menuTheme=2;C2.drawScope=true;C2.drawingSave=true
for _,v in ipairs({{'ASH',96,16},{' 0',136,32},{'  3',128,48},{' 12:05',104,64}})do
 local printed
 Font._menuCustomizerLabel(v[1],v[2],v[3],function(text,x,y)printed={text=text,x=x,y=y}end)
 check(printed.x+Font.width(printed.text)==152,'Gen 1 player, badges, dex and time share the right edge')
 check(printed.y==v[3],'save summary keeps row baseline')
end
summaryCalls={};Chrome._menuCustomizerSavePrint=function(text,x,y)summaryCalls[#summaryCalls+1]={text=text,x=x,y=y}end
Chrome.print('PLAYER ASH',5,2)
check(#summaryCalls==2 and summaryCalls[1].text=='PLAYER','Gen 2 player label is separate from its value')
check(summaryCalls[2].x*8+Font.width(summaryCalls[2].text)==152,'Gen 2 player value shares summary right edge')
C2.drawScope=false;C2.drawingSave=nil;Chrome._menuCustomizerSavePrint=savedPrint

local cardPrint=Chrome._menuCustomizerPrint
local cardCalls={}
Chrome._menuCustomizerPrint=function(text,x,y)cardCalls[#cardCalls+1]={text=text,x=x,y=y}end
C2.drawScope=true;C2.drawingTrainerCard=true
Chrome.printThrough('   0',11,12);Chrome.printThrough(':',15,12);Chrome.printThrough('00',16,12)
check(#cardCalls==1 and cardCalls[1].text=='0:00','trainer card renders hours and minutes as one string')
check(cardCalls[1].x*8+Font.width(cardCalls[1].text)==144,'trainer card time retains the field right edge')
for _,count in ipairs({'  3',' 42','251'})do
 Chrome.printThrough(count,15,10)
 local printed=cardCalls[#cardCalls]
 check(printed.x*8+Font.width(printed.text)==144,'trainer card dex count shares play time right edge')
end
local Card=require('src.ui.gen2.TrainerCard');local tileCalls=0;local nativeTile=Card._menuCustomizerTile
Card._menuCustomizerTile=function()tileCalls=tileCalls+1 end
local card={status={}};Card.tile(card,card.status,46,15,12)
check(tileCalls==0,'native trainer card colon tile is suppressed for Emerald text')
C2.drawingTrainerCard=nil;Card.tile(card,card.status,46,15,12)
check(tileCalls==1,'native trainer card colon remains with theme disabled')
Card._menuCustomizerTile=nativeTile;Chrome._menuCustomizerPrint=cardPrint;C2.drawScope=false;C2.cardHours=nil

-- MENUS navigation uses large aligned labels and detail pages for controls.
local stepped=0
local setting={label='SCALE',value=function()return '100%' end,step=function()stepped=stepped+1 end}
local menuPage=C2.openPage(game,'MENUS',{setting,{label='OTHER',activate=function()actions=actions+1 end}})
check(menuPage.rows[1].value==nil and menuPage.rows[1].activate~=nil,'MENUS setting becomes a navigation entry')
local pageDraw=menuPage.draw
menuPage.draw=function(self)
 check(Font.width('SCALE')==C2.theme.measure('SCALE'),'MENUS labels use START-sized Emerald glyphs')
 pageDraw(self)
end
C2.draw(game,{width=960,height=600,scale=4})
menuPage.rows[1].activate(game)
local control=game.stack:top()
check(control.detail and control.rows[1]==setting,'MENUS setting opens original control in detail page')
control.rows[1].step(game,1);check(stepped==1,'MENUS detail control remains adjustable')
game.stack:pop();game.stack:pop()
local nativeDraw=optionsPage.draw
optionsPage.draw=function(self)
 check(Font.width('MENUS')==C2.theme.measure('MENUS'),'main Options uses START-sized Emerald glyphs')
 nativeDraw(self)
end
C2.draw(game,{width=960,height=600,scale=4})
optionsPage.draw=nativeDraw
-- An unsupported native character may alias to space; it must remain blank.
spaceAlias=true;calls={}
check(C2.theme.gbGlyph(32,0,0),'space is handled by themed font')
check(#calls==0,'space never draws atlas pixels or an aliased symbol')
check(C2.theme.gbAdvance(32)==C2.theme.measure(' ')/2,'space retains its native Emerald advance')
spaceAlias=false
-- Both native card background operations survive the live-map compositor.
for _,id in ipairs({'TrainerCard','Gen2TrainerCard','Gen2PackMenu','TouchControlsEditor','CodebreakerCheats'}) do
 local card={screenId=id,isOpaque=true,draw=function()
  G.clear(1,1,1,1);G.rectangle('fill',0,0,160,144)
  Font.draw('TRAINER CARD',8,8)
 end}
 game.stack.states={world,optionsPage,card};calls={};C2.draw(game,{width=960,height=600,scale=4})
 local paper,opaqueClear=false,false
 for _,call in ipairs(calls)do
  if call.kind=='fill' and call.x==0 and call.y==0 and call.w==160 and call.h==144 then paper=true end
  if call.kind=='clear' and call.color[4]==1 then opaqueClear=true end
 end
 check(paper,'native full-screen background retained for '..id)
 check(opaqueClear,'native opaque clear retained for '..id)
end
-- Native Options clears must not fill custom border transparency.
values.menuTheme=2;game.stack.states={world,optionsPage};calls={}
C2.draw(game,{width=960,height=600,scale=4})
local fullPaper=false;local interiorPaper=false
for _,call in ipairs(calls)do
 if call.kind=='fill' and call.x==0 and call.y==0 and call.w==160 and call.h==144 then fullPaper=true end
 if call.kind=='fill' and call.w>100 and call.h>100 then interiorPaper=true end
end
check(not fullPaper,'custom Options frame has no full-canvas white backing')
check(interiorPaper,'Options retains paper inside its frame')
local id=optionsPage.screenId;local sub=optionsPage.sub
optionsPage.screenId=nil;optionsPage.sub=true;calls={}
C2.draw(game,{width=960,height=600,scale=4})
local submenuBacking=false
for _,call in ipairs(calls)do
 if call.kind=='fill' and call.x==0 and call.y==0 and call.w==160 and call.h==144 then submenuBacking=true end
end
check(not submenuBacking,'Options submenu without a screen id preserves transparent frame edges')
optionsPage.screenId=id;optionsPage.sub=sub

-- Controls and cheat lists use the selected frame instead of a flat backing.
local framedList={title='CONTROLS',items={{label='UP'}},drawItemBox=function()end,isOpaque=true,
 draw=function()G.rectangle('fill',0,0,160,144);Font.draw('CONTROLS',8,4);Font.draw('UP',16,24)end}
game.stack.states={world,optionsPage,framedList};calls={};C2.draw(game,{width=960,height=600,scale=4})
local flatBacking=false;local tiles=0
for _,call in ipairs(calls)do
 if call.kind=='fill' and call.x==0 and call.y==0 and call.w==160 and call.h==144 then flatBacking=true end
 if call.kind=='image' then tiles=tiles+1 end
end
check(not flatBacking,'Controls and cheats list backing preserves transparent frame edges')
check(tiles>=4,'Controls and cheats draw selected border tiles')
for _,generation in ipairs({1,2})do
 mod.generation=generation;game.stack.states={world,framedList};calls={}
 check(C2.context(game)~=nil,'standalone mod cheat list is recognized without an Options parent')
 C2.draw(game,{width=960,height=600,scale=4})
 local images=0;local nativeFill=false
 for _,call in ipairs(calls)do
  if call.kind=='image' then images=images+1 end
  if call.kind=='fill' and call.x==0 and call.y==0 and call.w==160 and call.h==144 then nativeFill=true end
 end
 check(images>=4 and not nativeFill,'standalone cheats use selected border and Emerald drawing in both generations')
end
mod.generation=2
local cheatWidth,headerWidth
local largeCheats={title='CODEBREAKER',screenId='GameSharkCompat',isOpaque=true,items={{label='SEEN ALL'}},drawItemBox=function()end,
 draw=function()
  G.rectangle('fill',0,0,160,144)
  Font._menuCustomizerLabel('CODEBREAKER',8,4,function(text)headerWidth=Font.width(text)end)
  cheatWidth=Font.width('SEEN ALL');Font.draw('SEEN ALL',16,24)
 end}
game.stack.states={world,largeCheats};C2.draw(game,{width=960,height=600,scale=4})
check(cheatWidth==C2.theme.measure('SEEN ALL'),'cheat rows use the same full Emerald font size as START')
check(headerWidth==C2.theme.measure('CODEBREAKER')/2,'cheat heading stays compact and clears the first row')
check(not C2.drawingCheats and not C2.compactText,'cheat font sizing is restored after rendering')
-- Dialogue borders are opt-in and do not enable menu font replacement.
local TextBox=require('src.render.TextBox')
local originalDialogue=TextBox._menuCustomizerDialogueDraw
TextBox._menuCustomizerDialogueDraw=function()Font.drawBox(0,12,20,6)end
for _,enabled in ipairs({0,1})do
 values.dialogueBorder=enabled;calls={};C2.drawScope=false
 TextBox.draw({})
 local tiles=0;for _,call in ipairs(calls)do if call.kind=='image' then tiles=tiles+1 end end
 check((tiles>0)==(enabled==1),'dialogue border follows toggle')
 check(not C2.dialogueScope,'dialogue rendering restores scope')
end
mod.generation=1;values.dialogueBorder=1;C2.dialogueRects={};TextBox.draw({})
check(#C2.dialogueRects==4,'Gen 1 dialogue marks four colored border strips')
for _,rect in ipairs(C2.dialogueRects)do check(rect.colors==false and (rect.w==8 or rect.h==8),'dialogue border bypasses palette remapping without covering its interior')end
mod.generation=2;C2.dialogueRects={}
TextBox._menuCustomizerDialogueDraw=originalDialogue;values.dialogueBorder=0
-- Gen 2 menu-account descriptions must not affect START docking.
local descriptionDraws=0
screen.showDescription=true
screen.draw=function(self)
 Chrome.box(10,0,10,10);self.list:draw()
 if self.showDescription and self.list.index==2 then
  descriptionDraws=descriptionDraws+1
  Chrome.paletteFill(0,104,80,40);Chrome.print('Save your',0,14)
 end
end
game.stack.states={world,screen}
values.startScale=100;values.startPosition=8;values.startOffsetX=0;values.startOffsetY=0
local baseline
for index=1,#items do
 list.index=index;C2.draw(game,{width=960,height=600,scale=4})
 local b=C2.layouts.start
 if not baseline then baseline={x=b.x,y=b.y,w=b.w,h=b.h} end
 check(b.x==baseline.x and b.y==baseline.y and b.w==baseline.w and b.h==baseline.h,'START stays fixed across described and undescribed entries')
 check(screen.showDescription==true,'native menu-account setting retained after drawing')
end
check(descriptionDraws==0,'Gen 2 START description panel suppressed')
for _,id in ipairs({'Gen2PackMenu','Gen2PartyMenu','Gen2PokedexMenu','Gen2OptionsMenu','Gen2SaveMenu','Gen2TrainerCard','Gen2Pokegear'})do
 local page={screenId=id,draw=function()Font.drawBox(2,2,12,10);Font.draw('POKEMON',24,24)end}
 game.stack.states={world,page};calls={};C2.draw(game,{width=960,height=600,scale=4})
 local used=false;for _,call in ipairs(calls)do if call.kind=='image' then used=true end end
 check(used,'Emerald theme covers '..id)
end
local modal={screenId='Gen2OptionsMenu',draw=function()Font.drawBox(2,2,12,10)end}
game.stack.states={world,modal};values.optionScale=100;values.optionPosition=8;values.optionOffsetX=0;values.optionOffsetY=0
C2.draw(game,{width=960,height=600,scale=4})
check(C2.layouts.option.w==384 and C2.layouts.option.h==320,'option modal uses measured box rather than whole screen')
local chromeKey='src.ui.game3.chrome';local oldChrome=package.loaded[chromeKey]
local nativeFrames=0
local chrome={dialogueWindow=function()return 1,15,28,4 end}
for _,key in ipairs({'dialogueFrame','signFrame','userFrame','stdFrame','fixedStdFrame'})do chrome[key]=function()nativeFrames=nativeFrames+1 end end
package.loaded[chromeKey]=chrome;mod.generation=3
local selectedDialogue=0
assert(load(mod:read('lib/menu_borders.lua')))()(mod,function(key)if key=='dialogueBorder' then return selectedDialogue elseif key=='menuBorder' then return 13 else return 2 end end,catalog,function()return true end)
chrome.dialogueFrame();check(nativeFrames==1,'Gen 3 dialogue stays native with toggle off')
selectedDialogue=1;calls={};chrome.dialogueFrame();chrome.signFrame()
check(nativeFrames==1 and #calls>0,'Gen 3 dialogue and signposts inherit selected border with toggle on')
mod.generation=2;package.loaded[chromeKey]=oldChrome
-- An HD party menu owns a 4x surface but keeps the classic logical layout.
-- Capture the whole page, including every name and the bottom prompt.
mod.generation=1
game.save={party={}}
for _,name in ipairs({'TORCHIC','BULBASAUR','CHARMANDER','PIKACHU','EEVEE','MEW'})do
 game.save.party[#game.save.party+1]={species=name,name=name}
end
game.save.party[1].nickname='';game.save.party[2].nickname=''
for _,theme in ipairs({1,2})do
 values.menuTheme=theme;values.otherWidth=100;values.otherHeight=100
 values.otherPosition=8;values.otherScale=100
 local hd={screenId='PartyMenu',isOpaque=true,holdsUIAnchors=true,
  uiSize=function()return 640,576 end}
 function hd:draw()
  G.push();G.scale(4,4)
  G.rectangle('fill',0,0,160,144)
  for i,mon in ipairs(game.save.party)do
   Font.draw(mon.nickname or mon.name,24,(i-1)*16)
   Font.draw('HP:',40,(i-1)*16+8)
  end
  Font.draw('CHOOSE A POKEMON',8,112)
  G.pop()
 end
 game.stack.states={world,hd};calls={};C2.game=game
 Renderer:setUISize(hd:uiSize())
 check(Renderer:fitScale()==4,'HD menu does not shrink world/menu fit to 1x')
 check(Renderer.uiWidth==160 and Renderer.uiHeight==144,'hidden engine canvas stays classic while HD menu is mirrored')
 C2.draw(game,{width=960,height=600,scale=Renderer:fitScale()})
 check(C2.layouts.other.w==640 and C2.layouts.other.h==576,'party uses the classic 4x window fit')
 check(C2.context(game).group=='other','HD party anchors do not classify as SAVE')
 check(C2.layouts.other.w<=960 and C2.layouts.other.h<=600,'HD page fits viewport')
 check(math.abs(C2.bounds.w-160)<.001 and math.abs(C2.bounds.h-144)<.001,'full HD surface captured in classic bounds')
 local names,prompt={},false
 for _,call in ipairs(calls)do
  if call.kind=='glyph' or call.kind=='image' then
   if call.x>=24 and call.x<100 then
    for i=1,6 do if math.abs(call.y-(i-1)*16)<.001 then names[i]=true end end
   end
   if call.y>=112 and call.y<120 then prompt=true end
  end
 end
 for i=1,6 do check(names[i],'HD party name row '..i..' remains visible')end
 check(prompt,'HD party bottom prompt remains visible')
 check(game.save.party[1].nickname=='' and game.save.party[2].nickname=='','empty nicknames stay unchanged in save')
 check(C2.drawScope==false and #stack==0,'capture restores draw scope and transform')
end
game.stack.states={world,{screenId='BattleState',isBattle=true}}
Renderer:setUISize(640,576)
check(Renderer:fitScale()==1,'battle keeps its own surface scale')
check(Renderer.uiWidth==640 and Renderer.uiHeight==576,'battle surface request is unchanged')
game.stack.states={world};Renderer:setUISize(160,144)
check(Renderer:fitScale()==4,'closing party restores normal field fit')
-- Desktop Emerald START markers match the glyph baseline. iOS and OPTIONS
-- retain their previous anchors; resizing must not magnify the logical offset.
C2.resizeX,C2.resizeY=1,1
surface=1;G.origin()
for theme=1,2 do for _,options in ipairs({false,true})do
 values.menuTheme=theme
 for _,resize in ipairs({1,2,4})do
  C2.resizeX,C2.resizeY=resize,resize
  for selector=1,#C2.selectors.names do
   local baseline
   for _,platform in ipairs({'Linux','Windows','iOS'})do
    love.system={getOS=function()return platform end}
    calls={};C2.drawSelector({options=options,selection={x=40,y=30,width=50,selector=selector}})
    check(#calls>0,'selector draws on '..platform)
    local dy=not options and (platform=='Windows' or platform=='iOS') and theme==2 and -2 or 0
    if baseline then
     check(#calls==#baseline,'selector retains geometry')
     for i,call in ipairs(calls)do
      check(call.x==baseline[i].x and math.abs(call.y-baseline[i].y-dy/resize)<.00001,
       'selector platform offset in logical pixels, without changing horizontal placement')
     end
    else baseline=calls end
    check(#stack==0,'selector restores transform')
   end
  end
 end
end end
C2.resizeX,C2.resizeY=1,1
love.system=nil
print('PASS Menu Customizer native GBC palette, selectors, reload, Emerald theme and layout: '..checks..' checks')
