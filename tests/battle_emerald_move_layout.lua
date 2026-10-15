-- Emerald glyphs use integer physical pixels while legacy borders fill the band.
local function read(path)local f=assert(io.open(path));local s=f:read('*a');f:close();return s end
local checks=0;local function check(v,why)checks=checks+1;assert(v,why)end
local function near(a,b)return math.abs(a-b)<1e-6 end
local transforms,depth={},0;local t={x=0,y=0,sx=1,sy=1};local glyphs,frameCalls={},{}
local G={}
function G.push()depth=depth+1;transforms[depth]=t;t={x=t.x,y=t.y,sx=t.sx,sy=t.sy}end
function G.pop()t=transforms[depth];transforms[depth]=nil;depth=depth-1 end
function G.origin()t={x=0,y=0,sx=1,sy=1}end
function G.translate(x,y)t.x=t.x+x*t.sx;t.y=t.y+y*t.sy end
function G.scale(x,y)t.sx=t.sx*x;t.sy=t.sy*y end
for _,key in ipairs({'setShader','setScissor','setColor'})do G[key]=function()end end
local F={CHAR_SELECTOR_ARROW=0xEF,measure=function(s)return #s*5 end}
function F.draw(s,x,y,opts)check(opts.maxWidth==nil,'Emerald labels use original full-string drawing');local width=type(s)=='string' and math.min(F.measure(s),opts.maxWidth or math.huge) or 8;glyphs[#glyphs+1]={s=s,x=t.x+x*t.sx,y=t.y+y*t.sy,sx=t.sx,sy=t.sy,font=opts.font,width=width*t.sx,height=16*t.sy,pane=x>=160 and 'right' or 'left'}end
function F.drawGlyph(s,x,y,opts)F.draw(s,x,y,opts)end
local origins={[3]={16,121,64,true},[4]={88,121,64,true},[5]={16,137,64,true},[6]={88,137,64,true},[7]={168,121,32,true},[9]={202,121,32,false},[10]={168,137,64,true}}
local C={WIN={MOVE_NAME_1=3,PP=7,PP_REMAINING=9,MOVE_TYPE=10},textOrigin=function(id)return table.unpack(origins[id])end}
local port={ready=function()return false end,presentationReady=function()return true end,
 presentation=function()return F,C end,presentationColors=function()return {}end}
local custom={nativeEmerald=port,emeraldFont=function()return true end,setting=function()return 3 end,
 frames=function(mode,rect,viewport)frameCalls[#frameCalls+1]={mode=mode,rect=rect}end}
local env=setmetatable({love={graphics=G},require=function(name)
 if name=='src.render.Font'then return {drawBox=function()error('unexpected native frame path')end}end
 return {displayName=function(s)return s end}
end},{__index=_G})
local api=assert(load(read('lib/battle_move_screen.lua'),'Emerald move layout','t',env))()({find=function()return {exports=custom}end})
local battle={phase='moveSelect',moveIndex=1,player={curMoves={{id='scratch',pp=34}}},data={moves={scratch={name='THUNDERPUNCH',pp=35,type='ELECTRIC'}}}}
for _,case in ipairs({{774,232,1,1},{1008,192,1,1},{1434,201,1,1},{478,67,3,3},{960,240,2,3},{160,48,1,1}})do
 local w,h,dx,dy=table.unpack(case);local rect={x=136,y=496,w=w,h=h}
 glyphs,frameCalls={},{}
 check(api.draw(battle,rect,{dpiX=dx,dpiY=dy}),'Emerald move screen draws')
 local inset=8*h/48;local innerH=h-2*inset;local leftW=w*2/3-2*inset;local rightW=w/3-2*inset
 local scale=math.min(leftW*dx/160,rightW*dx/80,innerH*dy/48);if scale>=1 then scale=math.floor(scale)end
 check(#frameCalls==1 and frameCalls[1].mode=='moves' and frameCalls[1].rect==rect,'frames retain the complete legacy rectangle')
 check(#glyphs>4,'moves, selector, PP and type all draw')
 check(glyphs[#glyphs].s=='ELECTRIC','complete ELECTRIC type string rendered')
 for _,glyph in ipairs(glyphs)do
  check(near(glyph.sx*dx,scale) and near(glyph.sy*dy,scale),'Emerald glyphs preserve square integer physical pixels')
  local pane=api.emeraldLayout(rect,{dpiX=dx,dpiY=dy})[glyph.pane].interior
  check(glyph.x>=pane.x and glyph.x+glyph.width<=pane.x+pane.w,'move name / PP / type ink stays inside its frame horizontally')
  check(glyph.y>=pane.y and glyph.y+glyph.height<=pane.y+pane.h,'move ink stays off top/bottom border')
 end
 local first=glyphs[1]
 local expectedX=math.floor((rect.x+inset+(leftW-160*scale/dx)/2)*dx+.5)/dx+16*scale/dx
 local expectedY=math.floor((rect.y+inset+(innerH-48*scale/dy)/2)*dy+.5)/dy+9*scale/dy
 check(near(first.x,expectedX) and near(first.y,expectedY),'native pane templates center independently inside legacy frames')
 check(depth==0,'graphics state restored')
end
battle.data.moves.scratch.type='FIGHTING'
glyphs={};check(api.draw(battle,{x=136,y=496,w=774,h=232},{}),'FIGHTING move panel draws')
check(glyphs[#glyphs].s=='FIGHTING','complete FIGHTING type string rendered')
-- The labels must follow native GB actions at every cursor position.
local layout=assert(loadfile('lib/emerald_battle_layout.lua'))()(G)
for generation=1,3 do
 for index=1,4 do
  glyphs={}
  local b={menuIndex=index,player={name='RED'},activeMon=function()return{name='RED'}end}
  layout.commands(F,b,generation,{x=0,y=0,w=960,h=192},custom,{}, {})
  local names={};for _,g in ipairs(glyphs)do if type(g.s)=='string'then names[#names+1]=g.s end end
  check(names[1]=='FIGHT'and names[2]==(generation<3 and 'POKéMON'or'BAG')and names[3]==(generation<3 and 'BAG'or'POKéMON')and names[4]=='RUN','command labels match native generation action order')
 end
end
-- Custom selectors retain their complete eight-pixel artwork.
F.drawGlyph=function(id,x,y,opts)
 glyphs[#glyphs+1]={s=id,x=t.x+x*t.sx,y=t.y+y*t.sy,sx=t.sx,sy=t.sy,width=8*t.sx,height=16*t.sy}
end
for _,factor in ipairs({1,1.5,2})do
 custom.fontSizing={factor=function()return factor end,unscaled=function(fn)return fn()end}
 for _,rect in ipairs({{x=160,y=880,w=1408,h=416},{x=0,y=432,w=960,h=168}})do
  for index=1,4 do
   for _,mode in ipairs({'commands','moves'})do
    glyphs,frameCalls={},{}
    battle.menuIndex=index;battle.moveIndex=index
    if mode=='commands'then layout.commands(F,battle,1,rect,custom,{}, {})
    else layout.moves(F,battle,rect,custom,function()return{}end,function(s)return s end,{})end
    check(frameCalls[1].rect==rect,'large font must retain original frame rectangle')
    for i,g in ipairs(glyphs)do
     check(g.x>=rect.x and g.x+g.width<=rect.x+rect.w,'text/selector stays in frame horizontally')
     check(g.y>=rect.y and g.y+g.height<=rect.y+rect.h,'text/selector stays in frame vertically')
     check(g.sx==math.floor(g.sx)and g.sy==math.floor(g.sy),'final glyph scale uses integer pixels')
     if g.s==F.CHAR_SELECTOR_ARROW then
      local name=glyphs[i-1]
      check(g.x+g.width<name.x,'full custom selector clears the selected label')
     end
    end
   end
  end
 end
end
F.draw=function()error('Emerald font failure')end
check(not pcall(api.draw,battle,{x=0,y=0,w=774,h=232},{}),'Emerald font errors propagate')
check(depth==0,'font error restores all pane transforms')
print('PASS: '..checks..' Emerald move font / independent border layout checks')
