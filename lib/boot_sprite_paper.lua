-- Remove only exterior white paper from native portrait assets.
return function()
 local G=love.graphics;local cache={}
 return function(path,colors,group)
  local key=path..':'..tostring(group or 'raw');if cache[key]then return cache[key]end
  local Assets=require('src.render.Assets')
  local source=Assets.imageData(path);local data=source:clone();local w,h=data:getDimensions()
  local seen,queue={},{};local head=1
  local function visit(x,y)
   if x<0 or y<0 or x>=w or y>=h then return end
   local id=y*w+x;if seen[id]then return end
   local r,g,b,a=data:getPixel(x,y)
   if a==0 or math.min(r,g,b)>.83 then seen[id]=true;queue[#queue+1]=id end
  end
  for x=0,w-1 do visit(x,0);visit(x,h-1)end
  for y=0,h-1 do visit(0,y);visit(w-1,y)end
  while head<=#queue do local id=queue[head];head=head+1;local x,y=id%w,math.floor(id/w)
   visit(x-1,y);visit(x+1,y);visit(x,y-1);visit(x,y+1)
  end
  data:mapPixel(function(x,y,r,g,b,a)
   if seen[y*w+x]then return r,g,b,0 end
   if math.min(r,g,b)>.83 then return 1,1,1,1 end
   if colors then local c=r>.5 and colors[2]or r>.17 and colors[3]or colors[4];return c[1]/255,c[2]/255,c[3]/255,a end
   return r,g,b,a
  end)
  local image=G.newImage(data);image:setFilter('nearest','nearest');data:release();cache[key]=image;return image
 end
end
