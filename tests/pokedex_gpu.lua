local root=assert(os.getenv('MENU_FIX_SOURCE')):gsub('\\','/')
local out=assert(os.getenv('MENU_FIX_OUTPUT')):gsub('\\','/')
local engine=root:match('^(.*)/%.work/')..'/.tools/engine-0358'
local function read(p)local f=assert(io.open(p,'rb'));local s=f:read('*a');f:close();return s end
local function write(p,s)local f=assert(io.open(out..'/'..p,'wb'));f:write(s);f:close()end
function love.load()
 local ok,err=xpcall(function()
  local G=love.graphics;local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
  local theme=1;local Font={encode=function(s)local out={};for i=1,#s do out[#out+1]=s:byte(i)end;return out end}
  package.loaded['src.render.Font']=Font
  package.loaded['src.core.Strings']=function(s,...)return select('#',...)>0 and string.format(s,...)or s end
  package.loaded['src.ui.Theme']={moreArrow=0xEE}
  package.loaded['src.pokemon.Sprites']={path=function()end}
  package.loaded['src.ui.PokedexMenu']={}
  local Entry=assert(loadstring(read(engine..'/src/ui/DexEntryMenu.lua')))();package.loaded['src.ui.DexEntryMenu']=Entry
  local mod={exports={},read=function(_,p)return read(root..'/'..p)end,assets={image=function(_,p)return G.newImage(love.filesystem.newFileData(read(root..'/'..p),p))end}}
  local T=assert(loadstring(read(root..'/lib/emerald_theme.lua')))()(mod,function()return theme==2 end)
  T.gbScale=function()return .5 end
  Font.advanceOf=function(id)return theme==2 and T.gbAdvance(id)or 8 end
  Font.width=function(s)local w=0;for _,id in ipairs(Font.encode(s))do w=w+Font.advanceOf(id)end;return w end
  local bounds={}
  Font.drawCode=function(id,x,y)
   if theme==2 and T.gbGlyph(id,x,y)then return end
   G.setColor(0,0,0,1);G.rectangle('fill',x,y,6,8)
  end
  Font.draw=function(s,x,y)
   if y>=88 then bounds[#bounds+1]={x=x,y=y,w=Font.width(s),text=s}end
   local pen=x;for _,id in ipairs(Font.encode(s))do Font.drawCode(id,pen,y);pen=pen+Font.advanceOf(id)end
  end
  local catalog=assert(loadstring(read(root..'/lib/border_catalog.lua')))()
  mod.generation=1
  package.loaded['src.core.GameVersion']={get=function()return 'red'end}
  local C={live=function()return true end}
  C.borders=assert(loadstring(read(root..'/lib/menu_borders.lua')))()(mod,function(key)
   if key=='menuTheme'then return theme elseif key=='pokedexBorderChoice'then return 13 else return 1 end
  end,catalog,function()return true end)

  local nativeDraw=Entry.draw
  local statsSprite=G.newImage(love.image.newImageData(8,8))
  local mirrored=false;local gpuDraw=G.draw
  G.draw=function(image,x,y,rot,sx,sy,...)
   if image==statsSprite then mirrored=sx==-1 and sy==1 end
   return gpuDraw(image,x,y,rot,sx,sy,...)
  end
  Entry.draw=function(self)
   if self.page~=2 then return nativeDraw(self)end
   G.rectangle('fill',0,0,160,144);G.draw(self.sprite,8,52)
   Font.draw('BASE STATS',72,8);Font.draw('H',0,136)
  end
  local M=assert(loadstring(read(root..'/lib/gb_pokedex_text.lua')))()(Font,function()return C end)
  local text='Obviously prefers hot places. When it rains, steam is said to spout from the tip of its tail. Its flame changes with its health.'
  local def={id='CHARMANDER',name='CHARMANDER',dex=4,dexEntry={text='entry',kind='LIZARD',heightM=.6,heightFt=2,weightKg=8.5}}
  local game={data={pokemon={CHARMANDER=def},text={entry=text},constants={dexDigits=4}},save={pokedex={owned={CHARMANDER=true}}},input={wasPressed=function()return false end}}
  local canvas=G.newCanvas(960,864,{dpiscale=1})
  for _,face in ipairs({1,2})do theme=face
   local height,weight=M.measurements(def.dexEntry);check(height=="2'00\"" and weight=='18.7 lb','metric conversion rounds to inches and tenths of a pound')
   local pages=M.pages(text,136,3);local entry=Entry.new(game,'CHARMANDER');entry.picDelay=0
   check(entry._dexDescriptionCount==#pages,'native entry has correct measured page count')
   for i=1,#pages do entry._dexDescriptionPage=i;bounds={}
    G.setCanvas(canvas);G.origin();G.scale(6,6);G.clear(1,1,1,1);entry:draw();G.setCanvas()
    check(#bounds>0 and #bounds<=3,'description shows at most three lines')
    for _,b in ipairs(bounds)do check(b.x>=12 and b.x+b.w<=152 and b.y>=88 and b.y+8<=128,'actual entry text stays inside description box')end
    check(game.data.text.entry==text,'render leaves source text intact')
   end
   write('pokedex-'..face..'.png',canvas:newImageData():encode('png'):getString())
  end
  local stats=Entry.new(game,'CHARMANDER');stats.page=2;stats.sprite=statsSprite
  bounds={};G.setCanvas(canvas);G.origin();G.scale(6,6);stats:draw();G.setCanvas()
  check(mirrored,'stats sprite orientation matches native entry')
  check(bounds[1].x==12 and bounds[1].y==128,'stats bottom marker clears the frame')
  check(G.draw~=nil and Font.draw~=nil,'drawing hooks restored')
  write('pokedex-stats.png',canvas:newImageData():encode('png'):getString())
  write('pokedex-result.txt','PASS '..checks..' native entry GPU font, page count and description bounds checks\n')
 end,debug.traceback)
 if not ok then write('pokedex-result.txt','FAIL '..tostring(err))end
 love.event.quit(ok and 0 or 1)
end
