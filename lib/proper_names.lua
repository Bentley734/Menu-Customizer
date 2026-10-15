-- Sentence-case exceptions come from the loaded game's species/trainers and save.
return function(mod)
 local M={};local names={};local game;local playerNames={}
 local function lower(s)return s:lower():gsub('É','é')end
 local function add(s,initialOnly)
  if type(s)~='string'or s==''or s:find('[<>{}\n]')then return end
  local key=lower(s);local word=true
  local display=key:gsub('[%z\1-\127\194-\244][\128-\191]*',function(c)
   if c:match('%w')or c:byte()>=128 then local out=word and(c=='é'and'É'or c:upper())or c;word=false;return out end
   if c~="'"then word=true end;return c
  end)
  if initialOnly then display=key:gsub('^[%z\1-\127\194-\244][\128-\191]*',function(c)return c=='é'and'É'or c:upper()end)end
  local first=key:sub(1,1);names[first]=names[first]or{};names[first][key]=display
 end
 local function scan(t,seen,initialOnly)
  if type(t)~='table'or seen[t]then return end;seen[t]=true
  for k,v in pairs(t)do
   if k=='name'or k=='nickname'or k=='trainerName'or k=='rivalName'or k=='playerName'then add(v,initialOnly)
   elseif type(v)=='table'then scan(v,seen,initialOnly)end
  end
 end
 -- Named characters whose names also occur in ordinary dialogue, rather than
 -- trainer records (professors, family members, and story NPCs).
 for s in ('Oak|Elm|Birch|Rowan|Juniper|Sycamore|Kukui|Magnolia|Sonia|Bill|Mr. Fuji|Daisy|Giovanni|Brock|Misty|Lt. Surge|Erika|Koga|Sabrina|Blaine|Lorelei|Bruno|Agatha|Lance|Professor Oak|Professor Elm|Professor Birch|Steven|Wallace|Wally|May|Brendan|Norman|Roxanne|Brawly|Wattson|Flannery|Winona|Tate|Liza|Sidney|Phoebe|Glacia|Drake|Archie|Maxie|Aqua|Magma|Kurt|Eusine|Morty|Whitney|Jasmine|Chuck|Pryce|Clair|Falkner|Bugsy|Karen|Will|Janine|Blue|Red|Green|Silver|Gold|Crystal|Ash|Gary|Jessie|James|Mary|Ben|Celio|Celio'):gmatch('[^|]+')do add(s,true)end
 add('Pokemon');add('Pokémon')
 local function observe(save)
  if type(save)~='table'then return end
  local function remember(name)
   if type(name)=='string'and name~=''then
    local key=lower(name);playerNames[key]=key:gsub('^[%z\1-\127\194-\244][\128-\191]*',function(c)return c=='é'and'É'or c:upper()end);add(name,true)
   end
  end
  remember(save.playerName);remember(save.rivalName)
  if save.player then remember(save.player.name);remember(save.player.rival)end
 end
 mod.hooks:wrap('screen.render_visible',function(next,state,...)
  if state then observe(state.save);observe(state.game and state.game.save)end
  return next(state,...)
 end)
 function M.players(text)
  observe(game and game.save)
  for key,display in pairs(playerNames)do
   local out,at={},1
   while at<=#text do
    local a,b=lower(text):find(key,at,true)
    if not a then out[#out+1]=text:sub(at);break end
    out[#out+1]=text:sub(at,a-1)
    local boundary=(a==1 or not text:sub(a-1,a-1):match('[%w\128-\255]'))and(b==#text or not text:sub(b+1,b+1):match('[%w\128-\255]'))
    out[#out+1]=boundary and display or text:sub(a,b);at=b+1
   end
   text=table.concat(out)
  end
  return text
 end
 mod.events:on('mods.loaded',function(e)
  local d=e.data or{};scan(d.pokemon,{});scan(d.trainers,{},true)
 end)
 mod.events:on('game.ready',function(e)game=e.game;scan(game and game.save,{},true);observe(game and game.save)end)
 function M.restore(text)
  if game and game.save then
   local s=game.save;add(s.rivalName,true);add(s.playerName,true);if s.player then add(s.player.name,true);add(s.player.rival,true)end
   for _,p in pairs(s.party or{})do if type(p)=='table'then add(p.nickname);add(p.name)end end
  end
  -- Longest match first, with byte boundaries supporting accented names.
  local at,out=1,{}
  while at<=#text do
   local best,display
   if at==1 or not text:sub(at-1,at-1):match('[%w\128-\255]')then
    for key,value in pairs(names[lower(text:sub(at,at))]or{})do
     local tail=at+#key
     if(not best or #key>#best)and lower(text:sub(at,tail-1))==key and(tail>#text or not text:sub(tail,tail):match('[%w\128-\255]'))then best,display=key,value end
    end
   end
   if best then out[#out+1]=display;at=at+#best else out[#out+1]=text:sub(at,at);at=at+1 end
  end
  return table.concat(out)
 end
 return M
end
