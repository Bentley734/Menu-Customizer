-- Run with LOVE; uses the shipped Emerald masks and production render modules.
local root=assert(os.getenv('MENU_FIX_SOURCE')):gsub('\\','/')
local out=assert(os.getenv('MENU_FIX_OUTPUT')):gsub('\\','/')
local function read(p)local f=assert(io.open(p,'rb'));local s=f:read('*a');f:close();return s end
local function write(p,s)local f=assert(io.open(p,'wb'));f:write(s);f:close()end
function love.load()
 local ok,err=xpcall(function()
  local G=love.graphics;local checks=0
  local function check(v,s)checks=checks+1;assert(v,s)end
  package.loaded['src.render.Font']={encode=function()return {}end}
  local choices={arrowSelector=1,selectionHighlight=25,battle_font_size=1}
  local mod={generation=3,exports={},options={get=function(_,k)return choices[k]end},save={get=function()end},
   read=function(_,p)return read(root..'/'..p)end,
   assets={image=function(_,p)return G.newImage(love.filesystem.newFileData(read(root..'/'..p),p))end}}
  local function loadMod(p)return assert(loadstring(mod:read('lib/'..p)))()end
  local T=loadMod('emerald_theme.lua')(mod,function()return true end)
  local opts={colors={fg={0,0,0,1},shadow={0,0,0,0}}}
  local icons=loadMod('menu_selectors.lua')
  local arrows=loadMod('arrow_selectors.lua')(mod,icons,function(k)return choices[k]end,function()return true end)
  mod.exports.arrowSelectors=arrows
  local F={CHAR_SELECTOR_ARROW=0xEF,COLOR={NORMAL=opts.colors},measure=T.measure,advance=function()return 8 end}
  F.draw=function(text,x,y,o)local w=T.draw(text,x,y,o);return #text,x+w,y end
  F.drawGlyph=function(id,x,y,o)return T.glyph(id,x,y,o)end
  local sizing=loadMod('battle_font_size.lua')(mod,function()return true end)
  sizing.decorate(F,'draw','measure','drawGlyph',false)
  local Message={open=true,_frame='dialogue',drawText=function()return F.draw('TTTT',16,121,opts)end}
  package.loaded['src.ui.game3.chrome']={dialogueWindow=function()return 2,15,26,4 end}
  local D=loadMod('dialogue_text.lua')(mod,Message,F,function()return true end)
  local source=G.newCanvas(240,160,{dpiscale=1});source:setFilter('nearest','nearest')
  local unit=0
  local originalGlyph=T.glyph
  T.glyph=function(id,x,y,o)
   if G.getCanvas()then return originalGlyph(id,x,y,o)end
   local ax,ay=G.transformPoint(x,y);local bx,by=G.transformPoint(x+1,y);local cx,cy=G.transformPoint(x,y+1)
   check(math.abs((bx-ax)-(cy-ay))<.00001,'square font pixels')
   check(math.abs(bx-ax-math.floor(bx-ax+.5))<.00001,'integer font pixels')
   unit=bx-ax;return originalGlyph(id,x,y,o)
  end
  for _,size in ipairs({0,1,2})do choices.battle_font_size=size;mod.exports.battleFontScope=true
   D.beginFrame();G.setCanvas(source);G.origin();G.clear(0,0,0,0)
   Message.drawText();G.setCanvas();G.origin()
   local blank=source:newImageData();local occupied=0
   for y=0,159 do for x=0,239 do local _,_,_,a=blank:getPixel(x,y);if a>0 then occupied=occupied+1 end end end
   check(occupied==0,'no letters baked into low-resolution canvas')
   G.clear(1,1,1,1);G.draw(source,11,13,0,3.47,4.91)
   check(unit==({3,4,6})[size+1],'font size snapped after final fractional resize')
  end
  -- The engine's effects path blits UI into a window-sized canvas first.
  -- Deferred dialogue must already be present when that canvas is processed.
  D.beginFrame();G.setCanvas(source);G.origin();G.clear(0,0,0,0);Message.drawText();G.setCanvas()
  local ww,hh=G.getDimensions();local intermediate=G.newCanvas(ww,hh,{dpiscale=1})
  G.setCanvas(intermediate);G.origin();G.clear(0,0,0,0);G.setColor(1,1,1,1)
  G.draw(source,11,13,0,3.47,3.47);G.setCanvas()
  local pixels=intermediate:newImageData();local ink=0
  for y=0,hh-1 do for x=0,ww-1 do local _,_,_,a=pixels:getPixel(x,y);if a>0 then ink=ink+1 end end end
  check(ink>0,'dialogue survives the intermediate effects canvas')
  mod.exports.battleFontScope=nil;choices.battle_font_size=0
  local menu={_pages={{index=3,scroll=1,rows={{},{},{}}}}}
  local selection=loadMod('option_selection.lua')(mod,F,function(k)return choices[k]end,function()return true end,'firered')
  local draw=selection.wrap(menu,function()G.setColor(0,0,0,2/16);G.rectangle('fill',16,56,208,13);return 'native' end)
  for id=1,10 do choices.arrowSelector=id
   G.setCanvas(source);G.origin();G.clear(0,0,0,0)
   check(draw()=='native','draw return contract')
   G.setCanvas();local data=source:newImageData();local occupied=0
   for y=72,84 do for x=15,24 do local _,_,_,a=data:getPixel(x,y);if a>0 then occupied=occupied+1 end end end
   check(occupied>0,'visible settings selector '..id)
  end
  for _,alpha in ipairs({0,25,100})do choices.selectionHighlight=alpha
   G.setCanvas(source);G.origin();G.clear(0,0,0,0);draw();G.setCanvas()
   local _,_,_,a=source:newImageData():getPixel(80,75)
   check(math.abs(a-alpha/100)<.006,'highlight intensity '..alpha)
  end
  -- Save a clean fractional-zoom sample for visual inspection.
  D.beginFrame();G.setCanvas(source);G.origin();G.clear(.92,.92,.9,1);Message.drawText();G.setCanvas()
  local preview=G.newCanvas(1100,650,{dpiscale=1})
  G.setCanvas(preview);G.origin();G.clear(.08,.1,.15,1);G.setColor(1,1,1,1)
  G.draw(source,11,13,0,3.47,3.47)
  loadMod('menu_text_surface.lua')(mod,F).draw(D.queues[source],11,13,3.47,3.47,1)
  G.setCanvas();write(out..'/dialogue-preview.png',preview:newImageData():encode('png'):getString())
  write(out..'/gpu-result.txt','PASS '..checks..' actual GPU selector, intensity, deferred dialogue and integer NORMAL/LARGE/EXTRA LARGE checks\n')
 end,debug.traceback)
 if not ok then write(out..'/gpu-result.txt','FAIL '..tostring(err))end
 love.event.quit(ok and 0 or 1)
end
