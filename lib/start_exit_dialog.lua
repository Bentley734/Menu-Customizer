-- The native Start renderer also paints the parent menu during confirmation.
-- Deferred text would otherwise replay those labels above the popup frames.
return function(Window,Chrome,draw,...)
 local unpack=unpack or table.unpack
 local saved={};local confirmation=false
 for _,key in ipairs({'stdFrame','printPx','cursorPx'})do
  local original=Window[key];saved[key]=original
  Window[key]=function(...)if confirmation then return original(...)end end
 end
 local dialogue=Chrome.dialogueFrame
 Chrome.dialogueFrame=function(...)
  confirmation=true
  return saved.stdFrame(Window.template(1,15,28,4))
 end
 local result={pcall(draw,...)}
 Chrome.dialogueFrame=dialogue
 for key,value in pairs(saved)do Window[key]=value end
 if not result[1]then error(result[2],0)end
 return unpack(result,2)
end
