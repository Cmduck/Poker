--
-- Author: GFun
-- Date: 2017-05-05 09:47:18
--
local UIBase = require("script.fightbombScript.ui.UIBase")
local UIBaoCard = class("UIBaoCard", UIBase)

UIBaoCard.CLICK_BAO_CARD_BTN_EVENT = "CLICK_BAO_CARD_BTN_EVENT"
UIBaoCard.CLICK_BU_BAO_CARD_BTN_EVENT = "CLICK_BU_BAO_CARD_BTN_EVENT"


function UIBaoCard:ctor()
    UIBaoCard.super.ctor(self)  
end

function UIBaoCard:onShow()
	-- body
	local nameTab = {"down", "right", "up", "left"}
    for i, v in ipairs(nameTab) do
    	local bao_node = "img_bao_" .. v
    	local bubao_node = "img_bubao_" .. v
    	self[bao_node] = cc.uiloader:seekNodeByName(self.UINode_, bao_node)
    	self[bao_node]:setVisible(false)
    	self[bubao_node] = cc.uiloader:seekNodeByName(self.UINode_, bubao_node)
    	self[bubao_node]:setVisible(false)
    end
	self["Btn_Bao"] = cc.uiloader:seekNodeByName(self.UINode_, "Btn_Bao")
	self["Btn_Bao"]:onButtonClicked(handler(self, self.clickBaoBtn))
	self["Btn_Bao"]:setVisible(false)
	self["Btn_BuBao"] = cc.uiloader:seekNodeByName(self.UINode_, "Btn_BuBao")
	self["Btn_BuBao"]:onButtonClicked(handler(self, self.clickBuBaoBtn))
	self["Btn_BuBao"]:setVisible(false)
end

function UIBaoCard:onHide()
    -- body
	local nameTab = {"down", "right", "up", "left"}
    for i, v in ipairs(nameTab) do
    	local bao_node = "img_bao_" .. v
    	local bubao_node = "img_bubao_" .. v
    	self[bao_node]:setVisible(false)
    	self[bubao_node]:setVisible(false)
    end
end

function UIBaoCard:onUpdate()
	local baoCardInfo = DataCenter:getUserBaoCardInfo()
	local current_user = DataCenter:getCurrentUser()
	local my_chairID = DataCenter:getSelfChairID()

    local directionTab = {"down", "right", "up", "left"}
	self["Btn_BuBao"]:setVisible(my_chairID == current_user and DataCenter:getServerStatus() == GS_UG_BAO)
	self["Btn_Bao"]:setVisible(my_chairID == current_user and DataCenter:getServerStatus() == GS_UG_BAO)

	for i = 0, GAME_PLAYER - 1 do
		local direction = directionTab[GetDirection(i) + 1]
		local nodeBaoImgName = "img_bao_"  .. direction
	    local nodeBuBaoImgName = "img_bubao_" .. direction
	    self[nodeBaoImgName]:setVisible(baoCardInfo[i + 1] == 1)
	    self[nodeBuBaoImgName]:setVisible(baoCardInfo[i + 1] == 2)
	end
end

function UIBaoCard:onRemove()
    -- body
    self:removeSelf()
end

function UIBaoCard:clickBaoBtn(event)
	-- body
	self["img_bao_down"]:setVisible(true)
	self["Btn_Bao"]:setVisible(false)
	self["Btn_BuBao"]:setVisible(false)
	self:dispatchEvent({name = UIBaoCard.CLICK_BAO_CARD_BTN_EVENT})
end

function UIBaoCard:clickBuBaoBtn(event)
	-- body
	self["img_bubao_down"]:setVisible(true)
	self["Btn_Bao"]:setVisible(false)
	self["Btn_BuBao"]:setVisible(false)
	self:dispatchEvent({name = UIBaoCard.CLICK_BU_BAO_CARD_BTN_EVENT})
end

return UIBaoCard