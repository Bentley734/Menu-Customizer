-- Run in LOVE with BATTLE_UI_WORKSPACE, POKEMON_CACHE_ROOT and
-- BATTLE_COMPOSED_FIXTURE set. The fixture contains unmodified 3.2.11 frame
-- sources. This exercises the final-window KIM path, not only isolated fonts.
local w=assert(os.getenv('BATTLE_UI_WORKSPACE'))..'/'
local cacheRoot=assert(os.getenv('POKEMON_CACHE_ROOT'))..'/'
local output=assert(os.getenv('BATTLE_COMPOSED_FIXTURE'))..'/'
local function read(path)
  local file=io.open(path,'rb');if not file then return end
  local content=file:read('*a');file:close();return content
end
local function write(path,content)
  local file=assert(io.open(path,'wb'));file:write(content);file:close()
end
local function extract(source,first,last)
  local a=assert(source:find(first,1,true),'missing production entry: '..first)
  local b=assert(source:find(last,a+#first,true),'missing production end: '..last)
  return source:sub(a,b-1)
end
package.path=w..'.tools/engine-0358/?.lua;'..w..'.tools/engine-0358/?/init.lua;'..package.path

function love.load()
  local checks=0
  local function check(value,message)checks=checks+1;assert(value,message)end
  local ok,err=xpcall(function()
    local G=love.graphics
    G.setDefaultFilter('nearest','nearest')
    local originalRead=love.filesystem.read
    love.filesystem.read=function(path)return read(w..'.tools/engine-0358/'..path)or originalRead(path)end
    local GV=require('src.core.GameVersion');GV.set('ruby')
    local Blob=require('src.import.CacheBlob')
    package.loaded['src.import.CacheFs']={readAt=function(path)
      local bytes=read(cacheRoot..path);return bytes and Blob.decode(path,bytes)
    end}
    local Sandbox=require('src.mods.Sandbox')
    local function image(path)
      local value=G.newImage(love.filesystem.newFileData(assert(read(path)),path:match('[^/]+$')))
      value:setFilter('nearest','nearest');return value
    end
    local mod={generation=3,exports={},read=function(_,path)return read(w..'MenuCustomizer/'..path)end,
      assets={image=function(_,path)return image(w..'MenuCustomizer/'..path)end}}
    local native=assert(Sandbox.compile(mod:read('lib/emerald_native.lua'),'@native-Emerald',Sandbox.envFor({modId='gen3transparency',permissions={engine_internals=true}})))()(mod)
    check(native.ready(),'native Emerald font must be loaded for the independent reference')
    local nativeFont=native.battleFont
    check(nativeFont.face({font='normal'}).height==16,'native normal height')
    check(nativeFont.face({font='narrow'}).height==16,'native narrow height')

    -- Load the real Blue character map; dialogue includes encoded GB ligatures.
    GV.set('blue');mod.generation=1
    local Assets=require('src.render.Assets')
    Assets.register=function()end
    Assets.image=function(path)return image(cacheRoot..'blue/'..path)end
    local Font=require('src.render.Font')
    Font.load({font=assert(loadstring(assert(read(cacheRoot..'blue/data/generated/font.lua'))))()})
    local theme=assert(loadstring(mod:read('lib/emerald_theme.lua')))()(mod,function()return true end)
    mod.exports.gbMenus={theme=theme}
    local denied=0
    local gbEnv=Sandbox.envFor({modId='gen3transparency',permissions={engine_internals=true}})
    local engineRequire=gbEnv.require
    gbEnv.require=function(name)
      if name:match('^src%.core%.game3')or name:match('^src%.ui%.game3')then
        denied=denied+1;error('cross-generation engine access: '..name)
      end
      return engineRequire(name)
    end
    local port=assert(Sandbox.compile(mod:read('lib/emerald_native.lua'),'@cached-Blue-port',gbEnv))()(mod)
    port.useEmeraldFont=function()return true end
    check(not port.ready()and port.presentationReady(),'Blue must use portable fonts even with Emerald cache present')

    local selection,style,align,stretch=12,3,2,0
    local catalog=assert(loadstring(mod:read('lib/border_catalog.lua')))()
    local function borderSetting(key)return key=='menuBorder'and selection or 2 end
    local borders=assert(loadstring(mod:read('lib/menu_borders.lua')))()(mod,borderSetting,catalog,function()return true end)
    local oldBorders=assert(loadstring(assert(read(output..'baseline/menu_borders.lua'))))()(mod,borderSetting,catalog,function()return true end)
    mod.exports.borders=borders
    local function setting(key,default)
      if key=='style'then return style elseif key=='opacity'then return 100
      elseif key=='menu_align'then return align elseif key=='menu_stretch'then return stretch end
      return default
    end
    local function placement(x,width,total)
      if stretch==1 then return 0,total/width end
      return(total-width)*align/2,1
    end
    local compose=assert(loadstring(mod:read('lib/battle_compositor.lua')))()(G,function()return 100 end)
    local api={setting=setting,nativeEmerald=port,emeraldFont=port.useEmeraldFont}
    local uiSource=mod:read('lib/battle_ui.lua')
    local env=setmetatable({G=G,mod=mod,setting=setting,placement=placement,compose=compose,api=api,
      emeraldArt=function()error('style 3 should use selected menu border')end},{__index=_G})
    local frameSource=extract(uiSource,'  local function panel(','  local function persist(')
    local create=assert(Sandbox.compile(frameSource..'\nreturn panel,frameGeometry,frames','@production-frame-functions',env))
    api.panel,api.frameGeometry,api.frames=create()
    api.faded=function(fn)return fn()end
    api.fadedScreen=function(fn,width,height)return compose(fn,width,height,0,0)end
    env.nativeEmerald=port;env.enabled=function()return true end
    env.battleFont={isEmerald=port.useEmeraldFont}
    assert(Sandbox.compile(extract(uiSource,'  function api.canDrawBottom(','  battleFont.active='),'@production-direct-bottom',env))()
    package.loaded['src.battle.TypeChart']={displayName=function(kind)return kind end}
    api.moveScreen=assert(loadstring(mod:read('lib/battle_move_screen.lua')))()({find=function()return {exports=api}end})

    -- The prior frame source has font calls disabled so only the original
    -- 336x64 two-panel geometry and border rasterization remain as reference.
    local oldPanelSource=extract(assert(read(output..'baseline/battle_ui.lua')),'  local function panel(','  local function persist(')
    local oldMod={generation=1,exports={borders=oldBorders}}
    local oldEnv=setmetatable({G=G,mod=oldMod,setting=setting,emeraldArt=function()end},{__index=_G})
    local oldPanel=assert(Sandbox.compile(oldPanelSource..'\nreturn panel','@3.2.11-panel',oldEnv))()
    local prior={setting=setting,panel=oldPanel,faded=function(fn)return fn()end}
    local legacySource=assert(read(output..'baseline/battle_move_screen.lua'))
    local legacyEnv=setmetatable({require=function(name)
      if name=='src.render.Font'then return {draw=function()end,drawCode=function()end,width=function(text)return #text*8 end}end
      return require(name)
    end},{__index=_G})
    local oldMoves=assert(Sandbox.compile(legacySource,'@3.2.11-move-frames',legacyEnv))()({find=function()return {exports=prior}end})

    -- Extract the exact final KIM presenter. A low-resolution capture is a
    -- hard failure: labels must reach the final-window canvas directly.
    local kimRoot=w..'.work/latest-sprite-fix/current-source/kim1025/'
    local kim={read=function(_,path)return read(kimRoot..path)end,
      find=function(id)if id=='gen3transparency'then return {exports={battleUi=api}}end end}
    kim._kimBattleMoveMenu=assert(loadstring(assert(kim:read('lib/battle_move_menu.lua'))))()(kim)
    local kimEnv=setmetatable({IS_GEN2=false,mod=kim,
      battleUiViewportRect=function(_,viewport)return 0,0,viewport.width,viewport.height end,
      touchBattleOrientation=function()end,menuBattleUi=function()return api end,
      captureBattleText=function()error('Emerald text was downsampled through the 160px capture')end},{__index=_G})
    local kimSource=extract(assert(read(kimRoot..'main.lua')),'  local function drawNativeBattleText(','  if mod.hooks and type(mod.hooks.wrap)')
    local drawKim=assert(Sandbox.compile(kimSource..'\nreturn drawNativeBattleText','@production-KIM-final-presenter',kimEnv))()
    local battle={phase='menu',menuIndex=2,
      shown={Font.encode('Wild KRICKETUNE'),Font.encode('appeared!')},msgWaiting=true,
      player={name='NIDOKING',mon={name='NIDOKING'},curMoves={{id=1,pp=34},{id=2,pp=11},{id=3,pp=5},{id=4,pp=0}}},
      data={moves={[1]={name='SCRATCH',pp=35,type='NORMAL'},[2]={name='THUNDERBOLT',pp=15,type='ELECTRIC'},
        [3]={name='DOUBLE KICK',pp=30,type='FIGHTING'},[4]={name='POISON STING',pp=35,type='POISON'}}},moveIndex=2}

    local function canvas(width,height,draw,solid)
      local c=G.newCanvas(width,height,{dpiscale=1,format='rgba8'});c:setFilter('nearest','nearest')
      G.push('all');G.setCanvas(c);G.origin();G.setShader();G.setScissor()
      G.clear(solid and .22 or 0,solid and .42 or 0,solid and .23 or 0,solid and 1 or 0)
      G.setColor(1,1,1,1);draw();G.pop();return c
    end
    local function equal(actual,expected,message)
      local a,b=actual:newImageData():getString(),expected:newImageData():getString()
      if a~=b then
        write(output..'failed-actual.png',actual:newImageData():encode('png'):getString())
        write(output..'failed-reference.png',expected:newImageData():encode('png'):getString())
        local first
        for i=1,#a do if a:byte(i)~=b:byte(i)then first=i;break end end
        local pixel=math.floor((first-1)/4)
        message=message..' first pixel '..(pixel%actual:getWidth())..','..math.floor(pixel/actual:getWidth())..' bytes '..a:byte(first)..'/'..b:byte(first)
      end
      check(a==b,message)
    end
    local function rectFor(width,height)
      local scale=math.min(width/160,height/144)
      return{x=math.floor((width-160*scale)/2+.5),y=math.floor(height-48*scale+.5),w=160*scale,h=48*scale}
    end
    local function oldFrames(mode,rect)
      if mode=='moves'then check(oldMoves.draw(battle,rect,{}),'legacy move frames');return end
      local x,width=0,160
      if mode=='menu'then x,width=placement(64,96,160);width=96*width end
      G.push('all');G.translate(rect.x+x*rect.w/160,rect.y)
      G.scale((mode=='menu'and width or 160)*rect.w/160/(mode=='menu'and 96 or 160),rect.h/48)
      oldPanel(0,0,mode=='menu'and 96 or 160,48,false);G.pop()
    end
    local function referenceText(mode,rect)
      local r=rect
      if mode=='menu'then
        local x,s=placement(64,96,160);r={x=rect.x+x*rect.w/160,y=rect.y,w=96*s*rect.w/160,h=rect.h}
      end
      local inset=8*r.h/48
      local inner={x=r.x+inset,y=r.y+inset,w=r.w-2*inset,h=r.h-2*inset}
      if mode=='menu'then r=inner end
      local width=mode=='menu'and 120 or 240
      local scale=math.min(r.w/width,r.h/48);if scale>=1 then scale=math.floor(scale)end
      local tx=math.floor(r.x+(r.w-width*scale)/2+.5)
      local ty=math.floor(r.y+(r.h-48*scale)/2+.5)
      G.push('all')
      if mode~='moves'then
        G.setScissor(inner.x,inner.y,inner.w,inner.h)
        G.translate(tx,ty);G.scale(scale,scale);G.translate(0,-112)
      end
      local function textAt(x,fn)
        if mode~='moves'then return fn()end
        local edge=8*rect.h/48
        local leftWidth=rect.w*2/3-2*edge
        local rightWidth=rect.w/3-2*edge
        local height=rect.h-2*edge
        local unit=math.min(leftWidth/160,rightWidth/80,height/48)
        if unit>=1 then unit=math.floor(unit)end
        local right=x>=160
        local paneX=rect.x+edge+(right and rect.w*2/3 or 0)
        local paneWidth=right and rightWidth or leftWidth
        local nativeWidth=right and 80 or 160
        local nativeX=right and 160 or 0
        local x0=math.floor(paneX+(paneWidth-nativeWidth*unit)/2+.5)
        local y0=math.floor(rect.y+edge+(height-48*unit)/2+.5)
        G.push('all');G.origin()
        G.setScissor(paneX,rect.y+edge,paneWidth,height)
        G.translate(x0,y0);G.scale(unit,unit);G.translate(-nativeX,-112)
        fn();G.pop()
      end
      local colors=native.colors()
      if mode=='menu'then
        for i,label in ipairs({'FIGHT','BAG','POKéMON','RUN'})do
          nativeFont.draw(label,8+56*((i-1)%2),121+16*math.floor((i-1)/2),{colors=colors})
        end
        local cursor=battle.menuIndex-1
        nativeFont.drawGlyph(nativeFont.CHAR_SELECTOR_ARROW,56*(cursor%2),121+16*math.floor(cursor/2),{colors=colors})
      elseif mode=='moves'then
        for i=1,4 do
          local mv=battle.player.curMoves[i];local def=battle.data.moves[mv.id]
          local x,y,width=native.chrome.textOrigin(i+2)
          textAt(x,function()nativeFont.draw(def.name,x,y,{font='narrow',colors=colors})end)
          if i==battle.moveIndex then textAt(0,function()nativeFont.drawGlyph(nativeFont.CHAR_SELECTOR_ARROW,8+72*((i-1)%2),y,{colors=colors})end)end
        end
        local selected=battle.player.curMoves[battle.moveIndex];local def=battle.data.moves[selected.id]
        local ppColors=native.colors(selected.pp,def.pp)
        local x,y,width=native.chrome.textOrigin(7);textAt(x,function()nativeFont.draw('PP',x,y,{font='narrow',colors=ppColors})end)
        x,y,width=native.chrome.textOrigin(9);textAt(x,function()nativeFont.draw(string.format('%2d/%2d',selected.pp,def.pp),x,y,{colors=ppColors})end)
        x,y,width=native.chrome.textOrigin(10);textAt(x,function()nativeFont.draw('TYPE/',x,y,{font='narrow',colors=colors})end)
        local advance=nativeFont.measure('TYPE/',{font='narrow'})
        textAt(x,function()nativeFont.draw(def.type,x+advance,y,{colors=colors})end)
      else
        nativeFont.draw('Wild KRICKETUNE',16,121,{colors=colors,maxWidth=208})
        nativeFont.draw('appeared!',16,137,{colors=colors,maxWidth=208})
        nativeFont.drawGlyph(0x7A,224,137,{colors=colors})
      end
      G.pop()
    end
    for _,size in ipairs({{1047,729},{1920,1080},{5120,1440}})do
      local width,height=size[1],size[2];local rect=rectFor(width,height)
      local viewport={width=width,height=height,dpiX=1,dpiY=1}
      for _,mode in ipairs({'menu','moves','dialogue'})do
        battle.phase=mode=='moves'and'moveSelect'or mode=='dialogue'and'messages'or'menu'
        local actualFrame=canvas(width,height,function()api.frames(mode=='dialogue'and'none'or mode,rect,viewport)end)
        local expectedFrame=canvas(width,height,function()oldFrames(mode,rect)end)
        equal(actualFrame,expectedFrame,'3.2.11 border pixels differ: '..mode..' '..width)
        actualFrame:release();expectedFrame:release()
        local composed=canvas(width,height,function()check(drawKim(battle,viewport),'KIM direct draw '..mode)end,true)
        local reference=canvas(width,height,function()oldFrames(mode,rect);referenceText(mode,rect)end,true)
        equal(composed,reference,'composed KIM pixels differ from original frame + native Emerald glyphs: '..mode..' '..width)
        write(output..mode..'-'..width..'x'..height..'.png',composed:newImageData():encode('png'):getString())
        composed:release();reference:release();collectgarbage('collect')
      end
    end
    for _,border in ipairs({3,13})do
      selection=border
      local rect=rectFor(1047,729)
      for _,mode in ipairs({'menu','moves','dialogue'})do
        battle.phase=mode=='moves'and'moveSelect'or mode=='dialogue'and'messages'or'menu'
        local actual=canvas(1047,729,function()api.frames(mode=='dialogue'and'none'or mode,rect,{})end)
        local expected=canvas(1047,729,function()oldFrames(mode,rect)end)
        equal(actual,expected,'3.2.11 alternate border '..border..' '..mode)
        actual:release();expected:release()
      end
    end
    -- Width/alignment alter only original command bounds, never dialogue/moves.
    for _,wide in ipairs({false,true})do for _,position in ipairs({0,1,2})do for _,full in ipairs({0,1})do
      align,stretch=position,full
      local nativeWidth=wide and 304 or 160
      local rect={x=20,y=30,w=nativeWidth*2,h=(wide and 40 or 48)*2,nativeWidth=nativeWidth,nativeHeight=wide and 40 or 48,wide=wide}
      local r=api.frameGeometry('menu',rect)
      local commandWidth=wide and 144 or 96
      local expectedWidth=(full==1 and nativeWidth or commandWidth)*2
      local expectedX=full==1 and 20 or 20+(nativeWidth-commandWidth)*position
      check(r.x==expectedX and r.w==expectedWidth and r.h==rect.h,'original command pane bounds')
      local dialogue=api.frameGeometry('none',rect)
      check(dialogue.x==rect.x and dialogue.w==rect.w,'dialogue owns original full strip')
    end end end
    -- Atlas bytes come from the actual Emerald extraction, not approximations.
    for _,face in ipairs({'normal','narrow'})do for _,layer in ipairs({'fg','shadow'})do
      local raw=require('src.import.CacheFs').readAt('emerald/data/generated/gba/chrome/fonts/latin_'..face..'_'..layer..'.rgba')
      local data=love.image.newImageData(love.filesystem.newFileData(assert(mod:read('assets/emerald/battle_'..face..'_'..layer..'.png')),'font.png'))
      check(data:getString()==raw,'bundled '..face..' '..layer..' differs from Emerald extraction')
    end end
    for _,game in ipairs({'red','blue','yellow','gold','silver','crystal'})do
      GV.set(game);mod.generation=GV.generation()
      local other=assert(Sandbox.compile(mod:read('lib/emerald_native.lua'),'@cached-'..game,gbEnv))()(mod)
      other.useEmeraldFont=function()return true end
      check(not other.ready()and other.presentationReady(),'cached portable renderer for '..game)
      local state=mod.generation==2 and{phase='resolving',messageLines=function()return {'Wild KRICKETUNE','appeared!'}end,messageArrowVisible=function()return true end}or battle
      state.phase=mod.generation==2 and'resolving'or'messages'
      local drawn=canvas(320,288,function()
        check(other.bottom(state,mod.generation,{x=0,y=192,w=320,h=96},api,{}),'cached bottom renderer '..game)
      end)
      drawn:release()
    end
    check(denied==0,'Gen 1 reached a forbidden Gen 3 engine module')
  end,debug.traceback)
  write(output..'result.txt',ok and('PASS '..checks..' composed GPU checks')or tostring(err))
  love.event.quit(ok and 0 or 1)
end
