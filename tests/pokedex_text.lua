local root=arg[1]
local function read(p)local f=assert(io.open(root..'/'..p,'rb'));local s=f:read('*a');f:close();return s end
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
local size=8;local Font={width=function(text)return #text*size end}
local C={drawScope=false,live=function()return true end}
local rendered={};local closed=0;local pressed
local Entry={}
function Entry.new(game)
 return setmetatable({game=game,def=game.def,page=1,pageCount=8,picDelay=0,crying=function()return false end},{__index=Entry})
end
function Entry.render(game,def,_,_,_,page)
 local chunks={};for chunk in (game.data.text[def.dexEntry.text]..'\f'):gmatch('(.-)\f')do chunks[#chunks+1]=chunk end
 rendered[#rendered+1]=chunks[page]
end
function Entry:draw()if self.page==2 then rendered[#rendered+1]='STATS'else Entry.render(self.game,self.def,nil,self.forceOwned,false,self.page)end end
function Entry:update()
 if pressed=='a'or pressed=='b'then
  if self.page<self.pageCount then self.page=self.page+1 else closed=closed+1 end
 elseif pressed=='down'then self.page=self.page+1
 elseif pressed=='up'and self.page>1 then self.page=self.page-1 end
end
package.loaded['src.ui.DexEntryMenu']=Entry;package.loaded['src.ui.PokedexMenu']={}
local M=assert(load(read('lib/gb_pokedex_text.lua')))()(Font,function()return C end)
local text='Obviously prefers hot places. When it rains, steam is said to spout from the tip of its tail.\nIts flame reflects its health.'
local game={def={id='CHARMANDER',dexEntry={text='entry'}},data={text={entry=text}},save={pokedex={owned={CHARMANDER=true}}},input={wasPressed=function(_,k)return pressed==k end}}
for _,s in ipairs({8,3})do size=s
 local pages=M.pages(text,136,3);check(#pages>0,'description pages generated')
 local words={};for _,page in ipairs(pages)do
  check(#page<=3,'no more than three visible description lines')
  for _,line in ipairs(page)do check(Font.width(line)<=136,'description fits between frame borders');words[#words+1]=line end
 end
 check(table.concat(words,' ')==text:gsub('\n',' '),'all description words retained in order')
 local entry=Entry.new(game);check(entry.pageCount==1,'description count does not collide with stats page number')
 for index=1,#pages do
  entry:draw();check(game.data.text.entry==text,'source text restored after rendering')
  local printed=M.pages(text:gsub('%.%s*$',''),136,3)
  check(rendered[#rendered]==table.concat(printed[index],'\n'),'correct description page rendered')
  if index<#pages then pressed='down';entry:update();check(entry.page==1,'DOWN continues description before stats')end
 end
 pressed='down';entry:update();check(entry.page==2,'stats follows final description page')
 entry:draw();check(rendered[#rendered]=='STATS','stats remains accessible')
 pressed='up';entry:update();check(entry.page==1 and entry._dexDescriptionPage==#pages,'UP returns to final description page')
 pressed='b';entry:update();check(closed>0,'B closes normally')
end
size=8;local long=M.pages(string.rep('Z',100),136,3)
local combined='';for _,page in ipairs(long)do for _,line in ipairs(page)do check(Font.width(line)<=136,'long word split safely');combined=combined..line end end
check(#combined==100,'long word loses no letters')
game.save.pokedex.owned.CHARMANDER=false;local unseen=Entry.new(game);check(unseen._dexDescriptionCount==nil,'unowned description remains hidden')
check(Entry.screenId=='DexEntryMenu' and package.loaded['src.ui.PokedexMenu'].screenId=='PokedexMenu','list and standalone entry use menu font context')
local h,w=M.measurements({heightM=.6,weightKg=8.5});check(h=="2'00\"" and w=='18.7 lb','metric conversion')
h,w=M.measurements({heightFt=5,heightIn=11,weight=1234});check(h=="5'11\"" and w=='123.4 lb','native customary values preserved')
print('PASS '..checks..' Pokedex font context, wrapping, description navigation and stats checks')
