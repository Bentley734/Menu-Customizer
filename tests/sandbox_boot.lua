package.path='./?.lua;./?/init.lua;'..package.path
love=require('tests.love_stub')
local GV=require('src.core.GameVersion');GV.set(arg[1])
local Loader=require('src.mods.Loader')
local fs={}
function fs.getInfo(path)
 if path=='mods' or path=='mods/menu' then return {type='directory'} end
 if files[path] then return {type='file'} end
 return nil
end
function fs.getDirectoryItems(path)if path=='mods' then return {'menu'}end;return {}end
function fs.read(path)return files[path]end
function fs.write(path,value)files[path]=value;return true end
function fs.createDirectory()return true end
function fs.load(path)return loadstring(files[path] or '')end
local loader=Loader.new({fs=fs,generation=GV.generation(),version=arg[1],dev=false})
loader:load({pokemon={},moves={},items={},maps={},tilesets={}})
local state=loader.mods.gen3transparency
if arg[2]=='published' then
 assert(state and state.state=='failed', 'published 3.1.0 must reproduce the boot failure')
 assert(table.concat(loader.errors,'\n'):find('Gen 3 engine module',1,true),'same cross-generation error as screenshot')
 print('PASS reproduced published 3.1.0 boot failure: '..arg[1]);return
end
assert(state and state.state=='loaded',table.concat(loader.errors,'\n'))
assert(loader.exports.gen3transparency.gbMenus,'GB menu exports available')
print('PASS actual .58 Loader/Sandbox boot: '..arg[1])
