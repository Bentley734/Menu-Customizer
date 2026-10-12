local settings={};local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
local mod={exports={},options={get=function(_,k)return settings[k]end},save={get=function()end},read=function(_,p)local f=assert(io.open(p));local s=f:read('*a');f:close();return s end}
local P=assert(loadfile('lib/battle_text_palette.lua'))()(mod);local E=P.effects
check(P.names[1]=='BLACK' and P.names[3]=='BLUE' and P.backgroundNames[2]=='BLACK','saved palette IDs retained')
for _,kind in ipairs({'text','shadow','background','menuBackground'})do
 local names=kind=='text' and P.names or kind=='shadow' and P.shadowNames or kind=='background' and P.backgroundNames or P.menuBackgroundNames
 local n=0;local seen={}
 for i=1,#names do check(not seen[n],'chooser repeats before complete cycle');seen[n]=true;n=P.step(kind,n,1)end
 check(n==0,'chooser wraps');check(P.step(kind,P.step(kind,0,1),-1)==0,'chooser reversible')
end
local sampled=assert(loadfile('lib/color_swatches.lua'))()
check(#sampled==170,'exact border catalogue present')
check(sampled[2].rgb[2]==130/255 and sampled[4].rgb[3]==167/255,'town colour RGB values retain their saved IDs')
for _,s in ipairs(sampled)do check(not s.name:find('#') and not s.name:find('BORDER'),'swatches use colour names')end
settings.battle_fx_alternate=1;settings.battle_fx_count=5
local expected={0,2,3,4,5,0}
P.withText('battle',function()
 for _,n in ipairs(expected)do check(E.ink(P.colors(),false)==P.color('text',n),'five letters cycle in order')end
end)
settings.battle_fx_alternate=2
P.withText('battle',function()
 check(E.ink(P.colors(),false)==P.color('text',0),'first word');check(E.ink(P.colors(),false)==P.color('text',0),'same word same color')
 E.ink(P.colors(),true);check(E.ink(P.colors(),false)==P.color('text',2),'next word next color')
end)
check(not pcall(P.withText,'battle',function()error('probe')end),'error propagated')
P.withText('battle',function()check(E.ink(P.colors(),false)==P.color('text',0),'sequence restored after error')end)
local persisted={};local rows=E.rows('name',function(_,key,n)settings[key]=n;persisted[key]=n;return false end)
check(#rows==10,'all effect controls present');rows[1].step({},1);rows[2].step({},1);rows[8].step({},1);rows[9].step({},1)
check(persisted.battle_name_fx_alternate==1 and persisted.battle_name_fx_count==3,'alternate settings persist independently')
check(persisted.battle_name_fx_glow~=nil and persisted.battle_name_fx_double~=nil,'independent layer colors persist')
settings.battle_fx_alternate=0;settings.battle_fx_double=1;settings.battle_fx_glow=5;settings.battle_shadow_color=7
local stack,commands={},{};local color={1,1,1,1};love={timer={getTime=function()return 0 end},graphics={
 push=function()stack[#stack+1]=color end,pop=function()color=table.remove(stack)end,setColor=function(...)color={...}end,
 transformPoint=function(x,y)return x*4,y*2 end,translate=function()end,scale=function(x,y)commands[#commands+1]={scale={x,y}}end}}
E.glyph(P.colors(),10,10,function(x,y)commands[#commands+1]={x=x,y=y,color=color}end)
check(commands[1].scale[1]==.5 and commands[1].scale[2]==1,'glyph pixels compensate nonuniform aspect')
check(commands[2].x==-3 and commands[2].y==3,'double shadow drawn first')
check(commands[3].x==-1 and commands[3].y==1,'shadow drawn next down-left')
check(commands[4].x==1 and commands[4].y==-1,'glow drawn above shadow up-right')
check(commands[5].x==0 and commands[5].y==0,'foreground last');check(#stack==0,'state restored')
check(not pcall(E.glyph,P.colors(),10,10,function()error('probe')end) and #stack==0,'effect state restored after draw failure')
print('PASS '..checks..' text effect sequence, palette, layer order, aspect and persistence checks')
