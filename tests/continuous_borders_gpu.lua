local root=assert(os.getenv('MENU_FIX_SOURCE')):gsub('\\','/')
local out=assert(os.getenv('MENU_FIX_OUTPUT')):gsub('\\','/')
local function read(p)local f=assert(io.open(root..'/'..p,'rb'));local s=f:read('*a');f:close();return s end
local function write(p,s)local f=assert(io.open(out..'/'..p,'wb'));f:write(s);f:close()end
function love.load()
 local ok,err=xpcall(function()
  local G=love.graphics;local checks=0
  local function check(v,m)checks=checks+1;assert(v,m)end
  local Path=assert(loadstring(read('lib/border_path.lua')))()
  local probe=G.newShader(Path.glsl..[[extern vec2 point;extern vec2 span;
   vec4 effect(vec4 c,Image tex,vec2 uv,vec2 pixel){vec3 p=borderPath(point,span);return vec4(p.x,p.y/8.0,p.z/1000.0,1.0);} ]])
  local white=G.newImage(love.image.newImageData(1,1));local target=G.newCanvas(1,1,{format='rgba32f',dpiscale=1})
  for _,size in ipairs({{240,64},{129.5,47.25},{80,112}})do
   local w,h=size[1],size[2];local top,side,arc=w-16,h-16,2*math.pi
   local total=2*(top+side)+4*arc
   local segments={
    {top,function(t)return 8+t*top,4 end},
    {arc,function(t)local a=-math.pi/2+t*math.pi/2;return w-8+4*math.cos(a),8+4*math.sin(a)end},
    {side,function(t)return w-4,8+t*side end},
    {arc,function(t)local a=t*math.pi/2;return w-8+4*math.cos(a),h-8+4*math.sin(a)end},
    {top,function(t)return w-8-t*top,h-4 end},
    {arc,function(t)local a=math.pi/2+t*math.pi/2;return 8+4*math.cos(a),h-8+4*math.sin(a)end},
    {side,function(t)return 4,h-8-t*side end},
    {arc,function(t)local a=-math.pi+t*math.pi/2;return 8+4*math.cos(a),8+4*math.sin(a)end}}
   local distance=0
   for _,seg in ipairs(segments)do for i=1,19 do
    local t=i/20;local x,y=seg[2](t)
    G.setCanvas(target);G.origin();G.setShader(probe);probe:send('point',{x,y});probe:send('span',{w,h});G.draw(white);G.setShader();G.setCanvas()
    local u,depth,p=target:newImageData():getPixel(0,0)
    check(math.abs(u-(distance+t*seg[1])/total)<.00001,'continuous arc length through every corner')
    check(math.abs(depth-.5)<.00001,'constant strip thickness')
    check(math.abs(p*1000-total)<.001,'closed perimeter')
   end;distance=distance+seg[1]end
  end
  package.loaded['src.core.GameVersion']={get=function()return 'firered'end}
  local catalog=assert(loadstring(read('lib/border_catalog.lua')))()
  local selection,time=1,0;local oldTime=love.timer.getTime;love.timer.getTime=function()return time end
  local mod={generation=1,exports={},read=function(_,p)return read(p)end,options={get=function()end},save={get=function()end},assets={image=function(_,p)return G.newImage(love.filesystem.newFileData(read(p),p))end}}
  local B=assert(loadstring(read('lib/menu_borders.lua')))()(mod,function(k)return k=='menuBorder'and selection or 0 end,catalog,function()return true end)
  local seen={};local sheet=G.newCanvas(1000,900,{dpiscale=1});G.setCanvas(sheet);G.clear(.06,.07,.1,1);G.setCanvas()
  local n=0
  for i,e in ipairs(catalog.entries)do if e.animation and not seen[e.animation]then
   seen[e.animation]=true;selection=i;n=n+1
   for _,size in ipairs({{240,64},{129.5,47.25},{80,112}})do
    local c=G.newCanvas(math.ceil(size[1]),math.ceil(size[2]),{dpiscale=1})
    for _,phase in ipairs({0,2.1,8.7})do time=phase
     G.setCanvas(c);G.origin();G.clear(0,0,0,0);B.drawPixels(0,0,size[1],size[2],{0,0,0,0});G.setCanvas()
     local data=c:newImageData()
     for _,point in ipairs({{5,5},{size[1]-6,5},{size[1]-6,size[2]-6},{5,size[2]-6},{size[1]/2,4},{size[1]-5,size[2]/2},{size[1]/2,size[2]-5},{4,size[2]/2}})do
      local _,_,_,a=data:getPixel(math.floor(point[1]),math.floor(point[2]));check(a>.99,'solid connected animated corner/edge '..e.animation)
     end
    end
    if size[1]==240 then
     G.setCanvas(sheet);G.setColor(1,1,1,1);G.print(e.label,(n-1)%2*500+15,math.floor((n-1)/2)*110+8)
     G.draw(c,(n-1)%2*500+15,math.floor((n-1)/2)*110+28,0,1.9,1);G.setCanvas()
    end
   end
  end end
  love.timer.getTime=oldTime
  write('continuous-borders.png',sheet:newImageData():encode('png'):getString())
  write('borders-result.txt','PASS '..checks..' GPU arc-length, thickness, closure and solid corner checks across '..n..' animated families\n')
 end,debug.traceback)
 if not ok then write('borders-result.txt','FAIL '..tostring(err))end
 love.event.quit(ok and 0 or 1)
end

