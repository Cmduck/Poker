module(..., package.seeall) 

--------------------------------------------------------------------------
-- 状态--等待开始
--------------------------------------------------------------------------
local EventProxyEx = require("script.fightbombScript.common.EventProxyEx")
local HandCards    = require("script.fightbombScript.card.HandCards")
local ComboCards   = require("script.fightbombScript.card.ComboCards")
local ShowCards    = require("script.fightbombScript.card.ShowCards")
local CardView     = require("script.fightbombScript.card.CardView")
local StateBase    = require("script.fightbombScript.state.StateBase")
local CardHelper   = require("script.fightbombScript.card.CardHelper")
local scheduler    = require(cc.PACKAGE_NAME .. ".scheduler")
local GafHelper = require("script.fightbombScript.common.GafHelper")
local ActionHelper = require("script.fightbombScript.common.ActionHelper")
local StatePlaying = class("StatePlaying", StateBase)

StatePlaying.GAME_RES = {
	Card = {
		plist = "ccbResources/fightbombRes/card/card.plist",
		png   = "ccbResources/fightbombRes/card/card.png"
	},
	--警报灯
	WarnAnimation = {	
		plist = "ccbResources/fightbombRes/animation/warn_animation.plist",
		png = "ccbResources/fightbombRes/animation/warn_animation.png"
	},
	SmallCard = {
	    plist = "ccbResources/fightbombRes/card_small/card_small.plist",
	    png   = "ccbResources/fightbombRes/card_small/card_small.png"
	},
	Handshake = {
		plist = "ccbResources/fightbombRes/animation/handshake_animation.plist",
		png = "ccbResources/fightbombRes/animation/handshake_animation.png"
	},
}
function StatePlaying:ctor(scene)
	StatePlaying.super.ctor(self, scene)

 --    self:setContentSize(display.width, display.height)
	-- self:setTouchEnabled(true)
	-- self:setTouchSwallowEnabled(false)
	-- --注册触摸事件
 --    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch_))
	self.m_nClickNum_       = 0
	self.selectCards_       = {}

	self.tipsIndex_         = -1
	self.tipsTab_           = {}

	self.tips50KIndex_ 		= -1
	self.tips50KTab_		= {}

	self.bWarnAnimationStatus_ = {false, false, false}
	self.warnLabelTab_ = {}

	self.bInCallCardAction_ = false
end

function StatePlaying:StateBegin()  -- 开始该状态

	self:PlayStartMusic()
	--创建手牌
	self:ShowHandCards()
	--self:ShowUserChairID()
	--self:showAllPlayerCards()--test
end

function StatePlaying:ShowUserChairID()
	local str = DataCenter:getSelfChairID()
	local label = display.newTTFLabel({
        text = tostring(str),
        font = "Arial",
        size = 36,
        color = cc.c3b(255, 0, 0), 
        align = cc.ui.TEXT_ALIGN_LEFT,
        valign = cc.ui.TEXT_VALIGN_TOP,
        dimensions = cc.size(36, 36)
    })
    label:align(display.CENTER, display.cx, display.cy + 100):addTo(self)
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
	self.myHandCards_:align(display.CENTER, display.cx, 170)
	-- EventProxyEx.new(self.myHandCards_, self):addEventListener(self.myHandCards_.class.ADD_CARD_EVENT, handler(self, self.onAddCard))
	-- EventProxyEx.new(self.myHandCards_, self):addEventListener(self.myHandCards_.class.REMOVE_CARD_EVENT, handler(self, self.onRemoveCard))
	local hand_card_data = DataCenter:getSelfHandCardData()
	local hand_card_count = DataCenter:getSelfHandCardCount()

	self.myHandCards_:createCards(hand_card_data, hand_card_count)--self.myHandCards_:createCards(testLeftCards) DataCenter:getMyHandCards()
	-- self.myHandCards_:InsertCard(0x24)
end

function StatePlaying:LoadUIComponent()
	-- body
	UIManager:ShowUI("UIBaoCard")
	UIManager:ShowUI("UICallCard")
	UIManager:ShowUI("UIOutCard")
	UIManager:ShowUI("UICountDown")
	UIManager:ShowUI("UIOverCard")
	--UIManager:ShowUI("UITrusteeship")
	UIManager:ShowUI("UIDismiss")
end

function StatePlaying:RegisterUIEvent()
	-- body
	local UIBackground = UIManager:GetUI("UIBackground")
	EventProxyEx.new(UIBackground, self)
		:addEventListener(UIBackground.class.CLICK_50K_BTN_EVENT, handler(self, self.on50KBtnClicked))
		:addEventListener(UIBackground.class.CLICK_SORT_BTN_EVENT, handler(self, self.onSortBtnClicked))	

	local UIBaoCard = UIManager:GetUI("UIBaoCard")
	EventProxyEx.new(UIBaoCard, self)
		:addEventListener(UIBaoCard.class.CLICK_BAO_CARD_BTN_EVENT, handler(self, self.onBaoCardClicked))
		:addEventListener(UIBaoCard.class.CLICK_BU_BAO_CARD_BTN_EVENT, handler(self, self.onBuBaoClicked))

	local UICallCard = UIManager:GetUI("UICallCard")
	EventProxyEx.new(UICallCard, self)
		:addEventListener(UICallCard.class.CLICK_CALL_CARD_BTN_EVENT, handler(self, self.onCallCardClicked))

	local UIOutCard = UIManager:GetUI("UIOutCard")
	EventProxyEx.new(UIOutCard, self)
		:addEventListener(UIOutCard.class.CLICK_TI_SHI_BTN_EVENT, handler(self, self.onTiShiClicked))
		:addEventListener(UIOutCard.class.CLICK_CHU_PAI_BTN_EVENT, handler(self, self.onChuPaiClicked))
		:addEventListener(UIOutCard.class.CLICK_BU_CHU_BTN_EVENT, handler(self, self.onBuChuClicked))
end

function StatePlaying:on50KBtnClicked()
	MusicCenter:PlayBtnEffect()
    self.myHandCards_:RearrangeHandCardsBy50K()
end

function StatePlaying:onSortBtnClicked()
	MusicCenter:PlayBtnEffect()
	self.myHandCards_:RearrangeHandCardsByOrder()
end

function StatePlaying:BindEvent()
	print("================ StatePlaying:BindEvent() =============")
	--游戏事件
    EventProxyEx.new(DataCenter, self)
    	:addEventListener(DataCenter.class.MSG_BAO_CARD_EVENT, handler(self, self.onNetMsgBaoCard_))
    	:addEventListener(DataCenter.class.MSG_BAO_CARD_END_EVENT, handler(self, self.onNetBaoCardEnd_))
    	:addEventListener(DataCenter.class.MSG_CALL_CARD_EVENT, handler(self, self.onNetMsgCallCard_))
    	:addEventListener(DataCenter.class.MSG_OUT_JIAO_CARD_EVENT, handler(self, self.onNetMsgOutJiaoCard_))
        :addEventListener(DataCenter.class.MSG_OUT_CARD_START_EVENT, handler(self, self.onNetMsgOutCardStart_))
        :addEventListener(DataCenter.class.MSG_OUT_CARD_END_EVENT, handler(self, self.onNetMsgOutCardEnd_))
        :addEventListener(DataCenter.class.MSG_OVER_CARD_EVENT, handler(self, self.onNetMsgOverCard_))
        :addEventListener(DataCenter.class.MSG_PASS_CARD_EVENT, handler(self, self.onNetMsgPassCard_))
        :addEventListener(DataCenter.class.MSG_CUR_TURN_OVER_EVENT, handler(self, self.onNetMsgCurTurnOver_))
    	:addEventListener(DataCenter.class.MSG_GAME_END_EVENT, handler(self, self.onNetMsgGameEnd_))
    	:addEventListener(DataCenter.class.MSG_REQUEST_LEAVE_EVENT, handler(self, self.onNetRequestLeave_))
    	:addEventListener(DataCenter.class.MSG_DISMISS_RESULT_EVENT, handler(self, self.onNetDismissResult_))
    	:addEventListener(DataCenter.class.MSG_TOTAL_ACCOUNT_EVENT, handler(self, self.onNetTotalAccount_))
    	:addEventListener(DataCenter.class.SYSTEM_G_USER_TRUSTEESHIP, handler(self, self.onNetSysMsgTrusteeship_))
end

--包牌
function StatePlaying:onNetMsgBaoCard_(event)
	UIManager:UpdateUI("UIBaoCard")
	UIManager:UpdateUI("UICountDown")
	local user = DataCenter:getPrevOperationUser()
	local cbGender = FGameDC:getDC():GetUserInfo(user).cbGender
	MusicCenter:PlayBaoCardSound(cbGender, 0)
end
--包牌结束
function StatePlaying:onNetBaoCardEnd_(event)
	-- body
	--检测包牌玩家是否为255 如果255 则显示叫牌按钮
	UIManager:RemoveUI("UIBaoCard")
	UIManager:UpdateUI("UICallCard")
	UIManager:UpdateUI("UIOutCard")
	UIManager:UpdateUI("UICountDown")
	UIManager:UpdateUI("UIBackground")
	UIManager:UpdateUI("UITopInfo")

	if DataCenter:getGameModel() == GAME_MODEL_BAO then
		GafHelper:PlayGaf(self, "_BaoPai", cc.p(display.cx, display.cy + 120))
		local user = DataCenter:getCurrentUser()
		local cbGender = FGameDC:getDC():GetUserInfo(user).cbGender
		MusicCenter:PlayBaoCardSound(cbGender, 1)
	end
end
--叫牌
function StatePlaying:onNetMsgCallCard_(event)
	-- body
	--显示叫牌在中间 显示叫牌动画 飞到UITopInfo 更新UITopInfo
	DataCenter:setIsDealUserOperation(false)
	UIManager:RemoveUI("UICallCard")
	UIManager:HideUI("UICountDown")
	UIManager:HideUI("UIOutCard")
	self:showCallCardAction()
end

--打出叫牌
function StatePlaying:onNetMsgOutJiaoCard_(event)
	UIManager:UpdateUI("UIIcon")
	UIManager:UpdateUI("UIBackground")

	ActionHelper:ShowHandShake(self, cc.p(display.cx, display.cy + 120))
	MusicCenter:PlayFindFriend()
end

function StatePlaying:onNetMsgCurTurnOver_(event) 
	UIManager:UpdateUI("UIIcon")
	UIManager:UpdateUI("UIBackground")
	self:clearAllPlayerOutCard()

	if DataCenter:getSelfChairID() == DataCenter:getCurTurnWinner() then
		if DataCenter:getCurXiScore()  ~= 0 then
			GafHelper:PlayGaf(self, "_ShouQian", cc.p(display.cx, display.cy + 120))
		elseif DataCenter:getCurTurnScore() ~= 0 then
			GafHelper:PlayGaf(self, "_ZhuaFen", cc.p(display.cx, display.cy + 120))
		end
	end

	DataCenter:setCurTurnScore(0)
	DataCenter:setCurXiScore(0)
end

function StatePlaying:onNetMsgOutCardStart_(event)
	self:clearCurrentUserOutCard()
	if not self.bInCallCardAction_ then
		UIManager:UpdateUI("UIOutCard")
		UIManager:UpdateUI("UICountDown")
	end
	if DataCenter:getCurrentUser() == DataCenter:getSelfChairID() then
		print("重置用户网络操作!")
		if DataCenter:getIsDealUserOperation() then DataCenter:setIsDealUserOperation(false) end
	end
	-- UIManager:GetUI("UIBackground"):UpdateTips()
end

function StatePlaying:onNetMsgOutCardEnd_(event)
	--删除出牌
	if DataCenter:getPrevOutUser() == DataCenter:getSelfChairID() then
		if DataCenter:getMyTrusteeshipStatus() then
			print("===================托管代打======================")
			local cardData = DataCenter:getPrevOutCardData()
			local cardCount = DataCenter:getPrevOutCardCount()
			local t = {}
			t[0] = cardData
			self:RemoveCards(t, cardCount)
		else
			print("===================普通出牌======================")
			self:RemoveOutCard()
		end
	end

	UIManager:UpdateUI("UIBackground")
	UIManager:UpdateUI("UIIcon")

	local cbTurnCardCount = DataCenter:getPrevOutCardCount()
    local cbTurnCardData = DataCenter:getPrevOutCardData()
    local cbTurnCardUser = DataCenter:getPrevOutUser()
    local bTurnLast = DataCenter:getHandCardCountTab()[cbTurnCardUser + 1] == 0

    print("出牌数目 = ", cbTurnCardCount)
    dump(cbTurnCardData, "出牌数据")
    print("出牌用户 = ", cbTurnCardUser)
    print("是否最后一手 = ", bTurnLast)
	self:showOtherPlayerOutCard(cbTurnCardData, cbTurnCardCount, cbTurnCardUser, bTurnLast)
	self:PlayOutCardEffect(cbTurnCardData, cbTurnCardCount, cbTurnCardUser, bTurnLast)

	if DataCenter:getHandCardCountTab()[cbTurnCardUser + 1] == 1 then
		GafHelper:PlayGaf(self, "_ShengYu", cc.p(display.cx, display.cy + 120))
		local cbGender = FGameDC:getDC():GetUserInfo(cbTurnCardUser).cbGender
		MusicCenter:PlayBaoDanSound(cbGender)
	end
	--添加分牌

	--dump(cbTurnCardData)
	for i = 0, cbTurnCardCount - 1 do
		local card_value = CardHelper:getCardValue(cbTurnCardData[i])
		if card_value == 0x0D or card_value == 0x0A or card_value == 0x05 then
			DataCenter:addScoreCardData(cbTurnCardData[i])
		end
	end
end

function StatePlaying:onNetMsgOverCard_(event)
	UIManager:UpdateUI("UIOverCard")
end

function StatePlaying:onNetMsgPassCard_(event)
	--UIManager:GetUI("UIOutCard"):ShowPassCard()
	self:PlayPassCardEffect()
end

function StatePlaying:onNetMsgGameEnd_(event)
	self:PlayEndMusic()
    UIManager:HideUI("UIOutCard")
    UIManager:HideUI("UICountDown")
	self:DeleteScheduler(self.delayShowClearHandle_)
	self:DeleteScheduler(self.delayClearCardHandle_)

	self.delayClearCardHandle_ = scheduler.performWithDelayGlobal(function()
            -- body
            self:showAllPlayerCards()
    end, 1)

    self.delayShowClearHandle_ = scheduler.performWithDelayGlobal(function()
            -- body
            StateManager:SetState(GAME_STATE_CLEARING)
    end, 4)
end

function StatePlaying:onNetRequestLeave_()
	UIManager:UpdateUI("UIDismiss", 0)
end

function StatePlaying:onNetDismissResult_()
	UIManager:UpdateUI("UIDismiss", 2, DataCenter:getDismissResult())
end

function StatePlaying:onNetTotalAccount_()
	if DataCenter:getServerType() == GAME_GENRE_SCORE and DataCenter:getDismissResult() then
		UIManager:RemoveUI("UIDismiss")
		--游戏解散
		if DataCenter:getGameEndType() == 1 then
			UIManager:ShowUI("UITotalClear")
		end
	end
end

function StatePlaying:onNetSysMsgTrusteeship_(event)
	UIManager:UpdateUI("UIIcon")
	--UIManager:UpdateUI("UITrusteeship")
end

function StatePlaying:DeleteScheduler(handle)
    if handle then
        scheduler.unscheduleGlobal(handle)
        handle = nil        
    end
end

function StatePlaying:onBaoCardClicked(event)
	MusicCenter:PlayBtnEffect()
	InternetManager:sendBaoCard(true)
end

function StatePlaying:onBuBaoClicked(event)
	MusicCenter:PlayBtnEffect()
	InternetManager:sendBaoCard(false)
end

function StatePlaying:onCallCardClicked(event)
	MusicCenter:PlayBtnEffect()
	local data = self.myHandCards_:getOutCardsData()

	--判断叫牌个数
	if #data == 0 then
		print("请选择叫牌！！！")
		ActionHelper:ShowCallCardErrorTips(self, cc.p(display.cx, 120))
		return
	elseif #data > 1 then
		print("只能选择一张叫牌!!!")
		ActionHelper:ShowCallCardErrorTips(self, cc.p(display.cx, 120))
		return 
	end

	--判断叫牌是否有效
	local selfCardData = self.myHandCards_:getHandCardsData()
	local selfCardCount = self.myHandCards_:getHandCardsCount()
	if not GameLogic:IsValidCallCard(selfCardData, selfCardCount, data[1]) then
		print("叫牌不合理!!!")
		ActionHelper:ShowCallCardErrorTips(self, cc.p(display.cx, 120))
		return 
	end
	DataCenter:setIsDealUserOperation(true)
	InternetManager:sendCallCard(data)
	self:resetOutCards()
end

function StatePlaying:onCallScoreClicked(event)
	-- body
	MusicCenter:PlayBtnEffect()
	InternetManager:sendCallScore(event.target:getScoreIndex())
end

function StatePlaying:onSelectMainClicked(event)
	MusicCenter:PlayBtnEffect()
	InternetManager:sendSelectMain(event.target:getColorIndex())
end

function StatePlaying:onBuChuClicked( event )
	-- body
	if not event.tishi then
		MusicCenter:PlayBtnEffect()
	end

	if DataCenter:getIsDealUserOperation() then
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

	DataCenter:setIsDealUserOperation(true)
	InternetManager:sendPassCard()
end

function StatePlaying:onTiShiClicked( event )
	MusicCenter:PlayBtnEffect()
	if DataCenter:getIsDealUserOperation() then
		print("################正在处理出牌或pass操作#############")
		return
	end
	self:resetOutCards()

	-- local bFirstOut = DataCenter:getIsFirstOutCard()
	-- if bFirstOut then
	-- 	print("首出牌，不提示！")
	-- 	return
	-- end
	print("self.tipsIndex_ = " .. self.tipsIndex_)
	--还未搜索提示
	if self.tipsIndex_ == -1 then
		local cbHandCardData = self.myHandCards_:getHandCardsData()
		local cbHandCardCount = self.myHandCards_:getHandCardsCount()

		local cbTurnCardData = DataCenter:getPrevOutCardData()
		local cbTurnCardCount = DataCenter:getPrevOutCardCount()
		local cbTurnCardUser = DataCenter:getPrevOutUser()
		local bTurnLast = DataCenter:getHandCardCountTab()[cbTurnCardUser + 1] == 0

		self.tipsTab_ = GameLogic:GetOutCardTip(cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount, bTurnLast)
		dump(self.tipsTab_, "所有提示")
		--没有找到提示
		if not self.tipsTab_ or #self.tipsTab_ == 0 then
			print("手上没有能大于上家的牌!")
			ActionHelper:ShowYaoBuQiTips(self, cc.p(display.cx, 120))
			local autoClickEvent = {tishi = true}
			self:onBuChuClicked(autoClickEvent)
			return
		end

		self.tipsIndex_ = 0
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
	self:resetOutCards()
	local view_list = self.myHandCards_:getCardsViewList()
	local myAllCardsData = self.myHandCards_:getHandCardsData()
	local myAllCardsCount= self.myHandCards_:getHandCardsCount()
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

	-- MusicCenter:PlayOutCardEffect(2, CT_SINGLE, 14)
	-- do return end 
	if DataCenter:getIsDealUserOperation() then
		print("################正在处理出牌#############")
		return
	end

	print("-----------------StatePlaying:onChuPaiClicked-----------------------")

	local bFirstOut = DataCenter:getIsFirstOutCard()
	local myOutCardData = self.myHandCards_:getOutCardsData()
	local cbCardCount = #myOutCardData
	local cbCardData = ConvertTableToArray(myOutCardData, cbCardCount)
	local bCardLast = DataCenter:getSelfHandCardCount() == cbCardCount
	GameLogic:SortCardList(cbCardData,cbCardCount,ST_ORDER)

	if cbCardData == nil or cbCardCount == 0 then
		MusicCenter:PlayWarnEffect()
		ActionHelper:ShowErrorTypeTips(self, cc.p(display.cx, 120))
		print("-----------------No Card! Please Pick Cards!----------------------")
		return
	end	

	local cbCardType = GameLogic:GetCardType(cbCardData, cbCardCount, bCardLast)
	print("我的:")
	GameLogic:typeDebug(cbCardType)

	if cbCardType == CT_ERROR then
		MusicCenter:PlayWarnEffect()
		print("---------------------------ERROR TYPE------------------------------")
		ActionHelper:ShowErrorTypeTips(self, cc.p(display.cx, 120))
		return 
	end

	print("是否支持三带二:", DataCenter:getIsThreePlusTwo())
	if DataCenter:getIsThreePlusTwo() then

	else
		if cbCardType == CT_THREE_LINE_TAKE_XXX then
			MusicCenter:PlayWarnEffect()
			print("---------------------------不支持三带类型------------------------------")
			ActionHelper:ShowErrorTypeTips(self, cc.p(display.cx, 120))
			return
		end
	end

	--非首出牌
	if not bFirstOut then
		local cbTurnCardCount = DataCenter:getPrevOutCardCount()
   		local cbTurnCardData = DataCenter:getPrevOutCardData()
   		local cbTurnCardUser = DataCenter:getPrevOutUser()
   		dump(cbTurnCardData, "上家出牌数据:")
   		local bTurnCardLast = DataCenter:getHandCardCountTab()[cbTurnCardUser + 1] == 0
    	local cbTurnCardType = GameLogic:GetCardType(cbTurnCardData, cbTurnCardCount, bTurnCardLast)

    	print("上家")
    	GameLogic:typeDebug(cbTurnCardType)
    	local bBig = GameLogic:CompareCard(cbTurnCardData, cbCardData, cbTurnCardCount, cbCardCount, bTurnCardLast, bCardLast)
		if not bBig then
			print("ERROR: No BIG!")
			ActionHelper:ShowErrorTypeTips(self, cc.p(display.cx, 120))
			return 
		end
	end

	DataCenter:setIsDealUserOperation(true)
	InternetManager:sendOutCard(cbCardData, cbCardCount)
	UIManager:HideUI("UICountDown")
	UIManager:HideUI("UIOutCard")
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

	print("需要删除的手牌:")
	dump(arrayMyData)
	self.myHandCards_:removeCards()

	local selfCardData = DataCenter:getSelfHandCardData()
	local selfCardCount = DataCenter:getSelfHandCardCount()
	print("删除前手牌:")
	dump(selfCardData)
	if not GameLogic:RemoveCard(arrayMyData, myOutCardCount, selfCardData, selfCardCount) then
		assert(false, "删除手牌错误!")
	end
	print("删除后手牌:")
	dump(selfCardData)
	DataCenter:reduceHandCardCount(myOutCardCount)

	self.myHandCards_:resetOutCardsData()

	--重置提示
	self.tipsTab_     = {}
	self.tipsIndex_   = -1
	self.m_nClickNum_ = 0
end

function StatePlaying:clearCurrentUserOutCard()
	-- body
	local current_user = DataCenter:getCurrentUser()
    local direction = GetDirection(current_user)

   	local node_name = {
		[eDown]  = "nodeOutCardDown",
		[eRight] = "nodeOutCardRight",
		[eUp]    = "nodeOutCardUp",
		[eLeft]  = "nodeOutCardLeft"
   	}

   	local current_name = node_name[direction]

   	if self[current_name] then
   		self[current_name]:removeSelf()
   		self[current_name] = nil
   	end
end

function StatePlaying:clearAllPlayerOutCard()
	-- body
	local node_name = {
		[eDown]  = "nodeOutCardDown",
		[eRight] = "nodeOutCardRight",
		[eUp]    = "nodeOutCardUp",
		[eLeft]  = "nodeOutCardLeft"
   	}

   	for k, v in pairs(node_name) do
   		if self[v] then
   			self[v]:removeSelf()
   			self[v] = nil
   		end
   	end
end

function StatePlaying:PlayPassCardEffect()
	local passUser = DataCenter:getPrevOperationUser()
	MusicCenter:PlayPassCardEffect(passUser)
end

function StatePlaying:PlayOutCardEffect(cbTurnCardData, cbTurnCardCount, cbTurnCardUser, bTurnLast)
    local direction = GetDirection(cbTurnCardUser)
    local card_type = GameLogic:GetCardType(cbTurnCardData, cbTurnCardCount, bTurnLast)
    GameLogic:typeDebug(card_type)
    print("card_type = ", card_type)
    local value = nil
    local cbGender = FGameDC:getDC():GetUserInfo(cbTurnCardUser).cbGender
    print("性别:" .. cbGender)
	if card_type == CT_SINGLE or card_type == CT_DOUBLE then
		value = CardHelper:getCardValue(cbTurnCardData[0])
		print("值:" .. value)
	elseif card_type == CT_WU_SHI_K or card_type == CT_FLUSH_WU_SHI_K then
		GafHelper:PlayGaf(self, "_510K", cc.p(display.cx, display.cy + 120))
	elseif card_type == CT_THREE_LINE_TAKE_XXX then
		if cbTurnCardCount > 5 then
			local direction = GetDirection(cbTurnCardUser)
			print("飞机方向 = ", direction)
			GafHelper:PlayGafWithDirection(self, "_Plane", cc.p(display.cx, display.cy), direction or eDown)
		end
	elseif card_type == CT_BOMB_FOUR or card_type == CT_BOMB_FIVE or card_type == CT_BOMB_SIX or card_type == CT_BOMB_SEVEN or 
		card_type == CT_BOMB_EIGHT then
		GafHelper:PlayGaf(self, "_ZhaDan", cc.p(display.cx, display.cy + 120))
	elseif card_type == CT_DOUBLE_LINE then
		GafHelper:PlayGaf(self, "_LianDui", cc.p(display.cx, display.cy + 120))
	elseif card_type == CT_BOMB_KING then
		GafHelper:PlayGaf(self, "_WangZha", cc.p(display.cx, display.cy + 120))
	end

	if card_type == CT_THREE_LINE_TAKE_XXX and cbTurnCardCount <= 5 then
		MusicCenter:PlayThreeTakeTwoSound(cbGender)
	else
		MusicCenter:PlayOutCardEffect(cbGender, card_type, value)
	end
end

function StatePlaying:showOtherPlayerOutCard(cbTurnCardData, cbTurnCardCount, cbTurnCardUser, bTurnLast)
	-- body
    local direction = GetDirection(cbTurnCardUser)

   	local card_type = GameLogic:GetCardType(cbTurnCardData, cbTurnCardCount, bTurnLast)
   	GameLogic:typeDebug(card_type)

   	print("出牌类型:", card_type)
   	if cbTurnCardUser == 255 or cbTurnCardCount == 0 then
   		return
   	end

   	local bSelf = direction == eDown

   	local node_name = {
		[eDown]  = "nodeOutCardDown",
		[eRight] = "nodeOutCardRight",
		[eUp]    = "nodeOutCardUp",
		[eLeft]  = "nodeOutCardLeft"
   	}

   	local pos_tab = {
		[eDown]  = cc.p(display.cx - (cbTurnCardCount - 1) * self.myHandCards_.CARD_DISTANCE / 2 * 0.75, display.cy - 5),
		[eRight] = cc.p(display.cx + 400 - (cbTurnCardCount > 9 and 9 or cbTurnCardCount - 1) * self.myHandCards_.CARD_DISTANCE * 0.75, display.cy + 155),
		[eUp]    = cc.p(display.cx + 40, display.cy + 290),
		[eLeft]  = cc.p(display.cx - 410, display.cy + 155)
   }

   	local current_node = node_name[direction]
   	local current_pos = pos_tab[direction]

   	if self[current_node] then
   		self[current_node]:removeSelf()
   		self[current_node] = nil
   	end

   	self[current_node] = ComboCards.new(cbTurnCardData, cbTurnCardCount, bSelf, bTurnLast)
   	self[current_node]:align(display.CENTER, current_pos.x, current_pos.y)
   	self[current_node]:addTo(self)
   	ActionHelper:OutCardAction(self[current_node], 0.75)

	-- local scorePos = cc.p(0, 0)
 --    if direction == eDown then
	-- 	scorePos.x = display.cx - (cbTurnCardCount - 1) * self.myHandCards_.CARD_DISTANCE / 2 * 0.75
	-- 	scorePos.y = display.cy + 20
	-- elseif direction == eRight then
	-- 	scorePos.x = display.cx + 350 - (cbTurnCardCount > 9 and 9 or cbTurnCardCount - 1) * self.myHandCards_.CARD_DISTANCE * 0.75 * 0.5
	-- 	scorePos.y = display.cy + 220
	-- elseif direction == eUp then
	-- 	scorePos.x = display.cx - 40
	-- 	scorePos.y = display.cy + 270
	-- elseif direction == eLeft then
	-- 	scorePos.x = display.cx - 350 + (cbTurnCardCount > 9 and 9 or cbTurnCardCount - 1) * self.myHandCards_.CARD_DISTANCE * 0.75 * 0.5
	-- 	scorePos.y = display.cy + 190
	-- end
end

function StatePlaying:ShowTrusteeshipBtn()
	--建桌没有托管
	if DataCenter:getServerType() == GAME_GENRE_SCORE then
		return 
	end
    local trusteeBtn = cc.ui.UIPushButton.new({normal = "ccbResources/fightbombRes/trusteeship/q_tuoguan_back.png", 
        pressed = "ccbResources/fightbombRes/trusteeship/q_tuoguan_back_p.png"})
    trusteeBtn:onButtonClicked(
    	function()
    		InternetManager:SetTrusteeship(true)
        end
    )
    trusteeBtn:addTo(self):align(display.CENTER, 270, 240)
end

function StatePlaying:StateEnd()    -- 结束该状态
	print("------------------- > Playing场景状态结束")
	self:DeleteScheduler(self.delayShowClearHandle_)
	self:DeleteScheduler(self.delayClearCardHandle_)
	UIManager:RemoveUI("UIOutCard")
	UIManager:RemoveUI("UICountDown")
	UIManager:RemoveUI("UIOverCard")

	--UIManager:RemoveUI("UITrusteeship")
	UIManager:RemoveUI("UIDismiss")
	self:removeSelf()
end

function StatePlaying:showAllPlayerCards()
	-- body
	self:clearAllPlayerOutCard()
	self.layer_ = display.newColorLayer(ccc4(0, 0, 0, 0))
    self.layer_:addTo(self)

 --    local testCards = {
 --    	[1] = {0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x12,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,},
	-- 	[2] = {0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,},
	-- 	[3] = {0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,},
	-- 	[4] = {0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,},
	-- }

	-- local testCardsCount = {
	-- 	[1] = 27,
	-- 	[2] = 27,
	-- 	[3] = 27,
	-- 	[4] = 27
	-- }
    local players_cards = DataCenter:getHandCardDataTab()
    local players_cards_count = DataCenter:getHandCardCountTab()

    for i = 1, GAME_PLAYER do
    	local cbCardData = players_cards[i] 	--players_cards[i]			--testCards
    	local cbCardCount = players_cards_count[i] 	--players_cards_count[i]	--#testCards
    	local direction = GetDirection(i - 1)			--GetDirection(i - 1)		--i - 1

    	local show_cards = ShowCards.new(cbCardData, cbCardCount, direction == eDown)
    	show_cards:addTo(self)
    	if direction == eDown then
    		show_cards:align(display.CENTER, display.cx - (cbCardCount - 1) * show_cards.CARD_DISTANCE / 2 * 0.6, display.cy - 30)
    	elseif direction == eRight then
    		show_cards:align(display.CENTER, display.cx + 470 - (cbCardCount > 9 and 9 or cbCardCount - 1) * show_cards.CARD_DISTANCE * 0.6, display.cy + 170)
    	elseif direction == eUp then
    		show_cards:align(display.CENTER, display.cx + 25, display.cy + 300)
		elseif direction == eLeft then
    		--todo
    		show_cards:align(display.CENTER, display.cx - 450 , display.cy + 170)
    	end
    end
end

function StatePlaying:removeAllPlayerCards()
	-- body
	if self.layer_ then
		self.layer_:removeSelf()
	end
end

function StatePlaying:ShowLessFiveAnimation()
	local posTab = {
		[eDown] = {x = 640, y = 200},
		[eRight] = {x = 1080, y = 420},
		[eLeft] = {x = 150, y = 420},
	}

	local szTip = "少于五张"
	local card_count_tab = DataCenter:getHandCardCountTab()
	for i = 0, GAME_PLAYER - 1 do
		local nCount = card_count_tab[i + 1]
		if i ~= DataCenter:getSelfChairID() and nCount <= 5 and not self.bWarnAnimationStatus_[i] then
			local direction = GetDirection(i)
			local tipsTxt = nCount == 1 and "剩余一张" or "少于五张"
			ActionHelper:ShowWarn(self, posTab[direction])
			self.bWarnAnimationStatus_[i] = true
			self.warnLabelTab_[i + 1] = display.newTTFLabel({
		        text = tipsTxt,
		        font = "Arial",
		        size = 32,
		        color = cc.c3b(255, 255, 255), 
		        align = cc.TEXT_ALIGNMENT_CENTER,
		    })
			self.warnLabelTab_[i + 1]:align(display.CENTER, posTab[direction].x + 100, posTab[direction].y):addTo(self)
		end

		if nCount == 1 and self.warnLabelTab_[i + 1] then
			self.warnLabelTab_[i + 1]:setString("剩余一张")
		end
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
	local pngPath = "ccbResources/fightbombRes/base/merge_show.png"
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
	if DataCenter:getGameModel() ~= GAME_MODEL_BAO then
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
		})
	sp:runAction(sequence)
end

function StatePlaying:showCallCardAction()
	-- body
	--不是叫牌模式 则退出
	if DataCenter:getGameModel() ~= 0 then
		return 
	end
	print("------------------------------showCallCardAction---------------------------------")
	self.bInCallCardAction_ = true
    local call_card_data = DataCenter:getCallCardData()

	local card = CardView.new(call_card_data)
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
	        	self.bInCallCardAction_ = false
	        	UIManager:UpdateUI("UITopInfo")
	        	UIManager:UpdateUI("UICountDown")
				UIManager:UpdateUI("UIOutCard")
			end)
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