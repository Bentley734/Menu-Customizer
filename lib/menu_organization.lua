-- One navigation structure for all generations; existing setting IDs stay intact.
return function(entries,openPage)
 local order={'START','BATTLE','OPTION','SAVE','OTHER','DIALOGUE','BORDERS','TRANSITIONS','MENU SELECTOR'}
 local pages={};for _,name in ipairs(order)do pages[name]={}end
 local appearance={};local misc={}
 for _,r in ipairs(entries)do
  local key=(r.id or ''):match('^wide_(.*)')or ''
  local dest
  if key=='startSelector'or key=='arrowSelector'or key=='selectionHighlight'then dest='MENU SELECTOR'
  elseif key=='menuBorder'or key:match('BorderChoice$')then dest='BORDERS'
  elseif key:match('^dialogue')then dest='DIALOGUE'
  elseif key:match('^scene_')or key=='menuTransition'then dest='TRANSITIONS'
  elseif key=='battle_ui'then dest='BATTLE'
  elseif key=='hideStartMods'or key:match('^start')then dest='START'
  elseif key:match('^option')then dest='OPTION'
  elseif key:match('^save')then dest='SAVE'
  elseif key:match('^other')then dest='OTHER'
  elseif key=='menuTheme'or key=='menuTextColor'or key=='menuTextShadowColor'or key=='menuBackgroundColor'or key=='text_fx'then appearance[#appearance+1]=r
  else misc[#misc+1]=r end
  if dest then pages[dest][#pages[dest]+1]=r end
 end
 local function link(name,children,id)
  return {id='wide_page_'..(id or name),label=name,group=true,value=function()return #children..' OPTIONS'end,
   activate=function(ctx)return openPage(name,children,ctx)end}
 end
 pages.OTHER[#pages.OTHER+1]=link('APPEARANCE',appearance,'appearance')
 pages.OTHER[#pages.OTHER+1]=link('GENERAL',misc,'general')
 local out={};for _,name in ipairs(order)do out[#out+1]=link(name,pages[name])end
 return out
end
