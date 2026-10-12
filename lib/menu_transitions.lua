-- Short, draw-only transitions: input and game state remain on the native stack.
local M={names={'INSTANT','FADE','SLIDE/FADE','RETRO POP','CRT POWER','LINK CABLE','POKEBALL IRIS','TILE WIPE','PSYCHIC SWIRL'}}
function M.sample(style,p,w,h)
 p=math.max(0,math.min(1,p));local e=1-(1-p)^3
 local t={sx=1,sy=1,dx=0,dy=0,rotation=0}
 if p>=1 then return t end
 if style==4 then t.sx=.75+.25*e+.06*math.sin(p*math.pi*3)*(1-p);t.sy=t.sx
 elseif style==5 then t.sy=.015+.985*e
 elseif style==6 then t.dx=-(w or 240)*.5*(1-p)^2
 elseif style==7 then t.mask=1
 elseif style==8 then t.mask=2
 elseif style==9 then t.rotation=.22*math.sin(p*math.pi)*(1-p);t.sx=.8+.2*e;t.sy=t.sx end
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
 else {number phase=mod(floor(q.x*8.0)+floor(q.y*6.0),14.0)/14.0;visible=step(phase,progress);}
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
