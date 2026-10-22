-- Actual render modules with recorded final-frame geometry. No game/save state.
local unpack=unpack or table.unpack
local checks=0
local function check(value,message)checks=checks+1;assert(value,message)end
local function near(a,b,message)check(math.abs(a-b)<.00001,message..': '..tostring(a)..' / '..tostring(b))end
local function graphics()
 local G={dpi=1,records={}}
 local sx,sy,tx,ty=1,1,0,0
 local canvas,clip,color=nil,nil,{1,1,1,1};local stack={}
 function G.push()stack[#stack+1]={sx,sy,tx,ty,canvas,clip,color}end
 function G.pop()local s=assert(table.remove(stack));sx,sy,tx,ty,canvas,clip,color=unpack(s,1,7)end
 function G.origin()sx,sy,tx,ty=1,1,0,0 end
 function G.translate(x,y)tx,ty=tx+x*sx,ty+y*sy end
 function G.scale(x,y)sx,sy=sx*x,sy*(y or x)end
 function G.transformPoint(x,y)return tx+x*sx,ty+y*sy end
 function G.setCanvas(c)canvas=c end
 function G.getCanvas()return canvas end
 function G.getDPIScale()return G.dpi end
 function G.setScissor(x,y,w,h)clip=x and{x,y,w,h}or nil end
 function G.getScissor()if clip then return unpack(clip)end end
 function G.setShader()end
 function G.setBlendMode()end
 function G.setColor(r,g,b,a)color=type(r)=='table'and r or{r,g,b,a or 1}end
 function G.clear()G.records={}end
 function G.draw()end
 function G.record(text)
  local x,y=G.transformPoint(0,0)
  local c=clip and{unpack(clip)}or nil
  G.records[#G.records+1]={text=text,x=x,y=y,sx=sx,sy=sy,clip=c}
 end
 function G.rectangle()end
 function G.balanced()return #stack==0 end
 return G
end

-- HUD names keep their layout rectangle but allow one final font pixel of ink
-- to its left. Occluders must be subtracted after that expansion.
local function nameCase(scale,dpi,cover,shadow)
 local G=graphics();G.dpi=dpi
 local F={drawBox=function()end}
 local colors={fg={1,0,0,1},shadow=shadow and{0,0,0,1}or{0,0,0,0}}
 local mod={generation=1,exports={customization={text=function(s)return s end},
  selectorPalette={colors=function()return colors end},
  battleFontSizing={unscaled=function(fn)return fn()end},gbMenus={theme={
   measure=function()return 60 end,draw=function(text)G.record(text)end}}}}
 local env=setmetatable({love={graphics=G},require=function(name)assert(name=='src.render.Font');return F end},{__index=_G})
 local source=assert(io.open('lib/battle_name_surface.lua')):read('*a')
 assert(load(source,'name clipping','t',env))()(mod)
 local M=assert(mod.exports.battleNameSurface)
 local sourceCanvas={}
 G.setCanvas(sourceCanvas);G.origin();M.capture('Charmander',40,0)
 if cover then M.occlude(unpack(cover))end
 G.setCanvas();G.origin();G.draw(sourceCanvas,0,0,0,scale,scale)
 check(#G.records>0,'a visible HUD name must still be drawn')
 local unit=math.max(1,math.floor(math.min(48*scale*dpi/60,12*scale*dpi/16)))
 local anchor=math.floor(40*scale*dpi+.5)/dpi
 local expectedLeft=math.min(40*scale,anchor-unit/dpi)
 for _,r in ipairs(G.records)do
  near(r.x,anchor,'name foreground anchor is unchanged')
  near(r.sx,unit/dpi,'name integer pixel size is unchanged')
  check(r.clip~=nil,'name paint remains clipped')
  if not cover then near(r.clip[1],expectedLeft,'name shadow has a complete left font pixel')end
  near(r.clip[1]+r.clip[3],88*scale,'name right fit bound is unchanged')
  if cover then
   local left,right=cover[1]*scale,(cover[1]+cover[3])*scale
   check(r.clip[1]>=right or r.clip[1]+r.clip[3]<=left,'shadow expansion never crosses a popup occluder')
  end
 end
 check(G.balanced(),'name rendering restores graphics state')
 return G.records
end
for _,spec in ipairs({{4,1},{3.5,1},{2.25,2},{3.507,1},{2.253,2}})do
 nameCase(spec[1],spec[2],nil,true)
 nameCase(spec[1],spec[2],nil,false)
 -- A popup ending at the glyph anchor covers exactly the newly exposed ink.
 local clipped=nameCase(spec[1],spec[2],{39,-4,1,40},true)
 near(clipped[1].clip[1],40*spec[1],'covered shadow is not grown back after subtraction')
end

-- The prompt alone permits its negative shadow bearing. Label positions,
-- right/top/bottom boundaries, and the command-cell clips stay unchanged.
local function promptCase(choice,justify,shadow,rectX)
 local G=graphics();local currentScope
 local colors={fg={1,0,0,1},shadow=shadow and{0,0,0,1}or{0,0,0,0}}
 local prompt={get=function(key,default)
  if key=='Size'then return 1 elseif key=='Justify'then return justify end
  return default
 end,colors=function(base)return base end}
 local mod={options={get=function()return 1 end},exports={battlePrompt=prompt,
  sectionFontSize={choice=function()return choice end,with=function(scope,fn)
   local old=currentScope;currentScope=scope;local out={fn()};currentScope=old;return unpack(out)
  end}}}
 local F={CHAR_SELECTOR_ARROW=0xEF,measure=function(s)return #s*6 end,drawGlyph=function()end}
 function F.draw(text,x,y)
  G.push('all');G.translate(x,y)
  -- The real section decorator may double complete prompt strings, bounded
  -- by their available width/height. This case deliberately exercises 2x.
  if currentScope=='battlePrompt'and choice==3 then G.scale(2,2)end
  G.record(text);G.pop()
 end
 local custom={frames=function()end}
 local layout=assert(loadfile('lib/emerald_battle_layout.lua'))()(G,mod)
 local rect={x=rectX,y=240,w=640,h=160}
 check(layout.commands(F,{player={name='Charmander'},menuIndex=1},1,rect,custom,colors,{dpiX=1,dpiY=1}),'commands draw')
 local edge=8*rect.h/48
 local left=rect.x+edge
 local paneWidth=rect.w-2*edge
 local promptWidth=paneWidth*.4
 local found=0
 for _,r in ipairs(G.records)do
  if r.text=='What will'or r.text=='Charmander do?'or r.text=='Charmander'or r.text=='do?'then
   found=found+1
   check(r.clip[1]<=r.x-r.sx+.00001,'each prompt line keeps its full negative shadow bearing')
   near(r.clip[1]+r.clip[3],left+promptWidth,'prompt right clip boundary is unchanged')
   near(r.clip[2],rect.y+edge,'prompt top boundary is unchanged')
   near(r.clip[4],rect.h-2*edge,'prompt panel height is unchanged')
   if justify==1 then near(r.x,math.floor(left+.5),'left-aligned foreground does not move')end
  else
   check(r.clip[1]>=left+promptWidth,'command cells do not borrow the prompt shadow margin')
  end
 end
 check(found>=2,'all prompt lines were checked')
 check(G.balanced(),'prompt rendering restores graphics state')
end
for _,rectX in ipairs({40,40.4,40.8})do
 for _,choice in ipairs({1,2,3})do for _,justify in ipairs({1,2,3})do
  promptCase(choice,justify,true,rectX)
  promptCase(choice,justify,false,rectX)
 end end
end
print('PASS '..checks..' name/prompt shadow clip, anchor, integer-scale, and popup-occlusion checks')
