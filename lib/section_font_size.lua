-- Relative, per-section font sizes. Medium is an exact pass-through.
return function(mod)
 local M={};mod.exports.sectionFontSize=M
 local unpack=unpack or table.unpack
 local S=assert(load(assert(mod:read('lib/battle_font_size.lua'))))()(mod,function()return true end)
 S.tagPrefix='_menuCustomizerSectionSize_'
 function M.scope()
  if M.current then return M.current end
  if mod.exports.moveSelectProfile and mod.exports.moveSelectProfile.active then return'moveSelect'end
  return mod.exports.textScopes.currentScope()
 end
 function M.choice(scope)
  local n=tonumber(mod.options:get((scope or M.scope())..'SectionFontSize'))or 2
  return math.max(1,math.min(3,math.floor(n)))
 end
 function S.factor()
  local gb=mod.exports.gbMenus;local surfaces=mod.exports.menuSurfaces
  if gb and gb.live and not gb.live()then return 1 end
  if surfaces and surfaces.enabled and not surfaces.enabled()then return 1 end
  if mod.exports.sectionHealthbox and M.scope()~='battleName'then return 1 end
  local choice=M.choice();if choice==2 then return 1 end
  local G=love.graphics;local base=1
  if G.transformPoint then
   local x,y=G.transformPoint(0,0);local a,b=G.transformPoint(1,0);local c,d=G.transformPoint(0,1)
   local aspect=mod.exports.fontAspect or{1,1}
   base=math.min(math.sqrt((a-x)^2+(b-y)^2)*(aspect[1]or 1),math.sqrt((c-x)^2+(d-y)^2)*(aspect[2]or 1))
  end
  if base<=0 then return 1 end
  local target=G.getCanvas and G.getCanvas()
  local dpi=target and target:getDPIScale()or(G.getDPIScale and G.getDPIScale()or 1)
  local pixels=math.max(1,math.floor(base*dpi*math.min(choice==1 and .5 or 2,M.maximum or math.huge)+.00001))
  return pixels/(base*dpi)
 end
 function M.with(scope,fn,...)
  local prior=M.current;M.current=scope
  local out={pcall(fn,...)};M.current=prior
  if not out[1]then error(out[2],0)end;return unpack(out,2)
 end
 function M.decorate(F,isGB)
  local rawMeasure=F[isGB and'width'or'measure']
  S.decorate(F,'draw',isGB and'width'or'measure',isGB and'drawCode'or'drawGlyph',isGB)
  local tag='_menuCustomizerSectionScope'
  if F[tag]then return end;F[tag]=true
  for _,key in ipairs({'draw',isGB and'width'or'measure'})do
   local fn=F[key]
   if fn then F[key]=function(...)
    local args={...};local opts=args[key=='draw'and 4 or 2]
    local colors=type(opts)=='table'and opts.colors
    local kind=type(colors)=='table'and colors._kind
    local nativeBattle=mod.exports.battleFontScope and key=='draw'and type(args[2])=='number'and type(args[3])=='number'and args[3]>=112
    if nativeBattle then
     local text=tostring(args[1]):upper()
     if text=='FIGHT'or text=='BAG'or text=='RUN'or text=='POKÃ‰MON'or text=='POKEMON'then kind='battleCommands'
     elseif args[2]<120 and(text:find('WHAT WILL',1,true)or text:find('DO?',1,true))then kind='battlePrompt'end
    end
    local function render()
     local before=M.maximum
     if key=='draw'and M.choice()~=2 and rawMeasure then
      local G=love.graphics;local opts=type(args[4])=='table'and args[4]or{}
      local maxWidth,maxHeight=opts.maxWidth,opts._sectionMaxHeight
      if nativeBattle then
       maxHeight=math.min(maxHeight or math.huge,16)
       local right=kind=='battleCommands'and(args[2]<184 and 184 or 240)or kind=='battlePrompt'and 120 or 240
       maxWidth=math.min(maxWidth or math.huge,math.max(1,right-args[2]))
      end
      if G.getScissor and G.inverseTransformPoint then
       local left,top,w,h=G.getScissor()
       if left then
        local right,bottom=G.inverseTransformPoint(left+w,top+h)
        maxWidth=math.min(maxWidth or math.huge,math.max(0,right-args[2]))
        maxHeight=math.min(maxHeight or math.huge,math.max(0,bottom-args[3]))
       end
      end
      S.depth=S.depth+1;local ok,width=pcall(rawMeasure,args[1],opts);S.depth=S.depth-1
      if not ok then error(width,0)end
      local height=isGB and 8 or 16
      if F.face then local face=F.face(opts);height=face and face.height or height end
      M.maximum=math.min(maxWidth and width>0 and maxWidth/width or math.huge,maxHeight and maxHeight/height or math.huge)
     end
     local out={pcall(fn,unpack(args))};M.maximum=before
     if not out[1]then error(out[2],0)end;return unpack(out,2)
    end
    if kind=='battleCommands'or kind=='battlePrompt'then return M.with(kind,render)end
    return render()
   end end
  end
 end
 function M.install()
  local F=require(mod.generation==3 and'src.ui.game3.frlg_font'or'src.render.Font')
  M.decorate(F,mod.generation<3)
 end
 return M
end
