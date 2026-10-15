-- Native grayscale sheets need white highlights kept separate from paper.
return function(mod)
 if mod.generation~=1 then return end
 local Class=require('src.ui.TrainerCard');local G=love.graphics
 local original=Class.draw;local image
 local function sheet()
  if image then return image end
  local data=require('src.render.Assets').imageData('assets/generated/trainer_card/badges.png'):clone()
  local w,h=data:getDimensions()
  for top=0,h-1,16 do
   local seen,queue={},{};local head=1
   local function visit(x,y)
    if x<0 or x>=w or y<top or y>=math.min(h,top+16)then return end
    local id=y*w+x;if seen[id]then return end
    local r,g,b,a=data:getPixel(x,y)
    if a==0 or math.min(r,g,b)>.98 then seen[id]=true;queue[#queue+1]=id end
   end
   for x=0,w-1 do visit(x,top);visit(x,math.min(h-1,top+15))end
   for y=top,math.min(h-1,top+15)do visit(0,y);visit(w-1,y)end
   while head<=#queue do local id=queue[head];head=head+1;local x,y=id%w,math.floor(id/w);visit(x-1,y);visit(x+1,y);visit(x,y-1);visit(x,y+1)end
   for y=top,math.min(h-1,top+15)do for x=0,w-1 do
    local r,g,b,a=data:getPixel(x,y);data:setPixel(x,y,r,g,b,seen[y*w+x]and 0 or 1)
   end end
  end
  image=G.newImage(data);image:setFilter('nearest','nearest');data:release();return image
 end
 Class.draw=function(self,...)
  local api=mod.exports.menuSurfaces
  if not api or not api.enabled()then return original(self,...)end
  local draw=G.draw
  G.draw=function(img,...)
   if api.custom('trainerCard')and self.frame and img==self.frame.img then return end
   if self.faces and img==self.faces.img then
    G.push('all');G.setShader();G.setColor(1,1,1,1)
    local out={pcall(draw,sheet(),...)};G.pop()
    if not out[1]then error(out[2],0)end;return (unpack or table.unpack)(out,2)
   end
   return draw(img,...)
  end
  local out={pcall(original,self,...)};G.draw=draw
  if not out[1]then error(out[2],0)end;return (unpack or table.unpack)(out,2)
 end
 local frame=Class.frameBox
 Class.frameBox=function(self,...)
  local api=mod.exports.menuSurfaces
  if api and api.enabled()and api.custom('trainerCard')then return require('src.render.Font').drawBox(...)end
  return frame(self,...)
 end
end
