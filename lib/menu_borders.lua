-- All generations use 8x8 frame tiles. Public GB calls include their border;
-- Game3 calls name the interior. Convert once here, never stretch corner art.
return function(mod,setting,catalog,active)
 local G=love.graphics
 local M={atlases={}}
 local palette=assert(load(assert(mod:read('lib/battle_text_palette.lua'))))()(mod)
 local function paint(c,fn,...)return palette.paint(c,fn,...)end
 local function selection(scope)
  local gb=mod.exports.gbMenus
  scope=scope or M.scope or mod.exports.menuPaperScope or (gb and gb.drawScope and gb.paperGroup)or (gb and gb.dialogueScope and 'dialogue')or 'other'
  local n=setting(scope..'BorderChoice')or 0
  return n>0 and n or setting('menuBorder')
 end
 function M.atlas(selection)
  local entry=catalog.entries[selection]
  if not entry or not entry.path then return nil end
  if M.atlases[selection] then return M.atlases[selection] end
  local image=mod.assets:image(entry.path)
  image:setFilter('nearest','nearest')
  local w,h=image:getDimensions()
  assert(w==24 and h==24,'Menu Customizer: invalid border atlas '..entry.path)
  local atlas={image=image,quads={},animation=entry.animation,gradient=entry.gradient,pokemonMotif=entry.pokemonMotif}
  for n=0,8 do atlas.quads[n]=G.newQuad(n%3*8,math.floor(n/3)*8,8,8,w,h) end
  M.atlases[selection]=atlas
  return atlas
 end
 -- Battle-only transparent paper masks, leaving the shared menu atlas intact.
 function M.battleAtlas(atlas,selection)
  if atlas.battleImage then return atlas.battleImage,atlas.paperImage end
  if not (love.image and love.image.newImageData and love.filesystem and G.newImage) then return atlas.image end
  local source=mod:read(catalog.entries[selection].path)
  local data=love.image.newImageData(love.filesystem.newFileData(source,'border.png'))
  local mask=assert(load(assert(mod:read('lib/border_paper.lua'))))()(data)
  local paper=love.image.newImageData(24,24)
  for key in pairs(mask)do
    local x,y=(key-1)%24,math.floor((key-1)/24)
    local _,_,_,a=data:getPixel(x,y)
    paper:setPixel(x,y,1,1,1,a);data:setPixel(x,y,0,0,0,0)
  end
  atlas.battleImage=G.newImage(data);atlas.paperImage=G.newImage(paper)
  atlas.battleImage:setFilter('nearest','nearest');atlas.paperImage:setFilter('nearest','nearest')
  if data.release then data:release()end;if paper.release then paper:release()end
  return atlas.battleImage,atlas.paperImage
 end
 -- Duplicate each cell's boundary into a one-pixel gutter. Fractional
 -- transforms can sample just outside a quad; adjacent corner art must never
 -- bleed into an edge tile or its paper. Keep the public 24px atlas intact.
 local function renderAtlas(atlas,selection,trim)
  if not (love.image and love.image.newImageData and love.filesystem and G.newImage) then
   local image,paper=atlas.image,nil
   if trim then image,paper=M.battleAtlas(atlas,selection)end
   return image,paper,atlas.quads,24
  end
  atlas.padded=atlas.padded or {};local key=trim and 'trim' or 'plain'
  local cached=atlas.padded[key]
  if cached then return cached.image,cached.paper,cached.quads,30 end
  local source=love.image.newImageData(love.filesystem.newFileData(mod:read(catalog.entries[selection].path),'border.png'))
  local mask=trim and assert(load(assert(mod:read('lib/border_paper.lua'))))()(source)
  local data=love.image.newImageData(30,30);local paper=trim and love.image.newImageData(30,30) or nil
  local quads={}
  for n=0,8 do
   local tx,ty=n%3,math.floor(n/3)
   quads[n]=G.newQuad(tx*10+1,ty*10+1,8,8,30,30)
   for py=0,9 do for px=0,9 do
    local sx,sy=tx*8+math.max(0,math.min(7,px-1)),ty*8+math.max(0,math.min(7,py-1))
    local r,g,b,a=source:getPixel(sx,sy);local x,y=tx*10+px,ty*10+py
    if mask and mask[sy*24+sx+1] then data:setPixel(x,y,0,0,0,0);paper:setPixel(x,y,1,1,1,a)
    else data:setPixel(x,y,r,g,b,a)end
   end end
  end
  cached={image=G.newImage(data),paper=paper and G.newImage(paper),quads=quads}
  cached.image:setFilter('nearest','nearest');if cached.paper then cached.paper:setFilter('nearest','nearest')end
  atlas.padded[key]=cached
  for _,d in ipairs({source,data,paper})do if d.release then d:release()end end
  return cached.image,cached.paper,cached.quads,30
 end
 local Path=assert(load(assert(mod:read('lib/border_path.lua'))))()
 local gradientShader
 local panelShader
 -- One quad owns the entire frame. Slice the texture in the fragment shader,
 -- rather than rasterising hundreds of separately transformed edge quads.
 -- This removes shared geometry edges as well as neighbouring atlas samples.
 local function wholePanel(atlas,image,paper,x,y,w,h,background)
  if not G.newShader then return false end
  if not panelShader then panelShader=G.newShader(Path.glsl..palette.gradients.glsl..palette.pokemonBackgrounds.glsl..palette.gradients.glsl:gsub('customGradient','paperCustomGradient'):gsub('stopA','paperStopA'):gsub('stopB','paperStopB'):gsub('stopC','paperStopC'):gsub('stopD','paperStopD'):gsub('gradientColor','paperGradientColor')..[[
   extern vec2 extent;extern bool usePaper;extern Image paperTexture;
   extern vec4 paperColor;extern bool paperGradient;extern float paperPhase;
   extern bool rainbow;extern float phase;extern int borderEffect;extern float pokemonMotif;
   vec3 hue(float h){return clamp(abs(fract(h+vec3(0.0,2.0/3.0,1.0/3.0))*6.0-3.0)-1.0,0.0,1.0);}
   vec4 effect(vec4 color,Image tex,vec2 uv,vec2 pixel){
    vec2 p=uv*extent;vec2 edge=min(vec2(8.0),extent*.5);
    vec2 cell=vec2(p.x<edge.x?0.0:p.x>=extent.x-edge.x?2.0:1.0,
                   p.y<edge.y?0.0:p.y>=extent.y-edge.y?2.0:1.0);
    vec2 start=vec2(cell.x<.5?0.0:cell.x>1.5?extent.x-edge.x:edge.x,
                    cell.y<.5?0.0:cell.y>1.5?extent.y-edge.y:edge.y);
    vec2 localPixel=mod(p-start,8.0);
    if(cell.x==1.0 && cell.y==1.0)
     localPixel=(p-edge)/max(vec2(.0001),extent-2.0*edge)*8.0;
    vec2 coord=(cell*10.0+vec2(1.5)+clamp(floor(localPixel),vec2(0.0),vec2(7.0)))/30.0;
    vec4 ink=Texel(tex,coord);
    if(usePaper){vec4 paper=Texel(paperTexture,coord);
     if(paper.a>0.0 && !((rainbow || borderEffect>0) && (cell.x!=1.0 || cell.y!=1.0))){vec3 rgb=pokeStyle>0?pokemonPaper(p):paperGradient?paperGradientColor(paperPhase+pixel.x/320.0+pixel.y/640.0):paperColor.rgb;
      return vec4(rgb,paper.a*paperColor.a*color.a);}}
    vec3 path=borderPath(p,extent);float depth=path.y;
    float along=path.x*path.z;
    bool animated=rainbow || borderEffect>0;
    if(animated && (cell.x!=1.0 || cell.y!=1.0))ink.a=depth>=0.0?1.0:0.0;
    float bevel=animated?.6+.4*(1.0-abs(depth-4.0)/4.0):(.35+.65*ink.r);
    vec3 rgb=rainbow?gradientColor(phase+path.x)*bevel:ink.rgb;
    if(borderEffect>0){
     float s=borderRepeat(path,16.0)-phase*96.0;
     if(borderEffect==1){
      rgb=vec3(.12,.17,.27)*bevel;
      vec2 d=vec2(mod(s+8.0,16.0)-8.0,depth-4.0);float radius=length(d);
      float spin=phase*32.0;vec2 q=vec2(cos(spin)*d.x-sin(spin)*d.y,sin(spin)*d.x+cos(spin)*d.y);
      if(radius<3.45){rgb=radius>2.8?vec3(.035):q.y<0.0?vec3(.94,.16,.22):vec3(.92,.96,1.0);
       if(abs(q.y)<.48)rgb=vec3(.035);if(radius<1.1)rgb=vec3(.035);if(radius<.55)rgb=vec3(.83,.9,.98);}
     }else if(borderEffect==2){
      float zig=4.0+1.9*(abs(mod(borderRepeat(path,2.0/.18)*.18+phase*3.0,2.0)-1.0)*2.0-1.0);
      float bolt=abs(depth-zig);rgb=vec3(.025,.08,.22)*bevel;
      rgb+=vec3(.13,.27,.43)*max(0.0,1.0-bolt/2.0);
      if(bolt<.8)rgb=vec3(1.0,.82,.26);if(bolt<.3)rgb=vec3(1.0,.99,.85);
     }else if(borderEffect==3){
      float wave=3.8+1.4*borderWave(path,.24,-phase*25.0)+.6*borderWave(path,.53,phase*13.0);
      rgb=mix(vec3(.035,.19,.44),vec3(.13,.61,.77),depth/8.0)*bevel;
      if(abs(depth-wave)<.55)rgb=vec3(.69,.95,.9);else rgb+=vec3(.04,.15,.18)*max(0.0,1.0-abs(depth-wave)/2.0);
     }else if(borderEffect==4){
      float wisp=3.8+1.4*borderWave(path,.13,phase*15.0);float trail=mod(borderRepeat(path,23.0)-phase*96.0,23.0);
      float glow=exp(-abs(depth-wisp)*1.7)*exp(-trail*.18);
      rgb=vec3(.14,.06,.27)*bevel+vec3(.47,.35,.7)*glow;
      if(trail<2.0 && abs(depth-wisp)<.8)rgb=vec3(.78,.84,1.0);
     }else if(borderEffect==5){
      float star=abs(mod(borderRepeat(path,24.0)-phase*96.0+12.0,24.0)-12.0);float height=abs(depth-4.0);
      rgb=vec3(.07,.06,.2)*bevel;
      if(star+height<2.6)rgb=mix(vec3(.58,.8,1.0),vec3(1.0,.9,.56),.5+.5*borderWave(path,.2,phase*20.0));
      if(star<.65 && height<2.7 || height<.65 && star<2.7)rgb=vec3(.96,.97,1.0);
      rgb+=vec3(.12,.2,.3)*exp(-abs(depth-4.0)*2.0)*max(0.0,1.0-mod(borderRepeat(path,24.0)-phase*96.0+12.0,24.0)/12.0);
     }else if(borderEffect==6){
      float stem=4.0+.5*borderWave(path,.16,phase*8.0);float leaf=mod(borderRepeat(path,24.0),12.0)-6.0;
      float side=mod(floor(borderRepeat(path,24.0)/12.0),2.0)<1.0?1.0:-1.0;
      rgb=vec3(.045,.17,.14)*bevel;
      if(abs(depth-stem)<.55)rgb=vec3(.27,.62,.35);
      if(abs(leaf)*.5+abs(depth-stem-side*1.35)<1.7)
       rgb=mix(vec3(.16,.46,.28),vec3(.57,.83,.4),.5+.5*borderWave(path,.12,-phase*12.0));
     }else if(borderEffect>=7){
      // Perimeter-space patterns share one quad, keeping the frame seam-free.
      float t=phase*12.0;float v=0.0;
      if(borderEffect==7){v=.5+.5*borderWave(path,.28,sin(depth*.9+t)*2.0-t);}
      else if(borderEffect==8){vec2 d=vec2(mod(borderRepeat(path,14.0)-phase*96.0+7.0,14.0)-7.0,depth-4.0);v=exp(-dot(d,d)*.16)*(.7+.3*borderWave(path,.1,t));}
      else if(borderEffect==9){vec2 d=vec2(mod(borderRepeat(path,12.0)-phase*96.0+6.0,12.0)-6.0,depth-4.0);v=.5+.5*cos((abs(d.x)+abs(d.y))*1.3-t);}
      else if(borderEffect==10){v=.5+.5*borderWave(path,.16,sin(depth*.8-t)*2.8+borderWave(path,.07,t));}
      else if(borderEffect==11){float line=abs(depth-(4.0+2.0*borderWave(path,1.0/8.0,t*.3)));v=exp(-line*2.0);v=max(v,exp(-abs(mod(borderRepeat(path,24.0)-phase*96.0,24.0)-12.0)*1.4)*.8);}
      else if(borderEffect==12){v=.5+.5*borderWave(path,.5,-phase*48.0+abs(depth-4.0)*2.0);}
      else if(borderEffect==13){v=mod(floor((borderRepeat(path,8.0)+sin(depth+t)*3.0-t*3.0)/4.0)+floor(depth/2.0),2.0);}
      else if(borderEffect>=16){
       float kind=float(borderEffect-16);float a=borderWave(path,.22,t*.25);
       float radial=log(.18+abs(depth-4.0))*(5.0+mod(kind,3.0));
       float fold=abs(cos(borderRepeat(path,24.0)*.26+t*.3));
       v=.5+.5*sin(radial+fold*(4.0+kind)-t);
       if(borderEffect==17)v=.5+.5*cos(depth*1.6+fold*7.0+t);
       if(borderEffect==18)v=exp(-abs(sin(depth*1.4+a*4.0-t))*4.0);
       if(borderEffect==19)v=.5+.5*sin(depth*1.2+sin(a*3.0+t)*4.0-t);
       if(borderEffect==20)v=exp(-abs(sin(radial+cos(a*4.0)*5.0-t))*3.5);
       if(borderEffect==21)v=.5+.5*sin(depth*1.8+fold*11.0+t);
       if(borderEffect==22)v=exp(-abs(sin(radial+a*8.0+t))*4.0);
       if(borderEffect==23)v=.5+.5*cos(depth*2.0+fold*13.0-t);
      }
      else if(borderEffect==15){
       float family=mod(pokemonMotif-1.0,6.0);float pitch=12.0+mod(pokemonMotif,5.0)*2.0;
       vec2 q=vec2(mod(borderRepeat(path,pitch)-t*(1.0+mod(pokemonMotif,3.0))+pitch*.5,pitch)-pitch*.5,depth-4.0);
       if(family<1.0){v=exp(-abs(q.x+sin(q.y*2.4+t)*1.7)*1.4);}
       else if(family<2.0){v=exp(-abs(q.x)*.65)*(.5+.5*sin(q.y*2.0+q.x-t*2.0));}
       else if(family<3.0){v=exp(-abs(q.y-sin(q.x*.65-t)*2.0)*1.8);}
       else if(family<4.0){v=exp(-abs(abs(q.x)*.55+abs(q.y)-2.3)*2.0);}
       else if(family<5.0){v=max(exp(-abs(length(q*vec2(.7,1.1))-2.5)*2.3),exp(-length(q)*1.6));}
       else{v=exp(-abs(length(q)-2.7)*2.0);v=max(v,exp(-abs(q.y)*3.0)*step(abs(q.x),2.5));}
      }
      else {float a=abs(depth-4.0-2.0*borderWave(path,.2,-t));float b=abs(depth-4.0+2.0*borderWave(path,.2,-t));v=exp(-min(a,b)*1.6);}
      vec3 tint=gradientColor(phase+path.x+v*.22);
      rgb=mix(tint*.13,tint,v)*bevel;
      rgb+=vec3(.18,.22,.25)*pow(v,8.0);
     }
    }
    return vec4(rgb*color.rgb,ink.a*color.a);
   }]])end
  local resolved=background and palette.effects.resolve(background,background._kind or 'menu') or {1,1,1,1}
  panelShader:send('extent',{w,h});panelShader:send('usePaper',paper~=nil)
  -- Match LOVE's byte vertex-colour conversion used by the original fills.
  local function byte(c)return math.floor(c*255)/255 end
  panelShader:send('paperTexture',paper or image);panelShader:send('paperColor',{byte(resolved[1]),byte(resolved[2]),byte(resolved[3]),byte(resolved[4] or 1)})
  panelShader:send('paperGradient',resolved.animation=='GRADIENT');panelShader:send('paperPhase',resolved.phase or 0)
  palette.pokemonBackgrounds.send(panelShader,resolved.pokemon,resolved.phase,image,{0,0,w,h})
  palette.gradients.send(panelShader,atlas.gradient)
  -- The two palette uniforms are independent: frame motion never tints paper.
  local paperStops=palette.gradients.byKey[resolved.gradient]
  panelShader:send('paperCustomGradient',paperStops~=nil)
  for i,label in ipairs({'paperStopA','paperStopB','paperStopC','paperStopD'})do panelShader:send(label,paperStops and paperStops.stops[i] or {0,0,0})end
  panelShader:send('pokemonMotif',atlas.pokemonMotif or 0)
  panelShader:send('rainbow',atlas.animation=='gradient')
  panelShader:send('borderEffect',({balls=1,lightning=2,water=3,ghost=4,stars=5,vines=6,acid=7,plasma=8,kaleido=9,molten=10,circuit=11,tunnel=12,checker=13,braid=14,pokemon=15,psy0=16,psy1=17,psy2=18,psy3=19,psy4=20,psy5=21,psy6=22,psy7=23})[atlas.animation] or 0)
  local phase=0
  if atlas.animation then phase=(love.timer and love.timer.getTime and love.timer.getTime() or 0)*.08*palette.effects.get('menu','speed',100)/100 end
  panelShader:send('phase',phase)
  G.setShader(panelShader);G.draw(image,x,y,0,w/30,h/30)
  return true
 end
 local function gradient(atlas,x,y,w,h)
  if atlas.animation~='gradient' or not G.newShader then return false end
  if not gradientShader then gradientShader=G.newShader(palette.gradients.glsl..[[
   extern vec2 anchor;extern vec2 span;extern float phase;
   vec4 effect(vec4 color,Image tex,vec2 uv,vec2 pixel){
    vec4 ink=Texel(tex,uv);
    float h=fract(phase+(pixel.x-anchor.x)/span.x*.65+(pixel.y-anchor.y)/span.y*.35);
    vec3 rgb=gradientColor(h);
    return vec4(rgb*(.18+.82*ink.r),color.a*ink.a);
   }]])end
  local ax,ay,bx,by=x,y,x+w,y+h
  if G.transformPoint then ax,ay=G.transformPoint(x,y);bx,by=G.transformPoint(x+w,y+h)end
  palette.gradients.send(gradientShader,atlas.gradient)
  gradientShader:send('anchor',{ax,ay});gradientShader:send('span',{math.max(1,bx-ax),math.max(1,by-ay)})
  local speed=palette.effects.get('menu','speed',100)/100
  gradientShader:send('phase',(love.timer and love.timer.getTime and love.timer.getTime() or 0)*.08*speed)
  G.setShader(gradientShader);return true
 end
 function M.draw(tx,ty,tw,th,scope)
  if M.nativeDialogue then return false end
  if active and not active() then return false end
  local selection=selection(scope)
  if selection==1 and setting('menuTheme')>1 then selection=13 end
  local background=mod.exports and mod.exports.menuBackground and mod.exports.menuBackground()
  if background then return M.drawPixels(tx*8,ty*8,tw*8,th*8,background,scope)end
  local atlas=M.atlas(selection)
  if not atlas then return false end
  if tw<2 or th<2 then return false end
  if atlas.animation or (love.image and love.image.newImageData and G.newImage) then return M.drawPixels(tx*8,ty*8,tw*8,th*8,nil,scope)end
  G.push('all');G.setShader();G.setColor(1,1,1,1)
  G.rectangle('fill',(tx+1)*8,(ty+1)*8,(tw-2)*8,(th-2)*8)
  local function cell(n,x,y) G.draw(atlas.image,atlas.quads[n],x*8,y*8) end
  cell(0,tx,ty);cell(2,tx+tw-1,ty)
  cell(6,tx,ty+th-1);cell(8,tx+tw-1,ty+th-1)
  for x=tx+1,tx+tw-2 do cell(1,x,ty);cell(7,x,ty+th-1) end
  for y=ty+1,ty+th-2 do cell(3,tx,y);cell(5,tx+tw-1,y) end
  G.pop()
  return true
 end
 -- Battle callers use full pixel bounds rather than menu interior tiles.
 function M.drawPixels(x,y,w,h,background,scope)
  background=background or mod.exports and mod.exports.menuBackground and mod.exports.menuBackground()
  local selection=selection(scope)
  if selection==1 then
   local version=require('src.core.GameVersion').get()
   local path=setting('menuTheme')>1 and 'assets/borders/emerald_03.png' or
    (mod.generation==1 and 'assets/borders/rby_01.png' or mod.generation==2 and 'assets/borders/gsc_01.png' or
     (version=='firered' or version=='leafgreen') and 'assets/borders/frlg_01.png' or 'assets/borders/emerald_01.png')
   for i,e in ipairs(catalog.entries)do if e.path==path then selection=i;break end end
  end
  local atlas=M.atlas(selection)
  if not atlas or w<=0 or h<=0 then return false end
  if atlas.animation and not background then background={1,1,1,1}end
  local image,paper,quads,textureSize=renderAtlas(atlas,selection,background~=nil)
  local edge=math.min(8,w/2,h/2)
  local xs,ys={x,x+edge,x+w-edge},{y,y+edge,y+h-edge}
  local ws,hs={edge,w-2*edge,edge},{edge,h-2*edge,edge}
  G.push('all');G.setShader();G.setColor(1,1,1,1)
  local ok,err=pcall(function()
   if textureSize==30 and wholePanel(atlas,image,paper,x,y,w,h,background)then return end
   -- Repeat original 8px cells; crop the last cell rather than stretching
   -- an entire edge. Corners and patterned interiors keep the same pixel size.
   atlas.fragments=atlas.fragments or {}
   local function tiled(n,rx,ry,rw,rh)
    for dy=0,rh-0.000001,8 do for dx=0,rw-0.000001,8 do
     local cw,ch=math.min(8,rw-dx),math.min(8,rh-dy)
      local quad=quads[n]
     if cw<8 or ch<8 then
      local key=textureSize..':'..n..':'..cw..':'..ch
      quad=atlas.fragments[key]
      if not quad then
       local step,offset=textureSize==30 and 10 or 8,textureSize==30 and 1 or 0
       quad=G.newQuad(n%3*step+offset,math.floor(n/3)*step+offset,cw,ch,textureSize,textureSize)
       atlas.fragments[key]=quad
      end
     end
     if paper then
      paint(background,G.draw,paper,quad,rx+dx,ry+dy);G.setColor(1,1,1,1)
     end
     gradient(atlas,x,y,w,h)
     G.draw(image,quad,rx+dx,ry+dy)
     G.setShader()
    end end
   end
   for row=1,3 do for col=1,3 do
    if ws[col]>0 and hs[row]>0 then
     if row==2 and col==2 then
      -- The plain paper is one surface: fractional tile joins can leave
      -- hairline gaps under the independently scaled battle canvas.
      if background then paint(background,G.rectangle,'fill',xs[col],ys[row],ws[col],hs[row]);G.setColor(1,1,1,1)
      else G.draw(atlas.image,atlas.quads[4],xs[col],ys[row],0,ws[col]/8,hs[row]/8)end
     else tiled((row-1)*3+col-1,xs[col],ys[row],ws[col],hs[row]) end
    end
   end end
  end)
  G.pop();if not ok then error(err,0)end
  return true
 end
 -- Battle panels share the dialogue's 48px reference height. Render in
 -- screen space so command-width and move-canvas transforms cannot distort
 -- the border. Text keeps its own native transform.
 function M.drawBattlePixels(x,y,w,h)
  local ui=mod.exports and mod.exports.battleUi
  local background=ui and ui.backgroundColor and ui.backgroundColor()
  if not G.transformPoint or not G.origin then return M.drawPixels(x,y,w,h,background,'battle') end
  local left,top=G.transformPoint(x,y)
  local right,bottom=G.transformPoint(x+w,y+h)
  local scale=(bottom-top)/48
  if scale<=0 or right<=left then return false end
  G.push('all');G.origin();G.translate(left,top);G.scale(scale,scale)
  local ok,result=pcall(M.drawPixels,0,0,(right-left)/scale,48,background,'battle')
  G.pop();if not ok then error(result,0)end
  return result
 end
 function M.dialogueEnabled()return active() and setting('dialogueBorder')==1 end
 if mod.generation==3 then
  local Chrome=require('src.ui.game3.chrome')
  Chrome._menuCustomizerBorders=M
  if not Chrome._menuCustomizerDialogueWrapped then
   for _,key in ipairs({'dialogueFrame','signFrame'})do
    local original=Chrome[key]
    Chrome[key]=function(...)
     local borders=Chrome._menuCustomizerBorders
     if borders.dialogueEnabled() then
      local x,y,w,h=Chrome.dialogueWindow()
      if borders.draw(x-1,y-1,w+2,h+2,'dialogue') then return end
     end
     -- Native dialogue frames can call our wrapped userFrame internally.
     -- Fence those calls so OFF really retains the native border.
     local prior=borders.nativeDialogue;borders.nativeDialogue=true
     local result={pcall(original,...)};borders.nativeDialogue=prior
     if not result[1]then error(result[2],0)end
     local bg=palette.menuBackground('dialogue')
     if bg and active()then
      local x,y,w,h=Chrome.dialogueWindow()
      G.push('all');paint(bg,G.rectangle,'fill',x*8,y*8,w*8,h*8);G.pop()
     end
     return (unpack or table.unpack)(result,2)
    end
   end
   Chrome._menuCustomizerDialogueWrapped=true
  end

  if not Chrome._menuCustomizerBorderWrapped then
   local user=Chrome.userFrame
   Chrome.userFrame=function(frame,tx,ty,tw,th,...)
    if Chrome._menuCustomizerBorders.draw(tx-1,ty-1,tw+2,th+2) then return end
    return user(frame,tx,ty,tw,th,...)
   end
   for _,key in ipairs({'stdFrame','fixedStdFrame'}) do
    local original=Chrome[key]
    Chrome[key]=function(tx,ty,tw,th,...)
     if Chrome._menuCustomizerBorders.draw(tx-1,ty-1,tw+2,th+2) then return end
     return original(tx,ty,tw,th,...)
    end
   end
   Chrome._menuCustomizerBorderWrapped=true
  end
 end
 return M
end
