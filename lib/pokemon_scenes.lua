-- Pixel-scene paper: fifteen compositions, with a frozen or live clock.
return [[
 float sceneBox(vec2 p,vec2 a,vec2 b){return step(a.x,p.x)*step(a.y,p.y)*(1.0-step(b.x,p.x))*(1.0-step(b.y,p.y));}
 float sceneTree(vec2 p,float x,float y,float size){
  vec2 q=(p-vec2(x,y))/size;
  return max(step(abs(q.x),.12)*step(0.0,q.y)*step(q.y,.6),step(abs(q.x),.7-abs(q.y+.25)*.65)*step(-1.25,q.y)*step(q.y,.25));
 }
 vec3 pokemonScene(vec2 pixel){
  vec2 extent=max(pokeArea.zw,vec2(1.0));
  vec2 p=floor((pixel-pokeArea.xy)/extent*vec2(240.0,160.0));
  float t=pokePhase;int scene=pokeStyle-28;
  vec3 sky=pokeBaseA,land=pokeBaseB,light=pokeAccent;
  vec3 c=mix(sky,land,p.y/220.0);float mask=0.0;
  // Forest layers and a winding path, inspired by Hoenn's wooded routes.
  if(scene==0 || scene==4 || scene==8){
   float ridge=91.0+7.0*sin(p.x*.035);c=mix(c,land*.68,step(ridge,p.y));
   float path=1.0-step(13.0+(p.y-80.0)*.12,abs(p.x-120.0-12.0*sin(p.y*.05)));
   c=mix(c,light*.38,path*step(90.0,p.y));
   for(int i=0;i<9;i++){float x=float(i)*31.0-7.0;
    float y=65.0+paperHash(vec2(float(i),2.0))*25.0;
    c=mix(c,land*.8,sceneTree(p,x,y,20.0));
    c=mix(c,sky*.8,sceneTree(p,x+12.0,y+30.0,22.0)*step(65.0,abs(x-120.0)));
   }
   if(scene==4){
    float y=48.0+10.0*sin(p.x*.012);mask=1.0-step(1.5,abs(p.y-y));c=mix(c,light*.55,mask);
    mask=sceneBox(p,vec2(18,35),vec2(52,56))+sceneBox(p,vec2(184,22),vec2(215,47));c=mix(c,light*.45,mask);
   }
   vec2 q=mod(p+vec2(sin(t*.4)*3.0,-t*2.0),vec2(29,23));
   mask=(1.0-step(1.2,length(q-vec2(14,11))))*(.45+.35*sin(t+floor(p.x/29.0)));
   c=mix(c,scene==8?vec3(.8,.32,.34):light,mask);
  }else if(scene==1 || scene==5 || scene==12){
   float horizon=scene==12?28.0:75.0;
   c=mix(c,land,step(horizon,p.y));
   float wave=sin(p.x*.065+p.y*.4-t*1.3)+sin(p.x*.13-p.y*.22+t*.8);
   c=mix(c,light,.18*step(1.3,wave)*step(horizon,p.y));
   if(scene==1){
    mask=1.0-step(17.0,length(p-vec2(183,52)));c=mix(c,light,mask);
    c=mix(c,sky*.65,sceneBox(p,vec2(0,122),vec2(72,128))+sceneBox(p,vec2(12,125),vec2(17,160))+sceneBox(p,vec2(60,125),vec2(65,160)));
   }else if(scene==5){
    float wall=29.0+10.0*sin(p.y*.03);mask=step(p.x,wall)+step(240.0-wall,p.x);c=mix(c,light*.55,clamp(mask,0.0,1.0));
    c=mix(c,sky,sceneBox(p,vec2(8,72),vec2(18,83))+sceneBox(p,vec2(219,96),vec2(228,106)));
   }else{
    vec2 q=mod(p+vec2(sin(t*.5)*3.0,t*4.0),vec2(41,37))-vec2(20,18);
    c=mix(c,light,(1.0-step(.9,abs(length(q)-7.0)))*.6);
   }
  }else if(scene==2){
   float ridge=52.0+abs(p.x-158.0)*.63;c=mix(c,land,step(ridge,p.y));
   float lava=1.0-step(2.0+max(0.0,p.y-66.0)*.08,abs(p.x-158.0-sin(p.y*.11+t*.3)*4.0));
   c=mix(c,light,lava*step(62.0,p.y)*.8);
   vec2 q=mod(p+vec2(sin(t*.5)*4.0,t*5.0),vec2(27,31));c=mix(c,light,(1.0-step(1.2,length(q-vec2(12,15))))*.8);
  }else if(scene==3){
   float roof=22.0+18.0*abs(sin(p.x*.071));float floorY=132.0-12.0*abs(sin(p.x*.047));
   c=mix(c,sky*.55,max(1.0-step(roof,p.y),step(floorY,p.y)));
   float waterfall=sceneBox(p,vec2(180,26),vec2(201,137));
   c=mix(c,light*.7,waterfall*(.55+.2*sin(p.y*.3-t*3.0)));
   vec2 q=mod(p,vec2(39,31))-vec2(19,15);c=mix(c,light,.45*(1.0-step(1.0,abs(q.x)+abs(q.y)))*(.7+.3*sin(t)));
  }else if(scene==6){
   float hills=108.0+12.0*sin(p.x*.03);c=mix(c,light*.65,step(hills,p.y));
   for(int i=0;i<5;i++)c=mix(c,land*.8,sceneTree(p,float(i)*60.0-6.0,100.0,19.0));
   vec2 q=mod(p+vec2(t*1.6,t*-4.0),vec2(23,19))-vec2(11,9);c=mix(c,light,1.0-step(1.0,length(q)));
  }else if(scene==7){
   float clouds=.5+.5*sin(p.x*.026+t*.13)+.15*sin(p.x*.071-t*.1);
   c=mix(c,light*.65,step(99.0+clouds*14.0,p.y));
   float tower=sceneBox(p,vec2(170,54),vec2(204,137));c=mix(c,land*.55,tower);
   c=mix(c,light*.55,tower*step(6.0,mod(p.y,17.0))*.5);
   c=mix(c,sky,sceneBox(p,vec2(181,101),vec2(192,130)));
  }else if(scene==9){
   c=mix(c,land,step(91.0+8.0*sin(p.x*.035),p.y));
   float cloth=sceneBox(p,vec2(15,120),vec2(96,156));float checks=mod(floor(p.x/6.0)+floor(p.y/6.0),2.0);
   c=mix(c,mix(light*.7,land*.55,checks),cloth);
   vec2 q=mod(p+vec2(-t,0),vec2(43,33))-vec2(21,16);c=mix(c,light,(1.0-step(1.0,abs(q.y)+abs(q.x)*.5))*.35);
  }else if(scene==10 || scene==11){
   c=mix(c,light,(1.0-step(scene==11?15.0:9.0,length(p-vec2(186,31))))*.85);
   for(int i=0;i<7;i++){
    float x=float(i)*39.0;float y=106.0+paperHash(vec2(x,8))*18.0;
    mask=sceneBox(p,vec2(x,y),vec2(x+32.0,160));c=mix(c,sky*.6,mask);
    c=mix(c,light,mask*sceneBox(mod(p,vec2(16,20)),vec2(5,6),vec2(9,11))*.5);
   }
   vec2 q=mod(p+vec2(0,-t*2.0),vec2(47,37))-vec2(23,18);
   mask=scene==10?sceneBox(q,vec2(-2,-3),vec2(3,4)):1.0-step(1.0,abs(q.x)+abs(q.y));
   c=mix(c,light,mask*(.55+.2*sin(t*.7+p.x)));
  }else if(scene==13){
   float fold=.5+.5*sin(p.x*.15);c=mix(c,land,fold*.3);
   float ribbon=1.0-step(3.0,abs(p.y-28.0-11.0*sin(p.x*.035+t*.3)));c=mix(c,light,ribbon*.6);
   vec2 q=mod(p+vec2(t,t*2.0),vec2(31,27))-vec2(15,13);c=mix(c,light,(1.0-step(1.0,abs(q.x)+abs(q.y)))*.6);
  }else{
   vec2 q=mod(p+vec2(t*1.5,0),vec2(48,44));float tile=sceneBox(q,vec2(4,4),vec2(44,40));
   c=mix(c,light*.52,tile);c=mix(c,land,sceneBox(q,vec2(6,6),vec2(42,34)));
  }
  // Keep the central reading area quiet; concentrate character art at edges.
  float middle=(1.0-smoothstep(35.0,95.0,abs(p.x-120.0)))*.23;c=mix(c,sky,middle);
  vec2 pos=vec2(25.0,112.0);if(scene==3 || scene==7)pos=vec2(31.0,55.0);
  if(scene==13)pos=vec2(193.0,108.0);
  float bob=scene==3 || scene==7 || scene==12?sin(t*.7)*2.0:0.0;
  vec2 size=pokeSpriteSize*1.25;vec2 q=(p-pos-vec2(0,bob))/size;
  if(scene==14)q=(mod(p+vec2(t*1.5,0),vec2(48,44))-vec2(12,8))/vec2(24,26);
  if(q.x>=0.0 && q.x<1.0 && q.y>=0.0 && q.y<1.0){
   vec4 stamp=Texel(pokeStamp,pokeSpriteRect.xy+q*pokeSpriteRect.zw);
   c=mix(c,stamp.rgb,stamp.a*.72);
  }
  return c;
 }
]]
