local root=assert(os.getenv('MENU_WORKSPACE')):gsub('\\','/')
local source=(os.getenv('MENU_SOURCE')or(root..'/.work/move-effects-audit/git-Menu-Customizer'))..'/'
function love.load()
 local ok,err=xpcall(function()
 local f=assert(io.open(source..'lib/black_artwork.lua'));local art=assert(loadstring(f:read('*a')))();f:close()
 local G=love.graphics
 local shader=G.newShader(art.glsl..[[extern int kind;extern float phase;vec4 effect(vec4 c,Image tex,vec2 uv,vec2 p){return vec4(blackArtwork((uv-.5)*vec2(3.0,2.0),phase,kind),1.0);}]])
 local tile=G.newCanvas(160,128);local image=G.newImage(love.image.newImageData(1,1))
 for _,time in ipairs({0,1.5})do
 local gallery=G.newCanvas(800,math.ceil(#art.names/5)*128);G.setCanvas(gallery);G.clear(0,0,0,1)
 for i=0,#art.names-1 do
 G.setCanvas(tile);G.clear();G.setShader(shader);shader:send('kind',i);shader:send('phase',time);G.setColor(1,1,1,1);G.draw(image,0,0,0,160,128);G.setShader()
 G.setCanvas();local d=tile:newImageData();local f=assert(io.open(root..'/.work/black-art/gpu/art-'..i..'-'..time..'.png','wb'));f:write(d:encode('png'):getString());f:close()
 G.setCanvas(gallery);G.draw(tile,i%5*160,math.floor(i/5)*128)
 end
 G.setCanvas();local f=assert(io.open(root..'/.work/black-art/gpu/gallery-'..time..'.png','wb'));f:write(gallery:newImageData():encode('png'):getString());f:close()
 end
 end,debug.traceback)
 local f=assert(io.open(root..'/.work/black-art/gpu/result.txt','w'));f:write(ok and 'PASS' or err);f:close();love.event.quit(ok and 0 or 1)
end