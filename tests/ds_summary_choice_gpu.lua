local root=assert(os.getenv('MENU_WORKSPACE')):gsub('\\','/')
local version=os.getenv('MENU_GAME')or'firered'
local out=root..'/.work/jump-wave/gpu'
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

  local G=love.graphics;local F=require('src.render.Font');local Runtime=require('src.mods.Runtime');local c=api.gbMenus;local border
  for id,e in ipairs(api.borderCatalog.entries)do if e.dsFrame then border=id;break end end
  local summary={game=game,save={},title={},titleUiBox={4,7,19,16},draw=function()
   F.drawBox(4,7,16,10)
   for i,row in ipairs({{'PLAYER','ASH'},{'BADGES',' 0'},{'POKéDEX','  0'},{'TIME','  4:07'}})do local y=56+i*16;F.draw(row[1],40,y);F.draw(row[2],i==1 and 96 or i==4 and 104 or 136,y)end
  end}
  local Choice=require('src.ui.ChoiceBox');local choice=Choice.new(game,function()end)
  local target=G.newCanvas(960,576);local printer=F.draw;local draws=0
  F.draw=function(text,x,y,...)
   if c.summaryScope then assert(x>=18 and x+F.width(text)<=134.01,'Summary text outside DS interior');draws=draws+1 end
   return printer(text,x,y,...)
  end
  G.setCanvas(target);G.clear(.1,.1,.1,1)
  for mode=1,2 do for align=1,3 do
   api.customization.write(game,{menuBorder=border,saveBorderChoice=border,optionBorderChoice=border,menuTheme=mode,saveSummaryTheme=mode,dialogueTheme=mode,saveSummaryJustify=align,allFontAlign=align})
   G.push('all');G.translate((align-1)*320,(mode-1)*288);G.scale(2)
   game.stack.states={summary};Runtime.call('screen.render_visible',function(state)state:draw()end,summary)
   G.setColor(0,0,0,1);choice:draw();G.pop()
  end end
  G.setCanvas();F.draw=printer;assert(draws==48,'Summary layout was not exercised')
  write(version..'-ds-summary-choice.png',target:newImageData():encode('png'):getString())
  write(version..'-result.txt','PASS native/Emerald Continue summary bounds and widened ChoiceBox rendering in all alignments')

 end,debug.traceback)
 if not ok then write(version..'-result.txt','FAIL '..tostring(err))end
 love.event.quit(ok and 0 or 1)
end
