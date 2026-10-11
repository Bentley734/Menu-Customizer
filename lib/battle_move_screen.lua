-- A dedicated flat move panel; never crop the native Gen1 TYPE/PP window.
return function(mod)
  local Font = require('src.render.Font')
  local TypeChart = require('src.battle.TypeChart')
  local api = {}
  local function customizer()
    if not (mod and type(mod.find)=='function') then return nil end
    local ok,h=pcall(mod.find,'battleuicustomizer')
    if not ok or not h then ok,h=pcall(mod.find,mod,'battleuicustomizer') end
    local e=ok and h and h.exports
    if type(e)=='table' and type(e.setting)=='function' then return e end
  end
  function api.installSourceGuard(active)
    if not mod then return end
    local function install()
      local ok,B=pcall(require,'src.battle.BattleState')
      if not ok or type(B.drawTextArea)~='function' then return end
      if B.drawTextArea==api.sourceWrapper then return end
      local inner=B.drawTextArea
      local function wrapper(battle,...)
        if battle.phase=='moveSelect' and active(battle) then return end
        return inner(battle,...)
      end
      api.sourceWrapper=wrapper;B.drawTextArea=wrapper
    end
    install()
    if mod.events then
      mod.events:on('mods.loaded',install)
      mod.events:on('game.ready',install)
    end
  end
  function api.layout(rect, dpiX, dpiY)
    dpiX, dpiY = tonumber(dpiX) or 1, tonumber(dpiY) or 1
    if dpiX <= 0 then dpiX=1 end
    if dpiY <= 0 then dpiY=1 end
    -- Frames fill the same rectangle as commands/dialogue. Size text
    -- independently so fitting the 2x2 grid never shrinks the entire panel.
    local scale = math.min(rect.w*dpiX/336, rect.h*dpiY/64)
    return {x=rect.x,y=rect.y,sx=rect.w/336,sy=rect.h/64,
      textSx=scale/dpiX,textSy=scale/dpiY}
  end
  function api.wrapName(label,limit)
    label=tostring(label);limit=math.max(1,math.floor(limit))
    if #label<=limit then return {label} end
    local cut
    for i=2,math.min(limit,#label-1) do if label:sub(i,i)==' ' then cut=i end end
    cut=cut or limit+1
    local first=label:sub(1,cut-1)
    local second=label:sub(cut):gsub('^%s+','')
    return {first,second}
  end
  function api.draw(battle, rect, viewport)
    if battle.phase~='moveSelect' then return false end
    local custom=customizer()
    local port=custom and custom.nativeEmerald
    if custom and custom.setting('style',1)==2 and port and port.ready() then
      local g=love.graphics
      local F,C=port.font,port.chrome
      local moves=battle.player and battle.player.curMoves or {}
      local colors=port.colors()
      -- Emerald's actual 240x160 screen; the lower 48 pixels are the menu.
      g.push('all')
      local ok,err=pcall(function()
        g.origin();g.setShader();g.setScissor()
        local dx,dy=viewport and viewport.dpiX or 1,viewport and viewport.dpiY or 1
        local pixels=math.min(rect.w*dx/240,rect.h*dy/48)
        local sx,sy=pixels/dx,pixels/dy
        g.translate(rect.x+(rect.w-240*sx)/2,rect.y+rect.h-48*sy);g.scale(sx,sy);g.translate(0,-112)
        local function frames()
          if custom.setting('style',1)==3 then
            custom.panel(0,112,160,48,false);custom.panel(160,112,80,48,false)
          else C.drawPanel('moves');C.drawMenuFrames('moves') end
        end
        if custom.fadedScreen then
          g.push('all');g.origin()
          custom.fadedScreen(function()
            g.translate(rect.x+(rect.w-240*sx)/2,rect.y+rect.h-48*sy);g.scale(sx,sy);g.translate(0,-112)
            frames()
          end,math.ceil(rect.x+rect.w),math.ceil(rect.y+rect.h))
          g.pop()
        else custom.faded(frames) end
        g.setColor(1,1,1,1)
        local function label(win,s,dx,narrow)
          local x,y,w,isNarrow=C.textOrigin(win)
          F.draw(tostring(s),x+(dx or 0),y,{font=(narrow==nil and isNarrow or narrow) and 'narrow' or 'normal',colors=colors,maxWidth=w-(dx or 0)})
        end
        for i=1,4 do
          local mv=moves[i];local def=mv and battle.data.moves[mv.id]
          label(C.WIN.MOVE_NAME_1+i-1,def and def.name or '-')
          if i==battle.moveIndex or i==battle.moveSwapIndex then
            local _,y=C.textOrigin(C.WIN.MOVE_NAME_1+i-1)
            F.drawGlyph(F.CHAR_SELECTOR_ARROW,8+72*((i-1)%2),y,{colors=colors})
          end
        end
        local mv=moves[battle.moveIndex or 1];local def=mv and battle.data.moves[mv.id]
        if def then
          local base=tonumber(def.pp) or 0
          local maximum=mv.maxPp or base+(mv.ppUps or 0)*math.floor(base/5)
          colors=port.colors(mv.pp or 0,maximum)
          label(C.WIN.PP,'PP')
          label(C.WIN.PP_REMAINING,string.format('%2d/%2d',mv.pp or 0,maximum))
          colors=port.colors()
          label(C.WIN.MOVE_TYPE,'TYPE/')
          label(C.WIN.MOVE_TYPE,TypeChart.displayName(def.type,battle.data),F.measure('TYPE/',{font='narrow'}),false)
        end
      end)
      g.pop();if not ok then error(err,0)end
      return true
    end
    local g=love.graphics
    local p=api.layout(rect,viewport and viewport.dpiX,viewport and viewport.dpiY)
    g.push('all')
    local ok,err=pcall(function()
      g.origin();g.setShader();g.setScissor()
      g.translate(p.x,p.y);g.scale(p.sx,p.sy)
      local function text(label,x,y,width,enlarge)
        label=tostring(label)
        local size=enlarge or 1
        local measured=Font.width and Font.width(label) or #label*8
        local fit=width and math.min(1,width*p.sx/math.max(1,(measured+.5)*p.textSx*size)) or 1
        g.push('all');g.translate(x,y)
        g.scale(p.textSx*fit*size/p.sx,p.textSy*fit*size/p.sy)
        local drawn,why=pcall(function()
          Font.draw(label,0,0)
          -- Half a font pixel strengthens stems without blurring the pixel font.
          Font.draw(label,.5,0)
        end);g.pop()
        if not drawn then error(why,0) end
      end
      local function cursor(code,x,y)
        g.push('all');g.translate(x,y)
        g.scale(p.textSx/p.sx,p.textSy/p.sy)
        local drawn,why=pcall(Font.drawCode,code,0,0);g.pop()
        if not drawn then error(why,0) end
      end
      local theme=customizer()
      local function emeraldPanel(x,w)
        -- Preserve the imported frame corners and border thickness instead of
        -- squeezing a 240px textbox into the narrow PP/type column.
        if api.emeraldFrame==nil then
          api.emeraldFrame=false
          local loaded,frame=pcall(function()
            local cache=require('src.import.CacheFs')
            local root='emerald/data/generated/gba/pokemon/battle/'
            local src=cache.readAt(root..'manifest.lua')
            local chunk=type(src)=='string' and load(src,'@kim-emerald-frame','t',{})
            local m=chunk and chunk()
            if type(m)~='table' then return end
            local iw,ih=m.textboxW or 256,m.textboxH or 512
            local rgba=cache.readAt(root..'textbox.rgba')
            if type(rgba)~='string' or #rgba~=iw*ih*4 then return end
            local image=g.newImage(love.image.newImageData(iw,ih,'rgba8',rgba))
            image:setFilter('nearest','nearest')
            local parts={}
            local xs,ys={0,12,228},{112,124,148}
            local ws,hs={12,216,12},{12,24,12}
            for row=1,3 do for col=1,3 do
              parts[#parts+1]={quad=g.newQuad(xs[col],ys[row],ws[col],hs[row],iw,ih),
                row=row,col=col,w=ws[col],h=hs[row]}
            end end
            return {image=image,parts=parts}
          end)
          if loaded and frame then api.emeraldFrame=frame end
        end
        if api.emeraldFrame then
          local frame=api.emeraldFrame
          local xs,ys={x,x+12,x+w-12},{0,12,52}
          local ws,hs={12,w-24,12},{12,40,12}
          g.setColor(1,1,1,1)
          for _,part in ipairs(frame.parts) do
            g.draw(frame.image,part.quad,xs[part.col],ys[part.row],0,
              ws[part.col]/part.w,hs[part.row]/part.h)
          end
          g.setColor(.97,.97,.87,1);g.rectangle('fill',x+8,8,w-16,48)
        else
          -- Emerald's red rim also remains available without an Emerald import.
          g.setColor(74/255,66/255,82/255,1);g.rectangle('fill',x,0,w,64)
          g.setColor(214/255,74/255,58/255,1);g.rectangle('fill',x+3,3,w-6,58)
          g.setColor(107/255,165/255,165/255,1);g.rectangle('fill',x+8,8,w-16,48)
          g.setColor(.97,.97,.87,1);g.rectangle('fill',x+8,8,w-16,48)
        end
      end
      local function frames()
        if theme and theme.setting('style',1)==3 then
          theme.panel(0,0,224,64,false);theme.panel(224,0,112,64,false)
        elseif theme and theme.setting('style',1)==2 then
          emeraldPanel(0,224);emeraldPanel(224,112)
        else
          g.setColor(1,1,1,1)
          Font.drawBox(0,0,28,8);Font.drawBox(28,0,14,8)
        end
      end
      -- Customizer composites opacity once and leaves text at full opacity.
      -- Emerald uses the same imported artwork with fixed-size borders.
      if theme and theme.fadedScreen then
        g.push('all');g.origin()
        theme.fadedScreen(function()
          g.translate(p.x,p.y);g.scale(p.sx,p.sy);frames()
        end,math.ceil(rect.x+rect.w),math.ceil(rect.y+rect.h))
        g.pop()
      elseif theme and type(theme.faded)=='function' then theme.faded(frames) else frames() end
      g.setColor(0.08,0.10,0.12,1)
      local moves=battle.player and battle.player.curMoves or {}
      for i=1,4 do
        local col=(i-1)%2;local row=math.floor((i-1)/2)
        local x=22+col*101
        local cellTop=8+row*24
        local mv=moves[i];local def=mv and battle.data.moves[mv.id]
        local label=def and def.name or mv and tostring(mv.id) or '-'
        local limit=math.max(1,math.floor(89*p.sx/(8*p.textSx*1.2)))
        local lines=api.wrapName(label,limit)
        -- Center the complete one/two-line name in its invisible quarter.
        local glyphHeight=8*p.textSy*1.2/p.sy
        local lineStep=11*p.textSy*1.2/p.sy
        local blockHeight=glyphHeight+(#lines-1)*lineStep
        local y=cellTop+(24-blockHeight)/2
        if #lines==1 then text(lines[1],x,y,89,1.2)
        else
          text(lines[1],x,y,89,1.2)
          text(lines[2],x,y+lineStep,89,1.2)
        end
        if battle.moveIndex==i then cursor(0xED,x-9,y) end
        if battle.moveSwapIndex==i and battle.moveIndex~=i then cursor(0xEC,x-9,y) end
      end
      local selected=moves[battle.moveIndex or 1]
      local def=selected and battle.data.moves[selected.id]
      text('PP',236,11,24)
      local pp='--/--'
      if def then
        local base=tonumber(def.pp) or 0
        local maximum=tonumber(selected.maxPp) or base+(selected.ppUps or 0)*math.floor(base/5)
        pp=string.format('%d/%d',tonumber(selected.pp) or 0,maximum)
      end
      text(pp,324-#pp*8,11,#pp*8)
      text('TYPE/',236,35,88)
      local name=def and def.type and TypeChart.displayName(def.type,battle.data) or '--'
      -- The native pixel font is eight pixels wide. Long type names get a
      -- separate line, keeping the detail column legible without stretching.
      text(name,236,46,88)
      if battle.player and battle.player.disabledSlot==battle.moveIndex then
        text('DISABLED',236,23,88)
      end
    end)
    g.pop()
    if not ok then error(err,0) end
    return true
  end
  return api
end
