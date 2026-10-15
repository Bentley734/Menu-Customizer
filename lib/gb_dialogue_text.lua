-- Retain every Emerald atlas pixel in Gen 1 dialogue. Replay glyphs only
-- when the native UI reaches the screen or its final effects canvas.
return function(Font)
 if Font._menuCustomizerDialoguePixels then return Font._menuCustomizerDialoguePixels end
 local G=love.graphics;local M={queues={}};local unpack=unpack or table.unpack
 function M.beginFrame()M.queues={}end
 function M.enqueue(x,y,nominal,render)
  local source=G.getCanvas and G.getCanvas()
  if not source then return render()end
  local ax,ay=G.transformPoint(x,y);local bx,by=G.transformPoint(x+1,y);local cx,cy=G.transformPoint(x,y+1)
  local queue=M.queues[source]or{};M.queues[source]=queue
  queue[#queue+1]={owner=Font._menuCustomizerGB.dialogueOwner,page=Font._menuCustomizerGB.dialogueOwner and Font._menuCustomizerGB.dialogueOwner.pageIndex,waveOpacity=Font._menuCustomizerGB.mod.exports.jumpWave.opacity,learning=Font._menuCustomizerGB.mod.exports.moveLearningProfile and Font._menuCustomizerGB.mod.exports.moveLearningProfile.active,choice=true,x=ax,y=ay,hx=bx-ax,hy=by-ay,vx=cx-ax,vy=cy-ay,nominal=nominal,render=render,color={G.getColor()}}
 end
 local code=Font.drawCode
 Font.drawCode=function(id,x,y,...)
  local C=Font._menuCustomizerGB
  local source=G.getCanvas and G.getCanvas()
  local choice=C and C.mod.exports.choiceFontScope
  if not source or not C or C.mod.generation~=1 or not(C.dialogueScope or choice) or C.drawScope and not choice or C.inBox then return code(id,x,y,...)end
  local ax,ay=G.transformPoint(x,y);local bx,by=G.transformPoint(x+1,y);local cx,cy=G.transformPoint(x,y+1)
  local rx,ry=choice and C.drawScope and (C.resizeX or 1)or 1,choice and C.drawScope and (C.resizeY or 1)or 1
  local nominal=C.theme.enabled()and C.theme.gbAdvance(id)and C.theme.gbScale()or 1
  local queue=M.queues[source]or {};M.queues[source]=queue
  queue[#queue+1]={owner=Font._menuCustomizerGB.dialogueOwner,page=Font._menuCustomizerGB.dialogueOwner and Font._menuCustomizerGB.dialogueOwner.pageIndex,waveOpacity=Font._menuCustomizerGB.mod.exports.jumpWave.opacity,learning=C.mod.exports.moveLearningProfile and C.mod.exports.moveLearningProfile.active,choice=choice,id=id,x=ax,y=ay,hx=(bx-ax)/rx,hy=(by-ay)/rx,vx=(cx-ax)/ry,vy=(cy-ay)/ry,nominal=nominal,
   color={G.getColor()},args={n=select('#',...),...}}
 end
 local draw=G.draw;local replaying=false
 G.draw=function(source,...)
  local result={draw(source,...)};local queue=not replaying and M.queues[source]
  if queue then
   local target=G.getCanvas()
   local final=not target or target:getWidth()>=G.getWidth()and target:getHeight()>=G.getHeight()
   local x,y,rotation,sx,sy,ox,oy=...
   if final and type(x)=='number'and (rotation or 0)==0 then
    sx=sx or 1;sy=sy or sx;local dpi=target and target:getDPIScale()or G.getDPIScale()
    local C=Font._menuCustomizerGB;local prior,priorChoice=C.dialogueScope,C.mod.exports.choiceFontScope;replaying=true
    local profile=C.mod.exports.moveLearningProfile;local priorLearning=profile and profile.active
    if profile and queue[1]and queue[1].learning then profile.active=true end
    G.push('all');G.setBlendMode('alpha','alphamultiply')
    local ok,err=pcall(C.palette.withText,'menu',function()
     local letters={};local space=Font.encode(' ')[1]
     for _,item in ipairs(queue)do
      C.dialogueScope=not item.choice;C.mod.exports.choiceFontScope=item.choice
      local px,py=x+(item.x-(ox or 0))*sx,y+(item.y-(oy or 0))*sy
      local hx=math.sqrt((item.hx*sx)^2+(item.hy*sy)^2)
      local vy=math.sqrt((item.vx*sx)^2+(item.vy*sy)^2)
      local unit=math.max(1,math.floor(math.min(hx,vy)*item.nominal*dpi+.00001))
      G.origin();G.setShader();G.setColor(unpack(item.color))
      G.translate(math.floor(px*dpi+.5)/dpi,math.floor(py*dpi+.5)/dpi)
      G.scale(unit/(dpi*item.nominal),unit/(dpi*item.nominal))
      local function ink()if item.render then item.render()else code(item.id,0,0,unpack(item.args,1,item.args.n))end end
      local key=tostring(item.owner or source)..':'..tostring(item.page or 0)..':'..tostring(item.choice)
      letters[key]=(letters[key]or 0)+(item.id==space and 0 or 1)
      local function motion()return C.palette.effects.replayMotion('menu',key,math.max(1,letters[key]),ink)end
      if item.waveOpacity then C.mod.exports.jumpWave.withOpacity(item.waveOpacity,motion)else motion()end
     end
    end)
    G.pop();replaying=false;C.dialogueScope,C.mod.exports.choiceFontScope=prior,priorChoice
    if profile then profile.active=priorLearning end
    if not ok then error(err,0)end
   end
  end
  return unpack(result)
 end
 Font._menuCustomizerDialoguePixels=M;return M
end
