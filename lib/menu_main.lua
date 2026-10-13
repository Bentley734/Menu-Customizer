return function(mod)
  local gameVersion = require('src.core.GameVersion').get()
  local catalog=assert(load(assert(mod:read('lib/border_catalog.lua')), '@'..mod.path..'/lib/border_catalog.lua'))()
  if mod.generation ~= 3 then
    return assert(load(assert(mod:read('lib/gb_menus.lua')), '@'..mod.path..'/lib/gb_menus.lua'))()(mod,catalog)
  end
  local Runtime = require('src.core.game3.runtime')
  local Battle = require('src.core.game3.battle')
  local Display = require('src.core.game3.display')
  local Renderer = require('src.render.Renderer')
  if Renderer._menuCustomizerGen3 then return Renderer._menuCustomizerGen3(mod,gameVersion,catalog) end
  local EngineRuntime=require('src.mods.Runtime')
  local startItemsHook
  local function active()
    local chain=EngineRuntime.hooks and EngineRuntime.hooks.chains and EngineRuntime.hooks.chains['ui.start_menu.items']
    for _,entry in ipairs(chain or {}) do
      if entry.owner==mod.id and entry.callback==startItemsHook then return true end
    end
    return false
  end
  local Start = require('src.ui.game3.start_menu')
  local function optionForVersion(version)
    if version=='ruby' or version=='sapphire'then
      local ok,menu=pcall(require,'src.ui.game3.rs.option_menu')
      if ok then return menu end
    end
    return require((version=='emerald' or version=='ruby' or version=='sapphire')
      and 'src.ui.game3.rse.option_menu' or 'src.ui.game3.option_menu')
  end
  local Option = optionForVersion(gameVersion)
  local Save = require('src.ui.game3.save_menu')
  local Stack = require('src.ui.game3.stack')
  local Fade = require('src.ui.game3.fade')
  local Bag = require('src.ui.game3.bag_menu')
  local originalBagShow = Bag.show
  Bag.show = function(...)
    local result = originalBagShow(...)
    if not active() then return result end
    Bag._open = nil -- Show the fully visible Bag on its first frame.
    Bag._bagAnim = nil -- Skip the bag icon's opening bounce.
    return result
  end
  local originalFadeBegin = Fade.begin
  Fade.begin = function(mode, speed, ...)
    -- Closing the Bag returns to the still-open START menu, yet the engine
    -- starts a fade from black. In widescreen that briefly covers the world.
    -- Keep the fade for item use and other transitions that leave START.
    local top = Stack.top()
    if active() and mode == Fade.MODE.FROM_BLACK and top and top.id == 'start'
        and Start.isOpen() and not Stack.has('bag') then
      return
    end
    return originalFadeBegin(mode, speed, ...)
  end
  local Rows = require('src.ui.game3.option_rows')
  -- Keep the internal ID so existing installs and saved options migrate in place.
  local MOD_ID = 'gen3transparency'
  local LEGACY_MOD_ID = 'firered_widescreen_qol'
  local choices = {'DEFAULT', 'LEFT', 'RIGHT', 'TOP LEFT', 'TOP RIGHT', 'BOTTOM LEFT', 'BOTTOM RIGHT', 'CENTER', 'TOP CENTER', 'BOTTOM CENTER'}
  local justifyChoices = {'LEFT', 'CENTER', 'RIGHT'}
  local Selectors=assert(load(assert(mod:read('lib/menu_selectors.lua'))))()
  local LevelText=assert(load(assert(mod:read('lib/level_text.lua'))))()
  local SceneEffects=assert(load(assert(mod:read('lib/scene_effects.lua'))))()
  local selectorChoices = Selectors.names
  local borderChoices = catalog.choices
  local opacityChoices = {}
  for pct = 65, 100, 5 do opacityChoices[#opacityChoices+1] = pct end
  local keys = {'startPosition', 'startJustify', 'startSelector', 'optionPosition', 'savePosition', 'otherPosition',
    'startOpacity', 'optionOpacity', 'otherOpacity', 'hideStartMods'}
  local menuPalette=assert(load(assert(mod:read('lib/battle_text_palette.lua'))))()(mod)
  local Transitions=assert(load(assert(mod:read('lib/menu_transitions.lua'))))()
  local extra = {selectionHighlight={25,0,100,5},arrowSelector={1,1,13,1},selectorColor={0,0,#menuPalette.names-1,1},dialogueJustify={1,1,3,1},menuTextColor={0,0,#menuPalette.names-1,1},menuTextShadowColor={0,0,#menuPalette.shadowNames-1,1},menuBackgroundColor={0,0,#menuPalette.menuBackgroundNames-1,1},startMenuBackgroundColor={0,0,#menuPalette.menuBackgroundNames-1,1},dialogueBorder={0,0,1,1},menuTheme={2,1,2,1}, menuBorder={1,1,#borderChoices,1}, backgroundDim={0,0,70,10}, controlsLegend={2,1,3,1},
    menuTransition={3,1,#Transitions.names,1}, positionPreview={1,0,1,1}}

  for _,scope in ipairs({'start','battle','option','save','other','dialogue'})do extra[scope..'BorderChoice']={0,0,#borderChoices,1}end
 extra.dialogueTheme={2,1,2,1};extra.dialogueBackgroundColor={0,0,#menuPalette.menuBackgroundNames-1,1};extra.dialogueTextColor={0,0,#menuPalette.names-1,1};extra.dialogueTextShadowColor={0,0,#menuPalette.shadowNames-1,1}

  for _, group in ipairs({'start','option','save','other'}) do
    extra[group..'Scale']={100,50,150,10}
    extra[group..'OffsetX']={0,-128,128,1}
    extra[group..'OffsetY']={0,-128,128,1}
  end
  for _,key in ipairs({'building_in','building_out','battle_in','battle_out'})do extra['scene_'..key]={1,1,#SceneEffects.names,1}end
  for k,v in pairs(menuPalette.effects.specs('menu'))do extra[k]=v end
  for key in pairs(extra) do keys[#keys+1]=key end
  local FX
  local ArrowSelectors
  local values
  local function isOpacity(key) return key:find('Opacity') ~= nil end
  local function isToggle(key) return key == 'hideStartMods' end
  local function settings()
    if values then return values end
    values = {}
    local format = mod.options:get('opacityFormat')
    local runtime = Runtime
    local game = runtime and runtime._game
    local legacy = game and game.options and game.options.modOptions
      and game.options.modOptions[LEGACY_MOD_ID]
    if format == nil and legacy then format = legacy.opacityFormat end
    local previous = {100, 85, 70, 55, 40}
    for _, key in ipairs(keys) do
      local raw = mod.options:get(key)
      if raw == nil then raw = mod.save:get(key) end
      if raw == nil and legacy then raw = legacy[key] end
      local n = tonumber(raw)
      if key=='menuBorder' then n=catalog.selection(raw,mod.options:get('borderCatalogFormat') or mod.save:get('borderCatalogFormat') or (legacy and legacy.borderCatalogFormat)) end
      if extra[key] then
        local spec=extra[key]
        values[key]=math.max(spec[2],math.min(spec[3],math.floor(n or spec[1])))
      elseif isToggle(key) then
        values[key] = n == 1 and 1 or 0
      elseif isOpacity(key) then
        if format ~= 2 then n = n and previous[math.floor(n)] end
        local percent = math.max(65, math.min(100, math.floor((n or 100)/5)*5))
        values[key] = math.floor((percent - 65)/5) + 1
      elseif key == 'startJustify' then
        values[key] = math.max(1, math.min(#justifyChoices, math.floor(n or 1)))
      elseif key == 'startSelector' then
        values[key] = math.max(1, math.min(#selectorChoices, math.floor(n or 3)))
      else
        values[key] = math.max(1, math.min(#choices, math.floor(n or 1)))
      end
    end
    return values
  end
  mod.exports.resetMenuSettings=function()values=nil;if FX then FX.touch('settingsScope')end end
  local function setting(key)
    return settings()[key]
  end
  local function installArrows()
    ArrowSelectors=assert(load(assert(mod:read('lib/arrow_selectors.lua'))))()(mod,Selectors,setting,active)
    mod.exports.arrowSelectors=ArrowSelectors;mod.exports.selectorPalette=menuPalette
    assert(load(assert(mod:read('lib/tm_case_labels.lua'))))()(mod,active)
  end
  installArrows()
  local function persist(key, value, ctx)
    -- Update the menu immediately, then write the same values into the
    -- engine's global options table and the loader's live lookup table.
    settings()[key] = value
    if key=='dialogueBorderChoice'and value>0 then settings().dialogueBorder=1;mod.save:set('dialogueBorder',1)end

    if FX then FX.touch(key) end
    local runtime = Runtime
    local game = ctx.game or (runtime and runtime._game)
    local options = game and game.options or ctx.options
    local function update(root)
      if not root then return end
      root.modOptions = root.modOptions or {}
      local bucket = root.modOptions[MOD_ID] or {}
      root.modOptions[MOD_ID] = bucket
      for _, k in ipairs(keys) do
        bucket[k] = isOpacity(k) and opacityChoices[settings()[k]] or settings()[k]
      end
      bucket.opacityFormat = 2
      if key=='battleBorderChoice'and value>0 then bucket.battle_style=3;mod.save:set('battle_style',3)end
      bucket.borderCatalogFormat = 2
    end
    update(options)
    if ctx.options ~= options then update(ctx.options) end
    local loader = game and game.mods
    if loader then
      loader.modOptions = loader.modOptions or {}
      loader.modOptions[MOD_ID] = options.modOptions[MOD_ID]
    end
    if mod.exports.settingsProfiles then mod.exports.settingsProfiles.commit(ctx)end
    if game and game.writeOptions then game:writeOptions() end
  end
  FX=assert(load(assert(mod:read('lib/menu_fx.lua')), '@'..mod.path..'/lib/menu_fx.lua'))()({
    setting=setting, Battle=Battle, Stack=Stack, mod=mod,
    Font=require('src.ui.game3.frlg_font')})
  mod.exports.menuBackground=function()
    if FX.active or mod.exports.previewScope or mod.exports.dialogueFontScope then return menuPalette.menuBackground(mod.exports.menuPaperScope or (FX.topId=='start' and 'start' or 'other'))end
  end
  local Borders=assert(load(assert(mod:read('lib/menu_borders.lua')), '@'..mod.path..'/lib/menu_borders.lua'))()(mod, setting, catalog, active)
  mod.exports.borders=Borders
  mod.exports.borderCatalog=catalog
  local Message=require('src.ui.game3.message')
  Message._menuCustomizerDialogueMod=mod
  if not Message._menuCustomizerFontScope then
   for _,name in ipairs({'draw','drawText'})do
    local original=Message[name]
    Message[name]=function(...)
     local exports=Message._menuCustomizerDialogueMod.exports
     local prior=exports.dialogueFontScope;exports.dialogueFontScope=Message._frame~='battle'
     local result={pcall(original,...)};exports.dialogueFontScope=prior
     if not result[1]then error(result[2],0)end
     return (unpack or table.unpack)(result,2)
    end
   end
   Message._menuCustomizerFontScope=true
  end
  local Hud=require('src.ui.game3.hud')
  local oldHudUpdate=Hud.update
  Hud.update=function(game,dt,inputTop,...)
    local input=game and game.input
    if input then
      for _, key in ipairs({'a','b','start','select','up','down','left','right','l','r'}) do
        if input.wasPressed and input:wasPressed(key) or input.isDown and input:isDown(key) then
          FX.lastInput=love.timer.getTime();break
        end
      end
    end
    return oldHudUpdate(game,dt,inputTop,...)
  end
  local Chrome=require('src.ui.game3.pokedex_chrome')
  for _, name in ipairs({'drawControlInfo','drawControlInfoLeft'}) do
    local original=Chrome[name]
    Chrome[name]=function(...)if FX.legendVisible() then return original(...) end end
  end
  local lastStartRows
  local function filteredStartRows(rows)
    if type(rows) ~= 'table' or setting('hideStartMods') ~= 1 then return rows end
    local out = {}
    for _, entry in ipairs(rows) do
      if entry.id ~= 'mods' then out[#out+1] = entry end
    end
    return out
  end
  startItemsHook=function(next, game, items)
    local rows = next(game, items)
    if type(rows) == 'table' then
      lastStartRows = rows
      return filteredStartRows(rows)
    end
    return rows
  end
  mod.hooks:wrap('ui.start_menu.items',startItemsHook)
  local function refreshStartRows()
    if not (lastStartRows and Start.isOpen()) then return end
    local selected = Start.ENTRIES[Start.cursor]
    Start.ENTRIES = filteredStartRows(lastStartRows)
    if selected then
      for i, entry in ipairs(Start.ENTRIES) do
        if entry.id == selected.id then Start.cursor = i; return end
      end
    end
    Start.cursor = math.max(1, math.min(Start.cursor, #Start.ENTRIES))
  end
  local function toggleModsRow()
    return {id='wide_hideStartMods', label='HIDE START MODS',
      value=function() return setting('hideStartMods') == 1 and 'ON' or 'OFF' end,
      step=function(ctx)
        persist('hideStartMods', 1 - setting('hideStartMods'), ctx)
        refreshStartRows()
        return false
      end}
  end
  local function row(key, label, variants)
    variants = variants or choices
    return {id='wide_'..key, label=label,
      value=function() return variants[setting(key)] end,
      step=function(ctx, direction)
        persist(key, ((setting(key)-1 + (direction < 0 and -1 or 1)) % #variants)+1, ctx)
        return false -- persisted above; avoid a second options-file write
      end}
  end
  local function opacityRow(key, label)
    return {id='wide_'..key, label=label,
      value=function() return tostring(opacityChoices[setting(key)] or 100)..'%' end,
      step=function(ctx, direction)
        persist(key, ((setting(key)-1 + (direction < 0 and -1 or 1)) % #opacityChoices)+1, ctx)
        return false
      end}
  end
  local members = {}
  for _, key in ipairs(keys) do members[#members+1] = 'wide_'..key end
  Rows.GROUPS[#Rows.GROUPS+1] = {id='group.gen3transparency_menus', label='MENUS', members=members}
  Rows.ORDER[#Rows.ORDER+1] = 'group.gen3transparency_menus'
  local oldBuild = Rows.build
  Rows.build = function(ctx)
    local entries = oldBuild(ctx)
    if not active() then return entries end
    for _,spec in ipairs({{'building_in','BUILDING ENTER'},{'building_out','BUILDING EXIT'},{'battle_in','BATTLE ENTER'},{'battle_out','BATTLE EXIT'}})do
      entries[#entries+1]=row('scene_'..spec[1],spec[2],SceneEffects.names)
    end
    entries[#entries+1] = row('menuBorder', 'MENU BORDER', borderChoices)
    local dialogue=row('dialogueBorder','DIALOGUE BORDER ON/OFF',{[0]='OFF',[1]='ON'})
    dialogue.step=function(ctx)persist('dialogueBorder',1-setting('dialogueBorder'),ctx);return false end
    entries[#entries+1]=dialogue
    for _,scope in ipairs({'start','battle','option','save','other','dialogue'})do
      local key=scope..'BorderChoice'
      local r={id='wide_'..key,label=scope:upper()..' BORDER',value=function()return setting(key)==0 and 'USE MENU' or borderChoices[setting(key)]end,
        step=function(ctx,d)persist(key,(setting(key)+(d<0 and -1 or 1))%(#borderChoices+1),ctx);return false end}
      entries[#entries+1]=r
    end
    entries[#entries+1]=row('dialogueTheme','DIALOGUE FONT',{'NATIVE','EMERALD'})
    local dialogBg={};for i,name in ipairs(menuPalette.menuBackgroundNames)do dialogBg[i-1]=name end
    local bg=row('dialogueBackgroundColor','DIALOGUE BACKGROUND',dialogBg)
    bg.step=function(ctx,d)persist('dialogueBackgroundColor',menuPalette.step('menuBackground',setting('dialogueBackgroundColor'),d),ctx);return false end
    entries[#entries+1]=bg
    for _,spec in ipairs({{'dialogueTextColor','DIALOGUE TEXT COLOR','text',menuPalette.names},{'dialogueTextShadowColor','DIALOGUE TEXT SHADOW','shadow',menuPalette.shadowNames}})do
      local key,label,kind,names=spec[1],spec[2],spec[3],spec[4]
      entries[#entries+1]={id='wide_'..key,label=label,value=function()return names[setting(key)+1]end,step=function(ctx,d)persist(key,menuPalette.step(kind,setting(key),d),ctx);return false end}
    end
    entries[#entries+1] = row('startPosition', 'START POSITION')
    entries[#entries+1] = row('startJustify', 'START ALIGNMENT', justifyChoices)
    entries[#entries+1] = row('dialogueJustify','DIALOGUE ALIGNMENT',justifyChoices)
    local selectorNames={};for i,name in ipairs(menuPalette.names)do selectorNames[i-1]=name end
    local selectorColor=row('selectorColor','UNDERLINE / DOTS COLOR',selectorNames)
    selectorColor.step=function(ctx,d)persist('selectorColor',menuPalette.step('text',setting('selectorColor'),d),ctx);return false end
    entries[#entries+1]=selectorColor
    entries[#entries+1] = row('menuTheme','MENU FONT',{'NATIVE','EMERALD'})
    local colorNames={};for i,name in ipairs(menuPalette.names)do colorNames[i-1]=name end
    local textRow=row('menuTextColor','MENU TEXT COLOR',colorNames)
    textRow.step=function(ctx,dir)persist('menuTextColor',menuPalette.step('text',setting('menuTextColor'),dir),ctx);return false end
    entries[#entries+1]=textRow
    local shadowNames={};for i,name in ipairs(menuPalette.shadowNames)do shadowNames[i-1]=name end
    entries[#entries+1]={id='wide_menuTextShadowColor',label='MENU TEXT SHADOW',value=function()return shadowNames[setting('menuTextShadowColor')]end,
      step=function(ctx,dir)persist('menuTextShadowColor',menuPalette.step('shadow',setting('menuTextShadowColor'),dir),ctx);return false end}
    entries[#entries+1] = row('startSelector', 'START SELECTOR', selectorChoices)
    entries[#entries+1] = row('arrowSelector','ARROW SELECTOR',ArrowSelectors.names)
    entries[#entries+1]={id='wide_selectionHighlight',label='HIGHLIGHT INTENSITY',value=function()return setting('selectionHighlight')..'%'end,
      step=function(ctx,d)persist('selectionHighlight',math.max(0,math.min(100,setting('selectionHighlight')+(d<0 and -5 or 5))),ctx);return false end}
    entries[#entries+1] = row('optionPosition', 'OPTION POSITION')
    entries[#entries+1] = row('savePosition', 'SAVE POSITION')
    entries[#entries+1] = row('otherPosition', 'OTHER POSITION')
    entries[#entries+1] = opacityRow('startOpacity', 'START OPACITY')
    entries[#entries+1] = opacityRow('optionOpacity', 'OPTION OPACITY')
    entries[#entries+1] = opacityRow('otherOpacity', 'OTHER OPACITY')
    entries[#entries+1] = toggleModsRow()
    for _, group in ipairs({'start','option','save','other'}) do
      for _, suffix in ipairs({'Scale','OffsetX','OffsetY'}) do
        local key=group..suffix;local spec=extra[key]
        entries[#entries+1]={id='wide_'..key,label=group:upper()..' '..({Scale='SCALE',OffsetX='X OFFSET',OffsetY='Y OFFSET'})[suffix],
          value=function()return tostring(setting(key))..(suffix=='Scale' and '%' or ' PX') end,
          step=function(c,d)persist(key,math.max(spec[2],math.min(spec[3],setting(key)+(d<0 and -spec[4] or spec[4]))),c);return false end}
      end
    end
    for _,key in ipairs({'menuBackgroundColor','startMenuBackgroundColor'})do
      local bgNames={};for i,name in ipairs(menuPalette.menuBackgroundNames)do bgNames[i-1]=name end
      bgNames[0]=key=='startMenuBackgroundColor' and 'USE MENU' or 'DEFAULT'
      entries[#entries+1]={id='wide_'..key,label=key=='menuBackgroundColor' and 'MENU BACKGROUND' or 'START BACKGROUND',value=function()return bgNames[setting(key)]end,
        step=function(ctx,dir)persist(key,menuPalette.step('menuBackground',setting(key),dir),ctx);return false end}
    end
    entries[#entries+1]=row('controlsLegend','CONTROL HINTS',{'ALWAYS','AUTO','HIDDEN'})
    entries[#entries+1]=row('menuTransition','TRANSITIONS',Transitions.names)
    entries[#entries+1]={id='wide_backgroundDim',label='BACKGROUND DIM',value=function()return setting('backgroundDim')..'%' end,
      step=function(c,d)persist('backgroundDim',math.max(0,math.min(70,setting('backgroundDim')+(d<0 and -10 or 10))),c);return false end}
    entries[#entries+1]={id='wide_positionPreview',label='POSITION PREVIEW',value=function()return setting('positionPreview')==1 and 'ON' or 'OFF' end,
      step=function(c)persist('positionPreview',1-setting('positionPreview'),c);return false end}
    return entries
  end
  local originalGroup=Rows.group
  Rows.group=function(entries,openPage)
    if not active() then return originalGroup(entries,openPage) end
    return originalGroup(entries,function(title,members)
      if title~='MENUS' then return openPage(title,members) end
      for _,r in ipairs(members)do
        local key=r.id:match('^wide_(.*)')
        local kind=(key=='menuTextColor'or key=='dialogueTextColor'or key=='selectorColor') and 'text' or (key=='menuTextShadowColor'or key=='dialogueTextShadowColor') and 'shadow' or (key=='menuBackgroundColor' or key=='startMenuBackgroundColor' or key=='dialogueBackgroundColor') and 'menuBackground'
        if kind then menuPalette.picker(r,kind,function()return setting(key)end,function(ctx,n)persist(key,n,ctx);return false end,openPage,key=='startMenuBackgroundColor' and 'USE MENU' or nil)end
        if key=='menuBorder'or key:match('BorderChoice$')then menuPalette.designPicker(r,catalog.groups,function()return setting(key)end,function(ctx,n)persist(key,n,ctx);return false end,openPage)end
      end
      local parent={};for _,r in ipairs(members)do parent[#parent+1]=r end
      parent[#parent+1]=mod.exports.settingsProfiles.row()
      parent[#parent+1]={id='wide_text_fx',label='MENU TEXT EFFECTS',children=menuPalette.effects.rows('menu',function(ctx,key,n)persist(key,n,ctx);return false end,openPage),value=function()return 'OPEN'end,activate=function()openPage('MENU TEXT EFFECTS',menuPalette.effects.rows('menu',function(ctx,key,n)persist(key,n,ctx);return false end,openPage))end}
      local battleUi=mod.exports.battleUi
      if battleUi then parent[#parent+1]={id='wide_battle_ui',label='BATTLE SETTINGS',children=battleUi.rows({},openPage),value=function()return 'OPEN'end,activate=function()openPage('BATTLE',battleUi.rows({},openPage))end}end
      parent=assert(load(assert(mod:read('lib/menu_organization.lua'))))()(parent,openPage)
      openPage(title,parent)
    end)
  end

  -- The field and the menus opened from START live in separate Game3
  -- canvases. Fade only the latter when the renderer composites them. This
  -- also includes nested screens such as a Pokemon summary or bag actions.
  local originalBlitCanvas = Renderer.blitCanvas
  -- Full-screen UI layers intentionally stop drawing the field. On a
  -- widescreen display their UI pillarbox would otherwise fill all unused
  -- space. Preserve the last overworld frame and composite it back first.
  local fieldSnapshot
  local function cacheField(source)
    local sw, sh = source:getWidth(), source:getHeight()
    if not fieldSnapshot or fieldSnapshot:getWidth() ~= sw or fieldSnapshot:getHeight() ~= sh then
      if fieldSnapshot and fieldSnapshot.release then fieldSnapshot:release() end
      fieldSnapshot = love.graphics.newCanvas(sw, sh, {dpiscale=1})
      fieldSnapshot:setFilter('nearest', 'nearest')
    end
    local Viewport = require('src.render.GameViewport')
    love.graphics.push('all')
    love.graphics.setCanvas(fieldSnapshot)
    love.graphics.origin()
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(source, 0, 0)
    Viewport.setTarget()
    love.graphics.pop()
  end
  local originalEndFrame = Renderer.endFrame
  local lastAmbientTick
  local function tickAmbient(game)
    local Objects=require('src.core.game3.objects')
    local Ghosts=require('src.core.game3.ghosts')
    local TilesetAnim=require('src.core.game3.tileset_anim')
    -- Menu input stays with the menu. Advance visual world actors and water
    -- tiles only; Field.update would move the player or activate scripts.
    local now = love.timer.getTime()
    if lastAmbientTick then
      local frames = math.min(3, math.floor((now - lastAmbientTick) * 60))
      for _ = 1, math.max(0, frames) do
        Objects.update(game)
        Ghosts.update(game)
        TilesetAnim.step()
        require('src.core.game3.field_effects').step()
        require('src.world.game3.Follower').update(game)
        FX.ambient()
      end
      if frames > 0 then lastAmbientTick = lastAmbientTick + frames/60 end
      if now-lastAmbientTick>.25 then lastAmbientTick=now end
    else
      lastAmbientTick = now
    end
  end
  local function drawLiveField(self, game)
    local FieldView = require('src.core.game3.field_view')
    local Oam = require('src.core.game3.oam')
    local Bg = require('src.core.game3.bg')
    love.graphics.push('all')
    local ok, err = pcall(function()
      self:beginWorldPass()
      love.graphics.origin()
      local vw, vh = self:worldViewSize()
      Oam.resetFrame()
      local previous = Oam.setLayer('world')
      local drawn,drawError=pcall(FieldView.draw,game,vw,vh)
      Oam.setLayer(previous)
      if not drawn then error(drawError,0) end
      Oam.animateSprites('world')
      Oam.buildOamBuffer()
      if Bg.hasVisible() then
        for pri = 3, 0, -1 do
          Bg.flushPriority(pri)
          Oam.flushPriority(pri, 'world')
        end
      else
        Oam.flush('world')
      end
      self:endWorldPass()
    end)
    love.graphics.pop()
    if not ok then error(err, 0) end
  end
  local warnedLiveField = false
  Renderer.endFrame = function(self, ...)
    if not active() then return originalEndFrame(self,...) end
    local top = Stack.top()
    local runtime = Runtime
    local game = runtime and runtime._game
    local battle = Battle
    local inFieldMenu = top and
      (FX.active or Stack.has('start') or top.id == 'dexnav' or top.id == 'gen3_dexnav' or top.id == 'codebreaker')
    if inFieldMenu and game and runtime.isActive()
        and not (battle and battle.isActive and battle.isActive()) then
      local ok, err = pcall(function()
        tickAmbient(game)
        if not self.worldActive then drawLiveField(self,game) end
      end)
      if not ok then
        self.worldActive = false
        if not warnedLiveField then
          warnedLiveField = true
          mod.log:warn('Menu Customizer live menu field unavailable: '..tostring(err))
        end
      end
    else
      lastAmbientTick = nil
    end
    -- Prefer the live map. A snapshot is retained for transitions where the
    -- engine has no active field (and for engines without field pass support).
    -- Battle-owned menus must keep the native battle surface. Restoring a
    -- field snapshot here also sets worldActive, which makes DYNAMIC UI
    -- inherit the overworld zoom and shrinks the switch-party screen.
    local keepField = not (battle and battle.isActive and battle.isActive())
      and top and top.hideBelow and fieldSnapshot and not self.worldActive
    if not keepField then return originalEndFrame(self, ...) end
    local oldWorld, oldActive = self.worldCanvas, self.worldActive
    self.worldCanvas, self.worldActive = fieldSnapshot, true
    local ok, result = pcall(originalEndFrame, self, ...)
    self.worldCanvas, self.worldActive = oldWorld, oldActive
    if not ok then error(result, 0) end
    return result
  end
  Renderer.blitCanvas = function(self, source, ...)
    if not active() then return originalBlitCanvas(self,source,...) end
    local top = Stack.top()
    if source == self.worldCanvas and not (top and top.hideBelow) then
      cacheField(source)
    end
    -- OPTIONS is replayed into a transparent, screen-space canvas in
    -- Display.present below. The normal UI canvas contains its opaque clear,
    -- so compositing it here would hide the field behind the submenu.
    -- OPTION remains marked open underneath the built-in MODS manager.
    -- Only suppress the UI canvas while OPTION itself is the top layer;
    -- otherwise the manager's entire canvas disappears behind the field.
    if source == self.canvas and top and top.mod == Option and Option.isOpen() then
      return
    end
    -- DexNav closes START before pushing its own Game3 layer. Its full-screen
    -- grid still belongs to the same UI canvas and uses OTHER OPACITY.
    if source == self.canvas and top and top.id ~= 'mod_manager'
        and (FX.active or Stack.has('start') or top.id == 'dexnav' or top.id == 'gen3_dexnav' or top.id == 'codebreaker')
        and top.mod ~= Start and top.mod ~= Option and top.mod ~= Save then
      local alpha = (opacityChoices[setting('otherOpacity')] or 100)/100
      local mode = setting('otherPosition')
      do
        local sx, sy, zones, zoneSx, zoneSy, bx, by, boxX, boxY,
          boxW, boxH, dpiX, dpiY = ...
        local factor=FX.scale('other')
        local winW,winH=love.graphics.getDimensions()
        factor=math.min(factor,winW/(source:getWidth()*sx),winH/(source:getHeight()*sy))
        local oldW,oldH=source:getWidth()*sx,source:getHeight()*sy
        sx,sy=sx*factor,sy*factor
        zoneSx,zoneSy=zoneSx and zoneSx*factor,zoneSy and zoneSy*factor
        bx,by=(bx or 0)+(oldW-oldW*factor)/2,(by or 0)+(oldH-oldH*factor)/2
        if mode ~= 1 then
          local winW, winH = love.graphics.getDimensions()
          local width, height = source:getWidth()*sx, source:getHeight()*sy
          local right = mode == 3 or mode == 5 or mode == 7
          local bottom = mode == 6 or mode == 7 or mode == 10
          local middle = mode == 2 or mode == 3
          local center = mode == 8 or mode == 9 or mode == 10
          local x = center and (winW-width)/2 or (right and winW-width-8 or 8)
          local y = (middle or mode == 8) and (winH-height)/2
            or (bottom and winH-height-8 or 8)
          boxX, boxY = math.max(0, math.floor(x)), math.max(0, math.floor(y))
          boxW, boxH = math.min(width, winW-boxX), math.min(height, winH-boxY)
          bx, by = boxX, boxY
        end
        local ox,oy=FX.offset('other')
        local width,height=source:getWidth()*sx,source:getHeight()*sy
        bx,by=math.max(0,math.min(winW-width,bx+ox)),math.max(0,math.min(winH-height,by+oy))
        FX.record('other',bx,by,width,height)
        local fade,progress;bx,by,fade,progress=FX.motion('other',bx,by,mode);alpha=alpha*fade
        boxX,boxY,boxW,boxH=bx,by,width,height
        love.graphics.push('all')
        love.graphics.setBlendMode('alpha', 'premultiplied')
        love.graphics.setColor(alpha, alpha, alpha, alpha)
        local ok, err = pcall(function()
          return Transitions.scope(setting('menuTransition'),progress or 1,{x=bx,y=by,w=width,h=height},function()
            return originalBlitCanvas(self,source,sx,sy,zones,zoneSx,zoneSy,bx,by,boxX,boxY,boxW,boxH,dpiX,dpiY)
          end)
        end)
        love.graphics.pop()
        if not ok then error(err, 0) end
        return
      end
    end
    local result=originalBlitCanvas(self, source, ...)
    if source==self.worldCanvas then FX.dim() end
    return result
  end

  -- The engine's 240x160 canvas clips anything drawn outside its bounds.
  -- Suppress the canvas menu pass, then render the same menus in screen space.
  local Window = require('src.ui.game3.window')
  local FrlgFont = require('src.ui.game3.frlg_font')
  local Theme=assert(load(assert(mod:read('lib/emerald_theme.lua'))))()(mod,function()return active() and (FX.active or mod.exports.previewScope or mod.exports.battleFontScope or mod.exports.dialogueFontScope) and setting(mod.exports.dialogueFontScope and 'dialogueTheme'or'menuTheme')==2 end)
  Theme.menuOptions=function(opts)if active() and (FX.active or mod.exports.previewScope or mod.exports.dialogueFontScope) and not mod.exports.battleFontScope then return menuPalette.menuOptions(opts)end;return opts end
  Theme.palette=menuPalette
  FrlgFont._menuCustomizerEmerald=Theme
  if not FrlgFont._menuCustomizerEmeraldWrapped then
    local draw,measure,glyph=FrlgFont.draw,FrlgFont.measure,FrlgFont.drawGlyph
    local function nativeFace(opts)return opts and (opts._vanilla or tostring(opts.font):match('^native_'))end
    FrlgFont.draw=function(text,x,y,opts)
      text=LevelText.normalize(text)
      local theme=FrlgFont._menuCustomizerEmerald
      if text=='▶' and mod.exports.arrowSelectors.draw(x,y,16,opts) then return 1,x+8,y end
      if theme.menuOptions then opts=theme.menuOptions(opts)end
      if theme.enabled() and not nativeFace(opts)then local width,endX,endY=theme.draw(text,x,y,opts);if width~=nil then return width,endX or x+width,endY or y end end
      if theme.palette then return theme.palette.nativeText(draw,measure,text,x,y,opts)end
      return draw(text,x,y,opts)
    end
    FrlgFont.measure=function(text,opts)
      text=LevelText.normalize(text)
      local theme=FrlgFont._menuCustomizerEmerald
      if theme.enabled() and not nativeFace(opts)then local result=theme.measure(text,opts);if result~=nil then return result end end
      return measure(text,opts)
    end
    FrlgFont.drawGlyph=function(id,x,y,opts)
      local theme=FrlgFont._menuCustomizerEmerald
      if id==FrlgFont.CHAR_SELECTOR_ARROW and mod.exports.arrowSelectors.draw(x,y,16,opts) then return 8 end
      if theme.menuOptions then opts=theme.menuOptions(opts)end
      if theme.enabled() and not nativeFace(opts)and theme.glyph(id,x,y,opts) then return end
      if theme.palette then return theme.palette.nativeText(glyph,nil,id,x,y,opts)end
      return glyph(id,x,y,opts)
    end
    FrlgFont._menuCustomizerEmeraldWrapped=true
  end
  local originalNativeStartDraw = Start.draw
  local emeraldLayout=require('src.ui.game3.rse.start_menu_data')
  local originalTemplate=Start.contentTemplate
  Start.contentTemplate=function(...)
    if not Theme.enabled() then return originalTemplate(...) end
    local n=math.min(math.max(1,#Start.ENTRIES),(Start._data and Start._data.maxVisible) or Start.MAX_VISIBLE or 8)
    return Window.template(emeraldLayout.window.left,emeraldLayout.window.top,emeraldLayout.window.width,n*2+2)
  end
  local function nativeStartUnscoped(...)
    local previous=Start._data
    if not Theme.enabled() and not (active() and previous and previous.drawCursor) then return originalNativeStartDraw(...) end
    local adapted={}
    for k,v in pairs(previous or {})do adapted[k]=v end
    if Theme.enabled() then
      adapted.window=emeraldLayout.window;adapted.textX=emeraldLayout.textX
      adapted.textY=emeraldLayout.textY;adapted.rowPitch=emeraldLayout.rowPitch
    end
    -- RS otherwise bypasses Window.cursorPx with its native red outline.
    if active() then adapted.drawCursor=nil end
    Start._data=adapted
    local ok,result=pcall(originalNativeStartDraw,...)
    Start._data=previous
    if not ok then error(result,0) end
    return result
  end
  local function nativeStartDraw(...)
    local prior=mod.exports.startSelectorScope
    mod.exports.startSelectorScope=not Start._confirmExit
    local result={pcall(nativeStartUnscoped,...)}
    mod.exports.startSelectorScope=prior
    if not result[1] then error(result[2],0) end
    return unpack(result,2)
  end
  local ballPixels = {'..1111..', '.122221.', '12222221', '11144111',
    '13344331', '13333331', '.133331.', '..1111..'}
  -- RS swaps STDPAL to its indexed primary-colour palette at font sync.
  -- Selector artwork is true colour and must not borrow those mutable slots.
  local ballColors = {[1]={98/255,98/255,98/255,1}, [2]={230/255,8/255,8/255,1},
    [3]={1,1,1,1}, [4]={213/255,213/255,205/255,1}}
  local function drawBallCursor(x, y)
    love.graphics.push('all');love.graphics.setShader()
    local r, g, b, a = love.graphics.getColor()
    for py, pixels in ipairs(ballPixels) do
      for px = 1, #pixels do
        local color = ballColors[tonumber(pixels:sub(px, px))]
        if color then
          love.graphics.setColor(color[1], color[2], color[3], color[4])
          love.graphics.rectangle('fill', x + px - 1, y + py + 2, 1, 1)
        end
      end
    end
    love.graphics.setColor(r, g, b, a)
    love.graphics.pop()
  end
  local function drawStartJustified(...)
    if not active() then return nativeStartDraw(...) end
    local alignment = setting('startJustify')
    local selector = setting('startSelector')
    local tpl
    if Theme.enabled() then
      local n=math.min(#Start.ENTRIES,(Start._data and Start._data.maxVisible) or Start.MAX_VISIBLE or 8)
      tpl=Window.template(emeraldLayout.window.left,emeraldLayout.window.top,emeraldLayout.window.width,n*2+2)
    else tpl=Start.contentTemplate() end
    local cursorX = tpl.left * 8
    local data = Theme.enabled() and emeraldLayout or Start._data
    local textInset=data and data.textX or Window.CURSOR_WIDTH
    local labelX = tpl.left * 8 + textInset
    local labelWidth = tpl.w * 8 - textInset
    local pitch = data and data.rowPitch or Window.optionHeight()
    local scroll = Start._scrollOffset or 0
    local topY = tpl.top * 8 + (data and data.textY or 0)
    local function labelPosition(text)
      local width = FrlgFont.measure(tostring(text or ''))
      local remaining = math.max(0, labelWidth-width)
      if alignment == 2 then
        -- Include the cursor column in the visual centre of the window.
        return labelX + math.floor(remaining/2) - Window.CURSOR_WIDTH/2, width
      elseif alignment == 3 then
        return labelX + remaining, width
      end
      return labelX, width
    end
    local originalPrint = Window.printPx
    local originalCursor = Window.cursorPx
    Window.cursorPx = function(x, y, opts)
      local selectedY = topY + (Start.cursor - scroll - 1) * pitch
      if selector ~= 3 and not Start._confirmExit and x == cursorX and y == selectedY then
        if selector == 1 then
          local entry = Start.ENTRIES[Start.cursor]
          if entry then
            local textX = labelPosition(entry.label)
            drawBallCursor(textX - #ballPixels[1] - 1, y)
          end
        end
        return
      end
      local dy=Start._confirmExit and love.system and love.system.getOS and love.system.getOS()=='iOS' and 2 or 0
      if selector==3 and not Start._confirmExit then
        local copy={};for k,v in pairs(opts or {})do copy[k]=v end;copy._startArrow=true
        return FrlgFont.drawGlyph(FrlgFont.CHAR_SELECTOR_ARROW,x,y+dy,copy)
      end
      return originalCursor(x, y+dy, opts)
    end
    Window.printPx = function(text, x, y, opts)
      local row = (y-topY)/pitch + 1 + scroll
      local index = math.floor(row)
      local entry = Start.ENTRIES[index]
      if x == labelX and row == index and entry and text == entry.label then
        local width
        x, width = labelPosition(text)
        local selected = not Start._confirmExit and index == Start.cursor
        if selected and selector==13 then
          love.graphics.push('all');love.graphics.setShader();love.graphics.setColor(.25,.65,1,setting('selectionHighlight')/100)
          love.graphics.rectangle('fill',tpl.left*8,y,tpl.w*8,pitch);love.graphics.pop()
        end
        local result = originalPrint(text, x, y, opts)
        if selected and selector>=5 and selector<=12 then
          Selectors.draw(selector,x-10,y+3)
        end
        if selected and (selector == 2 or selector == 4) then
          local color = menuPalette.effects.resolve(menuPalette.color('text',setting('selectorColor')),'menu')
          local r, g, b, a = love.graphics.getColor()
          love.graphics.setColor(color[1], color[2], color[3], color[4] or 1)
          if selector == 2 then
            love.graphics.rectangle('fill', x, y + 13, width, 1)
          else
            love.graphics.rectangle('fill', x - 4, y + 7, 2, 2)
            love.graphics.rectangle('fill', x + width + 2, y + 7, 2, 2)
          end
          love.graphics.setColor(r, g, b, a)
        end
        return result
      end
      return originalPrint(text, x, y, opts)
    end
    local ok, result = pcall(nativeStartDraw, ...)
    Window.printPx = originalPrint
    Window.cursorPx = originalCursor
    if not ok then error(result, 0) end
    return result
  end
  local originalStart, originalOption, originalSave, originalPresent =
    drawStartJustified, Option.draw, Save.draw, Display.present
  local presenting = false
  Start.draw = function(...)
    if presenting then return end
    return originalStart(...)
  end
  local Selection=assert(load(assert(mod:read('lib/option_selection.lua'))))()(mod,FrlgFont,setting,active,gameVersion)
  originalOption=Selection.wrap(Option,originalOption)
  local DialogueText=assert(load(assert(mod:read('lib/dialogue_text.lua'))))()(mod,Message,FrlgFont,active)
  local nativeOptions={[Option]=originalOption}
  local function installOption(menu)
    if not nativeOptions[menu] then nativeOptions[menu]=Selection.wrap(menu,menu.draw) end
    local native=nativeOptions[menu]
    if not menu._menuCustomizerDrawWrapped then
      menu.draw=function(...) if presenting then return end;return native(...) end
      menu._menuCustomizerDrawWrapped=true
    end
  end
  installOption(Option)
  Save.draw = function(...)
    if presenting then return end
    return originalSave(...)
  end
  -- The active START template owns its frame bounds in both games.
  local function startBounds(sx, sy)
    local tpl = Start.contentTemplate()
    local left, top = (tpl.left-1)*8*sx, (tpl.top-1)*8*sy
    local width, height = (tpl.w+2)*8*sx, (tpl.h+2)*8*sy
    return left, top, width, height
  end
  local canvas
  local textCanvas
  local MenuText=assert(load(assert(mod:read('lib/menu_text_surface.lua'))))()(mod,FrlgFont or require('src.ui.game3.frlg_font'))
  local function drawAt(menu, draw, mode, opacity, winW, winH, previewOnly, previewGroup)
    if not previewOnly and not menu.isOpen() then return end
    local sx, defaultX, defaultY, _, _, sy = Display.fit(winW, winH)
    local group=previewGroup or (menu==Start and 'start' or menu==Save and 'save' or menu==Option and 'option' or 'other')
    local baseSx,baseSy=sx,sy
    local factor=FX.scale(group)
    if menu~=Start or Start._confirmExit then factor=math.min(factor,(winW-16)/(240*sx),(winH-16)/(160*sy))
    else
      local _,_,bw,bh=startBounds(sx,sy)
      factor=math.min(factor,(winW-16)/bw,(winH-16)/bh)
    end
    sx,sy=sx*factor,sy*factor
    defaultX,defaultY=defaultX+(240*baseSx-240*sx)/2,defaultY+(160*baseSy-160*sy)/2
    local slim = group == 'option' and 0.94 or 1
    local pxScale = sx*slim
    local width, height = 240*pxScale, 160*sy
    local padX, padY = 8, 8
    local right = mode == 3 or mode == 5 or mode == 7
    local bottom = mode == 6 or mode == 7 or mode == 10
    local middle = mode == 2 or mode == 3
    local center = mode == 8 or mode == 9 or mode == 10
    local x = mode == 1 and defaultX + (240*sx-width)/2
      or (center and (winW-width)/2 or (right and (winW-width-padX) or padX))
    local y = mode == 1 and defaultY
      or ((middle or mode == 8) and (winH-height)/2
        or (bottom and winH-height-padY or padY))
    -- START itself occupies tiles 21..29; its confirmation dialog fills 0..29.
    -- Shift the small menu to the true edge while leaving its popups onscreen.
    if menu == Start and mode ~= 1 and not Start._confirmExit then
      local menuLeft, menuTop, menuWidth, menuHeight = startBounds(sx, sy)
      local menuRight = menuLeft + menuWidth
      if center then
        x = (winW-menuWidth)/2-menuLeft
        y = mode == 8 and (winH-menuHeight)/2-menuTop
          or (bottom and winH-menuHeight-padY-menuTop or padY-menuTop)
      else
        x = right and (winW-menuRight-padX) or (padX-menuLeft)
      end
    end
    local left,upper,bw,bh=0,0,width,height
    if menu==Start and not Start._confirmExit then left,upper,bw,bh=startBounds(sx,sy) end
    local ox,oy=FX.offset(group)
    x=math.max(-left,math.min(winW-bw-left,x+ox))
    y=math.max(-upper,math.min(winH-bh-upper,y+oy))
    FX.record(group,x+left,y+upper,bw,bh)
    if previewOnly then return end
    local transitionAlpha,progress;x,y,transitionAlpha,progress=FX.motion(group,x,y,mode)
    if not canvas then
      canvas = love.graphics.newCanvas(240, 160, {dpiscale=1})
      canvas:setFilter('nearest', 'nearest')
    end
    love.graphics.push('all')
    love.graphics.setCanvas(canvas)
    love.graphics.origin()
    love.graphics.setShader()
    love.graphics.clear(0, 0, 0, 0)
    -- Keep the input legend, omitting its blue background and the full-screen
    -- black backdrop. Both are solid fills; the glyphs draw afterward.
    local rectangle, clear = love.graphics.rectangle, love.graphics.clear
    if menu == Option then
      -- Emerald clears its OPTION background directly; FR/LG uses solid
      -- rectangles. Replay both onto transparent pixels before compositing.
      love.graphics.clear = function() return clear(0, 0, 0, 0) end
      love.graphics.rectangle = function(kind, rx, ry, rw, rh, ...)
        if kind == 'fill' and rx == 0 and ry == 0 and rw == 240
          and (rh == 160 or (rh == 16 and ry == 0)) then return end
        return rectangle(kind, rx, ry, rw, rh, ...)
      end
    end
    local priorPaper=mod.exports.menuPaperScope;mod.exports.menuPaperScope=group
    local priorAspect=mod.exports.fontAspect;mod.exports.fontAspect={pxScale,sy}
    local ok, queue = pcall(MenuText.capture,function()
      return (menuPalette and menuPalette.menuScope or function(f)return f()end)(draw)
    end)
    mod.exports.menuPaperScope=priorPaper;mod.exports.fontAspect=priorAspect
    love.graphics.rectangle, love.graphics.clear = rectangle, clear
    love.graphics.setCanvas()
    love.graphics.pop()
    if not ok then error(queue, 0) end
    -- Composite native-resolution frames/backgrounds first. Deferred fonts
    -- then land on square integer physical pixels without shrinking the atlas.
    local target=love.graphics.getCanvas()
    local dpi=target and target:getDPIScale() or love.graphics.getDPIScale()
    if not textCanvas or textCanvas:getWidth()~=winW or textCanvas:getHeight()~=winH or textCanvas:getDPIScale()~=dpi then
      if textCanvas then textCanvas:release()end
      textCanvas=love.graphics.newCanvas(winW,winH,{dpiscale=dpi})
      textCanvas:setFilter('nearest','nearest')
    end
    love.graphics.push('all');love.graphics.setCanvas(textCanvas);love.graphics.origin()
    love.graphics.setShader();love.graphics.setScissor();love.graphics.clear(0,0,0,0)
    love.graphics.setBlendMode('alpha','premultiplied');love.graphics.setColor(1,1,1,1)
    love.graphics.draw(canvas,x,y,0,pxScale,sy)
    love.graphics.setBlendMode('alpha','alphamultiply')
    local rendered,err=pcall(MenuText.draw,queue,x,y,pxScale,sy,dpi)
    love.graphics.pop()
    if not rendered then error(err,0)end
    love.graphics.push('all')
    love.graphics.origin()
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.setShader()
    -- Premultiplied canvas RGB must fall with alpha. Lowering only alpha
    -- leaves full-strength pale menu pixels that wash out the field below.
    local alpha = (opacityChoices[setting(opacity)] or 100)/100*transitionAlpha
    love.graphics.setColor(alpha, alpha, alpha, alpha)
    if Transitions then
      Transitions.scope(setting('menuTransition'),progress or 1,{x=x+left,y=y+upper,w=bw,h=bh},function()love.graphics.draw(textCanvas,0,0)end,{(x+left)/winW,(y+upper)/winH,bw/winW,bh/winH})
    else love.graphics.draw(textCanvas,0,0)end
    love.graphics.pop()
  end
  Display.present = function(game, w, h)
    if not active() then return originalPresent(game,w,h) end
    DialogueText.beginFrame()
    FX.beginFrame(Stack.top())
    presenting = true
    local ok, result = pcall(originalPresent, game, w, h)
    presenting = false
    if not ok then error(result, 0) end
    if result then
      w, h = w or love.graphics.getWidth(), h or love.graphics.getHeight()
      local top = Stack.top()
      -- A custom menu (such as CodeBreaker) hides START in the engine's UI
      -- stack. Our screen-space pass must honor that same top layer.
      if top and top.mod == Option and Option.isOpen() then
        drawAt(Option, originalOption, setting('optionPosition'), 'optionOpacity', w, h)
      elseif top and top.mod == Save and Save.isOpen() then
        -- Keep START open underneath so backing out of SAVE returns to it.
        drawAt(Save, originalSave, setting('savePosition'), 'otherOpacity', w, h)
      elseif top and top.mod == Start and Start.isOpen() then
        drawAt(Start, originalStart, setting('startPosition'), 'startOpacity', w, h)
      end
    end
    local previews={start=Start,option=Option,save=Save,other=Option}
    local preview=FX.previewGroup
    if preview and love.timer.getTime()<=FX.previewUntil then
      drawAt(previews[preview],nil,setting(preview..'Position'),preview..'Opacity',w or love.graphics.getWidth(),h or love.graphics.getHeight(),true,preview)
    end
    FX.overlay()
    return result
  end
  Renderer._menuCustomizerGen3=function(newMod,newVersion,newCatalog)
    mod,gameVersion,catalog=newMod,newVersion,newCatalog
    values=nil;lastStartRows=nil;lastAmbientTick=nil
    mod.exports.resetMenuSettings=function()values=nil;if FX then FX.touch('settingsScope')end end
    installArrows()
    assert(load(assert(mod:read('lib/scene_transitions.lua'))))()(mod,active)
    if fieldSnapshot and fieldSnapshot.release then fieldSnapshot:release() end
    fieldSnapshot=nil
    Selection.setMod(mod,gameVersion);DialogueText.setMod(mod)
    Option=optionForVersion(gameVersion)
    installOption(Option);originalOption=nativeOptions[Option]
    FX.setMod(mod)
    menuPalette=assert(load(assert(mod:read('lib/battle_text_palette.lua'))))()(mod)
    mod.exports.selectorPalette=menuPalette
    Theme.palette=menuPalette
    Theme=assert(load(assert(mod:read('lib/emerald_theme.lua'))))()(mod,function()return active() and (FX.active or mod.exports.previewScope or mod.exports.battleFontScope or mod.exports.dialogueFontScope) and setting(mod.exports.dialogueFontScope and 'dialogueTheme'or'menuTheme')==2 end)
    Theme.menuOptions=function(opts)if active() and (FX.active or mod.exports.previewScope or mod.exports.dialogueFontScope) and not mod.exports.battleFontScope then return menuPalette.menuOptions(opts)end;return opts end
    Theme.palette=menuPalette
  FrlgFont._menuCustomizerEmerald=Theme
    mod.hooks:wrap('ui.start_menu.items',startItemsHook)
    Borders=assert(load(assert(mod:read('lib/menu_borders.lua')), '@'..mod.path..'/lib/menu_borders.lua'))()(mod,setting,catalog,active)
    mod.exports.borders=Borders;mod.exports.borderCatalog=catalog
    assert(load(assert(mod:read('lib/preview_windows.lua'))))()(mod,menuPalette,active)
    mod.exports.effects=FX;mod.exports.version='3.2.65'
  end
  mod.exports.effects=FX
  assert(load(assert(mod:read('lib/preview_windows.lua'))))()(mod,menuPalette,active)
  mod.exports.version = '3.2.65'
  assert(load(assert(mod:read('lib/scene_transitions.lua'))))()(mod,active)
  mod.log:info('Menu Customizer: '..gameVersion..' START, OPTION and SAVE placement installed')
end
