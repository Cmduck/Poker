module(..., package.seeall) 

--------------------------------------------------------------------------
-- 状态--等待开始
--------------------------------------------------------------------------
local EventProxyEx = require("script.50kScript.common.EventProxyEx")
local GameLogic = require("script.50kScript.game.GameLogic")
local MusicCenter = require("script.50kScript.music.MusicCenter")
local StateBase = require("script.50kScript.state.StateBase")
local StateWait = class("StateWait", StateBase)

StateWait.StateWait_CLICK_READY_BUTTON = "StateWait_CLICK_READY_BUTTON"
StateWait.StateWait_OVER_COUNTDOWN_EVENET = "StateWait_OVER_COUNTDOWN_EVENET"

function StateWait:ctor(scene)
	StateWait.super.ctor(self, scene)
end

function StateWait:StateBegin()  -- 开始该状态
	self:LoadUIComponent()
	self:RegisterUIEvent()
	--self:Test50K()
	--self:TestOutCard()
end

function StateWait:LoadUIComponent()
	-- body
	UIManager:ShowUI("UIIcon")
	UIManager:ShowUI("UIReady")
end

function StateWait:RegisterUIEvent()
	-- body
    local UIReady = UIManager:GetUI("UIReady")
    EventProxyEx.new(UIReady, self)
        :addEventListener(UIReady.class.UIReady_CLICK_READY_BTN_EVENT, handler(self, self.onUserReady))
        :addEventListener(UIReady.class.UIReady_OVER_COUNTDOWN_EVENET, handler(self, self.onOverCountdown))
end

function StateWait:BindEvent()
	print("-----------------------------------------StateWait:BindEvent()------------------")
	
    EventProxyEx.new(DataCenter, self)
        :addEventListener(DataCenter.class.MSG_GAME_START_EVENT, handler(self, self.onNetGameStart_))	
end

function StateWait:onNetGameStart_(event)
	--GameLogic:SortHandCardList(DataCenter:getSelfHandCardData(), DataCenter:getSelfHandCardCount())
	GameLogic:SortCardList(DataCenter:getSelfHandCardData(), DataCenter:getSelfHandCardCount(), ST_ORDER)
	StateManager:SetState(GAME_STATE_PLAYING)
	--更新牌型
	UIManager:UpdateUI("UIBackground")
	UIManager:UpdateUI("UICountDown")
end

--用户点击准备
function StateWait:onUserReady(event)
	-- body
	print("GF_Debug: -> StateWait:onUserReady")
	MusicCenter:PlayBtnEffect()
	if DataCenter:isCreateTable() and DataCenter:getIsClickContinueGame() then
		InternetManager:SendContinueGameReady()
	else
		InternetManager:SendUserReady(0)
	end
end

function StateWait:onOverCountdown(event)
	-- body
	print("GF_Debug: -> StateWait:onOverCountdown")
	self.scene_:ExitGame()
end

function StateWait:StateEnd()    -- 结束该状态
  	print("------------------- > Wait场景状态结束")
	UIManager:RemoveUI("UIReady")
	self:removeSelf()
end

function StateWait:Test50K()
	local cbCardData = {0x05, 0x15, 0x0A, 0x0D, 0x3D}
	local cbCardCount = #cbCardData
	local cbHandCardData = ConvertTableToArray(cbCardData, cbCardCount)
	local cbHandCardCount = cbCardCount
	local OutCardWSKResult = GameLogic:CreateTagWSKOutCardResult()
	GameLogic:SearchWuShiK(cbHandCardData, cbHandCardCount, OutCardWSKResult)
	dump(OutCardWSKResult)
end

function StateWait:TestOutCard()
	local cbCardData = {0x05, 0x15, 0x0A, 0x0D, 0x3D, 0x4E, 0x4E, 0x4F, 0x4F}
	local cbCardCount = #cbCardData
	local cbHandCardData = ConvertTableToArray(cbCardData, cbCardCount)
	local cbHandCardCount = cbCardCount

	local cbTurnCardData = {0x4E, 0x4E}
	local cbTurnCardCount = #cbTurnCardData
	local cbTurnCardData = ConvertTableToArray(cbTurnCardData, cbTurnCardCount)
	local OutCardResult = GameLogic:CreateTagOutCardResult()
	GameLogic:SearchOutCard(cbHandCardData, cbHandCardCount, cbTurnCardData, cbTurnCardCount, OutCardResult)
	dump(OutCardResult)
	dump(cbTurnCardData)	
end

return StateWait