-- FR/LG's fixed GBA text cells must not inherit GB battle magnification.
return function(mod)
 local V=require('src.core.GameVersion')
 local function active()local v=V.get();return mod.generation==3 and (v=='firered'or v=='leafgreen')end
 local M={active=active}
 function M.choice()return tonumber(mod.options:get('frlgTextSize'))==2 and 2 or 1 end
 function M.options(opts)
  if not active() or M.choice()==1 or opts and opts._vanilla then return opts end
  local copy={};for k,v in pairs(opts or{})do copy[k]=v end
  -- Use an actual smaller atlas, never squeeze or fractionally scale pixels.
  copy.small=true;copy.font='small';return copy
 end
 function M.install()
  if mod.generation~=3 then return end
  local F=require('src.ui.game3.frlg_font')
  local state=F._menuCustomizerFrlgTextSize
  if state then state.api=M;return end
  state={api=M};F._menuCustomizerFrlgTextSize=state
  for _,key in ipairs({'draw','drawGlyph','measure','advance','wrap'})do
   local original=F[key]
   if original then
    if key=='draw'or key=='drawGlyph'then
     F[key]=function(text,x,y,opts,...)return original(text,x,y,state.api.options(opts),...)end
    elseif key=='wrap'then
     F[key]=function(text,width,opts,...)return original(text,width,state.api.options(opts),...)end
    else
     F[key]=function(text,opts,...)return original(text,state.api.options(opts),...)end
    end
   end
  end
 end
 mod.exports.frlgTextSize=M
 return M
end
