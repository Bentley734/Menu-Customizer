-- Short, draw-only transitions: input and game state remain on the native stack.
local M={names={'INSTANT','FADE','SLIDE/FADE','RETRO POP','CRT POWER','LINK CABLE','POKEBALL IRIS','TILE WIPE','PSYCHIC SWIRL','POKEBALL BOUNCE','SURF WAVE','TELEPORT','VORTEX','ORBIT','RUBBER ZOOM','PENDULUM','SPIRAL IRIS','RIPPLE BLOOM','KALEIDOSCOPE','DIAMOND PORTAL','VENETIAN DREAM','STARDUST DISSOLVE','ZIGZAG PORTAL','CHECKER PHASE'}}
function M.sample(style,p,w,h)
 p=math.max(0,math.min(1,p));local e=1-(1-p)^3
 local t={sx=1,sy=1,dx=0,dy=0,rotation=0}
 if p>=1 then return t end
 if style==4 then t.sx=.75+.25*e+.06*math.sin(p*math.pi*3)*(1-p);t.sy=t.sx
 elseif style==5 then t.sy=.015+.985*e
 elseif style==6 then t.dx=-(w or 240)*.5*(1-p)^2
 elseif style==7 then t.mask=1
 elseif style==8 then t.mask=2
 elseif style==9 then t.rotation=.22*math.sin(p*math.pi)*(1-p);t.sx=.8+.2*e;t.sy=t.sx
 elseif style==10 then t.dy=-(h or 160)*.24*math.abs(math.sin(p*math.pi*2))*(1-p);t.sx=.65+.35*e;t.sy=t.sx
 elseif style==11 then t.dx=(w or 240)*.12*math.sin(p*math.pi*2)*(1-p);t.dy=(h or 160)*.08*math.sin(p*math.pi*3)*(1-p)
 elseif style==12 then t.sx=.15+.85*e;t.sy=t.sx;t.rotation=.35*math.sin(p*math.pi*4)*(1-p)
 elseif style==13 then t.sx=.1+.9*e;t.sy=t.sx;t.rotation=-math.pi*2*(1-p)^2
 elseif style==14 then t.dx=(w or 240)*.22*math.cos(p*math.pi*4)*(1-p)^2;t.dy=(h or 160)*.2*math.sin(p*math.pi*4)*(1-p)^2;t.sx=.6+.4*e;t.sy=t.sx
 elseif style==15 then t.sx=math.max(.1,e+.22*math.sin(p*math.pi*5)*(1-p));t.sy=t.sx
 elseif style==16 then t.rotation=.65*math.sin(p*math.pi*4)*(1-p)^2;t.dy=-(h or 160)*.15*(1-p)^2
 elseif style>=17 and style<=24 then t.mask=style-14 end
 return t
end
local shader
function M.scope(style,p,box,fn,uv)
 if style<=3 or p>=1 then return fn()end
 local G=love.graphics;local t=M.sample(style,p,box.w,box.h)
 G.push('all')
 local result={pcall(function()
  local cx,cy=box.x+box.w/2,box.y+box.h/2
  G.translate(cx+t.dx,cy+t.dy);G.rotate(t.rotation);G.scale(t.sx,t.sy);G.translate(-cx,-cy)
  if t.mask then
   if not shader then shader=G.newShader([[
extern number progress;extern number kind;extern number aspect;extern vec4 region;
vec4 effect(vec4 c,Image tex,vec2 uv,vec2 pixel){
 vec2 q=(uv-region.xy)/region.zw;
 number visible=1.0;
 if(kind<1.5){vec2 d=(q-vec2(.5))*vec2(aspect,1.0);visible=step(length(d),.5*sqrt(aspect*aspect+1.0)*progress);}
 else if(kind<2.5){number phase=mod(floor(q.x*8.0)+floor(q.y*6.0),14.0)/14.0;visible=step(phase,progress);}
 else {
  vec2 d=q-vec2(.5);number radius=length(d)/.707107;number angle=atan(d.y,d.x);number phase=0.0;
  if(kind<3.5){phase=clamp(radius+.14*sin(angle*3.0-radius*16.0+progress*8.0),0.0,1.0);}
  else if(kind<4.5){phase=clamp(radius+.12*sin(radius*28.0-progress*10.0),0.0,1.0);}
  else if(kind<5.5){phase=radius*(.72+.28*abs(cos(angle*6.0+progress*4.0)));}
  else if(kind<6.5){phase=abs(d.x)+abs(d.y);}
  else if(kind<7.5){phase=fract(q.y*10.0+sin(q.x*6.283185+progress*5.0)*.12);}
  else if(kind<8.5){vec2 cell=floor(q*vec2(48.0,32.0));phase=fract(sin(dot(cell,vec2(127.1,311.7)))*43758.5453);}
  else if(kind<9.5){phase=clamp(abs(d.x)*2.0+.16*sin(q.y*37.6991+progress*8.0),0.0,1.0);}
  else {vec2 cell=floor(q*vec2(12.0,8.0));phase=mod(cell.x+cell.y,2.0)*.5+fract(q.x*12.0)*.25+fract(q.y*8.0)*.25;}
  visible=step(phase,progress);
 }
 return Texel(tex,uv)*c*visible;
}]])end
   shader:send('progress',p);shader:send('kind',t.mask);shader:send('aspect',box.w/math.max(1,box.h));shader:send('region',uv or {0,0,1,1})
   G.setShader(shader)
  end
  return fn()
 end)}
 G.pop();if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
end
return M
