local M={names={'VANILLA','SOFT FADE','WHITE FADE','WIPE LEFT','WIPE RIGHT','WIPE UP','WIPE DOWN','DOUBLE DOORS','CURTAINS','CIRCLE IRIS','DIAMOND IRIS','POKEBALL CLOSE','TILE DIAGONAL','CHECKERBOARD','HORIZONTAL BLINDS','VERTICAL BLINDS','SURF WAVE','LIGHTNING CUT','PSYCHIC SPIRAL','STARDUST DISSOLVE','PIXEL RAIN','LEAF SCATTER','CRT SHUTTER','RING RIPPLE','BATTLE CLAWS','RANDOM'}}
local shader
function M.draw(style,p,w,h)
 local G=love.graphics;p=math.max(0,math.min(1,p))
 if p<=0 then return end
 if style==26 then style=2 end
 G.push('all');G.origin();G.setShader();G.setScissor();G.setBlendMode('alpha');G.setColor(1,1,1,1)
 if style==2 or style==3 then
  G.setColor(style==3 and 1 or 0,style==3 and 1 or 0,style==3 and 1 or 0,p)
 else
  if not shader then shader=G.newShader([[
extern float progress;extern float kind;extern vec2 extent;
float hash(vec2 c){return fract(sin(dot(c,vec2(127.1,311.7)))*43758.5453);}
vec4 effect(vec4 c,Image tex,vec2 uv,vec2 pixel){
 vec2 q=clamp(pixel/extent,0.0,1.0);vec2 d=q-vec2(.5);
 float a=extent.x/max(1.0,extent.y);vec2 z=d*vec2(a,1.0);
 float radius=length(z)/(.5*sqrt(a*a+1.0));float phase=q.x;
 if(kind<4.5)phase=q.x;
 else if(kind<5.5)phase=1.0-q.x;
 else if(kind<6.5)phase=q.y;
 else if(kind<7.5)phase=1.0-q.y;
 else if(kind<8.5)phase=1.0-abs(d.x)*2.0;
 else if(kind<9.5)phase=abs(d.x)*2.0;
 else if(kind<10.5)phase=1.0-radius;
 else if(kind<11.5)phase=1.0-(abs(d.x)+abs(d.y));
 else if(kind<12.5){float ball=1.0-radius;float seam=1.0-abs(d.y)*2.0;phase=mix(ball,seam,.18);}
 else if(kind<13.5)phase=(floor(q.x*18.0)+floor(q.y*12.0))/30.0;
 else if(kind<14.5)phase=mod(floor(q.x*16.0)+floor(q.y*12.0),2.0)*.5+fract(q.x*16.0)*.5;
 else if(kind<15.5)phase=fract(q.y*12.0);
 else if(kind<16.5)phase=fract(q.x*16.0);
 else if(kind<17.5)phase=q.y+.09*sin(q.x*18.85-progress*8.0);
 else if(kind<18.5)phase=q.x+.1*sin(q.y*45.0)+.05*sin(q.y*99.0);
 else if(kind<19.5)phase=radius+.12*sin(atan(z.y,z.x)*5.0-radius*22.0);
 else if(kind<20.5)phase=hash(floor(q*vec2(48.0,32.0)));
 else if(kind<21.5)phase=q.y*.75+hash(vec2(floor(q.x*30.0),0.0))*.25;
 else if(kind<22.5)phase=hash(floor(q*vec2(16.0,12.0)))*.7+fract(q.x*16.0+q.y*12.0)*.3;
 else if(kind<23.5)phase=abs(d.y)*2.0;
 else if(kind<24.5)phase=radius+.08*sin(radius*40.0);
 else phase=q.x+.15*sin(floor(q.y*5.0)*2.0)+.1*fract(q.y*5.0);
 float covered=1.0-smoothstep(progress-.015,progress+.015,clamp(phase,.001,.999));
 if(progress>=.9999)covered=1.0;
 return vec4(0.0,0.0,0.0,covered*c.a);
}]])end
  shader:send('progress',p);shader:send('kind',style);local canvas=G.getCanvas and G.getCanvas()
  local dpi=canvas and canvas.getDPIScale and canvas:getDPIScale()or G.getDPIScale and G.getDPIScale()or 1
  shader:send('extent',{w*dpi,h*dpi});G.setShader(shader)
 end
 G.rectangle('fill',0,0,w,h);G.pop()
end
return M
