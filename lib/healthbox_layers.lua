-- Clean baked placeholder ink before applying panel opacity. Text and gauges
-- remain on the foreground layer, including native gender and level glyphs.
return function(G,mod,faded)
 local unpack=unpack or table.unpack
 return function(font,chrome,draw,...)
  local args={...};local saved={};local pass='background';local ink=0
  local rectangle,image=G.rectangle,G.draw
  local custom=mod.generation==3 and require('src.core.GameVersion').get()=='emerald' and mod.exports.battleUi.setting('style',1)==3
  local prior=mod.exports.healthboxBackground
  local function wrap(target,key,foreground)
   if type(target[key])~='function' then return end
   local original=target[key];saved[#saved+1]={target,key,original}
   target[key]=function(...)
    if foreground and pass=='background' then return end
    if not foreground and pass=='foreground' then return end
    ink=ink+1;local result={pcall(original,...)};ink=ink-1
    if not result[1]then error(result[2],0)end
    return unpack(result,2)
   end
  end
  wrap(font,'draw',true);wrap(font,'drawGlyph',true)
  local text,glyph=font.draw,font.drawGlyph
  local hpMaximum=false
  font.draw=function(value,x,y,opts,...)
   if custom then
    local copy={};for k,v in pairs(opts or{})do copy[k]=v end
    if tonumber(mod.options:get('menuTheme'))==2 and tostring(copy.font):match('^native_')then copy.font='narrow' end
    if not(copy.colors and copy.colors._effects)then copy.colors=mod.exports.battleUi.palette.colors('battle')end
    opts=copy
   end
   if opts and opts.small then
    local hpCurrent=type(value)=='string' and value:match('^%s*%d+/$')
    if hpCurrent or hpMaximum then y=y-1 end
    hpMaximum=hpCurrent and true or false
   end
   return text(value,x,y,opts,...)
  end
  font.drawGlyph=function(id,x,y,opts,...)
   if id==0x105 and opts and opts.small then
    y=y-1
    x=x-font.measure(' ',opts)
   end
   return glyph(id,x,y,opts,...)
  end
  local summary=chrome._menuCustomizerSummary
  if summary then wrap(summary,'drawStatusIcon',true)end
  for _,key in ipairs({'drawHpBar','drawRsStatusIcon','drawPartyBall'})do wrap(chrome,key,true)end
  -- EXP tiles include an opaque pale track below the HP numbers. Fade the
  -- entire strip with the panel so its empty portion cannot leave a white line.
  wrap(chrome,'drawExpBar',custom)
  for _,key in ipairs({'drawPlayerBox','drawEnemyBox','drawDoublesBox','drawSafariBox'})do wrap(chrome,key,false)end
  G.rectangle=function(...)if pass=='background' and not custom or ink>0 then return rectangle(...)end end
  G.draw=function(...)if pass=='background' or ink>0 then return image(...)end end
  local result={pcall(function()
   mod.exports.healthboxBackground=true
   faded(draw,unpack(args))
   mod.exports.healthboxBackground=prior
   pass='foreground';return draw(unpack(args))
  end)}
  G.rectangle,G.draw=rectangle,image;mod.exports.healthboxBackground=prior
  for i=#saved,1,-1 do local s=saved[i];s[1][s[2]]=s[3]end
  if not result[1]then error(result[2],0)end
  return unpack(result,2)
 end
end
