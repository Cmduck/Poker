module(..., package.seeall) 

--------------------------------------------------------------------------
-- 状态--等待开始
--------------------------------------------------------------------------
local EventProxyEx = require("script.fightbombScript.common.EventProxyEx")
local CardHelper = require("script.fightbombScript.card.CardHelper")
local StateBase = require("script.fightbombScript.state.StateBase")
local CardView     = require("script.fightbombScript.card.CardView")
local StateWait = class("StateWait", StateBase)
local CardClass = require("script.fightbombScript.card.CardClass")
-- local GafHelper = require("script.fightbombScript.common.GafHelper")
local ActionHelper = require("script.fightbombScript.common.ActionHelper")

StateWait.GAME_RES = {
	-- Card = {
	-- 	plist = "ccbResources/fightbombRes/card/card.plist",
	-- 	png   = "ccbResources/fightbombRes/card/card.png"
	-- },

	-- SmallCard = {
	--     plist = "ccbResources/fightbombRes/card_small/card_small.plist",
	--     png   = "ccbResources/fightbombRes/card_small/card_small.png"
	-- },
}

function StateWait:ctor(scene)
	StateWait.super.ctor(self, scene)
end

function StateWait:StateBegin()  -- 开始该状态
	print("进入空闲状态")
	--local card = self:createSmallCard(0x3D)
	--card:align(display.CENTER, display.cx, display.cy):addTo(self)
end

function StateWait:LoadUIComponent()
	-- body
	UIManager:ShowUI("UIReady")
	--UIManager:ShowUI("UIScoreCard")
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
    	:addEventListener(DataCenter.class.MSG_SCORE_RULE_EVENT, handler(self, self.onNetScoreRule_))
    	:addEventListener(DataCenter.class.MSG_TABLEDISMISS_EVENT, handler(self, self.onNetTableDismiss_))	--空闲时解散桌子
    	:addEventListener(DataCenter.class.MSG_STARTGAME_EVENT, handler(self, self.onNetStartGame_))
        :addEventListener(DataCenter.class.MSG_REQUEST_LEAVE_EVENT, handler(self, self.onNetRequestLeave_))
        :addEventListener(DataCenter.class.MSG_DISMISS_RESULT_EVENT, handler(self, self.onNetDismissResult_))
        :addEventListener(DataCenter.class.MSG_TOTAL_ACCOUNT_EVENT, handler(self, self.onNetTotalAccount_))	
end

function StateWait:onNetScoreRule_()
	--如果是房主
	if DataCenter:getTableUser() == DataCenter:getSelfChairID() then
		UIManager:RemoveUI("UICreateRoom")
		UIManager:UpdateUI("UIReady")
	end
	UIManager:UpdateUI("UITopInfo")
end

function StateWait:onNetRequestLeave_()
	UIManager:ShowUI("UIDismiss")
	UIManager:UpdateUI("UIDismiss", 0)
end

function StateWait:onNetTableDismiss_()
	FGameDC:getDC():SendTableDismiss()
end

function StateWait:onNetStartGame_()
	UIManager:GetUI("UIReady"):UpdateReadyStatus()
end

function StateWait:onNetGameStart_(event)
	GameLogic:SortCardList(DataCenter:getSelfHandCardData(), DataCenter:getSelfHandCardCount(), ST_ORDER)
	StateManager:SetState(GAME_STATE_PLAYING)

	UIManager:UpdateUI("UIBackground")
	UIManager:UpdateUI("UICountDown")
	-- UIManager:UpdateUI("UIOutCard")
	-- UIManager:UpdateUI("UICallScore")
	UIManager:UpdateUI("UIIcon")

	if DataCenter:getIs1V3() then
		UIManager:UpdateUI("UIBaoCard")
	else
		UIManager:UpdateUI("UICallCard")
	end
end

function StateWait:onNetDismissResult_()
	UIManager:UpdateUI("UIDismiss", 2, DataCenter:getDismissResult())
end

function StateWait:onNetTotalAccount_()
	if DataCenter:getServerType() == GAME_GENRE_SCORE and DataCenter:getDismissResult() then
		UIManager:RemoveUI("UIDismiss")

		--游戏解散
		if DataCenter:getGameEndType() == 1 then
			UIManager:ShowUI("UITotalClear")
		end
	end
end

--用户点击准备
function StateWait:onUserReady(event)
	-- body
	--MusicCenter:PlayBtnEffect()
    InternetManager:SendUserReady(0)
end

function StateWait:onOverCountdown(event)
	-- body
	print("GF_Debug: -> StateWait:onOverCountdown")
	local serverType = DataCenter:getServerType()
	if serverType == GAME_GENRE_SCORE then
		InternetManager:SendUserReady(0)
	elseif serverType == GAME_GENRE_GOLD then
		self.scene_:ExitGame()
	end
end

function StateWait:StateEnd()    -- 结束该状态
  	print("------------------- > Wait场景状态结束")
	UIManager:RemoveUI("UIReady")
	self:removeSelf()
end

function StateWait:TestMD5()
	local path1 = "ccbResources/fightbombRes/icon/icon.json"
	local path2 = "ccbResources/fightbombRes/icon/icon111.json"
    local fullPath1 = cc.FileUtils:getInstance():fullPathForFilename(path1)
    dump(fullPath1)
    local fullPath2 = cc.FileUtils:getInstance():fullPathForFilename(path2)
	dump(crypto.md5file(fullPath1))
	dump(crypto.md5file(fullPath2))
end

return StateWait