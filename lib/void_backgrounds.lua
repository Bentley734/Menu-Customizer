-- Paint only void geometry; keep native fill options as the zero/default.
return function(mod)
 local M={};mod.exports.voidBackgrounds=M
 local G=love.graphics;local unpack=unpack or table.unpack
 local function enabled()
  local R=require('src.mods.Runtime');local chains=R.hooks and R.hooks.chains
  for _,h in ipairs(chains and chains['ui.start_menu.items']or{})do if h.owner==mod.id then return true end end
  return false
 end
 function M.choice(outdoor)
  if not enabled()then return 0 end
  return math.max(0,math.floor(tonumber(mod.options:get(outdoor and 'outdoorVoidBackgroundColor'or'indoorVoidBackgroundColor'))or 0))
 end
 function M.outdoor(def,generation)
  if generation==1 then return def and def.tileset=='OVERWORLD' end
  if generation==2 then return def and (def.environment=='TOWN'or def.environment=='ROUTE')end
  return def and require('src.core.game3.dataset').isOutdoorMapType(def.mapType)
 end
 -- Subtract map bodies (including connected neighbors) from a viewport.
 function M.subtract(w,h,bodies)
  local rects={{0,0,w,h}}
  for _,b in ipairs(bodies)do
   local nextRects={}
   for _,r in ipairs(rects)do
    local x,y=math.max(r[1],b[1]),math.max(r[2],b[2])
    local right,bottom=math.min(r[1]+r[3],b[1]+b[3]),math.min(r[2]+r[4],b[2]+b[4])
    if x>=right or y>=bottom then nextRects[#nextRects+1]=r
    else
     for _,p in ipairs({{r[1],r[2],r[3],y-r[2]},{r[1],bottom,r[3],r[2]+r[4]-bottom},{r[1],y,x-r[1],bottom-y},{right,y,r[1]+r[3]-right,bottom-y}})do
      if p[3]>0 and p[4]>0 then nextRects[#nextRects+1]=p end
     end
    end
   end
   rects=nextRects
  end
  return rects
 end
 function M.paint(n,w,h,rects,mark)
  if n<=0 or #rects==0 then return end
  local P=mod.exports.selectorPalette;local color=P.color('background',n-1)
  G.push('all')
  local ok,err=pcall(function()
   G.setColor(1,1,1,1)
   P.paint(color,function()for _,r in ipairs(rects)do G.rectangle('fill',unpack(r));if mark then mark(unpack(r))end end end,'fill',0,0,w,h)
  end)
  G.pop();if not ok then error(err,0)end
 end
 function M.rows(openPage)
  local P=mod.exports.selectorPalette;local rows={}
  for _,scope in ipairs({'indoor','outdoor'})do
   local key=scope..'VoidBackgroundColor'
   local function current()return tonumber(mod.options:get(key))or 0 end
   local function write(ctx,n)mod.exports.customization.write(ctx,{[key]=n});return false end
   local row={id='wide_'..key,label=scope:upper()..' VOID BACKGROUND',value=function()local n=current();return n==0 and'NATIVE'or P.backgroundNames[n]end,
    step=function(ctx,d)return write(ctx,(current()+(d or 1))%(#P.backgroundNames+1))end}
   P.picker(row,'menuBackground',current,write,openPage,'NATIVE');rows[#rows+1]=row
  end
  return rows
 end
 local function wrap(Class,key,fn)
  if not Class or not Class[key]or Class['_voidBackground_'..key]then return end
  Class['_voidBackground_'..key]=true;local original=Class[key];Class[key]=function(...)return fn(original,...)end
 end
 local function viewSize()
  local canvas=G.getCanvas();if canvas then return canvas:getDimensions()end
  return G.getDimensions()
 end
 function M.install()
  if mod.generation==1 then
   local World=require('src.world.OverworldController');local Tiles=require('src.render.TileRenderer')
   wrap(World,'drawWorld',function(original,self,...)
    local old=M.world;M.world=self;local result={pcall(original,self,...)};M.world=old
    if not result[1]then error(result[2],0)end;return unpack(result,2)
   end)
   wrap(Tiles,'drawWindow',function(original,self,cx,cy,w,h,...)
    local result={original(self,cx,cy,w,h,...)};local world=M.world
    if not world or not world.map then return unpack(result)end
    local n=M.choice(M.outdoor(world.map.def,1));if n==0 then return unpack(result)end
    -- Neighbor cameras are local; all void cutouts use the host camera.
    local hostX,hostY=cx,cy
    for _,nb in ipairs(world.neighbors or{})do if nb.map==self.map then hostX=cx+nb.ox;hostY=cy+nb.oy end end
    local bodies={};local function body(map,x,y)if map and map.def then local d=map.def;bodies[#bodies+1]={x-math.floor(hostX),y-math.floor(hostY),d.width*32,d.height*32}end end
    body(world.map,0,0);for _,nb in ipairs(world.neighbors or{})do body(nb.map,nb.ox,nb.oy)end
    M.paint(n,w,h,M.subtract(w,h,bodies),require('src.render.PaletteFX').markTrueColor)
    return unpack(result)
   end)
  elseif mod.generation==2 then
   local World=require('src.world.gen2.World')
   wrap(World,'drawGround',function(original,self,s,...)
    local result={original(self,s,...)};local n=M.choice(M.outdoor(self.map and self.map.def,2))
    if n>0 and self.mapImage and self.camera then
     local w,h=viewSize();local bodies={};s=s or 1
     local function body(image,x,y)if image then local iw,ih=image:getDimensions();bodies[#bodies+1]={math.floor((x-self.camera.x)*s),math.floor((y-self.camera.y)*s),iw*s,ih*s}end end
     body(self.mapImage,0,0);for _,nb in ipairs(self.neighbors or{})do body(nb.image,nb.ox,nb.oy)end
     M.paint(n,w,h,M.subtract(w,h,bodies),require('src.render.PaletteFX').markTrueColor)
    end
    return unpack(result)
   end)
  else
   local Field=require('src.core.game3.field_view');local Map=require('src.core.game3.map')
   wrap(Field,'draw',function(original,game,w,h,opts,...)
    local result={original(game,w,h,opts,...)}
    if opts and opts.actorsOnly then return unpack(result)end
    local cx,cy=Field._nativeCamX,Field._nativeCamY
    local Runtime=require('src.core.game3.runtime');local session=Runtime.getSession and Runtime.getSession()
    local def=game and game.data and game.data.maps and session and game.data.maps[session.map]
    local n=M.choice(M.outdoor(def,3))
    if n>0 and cx and cy and def and Map.worldMidAt then
     w,h=w or Field._viewW,h or Field._viewH;local rects={}
     for wy=math.floor(cy/16),math.floor((cy+h-1)/16)do
      local top=math.max(0,wy*16-cy);local bottom=math.min(h,wy*16-cy+16);local run
      local last=math.floor((cx+w-1)/16)
      for wx=math.floor(cx/16),last+1 do
       local void=false
       if wx<=last then local _,_,isVoid=Map.worldMidAt(wx,wy,def);void=isVoid end
       if void and not run then run=math.max(0,wx*16-cx)
       elseif not void and run then local right=math.min(w,wx*16-cx);rects[#rects+1]={run,top,right-run,bottom-top};run=nil end
      end
     end
     M.paint(n,w,h,rects)
    end
    return unpack(result)
   end)
  end
 end
 return M
end
