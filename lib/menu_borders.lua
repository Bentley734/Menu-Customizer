-- All generations use 8x8 frame tiles. Public GB calls include their border;
-- Game3 calls name the interior. Convert once here, never stretch corner art.
return function(mod,setting,catalog,active)
 local G=love.graphics
 local M={atlases={}}
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
 function M.draw(tx,ty,tw,th)
  if active and not active() then return false end
  local selection=setting('menuBorder')
  if selection==1 and setting('menuTheme')==2 then selection=13 end
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
 function M.drawPixels(x,y,w,h)
  local selection=setting('menuBorder')
  if selection==1 then
   local version=require('src.core.GameVersion').get()
   local label=setting('menuTheme')==2 and 'EMERALD 03 / R/S 03' or
    (mod.generation==1 and 'R/B/Y' or mod.generation==2 and 'G/S/C 01' or
     (version=='firered' or version=='leafgreen') and 'FR/LG 01' or 'EMERALD 01 / R/S 01')
   for i,e in ipairs(catalog.entries)do if e.label==label then selection=i;break end end
  end
  local atlas=M.atlas(selection)
  if not atlas or w<=0 or h<=0 then return false end
  local edge=math.min(8,w/2,h/2)
  local xs,ys={x,x+edge,x+w-edge},{y,y+edge,y+h-edge}
  local ws,hs={edge,w-2*edge,edge},{edge,h-2*edge,edge}
  G.push('all');G.setShader();G.setColor(1,1,1,1)
  local ok,err=pcall(function()
   for row=1,3 do for col=1,3 do
    if ws[col]>0 and hs[row]>0 then G.draw(atlas.image,atlas.quads[(row-1)*3+col-1],xs[col],ys[row],0,ws[col]/8,hs[row]/8) end
   end end
  end)
  G.pop();if not ok then error(err,0)end
  return true
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
