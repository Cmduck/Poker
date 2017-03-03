local CardClass = class("CardClass", cc.mvc.ModelBase)

local CardHelper = require("script.50kScript.card.CardHelper")
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
CardClass.schema["HexData"] 		= {"number", CardClass.INVALID_VALUE}   -- 牌面值 即A为0x01
CardClass.schema["FaceValue"] 		= {"number", CardClass.INVALID_VALUE}   -- 牌面值 即A为0x01
CardClass.schema["Color"] 			= {"number", CardClass.INVALID_VALUE} 	-- 花色
CardClass.schema["ActualValue"] 	= {"number", CardClass.INVALID_VALUE} 	-- 扑克实际值 即A为14

function CardClass:ctor(properties)
	-- body
	local t = {}
	if type(properties) == "number" then
		t = CardHelper:getCardClassProperties(properties)
	    --print("GF_Debug:-> ~~~~~~~~~CardClass~~~~~~~~~~")
	    --dump(t)
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

function CardClass:setFaceValue(face_value)
	-- body
	self.FaceValue_ = face_value
end

function CardClass:setColor(color)
	-- body
	self.Color_ = color
end

function CardClass:getFaceValue()
	-- body
	return self.FaceValue_
end

function CardClass:getColor()
	-- body
	return self.Color_
end

function CardClass:setActualValue(actual_value)
	-- body
	self.ActualValue_ = actual_value
end

function CardClass:getActualValue()
	-- body
	return self.ActualValue_
end

function CardClass:setHexData(data)
	-- body
	self.HexData_ = data
end

function CardClass:getHexData()
	-- body
	return self.HexData_
end

function CardClass:isLarge(card1, card2)
	-- body
	return card1[card_actual_value_] > card2[card_actual_value_]
end

function CardClass:isSmall(card1, card2)
	-- body
	return card1[card_actual_value_] < card2[card_actual_value_]
end

return CardClass