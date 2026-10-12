local root=(os.getenv('BATTLE_UI_WORKSPACE')or'C:/Users/LSDMTHC/Desktop/Hoennto'):gsub('/$','')..'/'
local output=root..'.work/pokemon-paper/'
local function read(p)local f=assert(io.open(root..'MenuCustomizer/'..p,'rb'));local s=f:read('*a');f:close();return s end
local function write(p,s)local f=assert(io.open(output..p,'wb'));f:write(s);f:close()end
package.path=root..'.tools/engine-0358/?.lua;'..package.path
function love.load()
 local ok,err=xpcall(function()
  local G=love.graphics;local checks=0;local choices={};local clock=0
  local function check(v,m)checks=checks+1;assert(v,m)end
  local GV=require('src.core.GameVersion');GV.set('blue')
  local mod={generation=1,exports={},read=function(_,p)return read(p)end,options={get=function(_,k)return choices[k]end},save={get=function()end},
   assets={image=function(_,p)return G.newImage(love.filesystem.newFileData(read(p),p))end}}
  local P=assert(loadstring(read('lib/battle_text_palette.lua')))()(mod)
  local catalog=assert(loadstring(read('lib/border_catalog.lua')))();local selection=13
  local B=assert(loadstring(read('lib/menu_borders.lua')))()(mod,function(k)return k=='menuBorder'and selection or 2 end,catalog,function()return true end)
  local T=assert(loadstring(read('lib/emerald_theme.lua')))()(mod,function()return true end)
  local oldTime=love.timer.getTime;love.timer.getTime=function()return clock end
  local function canvas(w,h,dpi,fn)
   local c=G.newCanvas(w,h,{dpiscale=dpi or 1});G.push('all');G.setCanvas(c);G.origin();G.setShader();G.setScissor();G.clear(0,0,0,0);fn();G.pop();return c
  end
  local function panel(e,time)
   clock=time;return canvas(240,80,1,function()B.drawPixels(0,0,240,80,P.pokemonBackgrounds.color(e.key))end)
  end
  local groups,names=P.groups('background');local group
  for _,g in ipairs(groups)do if g.label=='POKEMON'then group=g end end
  check(group and #group.ids==14,'Pokemon chooser group incomplete')
  local hashes={};local gallery=canvas(1000,1100,1,function()G.clear(.045,.06,.085,1)end)
  local gallery2=canvas(1000,1100,1,function()G.clear(.045,.06,.085,1)end)
  local static=canvas(240,80,1,function()B.drawPixels(0,0,240,80,{1,1,1,1})end):newImageData()
  local blackPaper=canvas(240,80,1,function()B.drawPixels(0,0,240,80,{0,0,0,1})end):newImageData()
  for i,e in ipairs(P.pokemonBackgrounds.entries)do
   local colour=P.pokemonBackgrounds.color(e.key);check(colour.pokemon==e.key and colour.animation=='POKEMON','theme metadata')
   local id;for n,name in ipairs(P.backgroundNames)do if name==e.name then id=n-1 end end
   check(id~=nil and names[group.ids[i]+1]==e.name,'theme not reachable in favorite-first order')
   choices.battle_background_color=id;choices.menuBackgroundColor=id+1;choices.startMenuBackgroundColor=0
   check(P.background().pokemon==e.key and P.background()._kind=='battle','battle chooser lost theme')
   check(P.menuBackground('other').pokemon==e.key and P.menuBackground('start').pokemon==e.key,'menu/start inheritance lost')
   choices.startMenuBackgroundColor=1
   check(not P.menuBackground('start').pokemon and P.menuBackground('other').pokemon==e.key,'separate start background lost')
   choices.startMenuBackgroundColor=0;choices.menu_fx_speed=100
   local a=panel(e,0);local b=panel(e,3);local bytes=a:newImageData():getString();local later=b:newImageData():getString()
   check(bytes~=later,'theme does not animate '..e.name);check(not hashes[bytes],'duplicate theme '..e.name);hashes[bytes]=true
   choices.menu_fx_speed=50;local slow=panel(e,6)
   check(slow:newImageData():getString()==later,'color speed ignored '..e.name);slow:release();choices.menu_fx_speed=100
   local d=a:newImageData();local dark=(e.baseA[1]+e.baseA[2]+e.baseA[3])/3<.4
   local function luminance(r,g,b)
    local function lin(c)return c<=.04045 and c/12.92 or ((c+.055)/1.055)^2.4 end
    return .2126*lin(r)+.7152*lin(g)+.0722*lin(b)
   end
   for yy=9,70 do for xx=9,230 do
    local r,g,b,alpha=d:getPixel(xx,yy);check(alpha==1,'transparent hole in themed paper '..e.name)
    local l=luminance(r,g,b);local contrast=dark and 1.05/(l+.05)or(l+.05)/.05
    check(contrast>=4.5,'theme too busy for matching text colour '..e.name)
   end end
   for yy=0,79 do for xx=0,239 do
    if xx<3 or yy<3 or xx>=237 or yy>=77 then
     local r,g,b,alpha=d:getPixel(xx,yy);local rr,gg,bb,aa=static:getPixel(xx,yy)
     local br,bg,bb2,ba=blackPaper:getPixel(xx,yy)
     if br==rr and bg==gg and bb2==bb and ba==aa then check(r==rr and g==gg and b==bb and alpha==aa,'theme leaked onto frame '..e.name)end
    end
   end end
   -- Rectangle/fill path used by the alternate battle UI skins, including DPI.
   clock=3;local flat=canvas(240,80,1,function()P.paint(colour,G.rectangle,'fill',0,0,240,80)end)
   local pixel=flat:newImageData();local rim=b:newImageData()
   for _,p in ipairs({{12,12},{90,25},{160,60},{228,68}})do
    local r,g,b,a=pixel:getPixel(p[1],p[2]);local rr,gg,bb,aa=rim:getPixel(p[1],p[2])
    check(math.abs(r-rr)<.005 and math.abs(g-gg)<.005 and math.abs(b-bb)<.005 and a==aa,'fill and framed themes differ '..e.name)
   end
   local high=canvas(240,80,3,function()P.paint(colour,G.rectangle,'fill',0,0,240,80)end):newImageData()
   for _,p in ipairs({{12,12},{90,25},{160,60},{228,68}})do
    local r,g,b,a=pixel:getPixel(p[1],p[2]);local rr,gg,bb,aa=high:getPixel(p[1]*3+1,p[2]*3+1)
    check(r==rr and g==gg and b==bb and a==aa,'high DPI changes theme density '..e.name)
   end
   -- Actual selected menu font over animated Pokémon paper.
   for j,target in ipairs({gallery,gallery2})do
    clock=j==1 and 0 or 3
    local c=canvas(240,128,1,function()B.drawPixels(0,0,240,128,colour)end)
    local x=8+(i-1)%3*330;local y=12+math.floor((i-1)/3)*218
    G.push('all');G.setCanvas(target);G.origin();G.setShader();G.setColor(.85,.91,.97,1);G.print(e.name,x+4,y)
    G.setBlendMode('alpha','premultiplied');G.setColor(1,1,1,1);G.draw(c,x,y+27,0,1.3,1.3)
    G.setBlendMode('alpha','alphamultiply');G.translate(x+22,y+50);G.scale(2,2)
    local ink=dark and{1,1,1,1}or{.04,.05,.08,1}
    T.draw('FIGHT      BAG',0,0,{colors={fg=ink,shadow={0,0,0,0}}});T.draw('POKéMON    RUN',0,23,{colors={fg=ink,shadow={0,0,0,0}}});G.pop();c:release()
   end
   a:release();b:release();flat:release()
  end
  write('backgrounds.png',gallery:newImageData():encode('png'):getString());write('backgrounds-later.png',gallery2:newImageData():encode('png'):getString())
  -- Render isolated favorite previews large enough to inspect their animation.
  for _,e in ipairs({P.pokemonBackgrounds.entries[1],P.pokemonBackgrounds.entries[4]})do
   for frame=0,11 do
    clock=frame*.25;local c=canvas(720,240,1,function()G.scale(3,3);B.drawPixels(0,0,240,80,P.pokemonBackgrounds.color(e.key))end)
    write(e.key..'-'..frame..'.png',c:newImageData():encode('png'):getString());c:release()
   end
  end
  -- Selecting a normal paper after a Pokémon paper clears the shader state.
  local e=P.pokemonBackgrounds.entries[1]
  for id,name in ipairs(P.backgroundNames)do if name==e.name then choices.battle_background_color=id-1 end end
  choices.menu_fx_speed=25;choices.battle_fx_speed=50;clock=6
  local battleSlow=canvas(240,80,1,function()B.drawPixels(0,0,240,80,P.background())end)
  choices.battle_fx_speed=100;clock=3
  local battleFast=canvas(240,80,1,function()B.drawPixels(0,0,240,80,P.background())end)
  check(battleSlow:newImageData():getString()==battleFast:newImageData():getString(),'battle background ignores its independent color speed')
  battleSlow:release();battleFast:release();choices.menu_fx_speed=100
  clock=0;local original=canvas(240,80,1,function()B.drawPixels(0,0,240,80,{0,0,0,1})end)
  panel(P.pokemonBackgrounds.entries[1],2):release()
  local after=canvas(240,80,1,function()B.drawPixels(0,0,240,80,{0,0,0,1})end)
  check(original:newImageData():getString()==after:newImageData():getString(),'Pokemon theme state leaked into plain paper')
  love.timer.getTime=oldTime
  write('result.txt','PASS '..checks..' distinct animation, chooser, contrast, frame isolation, speed, DPI and state checks\n')
 end,debug.traceback)
 if not ok then write('result.txt','FAIL '..err)end;love.event.quit(ok and 0 or 1)
end
