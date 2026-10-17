local f=assert(io.open('lib/menu_organization.lua'));local source=f:read('*a');f:close()
local organize=assert(load(source))();local entries={}
for _,scope in ipairs({'menu','start','battle'})do for _,suffix in ipairs({'stardew','stardew_jumps','stardew_speed','stardew_height'})do
 entries[#entries+1]={id='fx_'..scope..'_fx_'..suffix,label=scope:upper()..' STARDEW '..suffix,step=function()return 'same'end}
end end
for _,key in ipairs({'','Jumps','Speed','Height'})do entries[#entries+1]={id='wide_stardewSelector'..key,label='STARDEW '..key}end
local pages=organize(entries,function(title,children)return title,children end);local count=0
local function check(rows,inside)
 for _,row in ipairs(rows)do
  local scoped=inside or row.label=='STARDEW'
  if row.children then check(row.children,scoped)
  elseif(row.id or''):lower():find('stardew',1,true)then assert(scoped,'Loose Stardew setting');count=count+1;if row.step then assert(row.step()=='same')end end
 end
end
check(pages,false);assert(count==16,'Lost a saved setting control');print('PASS scoped Stardew pages, selectors and callback preservation')
