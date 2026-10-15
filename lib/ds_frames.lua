-- Native 6x3 DS message frame: two left tiles, one repeating tile,
-- three right tiles. Cache geometry; never squeeze corner decorations.
return function(mod,paint)
 local G=love.graphics;local M={}
 function M.draw(atlas,x,y,w,h,background)
  if not atlas.dsImage then
   local d=love.image.newImageData(love.filesystem.newFileData(mod:read(atlas.path),'frame.png'))
   local paper=love.image.newImageData(48,24)
   -- Palette zero is the transparent exterior in the source indexed PNG.
   -- Seed the actual interior tile (column 2), not a left decoration.
   local mask,queue={},{}
   local function add(px,py)
    if px<0 or py<0 or px>=48 or py>=24 then return end
    local k=py*48+px;if mask[k]then return end
    local a,b,c,v=d:getPixel(px,py)
    if v>0 and math.min(a,b,c)>.75 and math.max(a,b,c)-math.min(a,b,c)<.05 then mask[k]=true;queue[#queue+1]={px,py}end
   end
   for py=8,15 do for px=16,23 do add(px,py)end end
   local i=1;while i<=#queue do local p=queue[i];i=i+1;add(p[1]-1,p[2]);add(p[1]+1,p[2]);add(p[1],p[2]-1);add(p[1],p[2]+1)end
   for k in pairs(mask)do local px,py=k%48,math.floor(k/48);local _,_,_,a=d:getPixel(px,py);paper:setPixel(px,py,1,1,1,a);d:setPixel(px,py,0,0,0,0)end
   atlas.dsImage=G.newImage(d);atlas.dsPaper=G.newImage(paper)
   atlas.dsImage:setFilter('nearest','nearest');atlas.dsPaper:setFilter('nearest','nearest');atlas.meshes={}
  end
  local key=w..':'..h;local mesh=atlas.meshes[key]
  if not mesh then
   local vertices={};local scale=math.min(1,w/48,h/24);local left,right,edge=16*scale,24*scale,8*scale
   local function quad(dx,dy,dw,dh,sx,sy,sw,sh)
    local a={dx,dy,sx/48,sy/24};local b={dx+dw,dy,(sx+sw)/48,sy/24};local c={dx+dw,dy+dh,(sx+sw)/48,(sy+sh)/24};local d={dx,dy+dh,sx/48,(sy+sh)/24}
    for _,v in ipairs({a,b,c,a,c,d})do vertices[#vertices+1]=v end
   end
   for row=0,2 do
    local yy=row==0 and 0 or row==1 and edge or h-edge
    local hh=row==1 and h-2*edge or edge
    if row==1 then
     for yy2=yy,yy+hh-.001,edge do local height=math.min(edge,yy+hh-yy2);quad(0,yy2,left,height,0,8,16,height/scale);quad(w-right,yy2,right,height,24,8,24,height/scale)end
     quad(left,yy,w-left-right,hh,16,8,8,8)
    else
     quad(0,yy,left,hh,0,row*8,16,8);quad(w-right,yy,right,hh,24,row*8,24,8)
     for xx=left,w-right-.001,edge do local width=math.min(edge,w-right-xx);quad(xx,yy,width,hh,16,row*8,width/scale,8)end
    end
   end
   mesh=G.newMesh(vertices,'triangles','static');atlas.meshes[key]=mesh
  end
  G.push('all');G.setShader();G.setColor(1,1,1,1)
  mesh:setTexture(atlas.dsPaper);paint(background or{1,1,1,1},G.draw,mesh,x,y)
  G.setShader();G.setColor(1,1,1,1);mesh:setTexture(atlas.dsImage);G.draw(mesh,x,y);G.pop();return true
 end
 return M
end
