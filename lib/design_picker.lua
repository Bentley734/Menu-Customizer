-- Keep stored selection IDs intact; organize only the navigation surface.
return function(row,groups,get,persist,openPage)
 row.group=true
 row.activate=function(ctx)
  local rows={}
  if row.id and row.id:match('BorderChoice$')then
   rows[#rows+1]={id=row.id..':inherit',label='USE MENU BORDER',value=function()return get()==0 and 'SELECTED'or'USE'end,
    activate=function(selectCtx)return persist(selectCtx or ctx,0)end}
  end
  for _,group in ipairs(type(groups)=='function'and groups()or groups)do
   local g=group
   local function choices(nextCtx)
    local items={}
    for _,choice in ipairs(g.choices)do
     local c=choice
     items[#items+1]={id=row.id..':choice:'..c.id,label=c.label,colorChoice=true,preview=function()
       local key=row.id:gsub('^wide_',''):gsub('^fx_','')
       local custom=row.customization
       return custom and custom.values(key,c.id)or {[key]=c.id}
      end,
      value=function()return get()==c.id and 'SELECTED'or'USE'end,
      selected=function()return get()==c.id end,
      activate=function(selectCtx)return persist(selectCtx or nextCtx or ctx,c.id)end}
    end
    return openPage(g.label,items,nextCtx or ctx)
   end
   if #g.choices==1 and row.id and row.id:find('Border',1,true)then
    local c=g.choices[1]
    rows[#rows+1]={id=row.id..':choice:'..c.id,label=c.label,colorChoice=true,
     preview=function()local key=row.id:gsub('^wide_',''):gsub('^fx_','');local custom=row.customization;return custom and custom.values(key,c.id)or {[key]=c.id}end,
     value=function()return get()==c.id and 'SELECTED'or'USE'end,
     selected=function()return get()==c.id end,
     activate=function(selectCtx)return persist(selectCtx or ctx,c.id)end}
   else
   rows[#rows+1]={id=row.id..':design:'..g.label,label=g.label,group=true,
    value=function()return #g.choices..' OPTIONS'end,
    selected=function()for _,c in ipairs(g.choices)do if get()==c.id then return true end end;return false end,
    activate=choices}
   end
  end
  return openPage(row.label,rows,ctx)
 end
 return row
end
