-- Native GB/GBC state menus stay on their input stack. Mirror their drawing
-- over the live map through the shared HUD seam; never tick field scripts.
return function(mod,catalog)
 local Runtime=require('src.mods.Runtime')
 local Font=require('src.render.Font')
 local Viewport=require('src.render.GameViewport')
 local G=love.graphics
 local C={mod=mod,catalog=catalog,drawScope=false,layouts={},frame=0}
 C.selectors=assert(load(assert(mod:read('lib/menu_selectors.lua'))))()
 local MOD_ID='gen3transparency'
 local positions={'DEFAULT','LEFT','RIGHT','TOP LEFT','TOP RIGHT','BOTTOM LEFT','BOTTOM RIGHT','CENTER','TOP CENTER','BOTTOM CENTER'}
 local menuPalette=assert(load(assert(mod:read('lib/battle_text_palette.lua'))))()(mod)
 C.palette=menuPalette
 local Transitions=assert(load(assert(mod:read('lib/menu_transitions.lua'))))()
 mod.exports.menuBackground=function()if C.drawScope or C.dialogueScope then return menuPalette.menuBackground(C.paperGroup)end end
 local specs={selectionHighlight={25,0,100,5},menuTextColor={0,0,#menuPalette.names-1,1},menuTextShadowColor={0,0,#menuPalette.shadowNames-1,1},menuBackgroundColor={0,0,#menuPalette.menuBackgroundNames-1,1},startMenuBackgroundColor={0,0,#menuPalette.menuBackgroundNames-1,1},dialogueBorder={0,0,1,1},menuTheme={2,1,2,1},menuBorder={1,1,#catalog.choices,1},startJustify={1,1,3,1},startSelector={3,1,#C.selectors.names,1},arrowSelector={1,1,13,1},selectorColor={0,0,#menuPalette.names-1,1},dialogueJustify={1,1,3,1},hideStartMods={0,0,1,1},
  backgroundDim={0,0,70,10},controlsLegend={2,1,3,1},menuTransition={3,1,#Transitions.names,1},positionPreview={1,0,1,1}}

 for _,scope in ipairs({'start','battle','option','save','other','dialogue','pokedex'})do specs[scope..'BorderChoice']={0,0,#catalog.choices,1}end
 specs.introTextColor={0,0,#menuPalette.names-1,1};specs.introTextShadowColor={0,0,#menuPalette.shadowNames-1,1};specs.introTextCase={0,0,3,1};specs.introLogo={1,0,1,1};specs.introTrainer={0,0,1,1}
 specs.introTheme={2,1,2,1};specs.introFontSize={0,0,2,1}
 specs.allShadowOpacity={100,0,100,5}
 specs.allTextColor={0,0,#menuPalette.names-1,1};specs.allTextShadowColor={0,0,#menuPalette.shadowNames-1,1}
 specs.allBorderChoice={1,1,#catalog.choices,1};specs.allBackgroundColor={0,0,#menuPalette.menuBackgroundNames-1,1}
 specs.introBackgroundColor={0,0,#menuPalette.menuBackgroundNames-1,1}
 specs.saveSummaryTheme={0,0,2,1};specs.saveSummaryBackgroundColor={0,0,#menuPalette.menuBackgroundNames-1,1}
 specs.dialogueTheme={2,1,2,1};specs.dialogueBackgroundColor={0,0,#menuPalette.menuBackgroundNames-1,1};specs.dialogueTextColor={0,0,#menuPalette.names-1,1};specs.dialogueTextShadowColor={0,0,#menuPalette.shadowNames-1,1}

 for k,v in pairs(menuPalette.effects.specs('menu'))do specs[k]=v end
 for k,v in pairs(menuPalette.effects.specs('intro'))do specs[k]=v end
 for _,group in ipairs({'start','option','save','other'}) do
  specs[group..'Position']={1,1,10,1}
  specs[group..'Scale']={100,50,150,10}
  specs[group..'Width']={100,70,130,5};specs[group..'Height']={100,80,130,5}
  specs[group..'OffsetX']={0,-128,128,1};specs[group..'OffsetY']={0,-128,128,1}
 end
 for _,group in ipairs({'start','option','other'}) do specs[group..'Opacity']={100,65,100,5} end
 local SceneEffects=assert(load(assert(mod:read('lib/scene_effects.lua'))))()
 for _,key in ipairs({'building_in','building_out','battle_in','battle_out'})do specs['scene_'..key]={1,1,#SceneEffects.names,1}end
 local marker
 C.arrows=assert(load(assert(mod:read('lib/arrow_selectors.lua'))))()(mod,C.selectors,function(key)return C.setting(key)end,function()return C.live()end)
 mod.exports.arrowSelectors=C.arrows;mod.exports.selectorPalette=menuPalette
 function C.live()
  local chain=Runtime.hooks and Runtime.hooks.chains and Runtime.hooks.chains['ui.start_menu.items']
  for _,entry in ipairs(chain or {}) do if entry.owner==mod.id and entry.callback==marker then return true end end
  return false
 end
 mod.exports.visualDefaults={};for key,spec in pairs(specs)do mod.exports.visualDefaults[key]=spec[1]end
 function C.setting(key)
  local spec=assert(specs[key],key)
  local raw=mod.options:get(key)
  if raw==nil then raw=mod.save:get(key) end
  local n=tonumber(raw)
  if key=='menuBorder' then n=catalog.selection(raw,mod.options:get('borderCatalogFormat') or mod.save:get('borderCatalogFormat')) end
  if key:find('Opacity') and mod.options:get('opacityFormat')~=2 then
   n=n and ({100,85,70,55,40})[math.floor(n)]
  end
  return math.max(spec[2],math.min(spec[3],math.floor(n or spec[1])))
 end
 function C.persist(game,key,value)
  local global=mod.exports.customization.globalValues(key,value)
  if global then return mod.exports.customization.write(game,global)end
  local options=game.options or (game.save and game.save.options)
  assert(options,'Menu Customizer: no option storage')
  if key=='menuTransition' and C.resetTransitions then C.resetTransitions()end
  options.modOptions=options.modOptions or {}
  local bucket=options.modOptions[MOD_ID] or {}
  options.modOptions[MOD_ID]=bucket
  -- Normalize all legacy opacity values together before changing the format.
  for k in pairs(specs) do bucket[k]=C.setting(k) end
  if key=='dialogueBorderChoice'then bucket.dialogueBorder=value>0 and 1 or 0 end
  if key=='battleBorderChoice'and value>0 then bucket.battle_style=3 end
  bucket[key]=value;bucket.opacityFormat=2;bucket.borderCatalogFormat=2
  if game.mods then game.mods.modOptions[MOD_ID]=bucket end
  if game.save and game.save.options and game.save.options~=options then
   game.save.options.modOptions=options.modOptions
  end
  if mod.exports.settingsProfiles then mod.exports.settingsProfiles.commit(game)end
  if game.writeOptions then game:writeOptions() end
  C.previewGroup=key:match('^(start)') or key:match('^(option)') or key:match('^(save)') or key:match('^(other)')
  C.previewUntil=love.timer.getTime()+3
 end

 local function isStart(s) return s and (s.screenId=='StartMenu' or s.screenId=='Gen2StartMenu' or (s.startCloses==true and s.anchor=='topright')) end
 local function isGen2Options(s)
  return mod.generation==2 and (s.screenId=='Gen2OptionsMenu' or
   s.rows and s.view and s.options and type(s.visible)=='function')
 end
 local function groupOf(s)
  if type(s.drawItemBox)=='function' and s.items and not s.itemBox then return 'option' end
  if s._menuCustomizerGroup then return s._menuCustomizerGroup end
  local id=s.screenId or ''
  if isStart(s) then return 'start' end
  if id:find('Option') or s.rows and (s.view or s.options) then return 'option' end
  if id:find('Save') then return 'save' end
  -- Anchors also belong to enlarged party/summary pages. Only an unnamed
  -- save panel needs the legacy anchor-only classification.
  if s.holdsUIAnchors and id=='' then return 'save' end
  return 'other'
 end
 local known={StartMenu=true,Gen2StartMenu=true,OptionsMenu=true,Gen2OptionsMenu=true,
  BagMenu=true,Gen2PackMenu=true,PartyMenu=true,Gen2PartyMenu=true,PokedexMenu=true,DexEntryMenu=true,Gen2PokedexMenu=true,
  TrainerCard=true,Gen2TrainerCard=true,Gen2Pokegear=true,Gen2SaveMenu=true,MenuCustomizerOptions=true}
 function C.context(game)
  if not C.live() or not game or not game.stack then return nil end
  local world=game.world or game.overworld
  local states=game.stack.states or {}
  if not world or not world.map then
   local bootOptions
   for _,state in ipairs(states)do
    local id=state.screenId or''
    if id=='OptionsMenu'or id=='Gen2OptionsMenu'or id=='MenuCustomizerOptions'or state.rows and(state.view or state.options)then bootOptions=true end
   end
   if not bootOptions then return nil end
   world={map={}} -- Same options mirror before an overworld has been loaded.
  end
  local first,recognized
  for i,s in ipairs(states) do
   if s.isBattle or (s.screenId or ''):find('Battle') then return nil end
   if s~=world and s.draw then
    first=first or i
    if known[s.screenId] or s._menuCustomizerGroup or isStart(s)
        or type(s.drawItemBox)=='function' and s.items and not s.itemBox
        or s.rows and (s.view or s.options) then recognized=true end
   end
  end
  if not recognized or not first then return nil end
  -- Mod manager screens have their own rendering/layout contract.
  local top=game.stack:top()
  if top and (top.screenId=='ModManager' or top.screenId=='ModsMenu' or top.screenId=='ManagerState') then return nil end
  local base=first
  for i=first,#states do if states[i].isOpaque then base=i end end
  local group=groupOf(top or states[base])
  -- A SAVE panel + its TextBox share one coordinate system. Suppress START
  -- beneath them so it does not show through the live-map composite.
  local saveAt
  for i=first,#states do if groupOf(states[i])=='save' then saveAt=i;group='save' end end
  if saveAt then base=math.max(base,saveAt) end
  return {first=first,base=base,group=group,world=world,states=states,top=top}
 end

 -- The shared border helper draws GB total bounds; the shader is suspended
 -- around it so colored GBA frames retain their original colors on GBC.
 local Borders=assert(load(assert(mod:read('lib/menu_borders.lua')),'@'..mod.path..'/lib/menu_borders.lua'))()(mod,C.setting,catalog,function()return C.live() and (C.drawScope or C.dialogueScope) end)
 C.borders=Borders
 C.theme=assert(load(assert(mod:read('lib/emerald_theme.lua'))))()(mod,function()return (C.drawScope or C.dialogueScope or mod.exports.choiceFontScope or mod.exports.battleFontScope) and (C.introScope and C.setting('introTheme')>0 and C.setting('introTheme')or C.summaryScope and C.setting('saveSummaryTheme')>0 and C.setting('saveSummaryTheme')or C.setting((C.dialogueScope or mod.exports.choiceFontScope) and 'dialogueTheme'or'menuTheme'))==2 end)
 -- START rows are sixteen pixels apart, just like Emerald's native menu.
 -- Use the original glyph size there instead of the dense GB screen size.
 C.theme.gbScale=function()if mod.exports.menuSurfaces and mod.exports.menuSurfaces.current=='loadReport'then return 1 end;if C.introScope then return C.introFitScale or (C.setting('introFontSize')+1)end;if mod.exports.battleFontScope then return mod.exports.battleFontScale or .5 end;if C.dialogueScope or mod.exports.choiceFontScope then return .75 end;return not C.compactText and (C.dialogueScope or C.drawingTitle or C.drawingStart or C.drawingCheats or C.drawingOptions and C.drawingOptions.fullFont) and 1 or .5 end
 C.theme.gbBaseline=function()if C.introScope then local scale=C.theme.gbScale();return math.max(0,scale*14-8)-(scale==1 and 6 or 0)end;return (C.dialogueScope or mod.exports.choiceFontScope) and 2 or 0 end
 C.theme.gbColors=function()
  if mod.exports.battleNameScope then return menuPalette.colors('name')end
  if mod.exports.battleFontScope then
   local ui=mod.exports.battleUi
   if ui and ui.nativeEmerald then return ui.nativeEmerald.presentationColors() end
   return {fg={74/255,74/255,74/255,1},shadow={214/255,214/255,206/255,1}}
  end
  return menuPalette.colors('menu')
 end
 Font._menuCustomizerGB=C
 if not Font._menuCustomizerGBWrapped then
  local box,draw,code,advance=Font.drawBox,Font.draw,Font.drawCode,Font.advanceOf
  Font.advanceOf=function(glyph)
   local current=Font._menuCustomizerGB
   if current and current.theme.enabled() then
    local width=current.theme.gbAdvance(glyph);if width then return width/(current.drawScope and current.resizeX or 1) end
   end
   return advance(glyph)/(current and current.drawScope and current.resizeX or 1)
  end
  Font.drawBox=function(tx,ty,tw,th,...)
   local current=Font._menuCustomizerGB
   if current and (current.drawScope or current.dialogueScope) then
    local b=current.bounds
    local x,y,w,h=tx*8,ty*8,tw*8,th*8
    if current.drawScope then local rx,ry=current.resizeX or 1,current.resizeY or 1;x,y,w,h=x*rx,y*ry,w*rx,h*ry end
    if not b then current.bounds={x=x,y=y,w=w,h=h}
    else local r,d=math.max(b.x+b.w,x+w),math.max(b.y+b.h,y+h);b.x,b.y=math.min(b.x,x),math.min(b.y,y);b.w,b.h=r-b.x,d-b.y end
    if (current.dialogueScope or current.mod.exports.previewScope) and current.mod.generation==1 then
     current.dialogueRects=current.dialogueRects or {}
     current.dialogueRects[#current.dialogueRects+1]={colors=false,x=tx*8,y=ty*8,w=tw*8,h=th*8}
    end
    current.inBox=true
    local args={n=select('#',...),...}
    local ok,result=pcall(function()
     if (not current.dialogueScope or current.paperGroup=='save' or current.setting('dialogueBorder')==1 and current.setting('dialogueBorderChoice')>0) and current.borders.draw(tx,ty,tw,th) then

      return
     end
     local result=box(tx,ty,tw,th,unpack(args,1,args.n))
     if current.dialogueScope then
      local bg=current.palette.menuBackground(current.paperGroup=='save' and 'save' or 'dialogue')
      if bg then current.palette.paint(bg,G.rectangle,'fill',(tx+1)*8,(ty+1)*8,math.max(0,(tw-2)*8),math.max(0,(th-2)*8))end
     end
     return result
    end)
    current.inBox=false
    if not ok then error(result,0) end
    return result
   end
   return box(tx,ty,tw,th,...)
  end
  local scrollText={}
  local function windowText(text,budget,selected)

   text=tostring(text)

   if Font.width(text)<=budget then return text end

   local chars={}

   for c in text:gmatch('[%z\1-\127\194-\244][\128-\191]*')do chars[#chars+1]=c end

   local first=1

   if selected then

    local now=love.timer.getTime();scrollText[text]=scrollText[text] or now
    local phase=math.floor((now-scrollText[text])*2)%(#chars+4)

    first=math.max(1,math.min(#chars,phase-1))

   end

   local shown=''

   for i=first,#chars do

    if Font.width(shown..chars[i])>budget then break end

    shown=shown..chars[i]

   end

   return shown

  end

  local function label(text,x,y,render,...)
   local current=Font._menuCustomizerGB
   local scope=current and current.mod and current.mod.exports or mod.exports
   if current and scope.battleHudScope then
    local prior,scale,nameScope=scope.battleFontScope,scope.battleFontScale,scope.battleNameScope
    scope.battleNameScope=(y==0 or y==56)
    if scope.battleNameScope and scope.battleHudNames then
     local queue=scope.battleHudNames
     local result={pcall(queue.presenter.record,queue,text,x,y,y==0 and 'enemy' or 'player')}
     scope.battleNameScope=nameScope
     if not result[1]then error(result[2],0)end
     if result[2]~=nil then return result[2]end
     scope.battleNameScope=true
    end
    if not scope.battleNameScope and (tostring(text):match('^[%d%s/]+$') or tostring(text):match('^HP') or (y==8 or y==64) or tostring(text):find('<LV>',1,true))then
     scope.battleFontScope=false
    elseif scope.battleHudCapture and (y==0 or y==56) then
     scope.battleFontScale=.75
     y=y-2
    end
    local result={pcall(function(...)
     local palette=current.palette or menuPalette
     if palette then return palette.withText(scope.battleNameScope and 'name' or 'battle',render,text,x,y,...)end
     return render(text,x,y,...)
    end,...)}
    scope.battleFontScope,scope.battleFontScale,scope.battleNameScope=prior,scale,nameScope
    if not result[1]then error(result[2],0)end
    return unpack(result,2)
   end
   if current and current.drawingParty and text=='' and x==24 and y%16==0 then
    -- Transferred mons can carry an empty nickname. Resolve the displayed
    -- row name without editing the party record or its persisted nickname.
    local game=current.drawingParty
    local mon=game.save and game.save.party and game.save.party[y/16+1]
    local def=mon and game.data and game.data.pokemon and game.data.pokemon[mon.species]
    if mon then text=(def and def.name) or mon.name or mon.species or text end
   end
   if current and current.drawingParty and tostring(text):match('^%s*%d+/%s*%d+$')then
    return render(tostring(text):gsub('%s+',''),108,y,...)
   end
   if current and current.drawScope and current.theme.enabled() then
    -- Preserve cartridge numeric fields' right edges with proportional text.
    local raw=tostring(text)
    if not current.drawingTrainerCard and (raw:match('^%s+%d') or (#raw==3 and raw:match('^%d%d%d$') and (x==48 or x==128))) and not raw:find('[^%d%s/,:.%-]') then
     local trimmed=raw:match('^%s*(.-)%s*$')
     return render(trimmed,x+#raw*8-Font.width(trimmed),y,...)
    end
   end
   if current and current.drawingSave and current.theme.enabled() then
    if (y==16 and x==96) or (y==32 and x==136) or (y==48 and x==128) or (y==64 and x==104) then
     text=tostring(text):match('^%s*(.-)%s*$')
     return render(text,152-Font.width(text),y,...)
    end
   end
   if current and current.drawingList then
    if current.drawingCheats and (x==8 and y==4 or y>=128) then
     current.compactText=true
     local result=render(text,x,y==4 and 10 or y-8,...)
     current.compactText=nil;return result
    end
    if x==8 and y==4 then y=10 elseif y>=128 then y=y-8 end
   end
   local start=current and (current.drawingStart or current.drawingOptions)
   if start and start.inlineValues then
    local valueRow=(y-start.rowY-16)/start.pitch+1+start.scroll
    if valueRow==math.floor(valueRow) and start.items[valueRow] then
     if start.nativeValues and x==80 then return end
     if x==88 or start.nativeValues and x==128 then
      local width=Font.width(text)
      local baseline=y
      G.push('all');G.translate(152-width,baseline)
      local result=render(text,0,0,...);G.pop();return result
     end
    end
   end
   if start and start.cards and x==24 then
    local row=(y-start.rowY-8)/start.pitch+1+start.scroll
    if row==math.floor(row) and start.items[row] then
     local width=Font.width(text)
     local textX=start.left+8+math.max(0,(start.width-16-width)/2)
     G.push('all');G.translate(textX,y)
     local result=render(text,0,0,...);G.pop();return result
    end
   end
   if not start or x~=start.labelX then return render(text,x,y,...) end
   local n=(y-start.rowY)/start.pitch+1+start.scroll
   local entry=start.items[n]
   if n~=math.floor(n) or not entry then return render(text,x,y,...) end
   local selector=start.options and current.arrows.id() or current.setting('startSelector')
   if not start.options and current.mod.options:get('startSelector')==14 then selector=3 end
   local left=start.left+8
   local right=start.left+start.width-8
   local reserve=selector==1 or selector==3 or selector>=5 and selector<=12
   local minimum=math.max(start.labelX,left+(reserve and 10 or selector==4 and 4 or 0))
   local maximum=right-(selector==4 and 4 or 0)
   if not start.inlineValues then text=windowText(text,math.max(1,maximum-minimum),n==start.index) end
   local shown=Font.width(text)
   local align=(start.inlineValues or start.cards) and 1 or current.setting('startJustify')
   local textX=align==2 and minimum+(maximum-minimum-shown)/2 or align==3 and maximum-shown or minimum
   G.push('all');G.translate(textX,y)
   local result
   if current.mod.exports.jumpWave.enabled()and n==start.index then current.mod.exports.jumpWave.select(start.owner or start.items,start.index,text);result=current.mod.exports.jumpWave.draw(render,Font.width,text,0,0,...)else result=render(text,0,0,...)end
   G.pop()
   if n==start.index then start.selection={x=textX,y=y,width=shown,selector=selector} end
   return result
  end
  Font.draw=function(text,x,y,...)
   local c=Font._menuCustomizerGB;local e=c and c.mod.exports
   local kind=e and e.battleNameScope and 'name' or e and e.battleFontScope and 'battle' or 'menu'
   return (c and c.palette or menuPalette).withText(kind,label,text,x,y,draw,...)
  end
  -- GBC palette printing paints paper and individual glyphs directly, bypassing
  -- Font.draw. Move the whole print operation, including its background.
  Font._menuCustomizerLabel=label
  local Hud=require('src.render.HudTiles');local tile=Hud.tile
  Hud.tile=function(id,x,y,...)
   local c=Font._menuCustomizerGB
   if c and c.drawingParty then
    if id==0x6E then return Font.draw(c.theme.enabled()and 'Lv'or 'L',x,y)end
    if id==0x71 then return Font.draw('HP:',math.min(x,48-Font.width('HP:')),y)end
    if id==0x62 then return end -- second native HP-label tile
   end
   return tile(id,x,y,...)
  end

  Font.drawCode=function(glyph,x,y,...)
   local current=Font._menuCustomizerGB
   local start=current and (current.drawingStart or current.drawingOptions)
   if start and glyph==0xED and x==start.labelX-8
       and y==start.rowY+(start.index-start.scroll-1)*start.pitch then return end
   local rx,ry=current and current.drawScope and not current.inBox and current.resizeX or 1,current and current.drawScope and not current.inBox and current.resizeY or 1
   G.push('all');G.translate(x,y);G.scale(1/rx,1/ry)
   local result
   local replacement=current and (glyph==0xED or glyph==0xEC) and current.arrows.draw(current.drawingTitle and -1 or 0,(current.theme.enabled() and current.theme.gbScale()==1) and -2 or 0,8)
   local vanillaHud=current and current.mod.exports.battleHudScope and not current.mod.exports.battleNameScope
   if replacement then
   elseif vanillaHud then result=code(glyph,0,0,...)
   elseif not (current and current.theme and current.theme.enabled() and current.theme.gbGlyph(glyph,0,0)) then
    if current and current.mod.exports.battleNameScope then result=(current.palette or menuPalette).nativeNameGlyph(code,glyph,0,0,...)
    elseif current and (current.drawScope or current.dialogueScope or current.mod.exports.choiceFontScope) then result=(current.palette or menuPalette).nativeMenuGlyph(code,glyph,0,0,...)
    else result=code(glyph,0,0,...)end
   end
   G.pop();return result
  end
  -- Draw after native labels and their opaque palette paper, so selectors
  -- cannot be erased. The label layout reserves their complete footprint.
  Font._menuCustomizerDrawSelector=function(start)
   local sel=start and start.selection;if not sel then return end
   local x,y,width=sel.x,sel.y,sel.width
   G.push('all');G.setShader();G.setColor(0,0,0,1)
   local current=Font._menuCustomizerGB
   local rx,ry=current.resizeX or 1,current.resizeY or 1
   G.translate(x,y);G.scale(1/rx,1/ry);width=width*rx;x,y=0,0
   local platform=love.system and love.system.getOS and love.system.getOS()
   if start.options then
    -- Retain the original 8x8 marker and horizontal gap; move it up only.
    if current.theme.enabled() and current.theme.gbScale()==1 then y=y-2 end
   elseif (platform=='Windows' or platform=='iOS') and current.setting('menuTheme')==2 then
    -- START markers follow Emerald's raised ink before inverse UI scaling.
    -- The old iOS +2 correction moved every marker below its selected label.
    y=y-2
   end
   if start.options then
    local raised=current.theme.enabled()and current.theme.gbScale()==1 and 6 or 0
    G.setColor(.25,.65,1,current.setting('selectionHighlight')/100)
    if start.cards then
     local back=start.index==#start.items
     -- Card frames consume eight pixels on each edge; BACK has no card.
     local height=back and 8 or 16
     local top=back and -1 or 0
     G.rectangle('fill',((start.left or 0)+8-sel.x)*rx,top*ry,math.max(1,(start.width or 160)-16)*rx,height*ry)
    else
     G.rectangle('fill',((start.left or 0)+8-sel.x)*rx,-raised-1,math.max(1,(start.width or 160)-16)*rx,(start.pitch or 16)*ry)
    end
    G.setColor(0,0,0,1)
   end
   if sel.selector==0 or sel.selector==14 then G.pop();return end
   if sel.selector==13 then
    G.setColor(.25,.65,1,current.setting('selectionHighlight')/100);G.rectangle('fill',((start.left or 0)+8-sel.x)*rx,-((current.theme.enabled() and current.theme.gbScale()==1) and 7 or 1),math.max(1,(start.width or 160)-16)*rx,(start.pitch or 16)*ry)
   elseif sel.selector>=5 then C.selectors.draw(sel.selector,x-10,y)
   elseif sel.selector==3 then code(0xED,x-10,y)
   elseif sel.selector==2 then
    G.setColor(1,1,1,1);G.rectangle('fill',x-1,y+7,width+2,3)
    current.palette.effects.paint(current.palette.color('text',current.setting('selectorColor')),'menu',function()G.rectangle('fill',x,y+8,width,1)end)
   elseif sel.selector==4 then
    G.setColor(1,1,1,1);G.rectangle('fill',x-5,y+2,4,4);G.rectangle('fill',x+width+1,y+2,4,4)
    current.palette.effects.paint(current.palette.color('text',current.setting('selectorColor')),'menu',function()
     G.rectangle('fill',x-4,y+3,2,2);G.rectangle('fill',x+width+2,y+3,2,2)
    end)
   else
    local pixels={'..1111..','.122221.','12222221','11144111','13344331','13333331','.133331.','..1111..'}
    local colors={{0,0,0,1},{.85,.12,.12,1},{1,1,1,1},{.5,.5,.5,1}}
    for py,row in ipairs(pixels) do for px=1,#row do
     local c=colors[tonumber(row:sub(px,px))]
     if c then G.setColor(unpack(c));G.rectangle('fill',x-10+px-1,y+py-1,1,1) end
    end end
   end
   G.pop()
  end
  Font._menuCustomizerGBWrapped=true
 end
 C.drawSelector=Font._menuCustomizerDrawSelector
 local Renderer=require('src.render.Renderer')
 -- Mirrored HD menus use our separate capture canvas. The hidden engine UI
 -- must stay classic-sized: its dimensions also select the world's fit and
 -- camera view. Leave the native zoom/DPI/faithful-ratio calculations intact.
 if not Renderer._menuCustomizerUISize then
  local size=Renderer.setUISize
  if type(size)=='function' then
   Renderer._menuCustomizerUISize=size
   Renderer.setUISize=function(self,w,h,...)
    local current=Font._menuCustomizerGB
    if current and current.context(current.game) then w,h=160,144 end
    return size(self,w,h,...)
   end
  end
 end
 if not Renderer._menuCustomizerDialogueColor then
  local begin=Renderer.beginFrame;local blit=Renderer.blitCanvas
  Renderer.beginFrame=function(self,...)
   local current=Font._menuCustomizerGB;if current then current.dialogueRects={};if current.dialogueText then current.dialogueText.beginFrame()end end
   return begin(self,...)
  end
  Renderer.blitCanvas=function(self,canvas,sx,sy,zones,...)
   local current=Font._menuCustomizerGB
   if current and current.mod.generation==1 and canvas==self.canvas and zones and #zones>0 and current.dialogueRects and #current.dialogueRects>0 then
    local merged={};for _,z in ipairs(zones)do merged[#merged+1]=z end
    for _,z in ipairs(current.dialogueRects)do merged[#merged+1]=z end
    zones=merged
   end
   return blit(self,canvas,sx,sy,zones,...)
  end
  Renderer._menuCustomizerDialogueColor=true
 end
 C.dialogueText=assert(load(assert(mod:read('lib/gb_dialogue_text.lua'))))()(Font)
 local TextBox=require('src.render.TextBox')
 if not TextBox._menuCustomizerPaginateInset then
  local paginate=TextBox.paginate
  TextBox.paginate=function(text,cols,...)
   local current=Font._menuCustomizerGB
   if current and current.live() and current.dialogueScope then cols=math.max(1,(cols or 18)-1)end
   return paginate(text,cols,...)
  end
  TextBox._menuCustomizerPaginateInset=true
 end
 if not TextBox._menuCustomizerDialogueNew then
  TextBox._menuCustomizerDialogueNew=TextBox.new
  TextBox.new=function(...)
   local current=Font._menuCustomizerGB;local enabled=current and current.live()
   local old=current and current.dialogueScope;if enabled then current.dialogueScope=true end
   local args={n=select('#',...),...}
   if enabled and type(args[2])=='string'then args[2]=current.mod.exports.customization.text(args[2])end
   local result={pcall(TextBox._menuCustomizerDialogueNew,unpack(args,1,args.n))}
   if current then current.dialogueScope=old end
   if not result[1]then error(result[2],0)end;return unpack(result,2)
  end
 end
 if not TextBox._menuCustomizerDialogueDraw then
  TextBox._menuCustomizerDialogueDraw=TextBox.draw
  TextBox.draw=function(self,...)
   local current=Font._menuCustomizerGB
   local enabled=current and current.live()
   local priorDialogue=current and current.dialogueScope
   if enabled then current.dialogueScope=true end
   local oldX,oldY1,oldY2=self.textX,self.line1Y,self.line2Y
   local glyph=Font.drawCode
   if enabled then
    local themed=current.setting('dialogueTheme')==2
    local inkTop,inkHeight=themed and -.5 or 0,themed and 8.25 or 8
    self.textX=self.boxTx*8+12
    self.line1Y=self.boxTy*8+math.floor((self.boxTh*8-(16+inkHeight))/2)-inkTop
    self.line2Y=self.line1Y+16
    local shifts={};local alignment=current.setting('dialogueJustify')
    for i,line in ipairs(self.shown or {})do
     local source=self.shownSource and self.shownSource[i]
     local page=self.pages and self.pages[self.pageIndex or 1]
     local full=source and page and page[source]
     local w=0
     if full then w=Font.width(full)else for _,id in ipairs(line)do w=w+Font.advanceOf(id)end end
     local slack=math.max(0,self.boxTw*8-24-w)
     shifts[i]=alignment==2 and math.floor(slack/2)or alignment==3 and slack or 0
    end
    Font.drawCode=function(id,x,y,...)
     local ys={self.line1Y+(self.scrollPx or 0),self.line2Y}
     for i=1,2 do if y==ys[i] and x>=self.textX and x<self.boxTx*8+(self.boxTw-1)*8 then x=x+(shifts[i]or 0);break end end
     return glyph(id,x,y,...)
    end
   end
   local args={n=select('#',...),...}
   local ok,result=pcall(function()
    local draw=function()return TextBox._menuCustomizerDialogueDraw(self,unpack(args,1,args.n))end
    if enabled then return current.palette.withText('menu',draw)end;return draw()
   end)
   Font.drawCode=glyph;self.textX,self.line1Y,self.line2Y=oldX,oldY1,oldY2
   if enabled then current.dialogueScope=priorDialogue end
   if not ok then error(result,0) end
   return result
  end
 end

 if mod.generation==2 then
  local Chrome=require('src.ui.gen2.Chrome')
  if not Chrome._menuCustomizerSavePrint then
   Chrome._menuCustomizerSavePrint=Chrome.print
   Chrome.print=function(text,tx,ty,...)
    local current=Font._menuCustomizerGB
    if current and current.drawingSave and current.theme.enabled() then
     if ty==2 and tx==5 then
      local name=tostring(text):match('^[Pp][Ll][Aa][Yy][Ee][Rr]%s+(.+)$')
      if name then
       Chrome._menuCustomizerSavePrint(current.mod.exports.customization.text('PLAYER'),tx,ty,...)
       return Chrome._menuCustomizerSavePrint(name,(152-Font.width(name))/8,ty,...)
      end
     end
     if ty==8 and tx==13 then current.saveHours=tostring(text):match('^%s*(.-)%s*$');return end
     if ty==8 and tx==16 then return end
     if ty==8 and tx==17 then text=(current.saveHours or '0')..':'..tostring(text):match('^%s*(.-)%s*$') end
     if ty==4 and tx==17 or ty==6 and tx==16 or ty==8 and tx==17 then
      text=tostring(text):match('^%s*(.-)%s*$')
      return Chrome._menuCustomizerSavePrint(text,(152-Font.width(text))/8,ty,...)
     end
    end
    return Chrome._menuCustomizerSavePrint(text,tx,ty,...)
   end
  end
  if not Chrome._menuCustomizerPrint then
   Chrome._menuCustomizerPrint=Chrome.printThrough
   Chrome.printThrough=function(text,tx,ty,...)
    local current=Font._menuCustomizerGB
    if current and current.drawingTrainerCard and current.theme.enabled() and tx==15 and ty==10 then
     text=tostring(text):match('^%s*(.-)%s*$')
     tx=(144-Font.width(text))/8
    end
    if current and current.drawingTrainerCard and current.theme.enabled() and ty==12 then
     if tx==11 then current.cardHours=tostring(text):match('^%s*(.-)%s*$');return end
     if tx==15 then return end
     if tx==16 then
      text=(current.cardHours or '0')..':'..tostring(text):match('^%s*(.-)%s*$')
      tx=(144-Font.width(text))/8
     end
    end
    return Font._menuCustomizerLabel(text,tx*8,ty*8,function(t,x,y,...)
     return Chrome._menuCustomizerPrint(t,x/8,y/8,...)
    end,...)
   end
  end
  local TrainerCard=require('src.ui.gen2.TrainerCard')
  if not TrainerCard._menuCustomizerTile then
   TrainerCard._menuCustomizerTile=TrainerCard.tile
   TrainerCard.tile=function(self,sheet,id,tx,ty,...)
    local current=Font._menuCustomizerGB
    if current and current.drawingTrainerCard and current.theme.enabled() and tx==15 and ty==12 and sheet==self.status then return end
    return TrainerCard._menuCustomizerTile(self,sheet,id,tx,ty,...)
   end
  end
 end

 -- A compact native settings page works on both GB and GBC. It retains
 -- standard A/B/d-pad input and puts every group behind OPTION > MENUS.
 local Page={isOpaque=true,isMenu=true,_menuCustomizerGroup='option'}
 Page.__index=Page
 local pushPage
 pushPage=function(game,title,rows,detail)
  local entries=rows
  if not detail then
   entries={}
   for _,original in ipairs(rows)do
    if original.step and not original.activate then
     entries[#entries+1]={id=original.id,label=original.label,preview=original.preview,activate=function(g)pushPage(g,original.label,{original},true)end}
    else entries[#entries+1]=original end
   end
  end
  local page=setmetatable({game=game,title=title,rows=entries,detail=detail,colorChoice=entries[1] and entries[1].colorChoice,index=1,scroll=0,screenId='MenuCustomizerOptions'},Page)
  game.stack:push(page);return page
 end
 C.openPage=pushPage
 function Page:update()
  local input=self.game.input;local count=#self.rows+1
  if input:wasPressed('b') or input:wasPressed('start') then self.game.stack:pop();return end
  if input:wasPressed('up') then self.index=(self.index-2)%count+1
  elseif input:wasPressed('down') then self.index=self.index%count+1
  elseif input:wasPressed('a') or input:wasPressed('left') or input:wasPressed('right') then
   local row=self.rows[self.index]
   if not row then if input:wasPressed('a') then self.game.stack:pop() end
   elseif row.activate then if input:wasPressed('a') then row.activate(self.game) end
   else row.step(self.game,input:wasPressed('left') and -1 or 1) end
  end
  self.scroll=math.max(0,math.min(self.scroll,self.index-1))
  if self.index>self.scroll+(self.detail and 4 or 7) then self.scroll=self.index-(self.detail and 4 or 7) end
 end
 function Page:draw()
  return mod.exports.customization.withRows(self.rows[self.index],self.rows,self.drawPreview,self)
 end
 function Page:drawPreview()
  Font.drawBox(0,0,20,18)
  G.setColor(0,0,0,1);C.compactText=true;Font.draw(self.title,8,10);C.compactText=nil
  for slot=1,(self.detail and 4 or 7) do
   local i=self.scroll+slot;local row=self.rows[i]
   if i<=#self.rows+1 then
    local y=24+(slot-1)*(self.detail and 32 or 16)
    if false then
     G.push('all');G.setShader();G.setColor(.25,.65,1,C.setting('selectionHighlight')/100)
     local ry=C.resizeY or 1
     local raised=C.theme.enabled() and C.theme.gbScale()==1 and 6 or 0
     G.rectangle('fill',8,y-(raised+1)/ry,144,self.detail and 32 or 16);G.pop()
    end
    Font.draw(row and row.label or 'BACK',24,y)
    if row and row.selected and row.selected() then
     G.rectangle('fill',16,y+2,1,2);G.rectangle('fill',17,y+3,1,2)
     G.rectangle('fill',18,y+2,1,2);G.rectangle('fill',19,y+1,1,2)
    end
    if row and self.detail then
     local value=row.value and row.value() or 'OPEN'
     -- The cartridge fonts have no percent glyph. Draw it explicitly rather
     -- than letting an unsupported character disappear from scale/opacity.
     local number=value:match('^(.-)%%$')
     Font.draw(number and number..'  ' or value,88,y+16)
     if number then
      local px=144
      local pixels={'1100010','1100100','0001000','0010000','0100011','1000011'}
      for py,line in ipairs(pixels) do for x=1,#line do
       if line:sub(x,x)=='1' then G.rectangle('fill',px+x-1,y+16+py,1,1) end
      end end
     end
    end
   end
  end
  if self.scroll+(self.detail and 4 or 7)<#self.rows+1 then
   Font.drawCode(require('src.ui.Theme').moreArrow,144,128)
  end
  if C.legendVisible()then
  C.compactText=true
  Font.draw(self.colorChoice and 'A:SELECT B:BACK' or self.detail and 'A:CHANGE B:BACK' or 'A:OPEN B:BACK',8,128)
  C.compactText=nil
  end
 end
 function C.legendVisible(now)
  local mode=C.setting('controlsLegend');now=now or love.timer.getTime()
  return mode==1 or mode==2 and now-(C.lastInput or now)<2
 end
 local function row(key,label,choices)
  local spec=specs[key]
  local entry={id='wide_'..key,label=label,preview=function()return mod.exports.customization.values(key,C.setting(key))end,value=function()
   local n=C.setting(key)
   return choices and choices[n] or tostring(n)..((key:find('Opacity') or key:find('Scale') or key:find('Width') or key:find('Height') or key=='backgroundDim' or key=='selectionHighlight') and '%' or '')
  end,step=function(game,dir)
   local n=C.setting(key)+dir*spec[4]
   if choices then n=(n-spec[2])%(spec[3]-spec[2]+1)+spec[2] else n=math.max(spec[2],math.min(spec[3],n)) end
   if key=='allTextColor'or key=='menuTextColor'or key=='introTextColor'or key=='dialogueTextColor'or key=='selectorColor' then n=menuPalette.step('text',C.setting(key),dir)
   elseif key=='allTextShadowColor'or key=='menuTextShadowColor'or key=='introTextShadowColor'or key=='dialogueTextShadowColor' then n=menuPalette.step('shadow',C.setting(key),dir)
   elseif key=='allBackgroundColor' or key=='menuBackgroundColor' or key=='startMenuBackgroundColor' or key=='dialogueBackgroundColor' then n=menuPalette.step('menuBackground',C.setting(key),dir)end
   C.persist(game,key,n)
  end}
  local kind=(key=='allTextColor'or key=='menuTextColor'or key=='introTextColor'or key=='dialogueTextColor'or key=='selectorColor') and 'text' or (key=='allTextShadowColor'or key=='menuTextShadowColor'or key=='introTextShadowColor'or key=='dialogueTextShadowColor') and 'shadow' or (key=='allBackgroundColor' or key=='menuBackgroundColor' or key=='startMenuBackgroundColor' or key=='dialogueBackgroundColor'or key=='saveSummaryBackgroundColor'or key=='introBackgroundColor') and 'menuBackground'
  if kind then menuPalette.picker(entry,kind,function()return C.setting(key)end,function(ctx,n)C.persist(ctx.game or ctx,key,n);return false end,
   function(title,rows,ctx)return pushPage(ctx.game or ctx,title,rows)end,key=='startMenuBackgroundColor' and 'USE MENU' or nil)end
  if key=='menuBorder'or key:match('BorderChoice$')then
   entry.customization=mod.exports.customization
   menuPalette.designPicker(entry,catalog.groups,function()return C.setting(key)end,
    function(ctx,n)C.persist(ctx.game or ctx,key,n);return false end,
    function(title,rows,ctx)return pushPage(ctx.game or ctx,title,rows)end)
  end
  return entry
 end
 local function toggle(key,label)
  local r=row(key,label);r.value=function()return C.setting(key)==1 and 'ON' or 'OFF' end
  r.step=function(game)C.persist(game,key,1-C.setting(key))end;return r
 end
 local bgNames,startBgNames={},{}
 for i,name in ipairs(menuPalette.menuBackgroundNames)do bgNames[i-1]=name;startBgNames[i-1]=name end
 bgNames[0]='DEFAULT';startBgNames[0]='USE MENU'
 local colorNames={};for i,name in ipairs(menuPalette.names)do colorNames[i-1]=name end
 local shadowNames={};for i,name in ipairs(menuPalette.shadowNames)do shadowNames[i-1]=name end
 local parent={mod.exports.settingsProfiles.row(),row('allShadowOpacity','ALL SHADOW OPACITY'),row('allTextColor','ALL COLORS',colorNames),row('allTextShadowColor','ALL SHADOWS',shadowNames),row('allBorderChoice','ALL BORDERS',catalog.choices),row('allBackgroundColor','ALL BACKGROUNDS',bgNames)}
 for _,r in ipairs(mod.exports.customization.rows(function(title,rows,ctx)return pushPage(ctx.game or ctx,title,rows)end))do parent[#parent+1]=r end
 for _,group in ipairs({'start','option','save','other'})do
  for _,suffix in ipairs({'Position','Scale','Width','Height','OffsetX','OffsetY'})do
   parent[#parent+1]=row(group..suffix,group:upper()..' '..(({OffsetX='X OFFSET',OffsetY='Y OFFSET'})[suffix]or suffix:upper()),suffix=='Position'and positions or nil)
  end
  if group~='save'then parent[#parent+1]=row(group..'Opacity',group:upper()..' OPACITY')end
 end
 parent[#parent+1]=row('startJustify','START ALIGNMENT',{'LEFT','CENTER','RIGHT'})
 parent[#parent+1]=row('dialogueJustify','DIALOGUE ALIGNMENT',{'LEFT','CENTER','RIGHT'})
 local selectorNames={};for i,name in ipairs(menuPalette.names)do selectorNames[i-1]=name end
 parent[#parent+1]=row('selectorColor','UNDERLINE / DOTS COLOR',selectorNames)
 parent[#parent+1]=row('startMenuBackgroundColor','START BACKGROUND',startBgNames)
 parent[#parent+1]=row('startSelector','START SELECTOR',C.selectors.names)
 parent[#parent+1]=toggle('hideStartMods','HIDE START MODS')
 parent[#parent+1]=row('arrowSelector','ARROW SELECTOR',C.arrows.names)
 parent[#parent+1]=row('selectionHighlight','HIGHLIGHT INTENSITY')
 parent[#parent+1]=row('menuTheme','MENU FONT',{'NATIVE','EMERALD'})

 parent[#parent+1]=row('menuTextColor','MENU TEXT COLOR',colorNames)

 parent[#parent+1]=row('menuTextShadowColor','MENU TEXT SHADOW',shadowNames)
 parent[#parent+1]=row('menuBackgroundColor','MENU BACKGROUND',bgNames)
 parent[#parent+1]=row('menuBorder','DEFAULT BORDER',catalog.choices)
 for _,scope in ipairs({'start','battle','option','save','other','dialogue','pokedex'})do
  local choices={[0]=scope=='dialogue'and 'NONE'or 'USE MENU'};for i,name in ipairs(catalog.choices)do choices[i]=name end
  parent[#parent+1]=row(scope..'BorderChoice',scope=='save'and 'SAVE SUMMARY BORDER'or scope:upper()..' BORDER',choices)
 end
 parent[#parent+1]=row('introTextColor','INTRO TEXT COLOR',selectorNames)
 parent[#parent+1]=row('introTextShadowColor','INTRO SHADOW COLOR',shadowNames)
 parent[#parent+1]=row('introLogo','TITLE LOGO',{[0]='VANILLA',[1]='HIGH RESOLUTION'})
 parent[#parent+1]=row('introTrainer','ASH TITLE ARTWORK',{[0]='OFF',[1]='ON'})
 for _,r in ipairs(menuPalette.effects.rows('intro',function(ctx,key,n)C.persist(ctx.game or ctx,key,n);return false end,function(title,rows,ctx)pushPage(ctx.game or ctx,title,rows)end))do parent[#parent+1]=r end
 parent[#parent+1]=row('introTheme','INTRO / START SCREEN FONT',{[1]='NATIVE',[2]='EMERALD'})
 parent[#parent+1]=row('introFontSize','INTRO / START TEXT SIZE',{[0]='NORMAL',[1]='LARGE',[2]='EXTRA LARGE'})
 parent[#parent+1]=row('introBackgroundColor','INTRO / START SCREEN BACKGROUND',bgNames)
 parent[#parent+1]=row('saveSummaryTheme','SAVE SUMMARY FONT',{[0]='USE MENU',[1]='NATIVE',[2]='EMERALD'})
 parent[#parent+1]=row('saveSummaryBackgroundColor','SAVE SUMMARY BACKGROUND',bgNames)
 parent[#parent+1]=row('dialogueTheme','DIALOGUE FONT',{'NATIVE','EMERALD'})
 parent[#parent+1]=row('dialogueBackgroundColor','DIALOGUE BACKGROUND',bgNames)
 parent[#parent+1]=row('dialogueTextColor','DIALOGUE TEXT COLOR',colorNames)
 parent[#parent+1]=row('dialogueTextShadowColor','DIALOGUE TEXT SHADOW',shadowNames)
 parent[#parent+1]=row('backgroundDim','BACKGROUND DIM')
 parent[#parent+1]=row('controlsLegend','CONTROL HINTS',{'ALWAYS','AUTO','HIDDEN'})
 parent[#parent+1]=row('menuTransition','MENU ANIMATION',Transitions.names)
 parent[#parent+1]=toggle('positionPreview','POSITION PREVIEW')
 parent[#parent+1]={id='wide_text_fx',label='TEXT EFFECTS',children=menuPalette.effects.rows('menu',function(ctx,key,n)C.persist(ctx.game or ctx,key,n);return false end,function(title,rows,ctx)pushPage(ctx.game or ctx or C.game,title,rows)end),activate=function(game)pushPage(game,'MENU TEXT EFFECTS',menuPalette.effects.rows('menu',function(ctx,key,n)C.persist(ctx.game or ctx,key,n);return false end,function(title,rows,ctx)pushPage(ctx.game or ctx or game,title,rows)end))end}
 parent[#parent+1]={id='wide_battle_ui',label='BATTLE SETTINGS',children=function()local ui=mod.exports.battleUi;return ui and ui.rows({},function(title,children,ctx)pushPage(ctx and (ctx.game or ctx)or C.game,title,children)end)or {}end,activate=function(game)
  local ui=mod.exports.battleUi;if ui then pushPage(game,'BATTLE',ui.rows({},function(title,children)pushPage(game,title,children)end))end
 end}
 for _,spec in ipairs({{'building_in','BUILDING ENTER'},{'building_out','BUILDING EXIT'},{'battle_in','BATTLE ENTER'},{'battle_out','BATTLE EXIT'}})do parent[#parent+1]=row('scene_'..spec[1],spec[2],SceneEffects.names)end
 local menuEntries=parent
 if mod.exports.menuSurfaces then for _,r in ipairs(mod.exports.menuSurfaces.rows(function(title,rows,ctx)return pushPage(ctx.game or ctx,title,rows)end))do parent[#parent+1]=r end end
 parent=assert(load(assert(mod:read('lib/menu_organization.lua'))))()(parent,function(title,rows,ctx)return pushPage(ctx.game or ctx,title,rows)end)
 C.rows=parent
 mod.hooks:wrap('ui.options.rows',function(next,game,rows)
  local entries=next(game,rows)
  entries[#entries+1]={id='wide_menus',label='MENUS',group=true,value=function()return 'OPEN' end,
   activate=function(g)
    local rows=assert(load(assert(mod:read('lib/menu_organization.lua'))))()(menuEntries,function(title,children,ctx)return pushPage(ctx and (ctx.game or ctx)or g,title,children)end)
    C.rows=rows;pushPage(g,'MENUS',rows)
   end}
  return entries
 end)
 marker=function(next,game,items)
  local rows=next(game,items)
  if C.setting('hideStartMods')~=1 then return rows end
  local filtered={}
  for _,entry in ipairs(rows) do
   local id=entry.id or entry.value
   if id~='mods' and id~='MODS' and entry.label~='MODS' then filtered[#filtered+1]=entry end
  end
  return filtered
 end
 mod.hooks:wrap('ui.start_menu.items',marker)

 -- Hide only the mirrored menu states, keeping input and update untouched.
 mod.hooks:wrap('screen.render_visible',function(next,state)
  if mod.generation==1 and state and state.titleUiBox and state.save and state.title and not state._customSaveSummary then
   state._customSaveSummary=true;local draw=state.draw
   state.draw=function(self,...)
    local c=Font._menuCustomizerGB;if not(c and c.live())then return draw(self,...)end
    local scope,paper,title,summary,rx,ry=c.drawScope,c.paperGroup,c.drawingTitle,c.summaryScope,c.resizeX,c.resizeY
    c.drawScope=true;c.paperGroup='save';c.drawingTitle=true;c.summaryScope=true;c.resizeX=1;c.resizeY=1
    local result={pcall(draw,self,...)}
    c.drawScope,c.paperGroup,c.drawingTitle,c.summaryScope,c.resizeX,c.resizeY=scope,paper,title,summary,rx,ry
    if not result[1]then error(result[2],0)end
    require('src.render.PaletteFX').markTrueColor(32,56,128,80)
    return (unpack or table.unpack)(result,2)
   end
  end
  local ctx=C.context(C.game)
  if ctx then for i=ctx.first,#ctx.states do if ctx.states[i]==state then return false end end end
  return next(state)
 end)
 local canvas
 local motion={}
 C.resetTransitions=function()motion={}end
 function C.prepareOptions(s)
  if s.sub or s._menuCustomizerCleanOptions then return end
  local clean={}
  for _,original in ipairs(s:visible()) do
   local link={}
   for key,value in pairs(original)do link[key]=value end
   link.value=nil;link.text=nil;link.values=nil;link.frame=nil
   link.step=nil;link.cycle=nil
   if not original.activate and not original.cancel and
       (original.values or original.frame or original.step or original.cycle) then
    link.group=true
    link.activate=function(game)
     local child=setmetatable({game=game,options=s.options,rows={original},
      view={original,{id='cancel',label='BACK',cancel=true}},index=1,scroll=0,sub=true,
      screenId='Gen2OptionsMenu',isOpaque=true},getmetatable(s))
     game.stack:push(child)
    end
   end
   if not original.cancel then clean[#clean+1]=link end
  end
  s.view=clean;s._menuCustomizerCleanOptions=true
 end
 function C.layout(group,b,viewport)
  local w,h=viewport.width,viewport.height
  local nativeScale=viewport.scale or math.min(w/160,h/144)
  local scale=nativeScale
  scale=math.max(.01,math.min(scale*C.setting(group..'Scale')/100,math.max(1,w-16)/b.w,math.max(1,h-16)/b.h))
  local bw,bh=b.w*scale,b.h*scale;local mode=C.setting(group..'Position')
  local center=mode==8 or mode==9 or mode==10
  local right=mode==3 or mode==5 or mode==7
  local bottom=mode==6 or mode==7 or mode==10
  local middle=mode==2 or mode==3 or mode==8
  local x,y
  if mode==1 then
   x=(viewport.gameX or (w-160*nativeScale)/2)+b.x*nativeScale
   y=(viewport.gameY or (h-144*nativeScale)/2)+b.y*nativeScale
  else
   x=center and (w-bw)/2 or (right and w-bw-8 or 8)
   y=middle and (h-bh)/2 or (bottom and h-bh-8 or 8)
  end
  x=math.max(0,math.min(w-bw,x+C.setting(group..'OffsetX')))
  y=math.max(0,math.min(h-bh,y+C.setting(group..'OffsetY')))
  return x,y,bw,bh,scale
 end
 local function startMetadata(s)
  if not isStart(s) then return nil end
  local list=s.list
  if list then return {owner=s,items=s.items,index=list.index,scroll=list.scroll or 0,rowY=list.y*8,pitch=list.spacing*8,labelX=list.x*8,left=80,width=80} end
  local count=math.min(s.maxVisible or #s.items,#s.items)
  return {owner=s,items=s.items,index=s.index,scroll=s.scroll or 0,rowY=(s.ty+s.th-2-(count-1)*(s.rowStep or 1))*8,
   pitch=(s.rowStep or 1)*8,labelX=(s.tx+2)*8,left=s.tx*8,width=s.tw*8}
 end
 function C.draw(game,viewport)
  local ctx=C.context(game);if not ctx then return end
  C.game=game
  C.frame=C.frame+1
  if ctx.top~=C.lastTop then C.lastTop=ctx.top;C.lastInput=love.timer.getTime() end
  local group=ctx.group;canvas=canvas or G.newCanvas(480,432,{dpiscale=1});canvas:setFilter('nearest','nearest')
  C.resizeX=C.setting(group..'Width')/100;C.resizeY=C.setting(group..'Height')/100
  G.push('all');G.setCanvas(canvas);G.origin();G.setShader();G.setScissor();G.clear(0,0,0,0);G.scale(2*C.resizeX,2*C.resizeY)
  local rect,clear=G.rectangle,G.clear
  G.clear=function(...)if C.drawingOpaque then return clear(...) end;clear(0,0,0,0)end
  G.rectangle=function(kind,x,y,w,h,...)
   if kind=='fill' and x==0 and y==0 and w==160 and h==144 and not C.inBox then
    if C.drawingList then
     if C.borders.draw(0,0,20,18) then
      C.bounds={x=0,y=0,w=160*C.resizeX,h=144*C.resizeY};return
     end
    end
    if not C.drawingOpaque then return end
   end
   -- Include filled modal panels in the measured menu bounds.
   if C.drawScope and kind=='fill' then
    local bx,by,bw,bh=x,y,w,h
    if G.transformPoint then
      local ex,ey=G.transformPoint(x+w,y+h)
      bx,by=G.transformPoint(x,y);bw,bh=ex-bx,ey-by
      bx,by,bw,bh=bx/2,by/2,bw/2,bh/2
    end
    local b=C.bounds
    if not b then C.bounds={x=bx,y=by,w=bw,h=bh}
    else
     local right,bottom=math.max(b.x+b.w,bx+bw),math.max(b.y+b.h,by+bh)
     b.x,b.y=math.min(b.x,bx),math.min(b.y,by)
     b.w,b.h=right-b.x,bottom-b.y
    end
   end
   if C.selectorScope then return rect(kind,x,y,w,h,...)end
   if C.drawScope then return menuPalette.tintFill(rect,kind,x,y,w,h,...)end
   return rect(kind,x,y,w,h,...)
  end
  C.drawScope=true;C.bounds=nil;C.paperGroup=group
  local ok,err=pcall(function()
   for i=ctx.base,#ctx.states do
    local s=ctx.states[i]
    C.drawingList=type(s.drawItemBox)=='function' and s.items~=nil and not s.itemBox
    local id=s.screenId or ''
    C.drawingCheats=C.drawingList and (id:find('GameShark',1,true)==1 or id:find('Codebreaker',1,true)==1 or s.title=='CODEBREAKER')
    C.drawingSave=s.screenId=='Gen2SaveMenu' or (C.mod.generation==1 and groupOf(s)=='save');C.saveHours=nil
    C.drawingTrainerCard=s.screenId=='Gen2TrainerCard';C.cardHours=nil
    C.drawingParty=mod.generation==1 and s.screenId=='PartyMenu' and (s.game or game) or nil
    C.drawingStart=startMetadata(s)
    C.drawingOptions=nil
    if mod.generation==1 and s.screenId=='OptionsMenu' and (s.view or s.rows) then
     -- Native category cards use half-size letters, unlike our full-size
     -- settings page. Defer their selector with the label and reserve 10px.
     local rows=s.view or s.rows;local items={}
     for _,row in ipairs(rows)do items[#items+1]=row end;items[#items+1]={label='BACK'}
     C.drawingOptions={owner=s,options=true,cards=true,fullFont=false,items=items,index=s.index,scroll=s.scroll or 0,rowY=8,pitch=32,labelX=16,left=0,width=160}
    elseif isGen2Options(s) and type(s.visible)=='function' then
     C.prepareOptions(s)
     local rows=s:visible()
     C.drawingOptions={owner=s,options=true,fullFont=true,inlineValues=s.sub,nativeValues=false,items=rows,index=s.index,scroll=s.scroll or 0,rowY=16,pitch=s.sub and 32 or 16,labelX=16,left=0,width=160}
    elseif s.screenId=='MenuCustomizerOptions' then
     local rows={};for _,row in ipairs(s.rows)do rows[#rows+1]=row end;rows[#rows+1]={label='BACK'}
     C.drawingOptions={owner=s,options=true,fullFont=true,inlineValues=s.detail,items=rows,index=s.index,scroll=s.scroll or 0,rowY=24,pitch=s.detail and 32 or 16,labelX=24,left=0,width=160}
    end
    -- Options clears the whole canvas before drawing its frame. Custom frame
    -- corners need transparent pixels outside the paper, unlike opaque screens.
    local framedOptions=isGen2Options(s) and
     (C.setting('menuTheme')==2 or (catalog.entries[C.setting('menuBorder')] or {}).path~=nil)
    C.drawingOpaque=not framedOptions and
     (s.isOpaque==true or s.screenId=='TrainerCard' or s.screenId=='Gen2TrainerCard')
    local anchor=s.anchor;s.anchor=nil
    local description=s.showDescription
    if mod.generation==2 and isStart(s) then s.showDescription=false end
    local draw=s.draw
    if isGen2Options(s) and s.sub then
     local rows=s:visible();s.scroll=math.max(0,math.min(s.scroll or 0,s.index-1))
     if s.index>s.scroll+3 then s.scroll=s.index-3 end
     C.drawingOptions.scroll=s.scroll
     draw=function()
      local Chrome=require('src.ui.gen2.Chrome');local Strings=require('src.core.Strings')
      Chrome.box(0,0,20,18)
      for slot=1,3 do
       local row=rows[s.scroll+slot]
       if row then
        local y=16+(slot-1)*32
        Font.draw(Strings(row.label),16,y)
        local value
        if row.frame then value='TYPE '..tostring(s.options.frame or 1)
        elseif row.text then value=row.text(s.options)
        elseif row.values then local v=s.options[row.key];value=row.display and Strings(row.display[v]) or tostring(v)
        elseif type(row.value)=='function' then local ok,v=pcall(row.value,s.game);value=ok and tostring(v) or '?' end
        if value then Font.draw(value,88,y+16) end
       end
      end
      if s.scroll+3<#rows then Font.drawCode(Chrome.DOWN_ARROW,8,120) end
     end
    end
    -- uiSize owners may draw a scaled 640x576 page. Capture it in classic
    -- design coordinates before our own supersampling/layout transform,
    -- rather than clipping the enlarged page inside a fixed 480x432 canvas.
    G.push('all')
    if type(s.uiSize)=='function' then
     local valid,w,h=pcall(s.uiSize,s)
     if valid and type(w)=='number' and type(h)=='number' and
         w>=160 and h>=144 and w<=640 and h<=576 then G.scale(160/w,144/h) end
    end
    local drawn,e=pcall(draw,s)
    G.pop();s.anchor=anchor;s.showDescription=description
    if drawn and C.drawSelector then
     C.selectorScope=true
     local selected,e=pcall(C.drawSelector,C.drawingStart or C.drawingOptions)
     C.selectorScope=nil
     if not selected then error(e,0)end
    end
    if not drawn then error(e,0) end
   end
  end)
  C.resizeX=nil;C.resizeY=nil;C.drawingTrainerCard=nil;C.cardHours=nil;C.drawingList=nil;C.drawingSave=nil;C.saveHours=nil;C.drawScope=false;C.paperGroup=nil;C.drawingStart=nil;C.drawingOptions=nil;C.drawingOpaque=nil;G.rectangle,G.clear=rect,clear
  C.drawingCheats=nil;C.compactText=nil;C.drawingParty=nil
  G.pop()
  if not ok then error(err,0) end
  local b=C.bounds
  b=b or {x=0,y=0,w=160,h=144}
  local x,y,bw,bh,scale=C.layout(group,b,viewport)
  C.layouts[group]={x=x,y=y,w=bw,h=bh}
  local now=love.timer.getTime();local style=C.setting('menuTransition');local st=motion[group]
  if not st or st.top~=ctx.top then st={born=now,top=ctx.top};motion[group]=st end
  local alpha=style==1 and 1 or math.min(1,(now-st.born)/.15)
  local opacity=C.setting((group=='save' and 'other' or group)..'Opacity')/100
  if style==3 then y=y+(C.setting(group..'Position')>=6 and 1 or -1)*12*(1-alpha) end
  G.push('all');G.origin();G.setShader();G.setScissor()
  G.setColor(0,0,0,C.setting('backgroundDim')/100);G.rectangle('fill',0,0,viewport.width,viewport.height)
  G.setBlendMode('alpha','premultiplied');G.setColor(opacity*alpha,opacity*alpha,opacity*alpha,opacity*alpha)
  Transitions.scope(style,math.min(1,(now-st.born)/.32),{x=x,y=y,w=bw,h=bh},function()G.draw(canvas,x-b.x*scale,y-b.y*scale,0,scale/2,scale/2)end,{b.x/160,b.y/144,b.w/160,b.h/144})
  -- Preview the actual visible menu bounds without moving any input state.
  if C.setting('positionPreview')==1 and C.previewGroup and now<=(C.previewUntil or 0) then
   local preview=C.layouts[C.previewGroup]
   if preview then G.setColor(.35,.85,1,.85);G.rectangle('line',preview.x,preview.y,preview.w,preview.h) end
  end
  local hints=C.setting('controlsLegend')
  if C.legendVisible(now)then
   G.setBlendMode('alpha');G.setColor(0,0,0,.8)
   local hintScale=math.max(1,math.floor(math.min(viewport.width/160,viewport.height/144)))
   local bottom=viewport.height-10*hintScale
   G.translate(8,bottom);G.scale(hintScale,hintScale);Font.draw('A:SELECT B:BACK',0,0)
  end
  G.pop()
 end
 mod.hooks:wrap('render.hud',function(next,game,viewport)
  next(game,viewport);C.game=game;C.draw(game,viewport)
 end)
 local function attach(game)
  C.game=game
  if game._menuCustomizerAmbient then return end
  game._menuCustomizerAmbient=true
  local update=game.update
  game.update=function(self,dt,...)
   local result=update(self,dt,...)
   local current=Font._menuCustomizerGB
   local ctx=current and current.context(self)
   if ctx then
    local input=self.input
    for _,key in ipairs({'a','b','start','up','down','left','right'}) do
     if input and input.wasPressed and input:wasPressed(key) then current.lastInput=love.timer.getTime();break end
    end
    current.ambientAccum=math.min((current.ambientAccum or 0)+dt,.05)
    while current.ambientAccum>=1/60 do
     current.ambientAccum=current.ambientAccum-1/60
     local world=ctx.world
     if mod.generation==2 and world.updatePeople then world:updatePeople();if world.pollTileAnim then world:pollTileAnim()end
     else
      for _,npc in ipairs(world.npcs or {}) do npc:update(world.map,world.entities) end
      for _,ghost in ipairs(world.ghosts or {}) do ghost.npc:update(ghost.map,ghost.peers) end
     end
    end
   end
   return result
  end
 end
 mod.events:on('game.ready',function(event)attach(event.game)end)
 mod.exports.borders=Borders;mod.exports.borderCatalog=catalog;mod.exports.gbMenus=C;
 assert(load(assert(mod:read('lib/preview_windows.lua'))))()(mod,menuPalette,function()return C.live()end)
 assert(load(assert(mod:read('lib/gb_pokedex_text.lua'))))()(Font,function()return Font._menuCustomizerGB end)
 -- The boot menu has no overworld, so it cannot use the HUD menu mirror.
 local Menu=require('src.ui.Menu')
 if not Menu._menuCustomizerTitle then
  Menu._menuCustomizerTitle=true;local draw=Menu.draw
  Menu.draw=function(self,...)
   local c=Font._menuCustomizerGB
   if not(self.titleUiBox and c and c.live())then return draw(self,...)end
   local scope,paper,title,intro,rx,ry=c.drawScope,c.paperGroup,c.drawingTitle,c.introScope,c.resizeX,c.resizeY
   c.drawScope=true;c.paperGroup='other';c.drawingTitle=true;c.introScope=true;c.resizeX=1;c.resizeY=1
   local oldFit,oldMenu=c.introFitScale,c.introMenuScale
   local tx,ty,tw,th,rowStep,itemY,maxVisible=self.tx,self.ty,self.tw,self.th,self.rowStep,self.itemY,self.maxVisible
   if c.setting('introFontSize')>0 and c.theme.enabled() then
    local scale=c.setting('introFontSize')+1
    local visible=math.min(#self.items,4)
    local function dimensions()
     c.introFitScale=scale
     local widest=0;for _,item in ipairs(self.items)do widest=math.max(widest,Font.width(item.label))end
     local pitch=math.ceil((14*scale+4)/8)
     local first=math.ceil(14*scale/8)
     return math.ceil((widest+24)/8),first+(visible-1)*pitch+2,pitch,first
    end
    local width,height,pitch,first=dimensions()
    while scale>1 and (width>20 or height>18)do scale=scale-1;width,height,pitch,first=dimensions()end
    c.introMenuScale=scale;c.introFitScale=scale
    self.tx=0;self.ty=0;self.tw=math.min(20,math.max(tw,width));self.th=math.min(18,math.max(th,height))
    self.rowStep=pitch;self.itemY=first;self.maxVisible=visible
   end
   local result={pcall(draw,self,...)}
   if c.mod.generation==1 then require('src.render.PaletteFX').markTrueColor(self.tx*8,self.ty*8,self.tw*8,self.th*8)end
   self.tx,self.ty,self.tw,self.th,self.rowStep,self.itemY,self.maxVisible=tx,ty,tw,th,rowStep,itemY,maxVisible
   c.introFitScale,c.introMenuScale=oldFit,oldMenu
   c.drawScope,c.paperGroup,c.drawingTitle,c.introScope,c.resizeX,c.resizeY=scope,paper,title,intro,rx,ry
   if not result[1]then error(result[2],0)end
   if c.mod.generation==1 then
    require('src.render.PaletteFX').markTrueColor(self.tx*8,self.ty*8,self.tw*8,self.th*8)
   end
   return (unpack or table.unpack)(result,2)
  end
 end
 assert(load(assert(mod:read('lib/intro_background.lua'))))()(mod,menuPalette,function()return C.live()end)
 assert(load(assert(mod:read('lib/intro_font.lua'))))()(mod,Font,function()return C.live()end)
 assert(load(assert(mod:read('lib/title_ash.lua'))))()(mod,function()return C.live()end)
 assert(load(assert(mod:read('lib/title_logo.lua'))))()(mod,function()return C.live()end)
 assert(load(assert(mod:read('lib/title_positions.lua'))))()(mod,function()return C.live()end)
 mod.exports.version='3.2.81'
 assert(load(assert(mod:read('lib/scene_transitions.lua'))))()(mod,function()return C.live()end)
 mod.log:info('Menu Customizer: native Gen '..mod.generation..' menus and all borders installed')
 return C
end
