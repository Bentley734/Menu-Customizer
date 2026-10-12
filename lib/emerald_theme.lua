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
   for id=0,511 do f.quads[id]=G.newQuad(id%16*16,math.floor(id/16)*16,16,16,256,512) end
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
  if text:find('[<>{}]') then return nil end
  local out={};for c in chars(text)do if not supported[c] then return nil end;out[#out+1]=glyphId(c) end;return out
 end
 function M.measure(text,opts)
  local ids=glyphs(text);if not ids then return nil end
  local f=face(opts and opts.small,opts and opts.battle or mod.exports and mod.exports.battleFontScope,opts and opts.font=="narrow");local width=0
  for _,id in ipairs(ids)do width=width+(f.widths[id] or 6) end
  return width
 end
 function M.glyph(id,x,y,opts)
  -- Space is advance-only, even if the imported atlas's reserved cell has ink.
  if id==0 then return true end
  local f=face(opts and opts.small,opts and opts.battle or mod.exports and mod.exports.battleFontScope,opts and opts.font=="narrow");local q=f.quads[id];if not q then return false end
  local colors=opts and opts.colors or {fg={.38,.38,.38,1},shadow={.84,.84,.8,1}}
  G.push('all');G.setShader()
  G.setColor(unpack(colors.shadow or {.84,.84,.8,1}));G.draw(f.shadow,q,x,y)
  G.setColor(unpack(colors.fg or {.38,.38,.38,1}));G.draw(f.fg,q,x,y)
  G.pop();return true
 end
 function M.draw(text,x,y,opts)
  local ids=glyphs(text);if not ids then return nil end
  local f=face(opts and opts.small,opts and opts.battle or mod.exports and mod.exports.battleFontScope,opts and opts.font=="narrow");local pen=x
  for i,id in ipairs(ids)do
   if opts and opts.limitChars and i>opts.limitChars then break end
   local width=f.widths[id] or 6
   if opts and opts.maxWidth and pen-x+width>opts.maxWidth then break end
   M.glyph(id,pen,y,opts);pen=pen+width
  end
  return pen-x
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
   for token,text in pairs({['<PO>']='PO',['<KE>']='Ké',['<PK>']='PK',['<MN>']='MN',["'d"]="'d",["'l"]="'l",["'m"]="'m",["'r"]="'r",["'s"]="'s",["'t"]="'t",["'v"]="'v"}) do
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
  local width=0;local f=face(false)
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
  G.push('all');G.translate(x,y-(scale==1 and 6 or 0));G.scale(scale,scale)
  local pen=0;local f=face(false)
  for _,id in ipairs(ids) do M.glyph(id,pen,0,M.gbColors and {colors=M.gbColors()} or nil);pen=pen+(f.widths[id] or 6) end
  G.pop();return true
 end
 return M
end
