local CardHelper = class("CardHelper")

--扑克花色
CardHelper.SPADE_COLOR 			= 0x00   --	梅花
CardHelper.HEART_COLOR 			= 0x01 	 --	方片
CardHelper.DIAMOND_COLOR 		= 0x02   --	红桃
CardHelper.CLUB_COLOR 			= 0x03   --	黑桃
CardHelper.JOKER				= 0x04   --	王

--特殊牌
CardHelper.SPECIAL_CARD 		= 0x25	 --红心5


--分值扑克
CardHelper.CARD_5 				= 0x05
CardHelper.CARD_10 				= 0x0A
CardHelper.CARD_K 				= 0x0D

--特定扑克值
CardHelper.CARD_A 				= 14
CardHelper.CARD_2				= 15
CardHelper.CARD_JOKER_BLACK		= 16
CardHelper.CARD_JOKER_RED		= 17


CardHelper.LOGIC_MASK_COLOR 	= 0xF0 	--花色掩码
CardHelper.LOGIC_MASK_VALUE 	= 0x0F	--数值掩码
--实际值映射表
-- 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F
CardHelper.CARD_ACTUAL_VALUE_TAB_DATA = {14, 15, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17};

--
function CardHelper:ctor()
	-- body
end

--取牌面值
function CardHelper:getCardValue(data)
	-- body
	return bit.band(data, CardHelper.LOGIC_MASK_VALUE)
end

--取花色
function CardHelper:getCardColor(data)
	-- body
	local n = bit.band(data, CardHelper.LOGIC_MASK_COLOR)
	return bit.rshift(n, 4)
end

--取实际值
function CardHelper:getCardLogicValue(data)
	-- body
	--dump(data)
	return CardHelper.CARD_ACTUAL_VALUE_TAB_DATA[self:getCardValue(data)]
end

function CardHelper:getCardClassProperties(data)
	-- body
	local FaceValue = self:getCardValue(data)
	local ActualValue = self:getCardLogicValue(data)
	local Color = self:getCardColor(data)
	local t = {id = "CardClass", HexData = data, FaceValue = FaceValue, ActualValue = ActualValue, Color = Color}
	return t
end

function CardHelper:debugLog(data, count)
	-- body
	if type(data) == "number" then
		print("当前的牌面值是:" .. self:getCardLogicValue(data) .. ", 当前的花色是:" .. self:getCardColor(data))
	else
		for i = 0, count - 1 do
			self:debugLog(data[i])
		end
	end
end

return CardHelper