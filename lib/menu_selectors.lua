local M={names={'POKEBALL','UNDERLINE','ARROW','DOTS','STAR','HEART','LIGHTNING','CRESCENT','DIAMOND','FLAME','PSYCHIC EYE','SPIRAL','HIGHLIGHT'}}
local art={
 {'...11...','...11...','11111111','.111111.','..1111..','.111111.','.11..11.','11....11'},
 {'.11..11.','11111111','11111111','11111111','.111111.','..1111..','...11...','........'},
 {'....111.','...111..','..111...','.111111.','...111..','..111...','.111....','11......'},
 {'..1111..','.111....','111.....','111.....','111.....','1111....','.11111..','..1111..'},
 {'...11...','..1111..','.111111.','11111111','11111111','.111111.','..1111..','...11...'},
 {'...1....','...11...','..111...','.11111..','.111111.','11111111','11111111','.111111.'},
 {'........','..1111..','.11..11.','11.11.11','11.11.11','.11..11.','..1111..','........'},
 {'.111111.','11....11','1.1111.1','1.1..1.1','1.1.11.1','1.111..1','11.....1','.111111.'},
}
local colors={{1,.8,.2},{1,.35,.6},{.45,.85,1},{.8,.65,1},{.35,.9,.75},{1,.45,.2},{.8,.5,1},{.4,.75,1}}
function M.draw(id,x,y)
 local pixels=art[id-4];if not pixels then return end
 local G=love.graphics;G.push('all');G.setShader();G.setColor(unpack(colors[id-4]))
 for row,s in ipairs(pixels)do for col=1,8 do if s:sub(col,col)=='1'then G.rectangle('fill',x+col-1,y+row-1,1,1)end end end
 G.pop()
end
-- Integer-pixel downsample for tight native cursor columns.
function M.drawCompact(id,x,y)
 local pixels=art[id-4];if not pixels then return end
 local G=love.graphics;G.push('all');G.setShader();G.setColor(unpack(colors[id-4]))
 for row=1,6 do for col=1,6 do
  local sy=math.floor((row-.5)*8/6)+1;local sx=math.floor((col-.5)*8/6)+1
  if pixels[sy]:sub(sx,sx)=='1'then G.rectangle('fill',x+col-1,y+row-1,1,1)end
 end end
 G.pop()
end
return M
