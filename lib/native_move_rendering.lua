-- Identify frames whose graphics belong entirely to the native battle renderer.
return function(state)
  if not state then
    local ok,game=pcall(require,'src.core.Game')
    local stack=ok and game and game.stack
    local states=stack and stack.states
    if type(states)=='table' then
      for i=#states,1,-1 do
        local s=states[i]
        if type(s)=='table' and s.player and s.enemy then state=s;break end
      end
    end
    if not state and stack and type(stack.top)=='function' then state=stack:top()end
  end
  if type(state)~='table' then return false end
  if state.animPlaying==true or state.anim~=nil or state.lockedBall~=nil then return true end
  local fx=state.fx
  if type(fx)=='table' then
    for _,key in ipairs({'shake','shakeX','shakeY','flash'})do
      local value=tonumber(fx[key]);if value and value~=0 then return true end
    end
    if fx.wavy or fx.bgp or fx.bgpSeq then return true end
  end
  for _,pf in pairs(state.picFx or {})do
    if type(pf)=='table' and (pf.kind or pf.hidden or pf.minimized or pf.fade
      or (tonumber(pf.ox)or 0)~=0 or (tonumber(pf.oy)or 0)~=0)then return true end
  end
  return false
end
