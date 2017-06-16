--
-- Author: GFun
-- Date: 2017-04-07 17:17:55
--
local UIBase = require("script.fightbombScript.ui.UIBase")
local UIMenu = class("UIMenu", UIBase)
local ActionHelper = require("script.fightbombScript.common.ActionHelper")

UIMenu.CLICK_SETTING_EVENT   = "CLICK_SETTING_EVENT"
UIMenu.CLICK_LANGUAGE1_EVENT = "CLICK_LANGUAGE1_EVENT"
UIMenu.CLICK_LANGUAGE2_EVENT = "CLICK_LANGUAGE2_EVENT"
UIMenu.CLICK_DISMISS_EVENT   = "CLICK_DISMISS_EVENT"
UIMenu.CLICK_EXIT_EVENT      = "CLICK_EXIT_EVENT"
UIMenu.CLICK_TRUSTEE_EVENT   = "CLICK_TRUSTEE_EVENT"

function UIMenu:ctor()
    UIMenu.super.ctor(self)
end

function UIMenu:onShow()
	-- body
	local nameTab = {"up_btn", "setting_btn", "language_btn_1", "language_btn_2", "dismiss_btn", "exit_btn", "trustee_btn"}

    for i, v in ipairs(nameTab) do
    	self[v] = cc.uiloader:seekNodeByName(self.UINode_, v)
    	self[v]:setVisible(true)
    end 

    self["up_btn"]:onButtonClicked(handler(self, self.clickUpBtn))
    self["setting_btn"]:onButtonClicked(handler(self, self.clickSettingBtn))
    self["language_btn_1"]:onButtonClicked(handler(self, self.clickLanguage1Btn))
    self["language_btn_2"]:onButtonClicked(handler(self, self.clickLanguage2Btn))
    self["dismiss_btn"]:onButtonClicked(handler(self, self.clickDismissBtn))
    self["exit_btn"]:onButtonClicked(handler(self, self.clickExitBtn))
    self["trustee_btn"]:onButtonClicked(handler(self, self.clickTrusteeBtn))

    self["language_btn_2"]:setVisible(false)
    local serverType = DataCenter:getServerType()
    local tableUser = DataCenter:getTableUser()
    local selfChairId = DataCenter:getSelfChairID()

    if serverType == GAME_GENRE_SCORE then
        self["dismiss_btn"]:setVisible(tableUser == selfChairId)
        self["exit_btn"]:setVisible(tableUser ~= selfChairId)
        self["trustee_btn"]:setVisible(false)
    elseif serverType == GAME_GENRE_GOLD then
        self["dismiss_btn"]:setVisible(false)
        self["exit_btn"]:setVisible(true)
    end
end

function UIMenu:onHide()
    -- body
    self:setVisible(false)
end

function UIMenu:onUpdate()

end

function UIMenu:onRemove()
    -- body
    self:removeSelf()
end

function UIMenu:clickUpBtn(event)
	print("clickUpBtn")
	self:onHide()
end

function UIMenu:clickSettingBtn(event)
	print("clickSettingBtn")
	self:dispatchEvent({name = UIMenu.CLICK_SETTING_EVENT})
end

function UIMenu:clickLanguage1Btn(event)
	print("clickLanguage1Btn")
	self:dispatchEvent({name = UIMenu.CLICK_LANGUAGE1_EVENT})
end

function UIMenu:clickLanguage2Btn(event)
	print("clickLanguage2Btn")
	self:dispatchEvent({name = UIMenu.CLICK_LANGUAGE2_EVENT})
end

function UIMenu:clickDismissBtn(event)
	print("clickDismissBtn")
	self:dispatchEvent({name = UIMenu.CLICK_DISMISS_EVENT})
end

function UIMenu:clickExitBtn(event)
	print("clickExitBtn")
	self:dispatchEvent({name = UIMenu.CLICK_EXIT_EVENT})
end

function UIMenu:clickSelectMainBtn(event)
	dump(event)
	print("Tag = ", event.target:getTag())
	self.colorIndex_ = event.target:getTag()
	self:dispatchEvent({name = UIMenu.CLICK_SELECT_MAIN_EVENT})
end

function UIMenu:clickTrusteeBtn(event)
    self:onHide()
    self:dispatchEvent({name = UIMenu.CLICK_TRUSTEE_EVENT})
end

return UIMenu