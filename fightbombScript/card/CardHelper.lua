local CardHelper = class("CardHelper")

--扑克花色
CardHelper.SPADE_COLOR 			= 0x00   --	梅花
CardHelper.HEART_COLOR 			= 0x01 	 --	方片
CardHelper.DIAMOND_COLOR 		= 0x02   --	红桃
CardHelper.CLUB_COLOR 			= 0x03   --	黑桃
CardHelper.KING_COLOR			= 0x04   --	王
CardHelper.INVALID_COLOR        = 0xF0   --无效花色
--特殊牌
CardHelper.SPECIAL_CARD 		= 0x25	 --红心5

--分值扑克
CardHelper.CARD_5 				= 0x05
CardHelper.CARD_10 				= 0x0A
CardHelper.CARD_K 				= 0x0D

--特定扑克逻辑值
CardHelper.LOGIC_VALUE_A          = 14
CardHelper.LOGIC_VALUE_2          = 15
CardHelper.LOGIC_VALUE_KING_BLACK = 16
CardHelper.LOGIC_VALUE_KING_RED   = 17

CardHelper.DATA_KING_RED 		= 0x4F
CardHelper.DATA_KING_BLACK 		= 0x4E

CardHelper.LOGIC_MASK_COLOR 	= 0xF0 	--花色掩码
CardHelper.LOGIC_MASK_VALUE 	= 0x0F	--数值掩码

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
	local card_value = CardHelper:getCardValue(data)
	local card_color = CardHelper:getCardColor(data)

	if card_color == CardHelper.KING_COLOR then
		return card_value + 2
	end

	return card_value <= 2 and card_value + 13 or card_value
end

function CardHelper:getCardClassProperties(data)
	-- body
	local card_value = self:getCardValue(data)
	local card_logic_value = self:getCardLogicValue(data)
	local card_color = self:getCardColor(data)
	local t = {id = "CardClass", m_cbCardData = data, m_cbCardValue = card_value, m_cbCardLogicValue = card_logic_value, m_cbCardColor = card_color}
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