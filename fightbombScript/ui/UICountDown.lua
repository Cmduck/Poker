--
-- Author: GFun
-- Date: 2016-10-27 19:30:26
--
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local UIBase = require("script.fightbombScript.ui.UIBase")
local UICountDown = class("UICountDown", UIBase)
local OUT_CARD_TIMER = 25
function UICountDown:ctor()
    UICountDown.super.ctor(self)
    self.time_ = 25
    self.countdownNode_ = nil
    self.countdownText_ = nil  
end

function UICountDown:onShow()
	-- body
	local nodeNameTab = {"node_down", "node_right", "node_up", "node_left"}

	for i, v in ipairs(nodeNameTab) do
		--加载节点
		self[v] = cc.uiloader:seekNodeByName(self.UINode_, v)
		self[v]:setVisible(false)
		--self[v]:setScale(0.5)
		self[v .. "_count_down"] = cc.uiloader:seekNodeByName(self[v], "count_down")
	end
end 

function UICountDown:onHide()
    -- body
    self:setVisible(false)
end


function UICountDown:onUpdate()
	self:setVisible(true)
	local current_user = DataCenter:getCurrentUser()
	print("UICountDown 当前玩家:" .. tostring(current_user))
	local nodeNameTab = {"node_down", "node_right", "node_up", "node_left"}
	local direction = GetDirection(current_user) + 1
	if self.handle_ then
		scheduler.unscheduleGlobal(self.handle_)
	end
	for i = 0, GAME_PLAYER - 1 do
		local direction = GetDirection(i) + 1
		local node_name = nodeNameTab[direction]
		
		if i == current_user then
			self[node_name]:setVisible(true)
			self.countdownNode_ = self[node_name]
			self.time_ = OUT_CARD_TIMER
			self[node_name .. "_count_down"]:setString(tostring(self.time_))
			self.countdownText_ = self[node_name .. "_count_down"]
			self.handle_ = scheduler.scheduleGlobal(handler(self, self.CountDown), 1)
		else
			self[node_name]:setVisible(false)
		end
	end
end

function UICountDown:onRemove()
    -- body
    self:removeSelf()
end

function UICountDown:CountDown(dt)
	-- body
	if self.time_ ~= 0	then
		self.time_ = self.time_ - 1
		self.countdownText_:setString(tostring(self.time_))
	else
		--to do
		--倒计时之后的操作
		print("---------------CountDown END ------------------")
		MusicCenter:PlayTimeOutEffect()
		self.countdownText_:setString("0")
		scheduler.unscheduleGlobal(self.handle_)
		self.handle_ = nil
	end
end

function UICountDown:onCleanup()
	-- body
	self.super.onCleanup(self)
	if self.handle_ then
		scheduler.unscheduleGlobal(self.handle_)
	end
end

return UICountDown