-- Keep menu art on its native pixel grid, but rasterize text only after resize.
return function(mod,Font)
 local G=love.graphics;local unpack=unpack or table.unpack;local M={}
 local function copy(opts)
  local out={};for k,v in pairs(opts or {})do out[k]=v end
  if out.colors then
   local colors={};for k,v in pairs(out.colors)do
    if type(v)=='table' and k~='_effects' then local c={};for a,b in pairs(v)do c[a]=b end;colors[k]=c else colors[k]=v end
   end;out.colors=colors
  end
  return out
 end
 local metricsCanvas
 function M.capture(fn,metrics)
  local queue={};local draw,glyph=Font.draw,Font.drawGlyph
  local function record(printer,text,x,y,opts)
   local ax,ay=G.transformPoint(x,y)
   local bx,by=G.transformPoint(x+1,y)
   local cx,cy=G.transformPoint(x,y+1)
   queue[#queue+1]={draw=printer,text=text,x=x,y=y,opts=copy(opts),
    anchor={ax,ay},horizontal={bx-ax,by-ay},vertical={cx-ax,cy-ay},
    clip={G.getScissor()},color={G.getColor()}}
  end
  Font.draw=function(text,x,y,opts)
   record(draw,text,x,y,opts)
   if metrics then
    metricsCanvas=metricsCanvas or G.newCanvas(1,1,{dpiscale=1})
    G.push('all');G.setCanvas(metricsCanvas);G.setScissor(0,0,0,0)
    local result={pcall(draw,text,x,y,opts)};G.pop()
    if not result[1]then error(result[2],0)end
    return unpack(result,2)
   end
   return Font.measure(text,opts)
  end
  Font.drawGlyph=function(id,x,y,opts)
   record(glyph,id,x,y,opts);return Font.advance(id,opts)
  end
  local result={pcall(fn)};Font.draw,Font.drawGlyph=draw,glyph
  if not result[1]then error(result[2],0)end
  return queue
 end
 function M.draw(queue,x,y,sx,sy,dpi)
  dpi=dpi or 1
  local prior=mod.exports.fontAspect;mod.exports.fontAspect=nil
  G.push('all')
  local result={pcall(function()
   for _,item in ipairs(queue)do
    local ax,ay=unpack(item.anchor)
    local scaleX=math.sqrt((item.horizontal[1]*sx)^2+(item.horizontal[2]*sy)^2)*dpi
    local scaleY=math.sqrt((item.vertical[1]*sx)^2+(item.vertical[2]*sy)^2)*dpi
    -- Round down so labels still fit the native column and row bounds.
    local unit=math.max(1,math.floor(math.min(scaleX,scaleY)+.00001))
    local px=math.floor((x+ax*sx)*dpi+.5)/dpi
    local py=math.floor((y+ay*sy)*dpi+.5)/dpi
    G.origin();G.setShader();G.setScissor();G.setColor(unpack(item.color))
    if item.clip[1]then
     local l=math.floor((x+item.clip[1]*sx)*dpi)/dpi
     local t=math.floor((y+item.clip[2]*sy)*dpi)/dpi
     local r=math.ceil((x+(item.clip[1]+item.clip[3])*sx)*dpi)/dpi
     local b=math.ceil((y+(item.clip[2]+item.clip[4])*sy)*dpi)/dpi
     G.setScissor(l,t,r-l,b-t)
    end
    G.translate(px,py);G.scale(unit/dpi,unit/dpi)
    item.draw(item.text,0,0,item.opts)
   end
  end)}
  G.pop();mod.exports.fontAspect=prior
  if not result[1]then error(result[2],0)end
 end
 return M
end
