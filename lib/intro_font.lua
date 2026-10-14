-- Apply shared font/color/effect rendering to native boot text and captions.
return function(mod,Font,active)
 for _,path in ipairs({'src.ui.IntroMovie','src.ui.YellowIntro','src.ui.TitleState','src.ui.OakSpeech','src.ui.gen2.TitleState','src.ui.gen2.OakSpeech','src.ui.gen2.GoldSilverIntro','src.ui.gen2.CrystalIntro'})do
  local ok,Class=pcall(require,path)
  if ok and type(Class.draw)=='function'and not Class._customIntroFont then
   Class._customIntroFont=true;local draw=Class.draw
   Class.draw=function(self,...)
    local C=Font._menuCustomizerGB;if not(active()and C)then return draw(self,...)end
    local scope,intro,rx,ry=C.drawScope,C.introScope,C.resizeX,C.resizeY
    C.drawScope=true;C.introScope=true;C.resizeX=1;C.resizeY=1
    local result={pcall(draw,self,...)}
    C.drawScope,C.introScope,C.resizeX,C.resizeY=scope,intro,rx,ry
    if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
   end
   if Class.drawCopyright then local original=Class.drawCopyright
    Class.drawCopyright=function(self,y,...)
     local C=Font._menuCustomizerGB
     if not(C and C.introScope and C.theme.enabled())then return original(self,y,...)end
     local G=love.graphics;G.setColor(0,0,0,1)
     local function caption(text,row)Font.draw(text,math.max(4,math.floor((160-Font.width(text))/2)),row)end
     if path=='src.ui.IntroMovie'then
      caption('Nintendo',56);caption('Creatures inc.',72);caption('GAME FREAK inc.',88)
     else caption(self.title and self.title.copyrightText or 'GAME FREAK inc.',y or 136)end
     G.setColor(1,1,1,1)
    end
   end
   if path=='src.ui.TitleState'then
    local outer=Class.draw
    Class.draw=function(self,...)
     local C=Font._menuCustomizerGB;local G=love.graphics;local original=G.draw;local emitted=false
     G.draw=function(image,...)
      if image==self.version and active()and C and C.setting('introTheme')~=1 then
       if not emitted then
        emitted=true;local text=self.blue and 'Blue Version'or 'Red Version'
        local scope,intro,rx,ry=C.drawScope,C.introScope,C.resizeX,C.resizeY
        C.drawScope=true;C.introScope=true;C.resizeX=1;C.resizeY=1
        Font.draw(text,math.floor((160-Font.width(text))/2)+(self.ribbonOffset or 0),64)
        C.drawScope,C.introScope,C.resizeX,C.resizeY=scope,intro,rx,ry
       end;return
      end
      return original(image,...)
     end
     local result={pcall(outer,self,...)};G.draw=original
     if not result[1]then error(result[2],0)end;return (unpack or table.unpack)(result,2)
    end
   end
  end
 end
end
