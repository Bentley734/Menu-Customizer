"""Deterministic 8px UI tile artwork; requires Pillow. Run from any directory."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageColor

ROOT=Path(__file__).resolve().parents[1]
THEMES=[
 ('POKE BALL','poke_ball',('#281c28','#f8aaa2','#e84848','#a82838'),'ball'),
 ('GREAT BALL','great_ball',('#182848','#88cefa','#3088d8','#204a98'),'great'),
 ('ULTRA BALL','ultra_ball',('#20202c','#ffe878','#e0b838','#58505c'),'ultra'),
 ('MASTER BALL','master_ball',('#301848','#f8a8e8','#a058d0','#683890'),'master'),
 ('PIKACHU','pikachu',('#483018','#fff090','#f0c830','#c89020'),'spark'),
 ('CHARIZARD','charizard',('#502018','#ffc878','#f08030','#b84020'),'flame'),
 ('SQUIRTLE','squirtle',('#183858','#b0eeff','#40b8e8','#2878b0'),'wave'),
 ('BULBASAUR','bulbasaur',('#183828','#a0e898','#50b868','#287848'),'leaf'),
 ('GENGAR','gengar',('#281830','#c898e8','#8858b0','#503070'),'ghost'),
 ('UMBREON','umbreon',('#181820','#f8e878','#383848','#202028'),'ring'),
 ('EEVEE','eevee',('#382818','#f8e0a8','#b88850','#785030'),'fur'),
 ('MEW','mew',('#583050','#ffe0f0','#f0a0c8','#b86898'),'psychic'),
]

def sprite(tile,rows,colors,x=1,y=1):
 for dy,row in enumerate(rows):
  for dx,key in enumerate(row):
   if key!='.':tile.putpixel((x+dx,y+dy),ImageColor.getcolor(colors[key],'RGBA'))

def build():
 for label,slug,colors,kind in THEMES:
  dark,hi,base,shade=colors
  top=Image.new('RGBA',(8,8),'white');d=ImageDraw.Draw(top)
  for y,c in enumerate((dark,hi,base,base,shade,shade,dark)):
   d.line((0,y,7,y),fill=c)
  if kind in ('ball','great','ultra','master'):
   d.line((0,3,7,3),fill=dark);d.line((0,5,7,5),fill=hi)
   if kind=='great':d.rectangle((1,1,2,2),fill='#e84848');d.rectangle((5,1,6,2),fill='#e84848')
   if kind=='ultra':d.rectangle((1,1,2,4),fill=hi);d.rectangle((5,1,6,4),fill=hi)
   if kind=='master':d.point((2,2),fill='#f8a8e8');d.point((5,2),fill='#f8a8e8')
  elif kind=='spark':
   sprite(top,('...hh.','..hh..','.hhh..','..h...','.h....'),{'h':hi})
  elif kind=='flame':
   sprite(top,('...h..','..hh..','.hhh..','hhhhh.','.hhh..'),{'h':hi})
  elif kind=='wave':
   sprite(top,('..hhh...','.h...h..','h.....hh'),{'h':hi},0,2)
  elif kind=='leaf':
   sprite(top,('...hh.','..hhh.','.hhhh.','.hhh..','hh....'),{'h':hi})
  elif kind=='ghost':
   sprite(top,('.h..h.','......','...h..','..h...','.h..h.'),{'h':hi})
  elif kind=='ring':
   sprite(top,('..hh..','.h..h.','.h..h.','..hh..'),{'h':hi},1,1)
  elif kind=='fur':
   sprite(top,('h.h.h.h.','.h.h.h.h','h.h.h.h.'),{'h':hi},0,2)
  elif kind=='psychic':
   sprite(top,('..h...','.hhh..','hhhhh.','.hhh..','..h...'),{'h':hi})
  corner=Image.new('RGBA',(8,8),dark)
  cd=ImageDraw.Draw(corner);cd.rectangle((1,1,6,6),fill=shade)
  cd.line((1,1,6,1),fill=hi);cd.line((1,1,1,6),fill=hi)
  ink={'d':dark,'h':hi,'b':base,'s':shade,'w':'#fff8f0','r':'#e84848','p':'#f8a8e8'}
  if kind in ('ball','great','ultra','master'):
   rows=['.dddd.','dbbbbd','dbbbbd','ddwwdd','dwwwwd','.dddd.']
   if kind=='great':rows[1]='drbbrd'
   if kind=='ultra':rows[1]='dhddhd';rows[2]='dhddhd'
   if kind=='master':rows[1]='dpbbpd';rows[2]='dhddhd'
   sprite(corner,rows,ink)
  elif kind=='spark':sprite(corner,('d....d','dbbbbd','bbbbbb','bdbbdb','rbbbb r'.replace(' ',''),'.dddd.'),ink)
  elif kind=='flame':sprite(corner,('...h..','..bh..','.bhhb.','bhhhhb','.bhhb.','..bb..'),ink)
  elif kind=='wave':sprite(corner,('..hhh.','.hbbbh','hbhh.h','hb....','.hhhh.','......'),ink)
  elif kind=='leaf':sprite(corner,('....h.','..hbh.','.hbbh.','hbbh..','hhh...','h.....'),ink)
  elif kind=='ghost':sprite(corner,('.dbbd.','dbbbbd','bwb bwb'.replace(' ',''),'bdbbdb','bwddwb','.dddd.'),ink)
  elif kind=='ring':sprite(corner,('.hhhh.','hhddhh','hddddh','hddddh','hhddhh','.hhhh.'),ink)
  elif kind=='fur':sprite(corner,('d....d','dbbbbd','bbbbbb','bdbbdb','.hbbh.','..hh..'),ink)
  else:sprite(corner,('..h...','.hhh..','hhwhh.','.hhh..','..h...','.....h'),ink)
  atlas=Image.new('RGBA',(24,24),'white')
  tiles=[corner,top,corner.transpose(Image.Transpose.FLIP_LEFT_RIGHT),
   top.transpose(Image.Transpose.ROTATE_90),Image.new('RGBA',(8,8),'white'),top.transpose(Image.Transpose.ROTATE_270),
   corner.transpose(Image.Transpose.FLIP_TOP_BOTTOM),top.transpose(Image.Transpose.FLIP_TOP_BOTTOM),corner.transpose(Image.Transpose.ROTATE_180)]
  for i,tile in enumerate(tiles):atlas.paste(tile,(i%3*8,i//3*8))
  atlas.save(ROOT/'assets/borders'/('pokemon_'+slug+'.png'))
 # A neutral double frame supplies the gradient shader with bevel brightness.
 gradient=Image.new('RGBA',(24,24),'white');d=ImageDraw.Draw(gradient)
 for inset,c in enumerate(('#101010','#b0b0b0','#777777','#e0e0e0','#aaaaaa','#555555','#222222')):
  d.rectangle((inset,inset,23-inset,23-inset),outline=c)
 # Middle edge cells repeat one constant bevel profile, not a corner profile.
 for x in range(8,16):
  for y,c in enumerate(('#101010','#b0b0b0','#777777','#e0e0e0','#aaaaaa','#555555','#222222')):
   gradient.putpixel((x,y),ImageColor.getcolor(c,'RGBA'));gradient.putpixel((x,23-y),ImageColor.getcolor(c,'RGBA'))
 for y in range(8,16):
  for x,c in enumerate(('#101010','#b0b0b0','#777777','#e0e0e0','#aaaaaa','#555555','#222222')):
   gradient.putpixel((x,y),ImageColor.getcolor(c,'RGBA'));gradient.putpixel((23-x,y),ImageColor.getcolor(c,'RGBA'))
 gradient.save(ROOT/'assets/borders/pokemon_gradient.png')
 print('Built',len(THEMES),'Pokémon-themed atlases and the animated gradient bevel')

if __name__=='__main__':build()
