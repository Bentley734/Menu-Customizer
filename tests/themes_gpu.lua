local root=assert(os.getenv('MENU_WORKSPACE')):gsub('\\','/')
local version=os.getenv('MENU_GAME')or'firered'
local out=root..'/.work/themes-update/gpu'
local source=os.getenv('MENU_SOURCE')or root..'/MenuCustomizer'
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
  local phase=tonumber(os.getenv('THEME_PHASE'))or 0;love.timer.getTime=function()return phase end
  local choices;local rows=api.customization.rows(function(_,children)choices=children end)
  for _,r in ipairs(rows)do if r.id=='wide_themeSets'then r.activate(game)end end
  local selected=os.getenv('THEME_NAME')or'DARK MODE - OBSIDIAN'
  for _,r in ipairs(choices)do if r.label==selected then r.activate(game)end end
  options.modOptions.gen3transparency.menuTransition=1;options.modOptions.gen3transparency.controlsLegend=3;if api.resetMenuSettings then api.resetMenuSettings()end
  local function capture(name,fn)
   local canvas=G.newCanvas(960,600);G.setCanvas(canvas);G.origin();G.clear(.15,.2,.25,1)
   G.push('all');G.translate(0,0);G.scale(GV.generation()<3 and 4 or 3.5)
   fn();G.pop();G.setCanvas();write(version..'-'..name..'-'..phase..'.png',canvas:newImageData():encode('png'):getString())
  end
  if GV.generation()==3 then
   local Bag=require('src.core.game3.bag');local Shop=require('src.ui.game3.shop_menu')
   local session={version=version,money=9000,bag=Bag.new(),name='RED',party={}}
   Shop.show{session=session,items={4,13,95,96,97}}
   if Shop._rse then Shop.mode='buy';Shop.state='list';Shop.row=0;Shop.scroll=0;Shop._status=nil else Shop.mode='buy'end
   capture('mart',Shop.draw);Shop.close()
   local PC=require('src.ui.game3.pc_menu');if version=='ruby'or version=='emerald'then PC.open=true;PC._session=session;PC.mode='root';PC.cursor=1;PC._status='Which PC should be accessed?'else PC.show(session)end
   capture('pc',PC.draw);PC.close()
   local Message=require('src.ui.game3.message');Message.show('Welcome!\nHow may I help you?')
   Message._shown=1000
   capture('dialogue',function()Message.draw()end)
  else
   local world={map={id='PokeMart'},draw=function()end};game.world=world
   local glyphCount=0;local oldGlyph=api.gbMenus.theme.glyph
   api.gbMenus.theme.glyph=function(...)glyphCount=glyphCount+1;return oldGlyph(...)end
   local shop
   if GV.generation()==1 then
    shop=require('src.ui.ShopMenu').new(game,{'POKE_BALL','POTION','FIRE_STONE','THUNDER_STONE','WATER_STONE'},function()end)
    game.stack.states={world,shop};shop.items[1].onSelect()
    local text=game.stack:top();if text.onDone then game.stack:pop();text.onDone()end
    local items={}
    for _,id in ipairs({'POKE_BALL','POTION','FIRE_STONE','THUNDER_STONE','WATER_STONE'})do local d=data.items[id];items[#items+1]={value=id,label=d.name,price='Â¥'..d.price}end
    items[#items+1]={cancel=true,label='CANCEL'}
    local list=M.with('mart',function()return require('src.ui.ListMenu').new(game,nil,items,{dialogue=true,itemBox=true,footer='Take your time.'})end)
    game.stack.states={world,shop,list}
   else
    shop=require('src.ui.gen2.MartMenu').new(game,{items=data.items,marts={lists={{'POKE_BALL','POTION','FIRE_STONE'}}},text={}})
    shop:enterBuy();game.stack.states={world,shop}
   end
   capture('mart',function()api.gbMenus.draw(game,{width=960,height=600})end);write(version..'-glyphs.txt',tostring(glyphCount))
   local menu=M.with('pc',function()return require('src.ui.Menu').new(game,{{label='WITHDRAW POKEMON'},{label='DEPOSIT POKEMON'},{label='CHANGE BOX'},{label='LOG OFF'}},{tx=0,ty=0,tw=19,th=10})end)
   game.stack.states={world,menu};capture('pc',function()api.gbMenus.draw(game,{width=960,height=600})end)
  end
  assert(not M.current and not api.previewScope,'surface scope leaked')
  write(version..'-result.txt','PASS native Mart and PC drawing, separate profiles and restored scope\n')
 end,debug.traceback)
 if not ok then write(version..'-result.txt','FAIL '..tostring(err))end
 love.event.quit(ok and 0 or 1)
end
