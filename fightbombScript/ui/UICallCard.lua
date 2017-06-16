--
-- Author: GFun
-- Date: 2017-05-08 10:01:18
--
--
-- Author: GFun
-- Date: 2017-05-05 09:47:18
--
local UIBase = require("script.fightbombScript.ui.UIBase")
local UICallCard = class("UICallCard", UIBase)

UICallCard.CLICK_CALL_CARD_BTN_EVENT = "CLICK_CALL_CARD_BTN_EVENT"


function UICallCard:ctor()
    UICallCard.super.ctor(self)  
end

function UICallCard:onShow()
	-- body
	self["Btn_call"] = cc.uiloader:seekNodeByName(self.UINode_, "Btn_call")
	self["Btn_call"]:onButtonClicked(handler(self, self.clickCallBtn))
	self["Btn_call"]:setVisible(false)
end

function UICallCard:onHide()
    -- body
    self:setVisible(false)
end

function UICallCard:onUpdate()
	local server_status = DataCenter:getServerStatus()
	local my_chairID = DataCenter:getSelfChairID()
	local banker_user = DataCenter:getBankerUser()
	self["Btn_call"]:setVisible(server_status == GS_UG_CALL and my_chairID == banker_user)
end

function UICallCard:onRemove()
    -- body
    self:removeSelf()
end

function UICallCard:clickCallBtn(event)
	-- body
	-- self["Btn_call"]:setVisible(false)
	self:dispatchEvent({name = UICallCard.CLICK_CALL_CARD_BTN_EVENT})
end

return UICallCard