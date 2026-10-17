local function chars(text)local n=0;for _ in text:gmatch('[%z\1-\127\194-\244][\128-\191]*')do n=n+1 end;return n end
for _,pixels in ipairs({false,true})do
 local calls={};local page='Hello ASH!\nBULBASAUR?';local limit
 local F={countChars=chars,measure=function(s)return chars(s)*6 end,linePitch=function()return 16 end}
 F.draw=function(s,x,y,opts)
  calls[#calls+1]={text=s,limit=opts.limitChars,y=y}
  local n=math.min(chars(s),opts.limitChars or chars(s));return pixels and n*6 or n,x+n*6,y
 end
 local Message={open=true,_frame='field',drawText=function()return F.draw(page,8,113,{limitChars=limit})end}
 local G={push=function()end,pop=function()end,getCanvas=function()return 'canvas'end,draw=function()end}
 local mod={exports={},options={get=function()end},save={get=function()end},read=function()
  return 'return function()return {capture=function(fn)fn();return {}end,draw=function()end}end'
 end}
 local env=setmetatable({love={graphics=G},require=function(name)
  assert(name=='src.ui.game3.chrome');return{dialogueWindow=function()return 1,14,28,4 end}
 end},{__index=_G})
 local f=assert(io.open('lib/dialogue_text.lua'));local source=f:read('*a');f:close()
 assert(load(source,'dialogue reveal','t',env))()(mod,Message,F,function()return true end)
 for _,n in ipairs({0,3,10,11,12,21})do
  calls={};limit=n;Message.drawText()
  assert(#calls==(n==0 and 0 or n<=11 and 1 or 2),'Incorrect visible row count at '..n)
  if #calls==2 then assert(calls[2].limit==n-11 and calls[2].y>calls[1].y,'Second line reveal/spacing wrong')end
 end
 calls={};limit=nil;Message.drawText();assert(#calls==2,'Unlimited second line lost')
end
print('PASS dialogue finite/partial/unlimited reveal with pixel-width and native-count printers')
