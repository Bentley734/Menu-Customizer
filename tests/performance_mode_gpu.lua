-- Run inside the native GPU harness; settings are in memory only.
return function(api,game)
 local G=love.graphics
 local original=game.options.modOptions.gen3transparency.performanceMode
 local osName=love.system.getOS;love.system.getOS=function()return 'Android'end
 api.customization.write(game,{performanceMode=nil})
 game.options.modOptions.gen3transparency.performanceMode=nil
 assert(api.performanceMode(),'Android default must enable performance mode')
 love.system.getOS=function()return 'Windows'end
 assert(not api.performanceMode(),'PC default must retain full-quality rendering')
 love.system.getOS=osName
 local color={1,1,1,.7,animation='GRADIENT',_speedGroup='background'}
 local function render(mode)
  api.customization.write(game,{performanceMode=mode,menuBorder=13,startBorderChoice=13})
  local c=G.newCanvas(640,480,{dpiscale=1})
  G.push('all');G.setCanvas(c);G.origin();G.clear(0,0,0,0);G.scale(2)
  api.borders.drawPixels(8,8,96,64,color,'start')
  assert(G.getCanvas()==c,'Panel changed its caller target')
  G.pop();local data=c:newImageData();c:release();return data
 end
 local a,b=render(0),render(1)
 for y=40,100 do for x=40,160 do
  local r,g,bb,alpha=a:getPixel(x,y);local r2,g2,b2,a2=b:getPixel(x,y)
  -- Performance shades once per logical pixel; only subpixel gradient sampling differs.
  assert(math.max(math.abs(r-r2),math.abs(g-g2),math.abs(bb-b2),math.abs(alpha-a2))<.025,'Performance rendering changed panel color/alpha')
 end end
 a:release();b:release()
 api.customization.write(game,{performanceMode=original})
 print('PASS performance defaults, toggle, alpha, target restoration and scaled colors')
end
