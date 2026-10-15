-- Draw-only text effects. Settings and layout remain independent of animation.
return function(mod,palette)
 local M={};local unpack=unpack or table.unpack
 local presets=assert(load(assert(mod:read('lib/font_color_presets.lua'))))()
 local presetNames={'CUSTOM'}
 for _,e in ipairs(presets)do
  presetNames[#presetNames+1]=e.name;e.colors={}
  for _,h in ipairs(e.hex)do e.colors[#e.colors+1]={tonumber(h:sub(1,2),16)/255,tonumber(h:sub(3,4),16)/255,tonumber(h:sub(5,6),16)/255,1}end
 end
 local prefixes={moveLearning='moveLearning_fx_',battleCommands='battleCommands_fx_',battlePrompt='battlePrompt_fx_',moveSelect='moveSelect_fx_',mods='mods_fx_',intro='intro_fx_',menu='menu_fx_',battle='battle_fx_',name='battle_name_fx_'}
 function M.get(kind,key,default)
  if kind=='menu'and mod.exports.gbMenus and mod.exports.gbMenus.introScope then kind='intro'end
  local k=(prefixes[kind] or prefixes.battle)..key
  return tonumber(mod.options:get(k) or mod.save:get(k)) or default or 0
 end
 function M.specs(kind)
  local p=prefixes[kind];local s={}
  s[p..'preset']={0,0,#presets,1}
  s[p..'alternate']={0,0,2,1};s[p..'count']={2,2,5,1};s[p..'speed']={100,25,200,25}
  s[p..'highlight']={0,0,1,1};s[p..'highlight_color']={6,0,#palette.names-1,1}
  s[p..'outline']={0,0,1,1};s[p..'outline_color']={0,0,#palette.names-1,1}
  for _,key in ipairs({'highlight_transparency','outline_transparency','shadow_transparency'})do s[p..key]={0,0,100,5}end
  for i=1,5 do s[p..'color'..i]={({0,2,3,4,5})[i],0,#palette.names-1,1}end
  return s
 end
 function M.rows(kind,persist,openPage)
  local p=prefixes[kind];local rows={}
  local function row(key,label,labels,default)
   local k=p..key;local spec=M.specs(kind)[k]
   local entry={id='fx_'..k,label=label,preview=function()return mod.exports.customization.values(k,M.get(kind,key,default or spec[1]))end,value=function()
    local n=M.get(kind,key,default or spec[1]);return labels and labels[n+1] or tostring(n)..((key=='speed'or key:find('transparency')) and '%' or '')
   end,step=function(ctx,dir)
    local n=M.get(kind,key,default or spec[1]);dir=dir and dir<0 and -1 or 1
    if key:match('^color')or key=='highlight_color'or key=='outline_color'then n=palette.step('text',n,dir)
    elseif key=='glow' or key=='double' then n=palette.step('shadow',n,dir)
    else n=(n-spec[2]+dir*spec[4])%(spec[3]-spec[2]+spec[4])+spec[2]end
    return persist(ctx,k,n)
   end}
   local colorKind=(key:match('^color')or key=='highlight_color'or key=='outline_color')and 'text' or (key=='glow' or key=='double') and 'shadow'
   if colorKind then palette.picker(entry,colorKind,function()return M.get(kind,key,default or spec[1])end,function(ctx,n)return persist(ctx,k,n)end,openPage)end
   rows[#rows+1]=entry
  end
  row('preset','COLOR PRESET',presetNames)
  local parent=rows
  if kind=='menu'then rows={}end
  row('alternate','ALTERNATE',{'OFF','BY LETTER','BY WORD'})
  row('count','COLOR COUNT')
  for i=1,5 do row('color'..i,'COLOR '..i,palette.names)end
  if kind=='menu'then
   local alternateRows=rows;rows=parent
   rows[#rows+1]={id='fx_'..p..'alternate_menu',label='ALTERNATE',value=function()return 'OPEN'end,
    activate=function(ctx)return openPage('ALTERNATE',alternateRows,ctx)end}
  end
  row('highlight','HIGHLIGHT',{'OFF','ON'})
  row('highlight_color','HIGHLIGHT COLOR',palette.names)
  row('outline','OUTLINE',{'OFF','ON'})
  row('outline_color','OUTLINE COLOR',palette.names)
  row('highlight_transparency','HIGHLIGHT TRANSPARENCY')
  row('outline_transparency','OUTLINE TRANSPARENCY')
  row('shadow_transparency','SHADOW TRANSPARENCY')
  local prefix=kind=='intro'and 'INTRO 'or kind=='menu'and 'MENU 'or kind=='name'and 'NAME 'or 'BATTLE '
  for _,entry in ipairs(rows)do entry.label=prefix..entry.label end
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
  local preset=presets[M.get(kind,'preset')]
  if preset then mode=mode==2 and 2 or 1;count=#preset.colors end
  if mode>0 and s and not space then
   local index=((mode==2 and s.word or s.letter)-1)%count+1
   fg=preset and preset.colors[index] or palette.color('text',M.get(kind,'color'..index,({0,2,3,4,5})[index]))
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
  local speed=M.get(kind or 'menu','speed',100)
  if mod.exports.animationSpeeds then speed=mod.exports.animationSpeeds.get(c._speedGroup or 'text',c._speedId or mod.exports.animationSpeeds.id(c),speed)end
  if c.animation=='POKEMON'then
   local col={};for k,v in pairs(c)do col[k]=v end
   col.phase=(love.timer and love.timer.getTime and love.timer.getTime() or 0)*speed/100
   return col
  end
  local t=(love.timer and love.timer.getTime and love.timer.getTime() or 0)*.08*speed/100
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
   local mode,x,y,w,h=...;local area=M.paperArea or (type(x)=='number'and type(h)=='number'and {x,y,w,h}or nil)
   palette.pokemonBackgrounds.send(M.pokemonShader,color.pokemon,color.phase,nil,area);G.setShader(M.pokemonShader)
  elseif color.animation=='GRADIENT' and G.newShader then
   if not shader then shader=G.newShader(palette.gradients.glsl..[[extern float phase;extern bool darkInk;extern vec2 gradientOrigin;extern vec2 gradientScale;
    vec4 effect(vec4 c,Image tex,vec2 uv,vec2 pixel){
     vec2 logical=(pixel-gradientOrigin)/gradientScale;float h=fract(phase+logical.x/320.0+logical.y/640.0);
     vec3 rgb=gradientColor(h);
     vec4 s=Texel(tex,uv);if(darkInk)s=vec4(1.0,1.0,1.0,s.a*(1.0-min(s.r,min(s.g,s.b))));return vec4(rgb,c.a)*s;
    }]])end
   local origin,scale={0,0},{1,1}
   if M.paperArea then
    local ax,ay=G.transformPoint(0,0);local bx,by=G.transformPoint(1,1)
    local target=G.getCanvas();local dpi=target and target:getDPIScale()or G.getDPIScale()
    origin={ax*dpi,ay*dpi};scale={math.max(.0001,(bx-ax)*dpi),math.max(.0001,(by-ay)*dpi)}
   end
   shader:send('gradientOrigin',origin);shader:send('gradientScale',scale)
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
 function M.glyph(colors,x,y,draw,metrics)
  local kind=colors._kind or 'battle';local fg=M.ink(colors,false)
  local function faded(c,key)
   if not c then return c end;local out={};for k,v in pairs(c)do out[k]=v end
   out[4]=(c[4]or 1)*(1-math.max(0,math.min(100,M.get(kind,key..'_transparency')))/100);return out
  end
  return M.aspect(x,y,function()
   local function layer(c,dx,dy)
    if c and colors._opacity then
     local faded={};for key,value in pairs(c)do faded[key]=value end
     faded[4]=(c[4] or 1)*colors._opacity;c=faded
    end
    if c and (c[4] or 1)>0 then return M.paint(c,kind,function()return draw(dx,dy)end)end
   end
   if M.get(kind,'highlight')==1 then
    local m=metrics or {width=8,top=0,height=8}
    local c=faded(palette.color('text',M.get(kind,'highlight_color',6)),'highlight')
    if colors._opacity then local copy={};for k,v in pairs(c)do copy[k]=v end;copy[4]=(c[4]or 1)*colors._opacity;c=copy end
    -- Rectangle textures are white; do not apply native black-glyph inversion.
    local old=M.darkInk;M.darkInk=false
    local result={pcall(M.paint,c,kind,function()love.graphics.rectangle('fill',x,y+(m.top or 0),math.max(1,m.width or 8),m.height or 8)end)}
    M.darkInk=old;if not result[1]then error(result[2],0)end
   end
   layer(faded(colors.shadow,'shadow'),-1,1)
   if M.get(kind,'outline')==1 then
    local c=faded(palette.color('text',M.get(kind,'outline_color')),'outline')
    for dy=-1,1 do for dx=-1,1 do if dx~=0 or dy~=0 then layer(c,dx,dy)end end end
   end
   return layer(fg,0,0)
  end)
 end
 return M
end
