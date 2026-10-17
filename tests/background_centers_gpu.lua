return function(api,game)
 local G=love.graphics;local P=api.selectorPalette;local PB=P.pokemonBackgrounds
 local backgrounds={{1,1,1,1,animation='GRADIENT',gradient=next(P.gradients.byKey),_speedGroup='background'}}
 for _,style in ipairs({1,13,28,43,71,81,151})do
  local found;for key,e in pairs(PB.byKey)do if e.style==style then found=key;break end end
  assert(found,'Missing style '..style);backgrounds[#backgrounds+1]=PB.color(found)
 end
 local thin;for i,e in ipairs(api.borderCatalog.entries)do if e.thin~=nil then thin=i;break end end
 local borders={13,258,assert(thin)}
 local function render(color,border,x,y,w,h)
  api.customization.write(game,{menuBorder=border,startBorderChoice=border})
  local c=G.newCanvas(320,240,{dpiscale=1});G.setCanvas(c);G.origin();G.setShader();G.setScissor();G.clear(0,0,0,0)
  assert(api.borders.drawPixels(x,y,w,h,color,'start'));G.setCanvas()
  local data=c:newImageData();c:release();return data
 end
 local comparisons=0
 for _,border in ipairs(borders)do for _,color in ipairs(backgrounds)do
  local a=render(color,border,8,8,96,64);local b=render(color,border,133,93,96,64)
  for py=20,43 do for px=32,63 do
   local r,g,bb,alpha=a:getPixel(8+px,8+py);local r2,g2,b2,a2=b:getPixel(133+px,93+py)
   assert(math.max(math.abs(r-r2),math.abs(g-g2),math.abs(bb-b2),math.abs(alpha-a2))<=2/255,
    'Background moved with screen coordinates: '..tostring(color.pokemon or color.gradient)..' border '..border)
  end end
  a:release();b:release();comparisons=comparisons+1
 end end
 -- The abstract/radial centre follows the owning box as its dimensions change.
 local radial;for key,e in pairs(PB.byKey)do if e.style==13 then radial=PB.color(key);break end end
 for _,color in ipairs({backgrounds[1],radial})do
  local a=render(color,13,8,8,96,64);local b=render(color,13,8,8,128,80)
  local r,g,bb=a:getPixel(56,40);local r2,g2,b2=b:getPixel(72,48)
  assert(math.max(math.abs(r-r2),math.abs(g-g2),math.abs(bb-b2))<=2/255,'Resized box lost its centre')
  a:release();b:release()
 end
 assert(not P.effects.paperArea,'Panel bounds scope leaked')
 print('PASS background translation/centre/resize comparisons',comparisons)
 return comparisons
end
