local api=testLoader.exports.gen3transparency;local M=api.customization;local P=api.selectorPalette;local B=api.borderCatalog
local game={options=testOptions,mods=testLoader,writeOptions=function(self)self.writes=(self.writes or 0)+1 end}
local bucket=testOptions.modOptions.gen3transparency or{};testOptions.modOptions.gen3transparency=bucket;testLoader.modOptions.gen3transparency=bucket
local function find(names,name)for i,n in ipairs(names)do if n==name then return i end end;error('Missing theme design: '..name)end
local opened;local rows=M.rows(function(_,children)opened=children end)
local themeRow;for _,row in ipairs(rows)do if row.id=='wide_themeSets'then themeRow=row end end
themeRow.activate(game);assert(#opened==14)
for i,row in ipairs(opened)do
 local t=M.themes[i];local bg=find(P.menuBackgroundNames,t[2])-1;local border=find(B.choices,t[3]);local ink=find(P.names,t[5])-1
 find(P.backgroundNames,t[4]);find(P.names,t[6])
 bucket.martCustom=1;bucket.pcCustom=1;bucket.martTextColor=0;bucket.pcBackgroundColor=1;bucket.pc_fx_outline=1;bucket.mart_fx_preset=4
 local preview=row.preview();row.activate(game)
 for _,scope in ipairs({'mart','pc'})do
  assert(bucket[scope..'Custom']==1 and bucket[scope..'Theme']==2)
  assert(bucket[scope..'BorderChoice']==border and bucket[scope..'BackgroundColor']==bg and bucket[scope..'TextColor']==ink)
  assert(bucket[scope..'_fx_outline']==0 and bucket[scope..'_fx_preset']==0)
  assert(bucket[scope..'_fx_shadow_transparency']==bucket.menu_fx_shadow_transparency)
  assert(preview[scope..'BorderChoice']==bucket[scope..'BorderChoice'])
 end
 assert(bucket.dialogueBorderChoice==border and bucket.battleBorderChoice==border and bucket.introTextColor==ink)
 assert(bucket.dialogueTextColor==ink and bucket.battle_text_color==ink and bucket.battle_name_color==ink)
 assert(bucket.saveSummaryBackgroundColor==bg and bucket.allBorderChoice==border and bucket.allBackgroundColor==bg)
 if t[1]:find('DARK MODE',1,true)then
  local c=P.color('background',bg-1);assert(c.animation=='GRADIENT'and B.entries[border].animation=='gradient')
  local white=P.color('text',ink)
  for phase=0,1,.125 do
   local color=P.gradients.sample(c.gradient,phase);assert(color and math.max(color[1],color[2],color[3])<.25)
   local contrast=(.2126*white[1]+.7152*white[2]+.0722*white[3]+.05)/(.2126*color[1]+.7152*color[2]+.0722*color[3]+.05)
   assert(contrast>4.5,'dark theme readability lost')
  end
 end
end
-- Global edits must reach active custom surfaces and not reactivate old styles.
bucket.menuTextColor=6;bucket.menuBackgroundColor=4;bucket.menuTheme=2;bucket.pcCustom=0;bucket.pcTextColor=2;bucket.pcBackgroundColor=1
M.write(game,M.globalValues('allBorderChoice',14))
assert(bucket.pcCustom==1 and bucket.pcTextColor==6 and bucket.pcBackgroundColor==4 and bucket.pcBorderChoice==14)
M.write(game,M.globalValues('allBackgroundColor',5));assert(bucket.martBackgroundColor==5 and bucket.pcBackgroundColor==5 and bucket.battle_background_color==4)
M.write(game,M.globalValues('allTextColor',6));assert(bucket.martTextColor==6 and bucket.pcTextColor==6 and bucket.battle_name_color==6)
M.write(game,M.globalValues('allTextShadowColor',1));assert(bucket.martTextShadowColor==1 and bucket.pcTextShadowColor==1)
M.write(game,M.globalValues('allShadowOpacity',40));assert(bucket.mart_fx_shadow_transparency==60 and bucket.pc_fx_shadow_transparency==60)
if api.gbMenus then api.gbMenus.persist(game,'allBorderChoice',15);assert(bucket.martBorderChoice==15 and bucket.pcBorderChoice==15)
else
 local seen={};for _,row in ipairs(rows)do if row.id=='wide_allBorderChoice'or row.id=='wide_allBackgroundColor'then row.step(game,1);seen[row.id]=true end end
 assert(seen.wide_allBorderChoice and seen.wide_allBackgroundColor,'Gen 3 lacks global border/background controls')
end
assert(not M.preview and not api.menuSurfaces.current,'theme preview leaked')
print('PASS fourteen full themes, animated dark contrast, new surfaces, globals and inactive-profile migration')
