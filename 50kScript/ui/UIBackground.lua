module(..., package.seeall) 

--------------------------------------------------------------------------
-- UI -- 背景UI
--------------------------------------------------------------------------
local scheduler     = require(cc.PACKAGE_NAME .. ".scheduler")
local EventProxyEx  = require("script.50kScript.common.EventProxyEx")
local GameLogic     = require("script.50kScript.game.GameLogic")
local MusicCenter = require("script.50kScript.music.MusicCenter")
local UIBase        = require("script.50kScript.ui.UIBase")
local UIBackground  = class("UIBackground", UIBase)

UIBackground.CLICK_EXIT_BTN_EVENET = "CLICK_EXIT_BTN_EVENET"

function UIBackground:ctor()
    UIBackground.super.ctor(self) 
end

function UIBackground:update(dt)
    -- body
    local time = os.date("%H:%M")
    cc.uiloader:seekNodeByName(self.UINode_, "time_text"):setString(time)
end

function UIBackground:onShow()
    -- body
    print(self.__cname .. ":onShow()")
    self:InitView()
    self:RegisterButtonEvent()
    self:LoadUIComponent()
    --self:InitWaitingBaoImg()
end

function UIBackground:InitView()
    -- body
    -- 背景分辨率适配
    cc.uiloader:seekNodeByName(self.UINode_, "bg_left"):setPositionY(display.cy)
    cc.uiloader:seekNodeByName(self.UINode_, "bg_right"):setPositionY(display.cy)
    cc.uiloader:seekNodeByName(self.UINode_, "bg_left"):setScaleY(display.height / 720)
    cc.uiloader:seekNodeByName(self.UINode_, "bg_right"):setScaleY(display.height / 720)

    self:SuitScreenForBg(cc.uiloader:seekNodeByName(self.UINode_, "bg_left"), cc.uiloader:seekNodeByName(self.UINode_, "bg_right"))

    --数值节点
    local numNodeName = {"num_score", "num_bei"}
    for i, v in ipairs(numNodeName) do
        self[v] = cc.uiloader:seekNodeByName(self.UINode_, v)
    end

    --牌型节点
    local cardTypeNodeName = "node_type_"
    --1 有 2 无
    local subNodeNameTab = {"Btn_card_type", "img_card_type_1", "img_card_type_2"}
    for i = 1, 6 do
        local parentNodeName = cardTypeNodeName .. i
        self[parentNodeName] = cc.uiloader:seekNodeByName(self.UINode_, parentNodeName)
        for j, v in ipairs(subNodeNameTab) do
            self[parentNodeName .. "_" .. v] = cc.uiloader:seekNodeByName(self[parentNodeName], v)
            --初始显示灰色
            if v == "img_card_type_1" then
                self[parentNodeName .. "_" .. v]:setVisible(false)
            end
        end
    end
end

function UIBackground:RegisterButtonEvent()
    -- body
    cc.uiloader:seekNodeByName(self.UINode_, "Btn_exit"):onButtonClicked(handler(self, self.clickExitBtn))
    cc.uiloader:seekNodeByName(self.UINode_, "Btn_voice"):onButtonClicked(handler(self, self.clickVoiceBtn))
    cc.uiloader:seekNodeByName(self.UINode_, "Btn_setting"):onButtonClicked(handler(self, self.clickSettingBtn))
    --cc.uiloader:seekNodeByName(self.UINode_, "Button_dismiss"):onButtonClicked(handler(self, self.clickDismissBtn))

    --注册牌型按钮事件
    --牌型节点
    local cardTypeNodeName = "node_type_"
    for i = 1, 6 do
        local parentNodeName = cardTypeNodeName .. i
        self[parentNodeName .. "_" .. "Btn_card_type"]:onButtonClicked(handler(self, self.clickCardTypeBtn))
        self[parentNodeName .. "_" .. "Btn_card_type"]:setTag(i)
        self[parentNodeName .. "_" .. "Btn_card_type"]:setButtonEnabled(false)
    end 
end

function UIBackground:LoadUIComponent()
    -- body
    UIManager:ShowUI("UIMusicChat"):setLocalZOrder(100)
    UIManager:ShowUI("UIChatBubble"):setLocalZOrder(100)
end

function UIBackground:InitWaitingBaoImg()
    -- body
    -- self.m_imgWaitBao = display.newSprite("ccbResources/sparrowyhRes/base/wait_bao.png")
    -- self.m_imgWaitBao:align(display.CENTER, display.cx, display.cy)
    -- self.m_imgWaitBao:addTo(self)
    -- self.m_imgWaitBao:setVisible(false)
end

function UIBackground:InitCardType()

end

function UIBackground:onHide()
    -- body
end

function UIBackground:onUpdate()
    -- body
    --dump(GetSelfChairID() == DataCenter:getUserChairId())
    --dump(DataCenter:getServerType() == 0x0001)
    -- if DataCenter:getServerType() == 0x0001 and DataCenter:getUserChairId() == GetSelfChairID() then
    --     cc.uiloader:seekNodeByName(self.UINode_, "Button_dismiss"):setVisible(true)
    -- else
    --     cc.uiloader:seekNodeByName(self.UINode_, "Button_exit"):setVisible(true)
    -- end
    -- cc.uiloader:seekNodeByName(self.UINode_, "round_score_num"):setString(DataCenter:getCurRoundCardScore())
    -- dump(self.m_imgWaitBao)
    -- if DataCenter:getServerStatus() == 101 then
    --     self.m_imgWaitBao:setVisible(true)
    -- else
    --     self.m_imgWaitBao:setVisible(false)
    -- end
    self:UpdateGameInfo()
    self:UpdateCardTypeInfo()
end

function UIBackground:onRemove()
    -- body
    self:removeSelf()
end

function UIBackground:getRoundScoreNode()
    -- body
    -- return cc.uiloader:seekNodeByName(self.UINode_, "round_score_num")
end

function UIBackground:clickDismissBtn(event)
    -- body
    --如果是建桌模式并且处于休闲状态
    -- if DataCenter:isCreateTable() then
    --     if DataCenter:getServerStatus() == 0 then
    --         InternetManager:sendDismissTable(GetSelfChairID())
    --     else
    --         UIManager:ShowUI("UIDismiss", 1)
    --     end
    -- end
end

function UIBackground:clickExitBtn(event)
    -- body
    MusicCenter:PlayBtnEffect()
    UIManager:ShowUI("UITip"):ShowTip("是否确定退出游戏?", function(bOk)
        if bOk == true then
            if DataCenter:isCreateTable() then
                if DataCenter:getServerStatus() == 0 then
                    InternetManager:SendUserHandExit()
                    self:dispatchEvent({name = UIBackground.CLICK_EXIT_BTN_EVENET})
                else
                    UIManager:ShowUI("UIDismiss", 1)
                end
            else
                print(UIBackground.CLICK_EXIT_BTN_EVENET)
                self:dispatchEvent({name = UIBackground.CLICK_EXIT_BTN_EVENET})
            end 
        end
    end)
end

function UIBackground:clickCardTypeBtn(event)
    print("点击了牌型:" .. event.target:getTag())
end

function UIBackground:SendChatMsg()
        print("SendChatMsg")

        --发送信息
        local Str=FGameDC:getDC():SendChatMessage(0,self.ChatFrame:getSendChat(),0);

        --聊天
        if(Str~="")then
            local_tip_ui.PopupTipUI(Str,1);
        end
end

function UIBackground:clickVoiceBtn(event)
    -- body
    -- local GameChat = import("script.public.GameChat")
    -- self.ChatFrame= GameChat:create(handler(self,self.OnChatFuc) ,handler(self, self.SendChatMsg) ,true)
    -- local scene = cc.Director:getInstance():getRunningScene() -- 添加到场景
    -- self.ChatFrame:addTo(scene)
    MusicCenter:PlayBtnEffect()
    UIManager:UpdateUI("UIMusicChat")
end

function UIBackground:clickSettingBtn(event)
    -- -- body
    MusicCenter:PlayBtnEffect()
    local MusicSet = require("script.public.MusicSet")
    self.m_mMusicSet = MusicSet:create(handler(self,self.closeMusicSet))
    local scene = cc.Director:getInstance():getRunningScene() -- 添加到场景
    self.m_mMusicSet:addTo(scene)
end

function UIBackground:closeMusicSet()
    -- body
    if self.m_mMusicSet then
        self.m_mMusicSet:removeSelf()
        self.m_mMusicSet = nil
    end
end

function UIBackground:OnChatFuc()
    -- body
    if self.ChatFrame then
        self.ChatFrame:removeSelf()
        self.ChatFrame = nil
    end
end

function UIBackground:test()
    -- body
    print("UIBackground:test()")
end

function UIBackground:SuitScreenForBg(Bg_left,Bg_Right,ScaleBg)
    -- 
    Bg_left:getTexture():setAliasTexParameters()
    Bg_Right:getTexture():setAliasTexParameters()
    if display.height==720 then
      --
      local BG
      BG = Bg_left
      BG:getTexture():setAliasTexParameters()

      BG = Bg_Right
      BG:getTexture():setAliasTexParameters()
      return 
    end

    if ScaleBg==nil then
        --todo
        ScaleBg=1.0
    end

    local scale = display.height/720

    print("缩放比例  scale="..scale)
    
    -- local BG = Bg_left
    -- BG:getTexture():setAliasTexParameters()
    -- BG:setScale(scale*ScaleBg) 
    -- BG:setPositionX(640-scale*360)
    

    -- BG = Bg_Right
    -- BG:getTexture():setAliasTexParameters()
    -- BG:setScale(scale*ScaleBg) 
    -- BG:setPositionX(640+scale*360)
end

function UIBackground:UpdateGameInfo()
    --print("------------更新UIBackground------------")
    local cell_score = DataCenter:getCellScore()
    local multiple = DataCenter:getMultiple()
    --print("底分:" .. cell_score)
    --print("倍数:" .. multiple)
    self["num_score"]:setString(cell_score)
    self["num_bei"]:setString(multiple)
end

function UIBackground:UpdateCardTypeInfo()
    print("-------------更新牌型信息----------------")
    local hand_card_data = DataCenter:getSelfHandCardData()
    local hand_card_count = DataCenter:getSelfHandCardCount()

    --dump(hand_card_data)
    local tagAnalyseResult = GameLogic:CreateTagAnalyseResult()
    GameLogic:AnalyseCardData(hand_card_data, hand_card_count, tagAnalyseResult)

    --dump(tagAnalyseResult, nil , 3)
    for i = 1, 6 do
        local parent_name = "node_type_" .. i .. "_"
        local bShow = false
        local struct_class

        --王炸
        if i == 1 then
            struct_class = GameLogic:CreateTagKingCount()
            bShow = GameLogic:SearchKingCount(hand_card_data, hand_card_count, struct_class) >= 2 and true or false
            --dump(struct_class, "王炸")
        --50K
        elseif i == 2 then
            struct_class = GameLogic:CreateTagWSKOutCardResult()
            bShow = GameLogic:SearchWuShiK(hand_card_data, hand_card_count, struct_class) == 1 and true or false
            --dump(struct_class)
        --炸弹
        elseif i == 3 then
            for j = 3, 8 do
                bShow = tagAnalyseResult.cbBlockCount[j - 1] > 0
                
                if bShow then break end
            end
        --连对 
        elseif i == 4 then
            struct_class = GameLogic:CreateTagOutCardResult()
            bShow = GameLogic:SearchLinkCard(hand_card_data, hand_card_count, 0, CT_DOUBLE_LINK, 6, struct_class)
        --顺子
        elseif i == 5 then
            struct_class = GameLogic:CreateTagOutCardResult()
            bShow = GameLogic:SearchLinkCard(hand_card_data, hand_card_count, 0, CT_SINGLE_LINK, 3, struct_class)
            --dump(struct_class)
        --对子
        elseif i == 6 then
            bShow = tagAnalyseResult.cbBlockCount[1] > 0
        end
        self[parent_name .. "Btn_card_type"]:setButtonEnabled(bShow)
        self[parent_name .. "img_card_type_1"]:setVisible(bShow)
        self[parent_name .. "img_card_type_2"]:setVisible(not bShow)
    end
end

function UIBackground:ResetUI()
    --牌型节点
    local cardTypeNodeName = "node_type_"
    --1 有 2 无
    local subNodeNameTab = {"Btn_card_type", "img_card_type_1", "img_card_type_2"}
    for i = 1, 6 do
        local parentNodeName = cardTypeNodeName .. i
        self[parentNodeName .. "_" .. "Btn_card_type"]:setButtonEnabled(false)
        self[parentNodeName .. "_" .. "img_card_type_1"]:setVisible(false)
        self[parentNodeName .. "_" .. "img_card_type_2"]:setVisible(true)
    end
    self:UpdateGameInfo()
end

return UIBackground