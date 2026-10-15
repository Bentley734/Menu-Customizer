-- Independent visual profiles. Native menus retain their input and actions.
return function(mod)
 local M={mod=mod};mod.exports.menuSurfaces=M
 local Runtime=require('src.mods.Runtime')
 Runtime._menuCustomizerSurfaces=M
 local unpack=unpack or table.unpack
 local get,saveGet=mod.options.get,mod.save.get
 function M.custom(scope)return tonumber(get(mod.options,scope..'Custom'))==1 end
 function M.enabled()
  for _,entry in ipairs(Runtime.hooks and Runtime.hooks.chains and Runtime.hooks.chains['ui.start_menu.items']or{})do
   if entry.owner==mod.id then return true end
  end
  return false
 end
 local aliases={menuTheme='Theme',menuBorder='BorderChoice',otherBorderChoice='BorderChoice',
  arrowSelector='Selector',selectorColor='SelectorColor',menuBackgroundColor='BackgroundColor',menuTextColor='TextColor',menuTextShadowColor='TextShadowColor'}
 function M.resolve(key)
  local scope=M.current
  if not scope or tonumber(get(mod.options,scope..'Custom'))~=1 then return nil end
  local suffix=aliases[key]
  local mapped=suffix and scope..suffix or key:match('^menu_fx_')and(scope..key:sub(5))
  if not mapped then return nil end
  local value=get(mod.options,mapped);if value==nil then value=saveGet(mod.save,mapped)end
  return value
 end
 mod.options.get=function(self,key)local value=M.resolve(key);if value~=nil then return value end;return get(self,key)end
 mod.save.get=function(self,key,...)local value=M.resolve(key);if value~=nil then return value end;return saveGet(self,key,...)end
 function M.with(scope,fn,...)
  if not M.enabled()then return fn(...)end
  local prior,paper,preview=M.current,mod.exports.menuPaperScope,mod.exports.previewScope
  M.current=scope;mod.exports.menuPaperScope='other'
  if mod.generation==3 then mod.exports.previewScope=true end
  local G=love.graphics;local rect=G.rectangle
  if mod.generation==3 and mod.exports.selectorPalette then
   G.rectangle=function(...)return mod.exports.selectorPalette.tintFill(rect,...)end
  end
  local fonts=mod.exports.allFonts
  local out
  if (scope=='mods'or scope=='trainerCard')and fonts and fonts.withFrame then out={pcall(fonts.withFrame,scope,fn,...)}else out={pcall(fn,...)}end
  G.rectangle=rect
  M.current=prior;mod.exports.menuPaperScope=paper;mod.exports.previewScope=preview
  if not out[1]then error(out[2],0)end;return unpack(out,2)
 end
 function M.base(fn,...)
  local prior=M.current;M.current=nil;local out={pcall(fn,...)};M.current=prior
  if not out[1]then error(out[2],0)end;return unpack(out,2)
 end
 local function callback(scope,fn)return function(...)return Runtime._menuCustomizerSurfaces.with(scope,fn,...)end end
 function M.tag(menu,scope)
  if type(menu)~='table'or not scope then return menu end
  if menu._menuCustomizerSurface==scope then return menu end
  menu._menuCustomizerSurface=scope;menu._menuCustomizerGroup='other'
  for _,key in ipairs({'draw','update','onDone','onClose','onCancel','enter'})do
   if type(menu[key])=='function'then menu[key]=callback(scope,menu[key])end
  end
  local rows=menu.items or menu.rows
  for _,row in ipairs(type(rows)=='table'and rows or{})do
   if type(row)=='table'and type(row.onSelect)=='function'then row.onSelect=callback(scope,row.onSelect)end
  end
  return menu
 end
 function M.surface(states)
  for i=#(states or{}),1,-1 do if states[i]._menuCustomizerSurface then return states[i]._menuCustomizerSurface end end
 end
 local function value(scope,suffix,fallback)
  local v=get(mod.options,scope..suffix);if v==nil then v=saveGet(mod.save,scope..suffix)end
  if v==nil and fallback then v=get(mod.options,fallback);if v==nil then v=saveGet(mod.save,fallback)end end
  return tonumber(v)
 end
 function M.rows(openPage)
  local palette=assert(mod.exports.selectorPalette)
  local catalog=mod.exports.borderCatalog or assert(load(assert(mod:read('lib/border_catalog.lua'))))()
  local result={}
  local scopes={'mart','pc','dialogue','mods'};if mod.generation<3 then scopes[#scopes+1]='loadReport';scopes[#scopes+1]='trainerCard'end
  for _,scope in ipairs(scopes)do
   local label=scope=='trainerCard'and'PLAYER CARD'or scope=='mods'and'MOD MENUS'or scope=='mart'and'POKE MART'or scope=='pc'and'PC MENUS'or scope=='loadReport'and'LOAD REPORT'or'DIALOGUE BOXES'
   local rows={}
   local function write(ctx,key,n)
    local values={[key]=n,borderCatalogFormat=2}
    if scope~='dialogue'and key~=scope..'Custom'then values[scope..'Custom']=1 end
    if key=='dialogueBorderChoice'then values.dialogueBorder=n>0 and 1 or 0 end
    mod.exports.customization.write(ctx,values);if mod.exports.resetMenuSettings then mod.exports.resetMenuSettings()end
    return false
   end
   local function add(suffix,title,default,minimum,maximum,names,kind,fallback)
    if scope=='dialogue'then fallback=nil end
    local key=scope..suffix
    local function current()return math.max(minimum,math.min(maximum,value(scope,suffix,fallback)or default))end
    local row={id='surface_'..key,label=title,value=function()local n=current();return names and names[n-minimum+1]or tostring(n)end,
     step=function(ctx,d)return write(ctx,key,minimum+(current()-minimum+(d or 1))%(maximum-minimum+1))end}
    if kind then palette.picker(row,kind,current,function(ctx,n)return write(ctx,key,n)end,openPage)end
    if suffix=='BorderChoice'then
     row.customization=mod.exports.customization
     palette.designPicker(row,catalog.groups,current,function(ctx,n)return write(ctx,key,n)end,openPage)
     row.value=function()local n=current();return n==0 and'NATIVE'or catalog.choices[n]end
    end
    rows[#rows+1]=row
   end
   if scope=='mods'then
    add('Selector','SELECTOR',1,1,13,mod.exports.arrowSelectors.names or mod.exports.gbMenus and mod.exports.gbMenus.selectors.names)
    add('SelectorColor','SELECTOR COLOR',0,0,#palette.names-1,palette.names,'text','selectorColor')
    for _,effect in ipairs(palette.effects.rows('mods',function(ctx,key,n)write(ctx,key,n);return false end,openPage))do rows[#rows+1]=effect end
   end
   if scope=='loadReport'then add('Enabled','SHOW LOAD REPORT',1,0,1,{'DISABLED','ENABLED'})end
   if scope~='dialogue'then add('Custom','STYLE',0,0,1,{'USE MENU','CUSTOM'})end
   add('Theme','FONT',2,1,2,{'NATIVE','EMERALD'},nil,scope=='dialogue'and nil or'menuTheme')
   add('BorderChoice','BORDER',scope=='dialogue'and 0 or 1,0,#catalog.choices,nil,nil,'menuBorder')
   add('BackgroundColor','BACKGROUND',0,0,#palette.menuBackgroundNames-1,palette.menuBackgroundNames,'menuBackground','menuBackgroundColor')
   add('TextColor','TEXT COLOR',0,0,#palette.names-1,palette.names,'text','menuTextColor')
   add('TextShadowColor','TEXT SHADOW',0,0,#palette.shadowNames-1,palette.shadowNames,'shadow','menuTextShadowColor')
   if scope=='dialogue'or scope=='loadReport'or scope=='mods'or scope=='trainerCard'then add('Justify','ALIGNMENT',scope=='loadReport'and 2 or 1,1,3,{'LEFT','CENTER','RIGHT'})end
   rows[#rows+1]={id='surface_'..scope..'Reset',label=scope=='dialogue'and'RESET DIALOGUE'or'USE MENU STYLE',activate=function(ctx)
    local values={}
    if scope=='dialogue'then values={dialogueTheme=2,dialogueBorderChoice=0,dialogueBorder=0,dialogueBackgroundColor=0,dialogueTextColor=0,dialogueTextShadowColor=0,dialogueJustify=1}
    else values[scope..'Custom']=0 end
    mod.exports.customization.write(ctx,values);if mod.exports.resetMenuSettings then mod.exports.resetMenuSettings()end;return false
   end}
   result[#result+1]={id='wide_surface_'..scope,label=label,children=rows,group=true,value=function()return'OPEN'end,activate=function(ctx)return openPage(label,rows,ctx)end}
  end
  return result
 end
 function M.install()
  if mod.generation==3 then
   local manager=require('src.ui.game3.mod_manager');if manager.draw then manager.draw=callback('mods',manager.draw)end
   local ShopChrome=require('src.ui.game3.shop_chrome')
   if not ShopChrome._menuCustomizerSurfaceBg then
    local draw=ShopChrome.drawBg;ShopChrome._menuCustomizerSurfaceBg=draw
    ShopChrome.drawBg=function(...)
     local out={draw(...)};local api=Runtime._menuCustomizerSurfaces
     if api.current=='mart'and api.custom('mart')then
      local borders=api.mod.exports.borders
      local version=require('src.core.GameVersion').get()
      local hoenn=version=='ruby'or version=='sapphire'or version=='emerald'
      local rects=hoenn and{{104,8,136,144}}or{{80,0,160,112},{0,112,240,48}}
      for _,r in ipairs(rects)do borders.drawPixels(r[1],r[2],r[3],r[4],nil,'other')end
      if hoenn then
       local palette=api.mod.exports.selectorPalette;local bg=palette.menuBackground()
       if bg then palette.paint(bg,love.graphics.rectangle,'fill',0,96,104,64)end
      end
     end
     return unpack(out)
    end
   end
   local Font=require('src.ui.game3.frlg_font')
   for _,key in ipairs({'draw','measure','drawGlyph'})do
    local tag='_menuCustomizerSurface_'..key
    if not Font[tag]then
     local original=Font[key];Font[tag]=original
     Font[key]=function(text,x,y,opts,...)
      local api=Runtime._menuCustomizerSurfaces
      -- RS cartridge labels explicitly select native_3. An explicit custom
      -- font applies to these labels as well as their measured geometry.
      if key=='measure'then opts=x end
      if api.current and api.resolve('menuTheme')==2 and type(opts)=='table'and tostring(opts.font):match('^native_')then
       local copy={}for k,v in pairs(opts)do copy[k]=v end;copy.font='narrow';opts=copy
      end
      if key=='draw'and api.current=='mart'and api.resolve('menuTheme')==2 and type(x)=='number'and type(y)=='number'then
       local Shop=package.loaded['src.ui.game3.shop_menu']
       if Shop and Shop._rse and Shop.state=='list'and x<=8 and y>=96 then
        local copy={}for k,v in pairs(opts or{})do copy[k]=v end
        copy.font='narrow';copy.maxWidth=math.min(copy.maxWidth or 104,104-x);opts=copy
       end
      end
      if key=='measure'then return original(text,opts,y,...)end
      return original(text,x,y,opts,...)
     end
    end
   end
   for _,pair in ipairs({{'src.ui.game3.shop_menu','mart'},{'src.ui.game3.pc_menu','pc'},{'src.ui.game3.item_pc','pc'},
    {'src.ui.game3.hall_of_fame_pc','pc'},{'src.ui.game3.box_storage_ui','pc'},
    {'src.ui.game3.storage_choose_box','pc'},{'src.ui.game3.rse.mailbox','pc'}})do
    local ui=require(pair[1]);local draw=ui.draw
    if draw and not ui._menuCustomizerSurfaceDraw then ui._menuCustomizerSurfaceDraw=draw;ui.draw=callback(pair[2],draw)end
   end
   local Bag=require('src.ui.game3.bag_menu')
   if not Bag._menuCustomizerSurfaceDraw then
    local draw=Bag.draw;Bag._menuCustomizerSurfaceDraw=draw
    Bag.draw=function(...)
     local api=Runtime._menuCustomizerSurfaces
     local scope=Bag._location=='shop'and'mart'or Bag._location=='itempc'and'pc'
     if scope then return api.with(scope,draw,...)end
     return draw(...)
    end
   end
  else
   local function constructor(path,scope)
    local class=require(path);local new=class.new
    if class._menuCustomizerSurfaceNew then
     if scope then class._menuCustomizerSurfaceNew.scope=scope end;return
    end
    local state={new=new,scope=scope};class._menuCustomizerSurfaceNew=state
    class.new=function(...)local args={n=select('#',...),...}
     local api=Runtime._menuCustomizerSurfaces;local chosen=state.scope or api.current
     if not chosen then return new(...)end
     return api.with(chosen,function()return api.tag(new(unpack(args,1,args.n)),chosen)end)
    end
   end
   for _,path in ipairs({'src.ui.Menu','src.ui.ListMenu','src.ui.ChoiceBox','src.ui.QuantityBox','src.render.TextBox','src.ui.BoxMenu'})do constructor(path)end
   constructor('src.ui.QuarantineReport','loadReport')
   constructor('src.mods.ManagerState','mods')
   constructor(mod.generation==1 and'src.ui.TrainerCard'or'src.ui.gen2.TrainerCard','trainerCard')
   local Screens=require('src.ui.Screens');local push=Screens.push
   if not Screens._menuCustomizerMods then
    Screens._menuCustomizerMods=true
    Screens.push=function(game,id,...)
     local scope=M.current;local inst=push(game,id,...)
     -- Some screen factories do not return the pushed state.
     inst=inst or(game.stack and game.stack:top())
     if scope=='mods'and type(inst)=='table'then M.tag(inst,'mods')end
     return inst
    end
   end
   if mod.generation==1 then
    constructor('src.ui.ShopMenu','mart');constructor('src.ui.PlayerPC','pc');constructor('src.ui.LeaguePC','pc')
    local World=require('src.world.OverworldController');local open=World.openPC
    if not World._menuCustomizerSurfacePC then World._menuCustomizerSurfacePC=open;World.openPC=callback('pc',open)end
   else
    for _,path in ipairs({'src.ui.gen2.CenterPcMenu','src.ui.gen2.PcMenu','src.ui.gen2.ItemPcMenu','src.ui.gen2.BoxMenu'})do constructor(path,'pc')end
    constructor('src.ui.gen2.MartMenu','mart')
   end
   local C=mod.exports.gbMenus;local draw=C.draw
   C.draw=function(game,viewport)
    local states=game and game.stack and game.stack.states
    local scope=M.surface(states)
    if scope then return M.with(scope,draw,game,viewport)end
    return draw(game,viewport)
   end
  end
 end
 return M
end
