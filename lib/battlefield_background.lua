-- A scenery-only provider: KIM invokes this before sprites and move effects.
return function(mod)
 local M={};mod.exports.battlefieldBackground=M
 function M.choice()return math.max(0,math.floor(tonumber(mod.options:get('battlefieldBackgroundColor'))or 0))end
 -- Optional scenery providers never render battle UI or own composition.
 function M.scenery()
  local ok,other=pcall(mod.find,mod,'hd-dynamic-battlefields')
  local provider=ok and other and other.exports and other.exports.battlefieldScenery
  if provider and provider.apiVersion==1 and provider.enabled()then return provider end
 end
 function M.available()return M.choice()~=0 or M.scenery()~=nil end
 function M.draw(x,y,w,h)
  local provider=M.scenery()
  if provider then
   local ok,painted=pcall(provider.draw,x,y,w,h)
   if ok and painted then return true end
  end
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
  local P=mod.exports.selectorPalette
  local function write(ctx,n)mod.exports.customization.write(ctx,{battlefieldBackgroundColor=n});return false end
  local row={id='wide_battlefieldBackgroundColor',label='BATTLEFIELD BACKGROUND',value=function()return M.choice()==0 and'NATIVE'or P.backgroundNames[M.choice()]end,
   step=function(ctx,d)return write(ctx,(M.choice()+(d or 1))%(#P.backgroundNames+1))end}
  P.picker(row,'menuBackground',M.choice,write,openPage,'NATIVE');return{row}
 end
 function M.install()
  if mod.generation==1 then
   local G=love.graphics;local layers=setmetatable({},{__mode='k'});local replay=false
   local draw,clear=G.draw,G.clear
   G.clear=function(...)local source=G.getCanvas();if source then layers[source]=nil end;return clear(...)end
   G.draw=function(source,...)
    if layers[source]and not replay then
     local target=G.getCanvas();local w,h
     if target then w,h=target:getDimensions();layers[target]=true else w,h=G.getDimensions()end
     replay=true;G.push('all');G.origin();G.setScissor();M.draw(0,0,w,h);G.pop();replay=false
    end
    return draw(source,...)
   end
   local B=require('src.battle.BattleState');local classic=B.drawClassic
   local zone=B.drawZonePass
   B.drawZonePass=function(self,...)
    if not self._menuCustomizerNativeField then return zone(self,...)end
    -- Shaking zone passes normally fill their exposed edges with white paper.
    local G=love.graphics;local rectangle=G.rectangle
    G.rectangle=function(mode,...)if mode~='fill'then return rectangle(mode,...)end end
    local out={pcall(zone,self,...)};G.rectangle=rectangle
    if not out[1]then error(out[2],0)end;return(unpack or table.unpack)(out,2)
   end
   B.drawClassic=function(self,...)
    if self.blankForAskName or not M.available()then return classic(self,...)end
    -- Paint scenery on the destination, keeping the native HUD scratch layer
    -- transparent instead of erasing the scenery with its white paper.
    local G=love.graphics;local source=G.getCanvas()
    if not source then
     G.push('all');G.origin();G.setScissor();local w,h=G.getDimensions();local painted=M.draw(0,0,w,h);G.pop()
     if not painted then return classic(self,...)end
    else
     local surfaces=mod.exports.menuSurfaces
     if not surfaces.enabled()then return classic(self,...)end
     -- Leave scenery transparent in the logical game canvas. Its final copy
     -- paints one full destination backdrop, including the letterbox margins.
     G.push('all');G.setShader();G.setBlendMode('replace','premultiplied');G.setColor(0,0,0,0);G.rectangle('fill',0,0,160,144);G.pop()
     layers[source]=true
    end
    local G=love.graphics;local rectangle=G.rectangle;local replaced=false
    G.rectangle=function(mode,x,y,w,h,...)
     local r,g,b,a=G.getColor()
     if not replaced and mode=='fill'and x==0 and y==0 and w==160 and h==144 and r==1 and g==1 and b==1 and a==1 then
      replaced=true
      if G.getCanvas()==self.bgCanvas then G.clear(0,0,0,0)end
      return
     end
     return rectangle(mode,x,y,w,h,...)
    end
    local prior=self._menuCustomizerNativeField;self._menuCustomizerNativeField=true
    local out={pcall(classic,self,...)};self._menuCustomizerNativeField=prior;G.rectangle=rectangle
    require('src.render.PaletteFX').markTrueColor(0,0,160,144)
    if not out[1]then error(out[2],0)end;return(unpack or table.unpack)(out,2)
   end
   return
  end
  if mod.generation~=3 then return end
  local Bg=require('src.core.game3.battle.bg');local draw=Bg.draw
  Bg.draw=function(...)
   local ok,kim=pcall(mod.find,'kim1025')
   local hd=ok and kim and kim.options and kim.options:get('hdBattleBackgrounds')~=false and kim.exports and kim.exports.frlgHdBackgrounds
   -- HD Dynamic Battlefields owns FR/LG's terrain and final-frame pass.
   -- Calling its provider here paints window artwork into the 240px UI
   -- canvas and bypasses its native/HD-sprite terrain handoff.
   if M.scenery() then return draw(...) end
   if not hd and M.draw(0,0,240,112)then return end
   return draw(...)
  end
 end
 return M
end
