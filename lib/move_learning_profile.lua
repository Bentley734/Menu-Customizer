-- Independent prompts, choices and forget-list visuals for move learning.
return function(mod)
 local M={};mod.exports.moveLearningProfile=M
 local get,saveGet=mod.options.get,mod.save.get
 local keys={menuTheme='Theme',dialogueTheme='Theme',menuBorder='BorderChoice',otherBorderChoice='BorderChoice',optionBorderChoice='BorderChoice',dialogueBorderChoice='BorderChoice',
  menuTextColor='TextColor',dialogueTextColor='TextColor',menuTextShadowColor='TextShadowColor',dialogueTextShadowColor='TextShadowColor',
  menuBackgroundColor='BackgroundColor',dialogueBackgroundColor='BackgroundColor',otherJustify='Justify',menuJustify='Justify',optionJustify='Justify',dialogueJustify='Justify',
  arrowSelector='Selector',selectorColor='SelectorColor'}
 local function resolve(key)
  if not M.active or get(mod.options,'moveLearningCustom')~=1 then return end
  if key=='dialogueBorder'then return 1 end
  local suffix=keys[key]or key:match('^menu_fx_(.*)')and key:sub(5)
  local k=suffix and'moveLearning'..suffix
  if k then local v=get(mod.options,k);if v==nil then v=saveGet(mod.save,k)end;return v end
 end
 mod.options.get=function(self,key)local v=resolve(key);if v~=nil then return v end;return get(self,key)end
 mod.save.get=function(self,key,...)local v=resolve(key);if v~=nil then return v end;return saveGet(self,key,...)end
 function M.with(fn,...)
  local prior=M.active;M.active=true;local out={pcall(fn,...)};M.active=prior
  if not out[1]then error(out[2],0)end;return(unpack or table.unpack)(out,2)
 end
 function M.rows(openPage)
  local P=mod.exports.selectorPalette;local C=mod.exports.customization;local out={}
  local function add(suffix,label,default,minimum,maximum,names,kind,fallback)
   local key='moveLearning'..suffix
   local function value()return tonumber(get(mod.options,key))or(fallback and tonumber(get(mod.options,fallback)))or default end
   local function write(ctx,n)C.write(ctx,{[key]=n,moveLearningCustom=suffix=='Custom'and n or 1,borderCatalogFormat=2});return false end
   local row={id='wide_'..key,label='MOVE LEARNING '..label,value=function()local n=value();return names and names[n-minimum+1]or tostring(n)end,
    step=function(ctx,d)return write(ctx,minimum+(value()-minimum+(d or 1))%(maximum-minimum+1))end}
   if kind then P.picker(row,kind,value,write,openPage)end
   if suffix=='BorderChoice'then
    local cat=mod.exports.borderCatalog;row.customization=C
    P.designPicker(row,cat.groups,value,write,openPage);row.value=function()return cat.choices[value()]or'NATIVE'end
   end
   out[#out+1]=row
  end
  add('Custom','STYLE',0,0,1,{'USE CURRENT','CUSTOM'})
  add('Theme','FONT',2,1,2,{'NATIVE','EMERALD'},nil,'menuTheme')
  add('TextCase','LETTER CASE',0,0,3,{'ORIGINAL','SENTENCE CASE','LOWERCASE','TITLE CASE'},nil,'textCase')
  add('Justify','ALIGNMENT',1,1,3,{'LEFT','CENTER','RIGHT'},nil,'dialogueJustify')
  add('BorderChoice','BORDER',1,0,#mod.exports.borderCatalog.choices,nil,nil,'dialogueBorderChoice')
  add('BackgroundColor','BACKGROUND',0,0,#P.menuBackgroundNames-1,P.menuBackgroundNames,'menuBackground','dialogueBackgroundColor')
  add('TextColor','TEXT COLOR',0,0,#P.names-1,P.names,'text','dialogueTextColor')
  add('TextShadowColor','TEXT SHADOW',0,0,#P.shadowNames-1,P.shadowNames,'shadow','dialogueTextShadowColor')
  add('Selector','SELECTOR',1,1,13,mod.exports.arrowSelectors.names,nil,'arrowSelector')
  add('SelectorColor','SELECTOR COLOR',0,0,#P.names-1,P.names,'text','selectorColor')
  for _,row in ipairs(P.effects.rows('moveLearning',function(ctx,key,n)C.write(ctx,{[key]=n,moveLearningCustom=1});return false end,openPage))do out[#out+1]=row end
  return out
 end
 function M.install()
  if mod.generation~=1 then return end
  local Learn=require('src.ui.MoveLearnMenu');local Text=require('src.render.TextBox');local Choice=require('src.ui.ChoiceBox')
  local function learning(game)
   for _,state in ipairs(game and game.stack and game.stack.states or{})do
    if getmetatable(state)==Learn or state._menuCustomizerLearning then return true end
   end
   return false
  end
  local function wrap(target,key)
   local fn=target[key];if not fn then return end
   target[key]=function(self,...)
    if M.active or self._menuCustomizerLearning or learning(self.game)then return M.with(fn,self,...)end
    return fn(self,...)
   end
  end
  for _,key in ipairs({'enter','askForget','confirmAbandon','finish','update','draw'})do wrap(Learn,key)end
  local new=Text.new
  Text.new=function(game,...)
   local function create(...)local box=new(game,...);box._menuCustomizerLearning=true;return box end
   if M.active or learning(game)then return M.with(create,...)end
   return new(game,...)
  end
  wrap(Text,'draw');wrap(Choice,'draw')
  local draw=Learn.draw
  Learn.draw=function(self,...)
   if not mod.exports.menuSurfaces.enabled()or get(mod.options,'moveLearningCustom')~=1 then return draw(self,...)end
   local args={...};return M.with(function()
    local e=mod.exports;local c=e.gbMenus;local ds,ps,cs=c.drawScope,c.paperGroup,e.choiceFontScope
    c.drawScope,c.paperGroup,e.choiceFontScope=true,'other',true
    local out={pcall(e.allFonts.withFrame,'other',draw,self,(unpack or table.unpack)(args))}
    c.drawScope,c.paperGroup,e.choiceFontScope=ds,ps,cs
    if not out[1]then error(out[2],0)end;return(unpack or table.unpack)(out,2)
   end)
  end
 end
 return M
end
