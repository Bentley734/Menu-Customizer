local root=assert(os.getenv('MENU_WORKSPACE')):gsub('\\','/')..'/'
local output=root..'.work/menu-33525-gpu/'
local function read(p)local f=assert(io.open(root..'MenuCustomizer/'..p,'rb'));local b=f:read('*a');f:close();return b end
local function write(p,b)local f=assert(io.open(output..p,'wb'));f:write(b);f:close()end
function love.load()
 local ok,err=xpcall(function()
  local G=love.graphics;local options={};local time=0
  local nativeShader=G.newShader
  G.newShader=function(code,...)
   if G.validateShader then local valid,why=G.validateShader(true,code,...);assert(valid,why)end
   return nativeShader(code,...)
  end
  package.loaded['src.core.GameVersion']={get=function()return'red'end}
  local mod={generation=1,exports={},read=function(_,p)return read(p)end,options={get=function(_,k)return options[k]end},save={get=function()end},assets={image=function(_,p)return G.newImage(love.filesystem.newFileData(read(p),p))end}}
  local P=assert(loadstring(read('lib/battle_text_palette.lua')))()(mod)
  local catalog=assert(loadstring(read('lib/border_catalog.lua')))();local selection=13
  local B=assert(loadstring(read('lib/menu_borders.lua')))()(mod,function(k)return k=='menuBorder'and selection or k=='menuTheme'and 2 or 0 end,catalog,function()return true end)
  love.timer.getTime=function()return time end
  local function render(key,t,w,h,border)
   time=t;selection=border or 13
   local c=G.newCanvas(w,h);G.push('all');G.setCanvas(c);G.origin();G.setShader();G.setScissor();G.clear(0,0,0,0)
   assert(B.drawPixels(0,0,w,h,key and P.pokemonBackgrounds.color(key)or{.02,.02,.02,1}));G.pop();return c:newImageData()
  end
  for n=0,4 do
   local key='matrix_'..n;local border
   for i,e in ipairs(catalog.entries)do if e.animation=='matrix'..n then border=i end end
   local a=render(key,2,640,180,border);local b=render(key,4,640,180,border)
   assert(a:getString()~=b:getString(),'matrix motion stopped')
   local frame1=render(nil,2,640,180,border);local frame2=render(nil,4,640,180,border)
   assert(frame1:getString()~=frame2:getString(),'Matrix border does not animate independently of its background')
   write(key..'.png',a:encode('png'):getString())
   options.menu_fx_speed=50;local slow=render(key,8,640,180,border)
   assert(slow:getString()==b:getString(),'matrix speed does not follow animation controls')
   options.menu_fx_speed=100
  end
  local water=render('black_waterfall',3,1280,360)
  local later=render('black_waterfall',5,1280,360)
  for _,x0 in ipairs({12,200,600,1050,1200})do
   local bright,moving=0,0
   for y=15,280 do for x=x0,x0+40 do
    local r,g,b=water:getPixel(x,y);local r2,g2,b2=later:getPixel(x,y)
    if r+g+b>.03 then bright=bright+1 end
    if math.abs(r-r2)+math.abs(g-g2)+math.abs(b-b2)>.01 then moving=moving+1 end
   end end
   assert(bright>100 and moving>100,'waterfall missing at ultrawide x='..x0)
  end
  write('black-waterfall-32x9.png',water:encode('png'):getString())
  write('result.txt','PASS Matrix backgrounds and borders, five variants, animation speed, 32:9 waterfall edge coverage and motion\n')
 end,debug.traceback)
 if not ok then write('result.txt','FAIL '..tostring(err))end
 love.event.quit(ok and 0 or 1)
end
