-- Native GB/GBC state menus stay on their input stack. Mirror their drawing
-- over the live map through the shared HUD seam; never tick field scripts.
return function(mod,catalog)
 local Runtime=require('src.mods.Runtime')
 local Font=require('src.render.Font')
 local Viewport=require('src.render.GameViewport')
 local G=love.graphics
 local C={mod=mod,catalog=catalog,drawScope=false,layouts={},frame=0}
 local MOD_ID='gen3transparency'
 local positions={'DEFAULT','LEFT','RIGHT','TOP LEFT','TOP RIGHT','BOTTOM LEFT','BOTTOM RIGHT','CENTER','TOP CENTER','BOTTOM CENTER'}
 local specs={dialogueBorder={0,0,1,1},menuTheme={2,1,2,1},menuBorder={1,1,#catalog.choices,1},startJustify={1,1,3,1},startSelector={3,1,4,1},hideStartMods={0,0,1,1},
  backgroundDim={0,0,70,10},controlsLegend={2,1,3,1},menuTransition={3,1,3,1},positionPreview={1,0,1,1}}
 for _,group in ipairs({'start','option','save','other'}) do
  specs[group..'Position']={1,1,10,1}
  specs[group..'Scale']={100,50,150,10}
  specs[group..'Width']={100,70,130,5};specs[group..'Height']={100,80,130,5}
  specs[group..'OffsetX']={0,-128,128,1};specs[group..'OffsetY']={0,-128,128,1}
 end
 for _,group in ipairs({'start','option','other'}) do specs[group..'Opacity']={100,65,100,5} end
 local marker
 function C.live()
  local chain=Runtime.hooks and Runtime.hooks.chains and Runtime.hooks.chains['ui.start_menu.items']
  for _,entry in ipairs(chain or {}) do if entry.owner==mod.id and entry.callback==marker then return true end end
  return false
 end
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
  local options=game.options or (game.save and game.save.options)
  assert(options,'Menu Customizer: no option storage')
  options.modOptions=options.modOptions or {}
  local bucket=options.modOptions[MOD_ID] or {}
  options.modOptions[MOD_ID]=bucket
  -- Normalize all legacy opacity values together before changing the format.
  for k in pairs(specs) do bucket[k]=C.setting(k) end
  bucket[key]=value;bucket.opacityFormat=2;bucket.borderCatalogFormat=2
  if game.mods then game.mods.modOptions[MOD_ID]=bucket end
  if game.save and game.save.options and game.save.options~=options then
   game.save.options.modOptions=options.modOptions
  end
  if game.writeOptions then game:writeOptions() end
  C.previewGroup=key:match('^(start)') or key:match('^(option)') or key:match('^(save)') or key:match('^(other)')
  C.previewUntil=love.timer.getTime()+3
 end

 local function isStart(s) return s and (s.screenId=='StartMenu' or s.screenId=='Gen2StartMenu') end
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
  BagMenu=true,Gen2PackMenu=true,PartyMenu=true,Gen2PartyMenu=true,PokedexMenu=true,Gen2PokedexMenu=true,
  TrainerCard=true,Gen2TrainerCard=true,Gen2Pokegear=true,Gen2SaveMenu=true,MenuCustomizerOptions=true}
 function C.context(game)
  if not C.live() or not game or not game.stack then return nil end
  local world=game.world or game.overworld
  if not world or not world.map then return nil end
  local states=game.stack.states or {}
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
 C.theme=assert(load(assert(mod:read('lib/emerald_theme.lua'))))()(mod,function()return C.drawScope and C.setting('menuTheme')==2 end)
 -- START rows are sixteen pixels apart, just like Emerald's native menu.
 -- Use the original glyph size there instead of the dense GB screen size.
 C.theme.gbScale=function()return not C.compactText and (C.drawingStart or C.drawingCheats or C.drawingOptions and C.drawingOptions.fullFont) and 1 or .5 end
 Font._menuCustomizerGB=C
 if not Font._menuCustomizerGBWrapped then
  local box,draw,code,advance=Font.drawBox,Font.draw,Font.drawCode,Font.advanceOf
  Font.advanceOf=function(glyph)
   local current=Font._menuCustomizerGB
   if current and current.theme.enabled() then
    local width=current.theme.gbAdvance(glyph);if width then return width/(current.resizeX or 1) end
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
    current.inBox=true
    local args={n=select('#',...),...}
    local ok,result=pcall(function()
     if current.borders.draw(tx,ty,tw,th) then
      if current.dialogueScope and current.mod.generation==1 then
       current.dialogueRects=current.dialogueRects or {}
       local function mark(x,y,w,h)current.dialogueRects[#current.dialogueRects+1]={colors=false,x=x,y=y,w=w,h=h}end
       mark(tx*8,ty*8,tw*8,8);mark(tx*8,(ty+th-1)*8,tw*8,8)
       mark(tx*8,(ty+1)*8,8,(th-2)*8);mark((tx+tw-1)*8,(ty+1)*8,8,(th-2)*8)
      end
      return
     end
     return box(tx,ty,tw,th,unpack(args,1,args.n))
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
   if current and current.drawingParty and text=='' and x==24 and y%16==0 then
    -- Transferred mons can carry an empty nickname. Resolve the displayed
    -- row name without editing the party record or its persisted nickname.
    local game=current.drawingParty
    local mon=game.save and game.save.party and game.save.party[y/16+1]
    local def=mon and game.data and game.data.pokemon and game.data.pokemon[mon.species]
    if mon then text=(def and def.name) or mon.name or mon.species or text end
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
   if not start or x~=start.labelX then return render(text,x,y,...) end
   local n=(y-start.rowY)/start.pitch+1+start.scroll
   local entry=start.items[n]
   if n~=math.floor(n) or not entry or (not start.options and text~=entry.label) then return render(text,x,y,...) end
   local selector=start.options and 3 or current.setting('startSelector')
   local left=start.left+8
   local right=start.left+start.width-8
   local reserve=selector==1 or selector==3
   local minimum=math.max(start.labelX,left+(reserve and 10 or selector==4 and 4 or 0))
   local maximum=right-(selector==4 and 4 or 0)
   if not start.inlineValues then text=windowText(text,math.max(1,maximum-minimum),n==start.index) end
   local shown=Font.width(text)
   local align=start.inlineValues and 1 or current.setting('startJustify')
   local textX=align==2 and minimum+(maximum-minimum-shown)/2 or align==3 and maximum-shown or minimum
   G.push('all');G.translate(textX,y)
   local result=render(text,0,0,...)
   G.pop()
   if n==start.index then start.selection={x=textX,y=y,width=shown,selector=selector} end
   return result
  end
  Font.draw=function(text,x,y,...)return label(text,x,y,draw,...)end
  -- GBC palette printing paints paper and individual glyphs directly, bypassing
  -- Font.draw. Move the whole print operation, including its background.
  Font._menuCustomizerLabel=label
  Font.drawCode=function(glyph,x,y,...)
   local current=Font._menuCustomizerGB
   local start=current and (current.drawingStart or current.drawingOptions)
   if start and glyph==0xED and x==start.labelX-8
       and y==start.rowY+(start.index-start.scroll-1)*start.pitch then return end
   local rx,ry=current and current.drawScope and not current.inBox and current.resizeX or 1,current and current.drawScope and not current.inBox and current.resizeY or 1
   G.push('all');G.translate(x,y);G.scale(1/rx,1/ry)
   local result
   if not (current and current.theme and current.theme.enabled() and current.theme.gbGlyph(glyph,0,0)) then result=code(glyph,0,0,...) end
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
   if sel.selector==3 then code(0xED,x-10,y)
   elseif sel.selector==2 then G.rectangle('fill',x,y+8,width,1)
   elseif sel.selector==4 then
    G.rectangle('fill',x-4,y+3,2,2);G.rectangle('fill',x+width+2,y+3,2,2)
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
   local current=Font._menuCustomizerGB;if current then current.dialogueRects={} end
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
 local TextBox=require('src.render.TextBox')
 if not TextBox._menuCustomizerDialogueDraw then
  TextBox._menuCustomizerDialogueDraw=TextBox.draw
  TextBox.draw=function(self,...)
   local current=Font._menuCustomizerGB
   local enabled=current and current.live() and current.setting('dialogueBorder')==1
   if enabled then current.dialogueScope=true end
   local args={n=select('#',...),...}
   local ok,result=pcall(function()return TextBox._menuCustomizerDialogueDraw(self,unpack(args,1,args.n))end)
   if enabled then current.dialogueScope=nil end
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
      local name=tostring(text):match('^PLAYER%s+(.+)$')
      if name then
       Chrome._menuCustomizerSavePrint('PLAYER',tx,ty,...)
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
     entries[#entries+1]={label=original.label,activate=function(g)pushPage(g,original.label,{original},true)end}
    else entries[#entries+1]=original end
   end
  end
  local page=setmetatable({game=game,title=title,rows=entries,detail=detail,index=1,scroll=0,screenId='MenuCustomizerOptions'},Page)
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
  if self.index>self.scroll+(self.detail and 4 or 6) then self.scroll=self.index-(self.detail and 4 or 6) end
 end
 function Page:draw()
  Font.drawBox(0,0,20,18)
  G.setColor(0,0,0,1);C.compactText=true;Font.draw(self.title,8,10);C.compactText=nil
  for slot=1,(self.detail and 4 or 6) do
   local i=self.scroll+slot;local row=self.rows[i]
   if i<=#self.rows+1 then
    local y=24+(slot-1)*(self.detail and 32 or 16)
    Font.draw(row and row.label or 'BACK',24,y)
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
  C.compactText=true
  Font.draw(self.detail and 'A:CHANGE B:BACK' or 'A:OPEN B:BACK',8,128)
  C.compactText=nil
 end
 local function row(key,label,choices)
  local spec=specs[key]
  return {id='wide_'..key,label=label,value=function()
   local n=C.setting(key)
   return choices and choices[n] or tostring(n)..((key:find('Opacity') or key:find('Scale') or key:find('Width') or key:find('Height') or key=='backgroundDim') and '%' or '')
  end,step=function(game,dir)
   local n=C.setting(key)+dir*spec[4]
   if choices then n=(n-spec[2])%(spec[3]-spec[2]+1)+spec[2] else n=math.max(spec[2],math.min(spec[3],n)) end
   C.persist(game,key,n)
  end}
 end
 local function toggle(key,label)
  local r=row(key,label);r.value=function()return C.setting(key)==1 and 'ON' or 'OFF' end
  r.step=function(game)C.persist(game,key,1-C.setting(key))end;return r
 end
 local parent={}
 for _,group in ipairs({'start','option','save','other'}) do
  local children={row(group..'Position','POSITION',positions),row(group..'Scale','SCALE'),row(group..'Width','WIDTH'),row(group..'Height','HEIGHT'),row(group..'OffsetX','X OFFSET'),row(group..'OffsetY','Y OFFSET')}
  if group~='save' then children[#children+1]=row(group..'Opacity','OPACITY') end
  if group=='start' then
   children[#children+1]=row('startJustify','TEXT',{'LEFT','CENTER','RIGHT'})
   children[#children+1]=row('startSelector','SELECTOR',{'POKEBALL','UNDERLINE','ARROW','DOTS'})
   children[#children+1]=toggle('hideStartMods','HIDE START MODS')
  end
  parent[#parent+1]={label=group:upper(),activate=function(game)pushPage(game,group:upper()..' MENU',children)end}
 end
 parent[#parent+1]=row('menuTheme','MENU FONT',{'NATIVE','EMERALD'})
 parent[#parent+1]=row('menuBorder','MENU BORDER',catalog.choices)
 parent[#parent+1]=row('dialogueBorder','DIALOGUE BORDER',{[0]='OFF',[1]='ON'})
 parent[#parent+1]=row('backgroundDim','BACKGROUND DIM')
 parent[#parent+1]=row('controlsLegend','CONTROL HINTS',{'ALWAYS','AUTO','HIDDEN'})
 parent[#parent+1]=row('menuTransition','TRANSITIONS',{'INSTANT','FADE','SLIDE/FADE'})
 parent[#parent+1]=toggle('positionPreview','POSITION PREVIEW')
 parent[#parent+1]={label='BATTLE UI',activate=function(game)
  local ui=mod.exports.battleUi;if ui then pushPage(game,'BATTLE UI',ui.rows({}))end
 end}
 C.rows=parent
 mod.hooks:wrap('ui.options.rows',function(next,game,rows)
  local entries=next(game,rows)
  entries[#entries+1]={id='wide_menus',label='MENUS',group=true,value=function()return 'OPEN' end,
   activate=function(g)pushPage(g,'MENUS',parent)end}
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
  local ctx=C.context(C.game)
  if ctx then for i=ctx.first,#ctx.states do if ctx.states[i]==state then return false end end end
  return next(state)
 end)
 local canvas
 local motion={}
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
  if list then return {items=s.items,index=list.index,scroll=list.scroll or 0,rowY=list.y*8,pitch=list.spacing*8,labelX=list.x*8,left=80,width=80} end
  local count=math.min(s.maxVisible or #s.items,#s.items)
  return {items=s.items,index=s.index,scroll=s.scroll or 0,rowY=(s.ty+s.th-2-(count-1)*(s.rowStep or 1))*8,
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
   return rect(kind,x,y,w,h,...)
  end
  C.drawScope=true;C.bounds=nil
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
    if isGen2Options(s) and type(s.visible)=='function' then
     C.prepareOptions(s)
     local rows=s:visible()
     C.drawingOptions={options=true,fullFont=true,inlineValues=s.sub,nativeValues=false,items=rows,index=s.index,scroll=s.scroll or 0,rowY=16,pitch=s.sub and 32 or 16,labelX=16,left=0,width=160}
    elseif s.screenId=='MenuCustomizerOptions' then
     local rows={};for _,row in ipairs(s.rows)do rows[#rows+1]=row end;rows[#rows+1]={label='BACK'}
     C.drawingOptions={options=true,fullFont=true,inlineValues=s.detail,items=rows,index=s.index,scroll=s.scroll or 0,rowY=24,pitch=s.detail and 32 or 16,labelX=24,left=0,width=160}
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
    if drawn and C.drawSelector then C.drawSelector(C.drawingStart or C.drawingOptions) end
    if not drawn then error(e,0) end
   end
  end)
  C.resizeX=nil;C.resizeY=nil;C.drawingTrainerCard=nil;C.cardHours=nil;C.drawingList=nil;C.drawingSave=nil;C.saveHours=nil;C.drawScope=false;C.drawingStart=nil;C.drawingOptions=nil;C.drawingOpaque=nil;G.rectangle,G.clear=rect,clear
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
  G.draw(canvas,x-b.x*scale,y-b.y*scale,0,scale/2,scale/2)
  -- Preview the actual visible menu bounds without moving any input state.
  if C.setting('positionPreview')==1 and C.previewGroup and now<=(C.previewUntil or 0) then
   local preview=C.layouts[C.previewGroup]
   if preview then G.setColor(.35,.85,1,.85);G.rectangle('line',preview.x,preview.y,preview.w,preview.h) end
  end
  local hints=C.setting('controlsLegend')
  if hints==1 or hints==2 and now-(C.lastInput or now)<2 then
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
 mod.exports.borders=Borders;mod.exports.borderCatalog=catalog;mod.exports.gbMenus=C;mod.exports.version='3.2.8'
 mod.log:info('Menu Customizer: native Gen '..mod.generation..' menus and all borders installed')
 return C
end
