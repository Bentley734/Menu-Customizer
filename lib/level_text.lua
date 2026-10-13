-- TextIR's expanded LV_2 symbol is not a printable literal tag. Use actual
-- font characters in both measurement and drawing so levels stay contiguous.
local M={}
function M.normalize(text)
 if type(text)~='string'then return text end
 return (text:gsub('{LV_2}','Lv'):gsub('<LV_2>','Lv'))
end
return M
