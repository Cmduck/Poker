--
-- Author: GFun
-- Date: 2016-10-12 11:45:49
--
local UIBase = require("script.50kScript.ui.UIBase")
local UITopInfo = class("UITopInfo", UIBase)
local CardClass = require("script.50kScript.card.CardClass")
local cardSmallPlist = "ccbResources/50kRes/card_small/card_small.plist"
local cardSmallPng = "ccbResources/50kRes/card_small/card_small.png"

function UITopInfo:ctor()
    UITopInfo.super.ctor(self)
    cc.SpriteFrameCache:getInstance():addSpriteFrames(cardSmallPlist, cardSmallPng)  
end

function UITopInfo:onShow()
	-- body
	local nameTab = {"name", "card_score", "card_node", "hou_card"}
    for i, v in ipairs(nameTab) do
    	self[v] = cc.uiloader:seekNodeByName(self.UINode_, v)
    end
    self:updateName()
    self["hou_card"]:setVisible(false)
    self["card_score"]:setString("0")
end

function UITopInfo:onHide()
    -- body
end

function UITopInfo:onUpdate()
    self:updateScore()
    self:updateName()
    self:updateCallCard()
end

function UITopInfo:onRemove()
    -- body
    display.removeSpriteFramesWithFile(cardSmallPlist, cardSmallPng)
    self:removeSelf()
end

function UITopInfo:updateScore()
    local score = DataCenter:getCurTurnScore()
    self["card_score"]:setString(score)
end

function UITopInfo:updateName()
    local banker_user = DataCenter:getBankerUser()
    local pUserData = FGameDC:getDC():GetUserInfo(banker_user)
    local name = FGameDC:getDC():UnicodeToUtf8(pUserData.szAccount[0])
    self["name"]:setString(name)    
end

function UITopInfo:updateCallCard()
    print("-------------DataCenter:getCallCardData() = " .. DataCenter:getCallCardData())
    if DataCenter:getGameModel() == GAME_MODE_JIAO and DataCenter:getCallCardData() ~= 0 then
        self:createSmallCard(DataCenter:getCallCardData())
        self["hou_card"]:setVisible(false)
    elseif DataCenter:getGameModel() == GAME_MODE_HOU then
        self.card_node:removeAllChildren()
        self["hou_card"]:setVisible(true)
    end
end

function UITopInfo:getSmallCardNode()
    -- body
    return self["card_node"]
end

function UITopInfo:createSmallCard(data)
	-- body
	self.cardClass_ = CardClass.new(data)
	--dump(self.cardClass_)
    local color = self.cardClass_:getColor()
    local actualValue = self.cardClass_:getActualValue()
    --print("UITopInfo:createSmallCard:-> ~~~~~~~~~~~~~~~~~~~ color = " .. color)
    --print("UITopInfo:createSmallCard:-> ~~~~~~~~~~~~~~~~~~~ actualValue = " .. actualValue)
    self.card_node:removeAllChildren()
    local cardBg = display.newSprite("#card_small_bottom.png")
        :align(display.CENTER, 0, 0)
        :addTo(self.card_node)
    if actualValue > 15 then
        local cardNum = display.newSprite("#card_small_" .. color .. actualValue .. ".png")
        :align(display.CENTER, 8, 30)
        :addTo(cardBg)
        local colorImg = display.newSprite("#card_small_joker_" .. actualValue .. ".png")
        :align(display.CENTER, 30, 15)  
        :addTo(cardBg)
    else
        local colorIndex = color % 2
        -- local cardBg = display.newSprite("#bottom.png")
        --     :align(display.CENTER, display.cx, display.cy)
        --     :addTo(self)
        local cardNum = display.newSprite("#card_small_" .. colorIndex .. actualValue .. ".png")
            :align(display.CENTER, 11, 45)
            :addTo(cardBg)

        local colorImg = display.newSprite("#card_small_" .. color .. ".png")
            :align(display.CENTER, 30, 15)
            :addTo(cardBg)
    end
end

return UITopInfo