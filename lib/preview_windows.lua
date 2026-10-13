-- Small field windows share the OPTIONS palette, independently of dialogue.
return function(mod,palette,active)
 local unpack=unpack or table.unpack
 local function install(name,gb)
  local ok,window=pcall(require,name);if not ok or not window.draw then return end
  window._menuCustomizerPreview={mod=mod,palette=palette,active=active}
  if window._menuCustomizerPreviewDraw then return end
  local original=window.draw;window._menuCustomizerPreviewDraw=original
  window.draw=function(...)
   local state=window._menuCustomizerPreview
   if not state.active()then return original(...)end
   local exports=state.mod.exports;local current=exports.gbMenus
   local preview,paper,dialogue=exports.previewScope,exports.menuPaperScope,exports.dialogueFontScope
   exports.previewScope,exports.menuPaperScope,exports.dialogueFontScope=true,'option',false
   local drawScope,gbDialogue,gbPaper
   if current then
    drawScope,gbDialogue,gbPaper=current.drawScope,current.dialogueScope,current.paperGroup
    current.drawScope,current.dialogueScope,current.paperGroup=true,false,'option'
   end
   local args={n=select('#',...),...}
   local result={pcall(function()
    if gb then return state.palette.withText('menu',original,unpack(args,1,args.n))end
    return state.palette.menuScope(original,unpack(args,1,args.n))
   end)}
   if current then current.drawScope,current.dialogueScope,current.paperGroup=drawScope,gbDialogue,gbPaper end
   exports.previewScope,exports.menuPaperScope,exports.dialogueFontScope=preview,paper,dialogue
   if not result[1]then error(result[2],0)end;return unpack(result,2)
  end
 end
 if mod.generation==3 then
  install('src.ui.game3.mon_pic');install('src.ui.game3.choice')
 else install('src.ui.PicBox',true);install('src.ui.ChoiceBox',true)end
end
