-- Original procedural artwork: sparse colored ink over almost pure black.
local M={names={
 'BLACK SPIRAL','BLACK MANDALA','BLACK MOIRE','BLACK LOTUS','BLACK LIQUID',
 'BLACK INFINITY','BLACK PRISM','BLACK THIRD EYE','BLACK WAVE WEAVE','BLACK ORBITS',
 'BLACK POKEBALLS','BLACK UMBREON RINGS','BLACK GENGAR EYES','BLACK PIKACHU BOLTS','BLACK CHARMANDER EMBERS',
 'BLACK SQUIRTLE BUBBLES','BLACK BULBASAUR LEAVES','BLACK MEW STARS','BLACK JIGGLYPUFF NOTES','BLACK SNORLAX DREAMS'}}
M.glsl=[[
 float blackLine(float d,float w){return 1.0-smoothstep(w,w+.018,abs(d));}
 vec3 blackArtwork(vec2 p,float t,int kind){
  vec2 z=p;float r=max(length(z),.001),a=atan(z.y,z.x);float v=0.0;
  if(kind==0)v=blackLine(sin(r*14.0-a*3.0-t),.025);
  else if(kind==1)v=blackLine(r-(.52+.16*cos(a*8.0+t*.3)),.012);
  else if(kind==2)v=blackLine(sin(z.x*15.0+sin(z.y*6.0+t))*cos(z.y*13.0-t*.3),.016);
  else if(kind==3)v=blackLine(r-(.45+.22*sin(a*5.0+t*.25)),.012);
  else if(kind==4)v=blackLine(sin(z.y*9.0+sin(z.x*5.0+t)*2.0),.025);
  else if(kind==5)v=blackLine(length(vec2(z.x,z.y*1.8))-(.48+.2*cos(a*2.0-t*.3)),.012);
  else if(kind==6)v=blackLine(abs(z.x)+abs(z.y)-(.65+.08*sin(t)),.012);
  else if(kind==7){v=blackLine(length(z*vec2(.7,1.6))-.48,.012);v=max(v,blackLine(r-.12,.01));}
  else if(kind==8)v=blackLine(sin(z.x*9.0+t)*sin(z.y*9.0-t*.4),.018);
  else if(kind==9)v=blackLine(r-(.25+mod(a+t*.3,2.094)*.22),.012);
  else {
   vec2 q=mod(z+vec2(t*.07,t*.04)+1.0,2.0)-1.0;
   float d=length(q);
   if(kind==10){v=blackLine(d-.35,.012);v=max(v,blackLine(q.y,.01)*step(abs(q.x),.35));v=max(v,blackLine(d-.075,.012));}
   else if(kind==11)v=blackLine(length(q*vec2(1.0,1.45))-.3,.014);
   else if(kind==12){vec2 e=vec2(abs(q.x)-.24,q.y+.07);v=blackLine(length(e*vec2(1.0,2.0))-.13,.015)*step(-.12,q.y);}
   else if(kind==13)v=blackLine(q.x-(abs(q.y+.2)-abs(q.y-.2))*.45,.014)*step(abs(q.y),.48);
   else if(kind==14)v=pow(max(0.0,sin(q.x*29.0+sin(q.y*8.0+t))*cos(q.y*25.0-t)),22.0);
   else if(kind==15)v=blackLine(d-(.22+.04*sin(t)),.012);
   else if(kind==16){vec2 leaf=vec2(q.x+q.y*.6,q.y);v=blackLine(abs(leaf.x)*1.7+abs(leaf.y)-.4,.016);}
   else if(kind==17)v=blackLine(abs(q.x)+abs(q.y)-.25,.012)*step(min(abs(q.x),abs(q.y)),.08);
   else if(kind==18){v=blackLine(q.x-.12,.012)*step(abs(q.y),.26);v=max(v,blackLine(length((q-vec2(.03,.26))*vec2(1.0,1.8))-.09,.015));v=max(v,blackLine(q.y+.26,.012)*step(abs(q.x-.22),.1));}
   else {v=max(blackLine(q.y-.22,.012),blackLine(q.y+.22,.012))*step(abs(q.x),.22);v=max(v,blackLine(q.y+q.x,.012)*step(abs(q.x),.22));}
  }
  // Sparse pigment; most of the panel remains RGB 1/255.
  v*=.65+.35*sin(t*.4+float(kind));
  vec3 tint=kind<10?vec3(.23,.16,.31):kind==11?vec3(.34,.28,.10):kind==13?vec3(.34,.29,.09):kind==14?vec3(.34,.12,.06):kind==15?vec3(.10,.25,.32):kind==16?vec3(.11,.29,.15):vec3(.25,.16,.30);
  return vec3(.004)+tint*v;
 }
]]
return M
