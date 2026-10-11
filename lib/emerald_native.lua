-- Read the player's Emerald extraction. Never substitute another ROM's font.
return function(mod)
  local M={}
  local Cache=require('src.import.CacheFs')
  local Compiler=require('src.mods.Sandbox').compile
  local function read(path) return Cache.readAt('emerald/'..path) end
  local function tableAt(path)
    local s=read(path);if type(s)~='string' then return nil end
    local f=load(s,'@emerald/'..path,'t',{});if not f then return nil end
    local ok,t=pcall(f);return ok and t or nil
  end
  local function clone(name,overrides)
    local path='lib/emerald_engine/'..name:match('([^%.]+)$')..'.lua'
    local source=mod:read(path)
    if not source then return nil end
    local loaded=setmetatable({['src.core.GameVersion']=require('src.core.GameVersion')},{__index=overrides})
    local privateLove=setmetatable({filesystem={read=read,getInfo=function()end}},{__index=love})
    local env=setmetatable({package={loaded=loaded},love=privateLove,io={open=function()end},
      require=function(n)return overrides[n] or require(n)end,_emeraldPort=M,_emeraldMod=mod},{__index=_G})
    env._G=env
    env.load=function(s,n,mode,e)return Compiler(s,n,e or env)end
    env.loadstring=env.load
    if name=='src.battle.WideBattle'then
      source=source:gsub('return WideBattle%s*$',[[
local originalHuds=drawHUDs
drawHUDs=function(b,s,...)if _emeraldPort.wideHud(b,s)then return end;return originalHuds(b,s,...)end
local originalBottom=drawTextArea
drawTextArea=function(b,...)if _emeraldPort.wideBottom(b)then return end;return originalBottom(b,...)end
return WideBattle
]])
    end
    return assert(Compiler(source,'@emerald-port/'..path,env))()
  end
  function M.ready()
    if M.font then return true end
    local manifest=tableAt('data/generated/gba/pokemon/battle/manifest.lua')
    local metrics=tableAt('data/generated/gba/chrome/fonts/metrics.lua')
    if not manifest or not metrics or not read('data/generated/gba/chrome/fonts/latin_narrow_fg.rgba') then return false end
    local profile=require('src.core.game3.profiles.emerald')
    local cache=setmetatable({readActive=read,read=read},{__index=Cache})
    local overrides={['src.import.CacheFs']=cache,
      ['src.core.game3.profile']={forSession=function()return profile end}}
    local font=clone('src.ui.game3.frlg_font',overrides)
    if not font then return false end
    if not font.face or not font.face({font='normal'})or not font.face({font='narrow'})then return false end
    overrides['src.ui.game3.frlg_font']=font
    overrides['src.ui.game3.chrome']=clone('src.ui.game3.chrome',overrides)
    local chrome=clone('src.ui.game3.battle_chrome',overrides)
    if not chrome then return false end
    local dataset={prefix='emerald',read=function(_,p)return read(p)end}
    chrome.install(dataset)
    -- ensureInstalled must not rebind this private renderer to the active ROM.
    chrome.ensureInstalled=function()end
    local nativeFrames=chrome.drawMenuFrames
    chrome.drawMenuFrames=function(mode)
      local borders=mod.exports and mod.exports.borders
      if borders and mode=='moves' then
        borders.drawBattlePixels(0,112,160,48);borders.drawBattlePixels(160,112,80,48)
      elseif borders and mode=='menu' then borders.drawBattlePixels(120,112,120,48)
      else nativeFrames(mode)end
    end
    M.font,M.chrome,M.profile=font,chrome,profile
    M.overrides=overrides
    overrides['src.ui.game3.battle_chrome']=chrome
    overrides['src.core.game3.dataset']={cache=function()return dataset end,mountExtractRoots=function()end}
    overrides['src.core.game3.battle.state']={displayName=function(b)return b.name or 'POKéMON'end}
    overrides['src.core.game3.battle.anim']={displayExpRatio=function(_,b)return b.expRatio or 0 end}
    overrides['src.core.game3.pokemon']={gender=function()end}
    overrides['src.core.game3.rom_text']={has=function()return false end}
    overrides['src.ui.game3.summary_chrome']=clone('src.ui.game3.summary_chrome',overrides)
    M.healthbox=clone('src.core.game3.battle.healthbox',overrides)
    if M.healthbox then M.healthbox.shouldShowCaughtMarker=function(_,b)return b.caught==true end end
    local function color(v)
      v=tonumber(v)or 0
      local function c(n)return (n*8+math.floor(n/4))/255 end
      return {c(v%32),c(math.floor(v/32)%32),c(math.floor(v/1024)%32),1}
    end
    M.colors=function(pp,maximum)
      local p=manifest.windowTextPal or {}
      local fg,shadow=p[14],p[16]
      if pp~=nil and maximum then
        local state
        if maximum==pp then state=3
        elseif maximum<=2 then state=pp>1 and 3 or 2-pp
        elseif maximum<=7 then state=pp>2 and 3 or 2-pp
        elseif pp==0 then state=2
        elseif pp<=math.floor(maximum/4) then state=1
        elseif pp>math.floor(maximum/2) then state=3
        else state=0 end
        local q=manifest.ppTextPal or {};fg,shadow=q[state*2+1]or fg,q[state*2+2]or shadow
      end
      return {fg=color(fg),shadow=color(shadow),bg={0,0,0,0}}
    end
    return true
  end
  function M.scope(fn,...)
    if not M.ready() then return fn(...) end
    local P=require('src.core.game3.profile')
    local F=require('src.ui.game3.frlg_font')
    local C=require('src.ui.game3.battle_chrome')
    local oldProfile=P.forSession;local savedF,savedC={},{}
    for k,v in pairs(M.font)do if type(v)=='function' then savedF[k]=F[k];F[k]=v end end
    for k,v in pairs(C)do savedC[k]=v end
    for k,v in pairs(M.chrome)do C[k]=v end
    local custom=mod.exports and mod.exports.battleUi
    if custom then
      C.drawPanel=function(mode)return custom.faded(function()M.chrome.drawPanel(mode);M.chrome.drawMenuFrames(mode)end)end
      C.drawMenuFrames=function()end
      for _,key in ipairs({'drawEnemyBox','drawPlayerBox','drawDoublesBox','drawSafariBox'})do
        C[key]=function(...)return custom.faded(M.chrome[key],...)end
      end
    end
    P.forSession=function(...)
      local native=oldProfile(...)
      return setmetatable({font=M.profile.font,ui=M.profile.ui},{__index=native})
    end
    local result={pcall(fn,...)}
    P.forSession=oldProfile
    for k in pairs(M.font)do if type(M.font[k])=='function'then F[k]=savedF[k]end end
    for k in pairs(M.chrome)do C[k]=savedC[k]end
    if not result[1]then error(result[2],0)end
    return (unpack or table.unpack)(result,2)
  end
  local gbMap,gbSignature
  function M.decode(line)
    if type(line)=='string'then return line end
    local F=require('src.render.Font')
    local signature=tostring(F.revision)..':'..table.concat(F.encode("Aa'?!é♂♀"),',')
    if not gbMap or signature~=gbSignature then
      gbMap={};gbSignature=signature
      local missing=F.encode('?')[1];local space=F.encode(' ')[1]
      for n=32,126 do
        local s=string.char(n);local ids=F.encode(s)
        if #ids==1 and ((ids[1]~=missing and ids[1]~=space)or s=='?'or s==' ')then gbMap[ids[1]]=s end
      end
      for _,s in ipairs({"'d","'l","'m","'r","'s","'t","'v",'é','É','♀','♂'})do
        local ids=F.encode(s);if #ids==1 and ids[1]~=missing and ids[1]~=space then gbMap[ids[1]]=s end
      end
      gbMap[0xE1]='POKé';gbMap[0xE2]='MON';gbMap[0x7F]=' '
    end
    local out={};for _,c in ipairs(line or {})do out[#out+1]=gbMap[c]or '?'end
    return table.concat(out)
  end
  function M.bottom(battle,generation,rect,custom)
    if not M.ready() or battle.safari or battle.contest then return false end
    local message=generation==2 and (battle.phase=='intro' or battle.phase=='resolving' or battle.phase=='locked-in')
    if battle.phase~='menu' and battle.phase~='messages' and not message then return false end
    local G=love.graphics;local F,C=M.font,M.chrome
    G.push('all')
    local ok,err=pcall(function()
      local scale=math.min(rect.w/240,rect.h/48)
      G.origin();G.setShader();G.setScissor();G.translate(rect.x+(rect.w-240*scale)/2,rect.y+rect.h-48*scale)
      G.scale(scale,scale);G.translate(0,-112)
      local menu=battle.phase=='menu'
      custom.faded(function()C.drawPanel(menu and 'menu' or 'none');C.drawMenuFrames(menu and 'menu' or 'none')end)
      G.setColor(1,1,1,1)
      if menu then
        local p=battle.player
        local mon=generation==2 and battle:activeMon('player') or p and p.mon
        local name=p and p.name or mon and (mon.nickname or mon.name) or 'POKéMON'
        F.draw('What will\n'..name..' do?',9,113,{colors=C.textboxColors(1,6)})
        local labels={'FIGHT','BAG','POKéMON','RUN'}
        for i,s in ipairs(labels)do
          F.draw(s,128+56*((i-1)%2),121+16*math.floor((i-1)/2),{colors=M.colors()})
        end
        local c=(battle.menuIndex or 1)-1
        F.drawGlyph(F.CHAR_SELECTOR_ARROW,120+56*(c%2),121+16*math.floor(c/2),{colors=M.colors()})
      else
        local lines=generation==2 and battle:messageLines() or battle.shown or {}
        for i,line in ipairs(lines)do if i<=2 then F.draw(M.decode(line),8,113+(i-1)*16+(battle.scrollPx or 0),{colors=C.textboxColors(1,6),maxWidth=224})end end
        local arrow=generation==2 and battle:messageArrowVisible() or battle.msgWaiting or battle.msgPrompt
        if arrow then F.drawGlyph(0x7A,224,137,{colors=C.textboxColors(1,6)})end
      end
    end)
    G.pop();if not ok then error(err,0)end;return true
  end
  function M.hud(battle,generation,side)
    if not M.ready() or not M.healthbox then return false end
    local source=generation==2 and battle:activeMon(side) or battle[side] and battle[side].mon
    if not source then return true end
    local state=generation==2 and source or battle[side]
    local hp=generation==2 and battle:hudHp(source,side) or state.shownHP or source.hp or 0
    if generation==1 then hp=hp>(source.hp or hp)and math.ceil(hp)or math.floor(hp)end
    local status=state.shownStatus or state.status or source.status
    local statuses={slp=1,psn=8,brn=16,frz=32,par=64,tox=128,sleep=1,poison=8,burn=16,freeze=32,paralysis=64}
    if type(status)=='string'then status=statuses[status:lower()]or 0 end
    local mon={hp=hp,maxHp=source.maxHp or source.stats and source.stats.hp or 1,
      level=generation==2 and side=='player' and (battle.shownLevel or source.level)or source.level,
      gender=source.gender,status=status}
    local b={mon=mon,name=state.name or source.nickname or source.name or 'POKéMON',
      side=side,isPlayer=side=='player',expRatio=generation==2 and side=='player' and (battle.shownExp or 0)/64 or 0}
    if side=='enemy'then
      b.caught=generation==2 and battle.caughtMark or battle.caughtMarkerVisible and battle:caughtMarkerVisible()
    elseif generation==1 and source.exp and battle.data then
      local def=battle.data.species and battle.data.species[source.species]
      if def and (source.level or 100)<100 then
        local Growth=require('src.pokemon.Growth')
        local lo=Growth.expForLevel(def.growthRate,source.level,battle.data.growth_rates)
        local hi=Growth.expForLevel(def.growthRate,source.level+1,battle.data.growth_rates)
        if hi>lo then b.expRatio=math.max(0,math.min(1,(source.exp-lo)/(hi-lo)))end
      end
    end
    local G=love.graphics;G.push('all')
    local ok,err=pcall(M.healthbox.draw,side,b,{ox=side=='player' and -94 or -12,oy=side=='player' and -24 or -14})
    G.pop();if not ok then error(err,0)end;return true
  end
  function M.wideHud(battle,slide)
    if battle.safari or battle.demo or not battle:statusHUDVisible()then return false end
    if battle.fieldCleared then return true end
    local G=love.graphics;local custom=mod.exports.battleUi
    if battle.enemy and not battle.showEnemyTrainer and not battle.enemySendingOut and not battle.enemyHudPending
      and not battle:growInScale(battle.enemy)and (slide or 0)==0 and not battle.introBalls and not battle.enemy.fainted then
      M.hud(battle,1,'enemy');if custom.protect then custom.protect(0,0,128,32)end
    end
    if battle.player and not battle.showPlayerBack and (slide or 0)==0 and not battle.player.fainted then
      G.push('all');G.translate(152,8)
      local ok,err=pcall(M.hud,battle,1,'player')
      if custom.protect then custom.protect(32,48,128,40)end
      G.pop();if not ok then error(err,0)end
    end
    return true
  end
  function M.wideBottom(battle)
    if not battle:bottomUIVisible()then return true end
    local G=love.graphics;local x,y=G.transformPoint(0,104);local r,b=G.transformPoint(304,144)
    local custom=mod.exports.battleUi;local rect={x=x,y=y,w=r-x,h=b-y}
    local drawn
    if battle.phase=='moveSelect'then drawn=custom.moveScreen.draw(battle,rect,{})
    else drawn=M.bottom(battle,1,rect,custom)end
    if drawn and custom.protect then custom.protect(0,104,304,40)end
    return drawn
  end
  function M.wideDraw(...)
    M.wide=M.wide or clone('src.battle.WideBattle',M.overrides)
    return M.wide.draw(...)
  end
  return M
end
