local choice,version=1,'firered'
local seen={};local F={}
for _,key in ipairs({'draw','drawGlyph','measure','advance','wrap'})do
 F[key]=function(...)seen[key]={...};return 7 end
end
local function build()
 local mod={generation=3,exports={},options={get=function()return choice end}}
 local env=setmetatable({require=function(name)
  if name=='src.core.GameVersion'then return{get=function()return version end}end
  if name=='src.ui.game3.frlg_font'then return F end
 end},{__index=_G})
 local f=assert(io.open('lib/frlg_text_size.lua'));local source=f:read('*a');f:close()
 return assert(load(source,'frlg size','t',env))()(mod)
end
local M=build();M.install();local opts={font='narrow',maxWidth=70,colors={fg={1,1,1,1}}}
F.draw('LABEL',10,20,opts);assert(seen.draw[4]==opts,'Normal must preserve native options')
choice=2
F.draw('LABEL',10,20,opts);assert(seen.draw[4].small and seen.draw[4].font=='small')
assert(opts.font=='narrow'and not opts.small,'Source options mutated')
F.measure('LABEL',opts);assert(seen.measure[2].font=='small')
F.wrap('LABEL',70,opts);assert(seen.wrap[3].small)
local vanilla={_vanilla=true};F.draw('HP',0,0,vanilla);assert(seen.draw[4]==vanilla)
for _,v in ipairs({'ruby','sapphire','emerald'})do
 version=v;F.draw('LABEL',10,20,opts);assert(seen.draw[4]==opts,'RSE options altered')
end
version='leafgreen';local old=F.draw;M=build();M.install();assert(F.draw==old,'Reload stacked duplicate wrappers')
choice=1;F.draw('LABEL',0,0,opts);assert(seen.draw[4]==opts,'New profile inherited stale small choice')
print('PASS FRLG native/small atlas sizing, option immutability, reload and RSE isolation')
