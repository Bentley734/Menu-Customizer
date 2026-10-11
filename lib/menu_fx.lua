-- Screen-space effects and menu-only actor simulation. Field input/scripts
-- are never advanced by this module.
return function(E)
 local M={frame=0,active=false,states={},layouts={},previewUntil=0,lastInput=0}
 function M.setMod(mod) E.mod=mod;M.states={};M.layouts={} end
 local G=love.graphics
 local function now()return love.timer.getTime()end
 local function setting(k)return E.setting(k)end
 function M.scale(group)return setting(group..'Scale')/100 end
 function M.offset(group)return setting(group..'OffsetX'),setting(group..'OffsetY')end
 function M.touch(key)
  M.lastInput=now()
  local group=key:match('^(start)') or key:match('^(option)') or key:match('^(save)') or key:match('^(other)')
  if group then M.previewGroup=group;M.previewUntil=now()+3 end
 end
 function M.beginFrame(top)
  M.frame=M.frame+1
  local id=top and top.id
  if id~=M.topId then M.topId=id;M.lastInput=now() end
  M.active=top~=nil and not E.Battle.isActive() and
   (E.Stack.has('start') or id=='option' or id=='save' or id=='bag'
    or id=='party' or id=='summary' or id=='pokedex' or id=='trainer_card'
    or id=='dexnav' or id=='gen3_dexnav' or id=='codebreaker' or id=='pokenav')
 end
 function M.legendVisible()
  if not M.active then return true end
  local mode=setting('controlsLegend')
  return mode==1 or mode==2 and now()-M.lastInput<2
 end
 function M.motion(group,x,y,mode)
  local time=now();local style=setting('menuTransition')
  local state=M.states[group]
  if not state or state.frame<M.frame-1 then
   state={x=x,y=y,born=time,at=time};M.states[group]=state
   if style==3 then state.y=y+((mode==6 or mode==7 or mode==10) and 12 or -12) end
  end
  local dt=math.max(0,math.min(.1,time-state.at));state.at=time;state.frame=M.frame
  if style==1 then state.x,state.y=x,y
  else
   local fraction=1-math.exp(-dt*24)
   state.x=state.x+(x-state.x)*fraction;state.y=state.y+(y-state.y)*fraction
  end
  local alpha=style==1 and 1 or math.min(1,(time-state.born)/.15)
  return state.x,state.y,alpha
 end
 function M.record(group,x,y,w,h)M.layouts[group]={x=x,y=y,w=w,h=h}end
 function M.dim()
  if not M.active or M.dimFrame==M.frame then return end
  M.dimFrame=M.frame
  local alpha=setting('backgroundDim')/100
  if alpha<=0 then return end
  G.push('all');G.origin();G.setShader();G.setScissor();G.setColor(0,0,0,alpha)
  local w,h=G.getDimensions();G.rectangle('fill',0,0,w,h);G.pop()
 end
 -- Protect the menu-owned input and battle state while running the current
 -- WildFollowers native actor systems. Restore guards even if a tick fails.
 function M.ambient()
  local wf=E.mod.find and E.mod:find('wildfollowers')
  local engine=wf and wf.exports and wf.exports.engine
  if not engine or not engine.Field.running or engine.controlsLocked() then return end
  local O,F=engine.Owe,engine.Follower
  if O and O.busy and O.busy() then return end
  local guards={}
  local function guard(object,key)
   if object and object[key] then guards[#guards+1]={object,key,object[key]};object[key]=function()return false end end
  end
  guard(O,'trigger');guard(O,'interact');guard(engine,'startWildBattle')
  local ok,err=pcall(function()
   if F then F.readOptions();if engine.C.OW_FOLLOWERS_ENABLED then F.tick() end end
   if O and engine.C.WE_OW_ENCOUNTERS then O.tick() end
   if engine.tickGrass then engine.tickGrass() end
  end)
  for i=#guards,1,-1 do local g=guards[i];g[1][g[2]]=g[3] end
  if not ok then error(err,0) end
 end
 -- Lightweight preview outline at the target placement, with a readout in
 -- a small transparent label canvas. It never captures menu input.
 local labelCanvas
 function M.overlay()
  if setting('positionPreview')~=1 or now()>M.previewUntil then return end
  local group=M.previewGroup;local box=group and M.layouts[group]
  if not box then return end
  G.push('all');G.origin();G.setShader();G.setScissor();G.setColor(.35,.85,1,.85)
  G.rectangle('line',box.x,box.y,box.w,box.h)
  if E.Font then
   labelCanvas=labelCanvas or G.newCanvas(240,20,{dpiscale=1});labelCanvas:setFilter('nearest','nearest')
   G.setCanvas(labelCanvas);G.origin();G.clear(0,0,0,0);G.setColor(1,1,1,1)
   local x,y=M.offset(group)
   E.Font.draw(group:upper()..' '..setting(group..'Scale')..'%  X:'..x..' Y:'..y,2,2,{small=true})
   G.setCanvas();G.origin();G.setBlendMode('alpha','premultiplied');G.setColor(1,1,1,1)
   local w,h=G.getDimensions();G.draw(labelCanvas,math.max(0,math.min(w-240,box.x)),math.max(0,math.min(h-20,box.y-20)))
  end
  G.pop()
 end
 return M
end
