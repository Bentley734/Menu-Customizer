local root=assert(os.getenv('MENU_FIX_SOURCE')):gsub('\\','/')
local out=assert(os.getenv('MENU_FIX_OUTPUT')):gsub('\\','/')
local workspace=root:match('^(.*)/%.work/')
package.path=workspace..'/.tools/engine-0358/?.lua;'..package.path
local function read(p)local f=assert(io.open(root..'/'..p,'rb'));local s=f:read('*a');f:close();return s end
local function write(p,s)local f=assert(io.open(out..'/'..p,'wb'));f:write(s);f:close()end
function love.load()
 local ok,err=xpcall(function()
  local G=love.graphics;local checks=0
  local function check(v,m)checks=checks+1;assert(v,m)end
  require('src.core.GameVersion').set('firered')
  local F=require('src.ui.game3.frlg_font')
  local choices={battle_font_size=0}
  local mod={exports={},options={get=function(_,k)return choices[k]end},save={get=function()end},read=function(_,p)return read(p)end,
   assets={image=function(_,p)return G.newImage(love.filesystem.newFileData(read(p),p))end}}
  local function module(p)return assert(loadstring(read('lib/'..p)))()end
  local T=module('emerald_theme.lua')(mod,function()return true end)
  F.measure=T.measure;F.draw=function(s,x,y,o)local w,ex,ey=T.draw(s,x,y,o);return w,ex,ey end
  F.drawGlyph=T.glyph;F.linePitch=function()return 16 end;F.advance=function()return 8 end
  local sizing=module('battle_font_size.lua')(mod,function()return true end)
  sizing.decorate(F,'draw','measure','drawGlyph',false)
  local Chrome={dialogueWindow=function()return 2,15,26,4 end};package.loaded['src.ui.game3.chrome']=Chrome
  local M={_frame='dialogue',open=true}
  function M.show(s,opts)M._pages={s};M._page=1;M._waiting=true;return M end
  local opts={colors={fg={0,0,0,1},shadow={0,0,0,0}}}
  M.drawText=function()
   local x,y,w=Chrome.dialogueWindow()
   return F.draw(M._pages[M._page],x*8,y*8+1,{colors=opts.colors,maxWidth=w*8,limitChars=M._revealed})
  end
  local D=module('dialogue_text.lua')(mod,M,F,function()return true end)
  local source=G.newCanvas(240,160,{dpiscale=1});source:setFilter('nearest','nearest')
  local oldGlyph=T.glyph;local widths={};local bounds
  T.glyph=function(id,x,y,o)
   if not G.getCanvas()then
    local ax,ay=G.transformPoint(x,y);local bx,by=G.transformPoint(x+1,y);local tx,ty=G.transformPoint(x,y+2);local cx,cy=G.transformPoint(x,y+13)
    local unit=bx-ax;check(math.abs(unit-math.floor(unit+.5))<.00001,'integer dialogue pixels')
    widths[#widths+1]=unit
    check(ty>=bounds.top-.001 and cy<=bounds.bottom+.001,'both lines inside frame interior')
   end
   return oldGlyph(id,x,y,o)
  end
  local messages={'GARY: Wait, ASH!','GARY: Wait, ASH!\nLet\'s check out our POKeMON!',
   'This longer conversation must wrap into extra pages while every letter keeps exactly the same chosen size.',
   'SUPERCALIFRAGILISTICEXPIALIDOCIOUSSUPERCALIFRAGILISTICEXPIALIDOCIOUS'}
  for _,size in ipairs({1,2})do choices.battle_font_size=size;local expected=size==1 and 4 or 6
   for _,s in ipairs(messages)do
    check(M.show(s,{speed=0})==M,'native message show contract')
    local reconstructed={}
    for i,page in ipairs(M._pages)do
     local lines=0;for _ in (page..'\n'):gmatch('(.-)\n')do lines=lines+1 end
     check(lines<=2,'at most two lines on each page')
     mod.exports.dialogueFontScope,mod.exports.dialogueFixedSize=true,true
     check(F.measure(page)<=200,'both lines fit horizontally without shrinking')
     mod.exports.dialogueFontScope,mod.exports.dialogueFixedSize=nil,nil
     reconstructed[#reconstructed+1]=page
     M._page=i;M._revealed=F.countChars(page);D.beginFrame()
     G.setCanvas(source);G.origin();G.clear(0,0,0,0);M.drawText();G.setCanvas()
     local _,y,_,h=Chrome.dialogueWindow();bounds={top=10+y*8*3.47,bottom=10+(y+h)*8*3.47}
     widths={};G.origin();G.draw(source,10,10,0,3.47,3.47)
     check(#widths>0,'dialogue remains visible')
     for _,unit in ipairs(widths)do check(unit==expected,'short and long messages have the same font size')end
    end
    check(table.concat(reconstructed):gsub('%s','')==s:gsub('%s',''),'pagination loses no text')
   end
  end
  check(T.measure('ASH\nGARY')==math.max(T.measure('ASH'),T.measure('GARY')),'multiline uses the same Emerald face')
  write('dialogue-result.txt','PASS '..checks..' GPU fixed-size, two-line bounds, wrapping, pagination and text-preservation checks\n')
 end,debug.traceback)
 if not ok then write('dialogue-result.txt','FAIL '..tostring(err))end
 love.event.quit(ok and 0 or 1)
end
