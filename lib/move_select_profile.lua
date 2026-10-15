-- Independent move-selection visuals; untouched settings inherit the battle UI.
return function(mod)
 local M={};mod.exports.moveSelectProfile=M
 local get,saveGet=mod.options.get,mod.save.get
 local keys={menuTheme='Theme',battleBorderChoice='BorderChoice',menuBorder='BorderChoice',battle_text_color='TextColor',battle_shadow_color='TextShadowColor',
  battle_background_color='BackgroundColor',battle_font_size='FontSize',battle_move_layout='Layout',battleJustify='Justify',battleTextCase='TextCase',
  arrowSelector='Selector',selectorColor='SelectorColor',battle_opacity='Opacity',battle_style='Style'}
 local function resolve(key)
  if not M.active or get(mod.options,'moveSelectCustom')~=1 then return end
  local suffix=keys[key]or key:match('^battle_fx_(.*)')and key:sub(7)
  local k=suffix and'moveSelect'..suffix
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
   local key='moveSelect'..suffix
   local function value()return tonumber(get(mod.options,key))or(fallback and tonumber(get(mod.options,fallback)))or default end
   local function write(ctx,n)C.write(ctx,{[key]=n,moveSelectCustom=suffix=='Custom'and n or 1,borderCatalogFormat=2});return false end
   local row={id='wide_'..key,label='MOVE SELECT '..label,value=function()local n=value();return names and names[n-minimum+1]or tostring(n)end,
    step=function(ctx,d)return write(ctx,minimum+(value()-minimum+(d or 1))%(maximum-minimum+1))end}
   if kind then P.picker(row,kind,value,write,openPage)end
   if suffix=='BorderChoice'then
    local cat=mod.exports.borderCatalog;row.customization=C
    P.designPicker(row,cat.groups,value,write,openPage);row.value=function()return cat.choices[value()]or'NATIVE'end
   end
   out[#out+1]=row
  end
  add('Custom','STYLE',0,0,1,{'USE BATTLE','CUSTOM'})
  add('Theme','FONT',2,1,2,{'NATIVE','EMERALD'},nil,'menuTheme')
  add('FontSize','FONT SIZE',0,0,2,{'NORMAL','LARGE','EXTRA LARGE'},nil,'battle_font_size')
  add('Layout','LAYOUT',0,0,1,{'GRID','LIST'},nil,'battle_move_layout')
  add('Justify','ALIGNMENT',1,1,3,{'LEFT','CENTER','RIGHT'},nil,'battleJustify')
  add('BorderChoice','BORDER',1,0,#mod.exports.borderCatalog.choices,nil,nil,'battleBorderChoice')
  add('BackgroundColor','BACKGROUND',0,0,#P.backgroundNames-1,P.backgroundNames,'background','battle_background_color')
  add('TextColor','TEXT COLOR',0,0,#P.names-1,P.names,'text','battle_text_color')
  add('TextShadowColor','TEXT SHADOW',0,0,#P.shadowNames-1,P.shadowNames,'shadow','battle_shadow_color')
  add('Selector','SELECTOR',1,1,13,mod.exports.arrowSelectors.names,nil,'arrowSelector')
  add('SelectorColor','SELECTOR COLOR',0,0,#P.names-1,P.names,'text','selectorColor')
  add('OffsetX','OFFSET X',0,-128,128)
  add('OffsetY','OFFSET Y',0,-128,128)
  add('Opacity','OPACITY',100,0,100,nil,nil,'battle_opacity')
  for _,row in ipairs(P.effects.rows('moveSelect',function(ctx,key,n)C.write(ctx,{[key]=n,moveSelectCustom=1});return false end,openPage))do out[#out+1]=row end
  return out
 end
 function M.install()
  local ui=mod.exports.battleUi;local draw=ui.moveScreen.draw
  ui.moveScreen.draw=function(battle,rect,viewport)
   if get(mod.options,'moveSelectCustom')==1 then
    local copy={};for k,v in pairs(rect)do copy[k]=v end
    copy.x=rect.x+(tonumber(get(mod.options,'moveSelectOffsetX'))or 0);copy.y=rect.y+(tonumber(get(mod.options,'moveSelectOffsetY'))or 0);rect=copy
   end
   return M.with(draw,battle,rect,viewport)
  end
  if mod.generation<3 then
   local B=require(mod.generation==1 and'src.battle.BattleState'or'src.ui.gen2.BattleState');local nav=B.moveGridNavigation
   if nav then B.moveGridNavigation=function(...)return M.with(nav,...)end end
  end
 end
 return M
end
