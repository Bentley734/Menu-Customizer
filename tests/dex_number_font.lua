local calls={};local native=0;local scope=true;local enabled=true
local H={statusTile=function()native=native+1 end}
local C={drawScope=true,theme={enabled=function()return enabled end}}
local F={draw=function(s,x,y)calls[#calls+1]={s,x,y}end}
local env=setmetatable({require=function(n)if n=='src.render.HudTiles'then return H end;return{}end},{__index=_G})
local f=assert(io.open('lib/gb_pokedex_text.lua'));local source=f:read('*a');f:close()
assert(load(source,'dex marker','t',env))()(F,function()return C end)
H.statusTile(0x74,8,56);assert(#calls==1 and calls[1][1]=='No'and calls[1][2]==8 and calls[1][3]==56)
H.statusTile(0x73,8,56);assert(native==1)
C.drawScope=false;H.statusTile(0x74,8,56);assert(native==2)
C.drawScope=true;enabled=false;H.statusTile(0x74,8,56);assert(native==3)
print('PASS dex marker font, position, native scope and disabled fallback')
