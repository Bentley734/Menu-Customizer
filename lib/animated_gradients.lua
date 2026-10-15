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
M.register({
 {key='red_psy_0',hex={'A90924','F02B3C','FF8276','6B0918'}},
 {key='red_psy_1',hex={'B7101B','EB3525','FF9A6A','7D1410'}},
 {key='red_psy_2',hex={'8F1534','DF3054','FF738A','670C2A'}},
 {key='red_psy_3',hex={'A3190E','F14325','FFA17A','731510'}},
 {key='red_psy_4',hex={'A90924','F02B3C','FF8276','6B0918'}},
 {key='red_psy_5',hex={'B7101B','EB3525','FF9A6A','7D1410'}},
 {key='red_psy_6',hex={'8F1534','DF3054','FF738A','670C2A'}},
 {key='red_psy_7',hex={'A3190E','F14325','FFA17A','731510'}},
 {key='red_psy_8',hex={'A90924','F02B3C','FF8276','6B0918'}},
 {key='red_psy_9',hex={'B7101B','EB3525','FF9A6A','7D1410'}},
 {key='red_psy_10',hex={'8F1534','DF3054','FF738A','670C2A'}},
 {key='red_psy_11',hex={'A3190E','F14325','FFA17A','731510'}},
 {key='red_psy_12',hex={'A90924','F02B3C','FF8276','6B0918'}},
 {key='red_psy_13',hex={'B7101B','EB3525','FF9A6A','7D1410'}},
 {key='red_psy_14',hex={'8F1534','DF3054','FF738A','670C2A'}},
 {key='red_psy_15',hex={'A3190E','F14325','FFA17A','731510'}},
 {key='red_psy_16',hex={'A90924','F02B3C','FF8276','6B0918'}},
 {key='red_psy_17',hex={'B7101B','EB3525','FF9A6A','7D1410'}},
 {key='red_psy_18',hex={'8F1534','DF3054','FF738A','670C2A'}},
 {key='red_psy_19',hex={'A3190E','F14325','FFA17A','731510'}},
})
M.register({
 {key='red_fire_0',hex={'8C0815','D71722','FF7836','A80D1B'}},
 {key='red_fire_1',hex={'9F1510','E22B19','FFAA45','BA2012'}},
 {key='red_fire_2',hex={'861026','D22434','FF6841','A4142C'}},
 {key='red_fire_3',hex={'8C0815','D71722','FF7836','A80D1B'}},
 {key='red_fire_4',hex={'9F1510','E22B19','FFAA45','BA2012'}},
 {key='red_fire_5',hex={'861026','D22434','FF6841','A4142C'}},
 {key='red_fire_6',hex={'8C0815','D71722','FF7836','A80D1B'}},
 {key='red_fire_7',hex={'9F1510','E22B19','FFAA45','BA2012'}},
 {key='red_fire_8',hex={'861026','D22434','FF6841','A4142C'}},
 {key='red_fire_9',hex={'8C0815','D71722','FF7836','A80D1B'}},
})
-- Dark paper is appended separately so existing palette IDs never move.
M.darkEntries={
 {key='dark_midnight',name='MIDNIGHT DRIFT',hex={'080B12','0E1422','151B2B','090E18'}},
 {key='dark_abyss',name='ABYSSAL DRIFT',hex={'061112','0A1C20','102A2C','081619'}},
 {key='dark_violet',name='VIOLET DRIFT',hex={'100A18','1C102B','28183A','140D20'}}}
M.register(M.darkEntries)
M.register({
 {key='dark_frame_midnight',hex={'111722','1B2534','30435B','151F2C'}},
 {key='dark_frame_abyss',hex={'10282C','173D43','20545A','122F35'}},
 {key='dark_frame_violet',hex={'261735','38224F','4B3068','2D1B40'}}})
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
