-- Shared transient previews, text case and coordinated Pokemon presets.
return function(mod)
 local M={};mod.exports.customization=M
 local get,saveGet=mod.options.get,mod.save.get
 mod.options.get=function(self,key)if M.preview and M.preview[key]~=nil then return M.preview[key]end;return get(self,key)end
 mod.save.get=function(self,key,...)if M.preview and M.preview[key]~=nil then return M.preview[key]end;return saveGet(self,key,...)end
 -- Materialize inherited surfaces before changing a single global property.
 -- This avoids reviving old, inactive PC/Mart overrides when enabling them.
 local function surface(v,scope)
  if tonumber(mod.options:get(scope..'Custom'))~=1 then
   for suffix,key in pairs({Theme='menuTheme',BorderChoice='menuBorder',BackgroundColor='menuBackgroundColor',TextColor='menuTextColor',TextShadowColor='menuTextShadowColor'})do
    v[scope..suffix]=mod.options:get(key)or(suffix=='Theme'and 2 or suffix=='BorderChoice'and 1 or 0)
   end
   local P=mod.exports.selectorPalette
   for key,spec in pairs(P and P.effects.specs('menu')or{})do v[scope..key:sub(5)]=mod.options:get(key)or spec[1]end
  end
  v[scope..'Custom']=1
 end
 function M.globalValues(key,n)
  local v={[key]=n}
  if key=='allBorderChoice'or key=='allBackgroundColor'or key=='allTextColor'or key=='allTextShadowColor'or key=='allShadowOpacity'or key=='allFontTheme'or key=='allFontAlign'then
   for _,scope in ipairs({'mart','pc','bag','party','loadReport','mods','trainerCard'})do surface(v,scope)end
  else return nil end
  if key=='allFontTheme'then
   for _,k in ipairs({'menuTheme','dialogueTheme','introTheme','saveSummaryTheme','martTheme','pcTheme','bagTheme','partyTheme','loadReportTheme','modsTheme','trainerCardTheme'})do v[k]=n end
  elseif key=='allFontAlign'then
   for _,scope in ipairs({'start','dialogue','menu','mart','pc','bag','party','battle','intro','save','option','other','pokedex','loadReport','mods','trainerCard'})do v[scope..'Justify']=n end
  elseif key=='allBorderChoice'then
   v.menuBorder=n;v.dialogueBorder=1;v.battle_style=3;v.borderCatalogFormat=2
   for _,scope in ipairs({'start','battle','option','save','other','dialogue','pokedex','mart','pc','bag','party','loadReport','mods','trainerCard'})do v[scope..'BorderChoice']=n end
  elseif key=='allBackgroundColor'then
   for _,k in ipairs({'menuBackgroundColor','startMenuBackgroundColor','dialogueBackgroundColor','saveSummaryBackgroundColor','introBackgroundColor','martBackgroundColor','pcBackgroundColor','bagBackgroundColor','partyBackgroundColor','loadReportBackgroundColor','modsBackgroundColor','trainerCardBackgroundColor'})do v[k]=n end
   v.battle_background_color=math.max(0,n-1)
   -- Keep native void fill opt-in; global changes include enabled voids.
   for _,k in ipairs({'indoorVoidBackgroundColor','outdoorVoidBackgroundColor','battlefieldBackgroundColor'})do if (tonumber(mod.options:get(k))or 0)>0 then v[k]=n end end
  elseif key=='allTextColor'or key=='allTextShadowColor'then
   local keys=key=='allTextColor'and{'menuTextColor','dialogueTextColor','introTextColor','gameFreakTextColor','gameFreakStarsColor','battleHudLevelColor','battleHudHPColor','selectorColor','choiceSelectorColor','battle_text_color','battle_name_color','martTextColor','pcTextColor','bagTextColor','partyTextColor','loadReportTextColor','modsTextColor','trainerCardTextColor'}
    or{'menuTextShadowColor','dialogueTextShadowColor','introTextShadowColor','gameFreakTextShadowColor','battleHudLevelShadowColor','battleHudHPShadowColor','battle_shadow_color','battle_name_shadow_color','martTextShadowColor','pcTextShadowColor','bagTextShadowColor','partyTextShadowColor','loadReportTextShadowColor','modsTextShadowColor','trainerCardTextShadowColor'}
   for _,k in ipairs(keys)do v[k]=n end
  else
   for _,prefix in ipairs({'menu_fx_','intro_fx_','battle_fx_','battle_name_fx_','mart_fx_','pc_fx_','bag_fx_','party_fx_'})do v[prefix..'shadow_transparency']=100-n end
  end
  return v
 end
 function M.values(key,n)
  key=key:gsub('^gen3transparency:','battle_')
  local global=M.globalValues(key,n);if global then return global end
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
 -- Preview artwork must never become the value displayed by another setting.
 function M.withRows(row,rows,fn,...)
  local originals={}
  for _,entry in ipairs(rows or {})do
   for _,key in ipairs({'value','selected','text'})do
    local original=entry[key]
    if type(original)=='function'then
     originals[#originals+1]={entry,key,original}
     entry[key]=function(...)
      local preview=M.preview;M.preview=nil
      local result={pcall(original,...)};M.preview=preview
      if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
     end
    end
   end
  end
  local result={pcall(M.with,row,fn,...)}
  for _,saved in ipairs(originals)do saved[1][saved[2]]=saved[3]end
  if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
 end
 local lowerAccents={['Á']='á',['É']='é',['Í']='í',['Ó']='ó',['Ú']='ú',['Ü']='ü',['Ñ']='ñ'}
 local upperAccents={};for upper,lower in pairs(lowerAccents)do upperAccents[lower]=upper end
 local properNames=assert(load(assert(mod:read('lib/proper_names.lua'))))()(mod)
 local modes={'ORIGINAL','SENTENCE CASE','LOWERCASE','TITLE CASE'}
 function M.text(text,game)
  if mod.exports.jumpWave and mod.exports.jumpWave.active then return text end
  if type(text)~='string'then return text end
  if game then properNames.observe(game.save)end
  local C=mod.exports.gbMenus
  local mode=mod.exports.textScopes and mod.exports.textScopes.mode()or tonumber(mod.options:get(C and C.introScope and 'introTextCase'or 'textCase'))or 0
  if mode==0 then return text end
  -- Leave encoded control tags untouched; never rewrite game data.
  local out={};local at=1;local first=true;local inWord=false
  while at<=#text do
   local a,b=text:find('<[^>]*>',at);local c,d=text:find('{[^}]*}',at)
   if c and(not a or c<a)then a,b=c,d end
   local chunk=text:sub(at,a and a-1 or #text):lower()
   for upper,lower in pairs(lowerAccents)do chunk=chunk:gsub(upper,lower)end
   if mode==1 then
    if first then chunk=chunk:gsub('(%a)',string.upper,1);if chunk:find('%a')then first=false end end
    chunk=chunk:gsub('([%.%!%?]%s+)(%a)',function(p,c)return p..c:upper()end)
    chunk=chunk:gsub('%f[%w]i%f[%W]','I')
   end
   if mode==3 then
    chunk=chunk:gsub('[%z\1-\127\194-\244][\128-\191]*',function(c)
     -- UTF-8 bytes stay within the word (e.g. Pokemon's accented e).
     if c:match('%w')or c:byte()>=128 then
      local result=not inWord and (upperAccents[c]or c:upper())or c;inWord=true;return result
     end
     if c~="'"then inWord=false end
     return c
    end)
   end
   if mode==1 then chunk=properNames.restore(chunk)end
   if mode==1 or mode==3 then chunk=properNames.players(chunk)end
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
  local out={{id='wide_textCase',label='ALL DECAPITALIZATION',value=function()return modes[(tonumber(mod.options:get('textCase'))or 0)+1]end,
   step=function(ctx,dir)local n=((tonumber(mod.options:get('textCase'))or 0)+(dir or 1))%#modes;M.write(ctx,mod.exports.textScopes and mod.exports.textScopes.values(n)or{textCase=n})end}}
  M.themes={} -- Presets retired; individual customizations remain available.
  if mod.generation==3 then
   local P,B=mod.exports.selectorPalette,mod.exports.borderCatalog
   for _,spec in ipairs({{'allBorderChoice','ALL BORDERS',1,B.choices,1},{'allBackgroundColor','ALL BACKGROUNDS',0,P.menuBackgroundNames,0,'menuBackground'},
    {'allTextColor','ALL COLORS',0,P.names,0,'text'},{'allTextShadowColor','ALL SHADOWS',0,P.shadowNames,0,'shadow'},{'allShadowOpacity','ALL SHADOW OPACITY',100,nil,0}})do
    local k,title,default,names,minimum,kind=(unpack or table.unpack)(spec)
    local function current()return tonumber(mod.options:get(k))or default end
    local function write(ctx,n)M.write(ctx,M.globalValues(k,n));return false end
    local row={id='wide_'..k,label=title,value=function()local n=current();return names and names[n-minimum+1]or tostring(n)..'%'end,
     preview=function()return M.values(k,current())end,step=function(ctx,dir)
      local n=names and(minimum+(current()-minimum+(dir or 1))%#names)or math.max(0,math.min(100,current()+(dir or 1)*5))
      return write(ctx,n)
     end,customization=M}
    if kind then P.picker(row,kind,current,write,openPage)
    elseif names then P.designPicker(row,B.groups,current,write,openPage)end
    out[#out+1]=row
   end
  end
  if mod.exports.jumpWave then for _,row in ipairs(mod.exports.jumpWave.rows())do out[#out+1]=row end end
  if mod.exports.allFonts then out[#out+1]=mod.exports.allFonts.row(openPage)end
  if mod.exports.textScopes then for _,row in ipairs(mod.exports.textScopes.rows(openPage))do out[#out+1]=row end end
  if mod.exports.battleHudCustomization then for _,row in ipairs(mod.exports.battleHudCustomization.rows(openPage))do out[#out+1]=row end end
  if mod.exports.animationSpeeds then for _,row in ipairs(mod.exports.animationSpeeds.rows(openPage))do out[#out+1]=row end end
  if mod.exports.battlefieldBackground then for _,row in ipairs(mod.exports.battlefieldBackground.rows(openPage))do out[#out+1]=row end end
  if mod.exports.voidBackgrounds then for _,row in ipairs(mod.exports.voidBackgrounds.rows(openPage))do out[#out+1]=row end end
  return out
 end
 return M
end
