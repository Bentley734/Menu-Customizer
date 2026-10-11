from pathlib import Path
import os,sys
root=Path(__file__).resolve().parents[2];sys.path.insert(0,str(root/'.tools/lua-test'))
from lupa.luajit21 import LuaRuntime
os.chdir(root/'.tools/engine-0358')
for version in ['red','blue','yellow','gold','silver','crystal','ruby','sapphire','emerald','firered','leafgreen']:
 for legacy in ['legacy','merged']:
  lua=LuaRuntime(unpack_returned_tuples=True);lua.execute('unpack=unpack or table.unpack;loadstring=loadstring or load')
  files={}
  for folder,mod in [('menu','MenuCustomizer'),('battle','BattleUICustomizer'),('kim','.work/latest-sprite-fix/current-source/kim1025')]:
   for p in (root/mod).rglob('*'):
    if p.is_file() and p.suffix in ['.lua','.json']:files['mods/'+folder+'/'+p.relative_to(root/mod).as_posix()]=p.read_text(encoding='utf8')
  lua.globals().files=lua.table_from(files);lua.globals().arg=lua.table_from([version,'fallback',legacy])
  try:lua.execute((root/'MenuCustomizer/tests/battle_merge_boot.lua').read_text())
  except Exception as e:print(version,legacy,e);raise
