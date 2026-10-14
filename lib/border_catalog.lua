-- Unique pixel-identical atlases; old numeric selections migrate to their equivalent.
local C={entries={
 {label="DEFAULT"},
 {label="GREY",path="assets/borders/frlg_01.png"},
 {label="BLACK & WHITE",path="assets/borders/frlg_02.png"},
 {label="RED",path="assets/borders/frlg_03.png"},
 {label="GREEN",path="assets/borders/frlg_04.png"},
 {label="BLUE",path="assets/borders/frlg_05.png"},
 {label="GOLD STRIPE",path="assets/borders/frlg_06.png"},
 {label="SILVER STRIPE",path="assets/borders/frlg_07.png"},
 {label="GREY CHECKER",path="assets/borders/frlg_08.png"},
 {label="GOLD RIBBON",path="assets/borders/frlg_09.png"},
 {label="LILAC TILE",path="assets/borders/frlg_10.png"},
 {label="SLATE GREY",path="assets/borders/emerald_01.png"},
 {label="PASTEL STRIPE",path="assets/borders/emerald_03.png"},
 {label="SILVER",path="assets/borders/emerald_04.png"},
 {label="RAINBOW",path="assets/borders/emerald_05.png"},
 {label="FOREST GREEN",path="assets/borders/emerald_06.png"},
 {label="CORAL TILE",path="assets/borders/emerald_07.png"},
 {label="BLACK & GOLD",path="assets/borders/emerald_08.png"},
 {label="ICE BLUE",path="assets/borders/emerald_09.png"},
 {label="BRONZE",path="assets/borders/emerald_10.png"},
 {label="LILAC WAVE",path="assets/borders/emerald_11.png"},
 {label="GREEN SPECKLE",path="assets/borders/emerald_12.png"},
 {label="BLUE & GOLD",path="assets/borders/emerald_13.png"},
 {label="SAND",path="assets/borders/emerald_14.png"},
 {label="LILAC LACE",path="assets/borders/emerald_15.png"},
 {label="RAINBOW LINE",path="assets/borders/emerald_16.png"},
 {label="WHITE MARBLE",path="assets/borders/emerald_17.png"},
 {label="YELLOW CHECKER",path="assets/borders/emerald_18.png"},
 {label="LIME LEAF",path="assets/borders/emerald_19.png"},
 {label="PINK STRIPE",path="assets/borders/emerald_20.png"},
 {label="RAINBOW BRIGHT",path="assets/borders/rs_05.png"},
 {label="CORAL BRIGHT",path="assets/borders/rs_07.png"},
 {label="PALE BLUE",path="assets/borders/rs_09.png"},
 {label="DARK BRONZE",path="assets/borders/rs_10.png"},
 {label="DARK GREEN",path="assets/borders/rs_12.png"},
 {label="NAVY & GOLD",path="assets/borders/rs_13.png"},
 {label="PALE SAND",path="assets/borders/rs_14.png"},
 {label="PALE MARBLE",path="assets/borders/rs_17.png"},
 {label="PALE LEAF",path="assets/borders/rs_19.png"},
 {label="BLACK FLORAL",path="assets/borders/rby_01.png"},
 {label="BLACK DOUBLE",path="assets/borders/gsc_01.png"},
 {label="BLACK CHAIN",path="assets/borders/gsc_02.png"},
 {label="BLACK THIN",path="assets/borders/gsc_03.png"},
 {label="BLACK ROPE",path="assets/borders/gsc_04.png"},
 {label="BLACK DASH",path="assets/borders/gsc_05.png"},
 {label="BLACK SQUARE",path="assets/borders/gsc_06.png"},
 {label="BLACK CORNER",path="assets/borders/gsc_07.png"},
 {label="BLACK ROUND",path="assets/borders/gsc_08.png"},
 {label="POKE BALL",path="assets/borders/pokemon_poke_ball.png"},
 {label="GREAT BALL",path="assets/borders/pokemon_great_ball.png"},
 {label="ULTRA BALL",path="assets/borders/pokemon_ultra_ball.png"},
 {label="MASTER BALL",path="assets/borders/pokemon_master_ball.png"},
 {label="PIKACHU",path="assets/borders/pokemon_pikachu.png"},
 {label="CHARIZARD",path="assets/borders/pokemon_charizard.png"},
 {label="SQUIRTLE",path="assets/borders/pokemon_squirtle.png"},
 {label="BULBASAUR",path="assets/borders/pokemon_bulbasaur.png"},
 {label="GENGAR",path="assets/borders/pokemon_gengar.png"},
 {label="UMBREON",path="assets/borders/pokemon_umbreon.png"},
 {label="EEVEE",path="assets/borders/pokemon_eevee.png"},
 {label="MEW",path="assets/borders/pokemon_mew.png"},
 {label="RAINBOW FLOW",path="assets/borders/pokemon_gradient.png",animation="gradient"},
 {label="ROLLING POKE BALLS",path="assets/borders/pokemon_gradient.png",animation="balls"},
 {label="LIGHTNING",path="assets/borders/pokemon_gradient.png",animation="lightning"},
 {label="WATER RIPPLE",path="assets/borders/pokemon_gradient.png",animation="water"},
 {label="GHOST WISPS",path="assets/borders/pokemon_gradient.png",animation="ghost"},
 {label="SHOOTING STARS",path="assets/borders/pokemon_gradient.png",animation="stars"},
 {label="LIVING VINES",path="assets/borders/pokemon_gradient.png",animation="vines"},
 {label="AURORA",path="assets/borders/pokemon_gradient.png",animation="gradient",gradient="aurora"},
 {label="AMETHYST TIDE",path="assets/borders/pokemon_gradient.png",animation="gradient",gradient="violet"},
 {label="MINT LAGOON",path="assets/borders/pokemon_gradient.png",animation="gradient",gradient="lagoon"},
 {label="DREAM MIST",path="assets/borders/pokemon_gradient.png",animation="gradient",gradient="dream"},
 {label="DEEP SPACE",path="assets/borders/pokemon_gradient.png",animation="gradient",gradient="cosmos"},
 {label="MOONLIT FOREST",path="assets/borders/pokemon_gradient.png",animation="gradient",gradient="forest"},
 {label="COTTON CANDY",path="assets/borders/pokemon_gradient.png",animation="gradient",gradient="candy"},
 {label="SUNSET DREAM",path="assets/borders/pokemon_gradient.png",animation="gradient",gradient="sunset"},
 {label="GOLDEN HOUR",path="assets/borders/pokemon_gradient.png",animation="gradient",gradient="ember"},
 {label="ACID RIBBONS",path="assets/borders/pokemon_gradient.png",animation="acid",gradient="violet"},
 {label="PLASMA BEADS",path="assets/borders/pokemon_gradient.png",animation="plasma",gradient="aurora"},
 {label="KALEIDO GEMS",path="assets/borders/pokemon_gradient.png",animation="kaleido",gradient="dream"},
 {label="MOLTEN DREAM",path="assets/borders/pokemon_gradient.png",animation="molten",gradient="candy"},
 {label="NEON CIRCUIT",path="assets/borders/pokemon_gradient.png",animation="circuit",gradient="lagoon"},
 {label="WORMHOLE",path="assets/borders/pokemon_gradient.png",animation="tunnel",gradient="cosmos"},
 {label="CHECKER MELT",path="assets/borders/pokemon_gradient.png",animation="checker",gradient="violet"},
 {label="AURORA BRAID",path="assets/borders/pokemon_gradient.png",animation="braid",gradient="aurora"},
},legacy={1,2,3,4,5,6,7,8,9,10,11,12,3,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,12,3,13,14,31,16,32,18,33,34,21,35,36,37,25,26,38,28,39,30,40,41,42,43,44,45,46,47,48}}
 -- Thirty Pokemon-inspired animated frames, independent of paper choices.
C.entries[#C.entries+1]={label="PIKACHU VOLT CIRCUIT",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="poke_frame_1",pokemonMotif=1}
C.entries[#C.entries+1]={label="CHARIZARD INFERNO",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="poke_frame_2",pokemonMotif=2}
C.entries[#C.entries+1]={label="BLASTOISE TIDAL ARMOR",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="poke_frame_3",pokemonMotif=3}
C.entries[#C.entries+1]={label="VENUSAUR BLOOM",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="poke_frame_4",pokemonMotif=4}
C.entries[#C.entries+1]={label="GENGAR NIGHT EYES",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="poke_frame_5",pokemonMotif=5}
C.entries[#C.entries+1]={label="EEVEE COZY TRAILS",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="poke_frame_6",pokemonMotif=6}
C.entries[#C.entries+1]={label="UMBREON ECLIPSE",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="poke_frame_7",pokemonMotif=7}
C.entries[#C.entries+1]={label="ESPEON PSYCHIC RINGS",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="poke_frame_8",pokemonMotif=8}
C.entries[#C.entries+1]={label="VAPOREON TIDEPOOL",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="poke_frame_9",pokemonMotif=9}
C.entries[#C.entries+1]={label="JOLTEON SPARK TAILS",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="poke_frame_10",pokemonMotif=10}
C.entries[#C.entries+1]={label="FLAREON EMBER FUR",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="poke_frame_11",pokemonMotif=11}
C.entries[#C.entries+1]={label="LEAFEON LEAF DANCE",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="poke_frame_12",pokemonMotif=12}
C.entries[#C.entries+1]={label="GLACEON FROST CRYSTALS",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="poke_frame_13",pokemonMotif=13}
C.entries[#C.entries+1]={label="SYLVEON RIBBON WALTZ",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="poke_frame_14",pokemonMotif=14}
C.entries[#C.entries+1]={label="MEW STAR ORBIT",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="poke_frame_15",pokemonMotif=15}
C.entries[#C.entries+1]={label="MEWTWO AURA CORE",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="poke_frame_16",pokemonMotif=16}
C.entries[#C.entries+1]={label="LUGIA SILVER CURRENT",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="poke_frame_17",pokemonMotif=17}
C.entries[#C.entries+1]={label="HO-OH RAINBOW FEATHERS",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="poke_frame_18",pokemonMotif=18}
C.entries[#C.entries+1]={label="RAYQUAZA SKY COILS",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="poke_frame_19",pokemonMotif=19}
C.entries[#C.entries+1]={label="KYOGRE OCEAN RUNES",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="poke_frame_20",pokemonMotif=20}
C.entries[#C.entries+1]={label="GROUDON MAGMA RUNES",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="poke_frame_21",pokemonMotif=21}
C.entries[#C.entries+1]={label="DIALGA TIME SHARDS",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="poke_frame_22",pokemonMotif=22}
C.entries[#C.entries+1]={label="PALKIA SPACE RIFTS",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="poke_frame_23",pokemonMotif=23}
C.entries[#C.entries+1]={label="GIRATINA SHADOW GATES",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="poke_frame_24",pokemonMotif=24}
C.entries[#C.entries+1]={label="LUCARIO AURA PULSE",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="poke_frame_25",pokemonMotif=25}
C.entries[#C.entries+1]={label="GARDEVOIR FAIRY VEIL",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="poke_frame_26",pokemonMotif=26}
C.entries[#C.entries+1]={label="DRAGONITE WING TRAILS",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="poke_frame_27",pokemonMotif=27}
C.entries[#C.entries+1]={label="SNORLAX DREAM CLOUDS",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="poke_frame_28",pokemonMotif=28}
C.entries[#C.entries+1]={label="JIGGLYPUFF SONG STARS",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="poke_frame_29",pokemonMotif=29}
C.entries[#C.entries+1]={label="CELEBI FOREST CLOCK",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="poke_frame_30",pokemonMotif=30}
C.entries[#C.entries+1]={label="RAICHU STARFALL",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="fresh_frame_raichu",pokemonMotif=31,pokemonName="RAICHU"}
C.entries[#C.entries+1]={label="SANDSHREW DREAM CURRENT",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="fresh_frame_sandshrew",pokemonMotif=32,pokemonName="SANDSHREW"}
C.entries[#C.entries+1]={label="NIDORAN F MOON GARDEN",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="fresh_frame_nidoran_f",pokemonMotif=33,pokemonName="NIDORAN F"}
C.entries[#C.entries+1]={label="NIDORAN M ENERGY RINGS",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="fresh_frame_nidoran_m",pokemonMotif=34,pokemonName="NIDORAN M"}
C.entries[#C.entries+1]={label="CLEFAIRY SOFT WAVES",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="fresh_frame_clefairy",pokemonMotif=35,pokemonName="CLEFAIRY"}
C.entries[#C.entries+1]={label="VULPIX FLOATING SPARKS",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="fresh_frame_vulpix",pokemonMotif=36,pokemonName="VULPIX"}
C.entries[#C.entries+1]={label="NINETALES STARFALL",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="fresh_frame_ninetales",pokemonMotif=37,pokemonName="NINETALES"}
C.entries[#C.entries+1]={label="ZUBAT DREAM CURRENT",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="fresh_frame_zubat",pokemonMotif=38,pokemonName="ZUBAT"}
C.entries[#C.entries+1]={label="ODDISH MOON GARDEN",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="fresh_frame_oddish",pokemonMotif=39,pokemonName="ODDISH"}
C.entries[#C.entries+1]={label="PARAS ENERGY RINGS",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="fresh_frame_paras",pokemonMotif=40,pokemonName="PARAS"}
C.entries[#C.entries+1]={label="VENONAT SOFT WAVES",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="fresh_frame_venonat",pokemonMotif=41,pokemonName="VENONAT"}
C.entries[#C.entries+1]={label="DIGLETT FLOATING SPARKS",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="fresh_frame_diglett",pokemonMotif=42,pokemonName="DIGLETT"}
C.entries[#C.entries+1]={label="PSYDUCK STARFALL",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="fresh_frame_psyduck",pokemonMotif=43,pokemonName="PSYDUCK"}
C.entries[#C.entries+1]={label="GROWLITHE DREAM CURRENT",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="fresh_frame_growlithe",pokemonMotif=44,pokemonName="GROWLITHE"}
C.entries[#C.entries+1]={label="POLIWAG MOON GARDEN",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="fresh_frame_poliwag",pokemonMotif=45,pokemonName="POLIWAG"}
C.entries[#C.entries+1]={label="ABRA ENERGY RINGS",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="fresh_frame_abra",pokemonMotif=46,pokemonName="ABRA"}
C.entries[#C.entries+1]={label="MACHOP SOFT WAVES",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="fresh_frame_machop",pokemonMotif=47,pokemonName="MACHOP"}
C.entries[#C.entries+1]={label="GEODUDE FLOATING SPARKS",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="fresh_frame_geodude",pokemonMotif=48,pokemonName="GEODUDE"}
C.entries[#C.entries+1]={label="PONYTA STARFALL",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="fresh_frame_ponyta",pokemonMotif=49,pokemonName="PONYTA"}
C.entries[#C.entries+1]={label="SLOWPOKE DREAM CURRENT",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="fresh_frame_slowpoke",pokemonMotif=50,pokemonName="SLOWPOKE"}
C.entries[#C.entries+1]={label="MAGNEMITE MOON GARDEN",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="fresh_frame_magnemite",pokemonMotif=51,pokemonName="MAGNEMITE"}
C.entries[#C.entries+1]={label="FARFETCHD ENERGY RINGS",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="fresh_frame_farfetchd",pokemonMotif=52,pokemonName="FARFETCHD"}
C.entries[#C.entries+1]={label="DODUO SOFT WAVES",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="fresh_frame_doduo",pokemonMotif=53,pokemonName="DODUO"}
C.entries[#C.entries+1]={label="SEEL FLOATING SPARKS",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="fresh_frame_seel",pokemonMotif=54,pokemonName="SEEL"}
C.entries[#C.entries+1]={label="GRIMER STARFALL",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="fresh_frame_grimer",pokemonMotif=55,pokemonName="GRIMER"}
C.entries[#C.entries+1]={label="SHELLDER DREAM CURRENT",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="fresh_frame_shellder",pokemonMotif=56,pokemonName="SHELLDER"}
C.entries[#C.entries+1]={label="KRABBY MOON GARDEN",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="fresh_frame_krabby",pokemonMotif=57,pokemonName="KRABBY"}
C.entries[#C.entries+1]={label="VOLTORB ENERGY RINGS",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="fresh_frame_voltorb",pokemonMotif=58,pokemonName="VOLTORB"}
C.entries[#C.entries+1]={label="CUBONE SOFT WAVES",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="fresh_frame_cubone",pokemonMotif=59,pokemonName="CUBONE"}
C.entries[#C.entries+1]={label="LAPRAS FLOATING SPARKS",path="assets/borders/pokemon_gradient.png",animation="pokemon",gradient="fresh_frame_lapras",pokemonMotif=60,pokemonName="LAPRAS"}
local originalPokemonNames={'PIKACHU','CHARIZARD','BLASTOISE','VENUSAUR','GENGAR','EEVEE','UMBREON','ESPEON','VAPOREON','JOLTEON','FLAREON','LEAFEON','GLACEON','SYLVEON','MEW','MEWTWO','LUGIA','HO-OH','RAYQUAZA','KYOGRE','GROUDON','DIALGA','PALKIA','GIRATINA','LUCARIO','GARDEVOIR','DRAGONITE','SNORLAX','JIGGLYPUFF','CELEBI'}
for _,e in ipairs(C.entries)do if e.pokemonMotif and e.pokemonMotif<=30 then e.pokemonName=originalPokemonNames[e.pokemonMotif]end end
-- Retain retired slots for save compatibility; omit them from the picker.
local keep={'LUCARIO','CHARIZARD','BLASTOISE','MEWTWO','GENGAR','LAPRAS'}
local winners={}
for i,e in ipairs(C.entries)do if e.pokemonMotif then local f=(e.pokemonMotif-1)%6+1;if e.pokemonName==keep[f]then winners[f]=i end end end
for _,e in ipairs(C.entries)do if e.pokemonMotif then local f=(e.pokemonMotif-1)%6+1
 if e.pokemonName~=keep[f]then e.hidden=true;local replacement=C.entries[winners[f]]
  if replacement then e.path,e.animation,e.gradient,e.pokemonMotif=replacement.path,replacement.animation,replacement.gradient,replacement.pokemonMotif end
 end
end end
C.entries[#C.entries+1]={label='SOLAR FRACTAL',path='assets/borders/pokemon_gradient.png',animation='psy0',gradient='ember'}
C.entries[#C.entries+1]={label='EMERALD MANDALA',path='assets/borders/pokemon_gradient.png',animation='psy1',gradient='forest'}
C.entries[#C.entries+1]={label='AMETHYST PRISM',path='assets/borders/pokemon_gradient.png',animation='psy2',gradient='violet'}
C.entries[#C.entries+1]={label='CHROMATIC LOTUS',path='assets/borders/pokemon_gradient.png',animation='psy3',gradient='candy'}
C.entries[#C.entries+1]={label='INFINITE STAR GATES',path='assets/borders/pokemon_gradient.png',animation='psy4',gradient='cosmos'}
C.entries[#C.entries+1]={label='MOLTEN HONEYCOMB',path='assets/borders/pokemon_gradient.png',animation='psy5',gradient='sunset'}
C.entries[#C.entries+1]={label='NEON CHRYSALIS',path='assets/borders/pokemon_gradient.png',animation='psy6',gradient='lagoon'}
C.entries[#C.entries+1]={label='COSMIC ROSETTE',path='assets/borders/pokemon_gradient.png',animation='psy7',gradient='aurora'}
C.choices={}
for i,entry in ipairs(C.entries) do C.choices[i]=entry.label end
function C.selection(raw,format)
 local n=math.floor(tonumber(raw) or 1)
 if format~=2 then n=C.legacy[n] or 1 end
 return math.max(1,math.min(#C.entries,n))
end
function C.groups()
 local groups,lookup={},{}
 local families={'VOLT TRAILS','EMBER FLOW','TIDAL WAVES','LEAF DANCE','PSYCHIC EYES','POKEBALL ORBITS'}
 for i,e in ipairs(C.entries)do if not e.hidden then
  local label=e.pokemonMotif and families[(e.pokemonMotif-1)%6+1] or e.animation and 'OTHER ANIMATED DESIGNS' or e.path and e.path:find('pokemon_',1,true) and 'CLASSIC POKEMON FRAMES' or 'GAME BORDERS'
  if not lookup[label]then lookup[label]={label=label,choices={}};groups[#groups+1]=lookup[label]end
  lookup[label].choices[#lookup[label].choices+1]={id=i,label=e.pokemonName or e.label}
 end end
 return groups
end
return C
