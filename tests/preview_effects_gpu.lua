local root=assert(os.getenv('MENU_FIX_SOURCE')):gsub('\\','/')
local out=assert(os.getenv('MENU_FIX_OUTPUT')):gsub('\\','/')
local engine=root:match('^(.*)/%.work/')..'/.tools/engine-0358'
local function read(p)local f=assert(io.open(p,'rb'));local s=f:read('*a');f:close();return s end
local function write(p,s)local f=assert(io.open(out..'/'..p,'wb'));f:write(s);f:close()end
function love.load()
 local ok,err=xpcall(function()
  local G=love.graphics;local checks=0
  local function check(v,m)checks=checks+1;assert(v,m)end
  local values={menuTextColor=2,menuTextShadowColor=1,dialogueTextColor=4,menuBorder=13,menuTheme=2}
  local mod={generation=3,exports={},options={get=function(_,k)return values[k]end},save={get=function()end},
   read=function(_,p)return read(root..'/'..p)end,assets={image=function(_,p)return G.newImage(love.filesystem.newFileData(read(root..'/'..p),p))end}}
  local function module(p)return assert(loadstring(mod:read('lib/'..p)))()end
  local P=module('battle_text_palette.lua')(mod)
  for i,name in ipairs(P.menuBackgroundNames)do if name=='MINT LAGOON'then values.menuBackgroundColor=i-1 end end
  check(values.menuBackgroundColor~=nil,'animated paper fixture')
  mod.exports.menuBackground=function()if mod.exports.previewScope then return P.menuBackground('option')end end
  package.loaded['src.core.GameVersion']={get=function()return 'firered'end}
  package.loaded['src.ui.game3.chrome']={}
  local catalog=module('border_catalog.lua');local B=module('menu_borders.lua')(mod,function(k)return values[k]or 0 end,catalog,function()return true end)
  package.loaded['src.render.Font']={encode=function()return {}end}
  local T=module('emerald_theme.lua')(mod,function()return true end)
  local F={draw=function(s,x,y,o)return T.draw(s,x,y,o)end,drawGlyph=function(id,x,y,o)return T.glyph(id,x,y,o)end}
  package.loaded['src.ui.game3.frlg_font']=F
  local Window={OPTION_HEIGHT=16,CURSOR_WIDTH=8,template=function(x,y,w,h)return {left=x,top=y,w=w,h=h}end,
   stdFrame=function(t)return B.draw(t.left-1,t.top-1,t.w+2,t.h+2)end,
   cursorPx=function()end,printPx=function(s,x,y)return F.draw(s,x,y)end}
  package.loaded['src.ui.game3.window']=Window;package.loaded['src.core.game3.display']={TILE=8}
  package.loaded['src.core.game3.rom_text']={};package.loaded['src.core.game3.se_ids']={}
  local Mon=assert(loadstring(read(engine..'/src/ui/game3/mon_pic.lua')))()
  local Choice=assert(loadstring(read(engine..'/src/ui/game3/choice.lua')))()
  package.loaded['src.ui.game3.mon_pic']=Mon;package.loaded['src.ui.game3.choice']=Choice
  module('preview_windows.lua')(mod,P,function()return true end)
  local blank=love.image.newImageData(1,1);blank:setPixel(0,0,0,0,0,0)
  Mon.active,Mon._img,Mon._w,Mon._h,Mon.left,Mon.top=true,G.newImage(blank),64,64,10,3
  Choice.active,Choice.kind,Choice.options,Choice.left,Choice.top,Choice.cursor=true,'yesno',{'YES','NO'},3,15,1
  local canvas=G.newCanvas(240,180,{dpiscale=1})
  G.setCanvas(canvas);G.origin();G.clear(0,0,0,0)
  mod.exports.dialogueFontScope=true;Mon.draw();Choice.draw();G.setCanvas()
  check(mod.exports.dialogueFontScope and not mod.exports.previewScope,'preview restores surrounding dialogue')
  local data=canvas:newImageData();mod.exports.dialogueFontScope=false;local actual=P.menuBackground('option')
  -- Compare the preview interiors with the same palette/border renderer.
  local expected=G.newCanvas(240,180,{dpiscale=1})
  G.setCanvas(expected);G.origin();G.clear(0,0,0,0);B.drawPixels(80,24,80,80,actual,'option');B.drawPixels(16,112,64,48,actual,'option');G.setCanvas()
  local compare=expected:newImageData()
  for _,p in ipairs({{90,40},{145,90},{24,120},{65,148}})do
   local a={data:getPixel(p[1],p[2])};local b={compare:getPixel(p[1],p[2])}
   for i=1,4 do check(math.abs(a[i]-b[i])<.006,'starter and YES/NO use configured paper')end
  end
  local ink=0
  for y=123,135 do for x=33,57 do local r,g,b=data:getPixel(x,y);if b>r+.25 and b>g+.25 then ink=ink+1 end end end
  check(ink>0,'YES/NO uses blue menu text despite red dialogue text')
  write('preview-windows.png',data:encode('png'):getString())
  mod.exports.dialogueFontScope=false
  local effects=G.newCanvas(8,8,{dpiscale=1})
  local function draw()
   G.setCanvas(effects);G.origin();G.clear(0,0,0,0)
   P.effects.glyph(P.colors('menu'),3,3,function(dx,dy)G.rectangle('fill',3+dx,3+dy,1,1)end,{width=3,height=3,top=0});G.setCanvas()
   return effects:newImageData()
  end
  values.menu_fx_highlight=1;values.menu_fx_outline=1
  values.menu_fx_highlight_transparency=25;values.menu_fx_outline_transparency=50;values.menu_fx_shadow_transparency=75
  local d=draw();local _,_,_,a=d:getPixel(5,5);check(math.abs(a-.75)<.006,'highlight 25% transparent')
  local _,_,_,a=d:getPixel(2,2);check(math.abs(a-.5)<.006,'outline 50% transparent')
  values.menu_fx_highlight=0;values.menu_fx_outline=0
  d=draw();local _,_,_,a=d:getPixel(2,4);check(math.abs(a-.25)<.006,'shadow 75% transparent')
  values.menu_fx_highlight=1;values.menu_fx_outline=1
  for _,key in ipairs({'highlight','outline','shadow'})do values['menu_fx_'..key..'_transparency']=100 end
  d=draw();local _,_,_,a=d:getPixel(2,4);check(a==0,'100% removes effect pixels')
  local _,_,_,a=d:getPixel(3,3);check(a==1,'foreground remains opaque')
  local cursorCanvas=G.newCanvas(64,24,{dpiscale=1})
  local icons=module('menu_selectors.lua');mod.exports.selectorPalette=P
  local arrows=module('arrow_selectors.lua')(mod,icons,function(k)return values[k]or 0 end,function()return true end)
  values.arrowSelector=13;values.selectionHighlight=25
  G.setCanvas(cursorCanvas);G.origin();G.clear(0,0,0,0);arrows.draw(0,0,16);G.setCanvas()
  local d=cursorCanvas:newImageData();local _,_,_,a=d:getPixel(10,10);check(math.abs(a-.25)<.006,'NONE uses the shared transparent highlight')
  G.setCanvas(cursorCanvas);G.origin();G.clear(0,0,0,0);arrows.draw(0,0,16,{_selectionHighlight=true});G.setCanvas()
  local _,_,_,a=cursorCanvas:newImageData():getPixel(10,10);check(a==0,'existing OPTIONS highlight is not duplicated')
  values.arrowSelector=11;values.selectorColor=2
  G.setCanvas(cursorCanvas);G.origin();G.clear(0,0,0,0);arrows.draw(0,0,16,{_selectorWidth=30,_selectorInset=8});G.setCanvas()
  local r,g,b,a=cursorCanvas:newImageData():getPixel(36,13);check(b>r+.5 and a==1,'Arrow underline uses custom selector color across full label')
  write('preview-effects-result.txt','PASS '..checks..' real GPU starter/YES-NO palette and text-effect alpha checks\n')
 end,debug.traceback)
 if not ok then write('preview-effects-result.txt','FAIL '..tostring(err))end
 love.event.quit(ok and 0 or 1)
end
