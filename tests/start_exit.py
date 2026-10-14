from pathlib import Path
import sys
sys.path.insert(0,'.tools/python')
from lupa.lua53 import LuaRuntime
vm=LuaRuntime(unpack_returned_tuples=True)
vm.globals().helper=Path('MenuCustomizer/lib/start_exit_dialog.lua').read_text()
s=Path('.tools/engine-0358/src/ui/game3/start_menu.lua').read_text();vm.globals().native=s[s.index('function StartMenu.draw()'):s.index('return StartMenu',s.index('function StartMenu.draw()'))]
vm.execute('''
local events={}
local function record(kind,value)events[#events+1]={kind,value}end
local Window={template=function(l,t,w,h)return {left=l,top=t,w=w,h=h}end,
 stdFrame=function(t)record('frame',t.top)end,printPx=function(t)record('text',t)end,
 cursorPx=function()record('cursor')end,menuRowPx=function(y,r)return y+(r-1)*16 end,CURSOR_WIDTH=8}
local Chrome={dialogueFrame=function()record('dialogue')end}
local FrlgFont={COLOR={NORMAL={}},draw=function(t)record('text',t)end}
local StartMenu={open=true,_confirmExit=true,_confirmCursor=2,cursor=8,ENTRIES={},
 _data={rowPitch=16,textY=2},contentTemplate=function()return Window.template(21,1,7,18)end}
for _,label in ipairs({'POKEMON','BAG','ASH','CHEATS','SAVE','TRAVEL','OPTION','EXIT'})do StartMenu.ENTRIES[#StartMenu.ENTRIES+1]={label=label}end
local env=setmetatable({StartMenu=StartMenu,Window=Window,Chrome=Chrome,FrlgFont=FrlgFont,Strings=function(t)return t end,
 RomText={plain=function(k)return k=='gText_Yes' and 'YES' or 'NO'end}},{__index=_G})
assert(load(native,'native','t',env))()
local confirm=assert(load(helper))()
local oldFrame,oldPrint,oldCursor,oldDialogue=Window.stdFrame,Window.printPx,Window.cursorPx,Chrome.dialogueFrame
confirm(Window,Chrome,StartMenu.draw)
assert(#events==6,#events)
assert(events[1][1]=='dialogue' and events[2][2]=='RETURN TO MAIN\\nMENU?' and events[3][1]=='frame' and events[3][2]==9 and events[4][1]=='cursor' and events[5][2]=='YES' and events[6][2]=='NO')
assert(Window.stdFrame==oldFrame and Window.printPx==oldPrint and Window.cursorPx==oldCursor and Chrome.dialogueFrame==oldDialogue)
assert(not pcall(confirm,Window,Chrome,function()error('intentional')end))
assert(Window.stdFrame==oldFrame and Window.printPx==oldPrint and Window.cursorPx==oldCursor and Chrome.dialogueFrame==oldDialogue)
print('PASS actual native Exit rendering: no parent labels; prompt, popup, YES/NO, selector and error restoration')
''')

