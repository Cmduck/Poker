local EventProxyEx = require("script.fightbombScript.common.EventProxyEx")
local CardView = require("script.fightbombScript.card.CardView")
local CardHelper = require("script.fightbombScript.card.CardHelper")
--手牌
local HandCards = class("HandCards", function()
    return display.newNode()
end)

HandCards.CARD_DISTANCE 		= 40	--扑克间距
HandCards.OUT_CARD_TOP_DISTANCE = 35	--出牌间距

--定义事件
HandCards.ADD_CARD_EVENT 		= "ADD_CARD_EVENT"
HandCards.REMOVE_CARD_EVENT 	= "REMOVE_CARD_EVENT"

local OriginPosX = 0

--[[
	排序类型
--]]
local SORT_ORDER = 1	--大小排序
local SORT_COLOR = 2	--花色排序
local SORT_50K 	 = 3	--50K排序

function HandCards:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	-- body
	self:setTouchEnabled(true)
	self:setTouchSwallowEnabled(false)
	--注册触摸事件
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch_))

    
    self.cardsData_ = {}
	self.cardsViewList_ = {}
	self.cardsNum_ = 0
	self.markCardIndex_ = -1
	self.scaleRatio_ = 1
	self.outCardsData_ = {}
	self.outCardsViewList_ = {}

	self.m_cbSortType_ = SORT_ORDER
end

function HandCards:setScaleRatio(num)
	-- body
	self.scaleRatio_ = num
end

function HandCards:createCards(cardsData, cardsCount)
	-- body
	print("手牌个数" .. tostring(cardsCount))
	--如果不拷贝 就和DataCenter使用同一块内存数据 这里删除 DataCenter里面的数据也有变动
	self.cardsData_ = clone(cardsData)
	self.cardsCount_ = cardsCount

	GameLogic:SortCardList(self.cardsData_, self.cardsCount_, ST_ORDER)
	OriginPosX = self:getPositionX()
	--dump(self.cardsData_)
	for i = 0, self.cardsCount_ - 1 do
		self:addCard(self.cardsData_[i])
	end
end

function HandCards:onTouch_( event )
	-- body
	if event.name == "began" then
		self.bMove_ = false
        self.selectCards_ = {}
        self.selectCardsNum_ = 0
        self.beginPoint_ = cc.p(event.x, event.y)
		local view_list = self:getCardsViewList()
		for i = #view_list, 1 , -1 do
			local view = self:getCardsViewList()[i]
			local card_bg = view:getCardBg()

			if view:isContainPoint(ccp(event.x, event.y), i == #view_list) then
				--如果点击坐标在扑克范围内
	            if self.selectCards_[i] == nil then
	                self.selectCards_[i] = view
	                self.selectCards_[i]:SetClickedColor(true)
	                self.selectCardsNum_ = self.selectCardsNum_ + 1
	            end
	            break
			end
		end

		return true
	elseif event.name == "moved" then
		--print("moved")
		self.bMove_ = true
		local view_list = self:getCardsViewList()
		for i = #view_list, 1 , -1 do
			local view = self:getCardsViewList()[i]
			local card_bg = view:getCardBg()
			--[[
			if view:isContainPoint(ccp(event.x, event.y), i == #view_list) then
				--如果点击坐标在扑克范围内
	            if self.selectCards_[i] == nil then
	                self.selectCards_[i] = view
	                self.selectCards_[i]:SetClickedColor(true)
	                self.selectCardsNum_ = self.selectCardsNum_ + 1
	            end
	            break
			end
			--]]
			if view:isContainPointMove(self.beginPoint_, ccp(event.x, event.y), i == #view_list) then
				--如果点击坐标在扑克范围内
	            if self.selectCards_[i] == nil then
	                self.selectCards_[i] = view
	                self.selectCards_[i]:SetClickedColor(true)
	                self.selectCardsNum_ = self.selectCardsNum_ + 1
	            end
	            --break
	        else
	        	if self.selectCards_[i] then
	        		self.selectCards_[i]:SetClickedColor(false)
	            	self.selectCardsNum_ = self.selectCardsNum_ - 1
	            	self.selectCards_[i] = nil
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
	end
end

function HandCards:getCardsViewList()
	-- body
	return self.cardsViewList_
end

--获取扑克总数
function HandCards:getHandCardsCount( ... )
	-- body
	return self.cardsNum_
end

--添加一张牌
function HandCards:addCard(cardData)
	-- body
	self.cardsViewList_[self.cardsNum_ + 1] = CardView.new(cardData)
	self.cardsViewList_[self.cardsNum_ + 1]:addTo(self)
	self.cardsViewList_[self.cardsNum_ + 1]:setLocalZOrder(self.cardsNum_)
	local posx = 0 + self.cardsNum_ * HandCards.CARD_DISTANCE
	if not DataCenter:getIsReConnect() and not DataCenter:getIsGameOver() then
		self.cardsViewList_[self.cardsNum_ + 1]:align(display.CENTER, 2 * display.width, 0)
		transition.moveTo(self.cardsViewList_[self.cardsNum_ + 1], {x = posx, y = 0, time = self.cardsNum_ * 0.05})
	else
		self.cardsViewList_[self.cardsNum_ + 1]:align(display.CENTER, posx, 0)
	end

	EventProxyEx.new(self.cardsViewList_[self.cardsNum_ + 1], self):addEventListener(CardView.CLICK_CARD_EVENT, handler(self, self.onClickCard))
	self.cardsNum_ = self.cardsNum_ + 1
	if self.cardsNum_ ~= 1 then
		local x = self:getPositionX()
		self:setPositionX(x - HandCards.CARD_DISTANCE / 2 * self.scaleRatio_)
    	--self:dispatchEvent({name = HandCards.ADD_CARD_EVENT})
	end
	--self:dispatchEvent({name = HandCards.ADD_CARD_EVENT})
end

function HandCards:onClickCard(event)
	-- body
	--dump(event)
	--print("HandCards ---------------------> onClickCard")
	local bTop = event.target:isTop()
	local y = event.target:getPositionY()
	if bTop then
		event.target:setPositionY(y + HandCards.OUT_CARD_TOP_DISTANCE)
		table.insert(self.outCardsData_, event.target:getCardData())
		table.insert(self.outCardsViewList_, event.target)
	else
		event.target:setPositionY(y - HandCards.OUT_CARD_TOP_DISTANCE)
		table.removebyvalue(self.outCardsData_, event.target:getCardData())
		table.removebyvalue(self.outCardsViewList_, event.target)
	end
end

function HandCards:removeCard(view)
	-- body
	--print("------------------------------HandCards:removeCard-------------------------------------------")
	local index = -1
	for i, v in ipairs(self.cardsViewList_) do
		if view == v then
			index = i
		end
		if index ~= -1 then
			--print("i = " .. i)
			local pos = v:getPositionX()
			v:setPositionX(pos - HandCards.CARD_DISTANCE)
		end
	end
	--print("index" .. index)

	--table.remove(self.cardsData_, index - 1)
	RemoveArrayItemByIndex(self.cardsData_, self.cardsNum_, index - 1) 
	table.remove(self.cardsViewList_, index)
	view:removeSelf()
	self.cardsNum_ = self.cardsNum_ - 1
	self.cardsCount_ = self.cardsCount_ - 1
	local x = self:getPositionX()
	self:setPositionX(x + HandCards.CARD_DISTANCE / 2)
	self:dispatchEvent({name = HandCards.REMOVE_CARD_EVENT})
end

--根据值插入
function HandCards:InsertCard(cbCardData)
	local insert_card_logic_value = CardHelper:getCardLogicValue(cbCardData)
	local insert_card_color = CardHelper:getCardColor(cbCardData)
	-- print("插入扑克数据: " .. cbCardData)
	-- print("insert_card_logic_value = " .. insert_card_logic_value)
	-- print("self.cardsNum_ = " .. self.cardsNum_)
	-- dump(self.cardsData_)
	local index = 0 
	local bInsert = false
	--从小到大
	for i = self.cardsNum_ - 1, 0, -1 do
		local view_index = i + 1
		local logic_value_temp = CardHelper:getCardLogicValue(self.cardsData_[i])
		local color_temp = CardHelper:getCardColor(self.cardsData_[i])
		local iZorder = self.cardsViewList_[view_index]:getLocalZOrder()
		local x = self.cardsViewList_[view_index]:getPositionX()
		--print("logic_value_temp = " .. logic_value_temp)
		if insert_card_logic_value > logic_value_temp then
			--如果大于当前牌
			--牌控件后移
			self.cardsViewList_[view_index + 1] = self.cardsViewList_[view_index]
			self.cardsViewList_[view_index + 1]:setPositionX(x + HandCards.CARD_DISTANCE)
			self.cardsViewList_[view_index + 1] = self.cardsViewList_[view_index]
			self.cardsViewList_[view_index + 1]:setLocalZOrder(iZorder + 1)
			--数据后移
			self.cardsData_[i + 1] = self.cardsData_[i]
			--插入最左
			if i == 0 then
				self.cardsViewList_[view_index] = CardView.new(cbCardData)
				self.cardsViewList_[view_index]:addTo(self)
				EventProxyEx.new(self.cardsViewList_[view_index], self):addEventListener(CardView.CLICK_CARD_EVENT, handler(self, self.onClickCard))
				self.cardsViewList_[view_index]:onTouch_()
				self.cardsViewList_[view_index]:setLocalZOrder(iZorder)
				self.cardsViewList_[view_index]:setPositionX(x)
				self.cardsData_[i] = cbCardData
				self.cardsNum_ = self.cardsNum_ + 1
				break
			end
		elseif insert_card_logic_value == logic_value_temp then
			--如果值相等 比较花色
			if insert_card_color > color_temp then
				--如果大于当前牌
				--牌控件后移
				self.cardsViewList_[view_index + 1] = self.cardsViewList_[view_index]
				self.cardsViewList_[view_index + 1]:setPositionX(x + HandCards.CARD_DISTANCE)
				self.cardsViewList_[view_index + 1] = self.cardsViewList_[view_index]
				self.cardsViewList_[view_index + 1]:setLocalZOrder(iZorder + 1)
				--数据后移
				self.cardsData_[i + 1] = self.cardsData_[i]
			else
				--小于当前的牌 找到插入位置
				self.cardsViewList_[view_index + 1] = CardView.new(cbCardData)
				self.cardsViewList_[view_index + 1]:addTo(self)
				EventProxyEx.new(self.cardsViewList_[view_index + 1], self):addEventListener(CardView.CLICK_CARD_EVENT, handler(self, self.onClickCard))
				self.cardsViewList_[view_index + 1]:onTouch_()
				self.cardsViewList_[view_index + 1]:setLocalZOrder(iZorder + 1)
				self.cardsViewList_[view_index + 1]:setPositionX(x + HandCards.CARD_DISTANCE)
				self.cardsData_[i + 1] = cbCardData
				self.cardsNum_ = self.cardsNum_ + 1
				break
			end
		else
			--小于当前的牌 找到插入位置
			self.cardsViewList_[view_index + 1] = CardView.new(cbCardData)
			self.cardsViewList_[view_index + 1]:addTo(self)
			EventProxyEx.new(self.cardsViewList_[view_index + 1], self):addEventListener(CardView.CLICK_CARD_EVENT, handler(self, self.onClickCard))
			self.cardsViewList_[view_index + 1]:onTouch_()
			self.cardsViewList_[view_index + 1]:setLocalZOrder(iZorder + 1)
			self.cardsViewList_[view_index + 1]:setPositionX(x + HandCards.CARD_DISTANCE)
			self.cardsData_[i + 1] = cbCardData
			self.cardsNum_ = self.cardsNum_ + 1
			break
		end
	end

	--dump(self.cardsData_)
	local parentX = self:getPositionX()
	--父节点左移
	self:setPositionX(parentX - HandCards.CARD_DISTANCE / 2 * self.scaleRatio_)
end

function HandCards:InsertCardByColor(cbCardData)
	-- body
	local insert_card_logic_value = CardHelper:getCardLogicValue(cbCardData)
	local insert_card_color = CardHelper:getCardColor(cbCardData)
	-- print("插入扑克数据: " .. cbCardData)
	-- print("insert_card_logic_value = " .. insert_card_logic_value)
	-- print("self.cardsNum_ = " .. self.cardsNum_)
	-- dump(self.cardsData_)
	local index = 0 
	local bInsert = false
	--从小到大
	for i = self.cardsNum_ - 1, 0, -1 do
		local view_index = i + 1
		local logic_value_temp = CardHelper:getCardLogicValue(self.cardsData_[i])
		local color_temp = CardHelper:getCardColor(self.cardsData_[i])

		if logic_value_temp == CardHelper.LOGIC_VALUE_2 then
			color_temp = 4
		end

		local iZorder = self.cardsViewList_[view_index]:getLocalZOrder()
		local x = self.cardsViewList_[view_index]:getPositionX()
		-- print("logic_value_temp = " .. logic_value_temp)
		if insert_card_color > color_temp then
			--如果大于当前牌
			--牌控件后移
			self.cardsViewList_[view_index + 1] = self.cardsViewList_[view_index]
			self.cardsViewList_[view_index + 1]:setPositionX(x + HandCards.CARD_DISTANCE)
			self.cardsViewList_[view_index + 1] = self.cardsViewList_[view_index]
			self.cardsViewList_[view_index + 1]:setLocalZOrder(iZorder + 1)
			--数据后移
			self.cardsData_[i + 1] = self.cardsData_[i]
			--插入最左
			if i == 0 then
				self.cardsViewList_[view_index] = CardView.new(cbCardData)
				self.cardsViewList_[view_index]:addTo(self)
				EventProxyEx.new(self.cardsViewList_[view_index], self):addEventListener(CardView.CLICK_CARD_EVENT, handler(self, self.onClickCard))
				self.cardsViewList_[view_index]:onTouch_()
				self.cardsViewList_[view_index]:setLocalZOrder(iZorder)
				self.cardsViewList_[view_index]:setPositionX(x)
				self.cardsData_[i] = cbCardData
				self.cardsNum_ = self.cardsNum_ + 1
				break
			end
		elseif insert_card_color == color_temp then
			--如果花色相等 比较值
			if insert_card_logic_value > logic_value_temp then
				--如果大于当前牌
				--牌控件后移
				self.cardsViewList_[view_index + 1] = self.cardsViewList_[view_index]
				self.cardsViewList_[view_index + 1]:setPositionX(x + HandCards.CARD_DISTANCE)
				self.cardsViewList_[view_index + 1] = self.cardsViewList_[view_index]
				self.cardsViewList_[view_index + 1]:setLocalZOrder(iZorder + 1)
				--数据后移
				self.cardsData_[i + 1] = self.cardsData_[i]
			else
				--小于当前的牌 找到插入位置
				self.cardsViewList_[view_index + 1] = CardView.new(cbCardData)
				self.cardsViewList_[view_index + 1]:addTo(self)
				EventProxyEx.new(self.cardsViewList_[view_index + 1], self):addEventListener(CardView.CLICK_CARD_EVENT, handler(self, self.onClickCard))
				self.cardsViewList_[view_index + 1]:onTouch_()
				self.cardsViewList_[view_index + 1]:setLocalZOrder(iZorder + 1)
				self.cardsViewList_[view_index + 1]:setPositionX(x + HandCards.CARD_DISTANCE)
				self.cardsData_[i + 1] = cbCardData
				self.cardsNum_ = self.cardsNum_ + 1
				break
			end
		else
			--小于当前的牌 找到插入位置
			self.cardsViewList_[view_index + 1] = CardView.new(cbCardData)
			self.cardsViewList_[view_index + 1]:addTo(self)
			EventProxyEx.new(self.cardsViewList_[view_index + 1], self):addEventListener(CardView.CLICK_CARD_EVENT, handler(self, self.onClickCard))
			self.cardsViewList_[view_index + 1]:onTouch_()
			self.cardsViewList_[view_index + 1]:setLocalZOrder(iZorder + 1)
			self.cardsViewList_[view_index + 1]:setPositionX(x + HandCards.CARD_DISTANCE)
			self.cardsData_[i + 1] = cbCardData
			self.cardsNum_ = self.cardsNum_ + 1
			break
		end
	end

	-- dump(self.cardsData_)
	local parentX = self:getPositionX()
	--父节点左移
	self:setPositionX(parentX - HandCards.CARD_DISTANCE / 2 * self.scaleRatio_)
end

function HandCards:InsertBottomCard(cbCardsData, cbCardsCount)
	for i = 1, cbCardsCount do
		self.cardsViewList_[self.cardsNum_ + 1] = CardView.new(cbCardsData[i])
		self.cardsViewList_[self.cardsNum_ + 1]:addTo(self)
		self.cardsViewList_[self.cardsNum_ + 1]:setLocalZOrder(self.cardsNum_)
		local posx = 0 + self.cardsNum_ * HandCards.CARD_DISTANCE
		self.cardsViewList_[self.cardsNum_ + 1]:align(display.CENTER, posx, 0)
		self.cardsData_[self.cardsNum_] = cbCardsData[i]
		EventProxyEx.new(self.cardsViewList_[self.cardsNum_ + 1], self):addEventListener(CardView.CLICK_CARD_EVENT, handler(self, self.onClickCard))
		self.cardsNum_ = self.cardsNum_ + 1
		if self.cardsNum_ ~= 1 then
			local x = self:getPositionX()
			self:setPositionX(x - HandCards.CARD_DISTANCE / 2 * self.scaleRatio_)
	    	--self:dispatchEvent({name = HandCards.ADD_CARD_EVENT})
		end
	end

	dump(self.cardsData_)
	GameLogic:SortCardColorList(self.cardsData_, self.cardsNum_)
	for i = 0, self.cardsNum_ - 1 do
		self.cardsViewList_[i + 1]:resetCardView(self.cardsData_[i])
		for j, v in ipairs(cbCardsData) do
			if self.cardsData_[i] == v then
				self.cardsViewList_[i + 1]:onTouch_()
			end
		end
	end
end

function HandCards:removeCards()
	-- body
	if #self.outCardsViewList_ <= 0 then
		print("ERROR : ----------> 当前出牌列表为空!!! ")
	end

	for _, v in ipairs(self.outCardsViewList_) do
		self:removeCard(v)
	end
	self.outCardsViewList_ = {}
end

function HandCards:getHandCardsData()
	-- body
	return self.cardsData_
end

function HandCards:getOutCardsData()
	-- body
	return self.outCardsData_
end

function HandCards:resetOutCardsData()
	-- body
	self.outCardsData_ = {}
end

function HandCards:resetOutCardsViewList()
	-- body
	self.outCardsViewList_ = {}
end

function HandCards:getOutCardsViewList()
	-- body
	return self.outCardsViewList_
end

function HandCards:RearrangeHandCards()
	-- body
	GameLogic:SortCardList(self.cardsData_, self.cardsCount_, ST_COLOR)

	for i = 0, self.cardsNum_ - 1 do
		self.cardsViewList_[i + 1]:resetCardView(self.cardsData_[i])
	end
end

function HandCards:RearrangeHandCardsBy50K()
	if self.m_cbSortType_ == SORT_50K then
		return
	end

	local OutCardWSKResult = GameLogic:CreateTagWSKOutCardResult()
    local cbHandCardData = self.cardsData_
    local cbHandCardCount = self.cardsNum_
    if GameLogic:SearchWuShiK( cbHandCardData, cbHandCardCount, OutCardWSKResult, true) then
    	self.m_cbSortType_ = SORT_50K

    	for i = 0, self.cardsNum_ - 1 do
			local bTop = self.cardsViewList_[i + 1]:isTop()
			if bTop then
				self.cardsViewList_[i + 1]:onTouch_()
			end
			self.cardsViewList_[i + 1]:resetCardView(self.cardsData_[i])
		end
    end
    print("排序类型 = ", self.m_cbSortType_)
end

function HandCards:RearrangeHandCardsByOrder()
	if self.m_cbSortType_ == SORT_ORDER then
		return 
	end

	self.m_cbSortType_ = SORT_ORDER
	GameLogic:SortCardList(self.cardsData_, self.cardsNum_, ST_ORDER)

	for i = 0, self.cardsNum_ - 1 do
		local bTop = self.cardsViewList_[i + 1]:isTop()
		if bTop then
			self.cardsViewList_[i + 1]:onTouch_()
		end
		self.cardsViewList_[i + 1]:resetCardView(self.cardsData_[i])
	end

	print("排序类型 = ", self.m_cbSortType_)
end

--重排列手牌
function HandCards:RearrangeHandCardsByColor()
	-- body
	GameLogic:SortCardColorList(self.cardsData_, self.cardsNum_)

	for i = 0, self.cardsNum_ - 1 do
		local bTop = self.cardsViewList_[i + 1]:isTop()
		if bTop then
			self.cardsViewList_[i + 1]:onTouch_()
		end
		self.cardsViewList_[i + 1]:resetCardView(self.cardsData_[i])
	end
end

--替换手牌
function HandCards:ReplaceHandCard(cbCardData, cbCardCount)
	self.cardsData_ = clone(cbCardData)
	self.cardsCount_ = cbCardCount
	self.cardsNum_ = 0
	for i = 0, cbCardCount - 1 do
		self.cardsViewList_[i + 1]:removeSelf()
	end
	self:setPositionX(OriginPosX)

	for i = 0, self.cardsCount_ - 1 do
		self:addCard(self.cardsData_[i])
	end
end

return HandCards
