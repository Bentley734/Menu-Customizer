-- Independent casing with the existing global choice as a saved-data fallback.
return function(mod)
 local M={};mod.exports.textScopes=M
 M.scopes={{'menu','MENUS'},{'start','START MENU'},{'option','OPTIONS'},{'dialogue','DIALOGUE'},{'intro','INTRO / TITLE'},
 {'saveSummary','SAVE SUMMARY'},{'mart','POKE MART'},{'pc','PC'},{'battle','BATTLE'},{'battleName','BATTLE NAMES'},
 {'party','PARTY'},{'bag','BAG'},{'summary','POKEMON SUMMARY'},{'pokedex','POKEDEX'},{'trainerCard','TRAINER CARD'},{'other','OTHER MENUS'}}
 function M.currentScope()
  local e=mod.exports;local c=e.gbMenus
  if c and c.introScope then return'intro'end
  if c and c.summaryScope then return'saveSummary'end
  if e.battleNameScope then return'battleName'end
  if e.battleFontScope then return'battle'end
  if e.dialogueFontScope or c and c.dialogueScope then return'dialogue'end
  if e.menuSurfaces and e.menuSurfaces.current then return e.menuSurfaces.current end
  if M.current then return M.current end
  local group=e.menuPaperScope or c and c.paperGroup
  return group=='save'and'saveSummary'or group or'menu'
 end
 function M.mode(scope)
  scope=scope or M.currentScope()
  return tonumber(mod.options:get(scope..'TextCase'))or tonumber(mod.options:get('textCase'))or 0
 end
 function M.values(n)
  local values={textCase=n};for _,s in ipairs(M.scopes)do values[s[1]..'TextCase']=n end;return values
 end
 function M.with(scope,fn,...)
  local prior=M.current;M.current=scope;local out={pcall(fn,...)};M.current=prior
  if not out[1]then error(out[2],0)end;return (unpack or table.unpack)(out,2)
 end
 function M.rows(openPage)
  local C=mod.exports.customization;local P=mod.exports.selectorPalette;local names={'ORIGINAL','SENTENCE CASE','LOWERCASE','TITLE CASE'};local rows={}
  for _,s in ipairs(M.scopes)do local scope,label=s[1],s[2];local key=scope..'TextCase'
   rows[#rows+1]={id='wide_'..key,label=label..' DECAPITALIZATION',value=function()return names[M.mode(scope)+1]end,
    step=function(ctx,d)C.write(ctx,{[key]=(M.mode(scope)+(d or 1))%4});return false end}
  end
  local function current()return tonumber(mod.options:get('gameFreakTextColor'))or tonumber(mod.options:get('introTextColor'))or 0 end
  local function write(ctx,n)C.write(ctx,{gameFreakTextColor=n});return false end
  local row={id='wide_gameFreakTextColor',label='GAME FREAK LOGO COLOR',value=function()return P.names[current()+1]end,step=function(ctx,d)return write(ctx,(current()+(d or 1))%#P.names)end}
  P.picker(row,'text',current,write,openPage);rows[#rows+1]=row
  local function shadow()return tonumber(mod.options:get('gameFreakTextShadowColor'))or tonumber(mod.options:get('introTextShadowColor'))or 0 end
  local function writeShadow(ctx,n)C.write(ctx,{gameFreakTextShadowColor=n});return false end
  local shade={id='wide_gameFreakTextShadowColor',label='GAME FREAK LOGO SHADOW',value=function()return P.shadowNames[shadow()+1]end,step=function(ctx,d)return writeShadow(ctx,(shadow()+(d or 1))%#P.shadowNames)end}
  P.picker(shade,'shadow',shadow,writeShadow,openPage);rows[#rows+1]=shade
  local function stars()return tonumber(mod.options:get('gameFreakStarsColor'))end
  local function writeStars(ctx,n)C.write(ctx,{gameFreakStarsColor=n});return false end
  local starRow={id='wide_gameFreakStarsColor',label='GAME FREAK FALLING STARS COLOR',value=function()local n=stars();return n and P.names[n+1]or 'NATIVE'end,
   step=function(ctx,d)return writeStars(ctx,((stars()or 0)+(d or 1))%#P.names)end}
  P.picker(starRow,'text',function()return stars()or 0 end,writeStars,openPage);rows[#rows+1]=starRow
  return rows
 end
 function M.install()
  local specs={}
  if mod.generation<3 then
   local prefix=mod.generation==2 and'src.ui.gen2.'or'src.ui.'
   for _,s in ipairs({{'PartyMenu','party'},{'BagMenu','bag'},{'SummaryMenu','summary'},{'PokedexMenu','pokedex'},{'TrainerCard','trainerCard'},{'StartMenu','start'}})do specs[#specs+1]={prefix..s[1],s[2]}end
   specs[#specs+1]={'src.ui.gen2.PackMenu','bag'};specs[#specs+1]={'src.ui.OptionsMenu','option'};specs[#specs+1]={'src.ui.gen2.OptionsMenu','option'}
  else
   for _,s in ipairs({{'party_menu','party'},{'bag_menu','bag'},{'summary_menu','summary'},{'pokedex','pokedex'},{'trainer_card','trainerCard'},{'start_menu','start'},{'option_menu','option'}})do
    for _,prefix in ipairs({'src.ui.game3.','src.ui.game3.rse.','src.ui.game3.rs.'})do specs[#specs+1]={prefix..s[1],s[2]}end
   end
  end
  if mod.generation==2 then
   local Chrome=require('src.ui.gen2.Chrome')
   for _,key in ipairs({'print','printThrough','printInverted','printRight','printRightThrough','printWrapped'})do
    local fn=Chrome[key]
    if fn and not Chrome['_customCase_'..key]then
     Chrome['_customCase_'..key]=true
     Chrome[key]=function(text,...)return fn(mod.exports.customization.text(text),...)end
    end
   end
  end
  for _,s in ipairs(specs)do
   local ok,target=pcall(require,s[1]);local scope=s[2]
   if ok and type(target)=='table'and target.draw and not target._customTextScope then
    target._customTextScope=true;local draw=target.draw;target.draw=function(...)return M.with(scope,draw,...)end
   end
  end
 end
 return M
end
