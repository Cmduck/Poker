--
-- Author: lcf
-- Date: 2016-07-05 12:10:21
--
-- 继承于 display.newNode()
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local UIListView = require(cc.PACKAGE_NAME ..".cc.ui.UIListView")
local MusicChat = class("MusicChat" ,function()
	return display.newNode()
end)


-- local isMan = true
-- local musicCV =  require ("script.public.MusicChat").new("ccbResources/oxRes"):addTo(self)
-- musicCV:setPosition(display.cx, display.cy)

-- musicCV:playSound(voiceID ,isMan)

-- 游戏当中监听
-- elseif (32==wCmdID)then
--     print("声音dwUserID.........."..Var1)
--     print("声音dwTargetUserID.........."..Var2)
--     print("声音dwUserID.........."..Var3)
--     self.musicCV:playSound(Var3 ,true)

-- gameResPath 传入游戏资源路径 ccbResources/oxRes
    -- 自动寻找 musicChatRes 目录下的配置和资源
-- isMan 传用户是否是男性
function MusicChat:ctor( gameResPath )
	print("MiniChat:ctor()")
    self.gameResPath = gameResPath

    local tagAccData=FGameDC:getDC():GetAccountsData();
    if(tagAccData.cbGender~=1)then 
        self.isMan = true
    else
        self.isMan = false
    end
    self.ini = self:realFile(gameResPath.."/musicChatRes/musicChat.txt")

    self.BG = display.newSprite(gameResPath.."/musicChatRes/View/"..self.ini.view.BG):addTo(self)

    self.musicInfo = nil
    self.musicPath = "Man"
    if isMan or isMan==nil then
        self.musicInfo =self.ini.musicMan
    else
        self.musicInfo =self.ini.musicWoMan
        self.musicPath = "WoMan"
    end

    -- dump(self.musicInfo)
    -- print(",,,,,,,,,,,,,,"..#self.musicInfo)
    -- print(",,,,,,,,,,,,,,"..#self.ini.fontColor)
	self.listView =	UIListView.new
	{
		-- bgColor = cc.c4b(100, 100, 100, 120),
        viewRect = cc.rect(-self.ini.W/2,-self.ini.H/2, self.ini.W, self.ini.H),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:onTouch(handler(self, self.touchListener))

    self.listView:addTo(self)

    for i,v in ipairs(self.musicInfo) do
        local item = self.listView:newItem()
        local content
        content = cc.ui.UILabel.new(
                    {text = v.info,
                    size = self.ini.fontSize,
                    align = cc.ui.TEXT_ALIGN_CENTER,
                    color = cc.c3b(self.ini.fontColor.R, self.ini.fontColor.G, self.ini.fontColor.B)})
        content:setOpacity(self.ini.fontColor.A)
        item:addContent(content)
        if i>1 then
            local SprObj=display.newSprite(gameResPath.."/musicChatRes/View/"..self.ini.view.Line)
            assert(SprObj~=nil)
            item:addContent(SprObj)
            SprObj:setPosition(330, 50)
        end
        item:setItemSize(self.ini.W, self.ini.fontSize+20)

        self.listView:addItem(item)
    end

    self.listView:reload()

    --dump(self.ini.view)
    local buttonImage = {
        normal = gameResPath.."/musicChatRes/View/"..self.ini.view.closeBT1,
        pressed = gameResPath.."/musicChatRes/View/"..self.ini.view.closeBT2,
        disabled = gameResPath.."/musicChatRes/View/"..self.ini.view.closeBT3,
    }

    self.closeButton = cc.ui.UIPushButton.new(buttonImage)
        :onButtonClicked(function(event)
            self:hide()
        end)
        :align(display.CENTER, 255, 180)
        :addTo(self)
end

function MusicChat:getCloseButton()
    return self.closeButton
end

function MusicChat:getCloseButton()
    return self.BG
end

function MusicChat:getWidth()
    return self:getCascadeBoundingBox().width
end

function MusicChat:height()
    return self:getCascadeBoundingBox().height
end

function MusicChat:touchListener(event)
    -- dump(event)
    if "clicked" == event.name then
        local item = event.item
        local width = item:getContent():getContentSize().width+50
        local temp = self.ini.W/2-width/2
        if event.point.x>temp and event.point.x<(self.ini.W-temp) then
            print("event.itemPos:" .. event.itemPos)
            print("该播放的音效为==="..self.gameResPath.."/musicChatRes/"..self.musicPath.."/"..self.musicInfo[event.itemPos].fileName..".mp3")
            print("该音效信息为==="..self.musicInfo[event.itemPos].info)
            local function done()
                --发送语言信息 dwTargetUserID/wVoiceIndex是接口参数  
                local pUserData=FGameDC:getDC():GetUserInfo(FGameDC:getDC():GetMeChairID());
                if pUserData~=nil then
                    local Msg="int,1,"..pUserData.dwUserID..",int,1,".."0"..",word,1,"..tonumber(self.musicInfo[event.itemPos].fileName)..","
                    FGameDC:getDC():SendGameMsg(117,Msg,0,101);
                    print("MusicChat-----Msg="..Msg)
                else
                    print("MusicChat-----pUserData 为nil")
                end
                self:hide()

            end
            item:getContent():runAction(cca.seq({cca.scaleTo(0.15, 1.15),cca.scaleTo(0.15, 1),cca.callFunc(done)}))

        end
    end
end
--根据传入的id 获取文本
function MusicChat:GetContentById(voiceID)
    -- 
    local res="";
    for i,v in ipairs(self.musicInfo) do
        if tonumber(v.fileName)==voiceID then
            --
            res=v.info;
            break
        end
    end

    return res;
end
-- 播放音效，voiceID为播放的id，isMan为说话人的性别
function MusicChat:playSound( voiceID ,isMan)
    if not isMan then
        --
        voiceID=voiceID + #self.ini.musicMan
    end
    if isMan or isMan==nil then
        audio.playSound(self.gameResPath.."/musicChatRes/Man/"..voiceID..".mp3")
    else
        audio.playSound(self.gameResPath.."/musicChatRes/Woman/"..voiceID..".mp3")
    end
end

function MusicChat:realFile(path)
    local fileData = cc.HelperFunc:getFileData(path)
    if(nil~=fileData)then
        local fun = loadstring(fileData)
        local ret, ini = pcall(fun)
        assert(ret)
        if ret then
            return ini
        end
        return ini
    end
    return nil;
end


return MusicChat