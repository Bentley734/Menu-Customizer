-- Run after the sandbox boot fixture; verify actual picker callbacks and IDs.
local api=testLoader.exports.gen3transparency
local opened,title
local function open(t,rows)title=t;opened=rows end
local raw=api.customization.rows(open)
for _,r in ipairs(api.menuSurfaces.rows(open))do raw[#raw+1]=r end
for _,key in ipairs({'introTheme','introBackgroundColor','introTextShadowColor'})do raw[#raw+1]={id='wide_'..key,label=key}end
local organize=assert(loadfile(sourceRoot..'/lib/menu_organization.lua'))()
local rows=organize(raw,open)
local found={}
local function scan(list,path)
 for _,r in ipairs(list)do
  assert(r.id~='wide_surface_mart'and r.id~='wide_surface_pc'and r.id~='wide_introSettings')
  found[r.id]={row=r,path=path}
  if r.children then scan(type(r.children)=='function'and r.children()or r.children,path..'/'..r.label)end
 end
end
scan(rows,'MENUS')
for _,scope in ipairs({'mart','pc'})do
 for suffix,page in pairs({Theme='FONT AND LAYOUT',BorderChoice='BORDERS',BackgroundColor='BACKGROUNDS',TextColor='COLORS',TextShadowColor='SHADOWS'})do
  local f=assert(found['surface_'..scope..suffix],scope..suffix)
  assert(f.path:find(page,1,true),f.path)
  assert(f.row.label:find(scope=='mart'and'POKE MART'or'PC',1,true))
 end
end
for id,f in pairs(found)do
 if id:find('intro',1,true)then assert(not f.path:find('INTRO / START SCREEN',1,true))end
end
local catalog=api.borderCatalog;local seen={};local visible=0
for _,g in ipairs(catalog.groups())do
 assert(g.label=='ANIMATED BORDERS'or g.label=='GAME BORDERS'or g.label=='CLASSIC POKEMON FRAMES')
 for _,c in ipairs(g.choices)do assert(not seen[c.id]);seen[c.id]=true;visible=visible+1 end
end
for i,e in ipairs(catalog.entries)do assert(not not seen[i]==not e.hidden)end
local P=api.selectorPalette
for _,kind in ipairs({'background','menuBackground'})do
 local groups=P.groups(kind);local seen={};local designs
 for _,g in ipairs(groups)do
  assert(not g.label:find('RED FIRE')and not g.label:find('BLACK')and g.label~='TRIPPY'and not g.label:find('POKEMON'))
  if g.label=='DESIGNS'then designs=g end
  for _,id in ipairs(g.ids)do assert(not seen[id]);seen[id]=true end
 end
 assert(designs and #designs.ids>40)
 local selected=designs.ids[#designs.ids];local saved
 local row=P.picker({id='wide_menuBackgroundColor',label='BACKGROUND'},kind,function()return selected end,function(_,id)saved=id end,open)
 row.activate({});for _,r in ipairs(opened)do if r.label=='DESIGNS'then r.activate({});break end end
 assert(title=='DESIGNS')
 local selectedRow
 for _,r in ipairs(opened)do assert(not r.group);if r.selected()then selectedRow=r end end
 assert(selectedRow);selectedRow.activate({});assert(saved==selected)
end
print('PASS categorized surface/intro settings, consolidated complete design lists and stable selection callbacks')
