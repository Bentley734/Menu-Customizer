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
  assert(r.id~='wide_surface_mart'and r.id~='wide_surface_pc'and r.id~='wide_surface_dialogue'and r.id~='wide_introSettings')
  found[r.id]={row=r,path=path}
  if r.children then scan(type(r.children)=='function'and r.children()or r.children,path..'/'..r.label)end
 end
end
scan(rows,'MENUS')
assert(found.wide_textCase.path=='MENUS/TEXT/DECAPITALIZATION')
for _,scope in ipairs(api.textScopes.scopes)do assert(found['wide_'..scope[1]..'TextCase'].path=='MENUS/TEXT/DECAPITALIZATION')end
for _,scope in ipairs({'mart','pc','dialogue'})do
 for suffix,page in pairs({Theme='FONT AND LAYOUT',BorderChoice='BORDERS',BackgroundColor='BACKGROUNDS',TextColor='COLORS',TextShadowColor='SHADOWS'})do
  local f=assert(found['surface_'..scope..suffix],scope..suffix)
  assert(f.path:find(page,1,true),f.path)
  assert(f.row.label:find(scope=='mart'and'POKE MART'or scope=='pc'and'PC'or'DIALOGUE',1,true))
 end
end
assert(found.wide_allFonts.path=='MENUS/TEXT/FONT AND LAYOUT')
for id,f in pairs(found)do
 if id:find('intro',1,true)then assert(not f.path:find('INTRO / START SCREEN',1,true))end
end
local catalog=api.borderCatalog;local seen={};local visible=0
for _,g in ipairs(catalog.groups())do
 assert(#g.choices<=24,'Oversized border submenu')
 for _,c in ipairs(g.choices)do assert(not seen[c.id]);seen[c.id]=true;visible=visible+1 end
end
for i,e in ipairs(catalog.entries)do assert(not not seen[i]==not e.hidden)end
local P=api.selectorPalette
for _,kind in ipairs({'background','menuBackground'})do
 local groups=P.groups(kind);local seen={};local designs
 for _,g in ipairs(groups)do
  assert(g.label~='DESIGNS','Uncategorized wallpaper list remains')
  if g.label=='VERSION GRADIENTS'then designs=g end
  for _,id in ipairs(g.ids)do assert(not seen[id]);seen[id]=true end
 end
 assert(designs and #designs.ids==7)
 local selected=designs.ids[#designs.ids];local saved
 local row=P.picker({id='wide_menuBackgroundColor',label='BACKGROUND'},kind,function()return selected end,function(_,id)saved=id end,open)
 row.activate({});for _,r in ipairs(opened)do if r.label=='VERSION GRADIENTS'then r.activate({});break end end
 assert(title=='VERSION GRADIENTS')
 local selectedRow
 for _,r in ipairs(opened)do assert(not r.group);if r.selected()then selectedRow=r end end
 assert(selectedRow);selectedRow.activate({});assert(saved==selected)
end
-- Contextual labels omit redundant words without altering raw rows.
local examples={{id='wide_startMenuBackgroundColor',label='START BACKGROUND'},
 {id='wide_allBorderChoice',label='ALL BORDERS'},
 {id='wide_menuTextColor',label='MENU TEXT COLOR'},
 {id='wide_menuTextShadowColor',label='MENU TEXT SHADOW'},
 {id='wide_introFontSize',label='INTRO / START TEXT SIZE'}}
local clean=organize(examples,open);local labels={}
local function collect(list)for _,r in ipairs(list)do labels[r.id]=r.label;if r.children then collect(r.children)end end end
collect(clean)
assert(labels.wide_startMenuBackgroundColor=='START'and labels.wide_allBorderChoice=='ALL')
assert(labels.wide_menuTextColor=='MENU'and labels.wide_menuTextShadowColor=='MENU')
assert(labels.wide_introFontSize=='INTRO / START SIZE')
assert(examples[1].label=='START BACKGROUND','Source labels mutated')
print('PASS categorized surface/intro settings, themed complete design lists and stable selection callbacks')

local gen={}
for _,g in ipairs(catalog.groups())do
 assert(not g.label:find('GAME BORDERS',1,true))
 for _,choice in ipairs(g.choices)do local e=catalog.entries[choice.id]
  if e.path and e.path:find('rby_',1,true)then assert(g.label=='GEN 1')end
  if e.path and e.path:find('gsc_',1,true)then assert(g.label=='GEN 2')end
  if e.generation==4 then assert(g.label=='GEN 4');gen[#gen+1]=choice.id end
 end
end
assert(#gen==22,'Missing imported Gen IV frames')
print('PASS generation-sorted game borders, preserved catalog IDs, 22 Gen IV imports')
