-- Decorative animated paper. Sprite sheets are bundled; no downloader needed.
return function(mod)
 local M={entries={
  {key='mew_stardust',name='MEW STARDUST',pokemon='mew',style=1,a='F4E8FA',b='E7E8FC',ink='AA78C2'},
  {key='mew_tide',name='MEW PSYCHIC TIDE',pokemon='mew',style=2,a='E2F5EF',b='E6E1FA',ink='8679BD'},
  {key='mew_nebula',name='MEW NEBULA',pokemon='mew',style=1,a='211A3D',b='293D52',ink='C6A3EB'},
  {key='charmander_embers',name='CHARMANDER EMBERS',pokemon='charmander',style=3,a='FFF0DC',b='FFE3D9',ink='D38A5E'},
  {key='charmander_campfire',name='CHARMANDER CAMPFIRE',pokemon='charmander',style=3,a='30202E',b='442B31',ink='F0B77A'},
  {key='pikachu_sparks',name='PIKACHU SPARKS',pokemon='pikachu',style=4,a='FFF8D5',b='F8EBD1',ink='BA9951'},
  {key='squirtle_lagoon',name='SQUIRTLE LAGOON',pokemon='squirtle',style=5,a='DEF4FC',b='DDF5EB',ink='599BAF'},
  {key='bulbasaur_garden',name='BULBASAUR GARDEN',pokemon='bulbasaur',style=6,a='E8F5DC',b='DAF1E9',ink='6B9D75'},
  {key='gengar_haunt',name='GENGAR HAUNT',pokemon='gengar',style=7,a='292139',b='38294F',ink='BBA2D8'},
  {key='eevee_cozy',name='EEVEE COZY',pokemon='eevee',style=8,a='FAF0E2',b='F1E5D9',ink='AA8C73'},
  {key='jigglypuff_lullaby',name='JIGGLYPUFF LULLABY',pokemon='jigglypuff',style=9,a='FBE6F0',b='EEE5FB',ink='B183AE'},
  {key='dragonair_dream',name='DRAGONAIR DREAM',pokemon='dragonair',style=10,a='E4EDFD',b='EDE4FA',ink='889AC4'},
  {key='umbreon_moonlight',name='UMBREON MOONLIGHT',pokemon='umbreon',style=11,a='172A3C',b='292142',ink='DCC78B'},
  {key='snorlax_snooze',name='SNORLAX SNOOZE',pokemon='snorlax',style=12,a='E5F2EF',b='E7ECFA',ink='7C9EAA'},
  {key='acid_spiral',name='ACID SPIRAL',pokemon='mew',style=13,a='19102E',b='183C39',ink='B69AF5'},
  {key='liquid_aurora',name='LIQUID AURORA',pokemon='mew',style=14,a='102B35',b='392453',ink='7DDDBB'},
  {key='kaleido_dream',name='KALEIDO DREAM',pokemon='mew',style=15,a='281536',b='223656',ink='C696D8'},
  {key='neon_grid',name='NEON GRID',pokemon='mew',style=16,a='141E32',b='302047',ink='69CACC'},
  {key='plasma_cloud',name='PLASMA CLOUD',pokemon='mew',style=17,a='301938',b='153D45',ink='9CAAED'},
  {key='liquid_chrome',name='LIQUID CHROME',pokemon='mew',style=18,a='202B39',b='34454D',ink='A6CDD9'},
  {key='cosmic_tunnel',name='COSMIC TUNNEL',pokemon='mew',style=19,a='17192F',b='35204E',ink='A797EA'},
  {key='dream_waves',name='DREAM WAVES',pokemon='mew',style=20,a='E4E6FB',b='D9F0E9',ink='AD91CB'},
 }}
 local function rgb(hex)return{tonumber(hex:sub(1,2),16)/255,tonumber(hex:sub(3,4),16)/255,tonumber(hex:sub(5,6),16)/255}end
 M.byKey={}
 for _,e in ipairs(M.entries)do e.baseA=rgb(e.a);e.baseB=rgb(e.b);e.accent=rgb(e.ink);M.byKey[e.key]=e end
 local sheets,images
 local function sprite(key)
  if not sheets then sheets=assert(load(assert(mod:read('assets/pokemon-paper/sheets.lua'))))();images={}end
  local s=assert(sheets[key]);if not images[key]then images[key]=assert(mod.assets:image(s.image));images[key]:setFilter('nearest','nearest')end
  return s,images[key]
 end
 function M.color(key)
  local e=assert(M.byKey[key]);return{e.baseA[1],e.baseA[2],e.baseA[3],1,animation='POKEMON',pokemon=key}
 end
 function M.send(shader,key,time,fallback)
  local e=M.byKey[key];shader:send('pokeStyle',e and e.style or 0)
  if not e then if fallback then shader:send('pokeStamp',fallback)end;return end
  local s,image=sprite(e.pokemon);local frame=math.floor((time or 0)*4)%s.frames
  local box=s.ink;local w,h=box[3]-box[1],box[4]-box[2]
  shader:send('pokeStamp',image);shader:send('pokePhase',time or 0)
  shader:send('pokeBaseA',e.baseA);shader:send('pokeBaseB',e.baseB);shader:send('pokeAccent',e.accent)
  shader:send('pokeSpriteRect',{(frame%s.columns*s.width+box[1])/s.sheetWidth,(math.floor(frame/s.columns)*s.height+box[2])/s.sheetHeight,w/s.sheetWidth,h/s.sheetHeight})
  shader:send('pokeSpriteSize',{28*w/h,28})
 end
 M.glsl=[[
  extern int pokeStyle;extern float pokePhase;extern vec3 pokeBaseA;extern vec3 pokeBaseB;extern vec3 pokeAccent;
  extern Image pokeStamp;extern vec4 pokeSpriteRect;extern vec2 pokeSpriteSize;
  float paperHash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
  float paperDot(vec2 p,vec2 c,float r){return 1.0-step(r,length(p-c));}
  vec3 pokemonPaper(vec2 p){
   p=floor(p)+vec2(.5);float t=pokePhase;
   float flow=.5+.5*sin(p.x*.027+p.y*.021+t*.16);
   vec3 rgb=mix(pokeBaseA,pokeBaseB,flow);
   // Abstract paper uses the same clock and pixel grid, without Pokemon stamps.
   if(pokeStyle>=13){
    vec2 z=(p-vec2(120.0,64.0))*.035;float r=length(z);float a=atan(z.y,z.x);float v=0.0;
    if(pokeStyle==13){v=.5+.5*sin(r*7.0-a*3.0-t*.65);}
    else if(pokeStyle==14){v=.5+.5*sin(z.x*2.0+sin(z.y*2.3+t*.35)*2.5+t*.25);}
    else if(pokeStyle==15){v=.5+.5*cos(cos(a*8.0+t*.2)*r*3.0-t*.5);}
    else if(pokeStyle==16){vec2 g=abs(sin(z*3.0+vec2(t*.2,-t*.15)));v=1.0-smoothstep(.04,.18,min(g.x,g.y));}
    else if(pokeStyle==17){v=.5+(.25*sin(z.x*2.0+t*.4)+.25*cos(z.y*2.7-t*.3))*cos(r*1.5-t*.2);}
    else if(pokeStyle==18){v=.5+.5*sin(z.x*3.0+sin(z.y*3.0+t*.3)+sin(r*4.0-t*.4));v=v*v;}
    else if(pokeStyle==19){v=.5+.5*sin(log(1.0+r)*18.0-t*.8+a*.6);}
    else {v=.5+.5*sin(z.y*3.0+sin(z.x*1.5+t*.25)*1.8-t*.35);}
    rgb=mix(pokeBaseA,pokeBaseB,v);
    return mix(rgb,pokeAccent,v*.24);
   }
   // Staggered rows, uniform sprite aspect, and transparent padding excluded.
   vec2 drift=p+vec2(t*.75,0.0);float row=floor(drift.y/56.0);
   drift.x+=mod(row,2.0)*36.0;vec2 cell=floor(drift/vec2(72.0,56.0));float seed=paperHash(cell);
   vec2 d=mod(drift,vec2(72.0,56.0))-vec2(36.0,28.0);
   d-=vec2(sin(t*.42+seed*6.28)*2.0,cos(t*.55+seed*6.28)*2.0);
   vec2 q=d/pokeSpriteSize+.5;
   if(q.x>=0.0 && q.x<1.0 && q.y>=0.0 && q.y<1.0){
    vec4 stamp=Texel(pokeStamp,pokeSpriteRect.xy+q*pokeSpriteRect.zw);
    rgb=mix(rgb,mix(pokeAccent,stamp.rgb,.28),stamp.a*.23);
   }
   vec2 u=mod(p+vec2(t*.7,-t*.9),vec2(31.0,27.0))-vec2(15.5,13.5);
   float motif=0.0;
   if(pokeStyle==1){ // Psychic stardust: slowly breathing four-point stars.
    float twinkle=1.6+.6*sin(t*.8+floor(p.x/31.0)*2.0+floor(p.y/27.0));
    motif=1.0-step(twinkle,abs(u.x)+abs(u.y));
   }else if(pokeStyle==2){ // Mew's soft psychic ripples.
    float r=length(u);motif=(1.0-step(.55,abs(r-(4.0+sin(t*.6)*1.2))));
   }else if(pokeStyle==3){ // Rising tail-flame embers.
    u=mod(p+vec2(sin(t*.25)*2.0,t*2.4),vec2(29.0,25.0))-vec2(14.5,12.5);
    float flame=3.4*(1.0-(u.y+4.0)/9.0);motif=step(-4.0,u.y)*(1.0-step(5.0,u.y))*(1.0-step(flame,abs(u.x+sin(u.y*.65+t)*.8)));
   }else if(pokeStyle==4){ // Pikachu bolts, warm rather than strobing.
    float bolt=u.y<0.0?u.y*.38+1.2:u.y*.38-1.2;
    motif=(1.0-step(.7,abs(u.x-bolt)))*(1.0-step(5.0,abs(u.y)));
   }else if(pokeStyle==5){ // Squirtle bubbles and a gentle water shimmer.
    motif=1.0-step(.6,abs(length(u)-3.5));
    rgb=mix(rgb,pokeAccent,.025*(.5+.5*sin(p.y*.24-t*.5)));
   }else if(pokeStyle==6){ // Bulbasaur leaves drifting on a breeze.
    motif=1.0-step(3.2,abs(u.x*.8+u.y*.35)+abs(u.y*.7));
   }else if(pokeStyle==7){ // Gengar eyes emerging from lavender mist.
    motif=paperDot(u,vec2(-2.0,0.0),1.0)+paperDot(u,vec2(2.0,0.0),1.0);
    rgb=mix(rgb,pokeAccent,.03*(.5+.5*sin(p.x*.055+p.y*.08+t*.3)));
   }else if(pokeStyle==8){ // Eevee's soft little pawprints.
    motif=paperDot(u,vec2(0.0,1.2),1.9)+paperDot(u,vec2(-2.0,-1.5),.9)+paperDot(u,vec2(0.0,-2.5),.9)+paperDot(u,vec2(2.0,-1.5),.9);
   }else if(pokeStyle==9){ // Jigglypuff's floating eighth notes.
    motif=paperDot(u,vec2(-1.0,2.0),1.5);
    motif=max(motif,(1.0-step(.6,abs(u.x-.3)))*step(-3.0,u.y)*(1.0-step(2.0,u.y)));
    motif=max(motif,(1.0-step(.7,abs(u.y+3.0)))*step(0.0,u.x)*(1.0-step(2.5,u.x)));
   }else if(pokeStyle==10){ // Dragonair's moonlit ribbons.
    motif=(1.0-step(.6,abs(u.y-sin(u.x*.35+t*.4)*2.0)))*(1.0-step(5.5,abs(u.x)));
   }else if(pokeStyle==11){ // Umbreon's softly glowing golden rings.
    motif=1.0-step(.7,abs(length(u)-3.0));motif*=.65+.35*sin(t*.5);
   }else if(pokeStyle==12){ // Snorlax's rising Zs.
    motif=max((1.0-step(.55,abs(abs(u.y)-2.5)))*(1.0-step(2.8,abs(u.x))),
     (1.0-step(.6,abs(u.x+u.y)))*(1.0-step(2.5,abs(u.y))));
   }
   return mix(rgb,pokeAccent,clamp(motif,0.0,1.0)*.17);
  }
 ]]
 return M
end
