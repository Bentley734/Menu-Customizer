-- Shared cyclic palettes for fonts, paper and frames. Interpolate in RGB with
-- smooth joins, including the last-to-first join; no abrupt primary-colour steps.
local M={entries={
 {key='aurora',name='AURORA',hex={'7657E8','438CD9','46C6B2','98DEA3'}},
 {key='violet',name='AMETHYST TIDE',hex={'492C91','966BE5','728DEB','364EA3'}},
 {key='lagoon',name='MINT LAGOON',hex={'126B89','39B8CB','94E4C4','36AD91'}},
 {key='dream',name='DREAM MIST',hex={'BBA4EF','A2CAEF','B5E5D0','D4BDED'}},
 {key='cosmos',name='DEEP SPACE',hex={'292957','6543AC','A26CCB','3DA7BD'}},
 {key='forest',name='MOONLIT FOREST',hex={'214957','318476','76C595','567FB2'}},
 {key='candy',name='COTTON CANDY',hex={'E9A0C4','B3A0E9','8BC6E9','DAB2EE'}},
 {key='sunset',name='SUNSET DREAM',hex={'EBA17A','E27CA4','AF6AC8','6D6CBA'}},
 {key='ember',name='GOLDEN HOUR',hex={'C78B3F','EDC47C','DE9D94','AC8FB7'}},
}}
M.byKey={}
for _,entry in ipairs(M.entries)do
 entry.stops={}
 for _,h in ipairs(entry.hex)do entry.stops[#entry.stops+1]={tonumber(h:sub(1,2),16)/255,tonumber(h:sub(3,4),16)/255,tonumber(h:sub(5,6),16)/255}end
 M.byKey[entry.key]=entry
end
function M.register(entries)
 for _,entry in ipairs(entries)do
  local e={stops={}}
  for _,h in ipairs(entry.hex)do e.stops[#e.stops+1]={tonumber(h:sub(1,2),16)/255,tonumber(h:sub(3,4),16)/255,tonumber(h:sub(5,6),16)/255}end
  M.byKey[entry.key]=e
 end
end
function M.sample(key,t)
 local entry=M.byKey[key];if not entry then return nil end
 local pos=(t%1)*4;local i=math.floor(pos);local f=pos-i;f=f*f*(3-2*f)
 local a,b=entry.stops[i+1],entry.stops[(i+1)%4+1]
 return {a[1]+(b[1]-a[1])*f,a[2]+(b[2]-a[2])*f,a[3]+(b[3]-a[3])*f,1}
end
M.glsl=[[
 extern bool customGradient;extern vec3 stopA;extern vec3 stopB;extern vec3 stopC;extern vec3 stopD;
 vec3 gradientColor(float phase){
  float h=fract(phase);
  if(!customGradient)return clamp(abs(fract(h+vec3(0.0,2.0/3.0,1.0/3.0))*6.0-3.0)-1.0,0.0,1.0);
  float p=h*4.0;float f=smoothstep(0.0,1.0,fract(p));
  if(p<1.0)return mix(stopA,stopB,f);if(p<2.0)return mix(stopB,stopC,f);
  if(p<3.0)return mix(stopC,stopD,f);return mix(stopD,stopA,f);
 }
]]
function M.send(shader,key,prefix)
 local entry=M.byKey[key];prefix=prefix or ''
 shader:send(prefix..'customGradient',entry~=nil)
 local stops=entry and entry.stops or {{1,0,0},{1,1,0},{0,1,1},{.5,0,1}}
 for i,label in ipairs({'stopA','stopB','stopC','stopD'})do shader:send(prefix..label,stops[i])end
end
return M
