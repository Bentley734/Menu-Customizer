local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
local t={x=0,y=0,sx=1,sy=1};local stack={};local calls={}
local G={}
function G.push()stack[#stack+1]=t;t={x=t.x,y=t.y,sx=t.sx,sy=t.sy}end
function G.pop()t=table.remove(stack)end
function G.origin()t={x=0,y=0,sx=1,sy=1}end
function G.translate(x,y)t.x=t.x+x*t.sx;t.y=t.y+y*t.sy end
function G.scale(x,y)t.sx=t.sx*x;t.sy=t.sy*y end
function G.setShader()end;function G.setScissor()end
local F={CHAR_SELECTOR_ARROW=239,measure=function(s,opts)return #s*(opts and opts.font=='narrow' and 4.5 or 5) end}
function F.draw(s,x,y,opts)calls[#calls+1]={s=s,x=t.x+x*t.sx,y=t.y+y*t.sy,sx=t.sx,sy=t.sy}end
function F.drawGlyph(id,x,y,opts)F.draw('>',x,y,opts)end
local api=assert(loadfile('lib/emerald_battle_layout.lua'))()(G)
local frames={};local custom={frames=function(mode,r)frames[#frames+1]=mode end}
local battle={menuIndex=2,moveIndex=3,player={name='NIDOKING',curMoves={{id=1,pp=15},{id=2,pp=25},{id=3,pp=35},{id=4,pp=20}}},data={moves={
 [1]={name='SURF',pp=15,type='WATER'},[2]={name='HORN ATTACK',pp=25,type='NORMAL'},[3]={name='POISON STING',pp=35,type='POISON'},[4]={name='SEISMIC TOSS',pp=20,type='FIGHTING'}}}}
for _,size in ipairs({{774,232},{1600,480},{960,360}})do
 local r={x=136,y=496,w=size[1],h=size[2]};local edge=8*r.h/48
 calls={};api.commands(F,battle,1,r,custom,{},{});
 check(frames[#frames]=='none','commands retain single full-width frame')
 for i=1,4 do check(calls[i+(i>2 and 1 or 0)].x>r.x+edge+(r.w-2*edge)*.4,'commands in right pane')end
 local first,last=calls[#calls-1],calls[#calls]
 check(first.s=='What will' and last.s=='NIDOKING do?','two-line Emerald prompt')
 check(first.x<r.x+r.w*.4,'prompt in left pane')
 check(calls[1].sx>=3,'commands enlarged at normal desktop sizes')
 calls={};api.moves(F,battle,r,custom,function()return {}end,function(s)return s end,{})
 check(frames[#frames]=='moves','move frame layout retained')
 local entries={};for _,c in ipairs(calls)do if battle.data.moves[1].name==c.s or c.s=='HORN ATTACK' or c.s=='POISON STING' or c.s=='SEISMIC TOSS'then entries[#entries+1]=c end end
 local cw=(r.w*2/3-2*edge)/2;local ch=(r.h-2*edge)/2
 for i,c in ipairs(entries)do
  local left=r.x+edge+(i-1)%2*cw;local top=r.y+edge+math.floor((i-1)/2)*ch
  check(c.x>=left and c.x+F.measure(c.s,{font='narrow'})*c.sx<=left+cw+1,'complete name fits its quarter')
  check(math.abs((c.x+F.measure(c.s,{font='narrow'})*c.sx/2)-(left+cw/2))<=1,'move name centered in its quarter')
  check(math.abs(c.y+8*c.sy-(top+ch/2))<=1,'move vertically centered')
  check(c.sx==c.sy and c.sx>=3,'move font larger with square pixels')
 end
 check(#entries==4 and #stack==0,'all four moves and graphics state restored')
end
local text=assert(io.open('lib/gb_menus.lua')):read('*a')
local labelSource=assert(text:match('(  local function label%(text,x,y,render,%.%.%.%).-)  Font.draw=function'))
local mod={exports={battleHudScope=true,battleHudCapture=true,battleFontScope=true}}
local env=setmetatable({mod=mod,Font={_menuCustomizerGB={}},unpack=table.unpack or unpack},{__index=_G})
local label=assert(load(labelSource..'return label','HUD labels','t',env))()
label('NIDOKING',8,0,function()check(mod.exports.battleFontScale==.75,'HUD names enlarged by 50 percent')end)
label('100',40,8,function()check(mod.exports.battleFontScope==false,'level digits retain cartridge font')end)
label('<LV>100',48,8,function()check(mod.exports.battleFontScope==false,'Gen2 level marker and digits match')end)
check(mod.exports.battleFontScope==true and mod.exports.battleFontScale==nil,'HUD scope restored')
print('PASS '..checks..' Emerald prompt/grid/HUD label checks')
