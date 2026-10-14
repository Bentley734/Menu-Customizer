-- Clean baked placeholder ink before applying panel opacity. Text and gauges
-- remain on the foreground layer, including native gender and level glyphs.
return function(G,mod,faded)
 local unpack=unpack or table.unpack
 return function(font,chrome,draw,...)
  local args={...};local saved={};local pass='background';local ink=0
  local rectangle,image=G.rectangle,G.draw
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
  local summary=chrome._menuCustomizerSummary
  if summary then wrap(summary,'drawStatusIcon',true)end
  for _,key in ipairs({'drawHpBar','drawRsStatusIcon','drawPartyBall'})do wrap(chrome,key,true)end
  -- EXP tiles include an opaque pale track below the HP numbers. Fade the
  -- entire strip with the panel so its empty portion cannot leave a white line.
  wrap(chrome,'drawExpBar',false)
  for _,key in ipairs({'drawPlayerBox','drawEnemyBox','drawDoublesBox','drawSafariBox'})do wrap(chrome,key,false)end
  G.rectangle=function(...)if pass=='background' or ink>0 then return rectangle(...)end end
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
