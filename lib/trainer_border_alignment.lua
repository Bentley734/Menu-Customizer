-- Match the trainer's feet to the Gen4 frame's visible top, not its clear rows.
return function(mod)
 if mod.generation~=1 then return end
 local B=require('src.battle.BattleState');local G=love.graphics;local active=false
 local placement,draw=B.backPlacement,B.drawPicsLayer
 B.backPlacement=function(...)local x,y=placement(...);return x,y+(active and 2 or 0)end
 B.drawPicsLayer=function(self,...)
  local ui=mod.exports.battleUi;local borders=mod.exports.borders;local prior=active
  active=mod.exports.menuSurfaces.enabled()and self.showPlayerBack and self.playerBackPic and ui and ui.setting('style',1)==3 and select(3,borders.insets('battle',160,48))or false
  local x,y,w,h=G.getScissor()
  if active and x and y+h==96 then G.setScissor(x,y,w,h+2)end
  local out={pcall(draw,self,...)};G.setScissor(x,y,w,h);active=prior
  if not out[1]then error(out[2],0)end;return(unpack or table.unpack)(out,2)
 end
end
