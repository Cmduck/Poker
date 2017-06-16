--
-- Author: GFun
-- Date: 2016-10-12 11:45:49
--
local UIBase = require("script.fightbombScript.ui.UIBase")
local UITopInfo = class("UITopInfo", UIBase)
local CardClass = require("script.fightbombScript.card.CardClass")

local cardSmallPlist = "ccbResources/fightbombRes/card_small/card_small.plist"
local cardSmallPng = "ccbResources/fightbombRes/card_small/card_small.png"

function UITopInfo:ctor()
    UITopInfo.super.ctor(self)
    display.addSpriteFrames(cardSmallPlist, cardSmallPng)  
end

function UITopInfo:onShow()
	-- body
	local nameTab = {"room_num", "cur_inning_num", "max_inning_num", "play_des", "img_jiaopai", "img_baopai", "small_card_node"}
    for i, v in ipairs(nameTab) do
    	self[v] = cc.uiloader:seekNodeByName(self.UINode_, v)
    end

    self["room_num"]:setString("0")
    self["cur_inning_num"]:setString("0")
    self["max_inning_num"]:setString("0")
    self["play_des"]:setString("")
    self["img_jiaopai"]:setVisible(false)
    self["img_baopai"]:setVisible(false)
end

function UITopInfo:onHide()
    -- body
    self:setVisible(false)
end

function UITopInfo:onUpdate()
    self:setVisible(true)
    local room_num = DataCenter:getRandID()
    local cur_inning_num = DataCenter:getCurInningNum()
    local max_inning_num = DataCenter:getMaxInningNum()
    local b1V3 = DataCenter:getIs1V3()
    local game_model = DataCenter:getGameModel()
    local server_type = DataCenter:getServerStatus()
    local bThreePlusTwo = DataCenter:getIsThreePlusTwo()

    print("game_model = ", game_model)
    print("server_type = ", server_type)
    self["room_num"]:setString(room_num)
    self["cur_inning_num"]:setString(cur_inning_num)
    self["max_inning_num"]:setString(max_inning_num)
    local str = "玩法:"

    if b1V3 then
        str = str .. " 1V3 "
    end

    if bThreePlusTwo then
        str = str .. " 三带二 "
    end

    self["play_des"]:setString(str)

    if game_model == GAME_MODEL_BAO then
        self["img_baopai"]:setVisible(server_type == GS_UG_PLAYING)
    else
        self["img_jiaopai"]:setVisible(server_type == GS_UG_PLAYING)
    end

    --显示叫牌
    self["small_card_node"]:removeAllChildren()
    local call_card_data = DataCenter:getCallCardData()
    if DataCenter:getServerStatus() == GS_UG_PLAYING and call_card_data ~= 0 then
        local call_card_view = self:createSmallCard(call_card_data)
        call_card_view:align(display.CENTER, 0, 0):addTo(self["small_card_node"])
    end
end

function UITopInfo:onRemove()
    -- body
    display.removeSpriteFramesWithFile(cardSmallPlist, cardSmallPng)
    self:removeSelf()
end

function UITopInfo:getSmallCardNode()
    -- body
    return self["small_card_node"]
end

function UITopInfo:createSmallCard(data)
    -- body
    print("创建小牌!")
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

return UITopInfo