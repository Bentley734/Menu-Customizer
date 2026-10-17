-- Battle-only palette. Literal colours never inherit a ROM's mutable STDPAL.
return function(mod)
  local M={names={'BLACK','CHARCOAL','BLUE','GREEN','RED','PURPLE','WHITE'}}
  local foreground={{0,0,0,1},{.18,.18,.18,1},{.05,.18,.55,1},{.05,.35,.12,1},{.6,.05,.05,1},{.4,.1,.5,1},{1,1,1,1}}
  M.shadowNames={'NONE','BLACK','CHARCOAL','GREY','LIGHT GREY','BLUE','GREEN','RED','PURPLE','WHITE'}
  local shadows={{0,0,0,0},{0,0,0,1},{.18,.18,.18,1},{.5,.5,.5,1},{.72,.72,.72,1},foreground[3],foreground[4],foreground[5],foreground[6],foreground[7]}
  M.backgroundNames={'WHITE','BLACK','CHARCOAL','NAVY','CREAM','PALE BLUE','PALE GREEN','PLUM'}
  local backgrounds={{1,1,1,1},{0,0,0,1},{.12,.12,.14,1},{.04,.08,.18,1},{1,.96,.82,1},{.82,.91,1,1},{.84,.95,.85,1},{.18,.06,.22,1}}
  -- Append colours so existing saved numeric choices retain their meaning.
  M.names[#M.names+1]='LIGHT BLUE';foreground[#foreground+1]={0.4,0.7,1,1}
  M.shadowNames[#M.shadowNames+1]='LIGHT BLUE';shadows[#shadows+1]={0.4,0.7,1,1}
  M.names[#M.names+1]='SKY BLUE';foreground[#foreground+1]={0.6,0.84,1,1}
  M.shadowNames[#M.shadowNames+1]='SKY BLUE';shadows[#shadows+1]={0.6,0.84,1,1}
  M.names[#M.names+1]='CYAN';foreground[#foreground+1]={0.1,0.85,0.9,1}
  M.shadowNames[#M.shadowNames+1]='CYAN';shadows[#shadows+1]={0.1,0.85,0.9,1}
  M.names[#M.names+1]='TEAL';foreground[#foreground+1]={0.1,0.55,0.55,1}
  M.shadowNames[#M.shadowNames+1]='TEAL';shadows[#shadows+1]={0.1,0.55,0.55,1}
  M.names[#M.names+1]='LIGHT GREEN';foreground[#foreground+1]={0.5,0.85,0.4,1}
  M.shadowNames[#M.shadowNames+1]='LIGHT GREEN';shadows[#shadows+1]={0.5,0.85,0.4,1}
  M.names[#M.names+1]='MINT';foreground[#foreground+1]={0.65,0.95,0.75,1}
  M.shadowNames[#M.shadowNames+1]='MINT';shadows[#shadows+1]={0.65,0.95,0.75,1}
  M.names[#M.names+1]='LIME';foreground[#foreground+1]={0.7,0.9,0.15,1}
  M.shadowNames[#M.shadowNames+1]='LIME';shadows[#shadows+1]={0.7,0.9,0.15,1}
  M.names[#M.names+1]='FOREST';foreground[#foreground+1]={0.02,0.23,0.12,1}
  M.shadowNames[#M.shadowNames+1]='FOREST';shadows[#shadows+1]={0.02,0.23,0.12,1}
  M.names[#M.names+1]='YELLOW';foreground[#foreground+1]={1,0.88,0.2,1}
  M.shadowNames[#M.shadowNames+1]='YELLOW';shadows[#shadows+1]={1,0.88,0.2,1}
  M.names[#M.names+1]='GOLD';foreground[#foreground+1]={0.85,0.6,0.05,1}
  M.shadowNames[#M.shadowNames+1]='GOLD';shadows[#shadows+1]={0.85,0.6,0.05,1}
  M.names[#M.names+1]='ORANGE';foreground[#foreground+1]={1,0.45,0.1,1}
  M.shadowNames[#M.shadowNames+1]='ORANGE';shadows[#shadows+1]={1,0.45,0.1,1}
  M.names[#M.names+1]='PEACH';foreground[#foreground+1]={1,0.78,0.6,1}
  M.shadowNames[#M.shadowNames+1]='PEACH';shadows[#shadows+1]={1,0.78,0.6,1}
  M.names[#M.names+1]='PINK';foreground[#foreground+1]={1,0.5,0.72,1}
  M.shadowNames[#M.shadowNames+1]='PINK';shadows[#shadows+1]={1,0.5,0.72,1}
  M.names[#M.names+1]='ROSE';foreground[#foreground+1]={0.75,0.2,0.4,1}
  M.shadowNames[#M.shadowNames+1]='ROSE';shadows[#shadows+1]={0.75,0.2,0.4,1}
  M.names[#M.names+1]='LAVENDER';foreground[#foreground+1]={0.76,0.66,1,1}
  M.shadowNames[#M.shadowNames+1]='LAVENDER';shadows[#shadows+1]={0.76,0.66,1,1}
  M.names[#M.names+1]='INDIGO';foreground[#foreground+1]={0.22,0.15,0.55,1}
  M.shadowNames[#M.shadowNames+1]='INDIGO';shadows[#shadows+1]={0.22,0.15,0.55,1}
  M.names[#M.names+1]='SILVER';foreground[#foreground+1]={0.75,0.78,0.82,1}
  M.shadowNames[#M.shadowNames+1]='SILVER';shadows[#shadows+1]={0.75,0.78,0.82,1}
  M.names[#M.names+1]='BROWN';foreground[#foreground+1]={0.4,0.24,0.12,1}
  M.shadowNames[#M.shadowNames+1]='BROWN';shadows[#shadows+1]={0.4,0.24,0.12,1}
  M.names[#M.names+1]='NAVY';foreground[#foreground+1]={0.04,0.08,0.18,1}
  M.shadowNames[#M.shadowNames+1]='NAVY';shadows[#shadows+1]={0.04,0.08,0.18,1}
  M.names[#M.names+1]='CREAM';foreground[#foreground+1]={1,0.96,0.82,1}
  M.shadowNames[#M.shadowNames+1]='CREAM';shadows[#shadows+1]={1,0.96,0.82,1}
  M.backgroundNames[#M.backgroundNames+1]='BLUE';backgrounds[#backgrounds+1]={0.05,0.18,0.55,1}
  M.backgroundNames[#M.backgroundNames+1]='LIGHT BLUE';backgrounds[#backgrounds+1]={0.4,0.7,1,1}
  M.backgroundNames[#M.backgroundNames+1]='SKY BLUE';backgrounds[#backgrounds+1]={0.6,0.84,1,1}
  M.backgroundNames[#M.backgroundNames+1]='CYAN';backgrounds[#backgrounds+1]={0.1,0.85,0.9,1}
  M.backgroundNames[#M.backgroundNames+1]='TEAL';backgrounds[#backgrounds+1]={0.1,0.55,0.55,1}
  M.backgroundNames[#M.backgroundNames+1]='GREEN';backgrounds[#backgrounds+1]={0.05,0.35,0.12,1}
  M.backgroundNames[#M.backgroundNames+1]='LIGHT GREEN';backgrounds[#backgrounds+1]={0.5,0.85,0.4,1}
  M.backgroundNames[#M.backgroundNames+1]='MINT';backgrounds[#backgrounds+1]={0.65,0.95,0.75,1}
  M.backgroundNames[#M.backgroundNames+1]='LIME';backgrounds[#backgrounds+1]={0.7,0.9,0.15,1}
  M.backgroundNames[#M.backgroundNames+1]='FOREST';backgrounds[#backgrounds+1]={0.02,0.23,0.12,1}
  M.backgroundNames[#M.backgroundNames+1]='YELLOW';backgrounds[#backgrounds+1]={1,0.88,0.2,1}
  M.backgroundNames[#M.backgroundNames+1]='GOLD';backgrounds[#backgrounds+1]={0.85,0.6,0.05,1}
  M.backgroundNames[#M.backgroundNames+1]='ORANGE';backgrounds[#backgrounds+1]={1,0.45,0.1,1}
  M.backgroundNames[#M.backgroundNames+1]='PEACH';backgrounds[#backgrounds+1]={1,0.78,0.6,1}
  M.backgroundNames[#M.backgroundNames+1]='RED';backgrounds[#backgrounds+1]={0.6,0.05,0.05,1}
  M.backgroundNames[#M.backgroundNames+1]='PINK';backgrounds[#backgrounds+1]={1,0.5,0.72,1}
  M.backgroundNames[#M.backgroundNames+1]='ROSE';backgrounds[#backgrounds+1]={0.75,0.2,0.4,1}
  M.backgroundNames[#M.backgroundNames+1]='PURPLE';backgrounds[#backgrounds+1]={0.4,0.1,0.5,1}
  M.backgroundNames[#M.backgroundNames+1]='LAVENDER';backgrounds[#backgrounds+1]={0.76,0.66,1,1}
  M.backgroundNames[#M.backgroundNames+1]='INDIGO';backgrounds[#backgrounds+1]={0.22,0.15,0.55,1}
  M.backgroundNames[#M.backgroundNames+1]='SILVER';backgrounds[#backgrounds+1]={0.75,0.78,0.82,1}
  M.backgroundNames[#M.backgroundNames+1]='BROWN';backgrounds[#backgrounds+1]={0.4,0.24,0.12,1}
  local baseCounts={text=#foreground,shadow=#shadows,background=#backgrounds}
  local swatches=mod.read and assert(load(assert(mod:read('lib/color_swatches.lua'))))() or {}
  for _,swatch in ipairs(swatches)do
    local c={swatch.rgb[1],swatch.rgb[2],swatch.rgb[3],1}
    M.names[#M.names+1]=swatch.name;foreground[#foreground+1]=c
    M.shadowNames[#M.shadowNames+1]=swatch.name;shadows[#shadows+1]=c
    M.backgroundNames[#M.backgroundNames+1]=swatch.name;backgrounds[#backgrounds+1]=c
  end
  local gradientSource=mod.read and mod:read('lib/animated_gradients.lua')
  M.gradients=gradientSource and assert(load(gradientSource))() or assert(loadfile('lib/animated_gradients.lua'))()
  M.gradients.register(assert(load(assert(mod:read('lib/pokemon_border_palettes.lua'))))())
  local function animated(name,key,mode)
    local c={1,1,1,1,animation=mode or 'GRADIENT',gradient=key}
    M.names[#M.names+1]=name;foreground[#foreground+1]=c
    M.shadowNames[#M.shadowNames+1]=name;shadows[#shadows+1]=c
    M.backgroundNames[#M.backgroundNames+1]=name;backgrounds[#backgrounds+1]=c
  end
  -- Keep the three old animation slots: RGB becomes a gentle Aurora gradient.
  -- Every static colour and the two other animation IDs keep their meaning.
  animated('AURORA','aurora');animated('ROTATING',nil,'ROTATING');animated('ANIMATED GRADIENT')
  for i=2,#M.gradients.entries do local e=M.gradients.entries[i];animated(e.name,e.key)end
  local pokemonSource=mod.read and mod:read('lib/pokemon_backgrounds.lua')
  M.pokemonBackgrounds=(pokemonSource and assert(load(pokemonSource))() or assert(loadfile('lib/pokemon_backgrounds.lua'))())(mod)
  -- Background-only additions: never shift saved font/shadow/gradient IDs.
  for _,e in ipairs(M.pokemonBackgrounds.entries)do
    M.backgroundNames[#M.backgroundNames+1]=e.name;backgrounds[#backgrounds+1]=M.pokemonBackgrounds.color(e.key)
  end
  for _,e in ipairs(M.gradients.darkEntries or{})do
    M.backgroundNames[#M.backgroundNames+1]=e.name
    backgrounds[#backgrounds+1]={1,1,1,1,animation='GRADIENT',gradient=e.key}
  end
  for _,e in ipairs(M.pokemonBackgrounds.blackEntries or{})do M.backgroundNames[#M.backgroundNames+1]=e.name;backgrounds[#backgrounds+1]=M.pokemonBackgrounds.color(e.key)end
  for _,e in ipairs(M.pokemonBackgrounds.forestEntries or{})do M.backgroundNames[#M.backgroundNames+1]=e.name;backgrounds[#backgrounds+1]=M.pokemonBackgrounds.color(e.key)end
  for _,e in ipairs(M.pokemonBackgrounds.extraEntries or{})do M.backgroundNames[#M.backgroundNames+1]=e.name;backgrounds[#backgrounds+1]=M.pokemonBackgrounds.color(e.key)end
  for _,e in ipairs(M.gradients.versionEntries or{})do animated(e.name,e.key)end
  -- Background and text rates must not share a palette table by reference.
  for _,pair in ipairs({{backgrounds,'background'},{foreground,'text'},{shadows,'text'}})do
   for i,c in ipairs(pair[1])do if c.animation then
    local copy={};for k,v in pairs(c)do copy[k]=v end
    copy._speedGroup=pair[2];copy._speedId=c.pokemon or c.gradient or c.animation;pair[1][i]=copy
   end end
  end
  local lists={text=foreground,shadow=shadows,background=backgrounds}
  function M.color(kind,n)local l=lists[kind] or foreground;return l[math.max(0,math.min(#l-1,math.floor(n or 0)))+1]end
  local function hue(c)
    local hi,lo=math.max(c[1],c[2],c[3]),math.min(c[1],c[2],c[3]);local d=hi-lo
    if d<.025 then return -1,hi end
    local h=hi==c[1] and ((c[2]-c[3])/d)%6 or hi==c[2] and (c[3]-c[1])/d+2 or (c[1]-c[2])/d+4
    return h/6,hi
  end
  local orders={}
  for kind,list in pairs(lists)do
    local ids={};for i=1,#list do ids[i]=i-1 end
    table.sort(ids,function(a,b)
      local x,y=list[a+1],list[b+1]
      if x.animation or y.animation then if not x.animation then return true elseif not y.animation then return false else return a<b end end
      if kind=='shadow' and (a==0 or b==0)then return a==0 end
      local ha,va=hue(x);local hb,vb=hue(y)
      if math.abs(ha-hb)>.000001 then return ha<hb elseif math.abs(va-vb)>.000001 then return va<vb else return a<b end
    end);orders[kind]=ids
  end
  function M.step(kind,n,dir)
    if kind=='menuBackground' then if n==0 then return dir<0 and orders.background[#orders.background]+1 or orders.background[1]+1 end
      local ids={0};for _,id in ipairs(orders.background)do ids[#ids+1]=id+1 end
      for i,id in ipairs(ids)do if id==n then return ids[(i-1+(dir<0 and -1 or 1))%#ids+1]end end;return 0
    end
    local ids=orders[kind] or orders.text
    for i,id in ipairs(ids)do if id==n then return ids[(i-1+(dir<0 and -1 or 1))%#ids+1]end end;return ids[1]
  end
  local effectsSource=mod.read and mod:read('lib/text_effects.lua')
  M.effects=effectsSource and assert(load(effectsSource))()(mod,M) or assert(loadfile('lib/text_effects.lua'))()(mod,M)
  function M.paint(color,fn,...)return M.effects.paint(color,color._kind or 'menu',fn,...)end
  function M.withText(kind,fn,...)return M.effects.sequence(kind,fn,...)end
  function M.menuBackground(kind)
    local n=tonumber(mod.options:get('menuBackgroundColor') or mod.save:get('menuBackgroundColor')) or 0
    local gb=mod.exports.gbMenus
    if kind=='dialogue'or mod.exports.dialogueFontScope or gb and gb.dialogueScope then
      n=tonumber(mod.options:get('dialogueBackgroundColor')or mod.save:get('dialogueBackgroundColor'))or 0
    elseif kind=='save' then
      local summary=tonumber(mod.options:get('saveSummaryBackgroundColor')or mod.save:get('saveSummaryBackgroundColor'))or 0
      if summary>0 then n=summary end
    elseif kind=='start' then
      local start=tonumber(mod.options:get('startMenuBackgroundColor') or mod.save:get('startMenuBackgroundColor')) or 0
      if start>0 then n=start end
    end
    n=math.max(0,math.min(#backgrounds,math.floor(n)))
    return n>0 and backgrounds[n] or nil
  end
  M.menuBackgroundNames={'DEFAULT'}
  for _,name in ipairs(M.backgroundNames)do M.menuBackgroundNames[#M.menuBackgroundNames+1]=name end
  -- IDs stay flat in storage; navigation groups the same colours by hue.
  function M.groups(kind,defaultLabel)
    local names=kind=='shadow' and M.shadowNames or kind=='background' and M.backgroundNames or kind=='menuBackground' and M.menuBackgroundNames or M.names
    local families={'SPECIAL','NEUTRALS','REDS','ORANGES','YELLOWS','GREENS','CYANS','BLUES','PURPLES','PINKS','BROWNS','ANIMATED','GRADIENTS','VERSION GRADIENTS','POKEMON','PSYCHEDELIC','RED PSYCHEDELIC','FIRE','BLACK PSYCHEDELIC','BLACK POKEMON','FOREST / GRASS','DESIGNS'}
    local buckets={};for _,name in ipairs(families)do buckets[name]={label=name,ids={}}end
    local count=#names
    for i=0,count-1 do
      local family,c,label
      if kind=='menuBackground' and i==0 or kind=='shadow' and i==0 then family='SPECIAL'
      else
        c=M.color(kind=='menuBackground' and 'background' or kind,kind=='menuBackground' and i-1 or i)
        label=names[i+1]
        if c.pokemon then
          local e=M.pokemonBackgrounds.byKey[c.pokemon];local style=e.style or 0
          family=e.blackFamily or(style>=151 and'FOREST / GRASS'or e.fire and'FIRE'or c.pokemon:find('red_psy',1,true)and'RED PSYCHEDELIC'or style>=13 and style<=32 and'PSYCHEDELIC'or'POKEMON')
        elseif c.animation and(kind=='background'or kind=='menuBackground')then
          family=c.gradient and c.gradient:find('version_',1,true)==1 and'VERSION GRADIENTS'or'GRADIENTS'
        elseif c.animation then family='ANIMATED'
        else
          local h,v=hue(c);local lo=math.min(c[1],c[2],c[3]);local sat=v>0 and (v-lo)/v or 0
          if h<0 or sat<.06 then family='NEUTRALS'
          elseif label:find('BROWN') or label:find('TAN') or label:find('SAND') or label:find('BEIGE') then family='BROWNS'
          elseif h<.04 or h>=.96 then family='REDS'
          elseif h<.12 then family='ORANGES'
          elseif h<.19 then family='YELLOWS'
          elseif h<.45 then family='GREENS'
          elseif h<.55 then family='CYANS'
          elseif h<.72 then family='BLUES'
          elseif h<.86 then family='PURPLES'
          else family='PINKS'end
        end
      end
      if not(c and c.pokemon and M.pokemonBackgrounds.byKey[c.pokemon].hidden)then local ids=buckets[family].ids;ids[#ids+1]=i end
    end
    local result={}
    for _,family in ipairs(families)do
      local group=buckets[family]
      if #group.ids>0 then
        table.sort(group.ids,function(a,b)
          if family=='POKEMON'then return a<b end
          local ia=kind=='menuBackground' and a-1 or a;local ib=kind=='menuBackground' and b-1 or b
          if ia<0 or ib<0 then return a<b end
          local base=baseCounts[kind=='menuBackground' and 'background' or kind] or baseCounts.text
          if ia<base or ib<base then
            if ia<base and ib<base then return a<b end
            return ia<base
          end
          local ca,cb=M.color(kind=='menuBackground' and 'background' or kind,ia),M.color(kind=='menuBackground' and 'background' or kind,ib)
          local _,va=hue(ca);local _,vb=hue(cb)
          if math.abs(va-vb)>.000001 then return va<vb end;return a<b
        end)
        if #group.ids>24 and family~='ANIMATED'and family~='NEUTRALS'then
         for first=1,#group.ids,24 do
          local part={label=family..' '..math.floor((first-1)/24+1),ids={}}
          for index=first,math.min(first+23,#group.ids)do part.ids[#part.ids+1]=group.ids[index]end
          result[#result+1]=part
         end
        else result[#result+1]=group end
      end
    end
    return result,names
  end
  M.designPicker=assert(load(assert(mod:read('lib/design_picker.lua'))))()
  function M.picker(row,kind,get,persist,openPage,defaultLabel)
    if not openPage then return row end
    row.customization=mod.exports.customization
    row.group=true
    row.activate=function(ctx)
      local groups,names=M.groups(kind,defaultLabel);local rows={}
      for _,group in ipairs(groups)do
        local g=group
        rows[#rows+1]={id=row.id..':'..g.label,label=g.label,group=true,
          value=function()return #g.ids..(g.label=='DESIGNS'and' DESIGNS'or' COLORS')end,
          selected=function()for _,id in ipairs(g.ids)do if get()==id then return true end end;return false end,
          activate=function(nextCtx)
            local shades={}
            for _,id in ipairs(g.ids)do
              local n=id
              shades[#shades+1]={id=row.id..':color:'..n,label=n==0 and defaultLabel or names[n+1],colorChoice=true,preview=function()
                local key=row.id:gsub('^wide_',''):gsub('^fx_','')
                return mod.exports.customization.values(key,n)
               end,
                value=function()return get()==n and 'SELECTED' or 'USE'end,
                selected=function()return get()==n end,
                activate=function(selectCtx)return persist(selectCtx or nextCtx or ctx,n)end}
            end
            openPage(g.label,shades,nextCtx or ctx)
          end}
      end
      return openPage(row.label,rows,ctx)
    end
    return row
  end
  function M.tintFill(fn,mode,x,y,w,h,...)
    local G=love.graphics;local bg=mod.exports and mod.exports.menuBackground and mod.exports.menuBackground()
    if not bg or not G.getColor then return fn(mode,x,y,w,h,...)end
    local r,g,b,a=G.getColor()
    if bg and mode=='fill' and math.min(r,g,b)>.55 and math.max(r,g,b)-math.min(r,g,b)<.06 then
      local shade=(r+g+b)/3
      local tint=bg.animation and bg or {math.min(1,bg[1]*(.6+.4*shade)+.12*shade),math.min(1,bg[2]*(.6+.4*shade)+.12*shade),math.min(1,bg[3]*(.6+.4*shade)+.12*shade),a}
      local result={pcall(M.paint,tint,fn,mode,x,y,w,h,...)}
      if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
    end
    return fn(mode,x,y,w,h,...)
  end
  function M.background()
    local n=tonumber(mod.options:get('battle_background_color') or mod.save:get('battle_background_color')) or 0
    local color=backgrounds[math.max(0,math.min(#backgrounds-1,math.floor(n)))+1]
    if color.animation then return {color[1],color[2],color[3],color[4],animation=color.animation,gradient=color.gradient,pokemon=color.pokemon,_kind='battle',_speedGroup='background',_speedId=color._speedId}end
    return color
  end
  function M.colors(kind)
    local key=(kind=='menu'or kind=='intro') and 'menuTextColor' or kind=='name' and 'battle_name_color' or 'battle_text_color'
    local gb=mod.exports.gbMenus
    local dialogue=kind=='menu'and(mod.exports.dialogueFontScope or gb and gb.dialogueScope)
    if dialogue then key='dialogueTextColor'elseif kind=='intro'or kind=='menu'and gb and gb.introScope then key='introTextColor'end
    local n=tonumber(mod.options:get(key) or mod.save:get(key)) or 0
    if mod.exports.gameFreakLogoScope then n=tonumber(mod.options:get('gameFreakTextColor'))or n end
    n=math.max(0,math.min(#foreground-1,math.floor(n)))
    local shadowKey=(kind=='menu'or kind=='intro') and 'menuTextShadowColor' or kind=='name' and 'battle_name_shadow_color' or 'battle_shadow_color'
    if dialogue then shadowKey='dialogueTextShadowColor'elseif kind=='intro'or kind=='menu'and gb and gb.introScope then shadowKey='introTextShadowColor'end
    local sh=tonumber(mod.options:get(shadowKey) or mod.save:get(shadowKey)) or 0
    if mod.exports.gameFreakLogoScope then sh=tonumber(mod.options:get('gameFreakTextShadowColor'))or sh end
    sh=math.max(0,math.min(#shadows-1,math.floor(sh)))
    return {fg=foreground[n+1],shadow=shadows[sh+1],bg={0,0,0,0},_kind=kind or 'battle',_effects=M.effects}
  end
  function M.clean(text)
    if type(text)~='string' then return text end
    -- Remove only palette/font controls; retain pauses, line breaks and variables.
    return (text:gsub('\252[\001\002\003\006].',''):gsub('\252\004...',''):gsub('\252\007',''))
  end
  local function scope(fn,kind,all,...)
    local F=require('src.ui.game3.frlg_font')
    local draw,glyph=F.draw,F.drawGlyph
    local function options(opts)
      local copy={};for k,v in pairs(opts or {})do copy[k]=v end
      copy.colors=M.colors(kind);copy.color=nil;copy.shadow=nil
      return copy
    end
    F.draw=function(text,x,y,opts,...)
      if not all and y<112 then return draw(text,x,y,opts,...) end
      return M.withText(kind,draw,M.clean(text),x,y,options(opts),...)
    end
    F.drawGlyph=function(id,x,y,opts,...)
      if not all and y<112 then return glyph(id,x,y,opts,...) end
      return glyph(id,x,y,options(opts),...)
    end
    local G=love and love.graphics
    local rectangle=G and G.rectangle
    if rectangle and kind=='menu' then
      G.rectangle=function(...)return M.tintFill(rectangle,...)end
    elseif rectangle and kind=='battle' then
      G.rectangle=function(mode,x,y,w,h,...)
        if mode=='fill' and x==16 and y>=112 and w==208 and h==16 then
          local result={pcall(M.paint,M.background(),rectangle,mode,x,y,w,h,...)}
          if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
        end
        return rectangle(mode,x,y,w,h,...)
      end
    end
    local result={pcall(M.withText,kind,fn,...)};F.draw,F.drawGlyph=draw,glyph
    if rectangle then G.rectangle=rectangle end
    if not result[1]then error(result[2],0)end
    return (unpack or table.unpack)(result,2)
  end
  function M.scope(fn,...)return scope(fn,'battle',false,...)end
  function M.menuScope(fn,...)return scope(fn,'menu',true,...)end
  function M.menuOptions(opts)
    local copy={};for k,v in pairs(opts or {})do copy[k]=v end
    copy.colors=M.colors('menu');if opts and opts._choiceColor then copy.colors.fg=M.color('text',opts._choiceColor)end;copy.color=nil;copy.shadow=nil
    return copy
  end
  -- Healthbox renderers print the name first, then gender, level and HP.
  -- Limit this palette to that first text draw, including numeric nicknames.
  function M.nameScope(font,fn,...)
    local draw=font.draw;local used=false
    font.draw=function(text,x,y,opts,...)
      if opts and opts.paletteRole=='battle' then return M.withText('battle',draw,text,x,y,opts,...)end
      if used then
        if tostring(text):find('/',1,true) or tostring(text):match('^[%d%s]+$') or tostring(text):match('^HP') then
          local vanilla={};for k,v in pairs(opts or {})do vanilla[k]=v end;vanilla._vanilla=true
          return draw(text,x,y,vanilla,...)
        end
        return draw(text,x,y,opts,...)
      end
      used=true
      local copy={};for k,v in pairs(opts or {})do copy[k]=v end
      copy.colors=M.colors('name')
      copy.colors.bg=opts and opts.colors and opts.colors.bg or copy.colors.bg
      copy.color=nil;copy.shadow=nil
      return M.withText('name',draw,text,x,y,copy,...)
    end
    local result={pcall(fn,...)};font.draw=draw
    if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
  end
  local inkShader
  local function nativeGlyph(kind,fn,id,...)
    local G=love.graphics
    G.push('all');G.setColor((unpack or table.unpack)(M.colors(kind).fg))
    if id<0x400000 and G.newShader then
      if not inkShader then inkShader=G.newShader([[vec4 effect(vec4 c,Image t,vec2 uv,vec2 p){vec4 s=Texel(t,uv);return vec4(c.rgb,c.a*s.a*(1.0-min(s.r,min(s.g,s.b))));}]])end
      G.setShader(inkShader)
    else G.setShader()end
    local old=M.effects.darkInk;M.effects.darkInk=id<0x400000
    local args={...};local colors=M.colors(kind)
    local result={pcall(M.effects.glyph,colors,tonumber(args[1])or 0,tonumber(args[2])or 0,function(dx,dy)
      G.push('all');G.translate(dx,dy);local painted={pcall(fn,id,(unpack or table.unpack)(args))};G.pop()
      if not painted[1]then error(painted[2],0)end;return (unpack or table.unpack)(painted,2)
    end)};M.effects.darkInk=old;G.pop()
    if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
  end
  -- Native face fallback, including scripts not covered by the Latin atlas.
  -- Use the engine printer for each glyph so encoding/advance stay native.
  local function plainUtf8(text)
    if type(text)~='string'then return false end
    local at=1
    for c in text:gmatch('[%z\1-\127\194-\244][\128-\191]*')do
      if text:sub(at,at+#c-1)~=c then return false end
      local a,b=c:byte(1,2);local size=a<128 and 1 or a<224 and 2 or a<240 and 3 or 4
      if #c~=size or a==224 and b<160 or a==237 and b>=160 or a==240 and b<144 or a==244 and b>=144 then return false end
      at=at+#c
    end
    return at==#text+1
  end
  function M.nativeText(draw,measure,text,x,y,opts)
    local colors=opts and opts.colors
    if not colors or not colors._effects then return M.effects.aspect(x,y,draw,text,x,y,opts)end
    local function one(t,px,py)
      if t==' ' then M.effects.ink(colors,true);return end
      return M.effects.glyph(colors,px,py,function(dx,dy)
        local copy={};for k,v in pairs(opts or {})do copy[k]=v end
        copy.colors={fg={love.graphics.getColor()},shadow={0,0,0,0},bg={0,0,0,0}}
        return draw(t,px+dx,py+dy,copy)
      end,{width=measure and measure(t,opts)or 8,top=opts and opts.small and 3 or 2,height=opts and opts.small and 9 or 11})
    end
    if not plainUtf8(text) or not measure or text:find('[<>]') then return one(text,x,y)end
    return M.withText(colors._kind or 'battle',function()
      local px,py=x,y;local count=0
      for c in text:gmatch('[%z\1-\127\194-\244][\128-\191]*')do
        count=count+1;if opts.limitChars and count>opts.limitChars then break end
        if c=='\n' then px=x;py=py+16
        else local width=measure(c,opts) or 8
          if not opts.maxWidth or px-x+width<=opts.maxWidth then one(c,px,py);px=px+width end
        end
      end
      return px-x,px,py
    end)
  end
  function M.nativeMenuGlyph(fn,id,...)return nativeGlyph('menu',fn,id,...)end
  function M.nativeNameGlyph(fn,id,...)return nativeGlyph('name',fn,id,...)end
  function M.nativeBattleGlyph(fn,id,...)return nativeGlyph('battle',fn,id,...)end
  return M
end
