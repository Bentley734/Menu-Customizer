-- Existing saved IDs remain stable; navigation follows customization type.
return function(entries,openPage)
 local order={'TEXT','BORDERS','BACKGROUNDS','TRANSITIONS','SELECTORS','POSITION','TRANSPARENCY'}
 local storage,themes;local intro={}
 local pages={};for _,name in ipairs(order)do pages[name]={}end
 local function add(r)
  if (r.id or ''):find('intro',1,true)then intro[#intro+1]=r;return end
  if r.id=='wide_settingsScope'then storage=r;return end
  if r.id=='wide_themeSets'then themes=r;return end
  if r.children then local children=type(r.children)=='function'and r.children()or r.children;for _,child in ipairs(children)do add(child)end;return end
  local key=r.id or '';local dest
  if key:find('menuTransition',1,true)then r.label='MISC TRANSITIONS'end
  if key:find('Selector',1,true)or key:find('selectorColor',1,true)or key:find('selectionHighlight',1,true)then dest='SELECTORS'
  elseif key:find('Border',1,true)or key:find(':style',1,true)then dest='BORDERS'
  elseif key:find('Background',1,true)or key:find('background_color',1,true)then dest='BACKGROUNDS'
  elseif key:find('scene_',1,true)or key:find('Transition',1,true)then dest='TRANSITIONS'
  elseif key:find('Opacity',1,true)or key:find(':opacity',1,true)or key:find('_transparency',1,true)or key:find('backgroundDim',1,true)then dest='TRANSPARENCY'
  elseif key:find('Position',1,true)or key:find('Offset',1,true)or key:find('Scale',1,true)or key:find('Width',1,true)or key:find('Height',1,true)or key:find('positionPreview',1,true)or key:find('menu_align',1,true)or key:find('menu_stretch',1,true)then dest='POSITION'
  else dest='TEXT'end
  pages[dest][#pages[dest]+1]=r
 end
 for _,r in ipairs(entries)do add(r)end
 local out={};for _,name in ipairs(order)do local children=pages[name]
  out[#out+1]={id='wide_page_'..name,label=name,group=true,children=children,value=function()return #children..' OPTIONS'end,activate=function(ctx)return openPage(name,children,ctx)end}
 end
 if #intro>0 then out[#out+1]={id='wide_introSettings',label='INTRO / START SCREEN',group=true,children=intro,activate=function(ctx)return openPage('INTRO / START SCREEN',intro,ctx)end}end
 if themes then out[#out+1]=themes end
 if storage then out[#out+1]=storage end
 return out
end
