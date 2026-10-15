local root=assert(os.getenv('MENU_WORKSPACE')):gsub('\\','/')
local version=os.getenv('MENU_GAME')or'firered'
local out=root..'/.work/battle-font-layout/gpu'
local source=root..'/.work/move-effects-audit/git-Menu-Customizer'
local engine=root..'/.work/moves-abilities/engine-0385'
local cache=assert(os.getenv('APPDATA')):gsub('\\','/')..'/pokemon-love2d'
local function read(p)local f=io.open(p,'rb');if not f then return end;local s=f:read('*a');f:close();return s end
local function write(p,s)local f=assert(io.open(out..'/'..p,'wb'));f:write(s);f:close()end
function love.load()
 local ok,err=xpcall(function()
  package.path=engine..'/?.lua;'..package.path
  local readFs,infoFs,loadFs=love.filesystem.read,love.filesystem.getInfo,love.filesystem.load
  local function host(p)if p:find('mods/menu/',1,true)==1 then return source..'/'..p:sub(11)end;return cache..'/'..version..'/'..p end
  love.filesystem.read=function(p,...)return read(host(p))or readFs(p,...)end
  love.filesystem.getInfo=function(p,...)local b=read(host(p));if b then return{type='file',size=#b}end;return infoFs(p,...)end
  love.filesystem.load=function(p,...)local b=read(host(p));if b then return loadstring(b,'@'..p)end;return loadFs(p,...)end
  local image=love.graphics.newImage
  love.graphics.newImage=function(p,...)if type(p)=='string'then local b=read(host(p));if b then p=love.filesystem.newFileData(b,p)end end;return image(p,...)end
  local GV=require('src.core.GameVersion');GV.set(version)
  local Blob=require('src.import.CacheBlob')
  local function cached(p)return Blob.decode(p,read(cache..'/'..version..'/'..p))end
  package.loaded['src.import.CacheFs']={loadActive=function(p)local b=cached(p);if b then return assert(loadstring(b))()end end,readActive=cached,read=cached,readAt=function(p)return cached(p)or Blob.decode(p,read(cache..'/'..p))end}
  local data=require('src.core.Data');data:load();if GV.generation()<3 then require('src.render.Font').load(data)end
  if GV.generation()==3 then
   local cv={read=function(_,p)return cached(p)end};require('src.core.game3.dataset').cache=function()return cv end
   local P=require('src.core.game3.pokemon');P.install(cv);require('src.core.game3.battle.moves').loadRomPack(cv)
  end
  local fs={}
  function fs.getInfo(p)if p=='mods'or p=='mods/menu'then return{type='directory'}end;if read(source..'/'..p:gsub('^mods/menu/',''))then return{type='file'}end end
  function fs.getDirectoryItems(p)if p=='mods'then return{'menu'}end;return{}end
  function fs.read(p)return read(source..'/'..p:gsub('^mods/menu/',''))end
  function fs.write()return true end;function fs.createDirectory()return true end
  function fs.load(p)return loadstring(fs.read(p))end
  local options={modOptions={gen3transparency={menuTheme=tonumber(os.getenv('MENU_FONT_THEME'))or 2,menuTransition=1,controlsLegend=3,opacityFormat=2,
   battle_style=3,battle_opacity=75,battle_background_color=5,battle_text_color=0,battle_font_size=0,battleBorderChoice=13,martCustom=1,martTheme=2,martBorderChoice=13,martBackgroundColor=10,martTextColor=0,martTextShadowColor=0,
   pcCustom=1,pcTheme=2,pcBorderChoice=13,pcBackgroundColor=6,pcTextColor=0,pcTextShadowColor=0,
   dialogueTheme=2,dialogueBorderChoice=13,dialogueBorder=1,dialogueBackgroundColor=10,dialogueTextColor=0}}}
  require('src.core.SaveData').loadOptions=function()return options end
  local Loader=require('src.mods.Loader');local loader=Loader.new{fs=fs,generation=GV.generation(),version=version,dev=false};loader:load(data)
  assert(loader.mods.gen3transparency.state=='loaded',table.concat(loader.errors,'\n'))
  local api=loader.exports.gen3transparency;local M=api.menuSurfaces
  local G=love.graphics;local game={data=data,options=options,mods=loader,save={money=9000,player={money=9000},inventory={},bagOrder={}},writeOptions=function()end}
  game.stack={states={},push=function(self,s)self.states[#self.states+1]=s end,pop=function(self)return table.remove(self.states)end,top=function(self)return self.states[#self.states]end}
  local function capture(name,fn)
   local original=G.draw;local trace={}
   G.draw=function(image,quad,...)
    if image.getWidth and image:getWidth()==256 and image:getHeight()==512 and #trace<100 then local x,y=G.transformPoint(0,0);local ex,ey=G.transformPoint(1,1);local qx,qy,qw,qh=quad:getViewport();trace[#trace+1]=table.concat({x,y,ex-x,ey-y,qx,qy,qw,qh},',')end
    return original(image,quad,...)
   end
   local canvas=G.newCanvas(1728,1296);G.setCanvas(canvas);G.origin();G.clear(.15,.2,.25,1)
   G.push('all');G.translate(0,0);G.scale(GV.generation()<3 and 4 or 3.5)
   fn();G.pop();loader.hooks:call('render.hud',function()end,game,{width=1728,height=1296,dpiX=1,dpiY=1});G.setCanvas();G.draw=original;write(version..'-'..name..'.trace',table.concat(trace,'\n'));write(version..'-'..name..'.png',canvas:newImageData():encode('png'):getString())
  end
  local battle={activeMon=function()return{name='SQUIRTLE'}end,phase='menu',menuIndex=2,moveIndex=2,player={name='SQUIRTLE',curMoves={{id='tackle',pp=25},{id='tailwhip',pp=30},{id='watergun',pp=25},{id='withdraw',pp=40}}},data={moves={tackle={name='TACKLE',pp=35,type='NORMAL'},tailwhip={name='TAIL WHIP',pp=30,type='NORMAL'},watergun={name='WATER GUN',pp=25,type='WATER'},withdraw={name='WITHDRAW',pp=40,type='WATER'}}}}
  local border;for id,e in ipairs(api.borderCatalog.entries)do if e.dsFrame then border=id;break end end
  options.modOptions.gen3transparency.battleBorderChoice=border
  options.modOptions.gen3transparency.battle_opacity=100
  local rect={x=0,y=896,w=800,h=200}

  local B=require('src.battle.BattleState')
  battle.data.moves.tailwhip.name='ANCIENT POWER';battle.data.moves.watergun.name='THUNDER PUNCH'
  assert(B.moveGridNavigation({wideLayout=function()return false end}),'Grid navigation remains disabled')
  local Wide=require('src.battle.WideBattle')
  for count=1,4 do for index=1,count do for _,key in ipairs({'left','right','up','down'})do
   local n=Wide.navigate(index,count,{wasPressed=function(_,k)return k==key end});assert(n and n>=1 and n<=count,'Grid direction selected an empty slot')
  end end end
  assert(Wide.navigate(1,4,{wasPressed=function(_,k)return k=='right'end})==2,'Right did not reach adjacent move')
  assert(Wide.navigate(2,4,{wasPressed=function(_,k)return k=='left'end})==1,'Left did not reach adjacent move')
  api.customization.write(game,{battle_move_layout=1})
  assert(not B.moveGridNavigation({wideLayout=function()return true end}),'List still uses grid navigation')
  api.customization.write(game,{battle_move_layout=0})
  local theme=api.gbMenus.theme;local glyph=theme.glyph;local count=0
  theme.glyph=function(id,x,y,opts)
   local ax,ay=G.transformPoint(x,y);local bx,by=G.transformPoint(x+1,y);local cx,cy=G.transformPoint(x,y+1)
   local sx,sy=math.sqrt((bx-ax)^2+(by-ay)^2),math.sqrt((cx-ax)^2+(cy-ay)^2)
   assert(math.abs(sx-sy)<.0001 and math.abs(sx-math.floor(sx+.5))<.0001,'Text pixels have fractional or uneven scaling')
   assert(math.abs(ax-math.floor(ax+.5))<.0001 and math.abs(ay-math.floor(ay+.5))<.0001,'Glyph not pixel aligned')
   count=count+1;return glyph(id,x,y,opts)
  end
  for layout=0,1 do for phaseIndex,phase in ipairs({'menu','moveSelect'})do
   api.customization.write(game,{battle_move_layout=layout});battle.phase=phase
   battle.data.moves.tailwhip.name='TAIL WHIP';battle.data.moves.watergun.name='WATER GUN'
   local native=G.newCanvas(160,144);G.setCanvas(native);G.origin();G.clear(0,0,0,0);B.drawTextArea(battle)
   local intermediate=G.newCanvas(1280,832);G.setCanvas(intermediate);G.origin();G.clear(0,0,0,0);G.setColor(1,1,1,1);G.draw(native,17.3,4.7,0,5.13,4.81)
   assert(count==0,'Text was rasterized before the final window copy')
   G.setCanvas();G.origin();G.clear(.1,.1,.1,1);G.draw(intermediate,3.4,2.6,0,.91,.87)
   assert(count>0,'Final window did not draw battle text');count=0
  end end
  assert(not M.current and not api.previewScope,'surface scope leaked')
  write(version..'-result.txt','PASS integer square pixels and aligned glyphs after fractional intermediate canvas resizing, grid/list and command/move panels\n')
 end,debug.traceback)
 if not ok then write(version..'-result.txt','FAIL '..tostring(err))end
 love.event.quit(ok and 0 or 1)
end
