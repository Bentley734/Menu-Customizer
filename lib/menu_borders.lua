-- All generations use 8x8 frame tiles. Public GB calls include their border;
-- Game3 calls name the interior. Convert once here, never stretch corner art.
return function(mod,setting,catalog,active)
 local G=love.graphics
 local M={atlases={}}
 local palette=assert(load(assert(mod:read('lib/battle_text_palette.lua'))))()(mod)
 local function paint(c,fn,...)return palette.paint(c,fn,...)end
 function M.atlas(selection)
  local entry=catalog.entries[selection]
  if not entry or not entry.path then return nil end
  if M.atlases[selection] then return M.atlases[selection] end
  local image=mod.assets:image(entry.path)
  image:setFilter('nearest','nearest')
  local w,h=image:getDimensions()
  assert(w==24 and h==24,'Menu Customizer: invalid border atlas '..entry.path)
  local atlas={image=image,quads={}}
  for n=0,8 do atlas.quads[n]=G.newQuad(n%3*8,math.floor(n/3)*8,8,8,w,h) end
  M.atlases[selection]=atlas
  return atlas
 end
 -- Battle-only transparent paper masks, leaving the shared menu atlas intact.
 function M.battleAtlas(atlas,selection)
  if atlas.battleImage then return atlas.battleImage,atlas.paperImage end
  if not (love.image and love.image.newImageData and love.filesystem and G.newImage) then return atlas.image end
  local source=mod:read(catalog.entries[selection].path)
  local data=love.image.newImageData(love.filesystem.newFileData(source,'border.png'))
  local mask=assert(load(assert(mod:read('lib/border_paper.lua'))))()(data)
  local paper=love.image.newImageData(24,24)
  for key in pairs(mask)do
    local x,y=(key-1)%24,math.floor((key-1)/24)
    local _,_,_,a=data:getPixel(x,y)
    paper:setPixel(x,y,1,1,1,a);data:setPixel(x,y,0,0,0,0)
  end
  atlas.battleImage=G.newImage(data);atlas.paperImage=G.newImage(paper)
  atlas.battleImage:setFilter('nearest','nearest');atlas.paperImage:setFilter('nearest','nearest')
  if data.release then data:release()end;if paper.release then paper:release()end
  return atlas.battleImage,atlas.paperImage
 end
 function M.draw(tx,ty,tw,th)
  if active and not active() then return false end
  local selection=setting('menuBorder')
  if selection==1 and setting('menuTheme')>1 then selection=13 end
  local background=mod.exports and mod.exports.menuBackground and mod.exports.menuBackground()
  if background then return M.drawPixels(tx*8,ty*8,tw*8,th*8,background)end
  local atlas=M.atlas(selection)
  if not atlas then return false end
  if tw<2 or th<2 then return false end
  G.push('all');G.setShader();G.setColor(1,1,1,1)
  G.rectangle('fill',(tx+1)*8,(ty+1)*8,(tw-2)*8,(th-2)*8)
  local function cell(n,x,y) G.draw(atlas.image,atlas.quads[n],x*8,y*8) end
  cell(0,tx,ty);cell(2,tx+tw-1,ty)
  cell(6,tx,ty+th-1);cell(8,tx+tw-1,ty+th-1)
  for x=tx+1,tx+tw-2 do cell(1,x,ty);cell(7,x,ty+th-1) end
  for y=ty+1,ty+th-2 do cell(3,tx,y);cell(5,tx+tw-1,y) end
  G.pop()
  return true
 end
 -- Battle callers use full pixel bounds rather than menu interior tiles.
 function M.drawPixels(x,y,w,h,background)
  background=background or mod.exports and mod.exports.menuBackground and mod.exports.menuBackground()
  local selection=setting('menuBorder')
  if selection==1 then
   local version=require('src.core.GameVersion').get()
   local label=setting('menuTheme')>1 and 'EMERALD 03 / R/S 03' or
    (mod.generation==1 and 'R/B/Y' or mod.generation==2 and 'G/S/C 01' or
     (version=='firered' or version=='leafgreen') and 'FR/LG 01' or 'EMERALD 01 / R/S 01')
   for i,e in ipairs(catalog.entries)do if e.label==label then selection=i;break end end
  end
  local atlas=M.atlas(selection)
  if not atlas or w<=0 or h<=0 then return false end
  local image,paper=atlas.image,nil
  if background then image,paper=M.battleAtlas(atlas,selection)end
  local edge=math.min(8,w/2,h/2)
  local xs,ys={x,x+edge,x+w-edge},{y,y+edge,y+h-edge}
  local ws,hs={edge,w-2*edge,edge},{edge,h-2*edge,edge}
  G.push('all');G.setShader();G.setColor(1,1,1,1)
  local ok,err=pcall(function()
   -- Repeat original 8px cells; crop the last cell rather than stretching
   -- an entire edge. Corners and patterned interiors keep the same pixel size.
   atlas.fragments=atlas.fragments or {}
   local function tiled(n,rx,ry,rw,rh)
    for dy=0,rh-0.000001,8 do for dx=0,rw-0.000001,8 do
     local cw,ch=math.min(8,rw-dx),math.min(8,rh-dy)
     local quad=atlas.quads[n]
     if cw<8 or ch<8 then
      local key=n..':'..cw..':'..ch
      quad=atlas.fragments[key]
      if not quad then
       quad=G.newQuad(n%3*8,math.floor(n/3)*8,cw,ch,24,24)
       atlas.fragments[key]=quad
      end
     end
     if paper then
      paint(background,G.draw,paper,quad,rx+dx,ry+dy);G.setColor(1,1,1,1)
     end
     G.draw(image,quad,rx+dx,ry+dy)
    end end
   end
   for row=1,3 do for col=1,3 do
    if ws[col]>0 and hs[row]>0 then
     if row==2 and col==2 then
      -- The plain paper is one surface: fractional tile joins can leave
      -- hairline gaps under the independently scaled battle canvas.
      if background then paint(background,G.rectangle,'fill',xs[col],ys[row],ws[col],hs[row]);G.setColor(1,1,1,1)
      else G.draw(atlas.image,atlas.quads[4],xs[col],ys[row],0,ws[col]/8,hs[row]/8)end
     else tiled((row-1)*3+col-1,xs[col],ys[row],ws[col],hs[row]) end
    end
   end end
  end)
  G.pop();if not ok then error(err,0)end
  return true
 end
 -- Battle panels share the dialogue's 48px reference height. Render in
 -- screen space so command-width and move-canvas transforms cannot distort
 -- the border. Text keeps its own native transform.
 function M.drawBattlePixels(x,y,w,h)
  local ui=mod.exports and mod.exports.battleUi
  local background=ui and ui.backgroundColor and ui.backgroundColor()
  if not G.transformPoint or not G.origin then return M.drawPixels(x,y,w,h,background) end
  local left,top=G.transformPoint(x,y)
  local right,bottom=G.transformPoint(x+w,y+h)
  local scale=(bottom-top)/48
  if scale<=0 or right<=left then return false end
  G.push('all');G.origin();G.translate(left,top);G.scale(scale,scale)
  local ok,result=pcall(M.drawPixels,0,0,(right-left)/scale,48,background)
  G.pop();if not ok then error(result,0)end
  return result
 end
 function M.dialogueEnabled()return active() and setting('dialogueBorder')==1 end
 if mod.generation==3 then
  local Chrome=require('src.ui.game3.chrome')
  Chrome._menuCustomizerBorders=M
  if not Chrome._menuCustomizerDialogueWrapped then
   for _,key in ipairs({'dialogueFrame','signFrame'})do
    local original=Chrome[key]
    Chrome[key]=function(...)
     local borders=Chrome._menuCustomizerBorders
     if borders.dialogueEnabled() then
      local x,y,w,h=Chrome.dialogueWindow()
      if borders.draw(x-1,y-1,w+2,h+2) then return end
     end
     return original(...)
    end
   end
   Chrome._menuCustomizerDialogueWrapped=true
  end

  if not Chrome._menuCustomizerBorderWrapped then
   local user=Chrome.userFrame
   Chrome.userFrame=function(frame,tx,ty,tw,th,...)
    if Chrome._menuCustomizerBorders.draw(tx-1,ty-1,tw+2,th+2) then return end
    return user(frame,tx,ty,tw,th,...)
   end
   for _,key in ipairs({'stdFrame','fixedStdFrame'}) do
    local original=Chrome[key]
    Chrome[key]=function(tx,ty,tw,th,...)
     if Chrome._menuCustomizerBorders.draw(tx-1,ty-1,tw+2,th+2) then return end
     return original(tx,ty,tw,th,...)
    end
   end
   Chrome._menuCustomizerBorderWrapped=true
  end
 end
 return M
end
