local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local UIBase = require("script.fightbombScript.ui.UIBase")
local UIReady = class("UIReady", UIBase)

UIReady.UIReady_CLICK_READY_BTN_EVENT = "UIReady_CLICK_READY_BTN_EVENT"
UIReady.UIReady_OVER_COUNTDOWN_EVENET = "UIReady_OVER_COUNTDOWN_EVENET"

function UIReady:ctor()
    UIReady.super.ctor(self)
    self.time_ = 10000   
end

function UIReady:onShow()
    -- body
    print(self.__cname .. ":onShow()")
    local nodeNameTab = {"img_ready_down", "img_ready_right", "img_ready_up", "img_ready_left"}
    for i, v in ipairs(nodeNameTab) do
    	self[v] = cc.uiloader:seekNodeByName(self.UINode_, v)
    	self[v]:setVisible(false)
    end
    
    self["Btn_ready"] = cc.uiloader:seekNodeByName(self.UINode_, "Btn_ready")
    self["Btn_ready"]:onButtonClicked(handler(self, self.clickReadyBtn))
    self["Btn_ready"]:setVisible(false)
    self["text_countdown"] = cc.uiloader:seekNodeByName(self.UINode_, "text_countdown")
    self["text_countdown"]:setVisible(false)

    self["text_countdown"]:setString(self.time_)
   --  self.handle_ = scheduler.scheduleGlobal(handler(self, self.CountDown), 1)
  	-- print("当前定时器时间:" .. self.time_)
end

function UIReady:onHide()
    -- body
    self:setVisible(false)
end

function UIReady:onUpdate()
    -- body
    print(self.__cname ..":-------------------------> onUpdate()")
    --self:setVisible(true)
    --屏蔽准备

    local nodeNameTab = {"img_ready_down", "img_ready_right", "img_ready_up", "img_ready_left"}

	for i = 0, GAME_PLAYER - 1 do
		local pUserData = FGameDC:getDC():GetUserInfo(i)
		local nodeName = nodeNameTab[GetDirection(i) + 1]

		if pUserData == nil or pUserData == 0 then
			
		else
			-- print(i .. " 用户的状态 = ".. pUserData.cbUserStatus)
			self[nodeName]:setVisible(pUserData.cbUserStatus == US_READY)
		end
	end

	local my_chairID = GetSelfChairID()
	local pMyData = FGameDC:getDC():GetUserInfo(my_chairID)
	local ready_tab = DataCenter:getReadyStatus()
	--手动准备
    -- self["Btn_ready"]:setVisible(pMyData.cbUserStatus == US_SIT)
    -- self["text_countdown"]:setVisible(pMyData.cbUserStatus == US_SIT and self.time_ ~= 0)

    -- if not self.handle_ and pMyData.cbUserStatus == US_SIT then
    -- 	self.handle_ = scheduler.scheduleGlobal(handler(self, self.CountDown), 1)
    -- end

    --自动准备
    if DataCenter:getServerStatus() == GS_UG_FREE then
    	if pMyData.cbUserStatus == US_SIT then
    		self:clickReadyBtn()
    	end
    elseif DataCenter:getServerStatus() == GS_UG_CONTINUE then
    	if ready_tab[my_chairID] ~= 0 then
    		self:clickReadyBtn()
    	end
    end
end

function UIReady:clickReadyBtn()
	-- body
    self["Btn_ready"]:setVisible(false)
    self["text_countdown"]:setVisible(false)
    if self.handle_ then
    	scheduler.unscheduleGlobal(self.handle_)
    	self.handle_ = nil
	end
	--继续场景发送继续游戏消息 非继续游戏场景发送准备消息
	print("DataCenter:getServerType() == GS_UG_CONTINUE :" .. tostring(DataCenter:getServerStatus() == GS_UG_CONTINUE))
	if DataCenter:getServerStatus() == GS_UG_CONTINUE then
		InternetManager:SendContinueGameReady()
	else
    	self:dispatchEvent({name = UIReady.UIReady_CLICK_READY_BTN_EVENT})
	end
end

function UIReady:UpdateReadyStatus()
	local nodeNameTab = {"img_ready_down", "img_ready_right", "img_ready_up", "img_ready_left"}
	local readyTab = DataCenter:getReadyStatus()
	dump(readyTab)
	for i = 0, GAME_PLAYER - 1 do
		local pUserData = FGameDC:getDC():GetUserInfo(i)
		local nodeName = nodeNameTab[GetDirection(i) + 1]

		if pUserData == nil or pUserData == 0 then
			
		else
			self[nodeName]:setVisible(readyTab[i + 1] == 1)
		end

		if i == DataCenter:getSelfChairID() and readyTab[i + 1] == 0 then
			--self["Btn_ready"]:setVisible(readyTab[i + 1] == 0)
			InternetManager:SendContinueGameReady() --自动准备
		end
	end
end

function UIReady:onRemove()
    -- body
    self:removeSelf()
end

function UIReady:CountDown(dt)
	-- body
	if self.time_ ~= 0	then
		self["text_countdown"]:setVisible(true)
		self.time_ = self.time_ - 1
		self["text_countdown"]:setString(tostring(self.time_))
	else
		--to do
		--倒计时之后的操作
		print("---------------CountDown END ------------------")
		self["text_countdown"]:setVisible(false)
		scheduler.unscheduleGlobal(self.handle_)
		self.handle_ = nil
		self:dispatchEvent({name = UIReady.UIReady_OVER_COUNTDOWN_EVENET})
	end
end

function UIReady:onCleanup()
	-- body
	self.super.onCleanup(self)
	if self.handle_ then
		scheduler.unscheduleGlobal(self.handle_)
	end
end

return UIReady