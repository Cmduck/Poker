--
-- Author: GFun
-- Date: 2016-10-24 18:11:31
--
--
local UIBase = require("script.50kScript.ui.UIBase")
local UICreateRoom = class("UICreateRoom", UIBase)

UICreateRoom.CLICK_CREATE_ROOM_BTN = "CLICK_CREATE_ROOM_BTN"
UICreateRoom.CLICK_CLOSE_BTN = "CLICK_CLOSE_BTN"

local LESS_CARD_COLOR 	= cc.c3b(255, 0, 0)
local ENOUGH_CARD_COLOR	= cc.c3b(0, 128, 0)

function UICreateRoom:ctor()
	self.maskLayer_ = display.newColorLayer(ccc4(0, 0, 0, 100))--ccc4
	self.maskLayer_:addTo(self)
    UICreateRoom.super.ctor(self)
end

function UICreateRoom:onShow()
	-- body
	-- self.maskLayer_ = display.newColorLayer(ccc4(0, 0, 0, 200))--ccc4
	-- dump(self.maskLayer_)
	-- self.maskLayer_:addTo(self)
	-- self.maskLayer_:setOpacity(cc.c4f(0, 0, 0, 150))
	local nameTab = {"inning_num_1", "inning_num_2", "inning_btn_1", "inning_btn_2", "option_btn_1", "option_btn_2", "Btn_close", "Btn_create_room", "room_card"}
    for i, v in ipairs(nameTab) do
    	self[v] = cc.uiloader:seekNodeByName(self.UINode_, v)
    	--print(v)
    end
    self["inning_btn_1"]:onButtonStateChanged(handler(self, self.onBtnInning1Clicked))
    self["inning_btn_2"]:onButtonStateChanged(handler(self, self.onBtnInning2Clicked))
    self["option_btn_1"]:onButtonStateChanged(handler(self, self.onBtnOption1Clicked))
    self["option_btn_2"]:onButtonStateChanged(handler(self, self.onBtnOption2Clicked))
    self["Btn_close"]:onButtonClicked(handler(self, self.clickCloseBtn))
    self["Btn_create_room"]:onButtonClicked(handler(self, self.clickCreateRoomBtn))
    -- self["inning_btn_1"]:setButtonSelected(true)
    -- self["option_btn_1"]:setButtonSelected(true)
end

function UICreateRoom:onBtnInning1Clicked(event)
	-- body
	local str = "房卡 ×" .. self.roomCardCost_[1]

	if self["inning_btn_2"]:isButtonSelected() then
		self["inning_btn_2"]:setButtonSelected(false)
	end
	if event.state == "on" then
		self.selectedInningNum_ = DataCenter:getInningOption()[1]
		self["inning_btn_1"]:setButtonSelected(true)
	elseif event.state == "off" then
		self.selectedInningNum_ = 0
		self["inning_btn_1"]:setButtonSelected(false)
	end
	--dump(self.selectedInningNum_)
	self:setRoomCardText(str, 1)
end

function UICreateRoom:onBtnInning2Clicked(event)
	-- body
	local str = "房卡 ×" .. self.roomCardCost_[2]
	if self["inning_btn_1"]:isButtonSelected() then
		self["inning_btn_1"]:setButtonSelected(false)
	end
	if event.state == "on" then
		self.selectedInningNum_ = DataCenter:getInningOption()[2]
		self["inning_btn_2"]:setButtonSelected(true)
	elseif event.state == "off" then
		self.selectedInningNum_ = 0
		self["inning_btn_2"]:setButtonSelected(false)
	end
	--dump(self.selectedInningNum_)
	self:setRoomCardText(str, 2)
end

function UICreateRoom:onBtnOption1Clicked( event )
	-- body
	--dump(event)
	if self["option_btn_2"]:isButtonSelected() then
		self["option_btn_2"]:setButtonSelected(false)
	end
	if event.state == "on" then
		self.selectedPlaneNum_ = DataCenter:getPlaneOption()[1]
		self["option_btn_1"]:setButtonSelected(true)
	elseif event.state == "off" then
		self.selectedPlaneNum_ = 0
		self["option_btn_1"]:setButtonSelected(false)
	end
	--dump(self.selectedPlaneNum_)
end

function UICreateRoom:onBtnOption2Clicked( event )
	-- body
	--dump(event)
	if self["option_btn_1"]:isButtonSelected() then
		self["option_btn_1"]:setButtonSelected(false)
	end
	if event.state == "on" then
		self.selectedPlaneNum_ = DataCenter:getPlaneOption()[2]
		self["option_btn_2"]:setButtonSelected(true)
	elseif event.state == "off" then
		self.selectedPlaneNum_ = 0
		self["option_btn_2"]:setButtonSelected(false)
	end
	--dump(self.selectedPlaneNum_)
end
 
function UICreateRoom:onHide()
    -- body
    self:setVisible(false)
end

function UICreateRoom:onUpdate()
	self:setVisible(true)
    self.selectedInningNum_ = DataCenter:getInningOption()[1]
    self.selectedPlaneNum_ = DataCenter:getPlaneOption()[1]
    self.roomCardCost_ = DataCenter:getRoomCardOption()
    for i, v in ipairs(DataCenter:getInningOption()) do
    	self["inning_num_" .. i]:setString(v)
    end
    self["inning_btn_1"]:setButtonSelected(true)
    self["option_btn_1"]:setButtonSelected(true)
end

function UICreateRoom:onRemove()
    self:removeSelf()
end

function UICreateRoom:setRoomCardText(str, index)
	-- body
	local bLess = DataCenter:getLessRoomCardTab()[index]
	local color
	if bLess then
		color = LESS_CARD_COLOR
		str = str .. " (不足)"
	else
		color = ENOUGH_CARD_COLOR
	end
	self.bLessCard_ = bLess
	self["room_card"]:setString(str)
	self["room_card"]:setColor(color)
end

function UICreateRoom:clickCloseBtn(event)
	-- body
	self:dispatchEvent({name = UICreateRoom.CLICK_CLOSE_BTN})
end

function UICreateRoom:clickCreateRoomBtn( event )
	-- body
	if self.bLessCard_ then
		print("房卡不足")
		return 
	end

	if not self.selectedInningNum_ or not self.selectedPlaneNum_ or self.selectedInningNum_ == 0 or self.selectedPlaneNum_ == 0 then
		print("-----------------------Please pick option!---------------------")
		return
	end
	InternetManager:sendScoreRule(self.selectedInningNum_, self.selectedPlaneNum_)
	StateManager:GetCurState():onUserReady()
end

return UICreateRoom