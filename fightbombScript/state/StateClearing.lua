module(..., package.seeall) 

--------------------------------------------------------------------------
-- 结算
--------------------------------------------------------------------------
local EventProxyEx = require("script.fightbombScript.common.EventProxyEx")
local StateBase = require("script.fightbombScript.state.StateBase")
local StateClearing = class("StateClearing", StateBase)

StateClearing.GAME_RES = {
	-- SmallCard = {
	-- 	plist = "ccbResources/fightbombRes/card_small/card_small.plist",
	-- 	png   = "ccbResources/fightbombRes/card_small/card_small.png"
	-- }
}

function StateClearing:ctor(scene)
	StateClearing.super.ctor(self, scene)
end
 
function StateClearing:StateBegin()  -- 开始该状态
	print("进入结算状态")
end

function StateClearing:LoadUIComponent()
	-- body
	self.Clear_UI_ = UIManager:ShowUI("UIClear") 	
end

function StateClearing:RegisterUIEvent()
	-- body
	EventProxyEx.new(self.Clear_UI_, self)
		:addEventListener(self.Clear_UI_.class.CLICK_EXIT_BTN, handler(self, self.onClickReturnBtn))
		:addEventListener(self.Clear_UI_.class.CLICK_CONTINUE_GAME_BTN, handler(self, self.onClickContinueGameBtn))
		:addEventListener(self.Clear_UI_.class.CLICK_LOOK_TOTAL_ACCOUNT_BTN, handler(self, self.onClickLookTotalAccountBtn))	
end

function StateClearing:StateEnd()    -- 结束该状态
	print("------------------- > Clearing场景状态结束")
	UIManager:RemoveUI("UIClear")
	self:removeSelf()
end

function StateClearing:BindEvent()
	--游戏事件
    EventProxyEx.new(DataCenter, self)
	    	:addEventListener(DataCenter.class.MSG_REQUEST_LEAVE_EVENT, handler(self, self.onNetRequestLeave_))
	    	:addEventListener(DataCenter.class.MSG_DISMISS_RESULT_EVENT, handler(self, self.onNetDismissResult_))
	    	:addEventListener(DataCenter.class.MSG_TOTAL_ACCOUNT_EVENT, handler(self, self.onNetTotalAccount_))
end

function StateClearing:onNetRequestLeave_()
	UIManager:ShowUI("UIDismiss")
	UIManager:UpdateUI("UIDismiss", 0)
end

function StateClearing:onNetDismissResult_()
	UIManager:UpdateUI("UIDismiss", 2, DataCenter:getDismissResult())
end

function StateClearing:onNetTotalAccount_()
	if DataCenter:getServerType() == GAME_GENRE_SCORE and DataCenter:getDismissResult() then
		UIManager:RemoveUI("UIDismiss")
		--游戏解散
		if DataCenter:getGameEndType() == 1 then
			UIManager:ShowUI("UITotalClear")
		end
	end
end

function StateClearing:PlayGameResultMusic()
	-- body
	if DataCenter:getIsWin() then
		MusicCenter:PlayWinEffect()
	else
		MusicCenter:PlayLostEffect()
	end
end

function StateClearing:onClickReturnBtn(event)
	-- body
	MusicCenter:PlayBtnEffect()
	self.scene_:ExitGame()
end

function StateClearing:onClickContinueGameBtn(event)
	-- body
	MusicCenter:PlayBtnEffect()
	DataCenter:RepositDataEx()
	StateManager:SetState(GAME_STATE_WAIT)

	local serverType = DataCenter:getServerType()
    if serverType == GAME_GENRE_SCORE then
		UIManager:UpdateUI("UITopInfo")
		DataCenter:setServerStatus(GS_UG_CONTINUE)
		InternetManager:SendContinueGameReady()
		UIManager:UpdateUI("UIIcon")
    elseif serverType == GAME_GENRE_GOLD then
    	UIManager:UpdateUI("UIReady")
		UIManager:UpdateUI("UIIcon")
    end
end

function StateClearing:onClickLookTotalAccountBtn( event )
	-- body
	self:StateEnd()
   	UIManager:ShowUI("UITotalClear")
end

return StateClearing