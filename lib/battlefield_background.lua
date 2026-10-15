-- A scenery-only provider: KIM invokes this before sprites and move effects.
return function(mod)
 local M={};mod.exports.battlefieldBackground=M
 function M.choice()return math.max(0,math.floor(tonumber(mod.options:get('battlefieldBackgroundColor'))or 0))end
 function M.draw(x,y,w,h)
  if M.choice()==0 then return false end
  local R=require('src.mods.Runtime');local enabled=false
  for _,v in ipairs(R.hooks and R.hooks.chains and R.hooks.chains['ui.start_menu.items']or{})do if v.owner==mod.id then enabled=true end end
  if not enabled then return false end
  local G=love.graphics;local P=mod.exports.selectorPalette
  G.push('all');G.setShader();G.setColor(1,1,1,1)
  local ok,err=pcall(P.paint,P.color('background',M.choice()-1),G.rectangle,'fill',x,y,w,h)
  G.pop();if not ok then error(err,0)end;return true
 end
 function M.rows(openPage)
  if mod.generation==2 then return{}end
  if mod.generation==1 then local ok,kim=pcall(mod.find,'kim1025');if not ok or not kim then return{}end end
  local P=mod.exports.selectorPalette
  local function write(ctx,n)mod.exports.customization.write(ctx,{battlefieldBackgroundColor=n});return false end
  local row={id='wide_battlefieldBackgroundColor',label='BATTLEFIELD BACKGROUND',value=function()return M.choice()==0 and'NATIVE'or P.backgroundNames[M.choice()]end,
   step=function(ctx,d)return write(ctx,(M.choice()+(d or 1))%(#P.backgroundNames+1))end}
  P.picker(row,'menuBackground',M.choice,write,openPage,'NATIVE');return{row}
 end
 function M.install()
  if mod.generation~=3 then return end
  local Bg=require('src.core.game3.battle.bg');local draw=Bg.draw
  Bg.draw=function(...)
   local ok,kim=pcall(mod.find,'kim1025')
   local hd=ok and kim and kim.options and kim.options:get('hdBattleBackgrounds')~=false and kim.exports and kim.exports.frlgHdBackgrounds
   if not hd and M.draw(0,0,240,112)then return end
   return draw(...)
  end
 end
 return M
end
