-- Decorative animated paper. Sprite sheets are bundled; no downloader needed.
return function(mod)
 local M={entries={
  {key='mew_stardust',name='MEW STARDUST',pokemon='mew',style=1,a='F4E8FA',b='E7E8FC',ink='AA78C2'},
  {key='mew_tide',name='MEW PSYCHIC TIDE',pokemon='mew',style=2,a='E2F5EF',b='E6E1FA',ink='8679BD'},
  {key='mew_nebula',name='MEW NEBULA',pokemon='mew',style=1,a='211A3D',b='293D52',ink='C6A3EB'},
  {key='charmander_embers',name='CHARMANDER EMBERS',pokemon='charmander',style=3,a='FFF0DC',b='FFE3D9',ink='D38A5E'},
  {key='charmander_campfire',name='CHARMANDER CAMPFIRE',pokemon='charmander',style=3,a='30202E',b='442B31',ink='F0B77A'},
  {key='pikachu_sparks',name='PIKACHU SPARKS',pokemon='pikachu',style=4,a='FFF8D5',b='F8EBD1',ink='BA9951'},
  {key='squirtle_lagoon',name='SQUIRTLE LAGOON',pokemon='squirtle',style=5,a='DEF4FC',b='DDF5EB',ink='599BAF'},
  {key='bulbasaur_garden',name='BULBASAUR GARDEN',pokemon='bulbasaur',style=6,a='E8F5DC',b='DAF1E9',ink='6B9D75'},
  {key='gengar_haunt',name='GENGAR HAUNT',pokemon='gengar',style=7,a='292139',b='38294F',ink='BBA2D8'},
  {key='eevee_cozy',name='EEVEE COZY',pokemon='eevee',style=8,a='FAF0E2',b='F1E5D9',ink='AA8C73'},
  {key='jigglypuff_lullaby',name='JIGGLYPUFF LULLABY',pokemon='jigglypuff',style=9,a='FBE6F0',b='EEE5FB',ink='B183AE'},
  {key='dragonair_dream',name='DRAGONAIR DREAM',pokemon='dragonair',style=10,a='E4EDFD',b='EDE4FA',ink='889AC4'},
  {key='umbreon_moonlight',name='UMBREON MOONLIGHT',pokemon='umbreon',style=11,a='172A3C',b='292142',ink='DCC78B'},
  {key='snorlax_snooze',name='SNORLAX SNOOZE',pokemon='snorlax',style=12,a='E5F2EF',b='E7ECFA',ink='7C9EAA'},
  {key='acid_spiral',name='ACID SPIRAL',pokemon='mew',style=13,a='19102E',b='183C39',ink='B69AF5'},
  {key='liquid_aurora',name='LIQUID AURORA',pokemon='mew',style=14,a='102B35',b='392453',ink='7DDDBB'},
  {key='kaleido_dream',name='KALEIDO DREAM',pokemon='mew',style=15,a='281536',b='223656',ink='C696D8'},
  {key='neon_grid',name='NEON GRID',pokemon='mew',style=16,a='141E32',b='302047',ink='69CACC'},
  {key='plasma_cloud',name='PLASMA CLOUD',pokemon='mew',style=17,a='301938',b='153D45',ink='9CAAED'},
  {key='liquid_chrome',name='LIQUID CHROME',pokemon='mew',style=18,a='202B39',b='34454D',ink='A6CDD9'},
  {key='cosmic_tunnel',name='COSMIC TUNNEL',pokemon='mew',style=19,a='17192F',b='35204E',ink='A797EA'},
  {key='dream_waves',name='DREAM WAVES',pokemon='mew',style=20,a='E4E6FB',b='D9F0E9',ink='AD91CB'},
  {key='vision_field',name='VISION FIELD',pokemon='mew',style=21,a='171A31',b='392449',ink='A2C6C2'},
  {key='sacred_lattice',name='SACRED LATTICE',pokemon='mew',style=22,a='172E32',b='322448',ink='91C5BD'},
  {key='energy_anatomy',name='ENERGY ANATOMY',pokemon='mew',style=23,a='26192F',b='193840',ink='CF9DAB'},
  {key='third_eye',name='THIRD EYE',pokemon='mew',style=24,a='211734',b='243B49',ink='B5A3DF'},
  {key='interbeing',name='INTERBEING',pokemon='mew',style=25,a='172D32',b='352142',ink='91CABB'},
  {key='lateral_spiral',name='LATERAL SPIRAL',pokemon='mew',style=26,a='231B35',b='323B42',ink='C0AC83'},
 }}
 -- Thirty independent animated paper choices; existing IDs stay in place.
 for _,e in ipairs({
{key="new_mew_0",name="MEW STARFALL",pokemon="mew",style=1,a="1E1620",b="251E33",ink="89D5D9",variant=1},
{key="new_charmander_0",name="CHARMANDER STARFALL",pokemon="charmander",style=3,a="22150C",b="352C19",ink="DC617B",variant=1},
{key="new_pikachu_0",name="PIKACHU STARFALL",pokemon="pikachu",style=4,a="221D0C",b="332413",ink="A879D9",variant=1},
{key="new_squirtle_0",name="SQUIRTLE STARFALL",pokemon="squirtle",style=5,a="0E1C1F",b="1D312A",ink="889CEA",variant=1},
{key="new_bulbasaur_0",name="BULBASAUR STARFALL",pokemon="bulbasaur",style=6,a="0F1C14",b="243018",ink="5DBBC0",variant=1},
{key="new_gengar_0",name="GENGAR STARFALL",pokemon="gengar",style=7,a="17121D",b="301C2A",ink="758ADD",variant=1},
{key="new_eevee_0",name="EEVEE STARFALL",pokemon="eevee",style=8,a="1D1811",b="353023",ink="BE8F96",variant=1},
{key="new_jigglypuff_0",name="JIGGLYPUFF STARFALL",pokemon="jigglypuff",style=9,a="20161C",b="2B2534",ink="8ECAD9",variant=1},
{key="new_dragonair_0",name="DRAGONAIR STARFALL",pokemon="dragonair",style=10,a="121820",b="2A2734",ink="89D4DE",variant=1},
{key="new_umbreon_0",name="UMBREON STARFALL",pokemon="umbreon",style=11,a="1E1B0D",b="1D222D",ink="BA9CCD",variant=1},
{key="new_snorlax_0",name="SNORLAX STARFALL",pokemon="snorlax",style=12,a="101919",b="2D3026",ink="91A8D5",variant=1},
{key="new_mew_1",name="MEW DREAM CURRENT",pokemon="mew",style=1,a="2D2231",b="16121E",ink="89D5D9",variant=2},
{key="new_charmander_1",name="CHARMANDER DREAM CURRENT",pokemon="charmander",style=3,a="332012",b="1F1A0E",ink="DC617B",variant=2},
{key="new_pikachu_1",name="PIKACHU DREAM CURRENT",pokemon="pikachu",style=4,a="332C12",b="1E150B",ink="A879D9",variant=2},
{key="new_squirtle_1",name="SQUIRTLE DREAM CURRENT",pokemon="squirtle",style=5,a="152A2F",b="111D18",ink="889CEA",variant=2},
{key="new_bulbasaur_1",name="BULBASAUR DREAM CURRENT",pokemon="bulbasaur",style=6,a="172A1E",b="151C0E",ink="5DBBC0",variant=2},
{key="new_gengar_1",name="GENGAR DREAM CURRENT",pokemon="gengar",style=7,a="221B2C",b="1C1018",ink="758ADD",variant=2},
{key="new_eevee_1",name="EEVEE DREAM CURRENT",pokemon="eevee",style=8,a="2C241A",b="1F1C15",ink="BE8F96",variant=2},
{key="new_jigglypuff_1",name="JIGGLYPUFF DREAM CURRENT",pokemon="jigglypuff",style=9,a="30212A",b="19161E",ink="8ECAD9",variant=2},
{key="new_dragonair_1",name="DRAGONAIR DREAM CURRENT",pokemon="dragonair",style=10,a="1C2430",b="18171E",ink="89D4DE",variant=2},
{key="new_umbreon_1",name="UMBREON DREAM CURRENT",pokemon="umbreon",style=11,a="2D2914",b="11141B",ink="BA9CCD",variant=2},
{key="new_snorlax_1",name="SNORLAX DREAM CURRENT",pokemon="snorlax",style=12,a="192626",b="1A1C17",ink="91A8D5",variant=2},
{key="new_mew_2",name="MEW MOON GARDEN",pokemon="mew",style=1,a="151017",b="2C243C",ink="89D5D9",variant=3},
{key="new_charmander_2",name="CHARMANDER MOON GARDEN",pokemon="charmander",style=3,a="180F08",b="3F351D",ink="DC617B",variant=3},
{key="new_pikachu_2",name="PIKACHU MOON GARDEN",pokemon="pikachu",style=4,a="181509",b="3D2B16",ink="A879D9",variant=3},
{key="new_squirtle_2",name="SQUIRTLE MOON GARDEN",pokemon="squirtle",style=5,a="0A1416",b="233A31",ink="889CEA",variant=3},
{key="new_bulbasaur_2",name="BULBASAUR MOON GARDEN",pokemon="bulbasaur",style=6,a="0B140E",b="2B391D",ink="5DBBC0",variant=3},
{key="new_gengar_2",name="GENGAR MOON GARDEN",pokemon="gengar",style=7,a="100D15",b="382131",ink="758ADD",variant=3},
{key="new_eevee_2",name="EEVEE MOON GARDEN",pokemon="eevee",style=8,a="15110C",b="3F392A",ink="BE8F96",variant=3},
{key="new_jigglypuff_2",name="JIGGLYPUFF MOON GARDEN",pokemon="jigglypuff",style=9,a="171014",b="322C3D",ink="8ECAD9",variant=3}
 })do M.entries[#M.entries+1]=e end
 for _,e in ipairs({
{key="fresh_raichu",name="RAICHU STARFALL",pokemon="raichu",style=1,a="201508",b="3A3323",ink="D98C38",variant=1,design="STARFALL",pokemonName="RAICHU"},
{key="fresh_sandshrew",name="SANDSHREW DREAM CURRENT",pokemon="sandshrew",style=2,a="1F190C",b="38311E",ink="D3AC50",variant=2,design="DREAM CURRENT",pokemonName="SANDSHREW"},
{key="fresh_nidoran_f",name="NIDORAN F MOON GARDEN",pokemon="nidoran_f",style=6,a="121B1E",b="2C3336",ink="78B6CC",variant=3,design="MOON GARDEN",pokemonName="NIDORAN F"},
{key="fresh_nidoran_m",name="NIDORAN M ENERGY RINGS",pokemon="nidoran_m",style=11,a="19121C",b="332C36",ink="A978BE",variant=1,design="ENERGY RINGS",pokemonName="NIDORAN M"},
{key="fresh_clefairy",name="CLEFAIRY SOFT WAVES",pokemon="clefairy",style=5,a="22181B",b="3A3333",ink="E7A3B8",variant=2,design="SOFT WAVES",pokemonName="CLEFAIRY"},
{key="fresh_vulpix",name="VULPIX FLOATING SPARKS",pokemon="vulpix",style=4,a="1B0D08",b="342615",ink="B45C37",variant=3,design="FLOATING SPARKS",pokemonName="VULPIX"},
{key="fresh_ninetales",name="NINETALES STARFALL",pokemon="ninetales",style=1,a="221F15",b="3A372B",ink="E9D58C",variant=1,design="STARFALL",pokemonName="NINETALES"},
{key="fresh_zubat",name="ZUBAT DREAM CURRENT",pokemon="zubat",style=2,a="0F161E",b="28202E",ink="6698CD",variant=2,design="DREAM CURRENT",pokemonName="ZUBAT"},
{key="fresh_oddish",name="ODDISH MOON GARDEN",pokemon="oddish",style=6,a="091019",b="172B1B",ink="426DAB",variant=3,design="MOON GARDEN",pokemonName="ODDISH"},
{key="fresh_paras",name="PARAS ENERGY RINGS",pokemon="paras",style=11,a="21140B",b="2C1518",ink="DF884B",variant=1,design="ENERGY RINGS",pokemonName="PARAS"},
{key="fresh_venonat",name="VENONAT SOFT WAVES",pokemon="venonat",style=5,a="160F1B",b="341E28",ink="9567B7",variant=2,design="SOFT WAVES",pokemonName="VENONAT"},
{key="fresh_diglett",name="DIGLETT FLOATING SPARKS",pokemon="diglett",style=4,a="19110C",b="35261D",ink="A87451",variant=3,design="FLOATING SPARKS",pokemonName="DIGLETT"},
{key="fresh_psyduck",name="PSYDUCK STARFALL",pokemon="psyduck",style=1,a="221E0E",b="3A3725",ink="E7CC62",variant=1,design="STARFALL",pokemonName="PSYDUCK"},
{key="fresh_growlithe",name="GROWLITHE DREAM CURRENT",pokemon="growlithe",style=2,a="21150A",b="383124",ink="DC9146",variant=2,design="DREAM CURRENT",pokemonName="GROWLITHE"},
{key="fresh_poliwag",name="POLIWAG MOON GARDEN",pokemon="poliwag",style=6,a="0F171F",b="2B3534",ink="659DCF",variant=3,design="MOON GARDEN",pokemonName="POLIWAG"},
{key="fresh_abra",name="ABRA ENERGY RINGS",pokemon="abra",style=11,a="1E190A",b="37311C",ink="C9AA43",variant=1,design="ENERGY RINGS",pokemonName="ABRA"},
{key="fresh_machop",name="MACHOP SOFT WAVES",pokemon="machop",style=5,a="151A1B",b="303232",ink="8CB2B8",variant=2,design="SOFT WAVES",pokemonName="MACHOP"},
{key="fresh_geodude",name="GEODUDE FLOATING SPARKS",pokemon="geodude",style=4,a="161616",b="31302B",ink="989996",variant=3,design="FLOATING SPARKS",pokemonName="GEODUDE"},
{key="fresh_ponyta",name="PONYTA STARFALL",pokemon="ponyta",style=1,a="222018",b="351B11",ink="E9D7A0",variant=1,design="STARFALL",pokemonName="PONYTA"},
{key="fresh_slowpoke",name="SLOWPOKE DREAM CURRENT",pokemon="slowpoke",style=2,a="201719",b="37302F",ink="D99CAC",variant=2,design="DREAM CURRENT",pokemonName="SLOWPOKE"},
{key="fresh_magnemite",name="MAGNEMITE MOON GARDEN",pokemon="magnemite",style=6,a="171A1B",b="263231",ink="9CAEB7",variant=3,design="MOON GARDEN",pokemonName="MAGNEMITE"},
{key="fresh_farfetchd",name="FARFETCHD ENERGY RINGS",pokemon="farfetchd",style=11,a="18140F",b="202B1D",ink="A38B66",variant=1,design="ENERGY RINGS",pokemonName="FARFETCHD"},
{key="fresh_doduo",name="DODUO SOFT WAVES",pokemon="doduo",style=5,a="1B1710",b="342D22",ink="B99E71",variant=2,design="SOFT WAVES",pokemonName="DODUO"},
{key="fresh_seel",name="SEEL FLOATING SPARKS",pokemon="seel",style=4,a="1D2022",b="383733",ink="C5DAE7",variant=3,design="FLOATING SPARKS",pokemonName="SEEL"},
{key="fresh_grimer",name="GRIMER STARFALL",pokemon="grimer",style=1,a="17121B",b="2F2530",ink="9B7AB8",variant=1,design="STARFALL",pokemonName="GRIMER"},
{key="fresh_shellder",name="SHELLDER DREAM CURRENT",pokemon="shellder",style=2,a="16141D",b="2F2A35",ink="9986C6",variant=2,design="DREAM CURRENT",pokemonName="SHELLDER"},
{key="fresh_krabby",name="KRABBY MOON GARDEN",pokemon="krabby",style=6,a="20150D",b="372C1F",ink="D88D59",variant=3,design="MOON GARDEN",pokemonName="KRABBY"},
{key="fresh_voltorb",name="VOLTORB ENERGY RINGS",pokemon="voltorb",style=11,a="1F0F11",b="353535",ink="D26774",variant=1,design="ENERGY RINGS",pokemonName="VOLTORB"},
{key="fresh_cubone",name="CUBONE SOFT WAVES",pokemon="cubone",style=5,a="1B150F",b="34322B",ink="B58F68",variant=2,design="SOFT WAVES",pokemonName="CUBONE"},
{key="fresh_lapras",name="LAPRAS FLOATING SPARKS",pokemon="lapras",style=4,a="10191D",b="2C3129",ink="6FA8C2",variant=3,design="FLOATING SPARKS",pokemonName="LAPRAS"}
 })do M.entries[#M.entries+1]=e end
 M.entries[#M.entries+1]={key='rainy_route',name='RAINY ROUTE',style=27,clip=true,a='FFFFFF',b='FFFFFF',ink='FFFFFF'}
 for _,e in ipairs({
 {key='scene_1_still',name='PETALBURG FIREFLIES',pokemon='bulbasaur',style=28,scene=true,still=true,a='102B28',b='234C38',ink='A6D77B'},
 {key='scene_1_animated',name='PETALBURG FIREFLIES',pokemon='bulbasaur',style=28,scene=true,still=false,a='102B28',b='234C38',ink='A6D77B'},
 {key='scene_2_still',name='SLATEPORT SUNSET',pokemon='squirtle',style=29,scene=true,still=true,a='33233F',b='A85D4A',ink='F3BD84'},
 {key='scene_2_animated',name='SLATEPORT SUNSET',pokemon='squirtle',style=29,scene=true,still=false,a='33233F',b='A85D4A',ink='F3BD84'},
 {key='scene_3_still',name='MT CHIMNEY EMBERS',pokemon='charmander',style=30,scene=true,still=true,a='271E32',b='703A31',ink='ED945B'},
 {key='scene_3_animated',name='MT CHIMNEY EMBERS',pokemon='charmander',style=30,scene=true,still=false,a='271E32',b='703A31',ink='ED945B'},
 {key='scene_4_still',name='METEOR FALLS',pokemon='dragonair',style=31,scene=true,still=true,a='17243D',b='344F75',ink='B4DCE5'},
 {key='scene_4_animated',name='METEOR FALLS',pokemon='dragonair',style=31,scene=true,still=false,a='17243D',b='344F75',ink='B4DCE5'},
 {key='scene_5_still',name='FORTREE CANOPY',pokemon='eevee',style=32,scene=true,still=true,a='142D32',b='397354',ink='D4DB8D'},
 {key='scene_5_animated',name='FORTREE CANOPY',pokemon='eevee',style=32,scene=true,still=false,a='142D32',b='397354',ink='D4DB8D'},
 {key='scene_6_still',name='SOOTOPOLIS LAGOON',pokemon='lapras',style=33,scene=true,still=true,a='173047',b='287C88',ink='A7E8CE'},
 {key='scene_6_animated',name='SOOTOPOLIS LAGOON',pokemon='lapras',style=33,scene=true,still=false,a='173047',b='287C88',ink='A7E8CE'},
 {key='scene_7_still',name='SHOAL CAVE SNOW',pokemon='seel',style=34,scene=true,still=true,a='273A55',b='55758D',ink='D5F0E9'},
 {key='scene_7_animated',name='SHOAL CAVE SNOW',pokemon='seel',style=34,scene=true,still=false,a='273A55',b='55758D',ink='D5F0E9'},
 {key='scene_8_still',name='SKY PILLAR CLOUDS',pokemon='mew',style=35,scene=true,still=true,a='25334F',b='7F7AA0',ink='F0D7BB'},
 {key='scene_8_animated',name='SKY PILLAR CLOUDS',pokemon='mew',style=35,scene=true,still=false,a='25334F',b='7F7AA0',ink='F0D7BB'},
 {key='scene_9_still',name='SAFARI BERRY GROVE',pokemon='pikachu',style=36,scene=true,still=true,a='263C27',b='658341',ink='EBC276'},
 {key='scene_9_animated',name='SAFARI BERRY GROVE',pokemon='pikachu',style=36,scene=true,still=false,a='263C27',b='658341',ink='EBC276'},
 {key='scene_10_still',name='LITTLEROOT PICNIC',pokemon='snorlax',style=37,scene=true,still=true,a='303A2B',b='708957',ink='E4D0A0'},
 {key='scene_10_animated',name='LITTLEROOT PICNIC',pokemon='snorlax',style=37,scene=true,still=false,a='303A2B',b='708957',ink='E4D0A0'},
 {key='scene_11_still',name='LAVENDER LANTERNS',pokemon='gengar',style=38,scene=true,still=true,a='211B37',b='514065',ink='CEADD5'},
 {key='scene_11_animated',name='LAVENDER LANTERNS',pokemon='gengar',style=38,scene=true,still=false,a='211B37',b='514065',ink='CEADD5'},
 {key='scene_12_still',name='MOONLIT ROOFTOPS',pokemon='umbreon',style=39,scene=true,still=true,a='151F36',b='394563',ink='ECD78F'},
 {key='scene_12_animated',name='MOONLIT ROOFTOPS',pokemon='umbreon',style=39,scene=true,still=false,a='151F36',b='394563',ink='ECD78F'},
 {key='scene_13_still',name='CERULEAN BUBBLES',pokemon='poliwag',style=40,scene=true,still=true,a='15354B',b='307887',ink='A9DFDB'},
 {key='scene_13_animated',name='CERULEAN BUBBLES',pokemon='poliwag',style=40,scene=true,still=false,a='15354B',b='307887',ink='A9DFDB'},
 {key='scene_14_still',name='CONTEST RIBBONS',pokemon='jigglypuff',style=41,scene=true,still=true,a='392A4C',b='835C7B',ink='EAB9D5'},
 {key='scene_14_animated',name='CONTEST RIBBONS',pokemon='jigglypuff',style=41,scene=true,still=false,a='392A4C',b='835C7B',ink='EAB9D5'},
 {key='scene_15_still',name='POKEMON POSTCARDS',pokemon='pikachu',style=42,scene=true,still=true,a='283448',b='56687A',ink='D1BD91'},
 {key='scene_15_animated',name='POKEMON POSTCARDS',pokemon='pikachu',style=42,scene=true,still=false,a='283448',b='56687A',ink='D1BD91'},
 })do M.entries[#M.entries+1]=e end
 for _,e in ipairs(M.entries)do if e.key=='rainy_route'or e.key=='sacred_lattice'or e.key=='vision_field'or e.key=='third_eye'then e.hidden=true;e.retired=true end end
 M.entries[#M.entries+1]={key='psy_0',name='SOLAR FRACTAL',style=43,a='180D12',b='A82D13',ink='ECD345'}
 M.entries[#M.entries+1]={key='psy_1',name='EMERALD MANDALA',style=44,a='0D1E18',b='28724E',ink='AEEA54'}
 M.entries[#M.entries+1]={key='psy_2',name='AMETHYST PRISM',style=45,a='1B102F',b='7134BA',ink='DD99FC'}
 M.entries[#M.entries+1]={key='psy_3',name='CHROMATIC LOTUS',style=46,a='26102C',b='9A3682',ink='F4B4D3'}
 M.entries[#M.entries+1]={key='psy_4',name='INFINITE STAR GATES',style=47,a='10132A',b='4E448F',ink='90DCD3'}
 M.entries[#M.entries+1]={key='psy_5',name='MOLTEN HONEYCOMB',style=48,a='26190E',b='984B21',ink='F5CB72'}
 M.entries[#M.entries+1]={key='psy_6',name='NEON CHRYSALIS',style=49,a='102825',b='176E80',ink='99F0BD'}
 M.entries[#M.entries+1]={key='psy_7',name='COSMIC ROSETTE',style=50,a='1E1536',b='513A9A',ink='EBB6F3'}
 M.entries[#M.entries+1]={key='red_psy_0',name='CRIMSON VORTEX',style=51,a='260407',b='BA1028',ink='FF6673'}
 M.entries[#M.entries+1]={key='red_psy_1',name='SCARLET MANDALA',style=52,a='30060C',b='DB2033',ink='FF906A'}
 M.entries[#M.entries+1]={key='red_psy_2',name='RUBY RIPPLE',style=53,a='22050B',b='AB153D',ink='FF526D'}
 M.entries[#M.entries+1]={key='red_psy_3',name='BLOOD MOON',style=54,a='380609',b='D32B19',ink='FCA078'}
 M.entries[#M.entries+1]={key='red_psy_4',name='VERMILION WAVES',style=55,a='260407',b='BA1028',ink='FF6673'}
 M.entries[#M.entries+1]={key='red_psy_5',name='CARMINE TUNNEL',style=56,a='30060C',b='DB2033',ink='FF906A'}
 M.entries[#M.entries+1]={key='red_psy_6',name='RED LOTUS',style=57,a='22050B',b='AB153D',ink='FF526D'}
 M.entries[#M.entries+1]={key='red_psy_7',name='SCARLET GRID',style=58,a='380609',b='D32B19',ink='FCA078'}
 M.entries[#M.entries+1]={key='red_psy_8',name='RUBY CHRYSALIS',style=59,a='260407',b='BA1028',ink='FF6673'}
 M.entries[#M.entries+1]={key='red_psy_9',name='CRIMSON ECHO',style=60,a='30060C',b='DB2033',ink='FF906A'}
 M.entries[#M.entries+1]={key='red_psy_10',name='MOLTEN ROSETTE',style=61,a='22050B',b='AB153D',ink='FF526D'}
 M.entries[#M.entries+1]={key='red_psy_11',name='RED NEBULA',style=62,a='380609',b='D32B19',ink='FCA078'}
 M.entries[#M.entries+1]={key='red_psy_12',name='CARMINE BRAID',style=63,a='260407',b='BA1028',ink='FF6673'}
 M.entries[#M.entries+1]={key='red_psy_13',name='SCARLET STAR GATE',style=64,a='30060C',b='DB2033',ink='FF906A'}
 M.entries[#M.entries+1]={key='red_psy_14',name='RUBY MIRAGE',style=65,a='22050B',b='AB153D',ink='FF526D'}
 M.entries[#M.entries+1]={key='red_psy_15',name='CRIMSON HONEYCOMB',style=66,a='380609',b='D32B19',ink='FCA078'}
 M.entries[#M.entries+1]={key='red_psy_16',name='RED THIRD EYE',style=67,a='260407',b='BA1028',ink='FF6673'}
 M.entries[#M.entries+1]={key='red_psy_17',name='VERMILION FRACTAL',style=68,a='30060C',b='DB2033',ink='FF906A'}
 M.entries[#M.entries+1]={key='red_psy_18',name='SCARLET INFINITY',style=69,a='22050B',b='AB153D',ink='FF526D'}
 M.entries[#M.entries+1]={key='red_psy_19',name='RUBY PLASMA',style=70,a='380609',b='D32B19',ink='FCA078'}
 M.entries[#M.entries+1]={key='red_fire_0',name='CRIMSON INFERNO',style=71,fire=true,a='200305',b='B30E19',ink='FF742F'}
 M.entries[#M.entries+1]={key='red_fire_1',name='SCARLET EMBERS',style=72,fire=true,a='290505',b='D02316',ink='FFAA45'}
 M.entries[#M.entries+1]={key='red_fire_2',name='RUBY LAVA',style=73,fire=true,a='220409',b='AE1731',ink='FF5C3F'}
 M.entries[#M.entries+1]={key='red_fire_3',name='RED FLAME CURTAIN',style=74,fire=true,a='200305',b='B30E19',ink='FF742F'}
 M.entries[#M.entries+1]={key='red_fire_4',name='CARMINE FIRESTORM',style=75,fire=true,a='290505',b='D02316',ink='FFAA45'}
 M.entries[#M.entries+1]={key='red_fire_5',name='MOLTEN RED RIVERS',style=76,fire=true,a='220409',b='AE1731',ink='FF5C3F'}
 M.entries[#M.entries+1]={key='red_fire_6',name='PHOENIX FIRE',style=77,fire=true,a='200305',b='B30E19',ink='FF742F'}
 M.entries[#M.entries+1]={key='red_fire_7',name='SCARLET HEAT HAZE',style=78,fire=true,a='290505',b='D02316',ink='FFAA45'}
 M.entries[#M.entries+1]={key='red_fire_8',name='VOLCANIC HEART',style=79,fire=true,a='220409',b='AE1731',ink='FF5C3F'}
 M.entries[#M.entries+1]={key='red_fire_9',name='CRIMSON FIRE WHIRL',style=80,fire=true,a='200305',b='B30E19',ink='FF742F'}
 local function rgb(hex)return{tonumber(hex:sub(1,2),16)/255,tonumber(hex:sub(3,4),16)/255,tonumber(hex:sub(5,6),16)/255}end
 for _,e in ipairs(M.entries)do if e.scene and not e.still then e.hidden=true;e.retired=true;e.removedAnimation=true end end
 local black=assert(load(assert(mod:read('lib/black_artwork.lua'))))()
 local forest=assert(load(assert(mod:read('lib/forest_artwork.lua'))))()
 M.forestEntries={}
 for i,name in ipairs(forest.names)do M.forestEntries[i]={key='forest_art_'..i,name=name,style=150+i,a='021009',b='082610',ink='208C35'}end
 M.blackEntries={}
 for i,name in ipairs(black.names)do M.blackEntries[i]={key='black_art_'..i,name=name,style=80+i,blackFamily=(i<=10 or i>20)and 'BLACK PSYCHEDELIC' or 'BLACK POKEMON',a='010101',b='010101',ink='302038'}end
 M.extraEntries={{key='black_waterfall',name='BLACK WATERFALL',style=131,blackFamily='DESIGNS',a='010102',b='010102',ink='19242E'}}
 local matrix=assert(load(assert(mod:read('lib/matrix_rain.lua'))))()
 M.matrixEntries={}
 for i,name in ipairs(matrix.names)do M.matrixEntries[i]={key='matrix_'..(i-1),name=name,style=200+i,blackFamily='MATRIX RAIN',a='010204',b='010204',ink='40FF90'}end
 -- Retain legacy IDs, but retire static Pokemon artwork from every picker.
 for _,e in ipairs(M.entries)do if e.still then e.hidden=true;e.retired=true;e.removedAnimation=true end end
 M.byKey={}
 for _,e in ipairs(M.entries)do e.baseA=rgb(e.a);e.baseB=rgb(e.b);e.accent=rgb(e.ink);M.byKey[e.key]=e
  if e.variant and not e.pokemonName then e.pokemonName=e.pokemon:upper() end
 end
 for _,e in ipairs(M.blackEntries)do e.baseA=rgb(e.a);e.baseB=rgb(e.b);e.accent=rgb(e.ink);M.byKey[e.key]=e end
 for _,e in ipairs(M.forestEntries)do e.baseA=rgb(e.a);e.baseB=rgb(e.b);e.accent=rgb(e.ink);M.byKey[e.key]=e end
 for _,e in ipairs(M.matrixEntries)do e.baseA=rgb(e.a);e.baseB=rgb(e.b);e.accent=rgb(e.ink);M.byKey[e.key]=e end
 for _,e in ipairs(M.extraEntries)do e.baseA=rgb(e.a);e.baseB=rgb(e.b);e.accent=rgb(e.ink);M.byKey[e.key]=e end
 local sheets,images
 local function sprite(key)
  if not sheets then sheets=assert(load(assert(mod:read('assets/pokemon-paper/sheets.lua'))))();images={}end
  local s=assert(sheets[key]);if not images[key]then images[key]=assert(mod.assets:image(s.image));images[key]:setFilter('nearest','nearest')end
  return s,images[key]
 end
 function M.color(key)
  local e=assert(M.byKey[key]);if e.removedAnimation then return {.04,.08,.18,1}end;return{e.baseA[1],e.baseA[2],e.baseA[3],1,animation='POKEMON',pokemon=key}
 end
 function M.send(shader,key,time,fallback,area)
  local e=M.byKey[key];shader:send('pokeStyle',e and e.style or 0);shader:send('pokeVariant',e and e.variant or 0)
  if e and e.retired then shader:send('pokeStyle',0);if fallback then shader:send('pokeStamp',fallback)end;return end
  if not e then if fallback then shader:send('pokeStamp',fallback)end;return end
  shader:send('pokeArea',area or {0,0,240,160})
  if e.clip then
   M.clipImages=M.clipImages or {}
   local frame=math.floor((time or 0)*20)%159;local page=math.floor(frame/24)+1;local cell=frame%24
   if not M.clipImages[page]then
    local img=assert(mod.assets:image(string.format('assets/animated-paper/rainy-route-%02d.png',page)))
    img:setFilter('nearest','nearest');M.clipImages[page]=img
   end
   shader:send('pokeStamp',M.clipImages[page])
   shader:send('pokeSpriteRect',{(cell%4*498+.5)/1992,(math.floor(cell/4)*332+.5)/1992,497/1992,331/1992})
   shader:send('pokeSpriteSize',{498,332});return
  end
  if e.still then time=0 end
  if e.style>=43 then
   shader:send('pokePhase',time or 0);shader:send('pokeBaseA',e.baseA);shader:send('pokeBaseB',e.baseB);shader:send('pokeAccent',e.accent)
   local _,image=sprite('mew');shader:send('pokeStamp',image);return
  end
  local s,image=sprite(e.pokemon);local frame=math.floor((time or 0)*4)%s.frames
  local box=s.ink;local w,h=box[3]-box[1],box[4]-box[2]
  shader:send('pokeStamp',image);shader:send('pokePhase',time or 0)
  shader:send('pokeBaseA',e.baseA);shader:send('pokeBaseB',e.baseB);shader:send('pokeAccent',e.accent)
  shader:send('pokeSpriteRect',{(frame%s.columns*s.width+box[1])/s.sheetWidth,(math.floor(frame/s.columns)*s.height+box[2])/s.sheetHeight,w/s.sheetWidth,h/s.sheetHeight})
  shader:send('pokeSpriteSize',{28*w/h,28})
 end
 M.glsl=[[
  extern int pokeStyle;extern float pokeVariant;extern float pokePhase;extern vec3 pokeBaseA;extern vec3 pokeBaseB;extern vec3 pokeAccent;
  extern vec4 pokeArea;extern Image pokeStamp;extern vec4 pokeSpriteRect;extern vec2 pokeSpriteSize;
  float paperHash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
  float paperDot(vec2 p,vec2 c,float r){return 1.0-step(r,length(p-c));}
  vec3 pokemonPaper(vec2 p){
   if(pokeStyle>=201){return matrixRain(p-pokeArea.xy,pokePhase,pokeStyle-201);}
   if(pokeStyle>=151){vec2 size=max(pokeArea.zw,vec2(1.0));return forestArtwork((p-pokeArea.xy-size*.5)/min(size.x,size.y)*2.0,pokePhase*.5,pokeStyle-151);}
   if(pokeStyle>=81){vec2 size=max(pokeArea.zw,vec2(1.0));vec2 q=(p-pokeArea.xy-size*.5)/min(size.x,size.y)*2.0;return blackArtwork(q,pokePhase*.5,pokeStyle-81);}
   if(pokeStyle>=71){
    vec2 size=max(pokeArea.zw,vec2(1.0));vec2 q=(p-pokeArea.xy-size*.5)/min(size.x,size.y);
    float t=pokePhase*.65,k=float(pokeStyle-71);
    float rise=q.y*8.0+t;
    float curl=sin(q.x*9.0+sin(rise*1.7)*1.3)+.5*sin(q.x*21.0-rise*2.1);
    float flame=.5+.5*sin(q.y*11.0+curl*2.2+t*2.0);
    if(pokeStyle==72)flame=pow(max(0.0,sin(q.x*33.0+sin(rise)*3.0)*sin(rise*6.0)),5.0);
    if(pokeStyle==73)flame=.5+.5*sin(q.x*8.0+sin(q.y*7.0+t)*2.8);
    if(pokeStyle==74)flame=exp(-abs(sin(q.x*15.0+sin(rise)*2.0))*5.0)*(.6+.4*sin(rise*3.0));
    if(pokeStyle==75)flame=.5+.5*sin(curl*3.0+sin(q.y*17.0+t*3.0)*2.0);
    if(pokeStyle==76)flame=exp(-abs(sin(q.x*11.0+q.y*5.0+sin(q.y*9.0+t)*2.0))*4.0);
    if(pokeStyle==77)flame=.5+.5*sin(abs(q.x)*17.0+curl+rise*2.0);
    if(pokeStyle==78)flame=.5+.5*sin(q.y*8.0+sin(q.x*6.0+t)*3.0+sin(q.x*16.0-t));
    vec2 z=(p-pokeArea.xy-size*.5)/min(size.x,size.y);float rad=length(z),angle=atan(z.y,z.x);
    if(pokeStyle==79)flame=.5+.5*cos(rad*25.0+curl*1.5-t*2.0);
    if(pokeStyle==80)flame=.5+.5*sin(angle*5.0+log(max(rad,.015))*8.0+t*2.0);
    flame=clamp(flame,0.0,1.0);
    vec3 rgb=mix(pokeBaseA,pokeBaseB,.3+.7*flame);
    return mix(rgb,pokeAccent,pow(flame,9.0)*.7);
   }
   if(pokeStyle>=43){
    vec2 size=max(pokeArea.zw,vec2(1.0));vec2 z=(p-pokeArea.xy-size*.5)/min(size.x,size.y)*3.0;
    float r=max(length(z),.012),a=atan(z.y,z.x),t=pokePhase*.35;float k=float(pokeStyle-43);
    float fold=abs(cos(a*(3.0+mod(k,5.0))+t*.4));
    float tunnel=log(r)*(-6.0-mod(k,3.0)*2.0)+t;
    float wave=sin(tunnel+fold*(5.0+mod(k,4.0)));
    if(pokeStyle==44)wave=sin(r*12.0-fold*8.0-t);
    if(pokeStyle==45)wave=sin((abs(z.x)+abs(z.y))*9.0+fold*6.0-t);
    if(pokeStyle==46)wave=cos(r*9.0+sin(a*7.0-t)*3.0-t);
    if(pokeStyle==47)wave=sin(tunnel+cos(a*5.0+t)*7.0);
    if(pokeStyle==48)wave=sin(z.x*8.0+sin(z.y*7.0+t)*2.0)+cos(z.y*9.0-t);
    if(pokeStyle==49)wave=sin(log(r)*12.0-t+sin(a*8.0)*4.0);
    if(pokeStyle==50)wave=cos(r*11.0+fold*12.0+sin(r*4.0-t)*3.0);
    if(pokeStyle==51)wave=sin(log(r)*13.0+a*5.0-t);
    if(pokeStyle==52)wave=cos(r*11.0+cos(a*8.0+t*.2)*6.0-t);
    if(pokeStyle==53)wave=sin(r*18.0+sin(a*3.0-t)*2.0-t);
    if(pokeStyle==54)wave=cos(r*9.0-a*2.0+sin(t)*2.0);
    if(pokeStyle==55)wave=sin(z.x*7.0+sin(z.y*5.0+t)*3.0-t);
    if(pokeStyle==56)wave=sin(log(r)*17.0+cos(a*6.0)*4.0+t);
    if(pokeStyle==57)wave=cos(r*8.0+abs(sin(a*7.0+t*.3))*9.0-t);
    if(pokeStyle==58)wave=sin(z.x*8.0+t)*cos(z.y*8.0-t);
    if(pokeStyle==59)wave=sin(log(r)*11.0+a*9.0+sin(r*5.0-t));
    if(pokeStyle==60)wave=cos(r*16.0+sin(r*3.0-t)*4.0);
    if(pokeStyle==61)wave=sin(r*13.0+cos(a*12.0-t*.2)*5.0);
    if(pokeStyle==62)wave=sin(z.x*4.0+sin(z.y*6.0-t)*3.0)+cos(r*8.0+t);
    if(pokeStyle==63)wave=sin(z.x*10.0+z.y*6.0+sin(z.y*5.0-t)*4.0);
    if(pokeStyle==64)wave=cos(log(r)*14.0+abs(cos(a*9.0))*8.0-t);
    if(pokeStyle==65)wave=sin(r*10.0-a*6.0+cos(r*4.0+t)*3.0);
    if(pokeStyle==66)wave=sin(z.x*9.0+cos(z.y*5.2)*2.0+t)*cos(z.y*9.0-t);
    if(pokeStyle==67)wave=cos(r*12.0+cos(a*2.0)*8.0+sin(t));
    if(pokeStyle==68)wave=sin(log(r)*18.0+cos(a*11.0+sin(r*4.0-t))*6.0);
    if(pokeStyle==69)wave=sin(z.x*6.0+z.y*6.0+t)*cos(z.x*6.0-z.y*6.0-t);
    if(pokeStyle==70)wave=sin(z.x*5.0+t)+cos(z.y*7.0-t)+sin(r*9.0-t);
    float edge=exp(-abs(wave)*5.0);float field=.5+.5*sin(wave*2.0+t+r*2.0);
    vec3 rgb=mix(pokeBaseA,pokeBaseB,field);
    rgb=mix(rgb,pokeAccent,edge*.8);
    float weave=.94+.06*cos(floor(p.x-pokeArea.x-pokeArea.z*.5)*2.1)*cos(floor(p.y-pokeArea.y-pokeArea.w*.5)*2.1);
    return rgb*weave;
   }
   if(pokeStyle>=28)return pokemonScene(p);
   if(pokeStyle==27){
    vec2 size=max(pokeArea.zw,vec2(1.0));vec2 uv=(p-pokeArea.xy)/size;
    float cover=max(size.x/pokeSpriteSize.x,size.y/pokeSpriteSize.y);
    uv=(uv-.5)*size/(pokeSpriteSize*cover)+.5;
    return Texel(pokeStamp,pokeSpriteRect.xy+clamp(uv,0.0,1.0)*pokeSpriteRect.zw).rgb;
   }
   p=floor(p-pokeArea.xy-pokeArea.zw*.5)+vec2(.5);float t=pokePhase;
   float flow=.5+.5*sin(p.x*.027+p.y*.021+t*.16);
   vec3 rgb=mix(pokeBaseA,pokeBaseB,flow);
   // Abstract paper uses the same clock and pixel grid, without Pokemon stamps.
   if(pokeStyle>=13){
    vec2 z=p*.035;float r=length(z);float a=atan(z.y,z.x);float v=0.0;
    if(pokeStyle==13){v=.5+.5*sin(r*7.0-a*3.0-t*.65);}
    else if(pokeStyle==14){v=.5+.5*sin(z.x*2.0+sin(z.y*2.3+t*.35)*2.5+t*.25);}
    else if(pokeStyle==15){v=.5+.5*cos(cos(a*8.0+t*.2)*r*3.0-t*.5);}
    else if(pokeStyle==16){vec2 g=abs(sin(z*3.0+vec2(t*.2,-t*.15)));v=1.0-smoothstep(.04,.18,min(g.x,g.y));}
    else if(pokeStyle==17){v=.5+(.25*sin(z.x*2.0+t*.4)+.25*cos(z.y*2.7-t*.3))*cos(r*1.5-t*.2);}
    else if(pokeStyle==18){v=.5+.5*sin(z.x*3.0+sin(z.y*3.0+t*.3)+sin(r*4.0-t*.4));v=v*v;}
    else if(pokeStyle==19){v=.5+.5*sin(log(1.0+r)*18.0-t*.8+a*.6);}
    else if(pokeStyle==20){v=.5+.5*sin(z.y*3.0+sin(z.x*1.5+t*.25)*1.8-t*.35);}
    else if(pokeStyle==21){
     vec2 eye=mod(z+vec2(t*.08,0.0),vec2(1.6,1.1))-vec2(.8,.55);
     float lid=abs(eye.y)-.28*(1.0-pow(clamp(abs(eye.x)/.7,0.0,1.0),2.0));
     float iris=length(eye*vec2(1.0,1.4));
     v=max(exp(-abs(lid)*28.0)*(1.0-step(.7,abs(eye.x))),exp(-abs(iris-.19)*30.0));
    }else if(pokeStyle==22){
     vec2 cell=mod(z,vec2(1.2,1.03923))-vec2(.6,.519615);
     float ring=min(abs(length(cell)-.6),min(abs(length(cell-vec2(.6,.519615))-.6),abs(length(cell+vec2(.6,.519615))-.6)));
     v=exp(-ring*35.0)*(.7+.3*sin(r*2.0-t*.4));
    }else if(pokeStyle==23){
     float spine=exp(-abs(sin(z.x*3.0+sin(z.y*.7+t*.2)))*14.0);
     float ribs=exp(-abs(sin(z.y*5.0+abs(z.x)*2.5-t*.3))*12.0);
     v=clamp(spine*.65+ribs*.45,0.0,1.0);
    }else if(pokeStyle==24){
     vec2 eye=z*vec2(.6,1.2);float iris=length(eye);
     float lid=abs(eye.y)-.9*(1.0-pow(clamp(abs(eye.x)/2.0,0.0,1.0),2.0));
     v=max(exp(-abs(lid)*14.0)*(1.0-step(2.0,abs(eye.x))),exp(-abs(iris-.55)*18.0));
     v=max(v,(.5+.5*sin(iris*18.0-t*.5))*.3);
    }else if(pokeStyle==25){
     float weave=sin(z.x*3.0+sin(z.y*2.0+t*.2))*sin(z.y*3.0+sin(z.x*2.0-t*.2));
     v=exp(-abs(weave)*10.0)*(.65+.35*cos(r*3.0-t*.3));
    }else {v=.5+.5*sin(log(1.0+r)*15.0-a*5.0-t*.5);v*=.6+.4*cos(a*10.0+r*3.0);}
    rgb=mix(pokeBaseA,pokeBaseB,v);
    return mix(rgb,pokeAccent,v*.24);
   }
   // Staggered rows, uniform sprite aspect, and transparent padding excluded.
   float spacing=56.0+pokeVariant*8.0;
   vec2 drift=p+vec2(t*(.75+pokeVariant*.45),sin(t*.22+pokeVariant)*pokeVariant*2.0);float row=floor(drift.y/spacing);
   drift.x+=mod(row,2.0)*36.0;vec2 cell=floor(drift/vec2(72.0+pokeVariant*4.0,spacing));float seed=paperHash(cell);
   vec2 d=mod(drift,vec2(72.0+pokeVariant*4.0,spacing))-vec2(36.0+pokeVariant*2.0,spacing*.5);
   d-=vec2(sin(t*.42+seed*6.28)*2.0,cos(t*.55+seed*6.28)*2.0);
   vec2 q=d/pokeSpriteSize+.5;
   if(q.x>=0.0 && q.x<1.0 && q.y>=0.0 && q.y<1.0){
    vec4 stamp=Texel(pokeStamp,pokeSpriteRect.xy+q*pokeSpriteRect.zw);
    rgb=mix(rgb,mix(pokeAccent,stamp.rgb,.28),stamp.a*.23);
   }
   vec2 u=mod(p+vec2(t*.7,-t*.9),vec2(31.0,27.0))-vec2(15.5,13.5);
   float motif=0.0;
   if(pokeStyle==1){ // Psychic stardust: slowly breathing four-point stars.
    float twinkle=1.6+.6*sin(t*.8+floor(p.x/31.0)*2.0+floor(p.y/27.0));
    motif=1.0-step(twinkle,abs(u.x)+abs(u.y));
   }else if(pokeStyle==2){ // Mew's soft psychic ripples.
    float r=length(u);motif=(1.0-step(.55,abs(r-(4.0+sin(t*.6)*1.2))));
   }else if(pokeStyle==3){ // Rising tail-flame embers.
    u=mod(p+vec2(sin(t*.25)*2.0,t*2.4),vec2(29.0,25.0))-vec2(14.5,12.5);
    float flame=3.4*(1.0-(u.y+4.0)/9.0);motif=step(-4.0,u.y)*(1.0-step(5.0,u.y))*(1.0-step(flame,abs(u.x+sin(u.y*.65+t)*.8)));
   }else if(pokeStyle==4){ // Pikachu bolts, warm rather than strobing.
    float bolt=u.y<0.0?u.y*.38+1.2:u.y*.38-1.2;
    motif=(1.0-step(.7,abs(u.x-bolt)))*(1.0-step(5.0,abs(u.y)));
   }else if(pokeStyle==5){ // Squirtle bubbles and a gentle water shimmer.
    motif=1.0-step(.6,abs(length(u)-3.5));
    rgb=mix(rgb,pokeAccent,.025*(.5+.5*sin(p.y*.24-t*.5)));
   }else if(pokeStyle==6){ // Bulbasaur leaves drifting on a breeze.
    motif=1.0-step(3.2,abs(u.x*.8+u.y*.35)+abs(u.y*.7));
   }else if(pokeStyle==7){ // Gengar eyes emerging from lavender mist.
    motif=paperDot(u,vec2(-2.0,0.0),1.0)+paperDot(u,vec2(2.0,0.0),1.0);
    rgb=mix(rgb,pokeAccent,.03*(.5+.5*sin(p.x*.055+p.y*.08+t*.3)));
   }else if(pokeStyle==8){ // Eevee's soft little pawprints.
    motif=paperDot(u,vec2(0.0,1.2),1.9)+paperDot(u,vec2(-2.0,-1.5),.9)+paperDot(u,vec2(0.0,-2.5),.9)+paperDot(u,vec2(2.0,-1.5),.9);
   }else if(pokeStyle==9){ // Jigglypuff's floating eighth notes.
    motif=paperDot(u,vec2(-1.0,2.0),1.5);
    motif=max(motif,(1.0-step(.6,abs(u.x-.3)))*step(-3.0,u.y)*(1.0-step(2.0,u.y)));
    motif=max(motif,(1.0-step(.7,abs(u.y+3.0)))*step(0.0,u.x)*(1.0-step(2.5,u.x)));
   }else if(pokeStyle==10){ // Dragonair's moonlit ribbons.
    motif=(1.0-step(.6,abs(u.y-sin(u.x*.35+t*.4)*2.0)))*(1.0-step(5.5,abs(u.x)));
   }else if(pokeStyle==11){ // Umbreon's softly glowing golden rings.
    motif=1.0-step(.7,abs(length(u)-3.0));motif*=.65+.35*sin(t*.5);
   }else if(pokeStyle==12){ // Snorlax's rising Zs.
    motif=max((1.0-step(.55,abs(abs(u.y)-2.5)))*(1.0-step(2.8,abs(u.x))),
     (1.0-step(.6,abs(u.x+u.y)))*(1.0-step(2.5,abs(u.y))));
   }
   return mix(rgb,pokeAccent,clamp(motif,0.0,1.0)*.17);
  }
 ]]
 local sceneShader=assert(load(assert(mod:read('lib/pokemon_scenes.lua'))))()
 M.glsl=matrix.glsl..forest.glsl..black.glsl..M.glsl
 M.glsl=M.glsl:gsub('  float paperDot',function()return sceneShader..'\n  float paperDot'end,1)
 return M
end
