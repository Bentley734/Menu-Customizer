return function(mod)
 local M={}
 function M.select(owner,index,text)
  if M.owner~=owner or M.index~=index or M.text~=text then
   M.owner,M.index,M.text=owner,index,text;M.started=love.timer.getTime()
  end
 end
 function M.enabled()
  local n=mod.options:get('jumpWaveEnabled');if n~=nil then return n==1 end
  return mod.options:get('startSelector')==14 or mod.options:get('arrowSelector')==14
 end
 function M.rows()
  return{{id='wide_jumpWaveSelector',label='JUMP WAVE',value=function()return M.enabled()and'ON'or'OFF'end,
   step=function(ctx)mod.exports.customization.write(ctx,{jumpWaveEnabled=M.enabled()and 0 or 1});return false end},
   {id='wide_jumpWaveSelectorSpeed',label='JUMP WAVE SPEED',value=function()return tostring(mod.options:get('jumpWaveSpeed')or 100)..'%'end,
   step=function(ctx,d)local n=tonumber(mod.options:get('jumpWaveSpeed'))or 100;n=25+(n-25+(d or 1)*25)%300;mod.exports.customization.write(ctx,{jumpWaveSpeed=n});return false end}}
 end
 function M.offset(index,count,time)
  local speed=tonumber(mod.options:get('jumpWaveSpeed'))or 100
  local phase=(time*speed/100/.22)%(count+3);if math.floor(phase)+1~=index then return 0 end
  return math.floor(math.sin((phase%1)*math.pi)*3+.5)
 end
 function M.draw(printer,measure,text,x,y,...)
  if type(text)~='string'or text:find('[<>{}]')then return printer(text,x,y,...)end
  if mod.exports.customization then text=mod.exports.customization.text(text)end
  local chars={};for c in text:gmatch('[%z\1-\127\194-\244][\128-\191]*')do chars[#chars+1]=c end
  local pen=0;if not M.started then M.select(nil,1,text)end;local time=math.max(0,love.timer.getTime()-M.started)
  local previous=M.active;M.active=true;local args={...}
  local ok,err=pcall(function()for i,c in ipairs(chars)do printer(c,x+pen,y-M.offset(i,#chars,time),(unpack or table.unpack)(args));pen=pen+measure(c)end end)
  M.active=previous;if not ok then error(err,0)end
  return pen
 end
 return M
end
