-- One font control surface; bounded alignment leaves numeric columns intact.
return function(mod)
 local M={};mod.exports.allFonts=M
 local C=mod.exports.customization;local G=love.graphics
 local unpack=unpack or table.unpack
 function M.align(x,width,ink,scope,default)
  local n=tonumber(mod.options:get((scope or'menu')..'Justify'))or tonumber(mod.options:get('allFontAlign'))or default or 1
  local gap=math.max(0,width-ink)
  return math.floor(x+(n==2 and gap/2 or n==3 and gap or 0)+.5)
 end
 local prefixes={'menu_fx_','intro_fx_','battle_fx_','battle_name_fx_','mart_fx_','pc_fx_','mods_fx_'}
 function M.values(key,n)
  local values=C.globalValues(key,n)or{[key]=n}
  if key=='allTextColor'then
   for _,prefix in ipairs(prefixes)do values[prefix..'preset']=0;values[prefix..'alternate']=0 end
  elseif key=='textCase'then if mod.exports.textScopes then values=mod.exports.textScopes.values(n)else values.introTextCase=n end
  elseif key=='menu_fx_stardew'or key:match('^menu_fx_stardew_')then
   local suffix=key:sub(9)
   for _,scope in ipairs(mod.exports.textScopes.scopes)do values[scope[1]..'_fx_'..suffix]=n end
   for _,scope in ipairs({'battle_name','battleCommands','battlePrompt','moveSelect','moveLearning'})do values[scope..'_fx_'..suffix]=n end
  elseif key:match('^menu_fx_')then
   if key=='menu_fx_shadow_transparency'then values.allShadowOpacity=100-n end
   for _,prefix in ipairs(prefixes)do values[prefix..key:sub(9)]=n end
  end
  return values
 end
 function M.row(openPage)
  local P=mod.exports.selectorPalette;local rows={}
  local function add(key,label,names,default,minimum,kind,step)
   minimum=minimum or 0
   local function current()
    local fallback=({allFontTheme='menuTheme',allFontAlign='startJustify',allTextColor='menuTextColor',allTextShadowColor='menuTextShadowColor'})[key]
    return tonumber(mod.options:get(key))or(fallback and tonumber(mod.options:get(fallback)))or default
   end
   local function write(ctx,n)C.write(ctx,M.values(key,n));return false end
   local row={id='wide_'..key,label=label,value=function()local n=current();return names and names[n-minimum+1]or tostring(n)..'%'end,
    preview=function()return M.values(key,current())end,step=function(ctx,d)
     local n=names and(minimum+(current()-minimum+(d or 1))%#names)or math.max(0,math.min(100,current()+(d or 1)*(step or 5)))
     return write(ctx,n)
    end,customization=C}
   if kind then P.picker(row,kind,current,write,openPage)end
   rows[#rows+1]=row
  end
  add('allFontTheme','FONT STYLE',{'NATIVE','EMERALD'},2,1)
  add('allTextColor','FONT COLOR',P.names,0,0,'text')
  add('allTextShadowColor','SHADOW COLOR',P.shadowNames,0,0,'shadow')
  add('allShadowOpacity','SHADOW OPACITY',nil,100)
  add('allFontAlign','ALIGNMENT',{'LEFT','CENTER','RIGHT'},1,1)
  local effects=P.effects.rows('menu',function(ctx,key,n)C.write(ctx,M.values(key,n));return false end,openPage)
  for _,row in ipairs(effects)do
   row.label=row.label:gsub('^MENU ','ALL ')
   local original=row.preview
   row.preview=function()
    local values=original and original()or{};local out={}
    for k,v in pairs(values)do for a,b in pairs(M.values(k,v))do out[a]=b end end
    return out
   end
  end
  rows[#rows+1]={id='all_fonts_effects',label='TEXT EFFECTS',group=true,children=effects,value=function()return'OPEN'end,activate=function(ctx)return openPage('ALL FONT EFFECTS',effects,ctx)end}
  return{id='wide_allFonts',label='ALL FONTS',group=true,children=rows,value=function()return'OPEN'end,activate=function(ctx)return openPage('ALL FONTS',rows,ctx)end}
 end
 local function enabled()
  local surfaces=mod.exports.menuSurfaces
  return surfaces and surfaces.enabled()and (surfaces.current=='mods'or mod.options:get('allFontAlign')~=nil or mod.options:get('loadReportJustify')~=nil or mod.exports.borders and select(3,mod.exports.borders.insets()))
 end
 local frames,scope,printing,anchors,jumpLabel
 local function within(fn,group,initial,...)
  if not enabled()or frames then return fn(...)end
  local oldFrames,oldScope,oldAnchors=frames,scope,anchors;frames,scope,anchors=initial or{},group,{}
  local out={pcall(fn,...)};frames,scope,anchors=oldFrames,oldScope,oldAnchors
  if not out[1]then error(out[2],0)end
  return unpack(out,2)
 end
 function M.withFrame(group,fn,...)return within(fn,group,nil,...)end
 function M.install()
  local F=require(mod.generation==3 and'src.ui.game3.frlg_font'or'src.render.Font')
  local draw=F.draw
  F.draw=function(text,x,y,opts,...)
   local inputX=x
   local gb=mod.exports.gbMenus
   local ownLayout=gb and (gb.drawingStart or gb.drawingOptions or gb.drawingParty or gb.summaryScope or gb.drawingDex)
   if frames and not printing and not ownLayout and type(x)=='number'and type(y)=='number'then
    local box
    for _,r in ipairs(frames)do if x>=r.x and y>=r.y and x<r.x+r.w and y<r.y+r.h and(not box or r.w<box.w)then box=r end end
    if box and x<=box.x+(scope=='mods'and 32 or 24)and not tostring(text):match('^[%d%s%p]+$')then
     local left,right,ds=8,8,false
     if mod.exports.borders then left,right,ds=mod.exports.borders.insets(nil,box.w,box.h)end
     if ds then x=math.max(x,box.x+left+8)end
     local width=box.x+box.w-right-x
     if scope=='option'then width=math.min(width,120-x)end
     if type(opts)=='table'and opts.maxWidth then width=math.min(width,opts.maxWidth)end
     local measure=F.measure or F.width;local ink=measure(text,opts)
     if ink and ink<=width then x=M.align(x,width,ink,scope)end
    end
   end
   if frames and not printing and not ownLayout and mod.exports.borders then
    for i=#frames,1,-1 do local b=frames[i]
     if y>=b.y and y<b.y+b.h and x>=b.x and x<b.x+b.w then
      local il,ir,ds=mod.exports.borders.insets(nil,b.w,b.h)
      if ds then local ink=(F.measure or F.width)(text,opts)or 0;x=math.max(b.x+il,math.min(x,b.x+b.w-ir-ink))end
      break
     end
    end
   end
   if anchors and not printing then anchors[tostring(inputX)..':'..tostring(y)]=x end
   local old=printing;printing=true;local args={...};local out
   if not ownLayout and jumpLabel==text and mod.exports.jumpWave and mod.exports.jumpWave.enabled() then
    out={pcall(mod.exports.jumpWave.draw,draw,F.measure or F.width,text,x,y,opts,unpack(args))}
   else out={pcall(draw,text,x,y,opts,unpack(args))}end;printing=old
   if not out[1]then error(out[2],0)end;return unpack(out,2)
  end
  local markerKey=mod.generation<3 and'drawCode'or'drawGlyph'
  local marker=F[markerKey]
  if marker then F[markerKey]=function(id,x,y,...)
   if anchors and (id==0xED or id==0xEC or mod.generation==3 and id==F.CHAR_SELECTOR_ARROW)then
    local aligned=scope=='mods'and x==8 and anchors['32:'..tostring(y)]or anchors[tostring(x+8)..':'..tostring(y)]
    if aligned then x=aligned-8 end
   end
   return marker(id,x,y,...)
  end end
  local function hook(target,key,group,seed)
   if not target or type(target[key])~='function'then return end
   local original=target[key]
   target[key]=function(...)
    local owner=select(1,...)
    if mod.generation<3 and type(owner)=='table'and owner.game and owner.game.stack and owner.game.stack.top then
     local top=owner.game.stack:top()
     local retainedTitle=owner.titleUiBox and owner.items and top and top.titleUiBox and top.save and top.title
     if top and top~=owner and not retainedTitle then return original(...)end
    end
    local initial=seed and seed(...)
    local previous=jumpLabel;local item=type(owner)=='table'and owner.items and owner.items[owner.index or 1];jumpLabel=item and item.label
    if item and not(mod.exports.gbMenus and(mod.exports.gbMenus.drawingStart or mod.exports.gbMenus.drawingOptions))and mod.exports.jumpWave and mod.exports.jumpWave.enabled()then mod.exports.jumpWave.select(owner,owner.index or 1,item.label)end
    local result={pcall(within,original,group,initial,...)};jumpLabel=previous
    if not result[1]then error(result[2],0)end;return unpack(result,2)
   end
  end
  if mod.generation<3 then
   local box=F.drawBox
   F.drawBox=function(x,y,w,h,...)
    if frames then frames[#frames+1]={x=x*8,y=y*8,w=w*8,h=h*8}end
    return box(x,y,w,h,...)
   end
   hook(require('src.ui.Menu'),'draw','menu')
   hook(require('src.ui.QuarantineReport'),'draw','loadReport')
   hook(require('src.mods.ManagerState'),'draw','mods')
   hook(require('src.ui.ListMenu'),'draw','menu',function(self)
    local width=136
    for _,item in ipairs(self.items or{})do if item.right and not self.dialogue then width=math.min(width,132-F.width(item.right))end end
    return{{x=8,y=8,w=width+16,h=120}}
   end)
  else
   local Window=require('src.ui.game3.window');local frame=Window.stdFrame
   Window.stdFrame=function(t,...)
    if frames and t then frames[#frames+1]={x=t.left*8,y=t.top*8,w=t.w*8,h=t.h*8}end
    return frame(t,...)
   end
   local dialogue=Window.dialogueFrame
   if dialogue then Window.dialogueFrame=function(...)
    if frames then frames[#frames+1]={x=0,y=112,w=240,h=48}end
    return dialogue(...)
   end end
   for _,pair in ipairs({{'src.ui.game3.pc_menu','pc'},{'src.ui.game3.item_pc_menu','pc'},{'src.ui.game3.shop_menu','mart'},
    {'src.ui.game3.option_menu','option'},{'src.ui.game3.rse.option_menu','option'},{'src.ui.game3.bag_menu','menu'}})do
    local ok,target=pcall(require,pair[1]);if ok then hook(target,'draw',pair[2])end
   end
  end
 end
 return M
end
