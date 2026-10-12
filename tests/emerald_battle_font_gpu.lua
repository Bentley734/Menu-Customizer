local w=assert(os.getenv('BATTLE_UI_WORKSPACE'))..'/'
local a=assert(os.getenv('POKEMON_CACHE_ROOT'))..'/'
local function read(p)local f=io.open(p,'rb');if not f then return end;local s=f:read('*a');f:close();return s end
package.path=w..'.tools/engine-0358/?.lua;'..w..'.tools/engine-0358/?/init.lua;'..package.path
function love.load()
 local ok,err=xpcall(function()
  local fsread=love.filesystem.read
  love.filesystem.read=function(p)return read(w..'.tools/engine-0358/'..p) or fsread(p)end
  local GV=require('src.core.GameVersion');GV.set('ruby')
  local Blob=require('src.import.CacheBlob');package.loaded['src.import.CacheFs']={readAt=function(p)local s=read(a..p);return s and Blob.decode(p,s)end}
  local mod={read=function(_,p)return read(w..'MenuCustomizer/'..p)end}
  local Sandbox=require('src.mods.Sandbox')
  local env=Sandbox.envFor({modId='gen3transparency',permissions={engine_internals=true}})
  local port=assert(Sandbox.compile(mod:read('lib/emerald_native.lua'),'@emerald-native',env))()(mod)
  assert(port.ready(),'Emerald renderer did not load')
  assert(port.font.face({font='narrow'}),'narrow font missing')
  assert(port.chrome.layout()=='rse')
  local G=love.graphics;local c=G.newCanvas(240,160);G.setCanvas(c);G.clear(.9,.95,.8,1)
  port.chrome.drawPanel('moves');port.chrome.drawMenuFrames('moves')
  local colors=port.colors()
  for i,s in ipairs({'SCRATCH','GROWL','-','-'})do local x,y=port.chrome.textOrigin(i+2);port.font.draw(s,x,y,{font='narrow',colors=colors})end
  local x,y=port.chrome.textOrigin(7);port.font.draw('PP',x,y,{font='narrow',colors=port.colors(34,35)})
  x,y=port.chrome.textOrigin(9);port.font.draw('34/35',x,y,{colors=port.colors(34,35)})
  x,y=port.chrome.textOrigin(10);port.font.draw('TYPE/',x,y,{font='narrow',colors=colors});port.font.draw('NORMAL',x+port.font.measure('TYPE/',{font='narrow'}),y,{colors=colors})
  port.font.drawGlyph(port.font.CHAR_SELECTOR_ARROW,8,121,{colors=colors})
  G.setCanvas();c:newImageData():encode('png'):getString()
  local hud=G.newCanvas(160,144);G.setCanvas(hud);G.clear(.9,.95,.8,1)
  local battle={phase='menu',menuIndex=1,player={name='TORCHIC',shownHP=17,mon={name='TORCHIC',level=5,hp=17,stats={hp=20}}},enemy={name='ZIGZAGOON',mon={level=2,hp=12,stats={hp=20}}}}
  assert(port.hud(battle,1,'enemy'));assert(port.hud(battle,1,'player'))
  G.setCanvas();local hf=assert(io.open(w..'.work/emerald-port/hud.png','wb'));hf:write(hud:newImageData():encode('png'):getString());hf:close()
  local screenCompose=assert(loadfile(w..'MenuCustomizer/lib/battle_compositor.lua'))()(love.graphics,function()return 100 end)
  local theme={fadedScreen=function(fn,w,h)return screenCompose(fn,w,h,0,0)end,nativeEmerald=port,setting=function()return 2 end,faded=function(fn)return fn()end}
  package.loaded['src.battle.TypeChart']={displayName=function(t)return t end}
  local panels=assert(loadstring(mod:read('lib/battle_move_screen.lua')))()({find=function()return {exports=theme}end})
  package.loaded['src.battle.TypeChart']={displayName=function(t)return t end}
  battle.phase='moveSelect';battle.moveIndex=1;battle.player.curMoves={{id=1,pp=34},{id=2,pp=40}}
  battle.data={moves={[1]={name='SCRATCH',pp=35,type='NORMAL'},[2]={name='GROWL',pp=40,type='NORMAL'}}}
  local menu=G.newCanvas(240,48);G.setCanvas(menu);G.clear(.9,.95,.8,1)
  assert(panels.draw(battle,{x=0,y=0,w=240,h=48},{}));G.setCanvas()
  local mi=menu:newImageData();local reference=c:newImageData()
  for yy=0,47 do for xx=0,239 do
    local r,g,b,aa=mi:getPixel(xx,yy);local rr,gg,bb,ab=reference:getPixel(xx,yy+112)
    assert(math.abs(r-rr)<.001 and math.abs(g-gg)<.001 and math.abs(b-bb)<.001 and math.abs(aa-ab)<.001,'move panel differs from native Emerald at '..xx..','..yy)
  end end
  local mf=assert(io.open(w..'.work/emerald-port/move.png','wb'));mf:write(mi:encode('png'):getString());mf:close()
  local f=assert(io.open(w..'.work/emerald-port/native.png','wb'));f:write(c:newImageData():encode('png'):getString());f:close()
  local F=require('src.ui.game3.frlg_font');local C=require('src.ui.game3.battle_chrome');local P=require('src.core.game3.profile')
  local fd,cp,pf=F.draw,C.drawPanel,P.forSession
  port.scope(function()assert(P.forSession().font==port.profile.font);assert(C.layout()=='rse');assert(F.draw==port.font.draw)end)
  assert(F.draw==fd and C.drawPanel==cp and P.forSession==pf,'scope not restored')
  for _,game in ipairs({'ruby','sapphire','emerald','firered','leafgreen'})do
    GV.set(game)
    assert(port.ready());assert(port.font.face({font='narrow'}).height==16)
    port.scope(function()assert(P.forSession().font==port.profile.font);assert(C.layout()=='rse')end)
    assert(F.draw==fd and C.drawPanel==cp and P.forSession==pf)
  end
  GV.set('ruby')
  local gen2={phase='menu',menuIndex=2,shownExp=32,showEnemyHud=true,showPlayerHud=true,
    activeMon=function(_,side)return side=='player'and {name='TORCHIC',gender='M',hp=17,maxHp=20,level=5}or {name='ZIGZAGOON',hp=12,maxHp=20,level=2}end,
    hudHp=function(_,mon)return mon.hp end,messageLines=function()return {'Wild ZIGZAGOON','appeared!'}end,messageArrowVisible=function()return true end}
  G.setCanvas(hud);G.clear(.9,.95,.8,1);assert(port.hud(gen2,2,'enemy'));assert(port.hud(gen2,2,'player'));G.setCanvas()
  G.setCanvas(menu);G.clear(.9,.95,.8,1);assert(port.bottom(gen2,2,{x=0,y=0,w=240,h=48},theme));G.setCanvas()
  gen2.phase='resolving';G.setCanvas(menu);assert(port.bottom(gen2,2,{x=0,y=0,w=240,h=48},theme));G.setCanvas()
  gen2.phase='moves';assert(not port.bottom(gen2,2,{x=0,y=0,w=240,h=48},theme))
  local assets=require('src.render.Assets')
  local cacheGame='blue'
  assets.register=function()end
  assets.image=function(p)local raw=assert(read(a..cacheGame..'/'..p));local img=G.newImage(love.filesystem.newFileData(raw,'font.png'));img:setFilter('nearest','nearest');return img end
  local GBFont=require('src.render.Font')
  for _,id in ipairs({'blue','gold'})do
    cacheGame=id
    GBFont.load({font=assert(loadstring(assert(read(a..id..'/data/generated/font.lua'))))()})
    assert(port.decode(GBFont.encode("can't learn more"))=="can't learn more",'GB ligature conversion failed for '..id)
  end
  local selection=13
  local catalog=assert(loadstring(mod:read('lib/border_catalog.lua')))()
  local assetsMod={generation=1,assets={image=function(_,p)local img=G.newImage(love.filesystem.newFileData(assert(read(w..'MenuCustomizer/'..p)),'frame.png'));img:setFilter('nearest','nearest');return img end}}
  local borders=assert(loadstring(mod:read('lib/menu_borders.lua')))()(assetsMod,function(k)return k=='menuBorder'and selection or 2 end,catalog,function()return true end)
  mod.exports={borders=borders}
  for i=1,#catalog.choices do
    selection=i;G.setCanvas(menu);G.clear(.9,.95,.8,1)
    assert(panels.draw(battle,{x=0,y=0,w=240,h=48},{}));G.setCanvas()
  end
  selection=13;G.setCanvas(menu);G.clear(.9,.95,.8,1);assert(panels.draw(battle,{x=0,y=0,w=240,h=48},{}));G.setCanvas()
  local f=assert(io.open(w..'.work/emerald-port/selected-border.png','wb'));f:write(menu:newImageData():encode('png'):getString());f:close()
  for _,size in ipairs({{774,232},{960,192},{304,40},{160,48},{390,117}})do
    local target=G.newCanvas(size[1],size[2]);G.setCanvas(target);G.clear(0,0,0,0)
    assert(panels.draw(battle,{x=0,y=0,w=size[1],h=size[2]},{}));G.setCanvas()
  end


  -- Prove the selected menu adapter cannot corrupt the imported battle face.
  local themeFont=assert(loadstring(mod:read('lib/emerald_theme.lua')))()(setmetatable({assets={image=function(_,p)local img=G.newImage(love.filesystem.newFileData(assert(read(w..'MenuCustomizer/'..p)),'font.png'));img:setFilter('nearest','nearest');return img end}},{__index=mod}),function()return true end)
  mod.exports.gbMenus={theme=themeFont}
  local correct=assert(Sandbox.compile(mod:read('lib/emerald_native.lua'),'@battle-font-regression',env))()(mod)
  correct.selectedFont={draw=function()error('menu adapter used for Emerald battle')end,measure=function()error('menu adapter measured Emerald battle')end,drawGlyph=function()error('menu adapter used for battle glyph')end}
  correct.useEmeraldFont=function()return true end
  assert(correct.ready())
  local ui={nativeEmerald=correct,emeraldFont=function()return true end,setting=function(k)return k=='style' and 3 or 100 end,faded=function(fn)return fn()end,panel=function(x,y,width,height)return borders.drawBattlePixels(x,y,width,height)end}
  local moves=assert(loadstring(mod:read('lib/battle_move_screen.lua')))()({find=function()return {exports=ui}end})
  local shots={{'dialogue',function()
    assert(correct.bottom({phase='messages',shown={GBFont.encode('Wild KRICKETUNE'),GBFont.encode('appeared!')}},1,{x=136,y=496,w=774,h=232},ui))
  end},{'moves',function()assert(moves.draw(battle,{x=136,y=496,w=774,h=232},{}))end}}
  for _,shot in ipairs(shots)do
    local c=G.newCanvas(1047,729);G.setCanvas(c);G.clear(.2,.48,.2,1)
    shot[2]();G.setCanvas()
    local f=assert(io.open(w..'.work/menu-battle-font/'..shot[1]..'.png','wb'));f:write(c:newImageData():encode('png'):getString());f:close()
  end

  -- Exercise cached assets inside a strict per-generation require boundary.
  for _,game in ipairs({'red','blue','yellow','gold','silver','crystal'})do
    GV.set(game)
    mod.generation=GV.generation()
    local gbEnv=Sandbox.envFor({modId='gen3transparency',permissions={engine_internals=true}})
    local originalRequire=gbEnv.require
    gbEnv.require=function(name)
      assert(not name:match('^src%.core%.game3') and not name:match('^src%.ui%.game3'), 'cross-generation require: '..name)
      return originalRequire(name)
    end
    local oldSource=mod:read('lib/emerald_native.lua'):gsub("    if %(mod.generation or require%('src.core.GameVersion'%).generation%(%)%) ~= 3 then return false end",'')
    local oldPort=assert(Sandbox.compile(oldSource,'@previous-'..game,gbEnv))()(mod)
    local oldOk,oldError=pcall(oldPort.ready)
    assert(not oldOk and tostring(oldError):find('cross-generation require',1,true),'previous crash must reproduce: '..game)
    local gbPort=assert(Sandbox.compile(mod:read('lib/emerald_native.lua'),'@cached-'..game,gbEnv))()(mod)
    gbPort.useEmeraldFont=function()return true end
    assert(not gbPort.ready() and gbPort.presentationReady(),game..' must use portable fonts with cache present')
    assert(not gbPort.hud(battle,mod.generation,'player'),game..' must retain generation-native HUD')
    local gbUI={nativeEmerald=gbPort,emeraldFont=ui.emeraldFont,setting=ui.setting,faded=ui.faded,panel=ui.panel}
    local gbMoves=assert(loadstring(mod:read('lib/battle_move_screen.lua')))()({find=function()return {exports=gbUI}end})
    local gbBattle=mod.generation==2 and {phase='resolving',messageLines=function()return {'Wild KRICKETUNE','appeared!'}end,messageArrowVisible=function()return true end} or {phase='messages',shown={GBFont.encode('Wild KRICKETUNE'),GBFont.encode('appeared!')}}
    local canvas=G.newCanvas(1047,729);G.setCanvas(canvas);G.clear(.2,.48,.2,1)
    assert(gbPort.bottom(gbBattle,mod.generation,{x=136,y=496,w=774,h=232},gbUI))
    G.setCanvas();G.setCanvas(canvas);assert(gbMoves.draw(battle,{x=136,y=496,w=774,h=232},{}));G.setCanvas()
  end
  GV.set('ruby');mod.generation=3
  local cache=require('src.import.CacheFs');local previousRead=cache.readAt
  cache.readAt=function()end
  local offline=assert(Sandbox.compile(mod:read('lib/emerald_native.lua'),'@offline-battle-font',env))()(mod)
  offline.useEmeraldFont=function()return true end
  assert(not offline.ready() and offline.presentationReady(),'bundled battle font needs no Emerald cache')
  local offlineUI={nativeEmerald=offline,emeraldFont=ui.emeraldFont,setting=ui.setting,faded=ui.faded,panel=ui.panel}
  local offlineMoves=assert(loadstring(mod:read('lib/battle_move_screen.lua')))()({find=function()return {exports=offlineUI}end})
  local c=G.newCanvas(1047,729);G.setCanvas(c);G.clear(.2,.48,.2,1)
  assert(offline.bottom({phase='messages',shown={GBFont.encode('Wild KRICKETUNE'),GBFont.encode('appeared!')}},1,{x=136,y=496,w=774,h=232},offlineUI))
  G.setCanvas();local f=assert(io.open(w..'.work/menu-battle-font/offline-dialogue.png','wb'));f:write(c:newImageData():encode('png'):getString());f:close()
  G.setCanvas(c);G.clear(.2,.48,.2,1);assert(offlineMoves.draw(battle,{x=136,y=496,w=774,h=232},{}));G.setCanvas()
  f=assert(io.open(w..'.work/menu-battle-font/offline-moves.png','wb'));f:write(c:newImageData():encode('png'):getString());f:close()
  cache.readAt=previousRead
  -- Bundled normal/narrow masks must match the actual extraction pixel for pixel.
  for _,face in ipairs({'normal','narrow'})do for _,layer in ipairs({'fg','shadow'})do
    local raw=assert(require('src.import.CacheFs').readAt('emerald/data/generated/gba/chrome/fonts/latin_'..face..'_'..layer..'.rgba'))
    local image=G.newImage(love.filesystem.newFileData(assert(read(w..'MenuCustomizer/assets/emerald/battle_'..face..'_'..layer..'.png')),'font.png'))
    local data=love.image.newImageData(love.filesystem.newFileData(assert(read(w..'MenuCustomizer/assets/emerald/battle_'..face..'_'..layer..'.png')),'font.png'))
    assert(data:getString()==raw,'bundled font differs from original Emerald extraction')
  end end
  local passed=pcall(port.scope,function()error('intentional')end);assert(not passed);assert(F.draw==fd and C.drawPanel==cp and P.forSession==pf)
 end,debug.traceback)
 local f=assert(io.open(w..'.work/menu-battle-font/result.txt','w'));f:write(ok and 'PASS' or err);f:close();love.event.quit()
end
