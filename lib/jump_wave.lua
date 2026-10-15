return function(mod)
 local M={}
 local selections=setmetatable({},{__mode="k"})
 function M.select(owner,index,text)
  -- Native and customized passes may draw the same row with different case.
  -- Keep its clock on the menu, rather than on the most recent draw call.
  local key=owner or M
  local state=selections[key]
  if not state or state.index~=index or state.alternating~=M.alternating()or index==nil and state.text~=text then
   state={index=index,text=text,alternating=M.alternating(),started=love.timer.getTime()};selections[key]=state
  end
  M.owner,M.index,M.text,M.started=owner,index,text,state.started
 end
 function M.classicEnabled()
  local n=mod.options:get('jumpWaveEnabled');if n~=nil then return n==1 end
  return mod.options:get('startSelector')==14 or mod.options:get('arrowSelector')==14
 end
 function M.alternating()return mod.options:get('stardewEnabled')==1 or mod.options:get('arrowSelector')==14 or mod.options:get('startSelector')==14 end
 function M.enabled()return M.alternating()or M.classicEnabled()end
 function M.timeline(time)
  if time<.3 then return math.max(0,time/.3),0 end
  if time<3.8 then return 1,0 end
  local t=math.max(0,math.min(1,(time-3.8)/.5));local ease=t*t*(3-2*t)
  return 1-ease,math.floor(20*ease+.5)
 end
 function M.withOpacity(alpha,fn,...)
  local G=love.graphics;local set=G.setColor;local prior=M.opacity;M.opacity=alpha
  G.push('all')
  G.setColor=function(r,g,b,a)
   if type(r)=='table'then return set(r[1],r[2],r[3],(r[4]or 1)*alpha)end
   return set(r,g,b,(a or 1)*alpha)
  end
  local r,g,b,a=G.getColor();set(r,g,b,a*alpha)
  local out={pcall(fn,...)};G.setColor=set;G.pop();M.opacity=prior
  if not out[1]then error(out[2],0)end;return(unpack or table.unpack)(out,2)
 end
 function M.rows()
  return{{id='wide_jumpWaveSelector',label='JUMP WAVE',value=function()return M.classicEnabled()and'ON'or'OFF'end,
   step=function(ctx)mod.exports.customization.write(ctx,{jumpWaveEnabled=M.classicEnabled()and 0 or 1});return false end},
   {id='wide_stardewSelector',label='STARDEW',value=function()return M.alternating()and'ON'or'OFF'end,
   step=function(ctx)mod.exports.customization.write(ctx,{stardewEnabled=M.alternating()and 0 or 1});return false end},
   {id='wide_jumpWaveSelectorSpeed',label='JUMP WAVE SPEED',value=function()return tostring(mod.options:get('jumpWaveSpeed')or 100)..'%'end,
   step=function(ctx,d)local n=tonumber(mod.options:get('jumpWaveSpeed'))or 100;n=25+(n-25+(d or 1)*25)%300;mod.exports.customization.write(ctx,{jumpWaveSpeed=n});return false end}}
 end
 function M.offset(index,count,time)
  local speed=tonumber(mod.options:get('jumpWaveSpeed'))or 100
  if M.alternating()then return math.floor(math.sin(time*speed/100*2*math.pi/.45+(index-1)*math.pi)*5+.5)end
  local phase=(time*speed/100/.22)%(count+3);if math.floor(phase)+1~=index then return 0 end
  return math.floor(math.sin((phase%1)*math.pi)*3+.5)
 end
 function M.draw(printer,measure,text,x,y,...)
  if type(text)~='string'or text:find('[<>{}]')then return printer(text,x,y,...)end
  if mod.exports.customization then text=mod.exports.customization.text(text)end
  local chars={};for c in text:gmatch('[%z\1-\127\194-\244][\128-\191]*')do chars[#chars+1]=c end
  local pen,lineY,maximum=0,0,0;if not M.started then M.select(nil,1,text)end;local time=math.max(0,love.timer.getTime()-M.started)
  local previous=M.active;M.active=true;local args={...}
  local function draw()
   local alpha,shift=1,0;if M.alternating()then alpha,shift=M.timeline(time)end
   local function letters()
    local ordinal=0
    for i,c in ipairs(chars)do
     local offset=0
     if not M.alternating()then offset=M.offset(i,#chars,time)
     elseif not c:match('^%s$')then ordinal=ordinal+1;offset=M.offset(ordinal,#chars,time)end
     if c=='\n' then maximum=math.max(maximum,pen);pen=0;lineY=lineY+16
     else printer(c,x+pen,y+lineY+shift-offset,(unpack or table.unpack)(args));pen=pen+measure(c)end
    end
   end
   if M.alternating()then return M.withOpacity(alpha,letters)end;return letters()
  end
  local ok,err=pcall(draw)
  M.active=previous;if not ok then error(err,0)end
  return math.max(maximum,pen)
 end
 return M
end
