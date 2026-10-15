-- Small field windows share the OPTIONS palette, independently of dialogue.
return function(mod,palette,active)
 local unpack=unpack or table.unpack
 local function install(name,gb,choice)
  local ok,window=pcall(require,name);if not ok or not window.draw then return end
  window._menuCustomizerPreview={mod=mod,palette=palette,active=active}
  if window._menuCustomizerPreviewDraw then return end
  local original=window.draw;window._menuCustomizerPreviewDraw=original
  window.draw=function(...)
   local state=window._menuCustomizerPreview
   if not state.active()then return original(...)end
   local exports=state.mod.exports;local current=exports.gbMenus
   local preview,paper,dialogue,choiceFont=exports.previewScope,exports.menuPaperScope,exports.dialogueFontScope,exports.choiceFontScope
   exports.previewScope,exports.menuPaperScope,exports.dialogueFontScope=true,'option',false
   exports.choiceFontScope=gb and choice or false
   local drawScope,gbDialogue,gbPaper
   if current then
    drawScope,gbDialogue,gbPaper=current.drawScope,current.dialogueScope,current.paperGroup
    current.drawScope,current.dialogueScope,current.paperGroup=true,false,'option'
   end
   local args={n=select('#',...),...}
   local owner=args[1];local oldTX,oldTW,printer,glyph
   if gb and choice and current and owner then
    local il,ir,ds=current.borders.insets('option',160,144)
    if ds then
     local F=require('src.render.Font');oldTX,oldTW=owner.tx,owner.tw
     local widest=0;for _,text in ipairs(owner.labels or{'YES','NO'})do widest=math.max(widest,F.width(require('src.core.Strings')(text)))end
     owner.tw=math.min(20,math.max(owner.tw,math.ceil((widest+il+ir)/8)))
     owner.tx=math.max(0,math.min(owner.tx,20-owner.tw))
     printer,glyph=F.draw,F.drawCode
     F.draw=function(text,x,y,...)return printer(text,owner.tx*8+il,y,...)end
     F.drawCode=function(id,x,y,...)return glyph(id,owner.tx*8+4,y,...)end
    end
   end
   local result={pcall(function()
    if gb then return state.palette.withText('menu',original,unpack(args,1,args.n))end
    return state.palette.menuScope(original,unpack(args,1,args.n))
   end)}
   if printer then local F=require('src.render.Font');F.draw,F.drawCode=printer,glyph;owner.tx,owner.tw=oldTX,oldTW end
   if current then current.drawScope,current.dialogueScope,current.paperGroup=drawScope,gbDialogue,gbPaper end
   exports.previewScope,exports.menuPaperScope,exports.dialogueFontScope,exports.choiceFontScope=preview,paper,dialogue,choiceFont
   if not result[1]then error(result[2],0)end;return unpack(result,2)
  end
 end
 if mod.generation==3 then
  install('src.ui.game3.mon_pic');install('src.ui.game3.choice')
 else install('src.ui.PicBox',true);install('src.ui.ChoiceBox',true,true)end
end
