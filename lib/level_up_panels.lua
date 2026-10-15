-- Level-up presentation shares battle settings; native state/input stays intact.
return function(mod,ui,font,panel,compose,enabled)
 local G=love.graphics;local unpack=unpack or table.unpack
 local M={};ui.levelUpPanels=M
 local pending
 local function drawPanel(rows,rect,native)
  local sw,sh=mod.generation==3 and 240 or 160,mod.generation==3 and 160 or 144
  return font.scope(function()
   local F=font.selected;local height,base=16,mod.generation<3 and 2/3 or 1
   if mod.generation<3 then
    if ui.emeraldFont and ui.emeraldFont()then F=ui.nativeEmerald.presentation()
    else
     local nativeFont=require('src.render.Font')
     F={draw=nativeFont.draw,measure=nativeFont.width};height=8;base=1
    end
   end
   local factor=ui.fontSizing.factor()
   local function draw()
    local labelWidth,valueWidth=0,0
    for _,row in ipairs(rows)do labelWidth=math.max(labelWidth,F.measure(row[1]));valueWidth=math.max(valueWidth,F.measure(row[2]))end
    local pad=8
    -- Geometry depends on normal text only, never on the selected font size.
    local w=math.min(sw,math.max(rect.w,(labelWidth+valueWidth)*base+8+pad*2))
    local h=math.min(sh,rect.h)
    local x=math.max(0,math.min(sw-w,rect.x+rect.w-w));local y=math.max(0,math.min(sh-h,rect.y))
    compose(function()
     if ui.setting('style',1)==1 then
      local borders=mod.exports.borders;local prior=borders.nativeDialogue;borders.nativeDialogue=true
      local ok,err=pcall(native,x,y,w,h);borders.nativeDialogue=prior;if not ok then error(err,0)end
      ui.fillBackground(x,y,w,h)
     elseif ui.setting('style',1)==3 then mod.exports.borders.drawPixels(x,y,w,h,ui.backgroundColor(),'battle')
     else panel(x,y,w,h,false)end
    end,sw,sh,0,0)
    -- Text bypasses the tiny native canvas. Fit and snap the whole font once
    -- in the destination framebuffer, including the label/value column gap.
    local ax,ay=G.transformPoint(x+pad,y+pad)
    local bx,by=G.transformPoint(x+w-pad,y+h-pad)
    local ex,ey=G.transformPoint(x+pad+1,y+pad)
    local unit=math.sqrt((ex-ax)^2+(ey-ay)^2)
    local target=G.getCanvas and G.getCanvas()
    local physical=target and target:getDPIScale()or(G.getDPIScale and G.getDPIScale()or 1)
    local pitch=(by-ay)/#rows
    local pixels=math.max(1,math.floor(math.min(unit*base*factor,(bx-ax-4*unit)/math.max(1,labelWidth+valueWidth),(pitch-1)/height)*physical+.00001))/physical
    local colors=ui.palette.colors('battle')
    G.push('all');G.origin();G.setShader()
    for i,row in ipairs(rows)do
     local ty=math.floor((ay+(i-1)*pitch+(pitch-height*pixels)/2)*physical+.5)/physical
     local function text(s,tx)
      G.push('all');G.translate(math.floor(tx*physical+.5)/physical,ty);G.scale(pixels,pixels)
      F.draw(s,0,0,{colors=colors});G.pop()
     end
     text(row[1],ax);text(row[2],bx-F.measure(row[2])*pixels)
    end
    G.pop()
    if ui.protect then ui.protect(x,y,w,h)end
   end
   if ui.fontSizing.unscaled then return ui.fontSizing.unscaled(draw)end
   return draw()
  end)
 end
 local function render(rows,rect,native)
  if #rows==0 then return end
  if mod.hooks then pending={rows=rows,rect=rect,native=native};return end
  return drawPanel(rows,rect,native)
 end
 if mod.hooks then
  mod.hooks:wrap('render.hud',function(nextFn,game,viewport)
   local out={nextFn(game,viewport)}
   local job=pending;pending=nil
   if job and enabled()then
    local sw,sh=mod.generation==3 and 240 or 160,mod.generation==3 and 160 or 144
    local w,h=viewport.width,viewport.height
    local scale=math.min(w/sw,h/sh)
    G.push('all');G.origin();G.setScissor();G.translate((w-sw*scale)/2,(h-sh*scale)/2);G.scale(scale,scale)
    local ok,err=pcall(drawPanel,job.rows,job.rect,job.native);G.pop()
    if not ok then error(err,0)end
   end
   return unpack(out)
  end,30000)
 end
 M.render=render
 local function install(target,key,wrapper)
  local tag='_menuCustomizerLevelUp_'..key
  if target[tag]then target[tag].run=wrapper;return end
  local state={native=target[key],run=wrapper};target[tag]=state
  target[key]=function(...)return state.run(state.native,...)end
 end
 if mod.generation<3 then
  local F=require('src.render.Font');local Chrome=mod.generation==2 and require('src.ui.gen2.Chrome')
  local target=mod.generation==1 and require('src.battle.BattleState').StatBox or require('src.ui.gen2.BattleState')
  if mod.generation==1 then
   -- KIM redraws the HUD after native child windows. Suppress that HUD while
   -- a stat window is on top, including KIM's separate HUD capture pass.
   local Battle=require('src.battle.BattleState')
   install(Battle,'drawHUDs',function(original,battle,...)
    local stack=battle.game and battle.game.stack
    local top=stack and stack:top()
    if enabled()and top and getmetatable(top)==target then return end
    return original(battle,...)
   end)
  end
  install(target,mod.generation==1 and'draw'or'drawStatsBox',function(original,...)
   if not enabled()then return original(...)end
   local rows,pending,rect={},nil,nil
   local box,draw=F.drawBox,F.draw
   local function capture(text)if not pending then pending=tostring(text)else rows[#rows+1]={pending,tostring(text)};pending=nil end end
   local function frame(x,y,w,h)rect={x=x*8,y=y*8,w=w*8,h=h*8}end
   local cbox,print,right
   G.push('all');F.drawBox=frame;F.draw=capture
   if Chrome then cbox,print,right=Chrome.textbox,Chrome.printThrough,Chrome.printRightThrough;Chrome.textbox=frame;Chrome.printThrough=capture;Chrome.printRightThrough=capture end
   local out={pcall(original,...)}
   F.drawBox,F.draw=box,draw
   if Chrome then Chrome.textbox,Chrome.printThrough,Chrome.printRightThrough=cbox,print,right end
   G.pop();if not out[1]then error(out[2],0)end
   if rect then render(rows,rect,function(x,y,w,h)return box(x/8,y/8,w/8,h/8)end)end
   return unpack(out,2)
  end)
 else
  local Window=require('src.ui.game3.window');local Growth=require('src.ui.game3.stat_growth')
  local Rom=require('src.core.game3.rom_text')
  local function stats(old,new,page,box,pos)
   local keys={'maxHp','atk','def','spa','spd','spe'}
   local labels={}
   if box and box.layout=='rs'then
    keys=box.stats;for i=1,#keys do labels[i]=Rom.at(box.names,i-1)end
   else
    local profile=require('src.core.game3.profile').active()
    local names=profile.ui and profile.ui.party and profile.ui.party.text and profile.ui.party.text.levelUpStats
    for i=1,6 do labels[i]=names and Rom.plain(names[i])or Rom.at('sLevelUpWindowStatNames',i-1)end
   end
   local rows={}
   for i,key in ipairs(keys)do local n=tonumber(new[key])or 0
    local text=tostring(n)
    if page==1 then local delta=n-(tonumber(old[key])or 0);text=(delta>=0 and'+'or'-')..math.abs(delta)end
    rows[#rows+1]={labels[i],text}
   end
   render(rows,{x=pos.x*8,y=pos.y*8,w=pos.w*8,h=pos.h*8},function(x,y,w,h)Window.stdFrame(Window.template(x/8,y/8,w/8,h/8))end)
  end
  install(Growth,'draw',function(original,...)
   if not enabled()or not Growth.isOpen()then return original(...)end
   return stats(Growth._oldStats or{},Growth._newStats or{},Growth._page,Growth._box,Growth._pos or{x=19,y=1,w=10,h=11})
  end)
  local Party=require('src.ui.game3.party_menu');local F=require('src.ui.game3.frlg_font')
  install(Party,'draw',function(original,...)
   if not enabled()or Party.mode~='stat_growth'then return original(...)end
   local frame,draw=Window.stdFrame,F.draw
   Window.stdFrame=function(t,...)if t.left==19 and t.top==1 and t.w==10 and t.h==11 then return end;return frame(t,...)end
   F.draw=function(text,x,y,...)if x>=152 and y<112 then return end;return draw(text,x,y,...)end
   local out={pcall(original,...)};Window.stdFrame,F.draw=frame,draw
   if not out[1]then error(out[2],0)end
   stats(Party._statGrowthOld or{},Party._statGrowthNew or{},Party._statGrowthPage,nil,{x=19,y=1,w=10,h=11})
   return unpack(out,2)
  end)
 end
 return M
end
