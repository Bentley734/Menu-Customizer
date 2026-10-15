-- Existing saved IDs remain stable; navigation follows customization type.
return function(entries,openPage)
 local order={'TEXT','BORDERS','BACKGROUNDS','TRANSITIONS','SELECTORS','POSITION','TRANSPARENCY'}
 -- Shorten only presentation copies: callbacks, keys and source rows stay intact.
 local function compact(row,words)
  local copy={};for k,v in pairs(row)do copy[k]=v end
  local label=row.label or ''
  for _,word in ipairs(words)do label=label:gsub('%f[%a]'..word..'%f[%A]','')end
  label=label:gsub('%s+',' '):match('^%s*(.-)%s*$')
  copy.label=label~=''and label or row.label
  return copy
 end
 local storage,themes,fonts,textSpeeds
 local pages={};for _,name in ipairs(order)do pages[name]={}end
 local function add(r)
  if r.id=='wide_animationSpeeds_text'then textSpeeds=r;return end
  if r.id=='wide_animationSpeeds_background'then pages.BACKGROUNDS[#pages.BACKGROUNDS+1]=r;return end
  if r.id=='wide_animationSpeeds_border'then pages.BORDERS[#pages.BORDERS+1]=r;return end
  if r.id=='wide_surface_mart'or r.id=='wide_surface_pc'or r.id=='wide_surface_dialogue'then
   local prefix=r.id=='wide_surface_mart'and'POKE MART'or r.id=='wide_surface_pc'and'PC'or'DIALOGUE'
   for _,child in ipairs(r.children)do
    -- Copy the presentation row; the original callbacks and saved keys survive.
    local row={};for k,v in pairs(child)do row[k]=v end
    row.label=prefix..' '..child.label;add(row)
   end
   return
  end
  if r.id=='wide_settingsScope'then storage=r;return end
  if r.id=='wide_themeSets'then themes=r;return end
  if r.id=='wide_allFonts'then fonts=r;return end
  if r.children then local children=type(r.children)=='function'and r.children()or r.children;for _,child in ipairs(children)do add(child)end;return end
  local key=r.id or '';local dest
  if key:find('menuTransition',1,true)then r.label='MISC TRANSITIONS'end
  if key:find('Selector',1,true)or key:find('selectorColor',1,true)or key:find('selectionHighlight',1,true)then dest='SELECTORS'
  elseif key:find('battleHudFrame',1,true)then dest='BORDERS'
  elseif key:find('Border',1,true)or key:find(':style',1,true)then dest='BORDERS'
  elseif key:find('Background',1,true)or key:find('background_color',1,true)then dest='BACKGROUNDS'
  elseif key:find('scene_',1,true)or key:find('Transition',1,true)then dest='TRANSITIONS'
  elseif key:find('Opacity',1,true)or key:find(':opacity',1,true)or key:find('_transparency',1,true)or key:find('backgroundDim',1,true)then dest='TRANSPARENCY'
  elseif key:find('Position',1,true)or key:find('Offset',1,true)or key:find('Scale',1,true)or key:find('Width',1,true)or key:find('Height',1,true)or key:find('positionPreview',1,true)or key:find('menu_align',1,true)or key:find('menu_stretch',1,true)then dest='POSITION'
  else dest='TEXT'end
  if dest=='BACKGROUNDS'then r=compact(r,{'BACKGROUNDS','BACKGROUND'})
  elseif dest=='BORDERS'then r=compact(r,{'BORDERS','BORDER'})end
  pages[dest][#pages[dest]+1]=r
 end
 for _,r in ipairs(entries)do add(r)end
 local textOrder={'FONT AND LAYOUT','COLORS','SHADOWS','MENU EFFECTS','BATTLE EFFECTS','NAME EFFECTS'}
 local textPages={};for _,name in ipairs(textOrder)do textPages[name]={}end
 for _,row in ipairs(pages.TEXT)do
  local key=(row.id or ''):lower();local category
  if key:find('_fx_',1,true)then
   category=key:find('name',1,true)and 'NAME EFFECTS'or key:find('battle',1,true)and 'BATTLE EFFECTS'or 'MENU EFFECTS'
  elseif key:find('shadow',1,true)then category='SHADOWS'
  elseif key:find('color',1,true)then category='COLORS'
  else category='FONT AND LAYOUT'end
  local words={'TEXT'}
  if category=='COLORS'then words={'TEXT','COLOR','COLORS'}
  elseif category=='SHADOWS'then words={'TEXT','SHADOW','SHADOWS','COLOR','COLORS'}end
  local list=textPages[category];list[#list+1]=compact(row,words)
 end
 -- Keep global controls here; menu-specific controls get one focused page.
 local layout,menus,menuOrder={},{},{'MENUS','START MENU','OPTIONS','DIALOGUE','INTRO / TITLE','SAVE SUMMARY','POKE MART','PC','BATTLE','BATTLE NAMES','PARTY','BAG','POKEMON SUMMARY','POKEDEX','TRAINER CARD','OTHER MENUS'}
 for _,name in ipairs(menuOrder)do menus[name]={}end
 for _,row in ipairs(textPages['FONT AND LAYOUT'])do
  local key=(row.id or ''):gsub('^wide_',''):gsub('^surface_',''):lower();local group
  if key=='textcase'or key:find('^all')or key=='controlslegend'then layout[#layout+1]=row
  else
   if key:find('intro',1,true)then group='INTRO / TITLE'
   elseif key:find('savesummary',1,true)or key:find('save',1,true)==1 then group='SAVE SUMMARY'
   elseif key:find('mart',1,true)then group='POKE MART'
   elseif key:find('pc',1,true)==1 then group='PC'
   elseif key:find('battlename',1,true)or key:find('battle_name',1,true)then group='BATTLE NAMES'
   elseif key:find('battle',1,true)then group='BATTLE'
   elseif key:find('dialogue',1,true)then group='DIALOGUE'
   elseif key:find('party',1,true)then group='PARTY'
   elseif key:find('bag',1,true)then group='BAG'
   elseif key:find('summary',1,true)then group='POKEMON SUMMARY'
   elseif key:find('pokedex',1,true)then group='POKEDEX'
   elseif key:find('trainer',1,true)then group='TRAINER CARD'
   elseif key:find('start',1,true)then group='START MENU'
   elseif key:find('option',1,true)then group='OPTIONS'
   elseif key:find('menu',1,true)then group='MENUS'
   else group='OTHER MENUS'end
   menus[group][#menus[group]+1]=row
  end
 end
 if fonts then table.insert(layout,1,fonts)end
 for _,name in ipairs(menuOrder)do local children=menus[name]
  if #children>0 then layout[#layout+1]={id='wide_layout_'..name,label=name,group=true,children=children,
   value=function()return #children..' OPTIONS'end,activate=function(ctx)return openPage(name,children,ctx)end}end
 end
 textPages['FONT AND LAYOUT']=layout
 pages.TEXT={}
 for _,name in ipairs(textOrder)do
  local children=textPages[name]
  if #children>0 then pages.TEXT[#pages.TEXT+1]={id='wide_text_page_'..name,label=name,group=true,children=children,
   value=function()return #children..' OPTIONS'end,activate=function(ctx)return openPage(name,children,ctx)end}end
 end
 if textSpeeds then pages.TEXT[#pages.TEXT+1]=textSpeeds end
 -- Global controls belong at the top of their matching page.
 for _,name in ipairs({'BORDERS','BACKGROUNDS'})do
  for i,row in ipairs(pages[name])do if (row.id or ''):find('wide_all',1,true)==1 then table.remove(pages[name],i);table.insert(pages[name],1,row);break end end
 end
 local out={}
 for _,name in ipairs(order)do local children=pages[name]
  out[#out+1]={id='wide_page_'..name,label=name,group=true,children=children,value=function()return #children..' OPTIONS'end,activate=function(ctx)return openPage(name,children,ctx)end}
 end
 if themes then out[#out+1]=themes end
 if storage then out[#out+1]=storage end
 return out
end
