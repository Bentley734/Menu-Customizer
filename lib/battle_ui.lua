-- Presentation only: customize command placement without changing battle input.
return function(mod)
  local ID = 'gen3transparency'
  local legacy={}
  local battleKeys={'style','opacity','font_size','menu_stretch','menu_align','text_color','background_color','shadow_color','name_color','name_shadow_color'}
  local textPalette=assert(load(assert(mod:read('lib/battle_text_palette.lua'))))()(mod)
  local G = love.graphics
  local unpack = unpack or table.unpack
  local marker
  local api
  local gbFrame
  local protectRegion
  local battleFont=assert(load(assert(mod:read('lib/battle_font.lua'))))()(mod)
  local nativeEmerald=assert(load(assert(mod:read('lib/emerald_native.lua'))))()(mod)
  local emerald
  local function emeraldArt()
    if emerald ~= nil then return emerald or nil end
    emerald=false
    local CacheFs=require('src.import.CacheFs')
    local root='emerald/data/generated/gba/pokemon/battle/'
    local src=CacheFs.readAt(root..'manifest.lua')
    if type(src)~='string' then return nil end
    local chunk=load(src,'@emerald-battle-manifest','t',{})
    local ok,m=pcall(chunk or function() end)
    if not ok or type(m)~='table' then return nil end
    local function image(file,w,h)
      local rgba=CacheFs.readAt(root..file..'.rgba')
      if type(rgba)~='string' or #rgba~=w*h*4 then return nil end
      local data=love.image.newImageData(w,h,'rgba8',rgba)
      local img=G.newImage(data); img:setFilter('nearest','nearest'); return img
    end
    local w,h=m.textboxW or 256,m.textboxH or 512
    local textbox=image('textbox',w,h)
    if not textbox then return nil end
    emerald={textbox=textbox,quad=G.newQuad(0,112,240,48,w,h),
      player=image('healthbox_player',128,64),enemy=image('healthbox_enemy',128,32)}
    return emerald
  end
  local function setting(key, default)
    local n = tonumber(mod.options:get('battle_'..key))
    if n == nil then n = tonumber(mod.save:get('battle_'..key)) end
    if n == nil then n = tonumber(legacy[key]) end
    if key == 'name_color' then return math.max(0,math.min(#textPalette.names-1,math.floor(n or 0))) end
    if key == 'name_shadow_color' then return math.max(0,math.min(#textPalette.shadowNames-1,math.floor(n or 0))) end
    if key == 'shadow_color' then return math.max(0,math.min(#textPalette.shadowNames-1,math.floor(n or 0))) end
    if key == 'background_color' then return math.max(0,math.min(#textPalette.backgroundNames-1,math.floor(n or 0))) end
    if key == 'text_color' then return math.max(0,math.min(#textPalette.names-1,math.floor(n or 0))) end
    if key == 'style' then return n == 3 and 3 or n == 2 and 2 or 1 end
    if key == 'menu_stretch' then return n == 1 and 1 or 0 end
    if key == 'font_size' then return math.max(0,math.min(2,math.floor(n or 0)))end
    if key == 'menu_align' then return n == 0 and 0 or n == 1 and 1 or 2 end
    return math.max(0, math.min(100, n or default))
  end
  local function enabled()
    local Runtime = require('src.mods.Runtime')
    local chains = Runtime.hooks and Runtime.hooks.chains
    for _, e in ipairs(chains and chains['ui.options.rows'] or {}) do
      if e.owner == mod.id and e.callback == marker then return true end
    end
    return false
  end
  local compose=assert(load(assert(mod:read('lib/battle_compositor.lua')),'@battle-ui/compositor.lua'))()(G,function() return setting('opacity',100) end)
  local function faded(fn,...)
    if mod.exports.healthboxBackground then return fn(...)end
    return compose(fn,512,192,0,0,...)
  end
  local healthboxLayers=assert(load(assert(mod:read('lib/healthbox_layers.lua'))))()(G,mod,function(fn,...)return compose(fn,512,192,0,0,...)end)
  local function placement(x,w,total)
    if setting('menu_stretch',0)==1 then return 0,total/w end
    return (total-w)*setting('menu_align',2)/2,1
  end
  local placementDepth=0
  local function placed(fn,x,w,total,...)
    local dest,scale=placement(x,w,total)
    G.push('all');G.translate(dest-scale*x,0);G.scale(scale,1)
    placementDepth=placementDepth+1
    local result={pcall(fn,...)};placementDepth=placementDepth-1;G.pop()
    if not result[1] then error(result[2],0) end
    return unpack(result,2)
  end
  local function textPlaced(fn,x,w,total,col,columns,...)
    local dest,scale=placement(x,w,total)
    local delta=dest-x+(w*scale-w)*(col+.5)/columns
    G.push('all');G.translate(delta,0);placementDepth=placementDepth+1
    local result={pcall(fn,...)};placementDepth=placementDepth-1;G.pop()
    if not result[1] then error(result[2],0) end
    return unpack(result,2)
  end
  local function fillBackground(x,y,w,h)
    if setting('background_color',0)==0 then return end
    textPalette.paint(textPalette.background(),G.rectangle,'fill',x+8,y+8,w-16,h-16)
  end
  -- Emerald palette and double frame, drawn at each game's native geometry.
  -- Original artwork; no ROM graphics are distributed.
  local function panel(x,y,w,h, dark)
    if setting('style',1)==3 and mod.exports.borders.drawBattlePixels(x,y,w,h) then return end
    local color = {G.getColor()}
    local a = 1
    G.setColor(.20,.29,.28,a); G.rectangle('fill',x,y,w,h)
    G.setColor(.78,.80,.65,a); G.rectangle('fill',x+1,y+1,w-2,h-2)
    G.setColor(.34,.49,.43,a); G.rectangle('fill',x+3,y+3,w-6,h-6)
    if dark then G.setColor(.18,.30,.34,a) else G.setColor(.97,.97,.87,a) end
    G.rectangle('fill',x+5,y+5,w-10,h-10)
    -- Reuse the user's imported Emerald battle frame when available. Keep the
    -- native game's text contrast and geometry inside the original frame.
    local art=emeraldArt()
    if art then
      G.setColor(1,1,1,a)
      G.draw(art.textbox,art.quad,x,y,0,w/240,h/48)
      if dark then G.setColor(.18,.30,.34,a) else G.setColor(.97,.97,.87,a) end
      G.rectangle('fill',x+6,y+6,w-12,h-12)
    end
    fillBackground(x,y,w,h)
    G.setColor(unpack(color))
  end
  -- Keep the 3.2.11 frame bounds independent from the Emerald text canvas.
  -- Command menus own only their original command pane; dialogue owns the
  -- whole bottom rectangle. Text fitting must never alter those bounds.
  local function frameGeometry(mode,rect)
    local nativeW=rect.nativeWidth or (mod.generation==3 and 240 or 160)
    local isWide=rect.wide or nativeW==304
    local nativeH=rect.nativeHeight or (isWide and 40 or 48)
    local x,w=0,nativeW
    if mode=='menu' then
      local commandW=mod.generation==3 and 120 or isWide and 144 or 96
      local commandX=nativeW-commandW
      local dest,scale=placement(commandX,commandW,nativeW)
      x,w=dest,commandW*scale
    end
    return {x=rect.x+x*rect.w/nativeW,y=rect.y,w=w*rect.w/nativeW,h=rect.h,
      nativeWidth=mode=='menu' and (mod.generation==3 and 120 or isWide and 144 or 96) or nativeW,
      nativeHeight=nativeH,wide=isWide}
  end
  local function frames(mode,rect,viewport)
    if mode=='moves' and api and api.moveScreen then return api.moveScreen.frames(rect,viewport) end
    local r=frameGeometry(mode,rect)
    G.push('all')
    local ok,err=pcall(function()
      G.origin();G.setShader();G.setScissor()
      compose(function()
        G.translate(r.x,r.y);G.scale(r.w/r.nativeWidth,r.h/r.nativeHeight)
        if setting('style',1)~=1 then panel(0,0,r.nativeWidth,r.nativeHeight,false)
        elseif gbFrame then gbFrame(0,0,r.nativeWidth/8,r.nativeHeight/8)
        else
          -- This API is used by GB presentation. Retain a safe native frame
          -- if another renderer calls it in a Gen 3 session.
          require('src.render.Font').drawBox(0,0,r.nativeWidth/8,r.nativeHeight/8)
        end
      end,math.ceil(rect.x+rect.w),math.ceil(rect.y+rect.h),0,0)
    end)
    G.pop();if not ok then error(err,0)end
    return r
  end
  local function persist(ctx,key,value)
    local game = ctx.game or ctx
    local options = ctx.options or game.options or (game.save and game.save.options)
    assert(options, 'Battle UI: missing options storage')
    options.modOptions = options.modOptions or {}
    local bucket = options.modOptions[ID] or {}
    options.modOptions[ID] = bucket
    for _,k in ipairs(battleKeys) do bucket['battle_'..k]=setting(k,k=='opacity' and 100 or k=='menu_align' and 2 or k=='style' and 1 or 0) end
    bucket['battle_'..key] = value
    if game.mods then game.mods.modOptions[ID] = bucket end
    if game.save and game.save.options then game.save.options.modOptions = options.modOptions end
    mod.save:set('battle_'..key,value)
    if mod.exports.settingsProfiles then mod.exports.settingsProfiles.commit(ctx or game)end
    if game.writeOptions then game:writeOptions() end
    return false
  end
  local function effectPersist(ctx,key,value)
    local game=ctx.game or ctx;local options=ctx.options or game.options or game.save and game.save.options
    assert(options,'Text effects: missing options storage');options.modOptions=options.modOptions or {}
    local b=options.modOptions[ID] or {};options.modOptions[ID]=b;b[key]=value;mod.save:set(key,value)
    if game.mods then game.mods.modOptions[ID]=b end
    if game.save and game.save.options then game.save.options.modOptions=options.modOptions end
    if mod.exports.settingsProfiles then mod.exports.settingsProfiles.commit(ctx or game)end;if game.writeOptions then game:writeOptions()end;return false
  end
  local function rows(out,openPage)
    for _, r in ipairs(out) do if r.id == ID..':style' then return out end end
    out[#out+1] = {id=ID..':style',label='BATTLE UI',
      value=function() return ({'VANILLA','EMERALD','MENU BORDER'})[setting('style',1)] end,
      step=function(ctx,dir) return persist(ctx,'style',(setting('style',1)-1+(dir and dir<0 and -1 or 1))%3+1) end}
    out[#out+1]={id=ID..':font_size',label='BATTLE FONT SIZE',
      value=function()return ({'NORMAL','LARGE (150%)','EXTRA LARGE (200%)'})[setting('font_size',0)+1]end,
      step=function(ctx,dir)return persist(ctx,'font_size',(setting('font_size',0)+(dir and dir<0 and -1 or 1))%3)end}
    if mod.generation<3 then out[#out+1]={id=ID..':move_layout',label='BATTLE MOVE LAYOUT',
      value=function()return setting('move_layout',0)==1 and'LIST'or'GRID'end,
      step=function(ctx)return persist(ctx,'move_layout',1-setting('move_layout',0))end}end
    out[#out+1] = {id=ID..':opacity',label='BATTLE OPACITY',
      value=function() return tostring(setting('opacity',100))..'%' end,
      step=function(ctx,dir)
        return persist(ctx,'opacity',(setting('opacity',100)+(dir<0 and -10 or 10))%110)
      end}
    out[#out+1] = {id=ID..':menu_stretch',label='BATTLE MENU WIDTH',
      value=function() return setting('menu_stretch',0)==1 and 'FULL WIDTH' or 'NORMAL' end,
      step=function(ctx) return persist(ctx,'menu_stretch',1-setting('menu_stretch',0)) end}
    out[#out+1] = {id=ID..':menu_align',label='BATTLE MENU ALIGN',
      value=function() return ({'LEFT','CENTER','RIGHT'})[setting('menu_align',2)+1] end,
      step=function(ctx,dir) return persist(ctx,'menu_align',(setting('menu_align',2)+(dir<0 and -1 or 1))%3) end}
    out[#out+1]={id=ID..':text_color',label='BATTLE TEXT COLOR',
      value=function()return textPalette.names[setting('text_color',0)+1]end,
      step=function(ctx,dir)return persist(ctx,'text_color',textPalette.step('text',setting('text_color',0),dir))end}
    out[#out+1]={id=ID..':background_color',label='BATTLE MENU BACKGROUND',
      value=function()return textPalette.backgroundNames[setting('background_color',0)+1]end,
      step=function(ctx,dir)return persist(ctx,'background_color',textPalette.step('background',setting('background_color',0),dir))end}
    out[#out+1]={id=ID..':shadow_color',label='BATTLE TEXT SHADOW',
      value=function()return textPalette.shadowNames[setting('shadow_color',0)+1]end,
      step=function(ctx,dir)return persist(ctx,'shadow_color',textPalette.step('shadow',setting('shadow_color',0),dir))end}
    out[#out+1]={id=ID..':name_color',label='POKEMON NAME COLOR',
      value=function()return textPalette.names[setting('name_color',0)+1]end,
      step=function(ctx,dir)return persist(ctx,'name_color',textPalette.step('text',setting('name_color',0),dir))end}
    out[#out+1]={id=ID..':name_shadow_color',label='POKEMON NAME SHADOW',
      value=function()return textPalette.shadowNames[setting('name_shadow_color',0)+1]end,
      step=function(ctx,dir)return persist(ctx,'name_shadow_color',textPalette.step('shadow',setting('name_shadow_color',0),dir))end}
    if openPage then
      for _,entry in ipairs(out)do
        local key=entry.id and entry.id:match('^'..ID..':(.*)')
        if key then entry.preview=function()return mod.exports.customization.values('battle_'..key,setting(key,0))end end
        local kind=(key=='text_color' or key=='name_color') and 'text' or (key=='shadow_color' or key=='name_shadow_color') and 'shadow' or key=='background_color' and 'background'
        if kind then textPalette.picker(entry,kind,function()return setting(key,0)end,function(ctx,n)return persist(ctx,key,n)end,openPage)end
      end
      for _,kind in ipairs({'battle','name'})do
      local k=kind;out[#out+1]={id=ID..':fx_'..k,label=k=='name' and 'NAME TEXT EFFECTS' or 'BATTLE TEXT EFFECTS',children=textPalette.effects.rows(k,effectPersist,openPage),value=function()return 'OPEN'end,activate=function()openPage(k=='name' and 'NAME TEXT EFFECTS' or 'BATTLE TEXT EFFECTS',textPalette.effects.rows(k,effectPersist,openPage))end}
    end end
    if mod.exports.moveSelectProfile then for _,row in ipairs(mod.exports.moveSelectProfile.rows(openPage))do out[#out+1]=row end end
    return out
  end
  marker=function(nextFn,game,out) return nextFn(game,out) end
  mod.hooks:wrap('ui.options.rows',marker,620)
  if mod.generation == 3 then
    local Healthbox=require('src.core.game3.battle.healthbox')
    local originalHealthbox=Healthbox.draw
    Healthbox.draw=function(...)
      if not enabled() then return originalHealthbox(...)end
      local Battle=require('src.core.game3.battle')
      local side=select(1,...)
      if Battle._st and Battle._st.safari and (side=='player' or type(side)=='number' and side%2==0) then return originalHealthbox(...)end
      local font=require('src.ui.game3.frlg_font')
      local chrome=require('src.ui.game3.battle_chrome')
      chrome._menuCustomizerSummary=require('src.ui.game3.summary_chrome')
      return healthboxLayers(font,chrome,function(...)
        return textPalette.nameScope(font,originalHealthbox,...)
      end,...)
    end
    local Message=require('src.ui.game3.message')
    local originalText=Message.drawText
    Message.drawText=function(...)
      if enabled() and Message._frame=='battle' then
        return battleFont.scope(function(...)return textPalette.scope(originalText,...)end,...)
      elseif enabled() then return battleFont.scope(function(...)return textPalette.menuScope(originalText,...)end,...)end
      return originalText(...)
    end
    local C = require('src.ui.game3.battle_chrome')
    local nativeFrames=C.drawMenuFrames
    local nativePanel=C.drawPanel
    local function drawGen3Panels(mode)
      local function pane(x,w)
        if setting('style',1)==1 then
          G.push('all');G.setScissor(x,112,w,48)
          nativePanel(mode);nativeFrames(mode);G.pop();fillBackground(x,112,w,48)
        else
          local borders=mod.exports.borders
          if not (borders and borders.drawBattlePixels(x,112,w,48))then panel(x,112,w,48,false)end
        end
      end
      return faded(function()
        if mode=='moves' then pane(0,160);pane(160,80)
        elseif mode=='menu' then
          if setting('menu_stretch',0)==0 and setting('menu_align',2)==2 then pane(0,120)end
          return placed(function()pane(120,120)end,120,120,240)
        else pane(0,240)end
      end)
    end
    mod.exports.drawGen3Panels=drawGen3Panels
    local Ui=require('src.core.game3.battle.ui')
    local drawing,command=nil,nil
    local nativeUi=Ui.draw
    Ui.draw=function(...)
      local priorDrawing,priorCommand=drawing,command
      drawing,command=true,nil
      local result
      if enabled() and setting('style',1)==2 and nativeEmerald.ready() then
        result={pcall(nativeEmerald.scope,nativeUi,...)}
      elseif enabled() then result={pcall(textPalette.scope,nativeUi,...)}
      else result={pcall(nativeUi,...)} end
      drawing,command=priorDrawing,priorCommand
      if not result[1] then error(result[2],0) end
      return unpack(result,2)
    end
    local F=require('src.ui.game3.frlg_font')
    local fontDraw=F.draw
    F.draw=function(text,x,y,...)
      if not enabled() or not command or y<112 then return fontDraw(text,x,y,...) end
      if x<120 then
        if setting('menu_stretch',0)==0 and setting('menu_align',2)==2 then return fontDraw(text,x,y,...)end
        return
      end
      local result={textPlaced(fontDraw,120,120,240,x>=184 and 1 or 0,2,text,x,y,...)}
      command=command+1;if command>=4 then command=nil end
      return unpack(result)
    end
    for _,spec in ipairs({{'src.ui.game3.window','cursorPx'},{'src.ui.game3.rs.menu_cursor','draw'}}) do
      local target=require(spec[1]);local native=target[spec[2]]
      target[spec[2]]=function(x,y,...)
        if enabled() and command and x>=120 and y>=112 then return textPlaced(native,120,120,240,x>=184 and 1 or 0,2,x-1,y,...) end
        return native(x,y,...)
      end
    end
    for _,name in ipairs({'drawPanel','drawMenuFrames','drawEnemyBox','drawPlayerBox','drawDoublesBox','drawSafariBox'}) do
      local original = C[name]
      if original then C[name] = function(...)
        if not enabled() then return original(...) end
        if setting('style',1)==2 and not nativeEmerald.ready() then return original(...) end
        local args = {...}
        if name=='drawMenuFrames' then return end
        if name=='drawPanel' and args[1]=='menu' then
          if drawing then command=0 end
          return drawGen3Panels('menu')
        end
        if setting('style',1)==1 then
          return faded(function()
            local result=original(unpack(args))
            if name=='drawPanel' then
              nativeFrames(unpack(args))
              if args[1]=='moves' then fillBackground(0,112,160,48);fillBackground(160,112,80,48)
              else fillBackground(0,112,240,48)end
            end
            return result
          end)
        end
        return faded(function()
        if name=='drawPanel' then
          local mode=args[1]
          panel(0,112,mode=='menu' and 120 or mode=='moves' and 160 or 240,48,mode~='moves')
          if mode=='menu' then panel(120,112,120,48,false)
          elseif mode=='moves' then panel(160,112,80,48,false) end
        else
          local x,y=args[1],args[2]
          if name=='drawDoublesBox' then x,y=args[2],args[3] end
          local art=emeraldArt()
          local img=art and (name=='drawEnemyBox' and art.enemy or art.player)
          if img and name~='drawDoublesBox' and name~='drawSafariBox' then
            local color={G.getColor()}
            G.setColor(1,1,1,1); G.draw(img,x,y)
            G.setColor(unpack(color))
          else panel(x,y,128,name=='drawEnemyBox' and 32 or name=='drawDoublesBox' and 32 or 40,false) end
          if name=='drawSafariBox' then return true end
        end
        end)
      end end
    end
  else
    local Font=require('src.render.Font')
    local Renderer=require('src.render.Renderer')
    local protected=setmetatable({}, {__mode='k'})
    local queue
    local begin=Renderer.beginFrame
    Renderer.beginFrame=function(self,...)
      protected=setmetatable({}, {__mode='k'})
      return begin(self,...)
    end
    local blit=Renderer.blitCanvas
    local function outside(z,r)
      local l,t=math.max(z.x,r.x),math.max(z.y,r.y)
      local right,bottom=math.min(z.x+z.w,r.x+r.w),math.min(z.y+z.h,r.y+r.h)
      if right<=l or bottom<=t then return {z} end
      local out={}
      local function add(x,y,w,h)
        if w<=0 or h<=0 then return end
        local copy={};for k,v in pairs(z) do copy[k]=v end
        copy.x,copy.y,copy.w,copy.h=x,y,w,h;out[#out+1]=copy
      end
      add(z.x,z.y,z.w,t-z.y);add(z.x,bottom,z.w,z.y+z.h-bottom)
      add(z.x,t,l-z.x,bottom-t);add(right,t,z.x+z.w-right,bottom-t)
      return out
    end
    Renderer.blitCanvas=function(self,canvas,sx,sy,zones,...)
      local rects=enabled() and protected[canvas]
      if rects and #rects>0 and zones and #zones>0 then
        local merged={}
        for _,z in ipairs(zones) do merged[#merged+1]=z end
        -- Do not paint a tinted copy underneath a translucent true-color
        -- copy. Exclude panels from every native zone before their one blit.
        for _,r in ipairs(rects) do
          local clipped={}
          for _,z in ipairs(merged) do
            for _,piece in ipairs(outside(z,r)) do clipped[#clipped+1]=piece end
          end
          merged=clipped
        end
        for i,r in ipairs(rects) do
          local pieces={r}
          for j=1,i-1 do
            local clipped={}
            for _,z in ipairs(pieces) do
              for _,piece in ipairs(outside(z,rects[j])) do clipped[#clipped+1]=piece end
            end
            pieces=clipped
          end
          for _,piece in ipairs(pieces) do merged[#merged+1]=piece end
        end
        zones=merged
        local opaque=self.uiOpaque;self.uiOpaque=false
        local result={pcall(blit,self,canvas,sx,sy,zones,...)}
        self.uiOpaque=opaque
        if not result[1] then error(result[2],0) end
        return unpack(result,2)
      end
      return blit(self,canvas,sx,sy,zones,...)
    end
    local function protect(x,y,w,h)
      local canvas=G.getCanvas()
      if not canvas then return end
      local x1,y1=G.transformPoint(x,y)
      local x2,y2=G.transformPoint(x+w,y+h)
      local left,top=math.min(x1,x2),math.min(y1,y2)
      local right,bottom=math.max(x1,x2),math.max(y1,y2)
      local cx,cy,cw,ch=G.getScissor()
      if cx then
        left,top=math.max(left,cx),math.max(top,cy)
        right,bottom=math.min(right,cx+cw),math.min(bottom,cy+ch)
      end
      if right<=left or bottom<=top then return end
      protected[canvas]=protected[canvas] or {}
      protected[canvas][#protected[canvas]+1]={colors=false,x=left,y=top,w=right-left,h=bottom-top}
    end
    protectRegion=protect
    local function portedHud(self,generation,side)
      local drawn=nativeEmerald.hud(self,generation,side)
      if drawn then
        if side=='enemy'then protect(0,0,128,32)else protect(32,48,128,40)end
      end
      return drawn
    end
    local B = require(mod.generation==2 and 'src.ui.gen2.BattleState' or 'src.battle.BattleState')
    if mod.generation==1 then
      local nativeHud=B.drawHUDs
      B.drawHUDs=function(self,slide,...)
        if not enabled()or setting('style',1)~=2 or not nativeEmerald.ready()or self.safari or self.demo
          or not self:statusHUDVisible()then return nativeHud(self,slide,...)end
        if self.fieldCleared then return end
        if self.enemy and not self.showEnemyTrainer and not self.enemySendingOut and not self.enemyHudPending
          and not self:growInScale(self.enemy)and (slide or 0)==0 and not self.introBalls and not self.enemy.fainted then
          portedHud(self,1,'enemy')
        end
        if self.player and not self.showPlayerBack and (slide or 0)==0 and not self.player.fainted then
          portedHud(self,1,'player')
        end
      end
    else
      for _,side in ipairs({'enemy','player'})do
        local key=side=='enemy'and 'drawEnemyHud'or 'drawPlayerHud';local original=B[key]
        B[key]=function(self,...)
          if not enabled()or setting('style',1)~=2 or not nativeEmerald.ready()or not self:statusHUDVisible()then return original(self,...)end
          if self[side=='enemy'and 'showEnemyHud'or 'showPlayerHud']then return portedHud(self,2,side)end
          return original(self,...)
        end
      end
    end
    local navigation=B.moveGridNavigation
    if navigation then B.moveGridNavigation=function(self,...)
      if enabled()and(setting('style',1)~=1 or battleFont.isEmerald())then return setting('move_layout',0)~=1 end
      return navigation(self,...)
    end end
    local method = mod.generation==2 and 'drawBottom' or 'drawTextArea'
    local draw = B[method]
    local mode, battle, wide, offset = nil,nil,false,0
    local nativeBox=mod.generation==2 and require('src.ui.gen2.Chrome').box or Font.drawBox
    gbFrame=nativeBox
    local nativeText,nativeCode=Font.draw,Font.drawCode
    local customMoves=false
    -- One composited surface owns the outer frame and inset; their opacity
    -- cannot accumulate. Text is fitted uniformly, never stretched sideways.
    local function drawMoves(self,isWide,ox)
      local data=mod.generation==2 and self.game and self.game.data or self.data
      data=data or {}; local defs=data.moves or {}
      local list=mod.generation==2 and self.playerMoves and self:playerMoves()
        or self.player and self.player.curMoves or {}
      local selected=self.moveIndex or 1
      local total=isWide and 304 or 160+(ox or 0)*8
      local width=isWide and 304 or 128+(ox or 0)*8
      if setting('menu_stretch',0)==1 then width=total end
      local x=(total-width)*setting('menu_align',2)/2
      local y=isWide and 104 or 96
      local height=isWide and 40 or 48
      local details=isWide and 72 or 40
      local dx=x+width-details-8
      local priorMode=mode;mode='box'
      if api and api.moveScreen and G.transformPoint then
        local px,py=G.transformPoint(x,y)
        local ex,ey=G.transformPoint(x+width,y+height)
        local view=self
        if mod.generation==2 then
          local disabled=self.battle and list[selected] and self.battle:moveDisabled(self.player,list[selected].id)
          view={phase='moveSelect',moveIndex=selected,moveSwapIndex=self.moveSwapIndex,data=data,
            player={curMoves=list,disabledSlot=disabled and selected or nil}}
          -- Copy PP values for presentation; never edit battle records.
          local copied={}
          for i,move in ipairs(list)do
            local c={};for k,v in pairs(move)do c[k]=v end
            c.maxPp=c.maxPp or require('src.battle.gen2.Mon').maxPpOf(move,data);copied[i]=c
          end
          view.player.curMoves=copied
        end
        local deferred=mod.exports.battlePanelSurface
        if deferred and deferred.defer(view,{x=px,y=py,w=ex-px,h=ey-py})then mode=priorMode;return end
        local ok,err=pcall(api.moveScreen.draw,view,{x=px,y=py,w=ex-px,h=ey-py},{})
        protect(x,y,width,height);mode=priorMode
        if not ok then error(err,0)end
        return
      end
      G.push('all')
      local ok,err=pcall(function()
        faded(function()
          G.setColor(0,0,0,1)
          if setting('style',1)~=1 then panel(x,y,width,height,false)
          else nativeBox(x/8,y/8,width/8,height/8) end
          -- A thin inset outline leaves space for four readable detail rows.
          G.setColor(.22,.25,.28,1)
          G.rectangle('line',dx+.5,y+7.5,details-1,height-15)
        end)
        protect(x,y,width,height)
        G.setShader();G.setColor(0,0,0,1)
        local function label(text,px,py,available,maxScale)
          text=tostring(text or '')
          local measured=Font.width and Font.width(text) or (Font.encode and #Font.encode(text) or #text)*8
          local s=math.min(maxScale or 1,available/math.max(8,measured))
          G.push();G.translate(px,py);G.scale(s,s)
          nativeText(text,0,0);G.pop()
        end
        local columns=isWide and 2 or 1
        local cell=(dx-x-16)/columns
        local names,longest={},8
        for i=1,4 do
          local move=list[i];local def=move and defs[move.id]
          names[i]=tostring(def and def.name or move and move.id or '-')
          local measured=Font.width and Font.width(names[i]) or #names[i]*8
          longest=math.max(longest,measured)
        end
        local listScale=math.min(1,(cell-4)/longest)
        for i=1,4 do
          local col=isWide and (i-1)%2 or 0
          local row=isWide and math.floor((i-1)/2) or i-1
          local tx=x+16+col*cell
          local ty=y+8+row*(isWide and 16 or 8)
          label(names[i],tx,ty,cell-4,listScale)
          if i==selected then nativeCode(0xED,tx-8,ty) end
          if self.moveSwapIndex==i and i~=selected then nativeCode(0xEC,tx-8,ty) end
        end
        local move=list[selected];local def=move and defs[move.id]
        local typeName='-';local pp='-/-'
        if move then
          if def and def.type then typeName=require('src.battle.TypeChart').displayName(def.type,data) end
          local maximum=move.maxPp
          if not maximum then
            if mod.generation==2 then maximum=require('src.battle.gen2.Mon').maxPpOf(move,data)
            elseif def then maximum=def.pp+(move.ppUps or 0)*math.floor(def.pp/5) end
          end
          pp=tostring(move.pp or 0)..'/'..(maximum and tostring(maximum) or '?')
        end
        local disabled=self.player and self.player.disabledSlot==selected
        if mod.generation==2 and move and self.battle and self.battle.moveDisabled then
          disabled=self.battle:moveDisabled(self.battle.player,move.id)
        end
        local labels={'TYPE',typeName,disabled and 'DISABLED' or 'PP',pp}
        for i,text in ipairs(labels) do label(text,dx+3,y+8+(i-1)*(isWide and 6 or 8),details-6,.75) end
      end)
      G.pop();mode=priorMode
      if not ok then error(err,0) end
    end
    local function commandMenu() return battle and battle.phase=='menu' and not battle.safari and not battle.contest end
    local function moves() return battle and (battle.phase=='moves' or battle.phase=='moveSelect') end
    local function menuGeometry()
      if commandMenu() then
        if wide then return 160,144,304,232,2 end
        return 64+offset*8,96,160+offset*8,120+offset*8,2
      elseif moves() then
        -- Wide/GBA move grids already share the bottom with a useful PP/TYPE panel.
        if wide then return 0,224,224,112,2 end
        return 32,128+offset*8,160+offset*8,nil,1
      end
    end
    local function moveText(fn,x,y,...)
      if customMoves and wide and mode~='box' and y>=104 then return end
      if enabled() and setting('style',1)~=1 and mode=='text' and battle
        and not commandMenu() and not moves() and y>=104 then
        return fn(x+2,y-4,...)
      end
      local lx,lw,total,split,columns=menuGeometry()
      if not enabled() or not lx or mode=='box' or mode=='background'
        or placementDepth>0 or y<(wide and 112 or moves() and 104 or 112) then return fn(x,y,...) end
      if wide and commandMenu() and x<160 then return end
      if wide and moves() and x>=224 then return fn(x,y,...) end
      if x<lx then return fn(x,y,...) end
      local col=split and x>=split and 1 or 0
      if commandMenu() and setting('style',1)~=1 then
        local row=y>=128 and 1 or 0
        local base=wide and (col==0 and 176 or 240) or (col==0 and 80+offset*8 or 128+offset*8)
        local labels={{'FIGHT',nil},{'ITEM','RUN'}}
        local label=labels[row+1][col+1]
        local width=label and (Font.width and Font.width(label) or #label*8) or 16
        local target=lx+(col+.5)*lw/2-width/2
        G.push('all');G.translate(target-base,-4)
        local result={pcall(textPlaced,fn,lx,lw,total,col,columns,x,y,...)}
        G.pop();if not result[1] then error(result[2],0)end
        return unpack(result,2)
      end
      return textPlaced(fn,lx,lw,total,col,columns,x,y,...)
    end
    local function skip(x,y,w,h)
      -- The TYPE/PP box ends one tile into the move list. In docked layouts
      -- its contents are outside the clip, leaving just this orphan border.
      if wide and commandMenu() and x==0 and y==13 and w==20 then return true end
      if moves() and x==0 and y==8 and w==11 and h==5 then return true end
      -- Full-width message paper is unused behind command and move selection.
      return battle and y==12 and x==0 and w>=20 and h==6
        and (battle.phase=='menu' and not battle.safari or moves())
    end
    local function boxWrapper(target,name)
      local original=target[name]
      target[name]=function(x,y,w,h,...)
        if wide and battle and battle.phase=='moveSelect' and y>=13 then
          if not customMoves then customMoves=true;drawMoves(battle,true,0) end
          return
        end
        if not mode or (wide and y<13) then return original(x,y,w,h,...) end
        if skip(x,y,w,h) then G.setColor(0,0,0,1); return end
        if mode=='text' then G.setColor(0,0,0,1); return end
        local args={...}
        local function background()
          if setting('style',1)~=1 then
            local prior=mode; mode='box'
            local ok,err=pcall(panel,x*8,y*8,w*8,h*8,false); mode=prior
            if not ok then error(err,0) end
          else
            local prior=mode; mode='box'
            local result={pcall(original,x,y,w,h,unpack(args))}; mode=prior
            if not result[1] then error(result[2],0) end
          end
        end
        local lx,lw,total=menuGeometry()
        local relocate=lx and x*8==lx and y>=12
        if wide then
          local function render() faded(background);protect(x*8,y*8,w*8,h*8) end
          if relocate then placed(render,lx,lw,total) else render() end
        else
          if relocate then placed(background,lx,lw,total) else background() end
          if queue then
            local dest,scale=x*8,1
            if relocate then dest,scale=placement(lx,lw,total) end
            queue[#queue+1]={dest,y*8,w*8*scale,h*8}
          end
        end
        G.setColor(0,0,0,1)
      end
    end
    if mod.generation==2 then boxWrapper(require('src.ui.gen2.Chrome'),'box')
    else boxWrapper(Font,'drawBox') end
    -- Remove native paper patches and border-repair glyphs on move selection.
    local textDraw=Font.draw
    Font.draw=function(text,x,y,...)
      local args={...}
      return moveText(function(px,py) return textDraw(text,px,py,unpack(args)) end,x,y)
    end
    if mod.generation==2 then
      local Chrome=require('src.ui.gen2.Chrome')
      for _,name in ipairs({'printThrough','cursorThrough'}) do
        local native=Chrome[name]
        if name=='printThrough' then
          Chrome[name]=function(text,x,y,...)
            local args={...}
            return moveText(function(px,py) return native(text,px/8,py/8,unpack(args)) end,x*8,y*8)
          end
        else
          Chrome[name]=function(x,y,...)
            local args={...}
            return moveText(function(px,py) return native(px/8,py/8,unpack(args)) end,x*8,y*8)
          end
        end
      end
    end
    if mod.generation==2 and B.printMessage then
      local message=B.printMessage
      B.printMessage=function(self,...)
        if battle==self and commandMenu() then return end
        return message(self,...)
      end
    end
    local code=Font.drawCode
    Font.drawCode=function(c,x,y,...)
      if enabled() and commandMenu() and (c==0xED or c==0xEC)then x=x-1 end
      if mode=='background' then return end
      if mode=='text' and moves() and ((x==32 and y==96) or (x==80 and y==96))
        and (c==Font.BORDER.h or c==Font.BORDER.br) then return end
      local args={...}
      return moveText(function(px,py) return code(c,px,py,unpack(args)) end,x,y)
    end
    local function run(self,...)
      local args={...}
      local priorBattle,priorMode,priorOffset=battle,mode,offset
      battle=self;offset=mod.generation==2 and (tonumber(args[1]) or 0) or 0
      local priorQueue=queue; queue={}
      local originalDraw,rectangle,print,printf=G.draw,G.rectangle,G.print,G.printf
      local function restore()
        G.draw,G.rectangle,G.print,G.printf=originalDraw,rectangle,print,printf
        battle,mode,offset=priorBattle,priorMode,priorOffset
        queue=priorQueue
      end
      local ok,err=pcall(function()
        -- Draw boxes at full opacity into one surface, including their overlaps.
        faded(function()
          mode='background'
          G.draw=function(...) if mode=='box' then return originalDraw(...) end end
          G.rectangle=function(...) if mode=='box' then return rectangle(...) end end
          G.print=function(...) if mode=='box' and print then return print(...) end end
          G.printf=function(...) if mode=='box' and printf then return printf(...) end end
          draw(self,unpack(args))
          G.draw,G.rectangle,G.print,G.printf=originalDraw,rectangle,print,printf
        end)
        for _,rect in ipairs(queue) do protect(unpack(rect)) end
        G.draw,G.print,G.printf=originalDraw,print,printf
        -- Text is drawn once at full opacity, without opaque paper rectangles.
        G.rectangle=function() end
        mode='text'; draw(self,unpack(args))
      end)
      restore()
      if not ok then error(err,0) end
    end
    B[method]=function(self,...)
      if not enabled() then return draw(self,...) end
      if setting('style',1)==2 and not nativeEmerald.ready() and not battleFont.isEmerald()then return draw(self,...)end
      if (setting('style',1)==2 or battleFont.isEmerald()) and G.transformPoint then
        if self.bottomUIVisible and not self:bottomUIVisible()then return end
        local width=wide and 304 or 160+(mod.generation==2 and (tonumber(select(1,...))or 0)or 0)*8
        local y=wide and 104 or 96;local h=wide and 40 or 48
        local x1,y1=G.transformPoint(0,y);local x2,y2=G.transformPoint(width,y+h)
        local deferred=mod.exports.battlePanelSurface
        if self.phase=='menu'and deferred and deferred.defer(self,{x=x1,y=y1,w=x2-x1,h=y2-y1})then return end
        if nativeEmerald.bottom(self,mod.generation,{x=x1,y=y1,w=x2-x1,h=y2-y1,nativeWidth=width,nativeHeight=h,wide=wide},api) then
          protect(0,y,width,h);return
        end
      end
      if self.phase==(mod.generation==2 and 'moves' or 'moveSelect') then
        if self.bottomUIVisible and not self:bottomUIVisible() then return end
        return drawMoves(self,false,mod.generation==2 and select(1,...) or 0)
      end
      return run(self,...)
    end
    if mod.generation==1 then
      local pictures=B.drawPicsLayer
      if pictures then
        B.drawPicsLayer=function(self,slide,sx,sy,side,skipClip,...)
          if enabled() and self.phase=='moveSelect' then skipClip=true end
          return pictures(self,slide,sx,sy,side,skipClip,...)
        end
      end
      local zonePass=B.drawZonePass
      B.drawZonePass=function(self,source,sx,sy,...)
        local rects=enabled() and protected[source]
        if not rects or #rects==0 then return zonePass(self,source,sx,sy,...) end
        local originalDraw,rectangle=G.draw,G.rectangle
        local function regions()
          local x,y,w,h=G.getScissor()
          if not x then x,y,w,h=0,0,source:getWidth(),source:getHeight() end
          local area={x=x,y=y,w=w,h=h}
          local pieces={area}
          local plain={}
          for _,r in ipairs(rects) do
            local moved={x=r.x+(sx or 0),y=r.y+(sy or 0),w=r.w,h=r.h}
            local nextPieces={}
            for _,p in ipairs(pieces) do
              local l,t=math.max(p.x,moved.x),math.max(p.y,moved.y)
              local right,bottom=math.min(p.x+p.w,moved.x+moved.w),math.min(p.y+p.h,moved.y+moved.h)
              if right>l and bottom>t then plain[#plain+1]={x=l,y=t,w=right-l,h=bottom-t} end
              for _,q in ipairs(outside(p,moved)) do nextPieces[#nextPieces+1]=q end
            end
            pieces=nextPieces
          end
          return area,pieces,plain
        end
        local function clipped(fn,args,includePlain)
          local area,pieces,plain=regions()
          local shader=G.getShader()
          for _,r in ipairs(pieces) do
            G.setScissor(r.x,r.y,r.w,r.h);fn(unpack(args))
          end
          if includePlain then
            G.setShader()
            for _,r in ipairs(plain) do
              G.setScissor(r.x,r.y,r.w,r.h);fn(unpack(args))
            end
          end
          G.setShader(shader);G.setScissor(area.x,area.y,area.w,area.h)
        end
        G.draw=function(image,...)
          if image~=source then return originalDraw(image,...) end
          return clipped(originalDraw,{image,...},false)
        end
        G.rectangle=function(...)
          return clipped(rectangle,{...},false)
        end
        local result={pcall(zonePass,self,source,sx,sy,...)}
        G.draw,G.rectangle=originalDraw,rectangle
        if not result[1] then error(result[2],0) end
        -- The native whole-screen zone and message zone overlap. Redraw
        -- protected source regions once after all native zones have finished.
        local unique={}
        for _,r in ipairs(rects) do
          local pieces={r}
          for _,previous in ipairs(unique) do
            local nextPieces={}
            for _,p in ipairs(pieces) do
              for _,q in ipairs(outside(p,previous)) do nextPieces[#nextPieces+1]=q end
            end
            pieces=nextPieces
          end
          for _,p in ipairs(pieces) do unique[#unique+1]=p end
        end
        G.push('all');G.setShader();G.setColor(1,1,1,1)
        G.setBlendMode('alpha','premultiplied')
        for _,r in ipairs(unique) do
          local x,y=r.x+(sx or 0),r.y+(sy or 0)
          G.setScissor(x,y,r.w,r.h)
          originalDraw(source,sx or 0,sy or 0)
          protect(x,y,r.w,r.h)
        end
        G.pop()
        return unpack(result,2)
      end
      local Wide=require('src.battle.WideBattle')
      local native=Wide.draw
      Wide.draw=function(self,...)
        if not enabled() then return native(self,...) end
        if setting('style',1)==2 and nativeEmerald.ready()then return nativeEmerald.wideDraw(self,...)end
        local priorMode,priorBattle,priorCustom=mode,battle,customMoves
        customMoves=false
        mode,battle,wide='wide',self,true
        local result={pcall(native,self,...)}
        mode,battle,wide=priorMode,priorBattle,false
        customMoves=priorCustom
        if not result[1] then error(result[2],0) end
        return unpack(result,2)
      end
    end
  end
  api={frames=frames,frameGeometry=frameGeometry,emeraldFont=battleFont.isEmerald,setting=setting,panel=panel,faded=faded,fadedScreen=function(fn,w,h)return compose(fn,w,h,0,0)end,placement=placement,textPlaced=textPlaced,rows=rows,nativeEmerald=nativeEmerald,protect=protectRegion}
  api.emeraldLayout=assert(load(assert(mod:read('lib/emerald_battle_layout.lua'))))()(G,mod)
  api.hudNames=assert(load(assert(mod:read('lib/battle_hud_names.lua'))))()(mod,textPalette,enabled)
  function api.canDrawBottom(battle)
    if not enabled() or battle.safari or battle.contest then return false end
    if not (battleFont.isEmerald() or setting('style',1)==2 and nativeEmerald.ready()) then return false end
    local phase=battle.phase
    return phase=='menu' or phase=='messages' or mod.generation==2 and
      (phase=='intro' or phase=='resolving' or phase=='locked-in') or false
  end
  function api.drawBottom(battle,rect,viewport)
    if not api.canDrawBottom(battle) then return false end
    return nativeEmerald.bottom(battle,mod.generation,rect,api,viewport)
  end
  battleFont.active=enabled
  api.ownsGen3Panels=enabled
  api.drawGen3Panels=mod.exports.drawGen3Panels
  api.palette=textPalette
  api.healthboxLayers=healthboxLayers
  api.backgroundColor=function()return setting('background_color',0)~=0 and textPalette.background() or nil end
  api.fillBackground=fillBackground
  nativeEmerald.textPalette=textPalette
  nativeEmerald.selectedFont=battleFont.selected
  nativeEmerald.useEmeraldFont=battleFont.isEmerald
  mod.exports.battleUi=api
  local function migrate(payload)
    local loader=payload and payload.loader
    local game=payload and payload.game
    loader=loader or game and game.mods
    local buckets=loader and loader.modOptions or game and game.options and game.options.modOptions
    local old=buckets and buckets.battleuicustomizer
    local handle=mod.find('battleuicustomizer')
    for _,k in ipairs(battleKeys) do
      local n=old and old[k]
      if n==nil and handle and handle.exports.setting then n=handle.exports.setting(k,k=='opacity' and 100 or k=='menu_align' and 2 or k=='style' and 1 or 0) end
      if n~=nil then legacy[k]=n end
      if mod.options:get('battle_'..k)==nil and mod.save:get('battle_'..k)==nil and legacy[k]~=nil then
        mod.save:set('battle_'..k,legacy[k])
        if buckets then buckets[ID]=buckets[ID] or {};buckets[ID]['battle_'..k]=legacy[k] end
      end
    end
    -- The legacy direct wrappers check their options-hook ownership. Removing
    -- that owner's hooks leaves them inert, preventing two render passes.
    if enabled() then require('src.mods.Runtime').hooks:removeOwner('battleuicustomizer') end
  end
  mod.events:on('mods.loaded',migrate)
  mod.events:on('game.ready',migrate)
  local flatMod={find=function()return {exports=api}end}
  api.moveScreen=assert(load(assert(mod:read('lib/battle_move_screen.lua'))))()(flatMod)
  battleFont.wrap(api.moveScreen,'draw',.75)
  if mod.generation==3 then
    battleFont.wrap(require('src.core.game3.battle.ui'),'draw')
  else
    local B=require(mod.generation==2 and 'src.ui.gen2.BattleState' or 'src.battle.BattleState')
    battleFont.wrap(B,mod.generation==2 and 'drawBottom' or 'drawTextArea')
    for _,key in ipairs({'drawHUDs','drawEnemyHud','drawPlayerHud'})do battleFont.wrapHud(B,key)end
    if mod.generation==1 then battleFont.wrap(require('src.battle.WideBattle'),'draw') end
  end

  local sizing=assert(load(assert(mod:read('lib/battle_font_size.lua'))))()(mod,enabled)
  mod.exports.battleFontSizing=sizing
  api.fontSizing=sizing
  sizing.decorate(require('src.render.Font'),'draw','width','drawCode',true)
  if mod.generation==3 then sizing.decorate(require('src.ui.game3.frlg_font'),'draw','measure','drawGlyph',false)end
  sizing.decorate(battleFont.selected,'draw','measure','drawGlyph',false)
  local gb=require('src.render.Font')._menuCustomizerGB
  if gb and gb.mod==mod then sizing.decorate(gb.theme,'draw','measure','glyph',false)end
  assert(load(assert(mod:read('lib/level_up_panels.lua')),'@menu-customizer/level_up_panels.lua'))()(mod,api,battleFont,panel,compose,enabled)
  sizing.scope(api.moveScreen,'draw');sizing.scope(api,'drawBottom')
  local drawMovesSized,drawBottomSized=api.moveScreen.draw,api.drawBottom
  api.moveScreen.draw=function(battle,rect,viewport)return sizing.viewport(viewport,drawMovesSized,battle,rect,viewport)end
  api.drawBottom=function(battle,rect,viewport)return sizing.viewport(viewport,drawBottomSized,battle,rect,viewport)end
  if mod.generation==3 then
    sizing.scope(require('src.core.game3.battle'),'draw')
    sizing.scope(require('src.core.game3.battle.ui'),'draw')
  else
    sizing.scope(require(mod.generation==2 and 'src.ui.gen2.BattleState' or 'src.battle.BattleState'),'draw')
    if mod.generation==1 then sizing.scope(require('src.battle.WideBattle'),'draw')end
  end

end

