-- Two-pixel animated frames, drawn procedurally without image downloads.
return function(mod,palette)
 local G=love.graphics;local rectangle=G.rectangle;local shader
 return function(atlas,x,y,w,h,background)
  if not shader then shader=G.newShader([[
   extern vec2 origin;extern vec2 scale;extern vec2 size;extern float phase;extern int style;
   float hash(float n){return fract(sin(n*127.1)*43758.5453);}
   vec4 effect(vec4 c,Image tex,vec2 uv,vec2 pixel){
    vec2 p=(pixel-origin)/scale;vec2 q=min(p,size-p);float edge=min(q.x,q.y);
    if(edge>=2.0||edge<0.0)discard;
    float along=p.x+p.y;float wave=.5+.5*sin(along*.2-phase*3.0);
    vec3 ink=vec3(.02);float shine=pow(max(0.0,sin(along*.07-phase)),12.0);
    if(style==0)ink=mix(vec3(.008,.009,.013),vec3(.3,.33,.4),shine*.7+wave*.15);
    else if(style==1){float fire=.5+.5*sin(along*.45-phase*7.0+sin(along*.17+phase*3.0));ink=mix(vec3(.35,.008,.025),vec3(1.0,.22,.025),fire);}
    else if(style==2){float leaf=pow(.5+.5*sin(along*.65-phase*2.0),4.0);ink=mix(vec3(.035,.22,.035),vec3(.42,.86,.12),leaf*.7+wave*.3);}
    else if(style==3){float facet=abs(fract(along*.13-phase*.12)*2.0-1.0);ink=mix(vec3(.015,.23,.16),vec3(.3,1.0,.65),facet*.6+shine*.4);}
    else if(style==4){float bolt=step(.7,sin(along*.8+sin(along*.3-phase*5.0)*2.0-phase*8.0));ink=mix(vec3(.55,.29,.01),vec3(1.0,.98,.4),bolt*.85+shine*.15);}
    else{float cell=floor(along/6.0);float spark=pow(max(0.0,sin(phase*3.0+hash(cell)*6.28)),24.0);ink=mix(vec3(.2,.42,.65),vec3(.68,.9,1.0),wave*.6);ink=mix(ink,vec3(1.0),spark);}
    float bevel=edge<.65?1.2:edge>1.35?.6:1.0;
    return vec4(ink*bevel,c.a);
   }
  ]])end
  G.push('all');G.setShader()
  palette.paint(background or{1,1,1,1},rectangle,'fill',x,y,w,h)
  local ax,ay=G.transformPoint(x,y);local bx,by=G.transformPoint(x+1,y+1)
  local canvas=G.getCanvas();local dpi=canvas and canvas:getDPIScale()or G.getDPIScale()
  shader:send('origin',{ax*dpi,ay*dpi});shader:send('scale',{math.max(.0001,(bx-ax)*dpi),math.max(.0001,(by-ay)*dpi)});shader:send('size',{w,h})
  local speeds=mod.exports.animationSpeeds;local speed=speeds and speeds.get('border',atlas.selection,100)or 100
  shader:send('phase',love.timer.getTime()*speed/100);shader:send('style',atlas.thin)
  G.setShader(shader);G.setColor(1,1,1,1);rectangle('fill',x,y,w,h);G.pop();return true
 end
end
