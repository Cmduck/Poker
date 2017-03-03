--
-- Author: GFun
-- Date: 2017-01-10 10:33:41
--


local UIBase = require("script.50kScript.ui.UIBase")
local UITrusteeship = class("UITrusteeship", UIBase)

local BG_IMG = "ccbResources/50kRes/trusteeship/trusteeship_back.png"
local BTN_IMG_1 = "ccbResources/50kRes/trusteeship/cancel_trusteeship.png"
local BTN_IMG_2 = "ccbResources/50kRes/trusteeship/cancel_trusteeship_n.png"

--事件
UITrusteeship.CLICK_CANCEL_BTN_EVENT = "CLICK_CANCEL_BTN_EVENT"

function UITrusteeship:ctor()
	self.maskLayer_ = display.newColorLayer(ccc4(0, 0, 0, 0))--ccc4
	self.maskLayer_:addTo(self)
    UITrusteeship.super.ctor(self)
end

function UITrusteeship:onShow()
	-- body
    print("==========>>>>>> UITrusteeship:onShow() <<<<<<===========    ")
    self:setLocalZOrder(101)
    self["Btn_CancelTrustee"] = cc.uiloader:seekNodeByName(self.UINode_, "Btn_CancelTrustee")
    self["Btn_CancelTrustee"]:onButtonClicked(handler(self, self.onClickCancelBtn))
    self:setVisible(false)
end

function UITrusteeship:onHide()
    -- body
    self:setVisible(false)
end

function UITrusteeship:onUpdate()
    print("==========>>>>>> UITrusteeship:onUpdate() <<<<<<===========    ")
    dump(DataCenter:getMyTrusteeshipStatus())
    self:setVisible(DataCenter:getMyTrusteeshipStatus())
end

function UITrusteeship:onRemove()
    -- body
    self:removeSelf()
end

function UITrusteeship:onClickCancelBtn(event)
    print("点击取消托管Btn！")
    InternetManager:SetTrusteeship(false)
	--self:dispatchEvent({name = UITrusteeship.CLICK_CANCEL_BTN_EVENT})
end

return UITrusteeship