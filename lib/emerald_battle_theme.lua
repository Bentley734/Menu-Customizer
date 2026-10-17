-- Preserve native gauge coordinates, HP rounding and animation values.
return function(mod,ui,enabled)
 local Version=require('src.core.GameVersion');local C=require('src.ui.game3.battle_chrome')
 local F=require('src.ui.game3.frlg_font');local G=love.graphics
 local function active()return enabled()and Version.get()=='emerald'and ui.setting('style',1)==3 end
 local function paint(key,fallback,x,y,w,h)
  local P=mod.exports.selectorPalette;local n=tonumber(mod.options:get(key))
  if n and n>=0 then return P.paint(P.color('text',n),G.rectangle,'fill',x,y,w,h)end
  G.setColor(fallback);G.rectangle('fill',x,y,w,h)
 end
 local M={};mod.exports.emeraldBattleTheme=M
 function M.rows(openPage)
  if Version.get()~='emerald'then return{}end
  local P=mod.exports.selectorPalette;local rows={}
  for _,spec in ipairs({{'battleBarOutlineColor','HP BAR OUTLINE'},{'battleBarFillColor','HP BAR FILL'},{'battleExpOutlineColor','XP BAR OUTLINE'},{'battleExpFillColor','XP BAR FILL'}})do
   local key,label=spec[1],spec[2]
   local function value()return tonumber(mod.options:get(key))or -1 end
   local function write(ctx,n)mod.exports.customization.write(ctx,{[key]=n});return false end
   local row={id='wide_'..key,label='BATTLE '..label,value=function()return value()<0 and'NATIVE'or P.names[value()+1]end,
    step=function(ctx,d)return write(ctx,((value()+1+(d or 1))%(#P.names+1))-1)end}
   P.picker(row,'text',function()return math.max(0,value())end,write,openPage);rows[#rows+1]=row
  end
  return rows
 end
 local hp=C.drawHpBar
 C.drawHpBar=function(x,y,value,maximum,status,...)
  if not active()then return hp(x,y,value,maximum,status,...)end
  G.push('all');G.setShader()
  local color=C.hpColor(value,maximum);local fill=color=='red'and{.85,.15,.12,1}or color=='yellow'and{.95,.75,.15,1}or{.2,.8,.25,1}
  local options={small=true,maxWidth=15,colors=ui.palette.colors('battle')}
  local theme=F._menuCustomizerEmerald
  if tonumber(mod.options:get('menuTheme'))==2 and theme then
   local prior=mod.exports.battleFontScope;mod.exports.battleFontScope=false
   local ok,err=pcall(theme.draw,'HP',x,y-3,options);mod.exports.battleFontScope=prior
   if not ok then G.pop();error(err,0)end
  else F.draw('HP',x,y-3,options)end
  local extent=math.max(8,math.min(48,232-x-16))
  paint('battleBarOutlineColor',{0,0,0,1},x+16,y,extent,6)
  G.setColor(.15,.15,.15,1);G.rectangle('fill',x+17,y+1,extent-2,4)
  local ratio=C.scaledHpFraction(value,maximum,extent-2)
  local width=math.max(0,math.min(extent-2,math.floor(ratio)))
  if width>0 then paint('battleBarFillColor',fill,x+17,y+1,width,4)end
  G.pop()
 end
 local tile=C.drawElementTile
 if tile then C.drawElementTile=function(id,...)
  if active()and(id==116 or id==117)then return end
  return tile(id,...)
 end end
 local bold=C.drawHpBoldChar
 if bold then C.drawHpBoldChar=function(ch,x,y,...)
  if not active()then return bold(ch,x,y,...)end
  F.draw(ch,x,y-2,{small=true,colors=ui.palette.colors('battle')});return true
 end end
 local xp=C.drawExpBar
 C.drawExpBar=function(x,y,ratio,...)
  if not active()then return xp(x,y,ratio,...)end
  G.push('all');G.setShader()
  paint('battleExpOutlineColor',{0,0,0,1},x,y-1,64,4)
  G.setColor(.15,.15,.15,1);G.rectangle('fill',x+1,y,62,2)
  local width=math.max(0,math.min(62,math.floor((tonumber(ratio)or 0)*62+.5)))
  if width>0 then paint('battleExpFillColor',{.2,.55,1,1},x+1,y,width,2)end
  G.pop()
 end
end
