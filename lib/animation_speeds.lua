-- Saved per-design rates; old shared rates are read only as a migration fallback.
return function(mod)
 local M={};mod.exports.animationSpeeds=M
 function M.id(color)return color and(color.pokemon or color.gradient or color.animation)end
 function M.get(group,id,fallback)
  local n=tonumber(mod.options:get('animationSpeed_'..group..'_'..tostring(id)))
  return math.max(0,math.min(400,n or fallback or 100))
 end
 function M.rows(openPage)
  local P=mod.exports.selectorPalette;local catalog=mod.exports.borderCatalog or assert(load(assert(mod:read('lib/border_catalog.lua'))))()
  local result={};local specs={{'background','BACKGROUNDS',P.backgroundNames,'background'},{'text','ANIMATED TEXT COLORS',P.names,'text'},{'border','BORDERS'}}
  for _,spec in ipairs(specs)do
   local group,title=spec[1],spec[2];local rows={};local seen={}
   local function add(id,label)
    if seen[id]then return end;seen[id]=true
    local key='animationSpeed_'..group..'_'..tostring(id)
    local function current()return M.get(group,id,tonumber(mod.options:get('menu_fx_speed'))or 100)end
    rows[#rows+1]={id='wide_'..key,label=label,value=function()return current()==0 and'PAUSED'or current()..'%'end,
     step=function(ctx,d)mod.exports.customization.write(ctx,{[key]=(current()+(d or 1)*25)%425});return false end}
   end
   if group=='border'then
    for i,e in ipairs(catalog.entries)do if e.animation and not e.hidden then add(i,e.label)end end
   else
    for i,name in ipairs(spec[3])do local c=P.color(spec[4],i-1)
     local e=c.pokemon and P.pokemonBackgrounds.byKey[c.pokemon]
     if c.animation and not(e and e.hidden)then add(M.id(c),name)end
    end
   end
   table.sort(rows,function(a,b)return a.label<b.label end)
   local label=group=='text'and'ANIMATED COLOR SPEEDS'or'ANIMATION SPEEDS'
   result[#result+1]={id='wide_animationSpeeds_'..group,label=label,group=true,children=rows,
    value=function()return #rows..' DESIGNS'end,activate=function(ctx)return openPage(title..' ANIMATION SPEEDS',rows,ctx)end}
  end
  return result
 end
 return M
end
