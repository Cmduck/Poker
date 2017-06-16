module(..., package.seeall) 

--------------------------------------------------------------------------
-- UI -- 背景UI
--------------------------------------------------------------------------
local scheduler    = require(cc.PACKAGE_NAME .. ".scheduler")
local GafHelper = require("script.fightbombScript.common.GafHelper")
local EventProxyEx = require("script.fightbombScript.common.EventProxyEx")
local CardClass    = require("script.fightbombScript.card.CardClass")
local UIBase       = require("script.fightbombScript.ui.UIBase")
local UIBackground = class("UIBackground", UIBase)

UIBackground.CLICK_EXIT_BTN_EVENET = "CLICK_EXIT_BTN_EVENET"
UIBackground.CLICK_50K_BTN_EVENT = "CLICK_50K_BTN_EVENT"
UIBackground.CLICK_SORT_BTN_EVENT = "CLICK_SORT_BTN_EVENT"


function UIBackground:ctor()
    UIBackground.super.ctor(self)
        -- self.maskLayer_ = display.newColorLayer(ccc4(0, 0, 0, 0))--ccc4
        -- self.maskLayer_:addTo(self)
        -- self.maskLayer_:setContentSize(display.width, display.height)
        -- self.maskLayer_:setTouchEnabled(true)
        -- self.maskLayer_:setTouchSwallowEnabled(false)
    --注册触摸事件
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(false)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch_))
    self.m_pBottomCardViewList_ = {}
    self.m_bShowMenu_ = false
end

function UIBackground:update(dt)
    -- body
    local time = os.date("%H:%M")
    self["time_num"]:setString(time)
end

function UIBackground:onShow()
    -- body
    print(self.__cname .. ":onShow()")
    self:InitView()
    self:RegisterButtonEvent()
    self:LoadUIComponent()
    self:LoadInviteBtn()
end

function UIBackground:InitView()
    -- body
    -- 背景分辨率适配
    cc.uiloader:seekNodeByName(self.UINode_, "bg_left"):setPositionY(display.cy)
    cc.uiloader:seekNodeByName(self.UINode_, "bg_right"):setPositionY(display.cy)
    cc.uiloader:seekNodeByName(self.UINode_, "bg_left"):setScaleY(display.height / 720)
    cc.uiloader:seekNodeByName(self.UINode_, "bg_right"):setScaleY(display.height / 720)
    display.newSprite("ccbResources/fightbombRes/background/logo.png"):align(display.CENTER, display.cx, display.cy + 70):addTo(self)
    self:SuitScreenForBg(cc.uiloader:seekNodeByName(self.UINode_, "bg_left"), cc.uiloader:seekNodeByName(self.UINode_, "bg_right"))

    self["Btn_LookScore"]   = cc.uiloader:seekNodeByName(self.UINode_, "Btn_LookScore")
    self["Btn_50K"]         = cc.uiloader:seekNodeByName(self.UINode_, "Btn_50K")
    self["Btn_Sort"]        = cc.uiloader:seekNodeByName(self.UINode_, "Btn_Sort")
    self["Btn_Voice"]       = cc.uiloader:seekNodeByName(self.UINode_, "Btn_Voice")
    self["Btn_Menu"]        = cc.uiloader:seekNodeByName(self.UINode_, "Btn_Menu")
    self["friend_score"]    = cc.uiloader:seekNodeByName(self.UINode_, "friend_score")
    self["enemy_score"]     = cc.uiloader:seekNodeByName(self.UINode_, "enemy_score")
    self["time_num"]        = cc.uiloader:seekNodeByName(self.UINode_, "time_num")
    self["SET_ITEM"]        = cc.uiloader:seekNodeByName(self.UINode_, "setting_bg")
    self["Btn_Exit"]        = cc.uiloader:seekNodeByName(self["SET_ITEM"], "Btn_Exit")
    self["Btn_Dismiss"]     = cc.uiloader:seekNodeByName(self["SET_ITEM"], "Btn_Dismiss")
    self["Btn_Setting"]     = cc.uiloader:seekNodeByName(self["SET_ITEM"], "Btn_Setting")
    self["Btn_putonghua"]   = cc.uiloader:seekNodeByName(self["SET_ITEM"], "Btn_putonghua")
    self["Btn_fangyan"]     = cc.uiloader:seekNodeByName(self["SET_ITEM"], "Btn_fangyan")

    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt)
        self:update(dt)
    end)

    self:scheduleUpdate()

    self:ShowCallCardTip()
    self["SET_ITEM"]:setVisible(false)
    self["Btn_putonghua"]:setVisible(false)
    self:ShowFactionScore(false)
end

function UIBackground:RegisterButtonEvent()
    -- body
    self["Btn_Menu"]:onButtonClicked(handler(self, self.clickMenuBtn))

    self["Btn_LookScore"]:onButtonClicked(handler(self, self.clickLookScoreBtn))
    self["Btn_50K"]:onButtonClicked(handler(self, self.click50KBtn))
    self["Btn_Sort"]:onButtonClicked(handler(self, self.clickSortBtn))
    self["Btn_Voice"]:onButtonClicked(handler(self, self.clickVoiceBtn))

    self["Btn_Exit"]:onButtonClicked(handler(self, self.clickExitBtn))
    self["Btn_Dismiss"]:onButtonClicked(handler(self, self.clickDismissBtn))
    self["Btn_Setting"]:onButtonClicked(handler(self, self.clickSettingBtn))
    self["Btn_putonghua"]:onButtonClicked(handler(self, self.clickPuTongHuaBtn))
    self["Btn_fangyan"]:onButtonClicked(handler(self, self.clickFangYanBtn))
end

function UIBackground:LoadUIComponent()
    -- body
    UIManager:ShowUI("UIMusicChat"):setLocalZOrder(100)
    UIManager:ShowUI("UIChatBubble"):setLocalZOrder(100)
end

function UIBackground:onHide()
    -- body
end

function UIBackground:onUpdate()
    -- body
    local serverType   = DataCenter:getServerType()
    local tableUser    = DataCenter:getTableUser()
    local selfChairId  = DataCenter:getSelfChairID()
    local serverStatus = DataCenter:getServerStatus()

    print("tableUser = " .. tableUser)
    print("selfChairId = " .. selfChairId)
    print("serverStatus = ", serverStatus)

    if serverType == GAME_GENRE_SCORE then
        self["Btn_Invite"]:setVisible(serverStatus == GS_UG_FREE)
    elseif serverType == GAME_GENRE_GOLD then
        self["Btn_Invite"]:setVisible(false)
    end

    self:ShowFactionScore(DataCenter:getGameModel() == GAME_MODEL_CALL and DataCenter:getIsOutCallCard())
    --self["call_tips"]:setVisible(DataCenter:getServerStatus() == GS_UG_CALL)
end

function UIBackground:onRemove()
    -- body
    self:removeSelf()
end

--显示叫牌提示
function UIBackground:ShowCallCardTip()
    self["call_tips"] = display.newSprite("ccbResources/fightbombRes/background/qingxuanzhejiaopai.png")
    self["call_tips"]:align(display.CENTER, display.cx, display.cy):addTo(self)
    self["call_tips"]:setVisible(false)
end

--显示阵营得分
function UIBackground:ShowFactionScore(bShow)
    -- body
    local my_chairId = DataCenter:getSelfChairID()
    local factionTab = DataCenter:getFaction()
    local enemyScoreNum = 0
    local friendScoreNum = 0
    local my_faction = factionTab[my_chairId + 1]
    local catch_score_tab = DataCenter:getCatchScore()

    for i = 0, GAME_PLAYER - 1 do
        local iFaction = factionTab[i + 1]
        if iFaction == my_faction then
            friendScoreNum = friendScoreNum + catch_score_tab[i + 1]
        else
            enemyScoreNum = enemyScoreNum + catch_score_tab[i + 1]
        end
    end
    self["enemy_score"]:setString(enemyScoreNum)
    self["friend_score"]:setString(friendScoreNum)
    
    self["enemy_score"]:setVisible(bShow)
    self["friend_score"]:setVisible(bShow)
end

function UIBackground:clickMenuBtn(event)
    self["SET_ITEM"]:setVisible(not self["SET_ITEM"]:isVisible())

    local serverType   = DataCenter:getServerType() 
    local tableUser    = DataCenter:getTableUser()
    local selfChairId  = DataCenter:getSelfChairID()
    if serverType == GAME_GENRE_SCORE then
        if tableUser == selfChairId then
            self["Btn_Exit"]:setVisible(false)
        else
            self["Btn_Dismiss"]:setVisible(false)
        end
    end
end

function UIBackground:onTouch_(event)
    -- body
    local pt = cc.p(event.x, event.y)
    if not self["SET_ITEM"]:hitTest(pt) and self["SET_ITEM"]:isVisible() then
        self["SET_ITEM"]:setVisible(false)   
    end
end

function UIBackground:clickInviteBtn(event)
    local strDescribe = DataCenter:getMaxInningNum() .. "局,"

    if DataCenter:getIs1V3() then
        strDescribe = strDescribe .. "1V3,"
    else
        strDescribe = strDescribe .. "2V2,"
    end

    if DataCenter:getIsThreePlusTwo() then
        strDescribe = strDescribe .. "三代二,"
    end

    strDescribe = strDescribe .. "速度来玩啊"
 
    print(strDescribe)
    local share_wx = require("script.public.share_wx")
    share_wx.PopupTipWXUI(false, strDescribe, GameScene , "打炸弹,房号【" .. DataCenter:getRandID() .. "】")    
end

function UIBackground:clickLookScoreBtn(event)
    -- body
    if DataCenter:getServerStatus() ~= GS_UG_PLAYING then
        return 
    end
    UIManager:ShowUI("UIScoreCard")
end

function UIBackground:click50KBtn(event)
    -- body
    self:dispatchEvent({name = UIBackground.CLICK_50K_BTN_EVENT})
end

function UIBackground:clickSortBtn(event)
    -- body
    self:dispatchEvent({name = UIBackground.CLICK_SORT_BTN_EVENT})
end

function UIBackground:clickDismissBtn(event)
    -- body
    local serverType = DataCenter:getServerType()

    print("serverType = " .. serverType)
    if serverType == GAME_GENRE_SCORE then
        if DataCenter:getServerStatus() == GS_UG_FREE then
            --房主解散
            InternetManager:sendDismissTable()
            --self:dispatchEvent({name = UIBackground.CLICK_EXIT_BTN_EVENET})
        elseif DataCenter:getServerStatus() == GS_UG_BAO then
            UIManager:ShowUI("UIDismiss")
        elseif DataCenter:getServerStatus() == GS_UG_CALL then
            UIManager:ShowUI("UIDismiss")
        elseif DataCenter:getServerStatus() == GS_UG_PLAYING then
            --游戏中退出
            UIManager:ShowUI("UIDismiss")
        elseif DataCenter:getServerStatus() == GS_UG_CONTINUE then
            local UIDismiss = UIManager:ShowUI("UIDismiss")
            UIDismiss:setVisible(true)
        else
            assert(false, "There is no the Scene Status!")
        end
    end
end

function UIBackground:clickExitBtn(event)
    -- body
    MusicCenter:PlayBtnEffect()
    local serverType = DataCenter:getServerType()

    if serverType == GAME_GENRE_SCORE then
        if DataCenter:getServerStatus() == GS_UG_FREE then
            --玩家手动退出
            InternetManager:SendUserHandExit()
            self:dispatchEvent({name = UIBackground.CLICK_EXIT_BTN_EVENET})
        elseif DataCenter:getServerStatus() == GS_UG_BAO then
            UIManager:ShowUI("UIDismiss")
        elseif DataCenter:getServerStatus() == GS_UG_CALL then  
            UIManager:ShowUI("UIDismiss")
        elseif DataCenter:getServerStatus() == GS_UG_PLAYING then
            --游戏中退出
            UIManager:ShowUI("UIDismiss")
        elseif DataCenter:getServerStatus() == GS_UG_CONTINUE then
            local UIDismiss = UIManager:ShowUI("UIDismiss")
            UIDismiss:setVisible(true)
        else
            assert(false, "There is no the Scene Status!")
        end
    elseif serverType == GAME_GENRE_GOLD then
        if StateManager:GetCurStateID() == GAME_STATE_WAIT then
            self:dispatchEvent({name = UIBackground.CLICK_EXIT_BTN_EVENET})
        else
            self:ShowMsgBox()
        end
    end
end

function UIBackground:clickTrusteeBtn(event)
    if StateManager:GetCurStateID() == GAME_STATE_PLAYING then
        InternetManager:SetTrusteeship(true)
    end
end

function UIBackground:ShowMsgBox()
    UIManager:ShowUI("UIMsgBox")
    EventProxyEx.new(UIManager:GetUI("UIMsgBox"), self)
        :addEventListener(UIManager:GetUI("UIMsgBox").class.CLICK_YES_BTN_EVENT, handler(self, self.onClickYes))
        :addEventListener(UIManager:GetUI("UIMsgBox").class.CLICK_NO_BTN_EVENT, handler(self, self.onClickNo))
end

function UIBackground:onClickYes(event)
    self:dispatchEvent({name = UIBackground.CLICK_EXIT_BTN_EVENET})
end

function UIBackground:onClickNo(event)
    UIManager:RemoveUI("UIMsgBox")
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
    MusicCenter:PlayBtnEffect()
    UIManager:UpdateUI("UIMusicChat")
end

function UIBackground:clickSettingBtn(event)
    -- -- body
    MusicCenter:PlayBtnEffect()
    local MusicSet = require("script.public.MusicSet")
    self.m_mMusicSet = MusicSet:create(handler(self,self.closeMusicSet))
    self.m_mMusicSet:addTo(GameScene)
end

function UIBackground:clickPuTongHuaBtn(event)
    -- body
    MusicCenter:PlayBtnEffect()
    self["Btn_fangyan"]:setVisible(true)
    self["Btn_putonghua"]:setVisible(false)
    MusicCenter:SetLanguage(1)
end

function UIBackground:clickFangYanBtn(event)
    -- body
    MusicCenter:PlayBtnEffect()
    self["Btn_putonghua"]:setVisible(true)
    self["Btn_fangyan"]:setVisible(false)
    MusicCenter:SetLanguage(2)
end

function UIBackground:clickLanguage1Btn(event)
    MusicCenter:PlayBtnEffect()
end

function UIBackground:clickLanguage2Btn(event)
    MusicCenter:PlayBtnEffect()
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
      -- local BG
      -- BG = Bg_left
      -- BG:getTexture():setAliasTexParameters()

      -- BG = Bg_Right
      -- BG:getTexture():setAliasTexParameters()
      return 
    end
end

function UIBackground:LoadInviteBtn()
    --建桌没有托管
    print("===================>>>>>>    Load Invite Btn")
    self["Btn_Invite"] = cc.ui.UIPushButton.new({normal = "ccbResources/fightbombRes/background/anniu_invite_friend.png", 
        pressed = "ccbResources/fightbombRes/background/anniu_invite_friend_dk.png"})
    self["Btn_Invite"]:onButtonClicked(
        function(event)
            self:clickInviteBtn(event)
        end
    )
    self["Btn_Invite"]:addTo(self):align(display.CENTER, display.cx, display.cy - 230)
    self["Btn_Invite"]:setVisible(false)
end

function UIBackground:HideInviteBtn()
    self["Btn_Invite"]:setVisible(false)
end

function UIBackground:createSmallCard(data)
    -- body
    self.cardClass_ = CardClass.new(data)

    local color = self.cardClass_:getCardColor()
    local faceValue = self.cardClass_:getCardValue()

    local Card = display.newSprite("#card_small_bottom.png")
        :align(display.CENTER, 0, 0)

    if faceValue > 13 then
        local cardNum = display.newSprite("#card_small_" .. color .. faceValue .. ".png")
        :align(display.CENTER, 8, 30)
        :addTo(Card)
        local colorImg = display.newSprite("#card_small_joker_" .. faceValue .. ".png")
        :align(display.CENTER, 30, 15)  
        :addTo(Card)
    else
        local colorIndex = color % 2
        local cardNum = display.newSprite("#card_small_" .. colorIndex .. faceValue .. ".png")
            :align(display.CENTER, 11, 45)
            :addTo(Card)

        local colorImg = display.newSprite("#card_small_" .. color .. ".png")
            :align(display.CENTER, 11, 15)
            :addTo(Card)
    end

    return Card
end

return UIBackground