--
-- Author: GFun
-- Date: 2016-10-08 19:22:06
--
local UIBase = require("script.50kScript.ui.UIBase")
local UIHou = class("UIHou", UIBase)

UIHou.CLICK_BAO_CARD_BTN_EVENT = "CLICK_BAO_CARD_BTN_EVENT"
UIHou.CLICK_BU_BAO_CARD_BTN_EVENT = "CLICK_BU_BAO_CARD_BTN_EVENT"

UIHou.CLICK_CALL_CARD_BTN_EVENT = "CLICK_CALL_CARD_BTN_EVENT"
UIHou.CLICK_MAIN_HOU_BTN_EVENT = "CLICK_MAIN_HOU_BTN_EVENT"
UIHou.CLICK_OTHER_HOU_BTN_EVENT = "CLICK_OTHER_HOU_BTN_EVENT"
UIHou.CLICK_OTHER_BU_HOU_BTN_EVENT = "CLICK_OTHER_BU_HOU_BTN_EVENT"

function UIHou:ctor()
    UIHou.super.ctor(self) 
end

function UIHou:onShow()
	-- body
	local nameTab = {"down", "right", "up", "left"}
    for i, v in ipairs(nameTab) do
    	local hou_node = "img_hou_" .. v
    	local buhou_node = "img_bu_hou_" .. v
    	self[hou_node] = cc.uiloader:seekNodeByName(self.UINode_, hou_node)
    	self[hou_node]:setVisible(false)
    	self[buhou_node] = cc.uiloader:seekNodeByName(self.UINode_, buhou_node)
    	self[buhou_node]:setVisible(false)
    end
	self["Btn_call"] = cc.uiloader:seekNodeByName(self.UINode_, "Btn_call")
	self["Btn_main_hou"] = cc.uiloader:seekNodeByName(self.UINode_, "Btn_main_hou")
	self["Btn_other_hou"] = cc.uiloader:seekNodeByName(self.UINode_, "Btn_other_hou")
	self["Btn_other_bu_hou"] = cc.uiloader:seekNodeByName(self.UINode_, "Btn_other_bu_hou")

	self["Btn_call"]:onButtonClicked(handler(self, self.clickCallBtn))
	self["Btn_main_hou"]:onButtonClicked(handler(self, self.clickMainHouBtn))
	self["Btn_other_hou"]:onButtonClicked(handler(self, self.clickOtherHouBtn))
	self["Btn_other_bu_hou"]:onButtonClicked(handler(self, self.clickOtherBuHouBtn))

	self["Btn_call"]:setVisible(DataCenter:getBankerUser() == DataCenter:getSelfChairID() and DataCenter:getServerStatus() == GS_UG_HOU)
	self["Btn_main_hou"]:setVisible(DataCenter:getBankerUser() == DataCenter:getSelfChairID() and DataCenter:getServerStatus() == GS_UG_HOU)
	self["Btn_other_hou"]:setVisible(false)
	self["Btn_other_bu_hou"]:setVisible(false)
end

function UIHou:onHide()
    -- body
	local nameTab = {"down", "right", "up", "left"}
    for i, v in ipairs(nameTab) do
    	local hou_node = "img_hou_" .. v
    	local buhou_node = "img_bu_hou_" .. v
    	self[hou_node]:setVisible(false)
    	self[buhou_node]:setVisible(false)
    end
end

function UIHou:onUpdate()

	local houCardInfo = DataCenter:getUserHouStateTab()
	local current_user = DataCenter:getCurrentUser()

    local directionTab = {"down", "right", "up", "left"}
    self["Btn_call"]:setVisible(DataCenter:getSelfChairID() == current_user and 
		DataCenter:getSelfChairID() == DataCenter:getBankerUser() and 
		DataCenter:getServerStatus() == GS_UG_HOU)

    self["Btn_main_hou"]:setVisible(DataCenter:getSelfChairID() == current_user and 
		DataCenter:getSelfChairID() == DataCenter:getBankerUser() and 
		DataCenter:getServerStatus() == GS_UG_HOU)

	self["Btn_other_hou"]:setVisible(DataCenter:getSelfChairID() == current_user and 
		DataCenter:getSelfChairID() ~= DataCenter:getBankerUser() and 
		DataCenter:getServerStatus() == GS_UG_HOU)
	self["Btn_other_bu_hou"]:setVisible(DataCenter:getSelfChairID() == current_user and 
		DataCenter:getSelfChairID() ~= DataCenter:getBankerUser() and 
		DataCenter:getServerStatus() == GS_UG_HOU)

	for i = 0, 3 do
		local direction = directionTab[GetDirection(i) + 1]
		local nodeHouImgName = "img_hou_"  .. direction
	    local nodeBuHouImgName = "img_bu_hou_" .. direction

	    self[nodeHouImgName]:setVisible(houCardInfo[i + 1] == 1)
	    self[nodeBuHouImgName]:setVisible(houCardInfo[i + 1] == 2)
	end

end

function UIHou:onRemove()
    -- body
    print("-------------UIHou:onRemove()--------------")
    self:removeSelf()
end

function UIHou:clickCallBtn(event)
	self:dispatchEvent({name = UIHou.CLICK_CALL_CARD_BTN_EVENT})
end

function UIHou:clickMainHouBtn(event)
	print("点击了main吼")
	self["img_hou_down"]:setVisible(true)
	self["Btn_call"]:setVisible(false)
	self["Btn_main_hou"]:setVisible(false)
	self:dispatchEvent({name = UIHou.CLICK_MAIN_HOU_BTN_EVENT})
end

function UIHou:clickOtherHouBtn(event)
	print("点击了other吼")
	self["img_hou_down"]:setVisible(true)
	self["Btn_other_hou"]:setVisible(false)
	self["Btn_other_bu_hou"]:setVisible(false)
	self:dispatchEvent({name = UIHou.CLICK_OTHER_HOU_BTN_EVENT})
end

function UIHou:clickOtherBuHouBtn(event)
	print("点击了不吼")
	self["img_bu_hou_down"]:setVisible(true)
	self["Btn_other_hou"]:setVisible(false)
	self["Btn_other_bu_hou"]:setVisible(false)
	self:dispatchEvent({name = UIHou.CLICK_OTHER_BU_HOU_BTN_EVENT})
end

return UIHou