--
-- Author: GFun
-- Date: 2016-10-31 09:57:40
--

local UIBase = require("script.fightbombScript.ui.UIBase")
local UIMsgBox = class("UIMsgBox", UIBase)

UIMsgBox.CLICK_YES_BTN_EVENT = "CLICK_YES_BTN_EVENT"
UIMsgBox.CLICK_NO_BTN_EVENT  = "CLICK_NO_BTN_EVENT"

function UIMsgBox:ctor()
    self.maskLayer_ = display.newColorLayer(ccc4(0, 0, 0, 200))--ccc4
    self.maskLayer_:addTo(self)
    UIMsgBox.super.ctor(self)
end

function UIMsgBox:onShow(tipTxt)
	-- body
    self:setLocalZOrder(102)
    self["tip_txt"] = cc.uiloader:seekNodeByName(self.UINode_, "tip_txt")
    self["Btn_yes"] = cc.uiloader:seekNodeByName(self.UINode_, "Btn_yes")
    self["Btn_no"] = cc.uiloader:seekNodeByName(self.UINode_, "Btn_no")
    if tipTxt then
        self["tip_txt"]:setString(tipTxt)
    end
    self["Btn_yes"]:onButtonClicked(handler(self, self.clickYesBtn))
    self["Btn_no"]:onButtonClicked(handler(self, self.clickNoBtn))
end

function UIMsgBox:onHide()
    -- body
end

function UIMsgBox:onUpdate()

end

function UIMsgBox:onRemove()
    -- body
    self:removeSelf()
end

function UIMsgBox:clickYesBtn(event)
    self:dispatchEvent({name = UIMsgBox.CLICK_YES_BTN_EVENT})
end

function UIMsgBox:clickNoBtn(event)
    self:dispatchEvent({name = UIMsgBox.CLICK_NO_BTN_EVENT})
end

return UIMsgBox