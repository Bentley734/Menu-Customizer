local function read(p)local f=assert(io.open(p));local s=f:read('*a');f:close();return s end
local tx,ty,sx,sy=0,0,1,1;local stack={};local ink
local G={}
function G.push()stack[#stack+1]={tx,ty,sx,sy}end
function G.pop()tx,ty,sx,sy=unpack(table.remove(stack))end
function G.transformPoint(x,y)return tx+x*sx,ty+y*sy end
function G.translate(x,y)tx,ty=tx+x*sx,ty+y*sy end
function G.scale(x,y)sx,sy=sx*x,sy*y end
function G.getDPIScale()return 1 end
local values={};local mod={generation=3,exports={textScopes={currentScope=function()return'menu'end}},options={get=function(_,k)return values[k]end}}
function mod:read(p)return read(p)end
local env=setmetatable({love={graphics=G},load=function(s)return assert(load(s,'size','t',env))end},{__index=_G})
-- Factory's nested module shares the same graphics fixture.
env.load=function(s)return assert(load(s,'nested','t',env))end
local M=assert(load(read('lib/section_font_size.lua'),'section','t',env))()(mod)
local F={measure=function(s)return #s*8 end,draw=function(s,x,y)ink={x=tx+x*sx,y=ty+y*sy,sx=sx,sy=sy};return #s,x+#s*8,y end,drawGlyph=function()end}
M.decorate(F,false)
for _,scope in ipairs({'menu','start','option','dialogue','intro','savedGame','saveSummary','mart','pc','battle','battleName','party','bag','summary','pokedex','trainerCard','other','loadReport','mods','battleCommands','battlePrompt','moveSelect','moveLearning'})do
 for _,base in ipairs({1,2,3,4})do
  for choice=1,3 do
   tx,ty,sx,sy=0,0,base,base;values[scope..'SectionFontSize']=choice
   M.with(scope,function()
    local expected=choice==2 and base or math.max(1,math.floor(base*(choice==1 and .5 or 2)))
    assert(math.abs(F.measure('AB')-16*expected/base)<1e-6,'measurement matches scaled glyphs')
    F.draw('AB',10,20)
    assert(ink.sx==expected and ink.sy==expected,'whole square pixels')
    assert(ink.x==10*base and ink.y==20*base,'anchor preserved')
   end)
   assert(#stack==0 and sx==base and sy==base,'graphics state restored')
  end
 end
 values[scope..'SectionFontSize']=nil
end
assert(M.choice()==2 and M.current==nil,'unsaved sections retain Medium/current size')
values.martSectionFontSize=3;assert(M.choice('mart')==3 and M.choice('pc')==2,'independent scopes')
local organize=assert(load(read('lib/menu_organization.lua')))()
local entries={{id='wide_battleCommandsTextColor',label='BATTLE COMMAND OPTIONS TEXT COLOR'},{id='wide_martSectionFontSize',label='POKE MART FONT SIZE'},{id='wide_savedGameSectionFontSize',label='SAVED GAME MESSAGE FONT SIZE'}}
local rows=organize(entries,function()end);local labels={}
local function visit(rows)for _,r in ipairs(rows)do labels[r.id]=r.label;if r.children then visit(r.children)end end end
visit(rows)
assert(labels.wide_battleCommandsTextColor=='COLOR')
assert(labels.wide_martSectionFontSize=='FONT SIZE')
assert(labels.wide_savedGameSectionFontSize=='FONT SIZE')
assert(entries[1].label=='BATTLE COMMAND OPTIONS TEXT COLOR')
print('PASS 23 section sizes at four scales, all presets, integer glyphs, preserved anchors/defaults, isolation and concise submenu labels')

local fallbackEnv=setmetatable({require=function()return{}end},{__index=_G})
local moves=assert(load(read('lib/battle_move_screen.lua'),'move names','t',fallbackEnv))()({})
for _,name in ipairs({'SMOKESCREEN','THUNDERPUNCH','SELFDESTRUCT'})do
 local lines=moves.wrapName(name,6);assert(#lines==1 and lines[1]==name,'single-word move stays intact')
end
local lines=moves.wrapName('WATER GUN',6);assert(#lines==2 and lines[1]=='WATER'and lines[2]=='GUN')
print('PASS single-word move names never acquire internal spaces or breaks')
