module(..., package.seeall) 

--------------------------------------------------------------------------
-- 状态--等待开始
--------------------------------------------------------------------------
local EventProxyEx = require("script.50kScript.common.EventProxyEx")
local HandCards    = require("script.50kScript.card.HandCards")
local ComboCards   = require("script.50kScript.card.ComboCards")
local ShowCards    = require("script.50kScript.card.ShowCards")
local CardView     = require("script.50kScript.card.CardView")
local StateBase    = require("script.50kScript.state.StateBase")
local GameLogic    = require("script.50kScript.game.GameLogic")
local MusicCenter  = require("script.50kScript.music.MusicCenter")
local CardHelper   = require("script.50kScript.card.CardHelper")
local scheduler    = require(cc.PACKAGE_NAME .. ".scheduler")
local ActionHelper = require("script.50kScript.common.ActionHelper")
local StatePlaying = class("StatePlaying", StateBase)

StatePlaying.StatePlaying_CLICK_READY_BUTTON    = "StatePlaying_CLICK_READY_BUTTON"
StatePlaying.StatePlaying_OVER_COUNTDOWN_EVENET = "StatePlaying_OVER_COUNTDOWN_EVENET"

local cardPlist = "ccbResources/50kRes/card/card.plist"
local cardPng   = "ccbResources/50kRes/card/card.png"

local game_playing_res = {
	Card = {
		plist = "ccbResources/50kRes/card/card.plist",
		png   = "ccbResources/50kRes/card/card.png"
	},
}
function StatePlaying:ctor(scene)
	StatePlaying.super.ctor(self, scene)

    self:LoadGameRes()
    self:setContentSize(display.width, display.height)
	self:setTouchEnabled(true)
	self:setTouchSwallowEnabled(false)
	--注册触摸事件
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch_))
	self.m_nClickNum_       = 0
	self.selectCards_       = {}
	self.selectCardsStatus_ = {} 
	self.tipsIndex_         = -1
	self.tipsTab_           = {}
	self.warnAnimationTab_  = {}
    self.warnPosTab_ = {
    	cc.p(215, 320),
    	cc.p(1055, 510),
    	cc.p(340, 660),
    	cc.p(215, 520)
	}
end

function StatePlaying:StateBegin()  -- 开始该状态

	self:PlayStartMusic()
	--创建手牌
	self:ShowHandCards()
	self:LoadUIComponent()
	self:RegisterUIEvent()
	self:ShowTrusteeshipBtn()
end

function StatePlaying:LoadGameRes()
	-- body
	for k, v in pairs(game_playing_res) do
		print("Loading Res---------------------->" .. k .. ".plist, " .. k .. ".png")
		display.addSpriteFrames(v.plist, v.png)
	end
	--error("Test")
end

function StatePlaying:RemoveGameRes()
	-- body
	for k, v in pairs(game_playing_res) do
		print("Remove Res---------------------->" .. k .. ".plist, " .. k .. ".png")
		display.removeSpriteFramesWithFile(v.plist, v.png)
	end
end

--播放开始音效
function StatePlaying:PlayStartMusic()
	-- body
	MusicCenter:PlayStartEffect()
end

function StatePlaying:PlayEndMusic()
	-- body
	MusicCenter:PlayEndEffect()
end

--显示手牌
function StatePlaying:ShowHandCards()
	-- body
	self.myHandCards_ = HandCards.new()
	self.myHandCards_:addTo(self)
	self.myHandCards_:align(display.CENTER, display.cx, 90)
	-- EventProxyEx.new(self.myHandCards_, self):addEventListener(self.myHandCards_.class.ADD_CARD_EVENT, handler(self, self.onAddCard))
	-- EventProxyEx.new(self.myHandCards_, self):addEventListener(self.myHandCards_.class.REMOVE_CARD_EVENT, handler(self, self.onRemoveCard))
	local hand_card_data = DataCenter:getSelfHandCardData()
	local hand_card_count = DataCenter:getSelfHandCardCount()

	self.myHandCards_:createCards(hand_card_data, hand_card_count)--self.myHandCards_:createCards(testLeftCards) DataCenter:getMyHandCards()

end


function StatePlaying:LoadUIComponent()
	-- body
	UIManager:ShowUI("UITopInfo")
	UIManager:ShowUI("UIHou")
	UIManager:ShowUI("UIOutCard")
	UIManager:ShowUI("UIOverCard")
	UIManager:ShowUI("UICountDown")
	UIManager:ShowUI("UITrusteeship")
	-- UIManager:ShowUI("UICountDown")
	-- UIManager:ShowUI("UIDismiss")
end

function StatePlaying:RegisterUIEvent()
	-- body
	local UIHou = UIManager:GetUI("UIHou")
	EventProxyEx.new(UIHou, self)
		:addEventListener(UIHou.class.CLICK_CALL_CARD_BTN_EVENT, handler(self, self.onCallCardClicked))
		:addEventListener(UIHou.class.CLICK_MAIN_HOU_BTN_EVENT, handler(self, self.onMainHouClicked))
		:addEventListener(UIHou.class.CLICK_OTHER_HOU_BTN_EVENT, handler(self, self.onOtherHouClicked))
		:addEventListener(UIHou.class.CLICK_OTHER_BU_HOU_BTN_EVENT, handler(self, self.onOtherBuHouClicked))

	local UIOutCard = UIManager:ShowUI("UIOutCard")
	EventProxyEx.new(UIOutCard, self)
		:addEventListener(UIOutCard.class.CLICK_BU_CHU_BTN_EVENT, handler(self, self.onBuChuClicked))
		:addEventListener(UIOutCard.class.CLICK_TI_SHI_BTN_EVENT, handler(self, self.onTiShiClicked))
		:addEventListener(UIOutCard.class.CLICK_CHU_PAI_BTN_EVENT, handler(self, self.onChuPaiClicked))
end

function StatePlaying:BindEvent()
	--游戏事件
    EventProxyEx.new(DataCenter, self)
        :addEventListener(DataCenter.class.MSG_PASS_CARD_EVENT, handler(self, self.onNetMsgPassCard_))
        :addEventListener(DataCenter.class.MSG_HOUSTATE_CARD_EVENT, handler(self, self.onNetMsgHouStateCard_))
        :addEventListener(DataCenter.class.MSG_CALL_CARD_EVENT, handler(self, self.onNetMsgCallCard_))
        :addEventListener(DataCenter.class.MSG_HOU_CARD_END_EVENT, handler(self, self.onNetMsgHouCardEnd_))
        :addEventListener(DataCenter.class.MSG_OUT_CARD_START_EVENT, handler(self, self.onNetMsgOutCardStart_))
        :addEventListener(DataCenter.class.MSG_OUT_CARD_END_EVENT, handler(self, self.onNetMsgOutCardEnd_))
        :addEventListener(DataCenter.class.MSG_CUR_TURN_OVER_EVENT, handler(self, self.onNetMsgCurTurnOver_))
        :addEventListener(DataCenter.class.MSG_OVER_CARD_EVENT, handler(self, self.onNetMsgOverCard_))
    	:addEventListener(DataCenter.class.MSG_GAME_END_EVENT, handler(self, self.onNetMsgGameEnd_))
    	:addEventListener(DataCenter.class.SYSTEM_G_USER_TRUSTEESHIP, handler(self, self.onNetSysMsgTrusteeship_))			
end

function StatePlaying:onNetMsgOutCard_(event)
	UIManager:UpdateUI("UITopInfo")
end

function StatePlaying:onNetMsgPassCard_(event)
	UIManager:GetUI("UIOutCard"):ShowPassCard()
	self:PlayPassCardEffect()
end

function StatePlaying:onNetMsgHouStateCard_(event)
	UIManager:UpdateUI("UIHou")
	UIManager:UpdateUI("UICountDown")
end

function StatePlaying:onNetMsgCallCard_(event)
	UIManager:UpdateUI("UITopInfo")
	UIManager:UpdateUI("UICountDown")
	UIManager:UpdateUI("UIHou")
end

function StatePlaying:onNetMsgHouCardEnd_(event)
	--更新出牌
	UIManager:UpdateUI("UIHou")
	UIManager:UpdateUI("UITopInfo")
	UIManager:UpdateUI("UIIcon")
	UIManager:UpdateUI("UIOutCard")
	UIManager:HideUI("UIHou")
	UIManager:UpdateUI("UICountDown")
end

function StatePlaying:onNetMsgCurTurnOver_(event) 
	UIManager:GetUI("UITopInfo"):updateScore()
	UIManager:UpdateUI("UIIcon")
	self:clearAllPlayerOutCard()
end

function StatePlaying:onNetMsgOutCardStart_(event)
	self:clearCurrentUserOutCard()
	UIManager:UpdateUI("UIOutCard")
	UIManager:UpdateUI("UICountDown")
	if DataCenter:getIsDealPassCard() and DataCenter:getCurrentUser() == DataCenter:getSelfChairID() then
		DataCenter:setIsDealPassCard(false)
	end

	if DataCenter:getCurrentUser() == DataCenter:getSelfChairID() then
		if DataCenter:getIsDealPassCard() then DataCenter:setIsDealPassCard(false) end
		if DataCenter:getIsDealOutCard() then DataCenter:setIsDealOutCard(false) end
	end
end

function StatePlaying:onNetMsgOutCardEnd_(event)
	--删除出牌
	if DataCenter:getPrevOutUser() == DataCenter:getSelfChairID() then
		if DataCenter:getMyTrusteeshipStatus() then
			print("===================托管代打======================")
			local cardsData = DataCenter:getPrevOutCardData()
			local cardsCount = DataCenter:getPrevOutCardCount()
			self:RemoveCards(clone(cardsData), cardsCount)
		else
			print("===================普通出牌======================")
			self:RemoveOutCard()
		end
	end
	UIManager:UpdateUI("UITopInfo") 
	UIManager:UpdateUI("UIBackground")
	UIManager:UpdateUI("UIIcon")
	self:showOtherPlayerOutCard()
	self:PlayOutCardEffect()
end

function StatePlaying:onNetMsgOverCard_(event)
	UIManager:UpdateUI("UIOverCard")
end

function StatePlaying:onNetMsgGameEnd_(event)
	self:PlayEndMusic()
    UIManager:HideUI("UIOutCard")
    UIManager:HideUI("UICountDown")
	self:DeleteScheduler(self.showAllCardHandle_)
    self.showAllCardHandle_ = scheduler.performWithDelayGlobal(function()
            -- body
            StateManager:SetState(GAME_STATE_CLEARING)
    end, 1)
end

function StatePlaying:onNetSysMsgTrusteeship_(event)
	UIManager:UpdateUI("UIIcon")
	UIManager:UpdateUI("UITrusteeship")
end

function StatePlaying:DeleteScheduler(handle)
    if handle then
        scheduler.unscheduleGlobal(handle)
        handle = nil        
    end
end

function StatePlaying:showCallCardTipImg()
	-- body
	self.myHandCards_:showCallCardTip()
end 

function StatePlaying:onCallCardClicked(event)
	MusicCenter:PlayBtnEffect()
	local data = self.myHandCards_:getOutCardsData()
	if #data == 0 then
		print("请选择叫牌！！！")
		return
	elseif #data > 1 then
		print("只能选择一张叫牌!!!")
		return 
	end
	InternetManager:sendCallCard(data)
	self:resetOutCards()
end

function StatePlaying:onMainHouClicked(event)
	MusicCenter:PlayBtnEffect()
	InternetManager:sendHouCard(true)
end

function StatePlaying:onOtherHouClicked(event)
	MusicCenter:PlayBtnEffect()
	InternetManager:sendHouCard(true)
end

function StatePlaying:onOtherBuHouClicked(event)
	MusicCenter:PlayBtnEffect()
	InternetManager:sendHouCard(false)
end

function StatePlaying:onBuChuClicked( event )
	-- body
	if not event.tishi then
		MusicCenter:PlayBtnEffect()
	end

	if DataCenter:getIsDealPassCard() then
		print("####################正在处理PASS##################")
		return 
	end
	if DataCenter:getIsFirstOutCard() then
		print("----------------Must pick cards!------------------------")
		return
	end
	--重置提示
	self.tipsTab_ = {}
	self.tipsIndex_ = -1
	self.m_nClickNum_ = 0
	self:resetOutCards()
	DataCenter:setIsDealPassCard(true)

	InternetManager:sendPassCard()
end

function StatePlaying:onTiShiClicked( event )
	MusicCenter:PlayBtnEffect()
	self:resetOutCards()
	dump(self.tipsTab_)
	local bFirstOut = DataCenter:getIsFirstOutCard()
	if bFirstOut then
		print("首出牌，不提示！")
		return
	end

	--还未搜索提示
	if self.tipsIndex_ == -1 then
		print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
		local selfCardData = self.myHandCards_:getHandCardsData()
		local selfCardCount = self.myHandCards_:getHandCardsCount()
		print("当前手牌数据:")
		dump(selfCardData)
		local prevCardData = DataCenter:getPrevOutCardData()
		local prevCardCount = DataCenter:getPrevOutCardCount()

		self.tipsTab_ = GameLogic:GetOutCardTip(prevCardData, prevCardCount, selfCardData, selfCardCount)
		-- print("提示牌型:")
		-- dump(self.tipsTab_)
		self.tipsIndex_ = 0
		--没有找到提示
		if not self.tipsTab_ or #self.tipsTab_ == 0 then
			print("手上没有能大于上家的牌!")
			self:showYaoBuQiTips()
			local autoClickEvent = {tishi = true}
			self:onBuChuClicked(autoClickEvent)
			return
		end
	elseif self.tipsIndex_ == 0 then
		self:showYaoBuQiTips()
		return
	end

	self.tipsIndex_ = self.tipsIndex_ + 1
	if self.tipsIndex_ > #self.tipsTab_ then
		self.tipsIndex_ = 1
	end

	--如果提示只有一种 则双击表示重置手牌
	if self.tipsIndex_ == 1 and #self.tipsTab_ == 1 then
		self.m_nClickNum_ = self.m_nClickNum_ + 1
		if 	self.m_nClickNum_ == 2 then
			self:resetOutCards()
			self.m_nClickNum_ = 0
			return
		end
	end
	print("当前提示牌:")
	print("当前索引:" .. self.tipsIndex_)
	dump(self.tipsTab_[self.tipsIndex_])
	self:extractTipsCards()
end

--重置出牌 所有牌默认未点击状态
function StatePlaying:resetOutCards()
	-- body
	local view_list = self.myHandCards_:getCardsViewList()
	for i, v in ipairs(view_list) do
		if v:isTop() then
			v:onTouch_()
		end
	end
end

--抽取提示手牌
function StatePlaying:extractTipsCards()
	-- body
	local view_list = self.myHandCards_:getCardsViewList()
	local myAllCardsData = self.myHandCards_:getHandCardsData()
	local myAllCardsCount= self.myHandCards_:getHandCardsCount()
	--已选择的个数
	local pickNum = 0
	local recordTab = {}
	local card_num = #self.tipsTab_[self.tipsIndex_]
	local card_data = clone(self.tipsTab_[self.tipsIndex_])

	for i = myAllCardsCount - 1, 0, -1 do
		if type(self.tipsTab_[self.tipsIndex_]) == "number" then
			if myAllCardsData[i] == self.tipsTab_[self.tipsIndex_] then
				if myAllCardsData[i] == self.tipsTab_[self.tipsIndex_ - 1] then
					view_list[i]:onTouch_()
				else
					view_list[i + 1]:onTouch_()
				end
				break
			end
		elseif type(self.tipsTab_[self.tipsIndex_]) == "table" then
			-- local card_num = #self.tipsTab_[self.tipsIndex_]
			-- local card_data = clone(self.tipsTab_[self.tipsIndex_])
			for j, vj in ipairs(card_data) do
				if myAllCardsData[i] == vj and pickNum <= card_num then
					view_list[i + 1]:onTouch_()
					card_data[j] = 0
					pickNum = pickNum + 1
					break
				end
			end
			if pickNum == cardNum then break end
		end
	end
end

--移除手牌(托管使用)
function StatePlaying:RemoveCards(cardsData, cardsCount)
	dump(cardsData)
	dump(cardsCount)
	local view_list = self.myHandCards_:getCardsViewList()
	local myAllCardsData = self.myHandCards_:getHandCardsData()
	local myAllCardsCount= self.myHandCards_:getHandCardsCount()

	dump(myAllCardsData)
	dump(myAllCardsCount)
	local pickNum = 0

	for i = myAllCardsCount - 1, 0, -1 do
		for j = 0, cardsCount - 1 do
			if myAllCardsData[i] == cardsData[j] and pickNum <= cardsCount then
				view_list[i + 1]:onTouch_()
				cardsData[j] = 0
				pickNum = pickNum + 1
				break
			end		
		end
		if pickNum == cardsCount then break end
	end
	self:RemoveOutCard()
end

function StatePlaying:onChuPaiClicked( event )
	-- body
	MusicCenter:PlayBtnEffect()
	if DataCenter:getIsDealOutCard() then
		print("################正在处理出牌#############")
		return
	end
	print("-----------------StatePlaying:onChuPaiClicked-----------------------")

	local bFirstOut = DataCenter:getIsFirstOutCard()
	local myOutCardData = self.myHandCards_:getOutCardsData()
	local myOutCardCount = #myOutCardData

	if myOutCardData == nil or myOutCardCount == 0 then
		--MusicCenter:PlayWarnEffect()
		print("-----------------No Card! Please Pick Cards!----------------------")
		return
	end	

	local arrayMyData = ConvertTableToArray(myOutCardData, myOutCardCount)
	GameLogic:SortCardList(arrayMyData,myOutCardCount,ST_ORDER)
	local cardtype = GameLogic:GetCardType(arrayMyData, myOutCardCount)

	if cardtype == CT_ERROR then
		--MusicCenter:PlayWarnEffect()
		print("---------------------------ERROR TYPE------------------------------")
		self:showErrorTypeTips()
		return 
	end

    local prevCount = DataCenter:getPrevOutCardCount()
    local prevData = DataCenter:getPrevOutCardData()
    print("上家出牌:")
    dump(prevData)

	if not bFirstOut then
		local bBig = GameLogic:CompareCard(prevData, arrayMyData, prevCount, myOutCardCount)
		if not bBig then
			self:showErrorTypeTips()
			return 
		end
	end
	DataCenter:setIsDealOutCard(true)
	InternetManager:sendOutCard(arrayMyData, myOutCardCount)
end

function StatePlaying:onAddCard(event)
	-- body
end

function StatePlaying:onRemoveCard(event)
	-- body
end

function StatePlaying:RemoveOutCard()
	local myOutCardData = self.myHandCards_:getOutCardsData()
	local myOutCardCount = #myOutCardData
	local arrayMyData = ConvertTableToArray(myOutCardData, myOutCardCount)

	self.myHandCards_:removeCards()

	local selfCardData = DataCenter:getSelfHandCardData()
	local selfCardCount = DataCenter:getSelfHandCardCount()
	--dump("移除前手牌数据:")
	--dump(selfCardData)

	-- print("要出的牌:")
	-- dump(arrayMyData)
	print(GameLogic:RemoveCard(arrayMyData, myOutCardCount, selfCardData, selfCardCount))
	DataCenter:setSelfHandCardCount(myOutCardCount)
	--dump("移除后手牌数据:")
	--dump(selfCardData)
	self.myHandCards_:resetOutCardsData()

	--重置提示
	self.tipsTab_ = {}
	self.tipsIndex_ = -1
	self.m_nClickNum_ = 0
end

function StatePlaying:clearCurrentUserOutCard()
	-- body
	local current_user = DataCenter:getCurrentUser()
    local direction = GetDirection(current_user)

	if direction == eDown then
    	if self.downPlayerOutCards_ then
    		self.downPlayerOutCards_:removeSelf()
    		self.downPlayerOutCards_ = nil
    	end	
	elseif direction == eRight then
		if self.rightPlayerOutCards_ then
			self.rightPlayerOutCards_:removeSelf()
			self.rightPlayerOutCards_ = nil
		end
	elseif direction == eUp then
		if self.upPlayerOutCards_ then
			self.upPlayerOutCards_:removeSelf()
			self.upPlayerOutCards_ = nil
		end
	elseif direction == eLeft then
		if self.leftPlayerOutCards_ then
			self.leftPlayerOutCards_:removeSelf()
			self.leftPlayerOutCards_ = nil
		end		
	end
end

function StatePlaying:clearAllPlayerOutCard()
	-- body
	if self.downPlayerOutCards_ then
		self.downPlayerOutCards_:removeSelf()
		self.downPlayerOutCards_ = nil
	end 
	if self.rightPlayerOutCards_ then
		self.rightPlayerOutCards_:removeSelf()
		self.rightPlayerOutCards_ = nil
	end

	if self.upPlayerOutCards_ then
		self.upPlayerOutCards_:removeSelf()
		self.upPlayerOutCards_ = nil
	end

	if self.leftPlayerOutCards_ then
		self.leftPlayerOutCards_:removeSelf()
		self.leftPlayerOutCards_ = nil
	end
end

function StatePlaying:PlayPassCardEffect()
	local passUser = DataCenter:getPrevOperationUser()
	MusicCenter:PlayPassCardEffect(passUser)
end

function StatePlaying:PlayOutCardEffect()
	print("---------------------------StatePlaying:PlayOutCardEffect()-------------------------------------")
	local prevCount = DataCenter:getPrevOutCardCount()
    local prevData = DataCenter:getPrevOutCardData()
    local prevUser = DataCenter:getPrevOutUser()
    local direction = GetDirection(prevUser)

    local card_type = GameLogic:GetCardType(prevData, prevCount)
    GameLogic:typeDebug(card_type)
    print("card_type = " .. card_type)
    local value
    local cbGender = FGameDC:getDC():GetUserInfo(prevUser).cbGender
    print("性别:" .. cbGender)
	if card_type == CT_SINGLE or card_type == CT_DOUBLE then
		value = CardHelper:getCardValue(prevData[0])
		print("值:" .. value)
		MusicCenter:PlayOutCardEffect(cbGender, card_type, value)
	end
end

function StatePlaying:showOtherPlayerOutCard()
	--print("--------------StatePlaying:showOtherPlayerOutCard()-----------------")
	-- body
    local prevCount = DataCenter:getPrevOutCardCount()
    local prevData = DataCenter:getPrevOutCardData()
    local prevUser = DataCenter:getPrevOutUser()
    local direction = GetDirection(prevUser)

    local cbCardData = prevData--ConvertTableToArray(prevData, prevCount)
    local cbCardCount = prevCount

    print("上家出牌数:" .. cbCardCount)
    print("上家出牌数据:")
    dump(cbCardData)
    --print("上家出牌用户:" .. prevUser)
   	if prevUser == 255 then
   		return
   	end
   	local card_type = GameLogic:GetCardType(cbCardData, cbCardCount)
   	GameLogic:typeDebug(card_type)

	local angle = 0
	local scorePos = cc.p(0, 0)
    if direction == eDown then
    	if self.downPlayerOutCards_ then
    		self.downPlayerOutCards_:removeSelf()
    		self.downPlayerOutCards_ = nil
    	end
    	if cbCardCount == 0 then
    		return
    	end
    	--true 自身出牌不折叠
    	local b = true
    	self.downPlayerOutCards_ = ComboCards.new(cbCardData, cbCardCount, b)
    	self.downPlayerOutCards_:addTo(self)
    	if b then
			self.downPlayerOutCards_:align(display.CENTER, display.cx - (cbCardCount - 1) * self.myHandCards_.CARD_DISTANCE / 2 * 0.75, display.cy - 70)
		else
			self.downPlayerOutCards_:align(display.CENTER, display.cx - (9 - 1) * self.myHandCards_.CARD_DISTANCE / 2 * 0.75, display.cy - 70)
		end
		ActionHelper:OutCardAction(self.downPlayerOutCards_, 0.75)
		scorePos.x = display.cx - (cbCardCount - 1) * self.myHandCards_.CARD_DISTANCE / 2 * 0.75
		scorePos.y = display.cy + 20
		angle = 0
	elseif direction == eRight then
		if self.rightPlayerOutCards_ then
			self.rightPlayerOutCards_:removeSelf()
			self.rightPlayerOutCards_ = nil
		end
    	if cbCardCount == 0 then
    		return
    	end

		self.rightPlayerOutCards_ =  ComboCards.new(cbCardData, cbCardCount, false)
		self.rightPlayerOutCards_:addTo(self)
		--align(display.CENTER, display.cx + 350 - (cbCardCount - 1) * self.myHandCards_.CARD_DISTANCE * 0.75, display.cy + 100)
		self.rightPlayerOutCards_:align(display.CENTER, display.cx + 380 - (cbCardCount > 9 and 9 or cbCardCount - 1) * self.myHandCards_.CARD_DISTANCE * 0.75, display.cy - 10)
		ActionHelper:OutCardAction(self.rightPlayerOutCards_, 0.75)
		angle = -90
		scorePos.x = display.cx + 350 - (cbCardCount > 9 and 9 or cbCardCount - 1) * self.myHandCards_.CARD_DISTANCE * 0.75 * 0.5
		scorePos.y = display.cy + 220
	elseif direction == eUp then
		if self.upPlayerOutCards_ then
			self.upPlayerOutCards_:removeSelf()
		end
    	if cbCardCount == 0 then
    		return
    	end

		self.upPlayerOutCards_ =  ComboCards.new(cbCardData, cbCardCount, false)
		self.upPlayerOutCards_:addTo(self)
		self.upPlayerOutCards_:align(display.CENTER, display.cx + 380 - (cbCardCount > 9 and 9 or cbCardCount - 1) * self.myHandCards_.CARD_DISTANCE * 0.75, display.cy + 200)
		ActionHelper:OutCardAction(self.upPlayerOutCards_, 0.75)
		angle = 180
		scorePos.x = display.cx - 40
		scorePos.y = display.cy + 270
	elseif direction == eLeft then
		if self.leftPlayerOutCards_ then
			self.leftPlayerOutCards_:removeSelf()
			self.leftPlayerOutCards_ = nil
		end
    	if cbCardCount == 0 then
    		return
    	end

		self.leftPlayerOutCards_ =  ComboCards.new(cbCardData, cbCardCount, false)
		self.leftPlayerOutCards_:addTo(self)
		self.leftPlayerOutCards_:align(display.CENTER, display.cx - 380 , display.cy + 120)
		ActionHelper:OutCardAction(self.leftPlayerOutCards_, 0.75)
		angle = 90
		scorePos.x = display.cx - 350 + (cbCardCount > 9 and 9 or cbCardCount - 1) * self.myHandCards_.CARD_DISTANCE * 0.75 * 0.5
		scorePos.y = display.cy + 190
	end
end

function StatePlaying:ShowTrusteeshipBtn()
    local trusteeBtn = cc.ui.UIPushButton.new({normal = "ccbResources/50kRes/trusteeship/q_tuoguan_back.png", 
        pressed = "ccbResources/50kRes/trusteeship/q_tuoguan_back_p.png"})
    trusteeBtn:onButtonClicked(
    	function()
    		InternetManager:SetTrusteeship(true)
        end
    )
    trusteeBtn:addTo(self):align(display.CENTER, 270, 240)
end

function StatePlaying:StateEnd()    -- 结束该状态
	print("------------------- > Playing场景状态结束")
	self:DeleteScheduler(self.showAllCardHandle_)
    self:RemoveGameRes()
	UIManager:RemoveUI("UIIcon")
	UIManager:RemoveUI("UIHou")
	UIManager:RemoveUI("UIOutCard")
	UIManager:RemoveUI("UIOverCard")
	UIManager:RemoveUI("UICountDown")
	UIManager:RemoveUI("UITopInfo")
	UIManager:RemoveUI("UITrusteeship")

	self:removeSelf()
end
local function isPointIn( rc, pt )
    local rect = cc.rect(rc.x, rc.y, rc.width, rc.height)
    return cc.rectContainsPoint(rect, pt)
end

function StatePlaying:onTouch_( event )
	-- body
	--dump(event)
	if DataCenter:getIsDealOutCard() then
		return
	end
	if event.name == "began" then
		self.bMove_ = false
        self.selectCards_ = {}
        self.selectCardsNum_ = 0
		local view_list = self.myHandCards_:getCardsViewList()
		for i = #view_list, 1 , -1 do
			local view = self.myHandCards_:getCardsViewList()[i]
			local card_bg = view:getCardBg()

			if view:isContainPoint(ccp(event.x, event.y), i == #view_list) then
				--如果点击坐标在扑克范围内
	            if self.selectCards_[i] == nil then
	                self.selectCards_[i] = view
	                self.selectCards_[i]:SetClickedColor(true)
	                self.selectCardsNum_ = self.selectCardsNum_ + 1
	            end
			end
		end

		return true
	elseif event.name == "moved" then
		--print("moved")
		self.bMove_ = true
		local view_list = self.myHandCards_:getCardsViewList()
		for i = #view_list, 1 , -1 do
			local view = self.myHandCards_:getCardsViewList()[i]
			local card_bg = view:getCardBg()

			if view:isContainPoint(ccp(event.x, event.y), i == #view_list) then
				--如果点击坐标在扑克范围内
	            if self.selectCards_[i] == nil then
	                self.selectCards_[i] = view
	                self.selectCards_[i]:SetClickedColor(true)
	                self.selectCardsNum_ = self.selectCardsNum_ + 1
	            end
			end
		end
	elseif event.name == "ended" then
		if self.selectCardsNum_ > 0 then
			MusicCenter:PlayClickCardEffect()
		end

		for k, v in pairs(self.selectCards_) do
			v:onTouch_()
			v:SetClickedColor(false)
		end
		--dump(self.myHandCards_:getOutCardsData())
	end
end

function StatePlaying:PlayBaoCardSound()
	-- body
	local prevBaoCardUser = DataCenter:getPrevBaoCardUser()
	local cbGender = FGameDC:getDC():GetUserInfo(prevBaoCardUser).cbGender
	local bBaoCard = DataCenter:getUserBaoCardInfo()[prevBaoCardUser + 1]	--1 或者0
	MusicCenter:PlayBaoCardSound(cbGender, bBaoCard)
end

function StatePlaying:showKnifeAnimation(angle)
	-- body
	local angle = angle or 180
	if not self.KnifeNode_ then 
		self.KnifeNode_ = display.newNode()
		self.KnifeNode_:addTo(self):align(display.CENTER, display.cx, display.cy)
	end
	self.KnifeNode_:setRotation(angle)
	local sp = display.newSprite("#knife_01.png", 0, 0)
	sp:addTo(self.KnifeNode_)
	local frames = display.newFrames("knife_%02d.png", 1, 5)
	local animation = display.newAnimation(frames, 0.5/5)
	sp:playAnimationOnce(animation, true)
	-- sp:playAnimationForever(animation)
end

function StatePlaying:showHandShake()
	-- body
	if not self.HandShakeNode_ then
		self.HandShakeNode_ = display.newNode()
		self.HandShakeNode_:addTo(self):align(display.CENTER, display.cx, display.cy + 30)
	end

	local sp = display.newSprite("#handshake_01.png", 0, 0)
	sp:addTo(self.HandShakeNode_)
	local frames = display.newFrames("handshake_%02d.png", 1, 3)
	local animation = display.newAnimation(frames, 0.2)
	--sp:playAnimationForever(animation)
	sp:playAnimationOnce(animation, false, function ()
		-- body
		local sequence = transition.sequence({
		    cc.MoveTo:create(0.2, cc.p(display.cx, display.cy + 10)),
		    cc.MoveTo:create(0.2, cc.p(display.cx, display.cy - 10)),
		    cc.DelayTime:create(0.3),
			cc.CallFunc:create(function()
            	sp:removeSelf()
    		end)
		})

		self.HandShakeNode_:runAction(sequence)
	end)
end

function StatePlaying:showWarnAnimation(direction)
	-- body
	if not self.warnAnimationTab_[direction] then
		local node = display.newNode()
		node:addTo(self):align(display.CENTER, self.warnPosTab_[direction].x, self.warnPosTab_[direction].y)
		local light = display.newSprite("ccbResources/50kRes/animation/jingbaoq.png")
		light:addTo(node):align(display.CENTER, 0, 0)
		local sp = display.newSprite("#light_00.png", 0, 0)
		sp:addTo(node):align(display.CENTER, 0, 0)
		local frames = display.newFrames("light_%02d.png", 0, 11)
		local animation = display.newAnimation(frames, 0.05)
		sp:playAnimationForever(animation)
		self.warnAnimationTab_[direction] = node
	end
end

--显示要不起提示
function StatePlaying:showYaoBuQiTips()
	-- body
	--dump(self.bInYaoBuQiAni_)
	if self.bInYaoBuQiAni_ then
		return 
	end
	self.bInYaoBuQiAni_ = true
	if not self.yaobuqiTips_ then
		self.yaobuqiTips_ = display.newSprite("ccbResources/50kRes/out_card/yaobuqi.png")
		self.yaobuqiTips_:addTo(self):align(display.CENTER, display.cx, 60)		
	end
	self.yaobuqiTips_:setOpacity(255)
	local sequence = transition.sequence({
		--cc.FadeIn:create(0.2),
		cc.DelayTime:create(0.5),
		cc.FadeOut:create(1),
		cc.CallFunc:create(function()
        	self.bInYaoBuQiAni_ = false
		end)		
		})
	self.yaobuqiTips_:runAction(sequence)
end

function StatePlaying:showErrorTypeTips()
	-- body
	--dump(self.bInErrorTypeAni_)
	if self.bInErrorTypeAni_ then
		return 
	end
	self.bInErrorTypeAni_ = true
	if not self.errorTypeTips_ then
		self.errorTypeTips_ = display.newSprite("ccbResources/50kRes/out_card/error_type_tips.png")
		self.errorTypeTips_:addTo(self):align(display.CENTER, display.cx, 80)		
	end
	self.errorTypeTips_:setOpacity(255)
	local sequence = transition.sequence({
		--cc.FadeIn:create(0.2),
		cc.DelayTime:create(0.5),
		cc.FadeOut:create(1),
		cc.CallFunc:create(function()
        	self.bInErrorTypeAni_ = false
		end)		
		})
	self.errorTypeTips_:runAction(sequence)
end


--播放飞机Gaf 0 下 1 右 2 上 3 左
function StatePlaying:showPlaneGaf(direction)
	-- body
	local gaf_path = ""
	local FlashSprite = require("script.public.FlashSprite")
	local f
	if direction == eDown then
		gaf_path = "ccbResources/50kRes/animation/feijixia/feijixia.gaf"
		if not self.gafPlaneDown_ then
			self.gafPlaneDown_ = FlashSprite.new(gaf_path)
			self.gafPlaneDown_:addTo(self)
		end
		f = self.gafPlaneDown_
	elseif direction == eRight then
		--todo
		gaf_path = "ccbResources/50kRes/animation/feijiyou/feijiyou.gaf"
		if not self.gafPlaneRight_ then
			self.gafPlaneRight_ = FlashSprite.new(gaf_path)
			self.gafPlaneRight_:addTo(self)
		end
		f = self.gafPlaneRight_
	elseif direction == eUp then
		--todo
		gaf_path = "ccbResources/50kRes/animation/feijishang/feijishang.gaf"
		if not self.gafPlaneUp_ then
			self.gafPlaneUp_ = FlashSprite.new(gaf_path)
			self.gafPlaneUp_:addTo(self)
		end
		f = self.gafPlaneUp_
	elseif direction == eLeft then
		--todo
		gaf_path = "ccbResources/50kRes/animation/feijizuo/feijizuo.gaf"
		if not self.gafPlaneLeft_ then
			self.gafPlaneLeft_ = FlashSprite.new(gaf_path)
			self.gafPlaneLeft_:addTo(self)
		end
		f = self.gafPlaneLeft_
	else
		return 
	end
	f:setVisible(true)
	f:setPos(display.cx, display.cy)
	f:start()
	f:setAnimationFinishedPlayDelegate(function()
		-- body
		f:setVisible(false)
	end)
end

function StatePlaying:showBombGaf(direction)
	-- body
	local gaf_path = ""
	local FlashSprite = require("script.public.FlashSprite")
	local f
	if direction == eDown then
		gaf_path = "ccbResources/50kRes/animation/zhadanxia/zhadanxia.gaf"
		if not self.gafBombDown_ then
			self.gafBombDown_ = FlashSprite.new(gaf_path)
			self.gafBombDown_:addTo(self)
		end
		f = self.gafBombDown_
	elseif direction == eRight then
		--todo
		gaf_path = "ccbResources/50kRes/animation/zhadanyou/zhadanyou.gaf"
		if not self.gafBombRight_ then
			self.gafBombRight_ = FlashSprite.new(gaf_path)
			self.gafBombRight_:addTo(self)
		end
		f = self.gafBombRight_
	elseif direction == eUp then
		--todo
		gaf_path = "ccbResources/50kRes/animation/zhadanshang/zhadanshang.gaf"
		if not self.gafBombUp_ then
			self.gafBombUp_ = FlashSprite.new(gaf_path)
			self.gafBombUp_:addTo(self)
		end
		f = self.gafBombUp_
	elseif direction == eLeft then
		--todo
		gaf_path = "ccbResources/50kRes/animation/zhadanzuo/zhadanzuo.gaf"
		if not self.gafBombLeft_ then
			self.gafBombLeft_ = FlashSprite.new(gaf_path)
			self.gafBombLeft_:addTo(self)
		end
		f = self.gafBombLeft_
	else
		return 
	end
	f:setVisible(true)
	f:setPos(display.cx, display.cy)
	f:start()
	f:setAnimationFinishedPlayDelegate(function()
		-- body
		f:setVisible(false)
	end)
end

function StatePlaying:showSingleStraightGaf()
	-- body
	local gaf_path = "ccbResources/50kRes/animation/shunziswf/shunziswf.gaf"
	local FlashSprite = require("script.public.FlashSprite")
	if not self.gafSingleNode_ then
		self.gafSingleNode_ = display.newNode()
		self.gafSingleNode_:addTo(self):align(display.CENTER, display.cx, display.cy)
		self.aniSingleStraightNode_ = FlashSprite.new(gaf_path)
		self.aniSingleStraightNode_:addTo(self.gafSingleNode_)
	end
	--self.gafSingleNode_:setRotation(90)
	self.aniSingleStraightNode_:setVisible(true)
	self.aniSingleStraightNode_:setPos(-50, 0)
	self.aniSingleStraightNode_:start()
	self.aniSingleStraightNode_:setAnimationFinishedPlayDelegate(function()
		-- body
		self.aniSingleStraightNode_:setVisible(false)
	end)
end

function StatePlaying:showPairStraightGaf()
	-- body
	local gaf_path = "ccbResources/50kRes/animation/liandui/liandui.gaf"
	local FlashSprite = require("script.public.FlashSprite")
	if not self.gafPairNode_ then
		self.gafPairNode_ = display.newNode()
		self.gafPairNode_:addTo(self):align(display.CENTER, display.cx, display.cy)
		self.aniPairStraightNode_ = FlashSprite.new(gaf_path)
		self.aniPairStraightNode_:addTo(self.gafPairNode_)
	end
	--self.gafPairNode_:setRotation(90)
	self.aniPairStraightNode_:setVisible(true)
	self.aniPairStraightNode_:setPos(0, 0)
	self.aniPairStraightNode_:start()
	self.aniPairStraightNode_:setAnimationFinishedPlayDelegate(function()
		-- body
		self.aniPairStraightNode_:setVisible(false)
	end)
end

function StatePlaying:showAllPlayerCards()
	-- body
	self:clearAllPlayerOutCard()
	self.layer_ = display.newColorLayer(ccc4(0, 0, 0, 0))
    --layer:setContentSize(display.width, display.height)
    self.layer_:addTo(GameScene)
    self.layer_:setLocalZOrder(100)
    local players_cards = DataCenter:getAllPlayerHandCardData()
    local players_cards_count = DataCenter:getAllPlayerHandCardCount()
    local pos = {
    	[eDown]	 = cc.p(display.cx, display.cy - 130),
    	[eRight] = cc.p(display.cx + 300, display.cy + 50),
    	[eUp]	 = cc.p(display.cx, display.cy + 150),
    	[eLeft]	 = cc.p(display.cx - 300, display.cy + 50),
	}

	local angle = {
		[eDown] = 0,
		[eRight] = -90,
		[eUp] = 0,
		[eLeft] = 90,
	}
    for i = 1, GAME_PLAYER do
    	local cbCardData = players_cards[i] 	--players_cards[i]			--testCards
    	local cbCardCount = players_cards_count[i] 	--players_cards_count[i]	--#testCards
    	local direction = GetDirection(i - 1)			--GetDirection(i - 1)		--i - 1
    	--dump(direction)
    	local show_cards = ShowCards.new(cbCardData, cbCardCount, direction == eDown)
    	show_cards:addTo(self)
    	if direction == eDown then
    		show_cards:align(display.CENTER, display.cx - (cbCardCount - 1) * show_cards.CARD_DISTANCE / 2 * 0.75, display.cy - 80)
    	elseif direction == eRight then
    		show_cards:align(display.CENTER, display.cx + 350 - (cbCardCount > 9 and 9 or cbCardCount - 1) * show_cards.CARD_DISTANCE * 0.75, display.cy + 100)
    	elseif direction == eUp then
    		show_cards:align(display.CENTER, display.cx - 40, display.cy + 270)
		elseif direction == eLeft then
    		--todo
    		show_cards:align(display.CENTER, display.cx - 350 , display.cy + 100)
    	end

    end
end

function StatePlaying:removeAllPlayerCards()
	-- body
	if self.layer_ then
		self.layer_:removeSelf()
	end
end

function StatePlaying:showCardScoreAction(scoreNum, pos)
	-- body

	local node = display.newNode()
	--node:setContentSize(display.width, display.height)
	node:addTo(self):align(display.CENTER, pos.x, pos.y)
	node:setScale(0.5)
	node:opacity(0)
	local sp = display.newSprite("#star_01.png", 0, 0)
	sp:addTo(node)
	local frames = display.newFrames("star_%02d.png", 1, 11)
	local animation = display.newAnimation(frames, 0.5/11)
	sp:playAnimationOnce(animation, true)
	--sp:playAnimationForever(animation)
	local pngPath = "ccbResources/50kRes/base/merge_show.png"
	local textOption = {stringValue = tostring("/" .. math.abs(scoreNum or 0)), path = pngPath, itemWidth = 26, itemHeight = 34, startCharMap = '/'}
	local scoreText = self:createLabelAtlas(textOption)
	scoreText:addTo(node):align(display.CENTER, 0, 0)

	local score_num_node = UIManager:GetUI("UIBackground"):getRoundScoreNode()
	local sequence = transition.sequence({
		cc.FadeIn:create(0.2),
		cc.ScaleTo:create(0.1, 1.1),
		cc.DelayTime:create(0.2),
		cc.EaseSineIn:create(cc.MoveTo:create(0.2, cc.p(score_num_node:getPositionX(), score_num_node:getPositionY()))),
		cc.DelayTime:create(0.1),
		cc.ScaleTo:create(0.1, 0.7),
		cc.ScaleTo:create(0.1, 0.5),
		cc.CallFunc:create(function()
        	node:removeSelf()
        	UIManager:UpdateUI("UIBackground")
		end)
		-- cc.Spawn:create(cc.ScaleTo:create(0.5, 1.3), cc.ScaleTo:create(0.5, 1),	cc.CallFunc:create(function()
  --       	node:removeSelf()
		-- end))
		})
	node:runAction(sequence)	
end

function StatePlaying:showBaoCardAction()
	-- body
	--不是包牌模式 则退出
	if DataCenter:getGameType() ~= 1 then
		return 
	end
	local sp = display.newSprite("#baoo.png")
	sp:addTo(self):align(display.CENTER, display.cx, display.cy)
	sp:setScale(1.5)
	sp:opacity(0)
	local pos = UIManager:GetUI("UIIcon"):getCurBaoUserPos(self)
	local sequence = transition.sequence({
		cc.FadeIn:create(0.2),
		cc.DelayTime:create(0.2),
		cc.EaseSineIn:create(cc.MoveTo:create(0.2, cc.p(pos.x, pos.y))),
		cc.DelayTime:create(0.1),
		cc.ScaleTo:create(0.1, 2),
		cc.ScaleTo:create(0.1, 1),
		cc.CallFunc:create(function()
        	sp:removeSelf()
        	UIManager:GetUI("UIIcon"):showBaoGaf()
		end)
		-- cc.Spawn:create(cc.ScaleTo:create(0.5, 1.3), cc.ScaleTo:create(0.5, 1),	cc.CallFunc:create(function()
  --       	node:removeSelf()
		-- end))
		})
	sp:runAction(sequence)
end

function StatePlaying:showCallCardAction()
	-- body
	--不是叫牌模式 则退出
	if DataCenter:getGameType() ~= 0 then
		return 
	end
	print("------------------------------showCallCardAction---------------------------------")
    local show_cards_data = DataCenter:getShowCardsData()
    local show_cards_num = #show_cards_data
	local card = CardView.new(show_cards_data[show_cards_num])
	card:addTo(self):align(display.CENTER, display.cx, display.cy)
	card:opacity(0)
	local desNode = UIManager:GetUI("UITopInfo"):getSmallCardNode()
	local pos = cc.p(desNode:getPositionX(), desNode:getPositionY())
	local sequence = transition.sequence({
		cc.FadeIn:create(0.2),
		cc.DelayTime:create(0.2),
		cc.Spawn:create(cc.MoveTo:create(0.2, cc.p(pos.x, pos.y)), cc.ScaleTo:create(0.2, 0.5)),
		cc.DelayTime:create(0.2),
		cc.ScaleTo:create(0.2, 0.7),
		cc.CallFunc:create(function()
        	card:removeSelf()
		end)
		-- cc.Spawn:create(cc.ScaleTo:create(0.5, 1.3), cc.ScaleTo:create(0.5, 1),	cc.CallFunc:create(function()
  		--		node:removeSelf()
		-- end))
		})
	card:runAction(sequence)	
end


function StatePlaying:createLabelAtlas(options)
	local labelAtlas
	if "function" == type(cc.LabelAtlas._create) then
		labelAtlas = cc.LabelAtlas:_create()
		labelAtlas:initWithString(options.stringValue,
			options.path,
			options.itemWidth,
			options.itemHeight,
			string.byte(options.startCharMap))
	else
		labelAtlas = cc.LabelAtlas:create(
			options.stringValue,
			options.path,
			options.itemWidth,
			options.itemHeight,
			string.byte(options.startCharMap))
	end

	labelAtlas:setAnchorPoint(
		cc.p(options.anchorPointX or 0.5, options.anchorPointY or 0.5))
	-- labelAtlas:setPosition(options.x, options.y)
	-- if not options.ignoreSize then
	-- 	labelAtlas:setContentSize(options.width, options.height)
	-- end
	return labelAtlas
end

return StatePlaying