-- Procedural glyphs: no sprite uploads, random state, or per-frame allocations.
return {names={'MATRIX GREEN','MATRIX CYAN','MATRIX VIOLET','MATRIX SPECTRUM','MATRIX AMBER'},glsl=[[
 float matrixHash(float x){return fract(sin(x*127.1+311.7)*43758.5453);}
 vec3 matrixRain(vec2 p,float t,int variant){
  vec2 cell=vec2(6.0,9.0),id=floor(p/cell),q=floor(mod(p,cell));
  float seed=matrixHash(id.x),speed=3.5+seed*5.0;
  float head=mod(t*speed+seed*47.0,34.0);
  float age=mod(head-id.y,34.0),trail=exp(-age*.20);
  float code=floor(t*(2.0+seed*2.0))+id.y*19.0+id.x*43.0;
  // A 4x7 alphabet with stable vertical strokes and changing crossbars.
  float bit=step(.47,matrixHash(code+q.y*7.0+q.x*23.0));
  float glyph=bit*step(q.x,3.0)*step(q.y,6.0);
  glyph=max(glyph,step(q.x,.0)*step(q.y,6.0)*step(.5,matrixHash(code)));
  float wave=.5+.5*sin(t*.32+id.x*.065+id.y*.025);
  vec3 a=vec3(.03,.72,.15),b=vec3(.22,1.0,.62);
  if(variant==1){a=vec3(.02,.35,.85);b=vec3(.10,1.0,.88);}
  if(variant==2){a=vec3(.38,.12,.95);b=vec3(1.0,.25,.70);}
  if(variant==3){a=.5+.5*cos(vec3(0.0,2.1,4.2)+t*.25+id.x*.035);b=.5+.5*cos(vec3(0.0,2.1,4.2)+t*.25+id.x*.035+1.4);}
  if(variant==4){a=vec3(.90,.20,.015);b=vec3(1.0,.85,.16);}
  vec3 ink=mix(a,b,wave);
  float lead=1.0-smoothstep(.0,1.3,age);
  return vec3(.002,.004,.008)+ink*(.025+glyph*trail*.65)+vec3(.65,.85,.72)*glyph*lead*.3;
 }
]]}
