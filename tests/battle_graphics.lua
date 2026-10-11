local root=assert(os.getenv('BATTLE_UI_WORKSPACE'),'set BATTLE_UI_WORKSPACE to the workspace with BattleUICustomizer and engine fixtures')..'/'
local function read(p) local f=assert(io.open(root..p,'rb')); local s=f:read('*a');f:close();return s end
local function run()
 local G=love.graphics
 local data=love.image.newImageData(1,1); data:setPixel(0,0,1,1,1,1)
 local pixel=G.newImage(data)
 local function ink(x,y) G.setColor(0,0,0,1);G.draw(pixel,x,y,0,4,4) end
 local target=G.newCanvas(1024,640,{dpiscale=1,format='rgba8'})
 local tint=G.newShader('vec4 effect(vec4 c, Image t, vec2 uv, vec2 p) { return vec4(0.8,0.0,0.9,1.0)*Texel(t,uv)*c; }')
 local tests=0
 for generation=1,3 do
  for style=1,2 do
   local settings={style=style,opacity=50}
   local Font={BORDER={h=1,br=2}}
   local textLog={}
   local previewFont
   Font.width=function(text)return previewFont and previewFont.width(text) or #text*8 end
   Font.drawCode=function(c,x,y) if previewFont then return previewFont.drawCode(c,x,y) end;ink(x,y) end
   Font.draw=function(text,x,y) textLog[#textLog+1]=text;if previewFont then return previewFont.draw(text,x,y) end;Font.drawCode(0,x,y)end
   Font.drawBox=function(x,y,w,h)
    if previewFont then return previewFont.drawBox(x,y,w,h) end
    G.setColor(.3,.4,.5,1);G.rectangle('fill',x*8,y*8,w*8,h*8)
    G.setColor(.8,.8,.8,1);G.rectangle('fill',x*8+2,y*8+2,w*8-4,h*8-4)
    G.setColor(1,1,1,1);G.rectangle('fill',x*8+4,y*8+4,w*8-8,h*8-8)
   end
   local Chrome={box=Font.drawBox}
   local B={drawPicsLayer=function(self,slide,sx,sy,side,skip)return skip end}
   if generation==1 then
    local battleSource=read('gen1recomp-0.3.54/src/battle/BattleState.lua')
    local zoneTable=assert(battleSource:match('(local BATTLE_ZONES%s*=%s*{.-)\n}'))..'\n}\n'
    local native=assert(battleSource:match('(function BattleState:drawZonePass.-)\nend\n'))..'\nend\n'
    B.drawZonePass=assert(loadstring('local BattleState={}\n'..zoneTable..native..'\nreturn BattleState.drawZonePass'))()
    local pics=assert(battleSource:match('(function BattleState:drawPicsLayer.-)\nend\n'))..'\nend\n'
    local context='local BattleState={resolveBattleScale=function()return 1 end,backPlacement=function()return 20,80 end};local imagePadBottom,imagePadLeft={},{};local function imagePathOf()end;\n'
    B.drawPicsLayer=assert(loadstring(context..pics..'return BattleState.drawPicsLayer'))()

   end
   local method=generation==2 and 'drawBottom' or 'drawTextArea'
   B[method]=function(self)
    local box=generation==2 and Chrome.box or Font.drawBox
    box(0,12,20,6)
    if self.phase=='menu' then box(8,12,12,6); Font.draw('FIGHT',80,112)
    else
     box(0,8,11,5);box(4,12,16,6)
     G.setColor(1,1,1,1);G.rectangle('fill',32,96,8,8)
     Font.drawCode(Font.BORDER.h,32,96)
     Font.draw('MOVE',48,112)
     if self.phase=='messages' then Font.drawCode(0xEE,144,136)end
    end
   end
   local Wide={draw=function(self)
    if self.phase=='menu' then Font.drawBox(0,13,20,5);Font.drawBox(20,13,18,5);Font.draw('FIGHT',176,112)
    else Font.drawBox(0,13,28,5);Font.drawBox(28,13,10,5);Font.draw('MOVE',16,112);Font.draw('PP',232,112)end
   end}
   local C={drawPanel=function() Font.drawBox(0,14,30,6);Font.drawBox(16,14,14,6) end,
    drawMenuFrames=function() Font.drawBox(16,14,14,6) end}
   for _,n in ipairs({'drawEnemyBox','drawPlayerBox','drawDoublesBox','drawSafariBox'}) do C[n]=function() return true end end
   package.loaded['src.render.Font']=Font
   package.loaded['src.ui.gen2.Chrome']=Chrome
   package.loaded['src.battle.BattleState']=B
   package.loaded['src.ui.gen2.BattleState']=B
   package.loaded['src.battle.WideBattle']=Wide
   package.loaded['src.ui.game3.battle_chrome']=C
   package.loaded['src.core.game3.battle.ui']={draw=function()
    C.drawPanel('menu');C.drawMenuFrames('menu')
    local F=package.loaded['src.ui.game3.frlg_font']
    F.draw('prompt',10,122)
    package.loaded['src.ui.game3.window'].cursorPx(128,122)
    for _,pos in ipairs({{136,122},{192,122},{136,138},{192,138}})do F.draw('label',pos[1],pos[2])end
   end}
   package.loaded['src.ui.game3.frlg_font']={draw=function(text,x,y)ink(x,y)end}
   package.loaded['src.ui.game3.window']={cursorPx=function(x,y)ink(x,y)end}
   package.loaded['src.ui.game3.rs.menu_cursor']={draw=function(x,y)ink(x,y)end}
   package.loaded['src.ui.game3.option_rows']={build=function()return {} end}
   package.loaded['src.import.CacheFs']={readAt=function()end}
   local marks={}
   local Palette={honorsTrueColor=function() return false end,
    markTrueColor=function(x,y,w,h) marks[#marks+1]={x,y,w,h} end}
   Palette.mode='sgb';Palette.shader=function()return tint end
   Palette.forcesRawGrays=function()return false end
   Palette.permute=function(p)return p end
   Palette.sendColors=function()end;Palette.sendShades=function()end
   package.loaded['src.render.PaletteFX']=Palette
   local output=G.newCanvas(1024,640,{dpiscale=1,format='rgba8'})
   local rendererSource=read('gen1recomp-0.3.54/src/render/Renderer.lua')
   local scissor=assert(rendererSource:match('(local function scissorClamped.-)\nend\n'))..'\nend\n'
   local nativeBlit=assert(rendererSource:match('(function Renderer:blitCanvas.-)\nend\n'))..'\nend\n'
   local NativePalette={shader=function()return tint end,sendColors=function()end}
   local Renderer=assert(loadstring('local PaletteFX,SCISSOR_PIXEL_BIAS=...;local Renderer={}\n'..scissor..nativeBlit..'\nreturn Renderer'))(NativePalette,0)
   Renderer.beginFrame=function()end
   Renderer.endFrame=function(self)
    G.push('all');G.setCanvas(output);G.origin();G.setScissor();G.clear(0,0,0,0)
    G.setBlendMode('alpha','premultiplied');G.setColor(1,1,1,1)
    self:blitCanvas(target,1,1,{{colors={},x=0,y=0,w=1024,h=512}},1,1,0,0,0,0,1024,512,1,1)
    G.pop()
   end
   package.loaded['src.render.Renderer']=Renderer
   local Runtime={hooks={chains={}}};package.loaded['src.mods.Runtime']=Runtime
   local mod={id='gen3transparency',generation=generation,options={get=function(_,k)return settings[k:gsub("^battle_","")]end},save={get=function()return nil end}}
   mod.exports={borders={drawPixels=function()return false end}};mod.events={on=function()end};mod.find=function()end
   package.loaded['src.battle.TypeChart']={displayName=function(t)return t end}
   mod.read=function(_,p)return read('MenuCustomizer/'..p)end
   mod.hooks={wrap=function(_,name,cb)Runtime.hooks.chains[name]={{owner=mod.id,callback=cb}}end}
   assert(loadstring(read('MenuCustomizer/lib/battle_ui.lua')))()(mod)
   if generation==1 then
    local spriteState={phase='moveSelect',player={sprite=pixel},bottomUIVisible=function()return true end,fxHidden=function()return false end,picImage=function()return pixel end,growInScale=function()end,shrinkOutScale=function()end,picOffset=function()return 0 end,drawBattlerPic=function()G.setColor(1,1,1,1);G.draw(pixel,20,80,0,16,16)end}
    G.setCanvas(target);G.origin();G.setShader();G.setScissor();G.clear(0,0,0,0)
    B.drawPicsLayer(spriteState,0,0,0,'player',false);G.setCanvas()
    assert(select(4,target:newImageData():getPixel(25,90))>.99,'actual engine drawPicsLayer keeps lower player pixels')
    spriteState.phase='mimicSelect'
    G.setCanvas(target);G.clear(0,0,0,0);B.drawPicsLayer(spriteState,0,0,0,'player',false);G.setCanvas()
    assert(select(4,target:newImageData():getPixel(25,90))==0,'unmodified Mimic retains original clipping')
    tests=tests+2
   end
   for _,phase in ipairs({'menu'}) do
    for _,scale in ipairs({1,2}) do
     Renderer:beginFrame()
     G.setCanvas(target);G.origin();G.setShader();G.setScissor();G.clear(0,0,0,0)
     G.translate(3,5);G.scale(scale);G.setShader(tint)
     if generation==3 then C.drawPanel(phase);C.drawMenuFrames(phase)
     else B[method]({phase=generation==1 and phase=='moves' and 'moveSelect' or phase}) end
     assert(G.getShader()==tint,'caller shader restored')
     G.setCanvas();G.setShader();G.origin()
     local image=target:newImageData()
     local function alpha(x,y) local r,g,b,a=image:getPixel(3+x*scale,5+y*scale);return a,r,g,b end
     local a=alpha(generation==3 and 140 or 100, generation==3 and 140 or 135)
     assert(math.abs(a-.5)<.01,'panel alpha must be 0.5, got '..a)
     if generation<3 then
      if phase=='menu' then assert(alpha(4,110)==0,'unused left box removed')
      else
       assert(math.abs(alpha(50,98)-.5)<.01,'overlap and border patch opacity uniform')
       assert(alpha(4,98)==0,'orphan move-info bottom border removed')
      end
      assert(alpha(phase=='menu' and 80 or 48,112)>.99,'text stays opaque')
     end
     if generation<3 then
      Renderer:endFrame()
      local shown=output:newImageData()
      local x,y=3+100*scale,5+135*scale
      local r,g,b,a=image:getPixel(x,y)
      local rr,gg,bb,aa=shown:getPixel(x,y)
      assert(math.abs(r-rr)<.01 and math.abs(g-gg)<.01 and math.abs(b-bb)<.01 and math.abs(a-aa)<.01,
       'translated/scaled landscape panel must survive final palette blit')
      tests=tests+1
     end
     tests=tests+1
    end
   end
   if generation<3 then
    marks={}
    G.setCanvas(target);G.origin();G.setShader();G.clear(0,0,0,0)
    B[method]({phase='menu'})
    G.setCanvas()
    local before=target:newImageData()
    Renderer:endFrame()
    local after=output:newImageData()
    local r,g,b,a=before:getPixel(100,135)
    local rr,gg,bb,aa=after:getPixel(100,135)
    assert(math.abs(r-rr)<.01 and math.abs(g-gg)<.01 and math.abs(b-bb)<.01 and math.abs(a-aa)<.01,
      'final palette pass must preserve panel color and opacity')
    Renderer:beginFrame()
    Renderer:endFrame()
    local reset=output:newImageData();local _,gg=reset:getPixel(100,135)
    assert(gg<.01,'panel protections expire at beginFrame')
    tests=tests+1
   end
   if generation==1 then
    for _,shake in ipairs({0,2}) do
     Renderer:beginFrame()
     G.setCanvas(target);G.origin();G.setShader();G.setScissor();G.clear(0,0,0,0)
     G.setColor(1,1,1,1);G.rectangle('fill',20,20,4,4)
     B[method]({phase='menu'})
     G.setCanvas()
     local before=target:newImageData()
     G.setCanvas(output);G.clear(0,0,0,0)
     B.drawZonePass({sgbBattlePals=function()return {[0]={},[1]={},[2]={},[3]={}}end,
       activeBgp=function()return 228 end},target,shake,shake)
     G.setCanvas();G.setShader();G.setScissor()
     local after=output:newImageData()
     local r,g,b,a=before:getPixel(100,135)
     local rr,gg,bb,aa=after:getPixel(100+shake,135+shake)
     assert(math.abs(r-rr)<.01 and math.abs(g-gg)<.01 and math.abs(b-bb)<.01 and math.abs(a-aa)<.01,
       'actual Gen 1 zone pass: style '..style..' shake '..shake..' expected '..r..','..g..','..b..','..a..' got '..rr..','..gg..','..bb..','..aa)
     local fr,fg,fb=after:getPixel(20+shake,20+shake)
     assert(fr>.7 and fg<.01 and fb>.8,'native field palette remains active')
     tests=tests+1
    end
    G.setCanvas(target);G.origin();G.clear(0,0,0,0);G.setShader(tint)
    Wide.draw({phase='menu'});assert(G.getShader()==tint)
    G.setCanvas();G.setShader()
    local im=target:newImageData();local r,g,b,a=im:getPixel(20,120)
    assert(a==0,'unused wide prompt panel removed')
    local r,g,b,a=im:getPixel(200,135);assert(math.abs(a-.5)<.01 and g>.1,'wide command panel avoids inherited palette shader')
    tests=tests+1
   end
   -- Verify panel geometry separately from unstretched text and cursor pixels.
   for _,view in ipairs({'classic','wide'})do
    if view=='classic' or generation==1 then
     for _,phase in ipairs({'menu'})do
      if generation<3 or phase=='menu' then
       local sourceX= generation==3 and 120 or view=='wide' and (phase=='menu' and 160 or 0) or phase=='menu' and 64 or 32
       local sourceW= generation==3 and 120 or view=='wide' and (phase=='menu' and 144 or 224) or phase=='menu' and 96 or 128
       local total= generation==3 and 240 or view=='wide' and (phase=='menu' and 304 or 224) or 160
       for stretch=0,1 do for align=0,2 do for _,scale in ipairs({1,2})do
        settings.menu_stretch,settings.menu_align=stretch,align
        local dest,sx=mod.exports.battleUi.placement(sourceX,sourceW,total)
        local width=sourceW*sx
        Renderer:beginFrame()
        G.setCanvas(target);G.origin();G.setScissor();G.setShader(tint);G.clear(0,0,0,0)
        G.translate(3,5);G.scale(scale)
        if generation==3 then package.loaded['src.core.game3.battle.ui'].draw()
        elseif view=='wide' then Wide.draw({phase=phase=='moves' and 'moveSelect' or phase})
        else B[method]({phase=generation==1 and phase=='moves' and 'moveSelect' or phase})end
        assert(G.getShader()==tint,'placement restores shader')
        G.setCanvas();G.setShader();G.origin()
        local im=target:newImageData()
        local function pixel(x,y)return im:getPixel(3+math.floor(x*scale),5+y*scale)end
        local r,g,b,a=pixel(dest+width/2,142)
        assert(math.abs(a-.5)<.01,'placed menu alpha '..generation..view..phase..stretch..align..': '..a)
        if dest>0 then assert(select(4,pixel(dest-2,142))==0,'left gap stays clear')end
        if dest+width<total then assert(select(4,pixel(dest+width+2,142))==0,'right gap stays clear')end
        local textX=generation==3 and 136 or view=='wide' and (phase=='menu' and 176 or 16) or phase=='menu' and 80 or 48
        local textY=generation==3 and 122 or 112
        local columns=(phase=='menu' or view=='wide') and 2 or 1
        if phase=='menu' then columns=2 end
        local expected=dest+(textX-sourceX)+(width-sourceW)*.5/columns
        assert(select(4,pixel(expected+1,textY+1))>.99,'labels follow translation')
        assert(select(4,pixel(expected+3,textY+1))>.99,'text retains original width')
        assert(select(4,pixel(expected+4,textY+1))<.6,'text must not stretch horizontally')
        if generation<3 then
         Renderer:endFrame();local after=output:newImageData()
         local rr,gg,bb,aa=after:getPixel(3+math.floor((dest+width/2)*scale),5+142*scale)
         assert(math.abs(r-rr)<.01 and math.abs(g-gg)<.01 and math.abs(b-bb)<.01 and math.abs(a-aa)<.01,'placed menu survives palette compositor')
        end
        tests=tests+1
       end end end
      end
     end
    end
   end

   if generation<3 then
    G.setCanvas(target);G.origin();G.setShader();G.setScissor();G.clear()
    B[method]({phase='messages'});G.setCanvas()
    local im=target:newImageData()
    local r,g,b,a=im:getPixel(49,109)
    assert(r<.01 and g<.01 and b<.01 and a>.99,'message text lifted four native pixels')
    r,g,b,a=im:getPixel(145,137)
    assert(r<.01 and g<.01 and b<.01 and a>.99,'continue arrow retains original position')
    tests=tests+2
   end
   if generation<3 then
    package.loaded['src.battle.TypeChart']={displayName=function(t)return t end}
    package.loaded['src.battle.gen2.Mon']={maxPpOf=function(move,data)return data.moves[move.id].pp+(move.ppUps or 0)*3 end}
    local defs={SURF={name='SURF',type='WATER',pp=15},HORN={name='HORN ATTACK',type='NORMAL',pp=25},POISON={name='POISON STING',type='POISON',pp=35},SEISMIC={name='SEISMIC TOSS',type='FIGHTING',pp=20}}
    local moves={{id='SURF',pp=12,ppUps=2},{id='HORN',pp=0},{id='POISON',pp=20},{id='SEISMIC',pp=19}}
    local function state()
     return {phase=generation==1 and 'moveSelect' or 'moves',data={moves=defs},game={data={moves=defs}},player={curMoves=moves},playerMoves=function()return moves end,moveIndex=1}
    end
    for _,view in ipairs(generation==1 and {'classic','wide'} or {'classic'}) do
     for stretch=0,1 do for align=0,2 do for _,opacity in ipairs({0,50,100}) do
      settings.menu_stretch,settings.menu_align,settings.opacity=stretch,align,opacity
      Renderer:beginFrame()
      G.setCanvas(target);G.origin();G.setScissor();G.setShader(tint);G.clear(0,0,0,0)
      local st=state()
      if view=='wide' then Wide.draw(st) else B[method](st) end
      assert(G.getShader()==tint,'moves restore inherited palette')
      G.setCanvas();G.setShader()
      local im=target:newImageData()
      local total=view=='wide' and 304 or 160
      local width=(view=='wide' or stretch==1) and total or 128
      local x=(total-width)*align/2
      local y=view=='wide' and 104 or 96
      assert(select(4,im:getPixel(40,80))==0,'old type overlay leaves no pixels over player')
      assert(math.abs(select(4,im:getPixel(x+width-20,140))-opacity/100)<.01,'inset opacity is applied once')
      assert(math.abs(select(4,im:getPixel(x+20,140))-opacity/100)<.01,'outer and inset use uniform opacity')
      local cursorX=x+13*width/336;local textX=x+22*width/336
      local baseline=y+11*(view=='wide' and 40 or 48)/64
      assert(select(4,im:getPixel(math.ceil(cursorX),math.ceil(baseline)))>.99,'selection cursor remains opaque '..generation..'/'..style..'/'..view..'/'..stretch..'/'..align..'/'..opacity..' at '..cursorX..','..baseline)
      assert(select(4,im:getPixel(math.ceil(textX),math.ceil(baseline)))>.99,'move name remains opaque')
      if view=='classic' and x>0 then assert(select(4,im:getPixel(x-2,120))==0,'unused space is fully clear')end
      Renderer:endFrame();local after=output:newImageData()
      local r,g,b,a=im:getPixel(x+20,140);local rr,gg,bb,aa=after:getPixel(x+20,140)
      assert(math.abs(r-rr)<.01 and math.abs(g-gg)<.01 and math.abs(b-bb)<.01 and math.abs(a-aa)<.01,'move surface preserves color in final palette pass')
      tests=tests+1
     end end end
    end

    for index=1,4 do
     textLog={};local st=state();st.moveIndex=index
     G.setCanvas(target);G.origin();G.setShader();G.setScissor()
     B[method](st);G.setCanvas()
     local text=table.concat(textLog,'|')
     local expected=({'12/21','0/25','20/35','19/20'})[index]
     assert(text:find(expected,1,true),'selected PP and PP Ups '..expected)
     assert(text:find(defs[moves[index].id].type,1,true),'selected move type')
     tests=tests+1
    end
    textLog={};local st=state();st.player.disabledSlot=1
    if generation==2 then st.battle={player=st.player,moveDisabled=function()return true end}end
    G.setCanvas(target);B[method](st);G.setCanvas()
    assert(table.concat(textLog,'|'):find('DISABLED',1,true),'disabled selection indicated');tests=tests+1
    -- Render actual extracted Blue glyphs for visual review, without shipping ROM assets.
    if generation==1 and os.getenv('BATTLE_UI_BLUE_CACHE') then
     local save=os.getenv('BATTLE_UI_BLUE_CACHE')..'/'
     local function saved(path)local f=assert(io.open(save..path,'rb'));local b=f:read('*a');f:close();return b end
     package.loaded['src.render.Assets']={register=function()end,image=function(path)
      local img=G.newImage(love.filesystem.newFileData(saved(path),path));img:setFilter('nearest','nearest');return img
     end}
     previewFont=assert(loadstring(read('.tools/engine-0358/src/render/Font.lua')))()
     previewFont.load({font=assert(loadstring(saved('data/generated/font.lua')))()})
     settings.opacity=50;settings.menu_stretch=0;settings.menu_align=2
     G.setCanvas(target);G.origin();G.setScissor();G.setShader();G.clear(.2,.48,.2,1)
     G.scale(4);B[method](state());G.setCanvas();G.origin()
     local bytes=target:newImageData():encode('png'):getString();local f=assert(io.open(root..'Battle-UI-Customizer-v1.0.7-preview-'..style..'.png','wb'));f:write(bytes);f:close();previewFont=nil
    end
    settings.opacity=50
   end

   settings.menu_stretch,settings.menu_align=0,2
   G.setCanvas(target);G.origin();G.setShader(tint)
   local ok=pcall(mod.exports.battleUi.faded,function()error('expected')end)
   assert(not ok and G.getCanvas()==target and G.getShader()==tint,'error restores graphics state')
   G.setCanvas();G.setShader()
  end
 end
 return 'PASS '..tests..' real LÃ–VE pixel cases: uniform alpha, removed boxes, native border cleanup, opaque text, landscape palette, restored state.'
end
function love.load()
 local ok,result=pcall(run)
 local f=assert(io.open(root..'.work/menu-battle-merge/native-gpu-result.txt','w'));f:write(ok and result or ('FAIL '..tostring(result)));f:close()
 love.graphics.setCanvas();love.graphics.setShader();love.event.quit(ok and 0 or 1)
end


