-- Flatten opaque panel layers, then apply opacity exactly once.
return function(G, opacity)
  local pool, depth = {}, 0
  local unpack=unpack or table.unpack
  return function(draw,w,h,x,y,...)
    depth=depth+1
    local slot=depth
    local key=w..'x'..h
    pool[slot]=pool[slot] or {}
    local canvas=pool[slot][key]
    if not canvas then
      canvas=G.newCanvas(w,h,{dpiscale=1,format='rgba8'})
      canvas:setFilter('nearest','nearest')
      pool[slot][key]=canvas
    end
    G.push('all')
    G.setCanvas(canvas); G.origin(); G.setScissor(); G.setShader()
    G.setBlendMode('alpha','alphamultiply'); G.clear(0,0,0,0)
    G.setColor(1,1,1,1)
    local result={pcall(draw,...)}
    G.pop()
    depth=depth-1
    if not result[1] then error(result[2],0) end
    G.push('all')
    -- A canvas contains premultiplied pixels. Disable the caller's indexed
    -- palette shader so landscape cannot reinterpret true-color UI as shades.
    G.setShader(); G.setBlendMode('alpha','premultiplied')
    local a=opacity()/100
    G.setColor(a,a,a,a); G.draw(canvas,x or 0,y or 0)
    G.pop()
    return unpack(result,2)
  end
end
