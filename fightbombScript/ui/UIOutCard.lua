--
-- Author: GFun
-- Date: 2016-10-09 15:53:06
--

local UIBase = require("script.fightbombScript.ui.UIBase")
local UIOutCard = class("UIOutCard", UIBase)
local ActionHelper = require("script.fightbombScript.common.ActionHelper")

UIOutCard.CLICK_BU_CHU_BTN_EVENT = "CLICK_BU_CHU_BTN_EVENT"
UIOutCard.CLICK_TI_SHI_BTN_EVENT = "CLICK_TI_SHI_BTN_EVENT"
UIOutCard.CLICK_CHU_PAI_BTN_EVENT = "CLICK_CHU_PAI_BTN_EVENT"

function UIOutCard:ctor()
    UIOutCard.super.ctor(self)  
end

function UIOutCard:onShow()
    -- body
    local nameTab = {"Btn_NoOut", "Btn_Tip", "Btn_OutCard", "Btn_FirstOut"}
    local directionTab = {"img_pass_down", "img_pass_right", "img_pass_up", "img_pass_left"}
    for i, v in ipairs(nameTab) do
        self[v] = cc.uiloader:seekNodeByName(self.UINode_, v)
        self[v]:setVisible(false)
    end
    for i, v in ipairs(directionTab) do
        self[v] = cc.uiloader:seekNodeByName(self.UINode_, v)
        self[v]:setVisible(false)
    end
    self["Btn_NoOut"]:onButtonClicked(handler(self, self.clickBuChuBtn))
    self["Btn_Tip"]:onButtonClicked(handler(self, self.clickTiShiBtn))
    self["Btn_OutCard"]:onButtonClicked(handler(self, self.clickChuPaiBtn))
    self["Btn_FirstOut"]:onButtonClicked(handler(self, self.clickChuPaiBtn))
end

function UIOutCard:onHide()
    -- body
    self:setVisible(false)
end

--带pass动作
function UIOutCard:ShowPassCard()
    local directionTab = {"down", "right", "up", "left"}
    local passTab = DataCenter:getUserPassCardTab()
    local passUser = DataCenter:getPrevOperationUser()

    local directionName = directionTab[GetDirection(passUser) + 1]
    ActionHelper:OutCardAction(self["img_pass_" .. directionName])
end

function UIOutCard:ShowPass()
    -- body
    local directionTab = {"down", "right", "up", "left"}
    local passTab = DataCenter:getUserPassCardTab()
    local passUser = DataCenter:getPrevOperationUser()
    dump(passTab)
    for i = 0, GAME_PLAYER - 1 do
        --获取当前椅子号的方位 对应的方向英文
        local directionName = directionTab[GetDirection(i) + 1]
        self["img_pass_" .. directionName]:setVisible(passTab[i + 1] == 1)
    end
end

function UIOutCard:ShowOut()
    local nameTab = {"Btn_NoOut", "Btn_Tip", "Btn_OutCard"}

    for i, v in ipairs(nameTab) do
        self[v] = cc.uiloader:seekNodeByName(self.UINode_, v)
        self[v]:setVisible(not DataCenter:getIsFirstOutCard() and 
            DataCenter:getCurrentUser() == DataCenter:getSelfChairID() and 
            DataCenter:getServerStatus() == GS_UG_PLAYING)
    end
    self["Btn_FirstOut"]:setVisible(DataCenter:getIsFirstOutCard() and 
            DataCenter:getCurrentUser() == DataCenter:getSelfChairID() and 
            DataCenter:getServerStatus() == GS_UG_PLAYING)
end

function UIOutCard:onUpdate()
    self:setVisible(true)
    self:ShowPass()
    self:ShowOut()
end

function UIOutCard:onRemove()
    -- body
    self:removeSelf()
end

function UIOutCard:clickBuChuBtn(event)
    -- body
    self:dispatchEvent({name = UIOutCard.CLICK_BU_CHU_BTN_EVENT})
end

function UIOutCard:clickChuPaiBtn(event)
    -- body
    self:dispatchEvent({name = UIOutCard.CLICK_CHU_PAI_BTN_EVENT})
end

function UIOutCard:clickTiShiBtn(event)
    -- body
    self:dispatchEvent({name = UIOutCard.CLICK_TI_SHI_BTN_EVENT})
end

return UIOutCard