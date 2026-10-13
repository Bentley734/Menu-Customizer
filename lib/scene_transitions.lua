-- Replace visual passes only. Native updates own locks, warps and callbacks.
return function(mod,active)
 local G=love.graphics;local unpack=unpack or table.unpack
 local E=assert(load(assert(mod:read('lib/scene_effects.lua'))))()
 local M={pending=nil,intent=nil,fadeKey=nil,live=active,effects=E}
 local function get(key)
  local n=tonumber(mod.options:get('scene_'..key)or mod.save:get('scene_'..key))or 1
  return math.max(1,math.min(#E.names,math.floor(n)))
 end
 M.get=get
 function M.queue(key,p,owner)
  if not active()then return false end
  local style=get(key);if style==1 then return false end
  if style==26 then
   owner=owner or M
   owner._sceneRandom=owner._sceneRandom or math.random(4,25);style=owner._sceneRandom
  end
  M.pending={style=style,p=math.max(0,math.min(1,p))};return true
 end
 local function loadModule(name)local ok,v=pcall(require,name);return ok and v or nil end
 local R=require('src.render.Renderer');R._menuCustomizerScenes=M
 local P=require('src.render.Pipelines');P._menuCustomizerScenes=M
 if not P._menuCustomizerScenePresent then
  local wants,present=P.wantsPresent,P.present
  -- Force a full-window composite; transition masks precede ShaderFX
  -- and render.output, even when no other pipeline or shader is enabled.
  P.wantsPresent=function(...)
   local ctx=P._menuCustomizerScenes
   return (ctx and ctx.pending~=nil)or wants(...)
  end
  P.present=function(canvas,...)
   local composed=present(canvas,...)or canvas
   local ctx=P._menuCustomizerScenes;local pending=ctx and ctx.pending
   if pending and composed then
    ctx.pending=nil
    G.push('all');G.setCanvas(composed)
    local w,h=composed:getDimensions()
    local ok,err=pcall(ctx.effects.draw,pending.style,pending.p,w,h)
    G.pop()
    if not ok then error(err,0)end
   end
   return composed
  end
  P._menuCustomizerScenePresent=true
 end
 if not R._menuCustomizerSceneEnd then
  local finish=R.endFrame
  if finish then
   R.endFrame=function(self,...)
    local ctx=R._menuCustomizerScenes
    if ctx and ctx.job and ctx.live()then
     local elapsed=love.timer.getTime()-ctx.job.born
     if elapsed<.5 then ctx.queue('battle_out',1-elapsed/.5,ctx.job)else ctx.job=nil end
    end
    local pending=ctx and ctx.pending
    if pending then self.worldFadeAlpha=nil;self.screenVeil=nil;self.battleWipe=nil end
    local result={finish(self,...)}
    -- Custom composition hooks can bypass the normal present pass.
    -- Discard their unused mask so it cannot leak into a later frame.
    if ctx then ctx.pending=nil end
    return unpack(result)
   end
   R._menuCustomizerSceneEnd=true
  end
 end
 local T=loadModule('src.render.Transition')
 if T then
  T._menuCustomizerScenes=M
  if not T._menuCustomizerSceneNew then
   local new=T.new
   T.new=function(game,mid,done,warp,opts)
    local s=new(game,mid,done,warp,opts)
    if not warp then return s end
    local native=s.draw
    -- The overworld consumes palette bytes before s.draw runs, so bypass
    -- that visual path too; skipping the overlay alone is insufficient.
    for _,name in ipairs({'bgp','obp0'})do
     local original=s[name]
     if original then s[name]=function(self,...)
      local ctx=T._menuCustomizerScenes
      local key=self.phase=='in'and'building_in'or'building_out'
      if ctx.live()and ctx.get(key)~=1 then return 0xE4 end
      return original(self,...)
     end end
    end
    s.draw=function(self,...)
     local ctx=T._menuCustomizerScenes;local key=self.phase=='in'and'building_in'or'building_out'
     local len=self.phase=='in'and self.framesIn or self.frames
     local p=math.min(1,(self.t or 0)/math.max(1,len or 1));if self.phase=='in'then p=1-p end
     if ctx.queue(key,p,self)then return end;return native(self,...)
    end
    -- Vanilla Gen 1 skips its reveal; opt-in styles request that native phase.
    if T._menuCustomizerScenes.live() and T._menuCustomizerScenes.get('building_in')~=1 and (s.framesIn or 0)==0 then s.framesIn=s.frames end
    return s
   end
   if T.battleReturn then
    local ret=T.battleReturn
    T.battleReturn=function(...)
     local s=ret(...);local draw=s.draw
     s.draw=function(self,...)
      local p=1-math.max(0,(self.t-self.hold)/math.max(1,self.frames))
      if T._menuCustomizerScenes.queue('battle_out',p,self)then return end
      return draw(self,...)
     end
     return s
    end
   end
   T._menuCustomizerSceneNew=true
  end
 end
 local function classBattle(name,gen2)
  local B=loadModule(name);if not B or not B.draw then return end
  B._menuCustomizerScenes=M
  if B._menuCustomizerSceneDraw then return end
  local draw=B.draw
  B.draw=function(self,...)
   local ctx=B._menuCustomizerScenes
   local p
   if gen2 then
    if self.phase=='flash'then p=.25*math.min(1,self.frame/math.max(1,self:flashFrames()))
    elseif self.phase=='black'then p=1 else p=.25+.75*math.min(1,(self.frame or 0)/40)end
   else
    p=self.phase=='flash'and .25*math.min(1,self.t/60)or .25+.75*math.min(1,self.t/math.max(1,self.wipeLen or 48))
   end
   if not ctx.queue('battle_in',p,self)then return draw(self,...)end
   if gen2 and self.drawWorld then return self:drawWorld()end
   local world=self.game and(self.game.world or self.game.overworld)
   if world and world.draw then world:draw()end
  end
  if gen2 and B.drawWidescreen then
   local wide=B.drawWidescreen
   B.drawWidescreen=function(self,...)
    local ctx=B._menuCustomizerScenes
    local p=self.phase=='black'and 1 or self.phase=='flash'and .25*math.min(1,self.frame/math.max(1,self:flashFrames()))or .25+.75*math.min(1,(self.frame or 0)/40)
    if not ctx.queue('battle_in',p,self)then return wide(self,...)end
    if self.drawWorld then return self:drawWorld()end
   end
  end
  if gen2 then
   -- bgOverlay is installed by the constructor and invoked while drawing
   -- the world, independently of draw/drawWidescreen.
   for _,name in ipairs({'drawBgLayer','drawTopLayer','paintLayer','drawTint'})do
    local original=B[name]
    if original then B[name]=function(self,...)
     local ctx=B._menuCustomizerScenes
     if ctx.live()and ctx.get('battle_in')~=1 then return end
     return original(self,...)
    end end
   end
  end
  B._menuCustomizerSceneDraw=true
 end
 classBattle('src.render.BattleTransition',false)
 classBattle('src.ui.gen2.BattleTransition',true)
 if mod.generation==3 then
  local F=loadModule('src.ui.game3.fade');local B=loadModule('src.core.game3.battle_transition')
  local Battle=loadModule('src.core.game3.battle');local W=loadModule('src.core.game3.warp')
  if W then
   W._menuCustomizerScenes=M
   if not W._menuCustomizerSceneWrapped then
    if W.fadeModes then local old=W.fadeModes;W.fadeModes=function(...)W._menuCustomizerScenes.intent='building_out';return old(...)end end
    if W.mapTransition then local old=W.mapTransition;W.mapTransition=function(...)W._menuCustomizerScenes.intent='building_in';return old(...)end end
    W._menuCustomizerSceneWrapped=true
   end
  end
  if F then
   F._menuCustomizerScenes=M
   if not F._menuCustomizerSceneWrapped then
    local begin,draw,finish,clear=F.begin,F.draw,F._finish,F.clear
    F.begin=function(mode,...)
     F._sceneRandom=nil
     local ctx=F._menuCustomizerScenes
     ctx.fadeKey=ctx.intent or(Battle and Battle.isActive and Battle.isActive()and'battle_out'or nil)
     if ctx.fadeKey=='building_in'or ctx.fadeKey=='building_out'then
      ctx.fadeKey=(mode==0 or mode==2)and'building_in'or'building_out'
     end
     return begin(mode,...)
    end
    F.draw=function(...)
     local ctx=F._menuCustomizerScenes
     if ctx.fadeKey and ctx.queue(ctx.fadeKey,(F.t or 0)/16,F)then R.screenVeil=nil;return end
     return draw(...)
    end
    F._finish=function(...)
     local result={finish(...)}
     if not F.active and(F.t or 0)==0 then F._menuCustomizerScenes.intent=nil;F._menuCustomizerScenes.fadeKey=nil end
     return unpack(result)
    end
    F.clear=function(...)F._menuCustomizerScenes.intent=nil;F._menuCustomizerScenes.fadeKey=nil;return clear(...)end
    F._menuCustomizerSceneWrapped=true
   end
  end
  if B then
   B._menuCustomizerScenes=M
   if not B._menuCustomizerSceneWrapped then
    local draw,world=B.draw,B.drawWorld
    if B.begin then local begin=B.begin;B.begin=function(...)B._sceneRandom=nil;return begin(...)end end
    local function custom()
     if not B._active then return false end
     local ctx=B._menuCustomizerScenes;ctx.intent='battle_in'
     local p=B._phase=='ending'and 1 or math.min(.98,(B._frame or 0)/48)
     return ctx.queue('battle_in',p,B)
    end
    B.draw=function(...)if custom()then return end;return draw(...)end
    B.drawWorld=function(canvas,w,h,...)
     -- The supplied world canvas already contains the clean scene. Native
     -- drawWorld modifies it in place; do not draw it back onto itself.
     if custom()then B._worldDrawn=false;return true end
     return world(canvas,w,h,...)
    end
    B._menuCustomizerSceneWrapped=true
   end
  end
 end
 if mod.generation==2 then
  mod.events:on('battle.ended',function()if active()and get('battle_out')~=1 then M.job={born=love.timer.getTime()}end end)
 end
 mod.exports.sceneTransitions=M
 return M
end
