local location,scale
local G={push=function()end,pop=function()end,setBlendMode=function()end,origin=function()end,setShader=function()end,setScissor=function()end,setColor=function()end,
 getScissor=function()end,getColor=function()return 1,1,1,1 end,transformPoint=function(x,y)return x,y end,
 translate=function(x,y)location={x,y}end,scale=function(x,y)scale={x,y}end}
local F={draw=function()end,drawGlyph=function()end,measure=function()return 30 end,advance=function()return 6 end}
local mod={exports={menuTextPlacement={x=101,y=20,width=30,align=2,center=116}}}
local env=setmetatable({love={graphics=G}},{__index=_G})
local f=assert(io.open('lib/menu_text_surface.lua'));local source=f:read('*a');f:close()
local M=assert(load(source,'menu text surface','t',env))()(mod,F)
local q=M.capture(function()F.draw('LABEL',101,20,{})end)
for _,sx in ipairs({2.7,3.25,4.3,5})do
 M.draw(q,13,7,sx,sx,1)
 assert(scale[1]==math.floor(sx)and scale[1]==scale[2],'Noninteger text scale')
 assert(math.abs(location[1]+15*scale[1]-(13+116*sx))<=.5,'Off-centre label')
end
print('PASS Start label centering at integer and fractional window fits')
