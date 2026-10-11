-- Unique pixel-identical atlases; old numeric selections migrate to their equivalent.
local C={entries={
 {label="DEFAULT"},
 {label="FR/LG 01",path="assets/borders/frlg_01.png"},
 {label="FR/LG 02 / EMERALD 02 / R/S 02",path="assets/borders/frlg_02.png"},
 {label="FR/LG 03",path="assets/borders/frlg_03.png"},
 {label="FR/LG 04",path="assets/borders/frlg_04.png"},
 {label="FR/LG 05",path="assets/borders/frlg_05.png"},
 {label="FR/LG 06",path="assets/borders/frlg_06.png"},
 {label="FR/LG 07",path="assets/borders/frlg_07.png"},
 {label="FR/LG 08",path="assets/borders/frlg_08.png"},
 {label="FR/LG 09",path="assets/borders/frlg_09.png"},
 {label="FR/LG 10",path="assets/borders/frlg_10.png"},
 {label="EMERALD 01 / R/S 01",path="assets/borders/emerald_01.png"},
 {label="EMERALD 03 / R/S 03",path="assets/borders/emerald_03.png"},
 {label="EMERALD 04 / R/S 04",path="assets/borders/emerald_04.png"},
 {label="EMERALD 05",path="assets/borders/emerald_05.png"},
 {label="EMERALD 06 / R/S 06",path="assets/borders/emerald_06.png"},
 {label="EMERALD 07",path="assets/borders/emerald_07.png"},
 {label="EMERALD 08 / R/S 08",path="assets/borders/emerald_08.png"},
 {label="EMERALD 09",path="assets/borders/emerald_09.png"},
 {label="EMERALD 10",path="assets/borders/emerald_10.png"},
 {label="EMERALD 11 / R/S 11",path="assets/borders/emerald_11.png"},
 {label="EMERALD 12",path="assets/borders/emerald_12.png"},
 {label="EMERALD 13",path="assets/borders/emerald_13.png"},
 {label="EMERALD 14",path="assets/borders/emerald_14.png"},
 {label="EMERALD 15 / R/S 15",path="assets/borders/emerald_15.png"},
 {label="EMERALD 16 / R/S 16",path="assets/borders/emerald_16.png"},
 {label="EMERALD 17",path="assets/borders/emerald_17.png"},
 {label="EMERALD 18 / R/S 18",path="assets/borders/emerald_18.png"},
 {label="EMERALD 19",path="assets/borders/emerald_19.png"},
 {label="EMERALD 20 / R/S 20",path="assets/borders/emerald_20.png"},
 {label="R/S 05",path="assets/borders/rs_05.png"},
 {label="R/S 07",path="assets/borders/rs_07.png"},
 {label="R/S 09",path="assets/borders/rs_09.png"},
 {label="R/S 10",path="assets/borders/rs_10.png"},
 {label="R/S 12",path="assets/borders/rs_12.png"},
 {label="R/S 13",path="assets/borders/rs_13.png"},
 {label="R/S 14",path="assets/borders/rs_14.png"},
 {label="R/S 17",path="assets/borders/rs_17.png"},
 {label="R/S 19",path="assets/borders/rs_19.png"},
 {label="R/B/Y",path="assets/borders/rby_01.png"},
 {label="G/S/C 01",path="assets/borders/gsc_01.png"},
 {label="G/S/C 02",path="assets/borders/gsc_02.png"},
 {label="G/S/C 03",path="assets/borders/gsc_03.png"},
 {label="G/S/C 04",path="assets/borders/gsc_04.png"},
 {label="G/S/C 05",path="assets/borders/gsc_05.png"},
 {label="G/S/C 06",path="assets/borders/gsc_06.png"},
 {label="G/S/C 07",path="assets/borders/gsc_07.png"},
 {label="G/S/C 08",path="assets/borders/gsc_08.png"},
},legacy={1,2,3,4,5,6,7,8,9,10,11,12,3,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,12,3,13,14,31,16,32,18,33,34,21,35,36,37,25,26,38,28,39,30,40,41,42,43,44,45,46,47,48}}
C.choices={}
for i,entry in ipairs(C.entries) do C.choices[i]=entry.label end
function C.selection(raw,format)
 local n=math.floor(tonumber(raw) or 1)
 if format~=2 then n=C.legacy[n] or 1 end
 return math.max(1,math.min(#C.entries,n))
end
return C
