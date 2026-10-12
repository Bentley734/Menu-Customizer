local root=(os.getenv('BATTLE_UI_WORKSPACE') or 'C:/Users/LSDMTHC/Desktop/Hoennto'):gsub('\\','/')..'/'
local function read(path)local f=assert(io.open(root..'MenuCustomizer/'..path,'rb'));local b=f:read('*a');f:close();return b end
local function write(path,value)local f=assert(io.open(root..'.work/animated-themes/'..path,'wb'));f:write(value);f:close()end
function love.load()
 local ok,err=xpcall(function()
  local G=love.graphics;local checks=0
  local function check(v,m)checks=checks+1;assert(v,m)end
  local catalog=assert(loadstring(read('lib/border_catalog.lua')))()
  local selection,theme,version=2,1,'red'
  package.loaded['src.core.GameVersion']={get=function()return version end}
  local mod={generation=1,exports={},read=function(_,p)return read(p)end,options={get=function()end},save={get=function()end},assets={image=function(_,p)
   return G.newImage(love.image.newImageData(love.filesystem.newFileData(read(p),p)))
  end}}
  local M=assert(loadstring(read('lib/menu_borders.lua')))()(mod,function(k)return k=='menuBorder' and selection or theme end,catalog,function()return true end)
  local mask=assert(loadstring(read('lib/border_paper.lua')))()
  local sheets=G.newCanvas(900,900);G.setCanvas(sheets);G.clear(.12,.14,.18,1);G.setCanvas()
  for i=2,#catalog.entries do
   selection=i;local atlas=M.atlas(i)
   local original=love.image.newImageData(love.filesystem.newFileData(read(catalog.entries[i].path),'border.png'))
   local image,paper=M.battleAtlas(atlas,i)
   local trimmed=G.newCanvas(24,24);G.push('all');G.setCanvas(trimmed);G.origin();G.clear(0,0,0,0);G.setColor(1,1,1,1);G.draw(image,0,0);G.pop()
   local transparent=trimmed:newImageData();local expected=mask(original)
   for y=0,23 do for x=0,23 do
    local r,g,b,a=original:getPixel(x,y);local nr,ng,nb,na=transparent:getPixel(x,y)
    if expected[y*24+x+1]then check(na==0,'paper not transparent '..i)
    else check(na==a and (a==0 or nr==r and ng==g and nb==b),'art changed '..i)end
   end end
   for _,size in ipairs({{240,48},{80,112},{129.5,47.25}})do
    local c=G.newCanvas(math.ceil(size[1]),math.ceil(size[2]));G.push('all');G.setCanvas(c);G.origin();G.clear(0,0,0,0)
    check(M.drawPixels(0,0,size[1],size[2],{0,0,0,1}),'border render '..i)
    G.pop();local r,g,b,a=c:newImageData():getPixel(12,12)
    check(r==0 and g==0 and b==0 and a==1,'custom paper not reaching frame '..i)
    if i>=49 and i<=60 and size[1]==240 then
     local n=i-49;G.setCanvas(sheets);G.setColor(1,1,1,1);G.print(catalog.entries[i].label,n%2*450+10,math.floor(n/2)*140+8)
     G.draw(c,n%2*450+10,math.floor(n/2)*140+28,0,1.75,1.75);G.setCanvas()
    end
   end
  end
  -- Default selection must be independent of the renamed display strings.
  for _,case in ipairs({{1,'red',1,40},{2,'crystal',1,41},{3,'firered',1,2},{3,'ruby',1,12},{3,'sapphire',1,12},{3,'emerald',1,12},{1,'red',2,13},{2,'crystal',2,13},{3,'ruby',2,13}})do
   mod.generation,version,theme=case[1],case[2],case[3]
   local function frame(n)
    selection=n;local c=G.newCanvas(240,48);G.push('all');G.setCanvas(c);G.origin();G.clear(0,0,0,0);check(M.drawPixels(0,0,240,48,{0,0,0,1}),'default border missing');G.pop();return c:newImageData():getString()
   end
   check(frame(1)==frame(case[4]),'default border changed after rename')
  end

  local P=assert(loadstring(read('lib/battle_text_palette.lua')))()(mod)
  local clock=0;local originalTime=love.timer.getTime;love.timer.getTime=function()return clock end
  local speed=100;mod.options.get=function(_,k)if k=='menu_fx_speed' then return speed end end
  local function render(n,t,bg)
    selection=n;clock=t;local c=G.newCanvas(520,112)
    G.push('all');G.setCanvas(c);G.origin();G.clear(0,0,0,0);G.translate(.3,.2);G.scale(2,2)
    check(M.drawPixels(0,0,259.5,55.75,bg or {.04,.055,.09,1}),'animated frame draw failed '..n)
    G.pop();return c
  end
  local samples={};local hashes={}
  for n=61,#catalog.entries do
    local first=render(n,0);local nextFrame=render(n,1.7)
    local a,b=first:newImageData(),nextFrame:newImageData()
    check(a:getString()~=b:getString(),'effect does not move: '..catalog.entries[n].label)
    for _,data in ipairs({a,b})do
      local r,g,b,alpha=data:getPixel(100,60)
      check(math.abs(r-10/255)<.005 and math.abs(g-14/255)<.005 and math.abs(b-22/255)<.005 and alpha==1,'border effect leaks into paper')
    end
    local hash=love.data.encode('string','hex',love.data.hash('sha256',a:getString()))
    check(not hashes[hash],'duplicate animated border: '..catalog.entries[n].label);hashes[hash]=true
    speed=50;local slow=render(n,2);speed=100;local normal=render(n,1)
    check(slow:newImageData():getString()==normal:newImageData():getString(),'speed setting ignored: '..n)
    samples[#samples+1]={n=n,label=catalog.entries[n].label}
  end
  -- Every custom palette works in text, paper, shadow, glow and frame uniforms.
  for _,entry in ipairs(P.gradients.entries)do
    local fg;for i,name in ipairs(P.names)do if name==entry.name then fg=P.color('text',i-1);break end end
    check(fg and fg.gradient==entry.key,'palette chooser missing '..entry.key)
    clock=0;local resolved=P.effects.resolve(fg,'menu');check(resolved.gradient==entry.key,'palette metadata lost')
    local c=G.newCanvas(200,50);local function paint(t)
      clock=t;G.push('all');G.setCanvas(c);G.origin();G.clear(0,0,0,0)
      P.effects.paint(fg,'menu',G.rectangle,'fill',0,0,200,50);G.pop();return c:newImageData():getString()
    end
    check(paint(0)~=paint(2),'palette paint not animated '..entry.key)
    local bg={1,1,1,1,animation='GRADIENT',gradient=entry.key}
    local first=render(62,0,bg);local second=render(62,2,bg)
    check(first:newImageData():getString()~=second:newImageData():getString(),'gradient paper frozen '..entry.key)
    local d=first:newImageData();local expected=P.gradients.sample(entry.key,100.5/320+60.5/640)
    local rr,gg,bb=d:getPixel(100,60)
    check(math.abs(rr-expected[1])<.01 and math.abs(gg-expected[2])<.01 and math.abs(bb-expected[3])<.01,'paper uses wrong gradient stops '..entry.key)
  end
  local function gallery(t)
    local canvas=G.newCanvas(1100,1280);G.setCanvas(canvas);G.origin();G.clear(.045,.055,.09,1);G.setCanvas()
    for i,sample in ipairs(samples)do
      local x,y=(i-1)%2*550+14,math.floor((i-1)/2)*155+12
      local c=render(sample.n,t)
      G.push('all');G.setCanvas(canvas);G.origin();G.setShader();G.setColor(.84,.89,.96,1)
      G.print(sample.label,x,y);G.setColor(1,1,1,1);G.draw(c,x,y+25);G.pop()
    end
    return canvas:newImageData():encode('png'):getString()
  end
  for i=0,23 do write('frame-'..i..'.png',gallery(i/6))end
  write('animated-border-preview.png',gallery(1.3))
  love.timer.getTime=originalTime
  local bytes=sheets:newImageData():encode('png'):getString();write('new-borders.png',bytes)
  write('gpu-result.txt','PASS '..checks..' border art, animated effects, distinct palettes, speed and paper-isolation GPU checks\n')
 end,debug.traceback)
 if not ok then write('gpu-result.txt','FAIL '..err)end
 love.event.quit(ok and 0 or 1)
end
