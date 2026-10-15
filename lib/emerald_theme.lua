-- Native Emerald glyph masks; native fallback for control text and other scripts.
return function(mod,enabled)
 local G=love.graphics
 local charmap=assert(load(assert(mod:read('assets/emerald/charmap.lua'))))()
 local function glyphId(c)return charmap[c] or charmap['?'] end
 local M={enabled=enabled};local faces={}
 local function face(small,battle,narrow)
  local name=battle and (narrow and 'battle_narrow' or 'battle_normal') or small and 'small' or 'normal'
  if not faces[name] then
   local dir='assets/emerald/'..name
   local f={fg=mod.assets:image(dir..'_fg.png'),shadow=mod.assets:image(dir..'_shadow.png'),
    widths=assert(load(assert(mod:read(dir..'_widths.lua'))))(),quads={}}
   f.fg:setFilter('nearest','nearest');f.shadow:setFilter('nearest','nearest')
   -- Battle atlases contain ink beyond each glyph's proportional advance.
   -- Match the native renderer's width-clipped quads instead of drawing cells.
   for id=0,511 do
    local width=tonumber(f.widths[id] or f.widths[0]) or 16
    if width<=0 or width>16 then width=16 end
    f.quads[id]=G.newQuad(id%16*16,math.floor(id/16)*16,width,16,256,512)
   end
   faces[name]=f
  end
  return faces[name]
 end
 local supported={}
 for n=32,126 do supported[string.char(n)]=true end
 local function chars(text)return tostring(text):gmatch('[%z\1-\127\194-\244][\128-\191]*')end
 for c in chars('éÉàèùâêîôûäëïöüçÀÈÙÂÊÎÔÛÄËÏÖÜÇ♀♂¥')do supported[c]=true end
 local function glyphs(text)
  text=tostring(text)
  if mod.exports.customization then text=mod.exports.customization.text(text)end
  if text:find('[<>{}]') then return nil end
  local out={};for c in chars(text)do if c=='\n' then out[#out+1]=-1 elseif not supported[c]then return nil else out[#out+1]=glyphId(c)end end;return out
 end
 function M.measure(text,opts)
  local ids=glyphs(text);if not ids then return nil end
  local f=face(opts and opts.small,opts and opts.battle or mod.exports and mod.exports.battleFontScope,opts and opts.font=="narrow");local width=0
  local maximum=0
  for _,id in ipairs(ids)do if id==-1 then maximum=math.max(maximum,width);width=0 else width=width+(f.widths[id]or 6)end end
  return math.max(maximum,width)
 end
 function M.glyph(id,x,y,opts)
  local arrows=mod.exports and mod.exports.arrowSelectors
  if id==0xEF and arrows and arrows.draw(x,y,16,opts) then return true end
  -- Space is advance-only, even if the imported atlas's reserved cell has ink.
  if id==0 then if opts and opts.colors and opts.colors._effects then opts.colors._effects.ink(opts.colors,true)end;return true end
  local f=face(opts and opts.small,opts and opts.battle or mod.exports and mod.exports.battleFontScope,opts and opts.font=="narrow");local q=f.quads[id];if not q then return false end
  local colors=opts and opts.colors or {fg={.38,.38,.38,1},shadow={.84,.84,.8,1}}
  G.push('all');G.setShader()
  if colors._effects then colors._effects.glyph(colors,x,y,function(dx,dy)G.draw(f.fg,q,x+dx,y+dy)end,{width=f.widths[id]or 6,top=opts and opts.small and 3 or 2,height=opts and opts.small and 9 or 11})
  else
   G.setColor(unpack(colors.shadow or {.84,.84,.8,1}));G.draw(f.shadow,q,x,y)
   G.setColor(unpack(colors.fg or {.38,.38,.38,1}));G.draw(f.fg,q,x,y)
  end
  G.pop();return true
 end
 local drawing=false
 function M.draw(text,x,y,opts)
  local effects=opts and opts.colors and opts.colors._effects
  if effects and not drawing then
   drawing=true;local result={pcall(effects.sequence,opts.colors._kind or 'battle',M.draw,text,x,y,opts)};drawing=false
   if not result[1]then error(result[2],0)end;return unpack(result,2)
  end
  local ids=glyphs(text);if not ids then return nil end
  local f=face(opts and opts.small,opts and opts.battle or mod.exports and mod.exports.battleFontScope,opts and opts.font=="narrow");local pen=x
  local py,maximum,count=y,0,0
  for _,id in ipairs(ids)do
   if id==-1 then maximum=math.max(maximum,pen-x);pen=x;py=py+16
   else
    count=count+1;if opts and opts.limitChars and count>opts.limitChars then break end
    local width=f.widths[id]or 6
    if not opts or not opts.maxWidth or pen-x+width<=opts.maxWidth then M.glyph(id,pen,py,opts)end
    pen=pen+width
   end
  end
  return math.max(maximum,pen-x),pen,py
 end
 local GB=require('src.render.Font')
 local map,signature
 local function gbMap()
  local sig=tostring(GB.revision or 0)..':'..table.concat(GB.encode("ABCDEFGHIJKLMNOPQRSTUVWXYZé♀♂¥'d'l'm'r's't'v"),',')
  if not map or sig~=signature then
   map={};signature=sig
   local missing=GB.encode('?')[1]
   local space=GB.encode(' ')[1]
   for c in pairs(supported) do
    local codes=GB.encode(c)
    local id=glyphId(c)
    if #codes==1 and (codes[1]~=missing or c=='?') and codes[1]~=space and id~=0 then map[codes[1]]={id} end
   end
   for token,text in pairs({['№']='No',['<DOT>']='.',['<PO>']='PO',['<KE>']='Ké',['<PK>']='PK',['<MN>']='MN',["'d"]="'d",["'l"]="'l",["'m"]="'m",["'r"]="'r",["'s"]="'s",["'t"]="'t",["'v"]="'v"}) do
    local codes=GB.encode(token)
    if #codes==1 and codes[1]~=missing and codes[1]~=space then map[codes[1]]=glyphs(text) end
   end
   -- Unsupported engine characters may encode to SPACE. Never let one of
   -- those aliases replace the blank with an unrelated Emerald glyph.
   if space then map[space]={0} end
  end
  return map
 end
 function M.gbAdvance(code)
  local ids=gbMap()[code];if not ids then return nil end
  local width=0;local f=face(false,mod.exports and mod.exports.battleFontScope)
  for _,id in ipairs(ids) do width=width+(f.widths[id] or 6) end
  return width*(M.gbScale and M.gbScale() or .5)
 end
 function M.gbGlyph(code,x,y)
  local ids=gbMap()[code];if not ids then return false end
  -- Doubled menu surface retains each Emerald pixel at uniform half-size
  -- logical coordinates, without squeezing individual letters into tiles.
  local scale=M.gbScale and M.gbScale() or .5
  -- Align the full-size font's lower edge with GB's eight-pixel baseline,
  -- so the final row clears the frame without changing the row spacing.
  G.push('all');G.translate(x,y-(scale==1 and 6 or 0)-(M.gbBaseline and M.gbBaseline() or 0));G.scale(scale,scale)
  local pen=0;local f=face(false,mod.exports and mod.exports.battleFontScope)
  for _,id in ipairs(ids) do M.glyph(id,pen,0,M.gbColors and {colors=M.gbColors()} or nil);pen=pen+(f.widths[id] or 6) end
  G.pop();return true
 end
 return M
end
