local EventProxyEx = require("script.50kScript.common.EventProxyEx")
local CardView = require("script.50kScript.card.CardView")
local GameLogic = require("script.50kScript.game.GameLogic")
local CardHelper = require("script.50kScript.card.CardHelper")
--手牌
local HandCards = class("HandCards", function()
    return display.newNode()
end)

HandCards.CARD_DISTANCE 		= 40	--扑克间距
HandCards.OUT_CARD_TOP_DISTANCE = 35	--出牌间距

--定义事件
HandCards.ADD_CARD_EVENT 		= "ADD_CARD_EVENT"
HandCards.REMOVE_CARD_EVENT 	= "REMOVE_CARD_EVENT"

--
function HandCards:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	-- body

    self.cardsData_ = {}
	self.cardsViewList_ = {}
	self.cardsNum_ = 0
	self.markCardIndex_ = -1
	self.scaleRatio_ = 1
	self.outCardsData_ = {}
	self.outCardsViewList_ = {}
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

	GameLogic:SortHandCardList(self.cardsData_, self.cardsCount_)

	for i = 0, self.cardsCount_ - 1 do
		self:addCard(self.cardsData_[i])
	end
end

--显示叫牌
function HandCards:showCallCardTip()
	-- body
	if self.markCardIndex_ == -1 then
		return 
	end
	self.cardsViewList_[self.markCardIndex_]:showCallCardMark()
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
	--print("GF_Debug:-> ~~~~~~~~~~~HandCards:addCard~~~~~~~~~~~")
	--print("cardData:" .. cardData)
	self.cardsViewList_[self.cardsNum_ + 1] = CardView.new(cardData)
	self.cardsViewList_[self.cardsNum_ + 1]:addTo(self)
	local posx = 0 + self.cardsNum_ * HandCards.CARD_DISTANCE
	if not DataCenter:getIsReConnect() and not DataCenter:getIsGameOver() then
		self.cardsViewList_[self.cardsNum_ + 1]:align(display.CENTER, 2 * display.width, 0)
		transition.moveTo(self.cardsViewList_[self.cardsNum_ + 1], {x = posx, y = 0, time = self.cardsNum_ * 0.05})
	else
		self.cardsViewList_[self.cardsNum_ + 1]:align(display.CENTER, posx, 0)
	end
	--self.cardsViewList_[self.cardsNum_ + 1]:align(display.CENTER, posx, 0)
	--[[
    local show_cards_data = DataCenter:getShowCardsData()
    local show_cards_num = #show_cards_data
    --这里的bug真难找 只有有叫牌的用户才有self.markCardIndex_变量,所以没有此牌的客户端会出错#_#!
    if show_cards_num ~= 0 and cardData == show_cards_data[show_cards_num] then
    	self.markCardIndex_ = self.cardsNum_ + 1
    end
	--]]
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
	--print("HandCards:onClickCard:->~~~~~~~~~~~~~~~~ check out cards")
	--dump(self.outCardsData_)

end

function HandCards:removeCard(view)
	-- body
	print("------------------------------HandCards:removeCard-------------------------------------------")
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
	print("index" .. index)

	--table.remove(self.cardsData_, index - 1)
	RemoveArrayItemByIndex(self.cardsData_, self.cardsNum_, index - 1) 
	table.remove(self.cardsViewList_, index)
	view:removeSelf()
	self.cardsNum_ = self.cardsNum_ - 1

	local x = self:getPositionX()
	self:setPositionX(x + HandCards.CARD_DISTANCE / 2)
	self:dispatchEvent({name = HandCards.REMOVE_CARD_EVENT})
end

function HandCards:removeCards()
	-- body
	for _, v in ipairs(self.outCardsViewList_) do
		self:removeCard(v)
	end
	self.outCardsViewList_ = {}
end

--扑克排序
function HandCards:sortCards(cardsData)
	-- body
	GameLogic:SortHandCardList(self.cardsData_, #self.cardsData_)
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

return HandCards
