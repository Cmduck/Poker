local CardClass = class("CardClass", cc.mvc.ModelBase)

local CardHelper = require("script.fightbombScript.card.CardHelper")
--[[
	对子 one pair
	单张 single
	顺子 straight
	洗牌 shuffle
	分牌 deal 
--]]
--常量
CardClass.INVALID_VALUE 	= -1	 --无效值

-- 定义事件
CardClass.CHANGE_CARD_DATA_EVENT = "CHANGE_CARD_DATA_EVENT"	--扑克数据改变

-- 定义属性
CardClass.schema = clone(cc.mvc.ModelBase.schema)
CardClass.schema["m_cbCardData"] 		= {"number", CardClass.INVALID_VALUE}   -- 牌面值 即A为0x01
CardClass.schema["m_cbCardValue"] 		= {"number", CardClass.INVALID_VALUE}   -- 牌面值 即A为0x01
CardClass.schema["m_cbCardColor"] 		= {"number", CardClass.INVALID_VALUE} 	-- 花色
CardClass.schema["m_cbCardLogicValue"] 	= {"number", CardClass.INVALID_VALUE} 	-- 扑克实际值 即A为14

function CardClass:ctor(properties)
	-- body
	local t = {}
	if type(properties) == "number" then
		t = CardHelper:getCardClassProperties(properties)
	else
		t = properties
	end
	CardClass.super.ctor(self, t)
end

function CardClass:setCardData(data)
	-- body
	self:setProperties(CardHelper:getCardClassProperties(data))
	self:dispatchEvent({name = CardClass.CHANGE_CARD_DATA_EVENT})
end

function CardClass:getCardValue()
	-- body
	return self.m_cbCardValue_
end

function CardClass:getCardColor()
	-- body
	return self.m_cbCardColor_
end

function CardClass:getCardLogicValue()
	-- body
	return self.m_cbCardLogicValue_
end

function CardClass:setCardData(data)
	-- body
	self.m_cbCardData_ = data
end

function CardClass:getCardData()
	-- body
	return self.m_cbCardData_
end

return CardClass