-- Shared transient previews, text case and coordinated Pokemon presets.
return function(mod)
 local M={};mod.exports.customization=M
 local get,saveGet=mod.options.get,mod.save.get
 mod.options.get=function(self,key)if M.preview and M.preview[key]~=nil then return M.preview[key]end;return get(self,key)end
 mod.save.get=function(self,key,...)if M.preview and M.preview[key]~=nil then return M.preview[key]end;return saveGet(self,key,...)end
 function M.values(key,n)
  key=key:gsub('^gen3transparency:','battle_')
  local v={[key]=n}
  if key:find('Border')then for _,s in ipairs({'option','other'})do v[s..'BorderChoice']=n end;v.menuBorder=n;v.borderCatalogFormat=2
  elseif key:find('Background')or key:find('background_color')then v.menuBackgroundColor=n;v.startMenuBackgroundColor=n;v.dialogueBackgroundColor=n;if key:find('background_color')then v.menuBackgroundColor=n+1 end
  elseif key:find('ShadowColor')or key:find('shadow_color')then v.menuTextShadowColor=n
  elseif key:find('TextColor')or key:find('text_color')or key:find('name_color')or key=='selectorColor'then v.menuTextColor=n
  elseif key:find('Theme')then v.menuTheme=n
  elseif key:find('Justify')then v.startJustify=n
  elseif key=='arrowSelector'then v.arrowSelector=n
  elseif key=='startSelector'then v.startSelector=n
  elseif key:find('_fx_')then v['menu_fx_'..key:match('_fx_(.*)')]=n end
  local suffix=key:match('^[a-z]+(Position)$')or key:match('^[a-z]+(Scale)$')or key:match('^[a-z]+(Width)$')or key:match('^[a-z]+(Height)$')or key:match('^[a-z]+(OffsetX)$')or key:match('^[a-z]+(OffsetY)$')or key:match('^[a-z]+(Opacity)$')
  if suffix then v['option'..suffix]=n end
  return v
 end
 function M.with(row,fn,...)
  local old=M.preview
  if row and row.preview then M.preview=row.preview()end
  local result={pcall(fn,...)};M.preview=old
  if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
 end
 local modes={'ORIGINAL','SENTENCE CASE','LOWERCASE'}
 function M.text(text)
  if type(text)~='string'then return text end
  local mode=tonumber(mod.options:get('textCase'))or 0
  if mode==0 then return text end
  -- Leave encoded control tags untouched; never rewrite game data.
  local out={};local at=1;local first=true
  while at<=#text do
   local a,b=text:find('<[^>]*>',at);local c,d=text:find('{[^}]*}',at)
   if c and(not a or c<a)then a,b=c,d end
   local chunk=text:sub(at,a and a-1 or #text):lower()
   if mode==1 then
    if first then chunk=chunk:gsub('(%a)',string.upper,1);if chunk:find('%a')then first=false end end
    chunk=chunk:gsub('([%.%!%?]%s+)(%a)',function(p,c)return p..c:upper()end)
   end
   out[#out+1]=chunk;if not a then break end;out[#out+1]=text:sub(a,b);at=b+1
  end
  return table.concat(out)
 end
 function M.installText()
  for _,path in ipairs({'src.render.Font','src.ui.game3.frlg_font'})do
   local ok,F=pcall(require,path)
   if ok and not F._customizationCase then
    F._customizationCase=true
    for _,key in ipairs({'draw','drawText','width','measure'})do
     local old=F[key]
     if type(old)=='function'then F[key]=function(text,...)return old(M.text(text),...)end end
    end
   end
  end
 end
 function M.write(ctx,values)
  local game=ctx.game or ctx;local options=game.options or game.save and game.save.options
  if not options then return end
  options.modOptions=options.modOptions or {};local bucket=options.modOptions[mod.id]or {};options.modOptions[mod.id]=bucket
  for k,v in pairs(values)do bucket[k]=v end
  if game.mods then game.mods.modOptions[mod.id]=bucket end
  if mod.exports.settingsProfiles then mod.exports.settingsProfiles.commit(game)end
  if mod.exports.resetMenuSettings then mod.exports.resetMenuSettings()end
  if game.writeOptions then game:writeOptions()end
 end
 function M.rows(openPage)
  local out={{id='wide_textCase',label='TEXT DECAPITALIZATION',value=function()return modes[(tonumber(mod.options:get('textCase'))or 0)+1]end,
   step=function(ctx,dir)M.write(ctx,{textCase=((tonumber(mod.options:get('textCase'))or 0)+(dir or 1))%3})end}}
  local themes={
   {'PIKACHU','PIKACHU SPARKS','BLACK & GOLD','CREAM','CHARCOAL'},
   {'BULBASAUR','BULBASAUR GARDEN','FOREST GREEN','PALE GREEN','FOREST'},
   {'CHARMANDER','CHARMANDER EMBERS','RED','CREAM','RED'},
   {'SQUIRTLE','SQUIRTLE LAGOON','BLUE','PALE BLUE','BLUE'},
   {'MEW','MEW STARDUST','LILAC TILE','PLUM','WHITE'},
   {'GENGAR','GENGAR HAUNT','LILAC TILE','PLUM','WHITE'},
   {'EEVEE','EEVEE COZY','GOLD RIBBON','CREAM','CHARCOAL'},
   {'JIGGLYPUFF','JIGGLYPUFF LULLABY','PASTEL STRIPE','CREAM','PURPLE'},
   {'DRAGONAIR','DRAGONAIR DREAM','BLUE','PALE BLUE','BLUE'},
   {'UMBREON','UMBREON MOONLIGHT','BLACK & GOLD','NAVY','WHITE'},
   {'SNORLAX','SNORLAX SNOOZE','FOREST GREEN','PALE GREEN','CHARCOAL'},
   {'HOENN FOREST','PETALBURG FIREFLIES','FOREST GREEN','PALE GREEN','WHITE'},
   {'SOOTOPOLIS','SOOTOPOLIS LAGOON','BLUE','PALE BLUE','WHITE'},
   {'VOLCANO','MT CHIMNEY EMBERS','RED','PLUM','WHITE'},
   {'SKY PILLAR','SKY PILLAR CLOUDS','SILVER','NAVY','WHITE'}}
  local function locate(names,name,zero)for i,n in ipairs(names)do if n==name then return i-(zero and 1 or 0)end end;return zero and 0 or 1 end
  local function values(t)
   local P=mod.exports.selectorPalette;local B=mod.exports.borderCatalog
   local bg=locate(P.menuBackgroundNames,t[2],true);local color=locate(P.names,t[5],true)
   local border=locate(B.choices,t[3],false)
   local v={menuTheme=2,dialogueTheme=2,menuBorder=border,borderCatalogFormat=2,menuBackgroundColor=bg,startMenuBackgroundColor=bg,dialogueBackgroundColor=bg,
    menuTextColor=color,dialogueTextColor=color,menuTextShadowColor=1,dialogueTextShadowColor=1,selectorColor=color,arrowSelector=2,startSelector=1,selectionHighlight=30,
    battle_style=3,battle_opacity=100,battle_font_size=0,battle_text_color=color,battle_name_color=color,battle_background_color=locate(P.backgroundNames,t[4],true),battle_shadow_color=1,battle_name_shadow_color=1,dialogueBorder=1,startJustify=1,dialogueJustify=1,menuTransition=3,backgroundDim=20,opacityFormat=2}
   for _,s in ipairs({'start','option','other','save','battle','dialogue','pokedex'})do v[s..'BorderChoice']=border end
   for _,s in ipairs({'start','option','other'})do v[s..'Opacity']=100 end
   for _,prefix in ipairs({'menu_fx_','battle_fx_','battle_name_fx_'})do
    v[prefix..'preset']=0;v[prefix..'alternate']=0;v[prefix..'highlight']=0;v[prefix..'outline']=0;v[prefix..'shadow_transparency']=35
   end
   return v
  end
  local choices={};for _,t in ipairs(themes)do local theme=t
   choices[#choices+1]={id='theme_'..theme[1],label=theme[1],preview=function()return values(theme)end,value=function()return 'APPLY'end,activate=function(ctx)M.write(ctx,values(theme))end}
  end
  out[#out+1]={id='wide_themeSets',label='POKEMON THEMES',group=true,activate=function(ctx)return openPage('POKEMON THEMES',choices,ctx)end}
  return out
 end
 return M
end
