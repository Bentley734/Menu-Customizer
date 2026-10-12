-- Draw-only text effects. Settings and layout remain independent of animation.
return function(mod,palette)
 local M={};local unpack=unpack or table.unpack
 local prefixes={menu='menu_fx_',battle='battle_fx_',name='battle_name_fx_'}
 function M.get(kind,key,default)
  local k=(prefixes[kind] or prefixes.battle)..key
  return tonumber(mod.options:get(k) or mod.save:get(k)) or default or 0
 end
 function M.specs(kind)
  local p=prefixes[kind];local s={}
  s[p..'alternate']={0,0,2,1};s[p..'count']={2,2,5,1};s[p..'speed']={100,25,200,25}
  s[p..'glow']={0,0,#palette.shadowNames-1,1};s[p..'double']={0,0,#palette.shadowNames-1,1}
  for i=1,5 do s[p..'color'..i]={({0,2,3,4,5})[i],0,#palette.names-1,1}end
  return s
 end
 function M.rows(kind,persist,openPage)
  local p=prefixes[kind];local rows={}
  local function row(key,label,labels,default)
   local k=p..key;local spec=M.specs(kind)[k]
   local entry={id='fx_'..k,label=label,value=function()
    local n=M.get(kind,key,default or spec[1]);return labels and labels[n+1] or tostring(n)..(key=='speed' and '%' or '')
   end,step=function(ctx,dir)
    local n=M.get(kind,key,default or spec[1]);dir=dir and dir<0 and -1 or 1
    if key:match('^color') then n=palette.step('text',n,dir)
    elseif key=='glow' or key=='double' then n=palette.step('shadow',n,dir)
    else n=(n-spec[2]+dir*spec[4])%(spec[3]-spec[2]+spec[4])+spec[2]end
    return persist(ctx,k,n)
   end}
   local colorKind=key:match('^color') and 'text' or (key=='glow' or key=='double') and 'shadow'
   if colorKind then palette.picker(entry,colorKind,function()return M.get(kind,key,default or spec[1])end,function(ctx,n)return persist(ctx,k,n)end,openPage)end
   rows[#rows+1]=entry
  end
  row('alternate','ALTERNATE',{'OFF','BY LETTER','BY WORD'})
  row('count','COLOR COUNT')
  for i=1,5 do row('color'..i,'COLOR '..i,palette.names)end
  row('glow','GLOW COLOR',palette.shadowNames)
  row('double','DOUBLE SHADOW',palette.shadowNames)
  row('speed','COLOR SPEED')
  return rows
 end
 local sequences={}
 function M.sequence(kind,fn,...)
  local old=sequences[kind];sequences[kind]={letter=0,word=0,space=true}
  local result={pcall(fn,...)};sequences[kind]=old
  if not result[1]then error(result[2],0)end;return unpack(result,2)
 end
 function M.ink(colors,space)
  local kind=colors._kind or 'battle';local s=sequences[kind]
  if s then
   if space then s.space=true else s.letter=s.letter+1;if s.space then s.word=s.word+1;s.space=false end end
  end
  local mode=M.get(kind,'alternate');local count=math.max(2,math.min(5,math.floor(M.get(kind,'count',2))))
  local fg=colors.fg
  if mode>0 and s and not space then
   local index=((mode==2 and s.word or s.letter)-1)%count+1
   fg=palette.color('text',M.get(kind,'color'..index,({0,2,3,4,5})[index]))
  end
  return fg
 end
 local shader
 local function hue(h)
  local r=math.abs(h*6-3)-1;local g=2-math.abs(h*6-2);local b=2-math.abs(h*6-4)
  return {math.max(0,math.min(1,r)),math.max(0,math.min(1,g)),math.max(0,math.min(1,b)),1}
 end
 function M.resolve(c,kind)
  if not c or not c.animation then return c end
  if c.animation=='POKEMON'then
   local col={};for k,v in pairs(c)do col[k]=v end
   col.phase=(love.timer and love.timer.getTime and love.timer.getTime() or 0)*M.get(kind or 'menu','speed',100)/100
   return col
  end
  local t=(love.timer and love.timer.getTime and love.timer.getTime() or 0)*.08*M.get(kind or 'menu','speed',100)/100
  local col=palette.gradients.sample(c.gradient,t) or hue(t%1)
  col[4]=c[4] or 1
  if c.animation=='GRADIENT' then col.animation='GRADIENT';col.phase=t;col.gradient=c.gradient end
  return col
 end
 function M.paint(c,kind,fn,...)
  local G=love.graphics;local color=M.resolve(c,kind)
  G.push('all');G.setColor(unpack(color))
  if color.animation=='POKEMON' and G.newShader then
   if not M.pokemonShader then M.pokemonShader=G.newShader(palette.pokemonBackgrounds.glsl..[[
    extern vec2 pokeOrigin;extern vec2 pokeScale;
    vec4 effect(vec4 c,Image tex,vec2 uv,vec2 pixel){return vec4(pokemonPaper((pixel-pokeOrigin)/pokeScale),c.a)*Texel(tex,uv);}
   ]])end
   local ax,ay=G.transformPoint(0,0);local bx,by=G.transformPoint(1,1)
   local target=G.getCanvas();local dpi=target and target:getDPIScale() or G.getDPIScale()
   M.pokemonShader:send('pokeOrigin',{ax*dpi,ay*dpi});M.pokemonShader:send('pokeScale',{math.max(.0001,(bx-ax)*dpi),math.max(.0001,(by-ay)*dpi)})
   palette.pokemonBackgrounds.send(M.pokemonShader,color.pokemon,color.phase);G.setShader(M.pokemonShader)
  elseif color.animation=='GRADIENT' and G.newShader then
   if not shader then shader=G.newShader(palette.gradients.glsl..[[extern float phase;extern bool darkInk;
    vec4 effect(vec4 c,Image tex,vec2 uv,vec2 pixel){
     float h=fract(phase+pixel.x/320.0+pixel.y/640.0);
     vec3 rgb=gradientColor(h);
     vec4 s=Texel(tex,uv);if(darkInk)s=vec4(1.0,1.0,1.0,s.a*(1.0-min(s.r,min(s.g,s.b))));return vec4(rgb,c.a)*s;
    }]])end
   palette.gradients.send(shader,color.gradient);shader:send('phase',color.phase);shader:send('darkInk',M.darkInk or false);G.setShader(shader)
  end
  local result={pcall(fn,...)};G.pop()
  if not result[1]then error(result[2],0)end;return unpack(result,2)
 end
 -- Compensate the active transform at the glyph anchor, preserving placement.
 -- DPI-correct physical square pixels, including stretched KIM HUD canvases.
 function M.aspect(x,y,fn,...)
  local G=love.graphics
  if not G.transformPoint then return fn(...)end
  local ax,ay=G.transformPoint(x,y);local bx,by=G.transformPoint(x+1,y);local cx,cy=G.transformPoint(x,y+1)
  local sx=math.sqrt((bx-ax)^2+(by-ay)^2);local sy=math.sqrt((cx-ax)^2+(cy-ay)^2)
  local pending=mod.exports and mod.exports.fontAspect
  if pending then sx=sx*pending[1];sy=sy*pending[2]end
  if sx<.00001 or sy<.00001 or math.abs(sx-sy)<.00001 then return fn(...)end
  local s=math.min(sx,sy);G.push('all');G.translate(x,y);G.scale(s/sx,s/sy);G.translate(-x,-y)
  local result={pcall(fn,...)};G.pop();if not result[1]then error(result[2],0)end;return unpack(result,2)
 end
 function M.glyph(colors,x,y,draw)
  local kind=colors._kind or 'battle';local fg=M.ink(colors,false)
  local glow=palette.color('shadow',M.get(kind,'glow'));local double=palette.color('shadow',M.get(kind,'double'))
  return M.aspect(x,y,function()
   local function layer(c,dx,dy)
    if c and colors._opacity then
     local faded={};for key,value in pairs(c)do faded[key]=value end
     faded[4]=(c[4] or 1)*colors._opacity;c=faded
    end
    if c and (c[4] or 1)>0 then return M.paint(c,kind,function()return draw(dx,dy)end)end
   end
   layer(double,-3,3);layer(colors.shadow,-1,1);layer(glow,1,-1);return layer(fg,0,0)
  end)
 end
 return M
end
