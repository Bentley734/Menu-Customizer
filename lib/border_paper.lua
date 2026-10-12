-- Find only the white paper connected to the centre of a 3x3 frame atlas.
-- Disconnected white highlights on the outside remain part of the border.
return function(data)
  local w,h=data:getDimensions();local mask,queue={},{}
  local function add(x,y)
    if x<0 or y<0 or x>=w or y>=h then return end
    local key=y*w+x+1;if mask[key] then return end
    local r,g,b,a=data:getPixel(x,y)
    -- Imported frames include pale grey anti-aliasing around their white paper.
    if a>0 and math.min(r,g,b)>.75 and math.max(r,g,b)-math.min(r,g,b)<.05 then
      mask[key]=true;queue[#queue+1]={x,y}
    end
  end
  for y=8,15 do for x=8,15 do add(x,y)end end
  local i=1
  while i<=#queue do
    local p=queue[i];i=i+1
    add(p[1]-1,p[2]);add(p[1]+1,p[2]);add(p[1],p[2]-1);add(p[1],p[2]+1)
  end
  return mask
end
