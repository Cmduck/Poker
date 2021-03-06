
--组合牌(或出牌)
--单牌		单个牌	红心5>大王 >小王 >2>A>K>Q>J>10>9>8>7>6>5>4>3
--对子		数值相同的两张牌
--单顺		五张或更多的连续单牌
--双顺		两对或更多的连续对牌
--三带二	数值相同的三张牌+两张牌（两张单牌或对子都可以）
--炸弹		四张同数值牌颜色不同
--飞机		只能2飞机不能2个以上的飞机。
--一刀		双红心5 或者 四张相同颜色的同数值牌 或者五张同数值牌 或者三个王
--两刀		四张相同颜色的同数值牌加一张其他颜色的牌，三张红色的同数值牌加3张黑色的同数值牌
--三刀		四张黑色或红色的同数值牌加二张黑色或红色同数值牌
--四刀		七张同数值的牌或四张王 或四张红色5
--十刀      八张相同数值的牌，5除外  	
--十二刀	八张5
local GameLogic = require("script.50kScript.game.GameLogic")
local CardHelper = require("script.50kScript.card.CardHelper")
local CardView = require("script.50kScript.card.CardView")

local ComboCards = class("ComboCard", function()
    return display.newNode()
end)

ComboCards.CARD_DISTANCE = 40	--扑克间距

ComboCards.ROW_NUM = 9			--一行扑克数

function ComboCards:ctor(cardsData, cardsCount, bSelf)
	-- body
	self.cardsData_ = clone(cardsData)
	self.ComboCardsList_ = {}
	self.cardsNum_ = 0
	self.bSelf_ = bSelf
	self:createCards(self.cardsData_, cardsCount)
	self:setScale(0.75)
end

function ComboCards:createCards(cardsData, cardsCount)
	-- body
	--self:removeAllCards()
	self:sortCards(cardsData, cardsCount)
	for i = 0, cardsCount - 1 do
		self.ComboCardsList_[i] = CardView.new(self.cardsData_[i])
		self.ComboCardsList_[i]:addTo(self)
		if self.bSelf_ then
			self.ComboCardsList_[i]:align(display.CENTER, 0 + i * ComboCards.CARD_DISTANCE, 0)
		else
			local row = math.floor(i / ComboCards.ROW_NUM)
			local column = i % ComboCards.ROW_NUM
			self.ComboCardsList_[i]:align(display.CENTER, 0 + column * ComboCards.CARD_DISTANCE, 0 - row * 50)
		end
	end	
end
 
function ComboCards:sortCards(cardsData, cardsCount)
	-- body
	--GameLogic:SortCardList(cardsData, cardsCount, ST_ORDER)
	GameLogic:SortCardList2(cardsData, cardsCount)
	--print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
	--dump(cardsData)
	-- local card_type = GameLogic:getOutCardType(cardsData)

	-- if card_type == CT_ERROR then

	-- elseif card_type == CT_THREE_PLUS_TWO then
	-- 	self:sortCardsByTimes(cardsData)
	-- elseif card_type == CT_PLANE then
	-- 	--self:sortCardsByTimes(cardsData)
	-- 	self:sortCardsForPlane(cardsData)
	-- else
	-- 	self:sortCardsByValue(cardsData)
	-- end		
end

function ComboCards:sortCardsFromSmallToLarge(cardsData, cardsCount)

end

function ComboCards:sortCardsByValue(cardsData)
	-- body
	table.sort(cardsData, function(a, b)
		if CardHelper:getCardActualValue(a) == CardHelper:getCardActualValue(b) then
			return CardHelper:getCardColor(a) < CardHelper:getCardColor(b)
		else
			return CardHelper:getCardActualValue(a) < CardHelper:getCardActualValue(b)
		end
	end)	
end

function ComboCards:sortCardsByTimes(cardsData)
	-- body
	self:sortCardsByValue(cardsData)
	table.sort(cardsData, function(a, b)
		local t = GameLogic:ChangeCardsDataToArray_(cardsData)
		local realvalue1 = CardHelper:getCardActualValue(a)
		local realvalue2 = CardHelper:getCardActualValue(b)
		if t[realvalue1] == t[realvalue2] then
			if realvalue1 == realvalue2 then
				return CardHelper:getCardColor(a) < CardHelper:getCardColor(b)
			else
				return CardHelper:getCardActualValue(a) < CardHelper:getCardActualValue(b)
			end
		else
			return t[realvalue1] > t[realvalue2]
		end
	end)	
end

function ComboCards:sortCardsForPlane( cardsData )
	-- body
	self:sortCardsByValue(cardsData)
	local planeValueTab = GameLogic:getPlaneValue(cardsData)
	print("-------------------> planeValueTab:")
	dump(planeValueTab)
	local comboTab = {}
	--保证数目大于三张的牌只提取三张
	local recordTab = {}
	--双重循环提取飞机
	--从小到大
	for i = #planeValueTab[1], 1 , -1 do
		--从小到大排序
		local actual_value = planeValueTab[1][i]
		for j = 1, #cardsData do
			if not recordTab[actual_value] and actual_value == CardHelper:getCardActualValue(cardsData[j]) then
				recordTab[actual_value] = true
				table.insert(comboTab, cardsData[j])
				cardsData[j] = 0
				table.insert(comboTab, cardsData[j + 1])
				cardsData[j + 1] = 0
				table.insert(comboTab, cardsData[j + 2])
				cardsData[j + 2] = 0
			end
		end
	end
	print("-------------------> comboTab_1")
	dump(comboTab)
	for i, v in ipairs(cardsData) do
		if v ~= 0 then
			table.insert(comboTab, v)
		end
	end
	print("-------------------> comboTab_2")
	dump(comboTab)
	self.cardsData_ = comboTab
end


 function ComboCards:removeAllCards()
 	-- body
 	for i, v in ipairs(self.ComboCardsList_) do
 		self.ComboCardsList_[i]:removeSelf()
 		self.ComboCardsList_[i] = nil 
 	end
 end

return ComboCards

