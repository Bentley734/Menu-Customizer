local E=testLoader.exports.gen3transparency
local P=E.selectorPalette
local function page()end
for _,r in ipairs(E.customization.rows(page))do assert(r.id~='wide_themeSets','Presets still exposed')end
local rows=E.menuSurfaces.rows(page);local scopes={}
for _,r in ipairs(rows)do scopes[r.id:gsub('^wide_surface_','')]=r end
for _,scope in ipairs({'bag','party'})do
 assert(scopes[scope],scope..' missing')
 for _,suffix in ipairs({'Custom','Theme','BorderChoice','BackgroundColor','TextColor','TextShadowColor'})do
  local found=false;for _,r in ipairs(scopes[scope].children)do if r.id=='surface_'..scope..suffix then found=true end end
  assert(found,scope..suffix..' missing')
 end
 local values=E.customization.globalValues('allBackgroundColor',7)
 assert(values[scope..'Custom']==1 and values[scope..'BackgroundColor']==7,'global surface mismatch')
end
for _,kind in ipairs({'text','shadow','background','menuBackground'})do
 local groups=P.groups(kind);local visible={};local count=0
 for _,g in ipairs(groups)do for _,id in ipairs(g.ids)do
  assert(not visible[id],'duplicate picker ID');visible[id]=true;count=count+1
  assert(P.canonical(kind,id)==id,'duplicate alias exposed')
  local c=kind=='menuBackground'and id==0 and{}or P.color(kind=='menuBackground'and'background'or kind,kind=='menuBackground'and id-1 or id)
  assert(not(c.pokemon and P.pokemonBackgrounds.byKey[c.pokemon].still),'static Pokemon visible')
 end end
 assert(count>20,'palette unexpectedly empty')
 local n=next(visible)
 for _=1,count do n=P.step(kind,n,1);assert(visible[n],'arrow navigated to retired choice')end
end
for _,name in ipairs({'MATRIX GREEN','MATRIX CYAN','MATRIX VIOLET','MATRIX SPECTRUM','MATRIX AMBER'})do
 local bg,border=false,false
 for _,g in ipairs(P.groups('background'))do for _,id in ipairs(g.ids)do if P.backgroundNames[id+1]==name then bg=true end end end
 for _,g in ipairs(E.borderCatalog.groups())do for _,e in ipairs(g.choices)do if e.label==name then border=true end end end
 assert(bg and border,name..' not available as background and border')
end
