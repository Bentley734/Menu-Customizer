return function(mod)
 local M={}
 function M.offset(index,count,time)
  local phase=(time/.22)%(count+3);if math.floor(phase)+1~=index then return 0 end
  return math.floor(math.sin((phase%1)*math.pi)*3+.5)
 end
 function M.draw(printer,measure,text,x,y,...)
  if type(text)~='string'or text:find('[<>{}]')then return printer(text,x,y,...)end
  if mod.exports.customization then text=mod.exports.customization.text(text)end
  local chars={};for c in text:gmatch('[%z\1-\127\194-\244][\128-\191]*')do chars[#chars+1]=c end
  local pen=0;local time=love.timer.getTime()
  local previous=M.active;M.active=true;local args={...}
  local ok,err=pcall(function()for i,c in ipairs(chars)do printer(c,x+pen,y-M.offset(i,#chars,time),(unpack or table.unpack)(args));pen=pen+measure(c)end end)
  M.active=previous;if not ok then error(err,0)end
  return pen
 end
 return M
end
