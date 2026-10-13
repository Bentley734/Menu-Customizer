local root=assert(os.getenv('MENU_FIX_SOURCE')):gsub('\\','/')
local out=assert(os.getenv('MENU_FIX_OUTPUT')):gsub('\\','/')
local engine=root:match('^(.*)/%.work/')..'/.tools/engine-0358'
local function read(p)local f=assert(io.open(p,'rb'));local s=f:read('*a');f:close();return s end
local function write(p,s)local f=assert(io.open(out..'/'..p,'wb'));f:write(s);f:close()end
local function compile(s,env)local f=assert(loadstring(s));if env then setfenv(f,env)end;return f()end
function love.load()
 local ok,err=xpcall(function()
  local G=love.graphics;local checks=0
  local function check(v,m)checks=checks+1;assert(v,m)end
  local values={dialogueTheme=2,menuTheme=2,dialogueBorder=1,menuBorder=13,dialogueTextColor=2,selectionHighlight=25}
  local mod={generation=1,exports={},options={get=function(_,k)return values[k]end},save={get=function()end},
   read=function(_,p)return read(root..'/'..p)end,assets={image=function(_,p)return G.newImage(love.filesystem.newFileData(read(root..'/'..p),p))end}}
  local function module(p)return compile(mod:read('lib/'..p))end
  local mask=love.image.newImageData(8,8)
  for y=0,7 do for x=0,7 do local ink=y==0 or x==3;mask:setPixel(x,y,ink and 0 or 1,ink and 0 or 1,ink and 0 or 1,1)end end
  local native=G.newImage(mask);native:setFilter('nearest','nearest')
  local F={encode=function(s)local a={};for i=1,#s do a[#a+1]=s:byte(i)end;return a end,drawCode=function(_,x,y)G.draw(native,x,y)end,advanceOf=function()return 8 end}
  F.width=function(s)return #s*8 end
  F.draw=function(s,x,y)for i=1,#s do F.drawCode(s:byte(i),x+(i-1)*8,y)end end
  package.loaded['src.render.Font']=F;package.loaded['src.core.GameVersion']={get=function()return 'red'end}
  local P=module('battle_text_palette.lua')(mod)
  for i,name in ipairs(P.menuBackgroundNames)do if name=='MINT LAGOON'then values.dialogueBackgroundColor=i-1 end end
  check(values.dialogueBackgroundColor~=nil,'animated paper fixture')
  local C={mod=mod,palette=P,resizeX=1,resizeY=1,setting=function(k)return values[k]or 0 end}
  mod.exports.gbMenus=C;F._menuCustomizerGB=C
  mod.exports.menuBackground=function()return P.menuBackground('dialogue')end
  C.theme=module('emerald_theme.lua')(mod,function()return (C.dialogueScope or mod.exports.choiceFontScope) and values.dialogueTheme==2 end)
  C.theme.gbScale=function()return .75 end;C.theme.gbBaseline=function()return 2 end
  C.theme.gbColors=function()return P.colors('menu')end
  local raw=F.drawCode
  F.drawCode=function(id,x,y)
   if not C.theme.enabled()or not C.theme.gbGlyph(id,x,y)then return P.nativeMenuGlyph(raw,id,x,y)end
  end
  local glyph=C.theme.glyph;local units={}
  C.theme.glyph=function(id,x,y,opts)
   if G.getCanvas()and G.getCanvas():getWidth()>320 then
    local ax,ay=G.transformPoint(x,y);local bx,by=G.transformPoint(x+1,y);local cx,cy=G.transformPoint(x,y+1)
    check(math.abs(bx-ax-(cy-ay))<.0001,'square final glyph pixels')
    check(math.abs(bx-ax-math.floor(bx-ax+.5))<.0001,'integer final glyph pixels')
    units[#units+1]=bx-ax
   end
   return glyph(id,x,y,opts)
  end
  local D=module('gb_dialogue_text.lua')(F);C.dialogueText=D
  local B=module('menu_borders.lua')(mod,C.setting,module('border_catalog.lua'),function()return true end)
  C.borders=B
  local source=read(root..'/lib/gb_menus.lua')
  local box=function(tx,ty,tw,th)G.setColor(1,1,1,1);G.rectangle('fill',tx*8,ty*8,tw*8,th*8)end
  compile(assert(source:match('(  Font.drawBox=function.-)  local scrollText=')),setmetatable({Font=F,G=G,box=box},{__index=_G}))
  local ui=G.newCanvas(160,144,{dpiscale=1});ui:setFilter('nearest','nearest')
  local ww,hh=G.getDimensions();local target=G.newCanvas(ww,hh,{dpiscale=1})
  local indexed=G.newShader([[vec4 effect(vec4 c,Image tex,vec2 uv,vec2 px){vec4 s=Texel(tex,uv);return vec4(0.0,s.r*.8,s.r,s.a);} ]])
  local R={canvas=ui,beginFrame=function()end}
  local body=assert(read(engine..'/src/render/Renderer.lua'):match('(function Renderer:blitCanvas.-)\n%-%- Take a rect'))
  compile(body,setmetatable({Renderer=R,PaletteFX={shader=function()return indexed end,sendColors=function()end},
   scissorClamped=function(x,y,w,h)G.setScissor(x,y,w,h);return true end},{__index=_G}))
  compile(assert(source:match('( if not Renderer%._menuCustomizerDialogueColor then.-) local TextBox=')),setmetatable({Renderer=R,Font=F,mod=mod,C=C},{__index=_G}))
  for _,theme in ipairs({1,2})do for _,border in ipairs({0,1})do
   values.dialogueTheme,values.dialogueBorder=theme,border
   R:beginFrame();C.dialogueScope=true
   G.setCanvas(ui);G.origin();G.setScissor();G.clear(0,0,0,0)
   F.drawBox(0,12,20,6);F.draw('TTTT',16,112);F.draw('TTTT',16,128)
   G.setCanvas();C.dialogueScope=nil
   check(#C.dialogueRects==1 and C.dialogueRects[1].h==48,'complete frame and paper opt out of Gen 1 palette conversion')
   local r,g,b=ui:newImageData():getPixel(120,124)
   G.setCanvas(target);G.origin();G.setScissor();G.clear(0,0,0,0);G.setColor(1,1,1,1)
   G.setBlendMode('alpha','premultiplied')
   R:blitCanvas(ui,4,4,{{x=0,y=0,w=160,h=144,colors={}}},4,4,10,10,10,10,640,576,1,1)
   G.setCanvas();local rr,gg,bb=target:newImageData():getPixel(10+120*4+1,10+124*4+1)
   check(math.abs(r-rr)<.005 and math.abs(g-gg)<.005 and math.abs(b-bb)<.005,'animated paper retains original RGB through palette compositor')
   if theme==1 then
    local r,g,b=ui:newImageData():getPixel(21,116)
    local rr,gg,bb=target:newImageData():getPixel(10+21*4+1,10+116*4+1)
    check(math.abs(r-rr)<.005 and math.abs(g-gg)<.005 and math.abs(b-bb)<.005,'transparent native glyph pixels do not leak foreground color')
   end
   if theme==2 then check(#units>0,'Emerald letters are present');for _,u in ipairs(units)do check(u==3,'full glyph mask at three pixels per atlas pixel')end end
  end end
  -- YES/NO shares the field dialogue's final-resolution font geometry.
  values.dialogueTheme=2;D.beginFrame();units={}
  C.dialogueScope=true;G.setCanvas(ui);G.origin();G.clear(0,0,0,0);F.draw('YES',16,112)
  C.dialogueScope=false;C.drawScope=true;mod.exports.choiceFontScope=true
  C.resizeX,C.resizeY=1.25,.8;G.push('all');G.scale(1.25,.8)
  F.draw('YES',128,40);F.draw('NO',128,56)
  G.pop();C.resizeX,C.resizeY=nil,nil
  C.drawScope=false;mod.exports.choiceFontScope=nil;G.setCanvas()
  local choiceCount=0;for _,item in ipairs(D.queues[ui])do if item.choice then choiceCount=choiceCount+1 end end
  check(choiceCount==5,'all YES/NO letters defer even inside a menu draw scope')
  G.setCanvas(target);G.origin();G.clear(0,0,0,0);G.setColor(1,1,1,1);G.draw(ui,10,10,0,4,4);G.setCanvas()
  check(#units==8,'dialogue and YES/NO letters both replay')
  for _,unit in ipairs(units)do check(unit==3,'YES/NO uses the exact dialogue integer font size')end
  check(not C.dialogueScope and not mod.exports.choiceFontScope,'font scopes restore after mixed replay')
  write('gen1-dialogue.png',target:newImageData():encode('png'):getString())
  -- Execute the actual settings-page draw: it must leave the cursor to the
  -- shared deferred selector, rather than adding a second marker at x=12.
  local Page={};local inline=0;C.arrows={draw=function()inline=inline+1 end};C.compactText=false
  compile(assert(source:match('( function Page:draw%(%).-) local function row')),setmetatable({Page=Page,Font=F,G=G,C=C},{__index=_G}))
  local page=setmetatable({title='MENUS',rows={{label='START'}},index=1,scroll=0},{__index=Page})
  G.setCanvas(target);G.origin();page:draw();G.setCanvas()
  check(inline==0,'settings page no longer draws an extra selector')
  write('gen1-result.txt','PASS '..checks..' actual GPU RGB-preservation, native/Emerald, border on/off, integer glyph and selector-owner checks\n')
 end,debug.traceback)
 if not ok then write('gen1-result.txt','FAIL '..tostring(err))end
 love.event.quit(ok and 0 or 1)
end
