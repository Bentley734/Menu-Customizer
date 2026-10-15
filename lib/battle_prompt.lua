-- The command question has its own typography without changing command labels.
return function(mod)
 local M={};mod.exports.battlePrompt=M
 function M.get(suffix,default)return tonumber(mod.options:get('battlePrompt'..suffix))or default end
 function M.colors(base)
  local P=mod.exports.selectorPalette;local copy={};for k,v in pairs(base)do copy[k]=v end
  local fg,shadow=M.get('TextColor',-1),M.get('TextShadowColor',-1)
  if fg>=0 then copy.fg=P.color('text',fg)end
  if shadow>=0 then copy.shadow=P.color('shadow',shadow)end
  copy._kind='battlePrompt';return copy
 end
 function M.rows(openPage)
  local P,C=mod.exports.selectorPalette,mod.exports.customization;local rows={}
  local function add(suffix,label,default,min,max,names,kind)
   local key='battlePrompt'..suffix
   local function value()return M.get(suffix,default)end
   local function write(ctx,n)C.write(ctx,{[key]=n});return false end
   local row={id='wide_'..key,label='BATTLE PROMPT '..label,value=function()return names and names[value()-min+1]or tostring(value())end,
    step=function(ctx,d)return write(ctx,min+(value()-min+(d or 1))%(max-min+1))end}
   if kind then P.picker(row,kind,function()return math.max(0,value())end,write,openPage)end
   rows[#rows+1]=row
  end
  add('Size','TEXT SIZE',2,1,3,{'1X','2X','3X'})
  add('Font','FONT',1,1,2,{'REGULAR','NARROW'})
  add('Justify','ALIGNMENT',2,1,3,{'LEFT','CENTER','RIGHT'})
  add('TextColor','TEXT COLOR',-1,-1,#P.names-1,setmetatable({'USE BATTLE'},{__index=function(_,i)return P.names[i-1]end}),'text')
  add('TextShadowColor','TEXT SHADOW',-1,-1,#P.shadowNames-1,setmetatable({'USE BATTLE'},{__index=function(_,i)return P.shadowNames[i-1]end}),'shadow')
  for _,row in ipairs(P.effects.rows('battlePrompt',function(ctx,key,n)C.write(ctx,{[key]=n});return false end,openPage))do rows[#rows+1]=row end
  return rows
 end
 return M
end
