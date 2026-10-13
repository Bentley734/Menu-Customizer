-- Profiles live in the mod's options bucket, independent of progress saves.
return function(mod)
 local ID='gen3transparency'
 local originalGet=mod.options.get
 local originalSaveGet=mod.save.get
 local M={}
 local function version()return require('src.core.GameVersion').get()end
 local function copy(t)
  local out={};for k,v in pairs(t or {})do if type(v)~='table'and k~='_settingsScope'then out[k]=v end end;return out
 end
 local function document()return originalGet(mod.options,'_settingsProfiles')end
 function M.mode()return tonumber(originalGet(mod.options,'_settingsScope'))or 0 end
 local function selected()
  local doc=document()
  if not doc then return nil end
  if M.mode()==1 then return doc.games and doc.games[version()]or doc.shared end
  return doc.shared
 end
 mod.options.get=function(self,key)
  if key=='_settingsProfiles'or key=='_settingsScope'then return originalGet(self,key)end
  local profile=selected()
  if profile then return profile[key]end
  return originalGet(self,key)
 end
 mod.save.get=function(self,key,default)
  local profile=selected()
  if profile then local value=profile[key];if value==nil then return default end;return value end
  return originalSaveGet(self,key,default)
 end
 local function context(ctx)
  local runtime=require('src.mods.Runtime')
  local game=ctx and(ctx.game or ctx)or runtime.game or runtime._game
  local options=ctx and ctx.options or game and(game.options or game.save and game.save.options)
  local loader=game and game.mods
  if not options then return nil end
  options.modOptions=options.modOptions or {}
  local bucket=options.modOptions[ID]or {};options.modOptions[ID]=bucket
  return bucket,game,options,loader
 end
 local function publish(bucket,game,options,loader)
  if loader then loader.modOptions=loader.modOptions or {};loader.modOptions[ID]=bucket end
  if game and game.save and game.save.options then game.save.options.modOptions=options.modOptions end
 end
 function M.commit(ctx)
  local bucket,game,options,loader=context(ctx);if not bucket then return end
  local doc=bucket._settingsProfiles
  if doc then
   doc.games=doc.games or {}
   if tonumber(bucket._settingsScope)==1 then doc.games[version()]=copy(bucket)else doc.shared=copy(bucket)end
  end
  publish(bucket,game,options,loader)
 end
 function M.apply(ctx)
  local bucket,game,options,loader=context(ctx);if not bucket then return end
  local doc=bucket._settingsProfiles;if not doc then return end
  doc.games=doc.games or {}
  local profile=tonumber(bucket._settingsScope)==1 and(doc.games[version()]or doc.shared)or doc.shared
  local values=copy(profile)
  for k,v in pairs(bucket)do if type(v)~='table'and k~='_settingsScope'then bucket[k]=nil end end
  for k,v in pairs(values)do bucket[k]=v end
  publish(bucket,game,options,loader)
  if mod.exports.resetMenuSettings then mod.exports.resetMenuSettings()end
 end
 function M.switch(ctx)
  local bucket,game,options,loader=context(ctx);if not bucket then return false end
  if not bucket._settingsProfiles then bucket._settingsProfiles={shared=copy(bucket),games={}}end
  M.commit(ctx)
  bucket._settingsScope=tonumber(bucket._settingsScope)==1 and 0 or 1
  local doc=bucket._settingsProfiles
  if bucket._settingsScope==1 and not doc.games[version()]then doc.games[version()]=copy(doc.shared)end
  M.apply(ctx)
  if game and game.writeOptions then game:writeOptions()end
  return false
 end
 function M.row()
  return {id='wide_settingsScope',label='SETTINGS STORAGE',value=function()return M.mode()==1 and 'PER GAME'or'SHARED'end,step=function(ctx)return M.switch(ctx)end}
 end
 mod.exports.settingsProfiles=M
 mod.events:on('game.ready',function(event)M.apply(event.game)end)
 return M
end
