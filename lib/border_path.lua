-- One closed rounded centreline. Corners use arc length, not nearest-edge
-- projection, so motion never jumps between the horizontal and vertical strips.
return {glsl=[[
 const float BORDER_PI=3.141592653589793;
 vec3 borderPath(vec2 p,vec2 size){
  float e=min(8.0,min(size.x,size.y)*.5),r=e*.5;
  float top=max(0.0,size.x-2.0*e),side=max(0.0,size.y-2.0*e);
  float arc=BORDER_PI*r*.5,total=2.0*(top+side)+4.0*arc;
  float along,depth;
  if(p.y<e && p.x>=e && p.x<=size.x-e){along=p.x-e;depth=p.y;}
  else if(p.x>size.x-e && p.y>=e && p.y<=size.y-e){along=top+arc+p.y-e;depth=size.x-p.x;}
  else if(p.y>size.y-e && p.x>=e && p.x<=size.x-e){along=top+2.0*arc+side+size.x-e-p.x;depth=size.y-p.y;}
  else if(p.x<e && p.y>=e && p.y<=size.y-e){along=2.0*top+3.0*arc+side+size.y-e-p.y;depth=p.x;}
  else{
   bool right=p.x>size.x*.5,bottom=p.y>size.y*.5;
   vec2 center=vec2(right?size.x-e:e,bottom?size.y-e:e),d=p-center;
   float angle=atan(d.y,d.x);depth=e-length(d);
   if(right && !bottom)along=top+(angle+BORDER_PI*.5)*r;
   else if(right && bottom)along=top+arc+side+angle*r;
   else if(!right && bottom)along=2.0*top+2.0*arc+side+(angle-BORDER_PI*.5)*r;
   else along=2.0*top+3.0*arc+2.0*side+(angle+BORDER_PI)*r;
  }
  return vec3(mod(along,total)/total,depth,total);
 }
 float borderRepeat(vec3 path,float pitch){return path.x*max(1.0,floor(path.z/pitch+.5))*pitch;}
 float borderWave(vec3 path,float frequency,float offset){
  float cycles=max(1.0,floor(path.z*frequency/(2.0*BORDER_PI)+.5));
  return sin(path.x*cycles*2.0*BORDER_PI+offset);
 }
]]}
