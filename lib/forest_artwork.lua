-- Original animated tree/grass silhouettes shared by paper and frames.
local M={names={'EMERALD FOREST','WINDY GRASSLAND','MIDNIGHT PINES','BAMBOO GROVE','FERN WAVES','CLOVER DRIFT','FIREFLY MEADOW','JUNGLE VINES','RAINY WOODLAND','MOSSY GLADE'}}
M.glsl=[[
 float forestEdge(float d){return 1.0-smoothstep(0.0,.035,d);}
 vec3 forestArtwork(vec2 p,float t,int kind){
  vec2 q=mod(p*vec2(3.0,2.0)+vec2(.12*sin(t*.15),0.0),2.0)-1.0;
  float wind=sin(t*.65+p.x*2.0)*.08;float leaf=0.0,trunk=0.0,light=0.0;
  if(kind==0 || kind==2 || kind==8){
   float x=q.x-wind*(1.0-q.y);
   trunk=forestEdge(abs(x)-.055)*step(-.1,q.y);
   if(kind==2)leaf=forestEdge(abs(x)-(.65+q.y*.7))*step(-.75,q.y)*step(q.y,.65);
   else leaf=forestEdge(length(vec2(x,q.y+.3)*vec2(1.1,1.25))-.62);
   if(kind==8)light=step(.985,sin(p.x*37.0+t*.2))*step(.4,fract(p.y*4.0-t*.4));
  }else if(kind==3){
   float x=q.x-wind;trunk=forestEdge(abs(x)-.07);
   leaf=forestEdge(abs(q.y+sin(x*5.0)*.18)-.055)*step(abs(x),.7);
  }else if(kind==4 || kind==7){
   float stem=sin(p.y*4.0+t*.25)*.16;trunk=forestEdge(abs(q.x-stem)-.035);
   vec2 f=vec2(abs(q.x-stem)-.26,mod(q.y+q.x*.5,.42)-.21);
   leaf=forestEdge(abs(f.x)*.5+abs(f.y)-.13);
  }else if(kind==5){
   vec2 f=q-vec2(wind,0.0);leaf=forestEdge(length(abs(f)-vec2(.22))-.24);
   trunk=forestEdge(abs(f.x)-.025)*step(0.0,f.y);
  }else{
   float blade=mod(p.x*12.0+sin(p.y*3.0+t*.65)*.45,2.0)-1.0;
   leaf=forestEdge(abs(blade)-.16*(1.0+q.y))*step(-.8,q.y);
   if(kind==9)leaf=max(leaf,forestEdge(length(q-vec2(wind,.45))-.45));
   if(kind==6)light=pow(max(0.0,sin(p.x*17.0+t*.3)*cos(p.y*19.0-t*.25)),28.0);
  }
  float shade=.7+.3*sin(p.y*2.0+t*.2+float(kind));
  vec3 base=vec3(.008,.035,.015)+vec3(.008,.035,.012)*(.5+.5*sin(p.y+t*.1));
  return base+vec3(.055,.28,.09)*leaf*shade+vec3(.04,.09,.025)*trunk+vec3(.28,.4,.06)*light;
 }
]]
return M
