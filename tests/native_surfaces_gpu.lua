-- Run as LOVE main.lua; MENU_WORKSPACE and MENU_SOURCE select the workspace and repository.
local root=assert(os.getenv('MENU_WORKSPACE')):gsub('\\','/')
local version=os.getenv('MENU_GAME')or'firered'
local out=root..'/.work/menu-33525-native'
local source=(os.getenv('MENU_SOURCE')or root..'/MenuCustomizer'):gsub('\\','/')
local engine=(os.getenv('MENU_ENGINE')or root..'/.tools/engine-0395'):gsub('\\','/')
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
  local options={modOptions={gen3transparency={menuTheme=1,menuTransition=1,controlsLegend=3,opacityFormat=2,
   martCustom=1,martTheme=2,martBorderChoice=13,martBackgroundColor=10,martTextColor=0,martTextShadowColor=0,
   pcCustom=1,pcTheme=2,pcBorderChoice=13,pcBackgroundColor=6,pcTextColor=0,pcTextShadowColor=0,
   dialogueTheme=2,dialogueBorderChoice=13,dialogueBorder=1,dialogueBackgroundColor=10,dialogueTextColor=0}}}
  require('src.core.SaveData').loadOptions=function()return options end
  local Loader=require('src.mods.Loader');local loader=Loader.new{fs=fs,generation=GV.generation(),version=version,dev=false};loader:load(data)
  assert(loader.mods.gen3transparency.state=='loaded',table.concat(loader.errors,'\n'))
  local api=loader.exports.gen3transparency;local M=api.menuSurfaces
  local G=love.graphics;local game={data=data,options=options,mods=loader,save={money=9000,player={money=9000},inventory={},bagOrder={}},writeOptions=function()end}
  game.stack={states={},push=function(self,s)self.states[#self.states+1]=s end,pop=function(self)return table.remove(self.states)end,top=function(self)return self.states[#self.states]end}
  local function capture(name,fn)
   local canvas=G.newCanvas(960,600);G.setCanvas(canvas);G.origin();G.clear(.15,.2,.25,1)
   G.push('all');G.translate(0,0);G.scale(GV.generation()<3 and 4 or 3.5)
   fn();G.pop();G.setCanvas();local d=canvas:newImageData();write(version..'-'..name..'.png',d:encode('png'):getString());return d:getString()
  end

  local bucket=options.modOptions.gen3transparency
  local function customize(scope,n)
   api.customization.write(game,{[scope..'Custom']=1,[scope..'Theme']=2,[scope..'BackgroundColor']=n,[scope..'BorderChoice']=#api.borderCatalog.entries,[scope..'TextColor']=6,[scope..'TextShadowColor']=1})
  end
  if GV.generation()==3 then
   local Bag=require('src.core.game3.bag');local UI=require('src.ui.game3.bag_menu')
   local session={version=version,money=9000,bag=Bag.new(),name='RED',party={},flags={}}
   UI.show(session.bag,{session=session});UI._open=nil;UI._switch=nil
   local function drawBag()require('src.ui.game3.screens').draw('bag',UI,session)end
   customize('bag',2);local a=capture('bag-black',drawBag)
   customize('bag',1);local b=capture('bag-white',drawBag);assert(a~=b,'Bag background ignored')
   UI.close()
   local Party=require('src.ui.game3.party_menu');Party.show({},nil,{session=session});for _=1,40 do Party.update()end
   customize('party',2);a=capture('party-black',Party.draw)
   customize('party',1);b=capture('party-white',Party.draw);assert(a~=b,'Party background ignored')
   Party.close()
  else
   game.world={map={id='PalletTown'},draw=function()end};game.save.party={}
   local Party=require(GV.generation()==1 and'src.ui.PartyMenu'or'src.ui.gen2.PartyMenu')
   local Bag=require(GV.generation()==1 and'src.ui.BagMenu'or'src.ui.gen2.PackMenu')
   for _,row in ipairs({{'bag',Bag},{'party',Party}})do
    local scope,Class=row[1],row[2];local ui=Class.new(game,{party={}})
    ui.screenId=scope=='bag'and(GV.generation()==1 and'BagMenu'or'Gen2PackMenu')or(GV.generation()==1 and'PartyMenu'or'Gen2PartyMenu')
    game.stack.states={game.world,ui}
    local function draw()api.gbMenus.draw(game,{width=960,height=600})end
    customize(scope,2);local a=capture(scope..'-black',draw)
    customize(scope,1);local b=capture(scope..'-white',draw);assert(a~=b,scope..' background ignored')
   end
   -- SAVE keeps the same owner even as its modal text state changes.
   local save={screenId=GV.generation()==1 and'SaveMenu'or'Gen2SaveMenu',_menuCustomizerGroup='save',draw=function()end}
   game.stack.states={game.world,save,{draw=function()end}}
   local owner=api.gbMenus.context(game).motionOwner
   game.stack.states[3]={draw=function()end}
   assert(api.gbMenus.context(game).motionOwner==owner,'SAVE transition owner changed with text child')
  end
  assert(not M.current and not api.previewScope,'surface scope leaked')
  write(version..'-result.txt','PASS native Bag and Party profiles, independent backgrounds and restored graphics scope\n')
 end,debug.traceback)
 if not ok then write(version..'-result.txt','FAIL '..tostring(err))end
 love.event.quit(ok and 0 or 1)
end
