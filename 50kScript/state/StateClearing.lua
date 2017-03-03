module(..., package.seeall) 

--------------------------------------------------------------------------
-- 结算
--------------------------------------------------------------------------
local EventProxyEx = require("script.50kScript.common.EventProxyEx")
local StateBase = require("script.50kScript.state.StateBase")
local StateClearing = class("StateClearing", StateBase)
local MusicCenter = require("script.50kScript.music.MusicCenter")

StateClearing.CLICK_CONTINUE_GAME_BTN = "CLICK_CONTINUE_BTN"
StateClearing.CLICK_RETURN_BTN = "CLICK_RETURN_BTN"

function StateClearing:ctor(scene)
	StateClearing.super.ctor(self, scene)
end
 
function StateClearing:StateBegin()  -- 开始该状态
	print("进入结算状态")
	--self:PlayGameResultMusic()
	self:LoadUIComponent()
	self:RegisterUIEvent( )
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
		--:addEventListener(self.Clear_UI_.class.CLICK_LOOK_TOTAL_ACCOUNT_BTN, handler(self, self.onClickLookTotalAccountBtn))	
end

function StateClearing:StateEnd()    -- 结束该状态
	print("------------------- > Clearing场景状态结束")
	local game_model = DataCenter:getGameModel()
	print("结算类型:" .. game_model == GAME_MODE_JIAO and "叫牌" or "吼牌")
	UIManager:RemoveUI(self.Clear_UI_.__cname)
	self:removeSelf()
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
	print(event.name)
	self.scene_:ExitGame()
end

function StateClearing:onClickContinueGameBtn(event)
	MusicCenter:PlayBtnEffect()
	DataCenter:RepositDataEx()
	StateManager:SetState(GAME_STATE_WAIT)
	-- body
	UIManager:UpdateUI("UIReady")
	UIManager:UpdateUI("UIIcon")
	UIManager:GetUI("UIBackground"):ResetUI()
end

function StateClearing:onClickLookTotalAccountBtn( event )
	-- body
	--InternetManager:SendRequestTotalAccount()
	self:StateEnd()
   	UIManager:ShowUI("UITotalClear")
end

return StateClearing