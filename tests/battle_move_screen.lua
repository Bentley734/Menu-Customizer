local function read(p)local f=assert(io.open(p));local s=f:read('*a');f:close();return s end

local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end

local texts,cursors,depth={},{},0

local boxes={}

local transforms,transform={}, {x=0,y=0,sx=1,sy=1}

local panelRect,panelLayout

local G={push=function()depth=depth+1;transforms[depth]={x=transform.x,y=transform.y,sx=transform.sx,sy=transform.sy}end,

 pop=function()transform=transforms[depth];transforms[depth]=nil;depth=depth-1 end}

for _,n in ipairs({'setShader','setScissor','setColor','rectangle'})do G[n]=function()end end

G.origin=function()transform={x=0,y=0,sx=1,sy=1}end

G.translate=function(x,y)transform.x=transform.x+x*transform.sx;transform.y=transform.y+y*transform.sy end

G.scale=function(x,y)transform.sx=transform.sx*x;transform.sy=transform.sy*y end

local function localPosition(x,y)return (transform.x+x*transform.sx-panelRect.x)/panelLayout.sx,

 (transform.y+y*transform.sy-panelRect.y)/panelLayout.sy end

local font={drawBox=function(...)boxes[#boxes+1]={...}end,

 draw=function(t,x,y)local px,py=localPosition(x,y);texts[#texts+1]={t=t,x=px,y=py,sx=transform.sx,sy=transform.sy}end,

 drawCode=function(c,x,y)local px,py=localPosition(x,y);cursors[#cursors+1]={c,px,py}end}

local env=setmetatable({love={graphics=G},require=function(n)if n=='src.render.Font'then return font end;return {displayName=function(t)return t end}end},{__index=_G})

local api=assert(load(read('lib/battle_move_screen.lua'),'menu','t',env))()()

for _,case in ipairs({{1024,288,1,1},{1434,201,1,1},{478,67,3,3},{390,117,3,3},{640,144,1,1},{960,240,2,3}})do

 local w,h,dx,dy=table.unpack(case);local rect={x=20,y=30,w=w,h=h};local p=api.layout(rect,dx,dy)

 check(math.abs(p.textSx*dx-p.textSy*dy)<1e-6,'square physical glyphs')

 check(p.x==rect.x and p.y==rect.y,'same top-left as commands/dialogue')

 check(math.abs(336*p.sx-w)<1e-6 and math.abs(64*p.sy-h)<1e-6,'same full width and height as commands/dialogue')

 check(p.textSx*dx>0,'positive text scale')

end

local b={phase='moveSelect',moveIndex=1,player={curMoves={{id='A',pp=29,ppUps=2},{id='B',pp=0},{id='A',pp=1}}},data={moves={A={name='THUNDERPUNCH',pp=35,type='ELECTRIC'},B={name='WATER GUN',pp=25,type='WATER'}}}}

for i=1,4 do

 texts,cursors={},{};b.moveIndex=i

 panelRect={x=0,y=0,w=1008,h=192};panelLayout=api.layout(panelRect)

 check(api.draw(b,panelRect,{}),'move menu draws')

 check(#cursors==1,'one selected cursor');check(cursors[1][2]==13+((i-1)%2)*101,'cursor column');local row=math.floor((i-1)/2);local name=({'THUNDERPUNCH','WATER GUN','THUNDERPUNCH','-'})[i];local lines=api.wrapName(name,9);local expected=8+row*24+(24-(8*1.2+(#lines-1)*11*1.2))/2;check(math.abs(cursors[1][3]-expected)<1e-6,'cursor centers with complete move name')

 local pp,typeName

 for _,t in ipairs(texts)do if math.abs(t.y-15)<1e-6 and t.x>264 then pp=t.t end;if math.abs(t.y-44)<1e-6 then typeName=t.t end;check(t.x+#t.t*8<=336,'text within panel');check(math.abs(t.sx-t.sy)<1e-6,'text is not stretched')end

 check(pp==({'29/49','0/25','1/35','--/--'})[i],'current / PP Ups maximum')

 check(typeName==({'ELECTRIC','WATER','ELECTRIC','--'})[i],'selected type')

 check(depth==0,'graphics state restored')

end

local wrapped=api.wrapName('POISON STING',10);check(wrapped[1]=='POISON' and wrapped[2]=='STING','wrap names at word boundaries')

local solid=api.wrapName('THUNDERPUNCH',10);check(solid[1]=='THUNDERPUN' and solid[2]=='CH','unbroken names use two lines')

check(#api.wrapName('SURF',10)==1,'short names stay on one line')

b.phase='messages';check(api.draw(b,{})==false,'messages use native panel')

b.phase='mimicSelect';check(api.draw(b,{})==false,'mimic retains native behavior')

local events,nativeCalls={},0

local B={drawTextArea=function()nativeCalls=nativeCalls+1 end}

local oldRequire=env.require

local theme={setting=function(k)return k=='style' and 2 or 50 end,

 panel=function()end,faded=function(fn)return fn()end}

local usedFrames=0;theme.panel=function()usedFrames=usedFrames+1 end

local moduleMod={find=function(id)return id=='battleuicustomizer' and {exports=theme}end,

 events={on=function(_,n,fn)events[n]=fn end}}

env.require=function(n)if n=='src.battle.BattleState'then return B end;return oldRequire(n)end

local withTheme=assert(load(read('lib/battle_move_screen.lua'),'menu integration','t',env))()(moduleMod)

local active=true;withTheme.installSourceGuard(function()return active end)

b.phase='moveSelect';B.drawTextArea(b);check(nativeCalls==0,'source move menu suppressed')

local kimGuard=B.drawTextArea

-- Simulate Customizer loading later and placing its own menu outside KIM.

B.drawTextArea=function(self)nativeCalls=nativeCalls+1;return kimGuard(self)end

events['mods.loaded']();B.drawTextArea(b);check(nativeCalls==0,'guard reinstalled outside late Customizer')

local once=B.drawTextArea;events['game.ready']();check(B.drawTextArea==once,'idempotent source guard')

active=false;B.drawTextArea(b);check(nativeCalls==2,'background-off forwards source owners')

active=true;b.phase='messages';B.drawTextArea(b);check(nativeCalls==4,'messages forward source owners')

b.phase='moveSelect';withTheme.draw(b,{x=0,y=0,w=1008,h=192},{})

check(#boxes==8,'Emerald avoids native frames')

check(usedFrames==0,'Emerald does not squeeze exported frames')

theme.setting=function()return 1 end

withTheme.draw(b,{x=0,y=0,w=1008,h=192},{})

check(#boxes==10,'native style keeps matching borders')



check(boxes[9][3]==28 and boxes[10][1]==28 and boxes[10][3]==14,'Emerald two-thirds move pane proportion')

local firstLine

for _,t in ipairs(texts)do if t.t:sub(1,7)=='THUNDER' and math.abs(t.y-8.6)<1e-6 then firstLine=t end end

check(firstLine and math.abs(firstLine.y-8.6)<1e-6,'wrapped move block is vertically centered')

font.draw=function()error('font failure')end;b.phase='moveSelect';check(not pcall(api.draw,b,{x=0,y=0,w=336,h=64},{}),'error propagated');check(depth==0,'error restores graphics')

print('PASS: '..checks..' move panel / PP / selected type / physical scale checks')



