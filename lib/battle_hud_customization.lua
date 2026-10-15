-- Gen 1 status tiles, scoped to battle HUD drawing (including KIM capture).
return function(mod)
 local M={};mod.exports.battleHudCustomization=M
 local unpack=unpack or table.unpack;local role;local masks=setmetatable({},{__mode='k'});local shader
 local roles={{'Level','LEVEL / STATUS'},{'HP','HP TEXT'},{'Frame','STATUS FRAME'}}
 function M.rows(openPage)
  if mod.generation~=1 then return{}end
  local P=mod.exports.selectorPalette;local C=mod.exports.customization;local rows={}
  for _,spec in ipairs(roles)do
   for _,shade in ipairs({false,true})do
    local key='battleHud'..spec[1]..(shade and'ShadowColor'or'Color');local kind=shade and'shadow'or'text';local names=shade and P.shadowNames or P.names
    local function value()return tonumber(mod.options:get(key))end
    local function write(ctx,n)C.write(ctx,{[key]=n});return false end
    local row={id='wide_'..key,label='BATTLE '..spec[2]..(shade and' SHADOW'or' COLOR'),value=function()local n=value();return n and names[n+1]or'NATIVE'end,
     step=function(ctx,d)return write(ctx,((value()or 0)+(d or 1))%#names)end}
    P.picker(row,kind,function()return value()or 0 end,write,openPage);rows[#rows+1]=row
   end
  end
  rows[#rows+1]={id='wide_battleHudFrameVisible',label='BATTLE STATUS FRAME',value=function()return mod.options:get('battleHudFrameVisible')==0 and'HIDDEN'or'VISIBLE'end,
   step=function(ctx)C.write(ctx,{battleHudFrameVisible=mod.options:get('battleHudFrameVisible')==0 and 1 or 0});return false end}
  local key='battleEmptySlotColor'
  local function value()return tonumber(mod.options:get(key))or 6 end
  local function write(ctx,n)C.write(ctx,{[key]=n});return false end
  local row={id='wide_'..key,label='BATTLE EMPTY PARTY SLOTS COLOR',value=function()return P.names[value()+1]end,step=function(ctx,d)return write(ctx,(value()+(d or 1))%#P.names)end}
  P.picker(row,'text',value,write,openPage);rows[#rows+1]=row
  return rows
 end
 function M.install()
  if mod.generation~=1 then return end
  local G=love.graphics;local F=require('src.render.Font');local original=F.draw
  local B=require('src.battle.BattleState');local nativeBalls=B.drawBallRow
  local ball={ '..1111..','.122221.','12222221','11133111','14433441','14444441','.144441.','..1111..' }
  local ring={ '..1111..','.1....1.','1......1','1......1','1......1','1......1','.1....1.','..1111..' }
  B.drawBallRow=function(self,party,x,y,dx)
   local gb=mod.exports.gbMenus
   if not(gb and gb.live())then return nativeBalls(self,party,x,y,dx)end
   local P=mod.exports.selectorPalette
   G.push('all');G.setShader()
   for i=1,6 do
    local mon=party[i];local bx=x+(i-1)*dx
    if not mon then
     P.effects.paint(P.color('text',tonumber(mod.options:get('battleEmptySlotColor'))or 6),'battle',function()
      for py,line in ipairs(ring)do for px=1,8 do if line:sub(px,px)=='1'then G.rectangle('fill',bx+px-1,y+py-1,1,1)end end end
     end)
    else
     local colors={{0,0,0,1},{.9,.08,.1,1},{.55,.55,.55,1},{1,1,1,1}}
     if mon.hp and mon.hp<=0 then colors[2]={.3,.3,.3,1};colors[4]={.55,.55,.55,1}
     elseif mon.status then colors[3]={1,.8,.1,1}end
     for py,line in ipairs(ball)do for px=1,8 do local col=colors[tonumber(line:sub(px,px))];if col then G.setColor(col);G.rectangle('fill',bx+px-1,y+py-1,1,1)end end end
    end
    if not mod.exports.battleHudCapture then require('src.render.PaletteFX').markTrueColor(bx,y,8,8)end
   end
   G.pop()
  end

  F.draw=function(text,x,y,...)
   local prior=role
   if mod.exports.battleHudScope and not mod.exports.battleNameScope then
    if y==8 or y==64 then role='Level'elseif y==80 then role='HP'end
   end
   local result={pcall(original,text,x,y,...)};role=prior
   if not result[1]then error(result[2],0)end;return unpack(result,2)
  end
  local draw=G.draw;local Assets=require('src.render.Assets');local images={};local loaded=false
  local function tiles()
   if loaded then return end;loaded=true
   local data=require('src.core.Data');local pages=data.font and data.font.pages or{}
   for _,p in ipairs({{'font_battle_extra',0x62},{'battle_hud_1',0x6D},{'battle_hud_2',0x73},{'battle_hud_3',0x76}})do
    local entry=pages[p[1]];local path=entry and entry.image or'assets/generated/battle/'..p[1]..'.png'
    local ok,image=pcall(Assets.image,path);if ok then images[image]=entry and entry.base or p[2]end
   end
  end
  local function mask(image,quad)
   local byQuad=masks[image];if not byQuad then byQuad={};masks[image]=byQuad end
   local key=quad or false;if byQuad[key]then return byQuad[key]end
   local w,h=image:getDimensions();if quad then local x,y; x,y,w,h=quad:getViewport()end
   if not shader then shader=G.newShader([[vec4 effect(vec4 c,Image t,vec2 uv,vec2 p){vec4 s=Texel(t,uv);return vec4(1.0,1.0,1.0,s.a*(1.0-min(s.r,min(s.g,s.b))));}]])end
   local canvas=G.newCanvas(w,h);local old=G.getCanvas();G.push('all');G.setCanvas(canvas);G.origin();G.setScissor();G.clear(0,0,0,0);G.setColor(1,1,1,1);G.setShader(shader);G.setBlendMode('replace','premultiplied')
   if quad then draw(image,quad,0,0)else draw(image,0,0)end
   G.setCanvas(old);G.pop();canvas:setFilter('nearest','nearest');byQuad[key]=canvas;return canvas
  end
  G.draw=function(image,...)
   if not mod.exports.battleHudScope then return draw(image,...)end
   local args={...};local quad=type(args[1])=='userdata'and args[1].typeOf and args[1]:typeOf('Quad')and args[1]or nil
   local chosen=role
   if not chosen then
    tiles();local base=images[image]
    if base and quad then
     local x,y=quad:getViewport();local width=image:getWidth();local code=base+y/8*(width/8)+x/8
     if code==0x6E then chosen='Level'
     elseif code==0x71 then chosen='HP'
     elseif code==0x73 or code==0x74 or code==0x76 or code==0x77 or code==0x78 or code==0x6F then chosen='Frame'end
    end
   end
   if not chosen then return draw(image,...)end
   if chosen=='Frame'and mod.options:get('battleHudFrameVisible')==0 then return end
   local fg=tonumber(mod.options:get('battleHud'..chosen..'Color'));local shadow=tonumber(mod.options:get('battleHud'..chosen..'ShadowColor'))
   if fg==nil and shadow==nil then return draw(image,...)end
   local P=mod.exports.selectorPalette;local ink=mask(image,quad)
   if quad then table.remove(args,1)end
   G.push('all');G.setShader();G.setBlendMode('alpha','alphamultiply')
   local oldRole=role;role=nil
   local ok,err=pcall(function()
    if shadow and shadow>0 then
     local shadowArgs={unpack(args)};shadowArgs[1]=(shadowArgs[1]or 0)+1;shadowArgs[2]=(shadowArgs[2]or 0)+1
     P.effects.paint(P.color('shadow',shadow),'battle',function()draw(ink,unpack(shadowArgs))end)
    end
    P.effects.paint(P.color('text',fg or 0),'battle',function()draw(ink,unpack(args))end)
   end)
   role=oldRole;G.pop();if not ok then error(err,0)end
   if not mod.exports.battleHudCapture then
    local FX=require('src.render.PaletteFX');if FX.markTrueColor then FX.markTrueColor(args[1]or 0,args[2]or 0,ink:getWidth()*(args[4]or 1),ink:getHeight()*(args[5]or args[4]or 1))end
   end
  end
 end
 return M
end
