require("script.fightbombScript.common.GameDefine")
local CardHelper = require("script.fightbombScript.card.CardHelper")
local GameLogic = class("GameLogic")

--[[
 bit.bnot(n) -- bitwise not (~n)
 bit.band(m, n) -- bitwise and (m & n)
 bit.bor(m, n) -- bitwise or (m | n)
 bit.bxor(m, n) -- bitwise xor (m ^ n)
 bit.brshift(n, bits) -- right shift (n >> bits)
 bit.blshift(n, bits) -- left shift (n << bits)
 bit.blogic_rshift(n, bits) -- logic right shift(zero fill >>>)
 --]]

local cbIndexCount = 5

local m_cbCardData = {
	0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,	--方块 A - K
	0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,	--梅花 A - K
	0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,	--红桃 A - K
	0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,	--黑桃 A - K
	0x4E,0x4F,															--小王 大王
	0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,
	0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,
	0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,
	0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,
	0x4E,0x4F
}

--[[
	结构体定义
--]]
local tagAnalyseResult = class("tagAnalyseResult")
function tagAnalyseResult:ctor()
	self.cbBlockCount = Create1Array(SAME_CARD_MAX)  					--扑克数目
	self.cbCardData = Create2Array(SAME_CARD_MAX, MAX_COUNT)			--扑克数据
end

local tagAnalyseColorResult = class("tagAnalyseColorResult")
function tagAnalyseColorResult:ctor()
	self.cbColorCardCount = Create1Array(SAME_CARD_MAX)
	self.cbConstMainCount = 0
	self.cbKingCardCount = 0

	self.cbColorCardData = Create2Array(SAME_CARD_MAX, NORMAL_COUNT)
	self.cbConstMainData = Create1Array(SAME_CARD_MAX)
	self.cbKingCardData = Create1Array(KING_COUNT)
end

local tagDistributing = class("tagDistributing")
function tagDistributing:ctor()
	self.cbCardCount = 0												--扑克数目
	self.cbDistributing = Create2Array(15, 6)							--分布信息
end

local tagWSKOutCardResult = class("tagWSKOutCardResult")
function tagWSKOutCardResult:ctor()
	self.cbTempCount = Create1Array(2)								--0 纯色组合个数；1 杂色组合个数
	self.cbResultCard = Create2Array(8, 3)							--组合扑克
end

local tagKingCount = class("tagKingCount")
function tagKingCount:ctor()
	self.cbKingCount = Create1Array(2)										--0 大王个数 1 小王个数
end		

local tagPlaneResult = class("tagPlaneResult")
function tagPlaneResult:ctor()
	-- body
	self.cbBodyCount = 0					--飞机数目
	self.cbBodyData = Create1Array(27)		--飞机数据
	self.cbWingCount = 0					--翅膀数目
	self.cbWingData = Create1Array(10)		--翅膀数据
	-- self.cbCardType = 1 					--飞机类型	三连  三带一 三带二
end

function GameLogic:CreateTagAnalyseResult()
	return tagAnalyseResult.new()
end

function GameLogic:CreateTagAnalyseColorResult()
	return tagAnalyseColorResult.new()
end

function GameLogic:CreateTagDistributing()
	return tagDistributing.new()
end

function GameLogic:CreateTagWSKOutCardResult()
	return tagWSKOutCardResult.new()
end

function GameLogic:CreateTagKingCount()
	return tagKingCount.new()
end

function GameLogic:CreateTagPlaneResult()
	-- body
	return tagPlaneResult.new()
end

function GameLogic:ctor()
	-- body
end

--@bLast 最后一手牌
function GameLogic:GetCardType(cbCardData, cbCardCount, bLast)
	if cbCardCount == 0 then return CT_ERROR end
	if cbCardCount == 1 then return CT_SINGLE end

	if cbCardCount == 2 then
		if self:GetCardValue(cbCardData[0]) == self:GetCardValue(cbCardData[1]) then 
			return CT_DOUBLE
		end
	end

	-- if cbCardCount == 3 then 
	-- 	if self:GetCardValue(cbCardData[0]) == self:GetCardValue(cbCardData[1]) and 
	-- 		self:GetCardValue(cbCardData[0]) == self:GetCardValue(cbCardData[2]) then
	-- 		return CT_THREE
	-- 	end
	-- end

	--王炸判断
	if cbCardCount == 4 and cbCardData[0] == 0x4F and cbCardData[3] == 0x4E then return CT_BOMB_KING end

	local AnalyseResult = self:CreateTagAnalyseResult()
	self:AnalyseCardData(cbCardData, cbCardCount, AnalyseResult)

	--五十K判断
	if cbCardCount == 3 then
		if self:GetCardValue(AnalyseResult.cbCardData[0][0]) == 0x0D and 
			self:GetCardValue(AnalyseResult.cbCardData[0][1]) == 0x0A and 
			self:GetCardValue(AnalyseResult.cbCardData[0][2]) == 0x05 then
			if self:GetCardColor(cbCardData[0]) == self:GetCardColor(cbCardData[1]) and 
				self:GetCardColor(cbCardData[0]) == self:GetCardColor(cbCardData[2]) then
				return CT_FLUSH_WU_SHI_K
			end

			return CT_WU_SHI_K
		end
	end

	--炸弹判断
	--四牌判断
	if AnalyseResult.cbBlockCount[3] == 1 and cbCardCount == 4 then
		return CT_BOMB_FOUR
	end

	if AnalyseResult.cbBlockCount[4] == 1 and cbCardCount == 5 then
		return CT_BOMB_FIVE
	end

	if AnalyseResult.cbBlockCount[5] == 1 and cbCardCount == 6 then
		return CT_BOMB_SIX
	end

	if AnalyseResult.cbBlockCount[6] == 1 and cbCardCount == 7 then
		return CT_BOMB_SEVEN
	end

	if AnalyseResult.cbBlockCount[7] == 1 and cbCardCount == 8 then
		return CT_BOMB_EIGHT
	end

	--三牌判断
	-- if AnalyseResult.cbBlockCount[2] > 0 then
	-- 	--三条类型
	-- 	if AnalyseResult.cbBlockCount[2] == 1 and cbCardCount == 3 then
	-- 		return CT_THREE
	-- 	end
	-- 	local bSerial = true
	-- 	--连牌判断
	-- 	if AnalyseResult.cbBlockCount[2] > 1 then
	-- 		local nThreeCount = AnalyseResult.cbBlockCount[2]
	-- 		local cbFirstCardData = AnalyseResult.cbCardData[2][0]
	-- 		local cbLastCardData = AnalyseResult.cbCardData[2][(nThreeCount - 1) * 3]
			
	-- 		local cbFirstLogicValue = self:GetCardLogicValue(cbFirstCardData)
	-- 		local cbLastLogicValue = self:GetCardLogicValue(cbLastCardData)

	-- 		if cbFirstLogicValue >= 15 then return CT_ERROR end
	-- 		bSerial = cbFirstLogicValue - cbLastLogicValue + 1 == nThreeCount
	-- 	end
	-- 	if bSerial then
	-- 		if AnalyseResult.cbBlockCount[2] * 3 == cbCardCount then return CT_THREE_LINE end
	-- 		if AnalyseResult.cbBlockCount[2] * 4 == cbCardCount then return CT_THREE_LINE_TAKE_ONE end
	-- 		if AnalyseResult.cbBlockCount[2] * 5 == cbCardCount then return CT_THREE_LINE_TAKE_TWO end
	-- 	end
	-- end

	local bType = self:IsThreeTakeXXX(cbCardData, cbCardCount, bLast)
	print("bType = ", bType)
	if bType then return CT_THREE_LINE_TAKE_XXX end

	--两牌判断
	if AnalyseResult.cbBlockCount[1] >= 2 and AnalyseResult.cbBlockCount[1] * 2 == cbCardCount then
		local nTwoCount = AnalyseResult.cbBlockCount[1]
		local cbFirstCardData = AnalyseResult.cbCardData[1][0]
		local cbLastCardData = AnalyseResult.cbCardData[1][(nTwoCount - 1) * 2]

		local cbFirstLogicValue = self:GetCardLogicValue(cbFirstCardData)
		local cbLastLogicValue = self:GetCardLogicValue(cbLastCardData)

		if cbFirstLogicValue >= 15 then return CT_ERROR end
		local bSerial = cbFirstLogicValue - cbLastLogicValue + 1 == nTwoCount

		-- for i = 1, AnalyseResult.cbBlockCount[1] - 1 do
		-- 	local cbCardDataNext = AnalyseResult.cbCardData[1][i * 2]
		-- 	local cbLogicValue = self:GetCardLogicValue(cbCardDataNext)
		-- 	if cbFirstLogicValue ~= cbLogicValue + i then  
		-- 		return CT_ERROR
		-- 	end
		-- end

		return bSerial and CT_DOUBLE_LINE or CT_ERROR
	end

	--单张判断
	if AnalyseResult.cbBlockCount[0] >= 2 then
		return CT_ERROR
	end

	return CT_ERROR
end

--获取花色
function GameLogic:GetCardColor(cbCardData)
	return CardHelper:getCardColor(cbCardData)
end

function GameLogic:GetCardValue(cbCardData)
	return CardHelper:getCardValue(cbCardData)
end

function GameLogic:GetCardLogicValue(cbCardData)
	return CardHelper:getCardLogicValue(cbCardData)
end

--排列扑克
--从大到小
function GameLogic:SortCardList(cbCardData, cbCardCount, cbSortType)
	if cbCardCount == 0 then return end
	if cbSortType == ST_CUSTOM then return end

	local cbSortValue = Create1Array(MAX_COUNT)

	for i = 0, cbCardCount - 1 do
		if cbSortType == ST_COUNT or cbSortType == ST_ORDER then
			cbSortValue[i] = self:GetCardLogicValue(cbCardData[i])
		elseif cbSortType == ST_VALUE then
			cbSortValue[i] = self:GetCardValue(cbCardData[i])
		elseif cbSortType == ST_COLOR then
			cbSortValue[i] = self:GetCardColor(cbCardData[i]) * 16 + CardHelper:getCardLogicValue(cbCardData[i])		
		end
	end

	--排序操作
	local bSorted = true
	local cbSwitchData = 0
	local cbLast = cbCardCount - 1
	repeat
		--从大到小排序
		bSorted = true
		for i = 0, cbLast - 1 do
			if cbSortValue[i] < cbSortValue[i + 1] or cbSortValue[i] == cbSortValue[i + 1] and cbCardData[i] < cbCardData[i + 1] then
				--设置标志
				bSorted = false

				--扑克数据
				cbSwitchData = cbCardData[i]
				cbCardData[i] = cbCardData[i + 1]
				cbCardData[i + 1] = cbSwitchData

				--排序权位
				cbSwitchData = cbSortValue[i]
				cbSortValue[i] = cbSortValue[i + 1]
				cbSortValue[i + 1] = cbSwitchData
			end
		end
		cbLast = cbLast - 1
	until (bSorted == true)

	--数目排序
	if cbSortType == ST_COUNT then

		--变量定义
		local cbCardIndex = 0

		--分析扑克
		local AnalyseResult = tagAnalyseResult.new()
		self:AnalyseCardData(cbCardData, cbCardCount, AnalyseResult);

		--提取扑克
		local num = table.nums(AnalyseResult.cbBlockCount)	--8
		for i = 0, num - 1 do
			--拷贝扑克
			local cbIndex = num - i - 1;
			--CopyMemory(&cbCardData[cbCardIndex], AnalyseResult.cbCardData[cbIndex], 
			--AnalyseResult.cbBlockCount[cbIndex] * (cbIndex + 1));
			CopyMemoryAtIndex(cbCardData, cbCardIndex, AnalyseResult.cbCardData, cbIndex, 
				AnalyseResult.cbBlockCount[cbIndex] * (cbIndex + 1))
			--设置索引
			cbCardIndex = cbCardIndex + AnalyseResult.cbBlockCount[cbIndex] * (cbIndex + 1)
		end
	end

	return
end

--从小到大排序
function GameLogic:SortCardList2(cbCardsData, cbCardsCount)
	local k = math.floor(cbCardsCount / 2)

	while (k > 0) do
		for i = k, cbCardsCount - 1 do
			local key = cbCardsData[i]
			local iRealValue = self:GetCardLogicValue(key)
			local j = i - k
			while j >= 0 and (iRealValue < self:GetCardLogicValue(cbCardsData[j]) or 
				iRealValue == self:GetCardLogicValue(cbCardsData[j]) and key < cbCardsData[j]) do
				cbCardsData[j + k] = cbCardsData[j]
				j = j - k
			end
			cbCardsData[j + k] = key
		end
		k  = math.floor(k / 2)
	end

	dump(cbCardsData, "排序后")
end

function GameLogic:SortCardColorList(cbCardData, cbCardCount)
	if cbCardCount == 0 then return end

	--先大小排序
	self:SortCardList(cbCardData, cbCardCount, ST_ORDER)

	--花色分析
	local ColorResult = self:CreateTagAnalyseColorResult()
	self:AnalyseCardColor(cbCardData, cbCardCount, ColorResult)

	--dump(ColorResult)
	--花色排序
	local cbCardPos = 0

	--大小王
	if ColorResult.cbKingCardCount > 0 then 
		CopyMemoryAtIndex(cbCardData, cbCardPos, ColorResult.cbKingCardData, 0, ColorResult.cbKingCardCount)
	end

	cbCardPos = ColorResult.cbKingCardCount

	--常主2
	if ColorResult.cbConstMainCount > 0  then
		for i = 0, ColorResult.cbConstMainCount - 1 do
			if self:GetCardColor(ColorResult.cbConstMainData[i]) == self.m_cbMainColor_ then
				cbCardData[cbCardPos] = ColorResult.cbConstMainData[i]
				cbCardPos = cbCardPos + 1
				break
			end
		end

		for i = 0, ColorResult.cbConstMainCount - 1 do
			if self:GetCardColor(ColorResult.cbConstMainData[i]) ~= self.m_cbMainColor_ then
				cbCardData[cbCardPos] = ColorResult.cbConstMainData[i]
				cbCardPos = cbCardPos + 1
			end
		end
	end

	--主
	if ColorResult.cbColorCardCount[self.m_cbMainColor_] > 0 then
		CopyMemoryAtIndex(cbCardData, cbCardPos, ColorResult.cbColorCardData[self.m_cbMainColor_], 0, ColorResult.cbColorCardCount[self.m_cbMainColor_])
	end

	cbCardPos = cbCardPos + ColorResult.cbColorCardCount[self.m_cbMainColor_]

	--非主
	for i = 3, 0, -1 do
		while true do
			if i == self.m_cbMainColor_ then break end

			if ColorResult.cbColorCardCount[i] > 0 then
				CopyMemoryAtIndex(cbCardData, cbCardPos, ColorResult.cbColorCardData[i], 0, ColorResult.cbColorCardCount[i])
				cbCardPos = cbCardPos + ColorResult.cbColorCardCount[i]
			end

			break
		end
	end
end

function GameLogic:SortOutCardList(cbCardData, cbCardCount, bLast)
	print("SortOutCardList")
	print("SortOutCardList")
	print("SortOutCardList")
	print("SortOutCardList")
	print("SortOutCardList")
	print("SortOutCardList")
	local card_type = self:GetCardType(cbCardData, cbCardCount, bLast)
	print("card_type = ", card_type)
	-- if card_type == CT_THREE_LINE_TAKE_ONE or card_type == CT_THREE_LINE_TAKE_TWO then
	-- 	self:SortCardList(cbCardData, cbCardCount, ST_ORDER)
	-- 	local AnalyseResult = tagAnalyseResult.new()
	-- 	self:AnalyseCardData(cbCardData, cbCardCount, AnalyseResult)

	-- 	local index = 0
	-- 	for i = AnalyseResult.cbBlockCount[2] - 1 , 0 , -1 do
	-- 		cbCardData[index + 2] = AnalyseResult.cbCardData[2][i * 3]
	-- 		cbCardData[index + 1] = AnalyseResult.cbCardData[2][i * 3 + 1]
	-- 		cbCardData[index] = AnalyseResult.cbCardData[2][i * 3 + 2]
	-- 		index = index + 3
	-- 	end

	-- 	for i = AnalyseResult.cbBlockCount[1] - 1, 0, -1 do
	-- 		cbCardData[index + 1] = AnalyseResult.cbCardData[1][i * 2]
	-- 		cbCardData[index] = AnalyseResult.cbCardData[1][i * 2 + 1]
	-- 		index = index + 2
	-- 	end

	-- 	for i = AnalyseResult.cbBlockCount[0] - 1, 0, -1 do
	-- 		cbCardData[index] = AnalyseResult.cbCardData[0][i]
	-- 		index = index + 1
	-- 	end
	-- else
	-- 	self:SortCardList2(cbCardData, cbCardCount)
	-- end

	if card_type == CT_THREE_LINE_TAKE_XXX then
		local PlaneResult = self:CreateTagPlaneResult()
		self:AnalysePlane(cbCardData, cbCardCount, PlaneResult)
		local index = 0
		if bLast then
			--填充机身
			for i = PlaneResult.cbBodyCount - 1, 0, -1 do
				cbCardData[index] = PlaneResult.cbBodyData[i * 3]
				cbCardData[index + 1] = PlaneResult.cbBodyData[i * 3 + 1]
				cbCardData[index + 2] = PlaneResult.cbBodyData[i * 3 + 2]
				index = index + 3 
			end
		else
			local body_count = cbCardCount / 5
			--填充机身
			for i = body_count - 1, 0, -1 do
				cbCardData[index] = PlaneResult.cbBodyData[i * 3]
				cbCardData[index + 1] = PlaneResult.cbBodyData[i * 3 + 1]
				cbCardData[index + 2] = PlaneResult.cbBodyData[i * 3 + 2]
				index = index + 3 
			end

			if body_count < PlaneResult.cbBodyCount then
				for i = body_count, PlaneResult.cbBodyCount - 1 do
					cbCardData[index] = PlaneResult.cbBodyData[i * 3]
					cbCardData[index + 1] = PlaneResult.cbBodyData[i * 3 + 1]
					cbCardData[index + 2] = PlaneResult.cbBodyData[i * 3 + 2]
					index = index + 3 
				end
			end
		end
		--填充翅膀
		for i = 0, PlaneResult.cbWingCount - 1 do
			cbCardData[index] = PlaneResult.cbWingData[i]
			index = index + 1
		end
	else
		self:SortCardList2(cbCardData, cbCardCount)
	end
end

--删除扑克
function GameLogic:RemoveCard(cbRemoveCard, cbRemoveCount, cbCardData, cbCardCount)
	--定义变量
	local cbDeleteCount = 0
	local cbTempCardData = Create1Array(MAX_COUNT)
	if cbCardCount > MAX_COUNT then return false end

	CopyMemory(cbTempCardData, cbCardData, cbCardCount)
	ZeroMemory(cbCardData, cbCardCount)

	--置零扑克
	for i = 0, cbRemoveCount - 1 do
		for j = 0, cbCardCount - 1 do
			if cbRemoveCard[i] == cbTempCardData[j] then
				cbDeleteCount = cbDeleteCount + 1
				cbTempCardData[j] = 0
				break 
			end
		end
	end
	if cbDeleteCount ~= cbRemoveCount then 
		return false 
	end

	--清理扑克
	local cbCardPos = 0
	for i = 0, cbCardCount - 1 do
		if cbTempCardData[i] ~= 0 then 
			cbCardData[cbCardPos] = cbTempCardData[i]
			cbCardPos = cbCardPos + 1
		end
	end
	return true	
end

--分析分布
function GameLogic:AnalyseDistributing(cbCardData, cbCardCount, Distributing)
	--设置变量
	--dump(Distributing)
	for i = 0, cbCardCount - 1 do
		while true do
			--todo
			if cbCardData[i] == 0 then break end
			--获取属性
			local cbCardColor = self:GetCardColor(cbCardData[i])
			local cbCardValue = self:GetCardValue(cbCardData[i])

			--分布信息
			--根据值索引 数组 0~5 0~3为花色 4为王 5是花色总数
			Distributing.cbCardCount = Distributing.cbCardCount + 1
			Distributing.cbDistributing[cbCardValue - 1][cbIndexCount] = Distributing.cbDistributing[cbCardValue-1][cbIndexCount] + 1
			Distributing.cbDistributing[cbCardValue - 1][cbCardColor] = Distributing.cbDistributing[cbCardValue-1][cbCardColor] + 1

			break
		end
	end
	--dump(Distributing, "Distributing", 4)
	return
end

--分析牌数据
function GameLogic:AnalyseCardData(cbCardData, cbCardCount, AnalyseResult)
	--为了实现i+=cbSameCount-1 操作
	local skipCount = 0

	for i = 0, cbCardCount - 1 do
		while true do
			if i < skipCount then break end
			local cbSameCount = 1
			local cbCardValueTemp = 0
			local cbLogicValue = CardHelper:getCardLogicValue(cbCardData[i])

			--搜索同牌
			for j = i + 1, cbCardCount - 1 do
				if CardHelper:getCardLogicValue(cbCardData[j]) ~= cbLogicValue then
					break
				end
				cbSameCount = cbSameCount + 1
			end
			--索引代表张数类型(名词) 值标识个数(量词)
			--记录当前牌数已有次数 再根据已有次数分布当前牌的所有数据
			local cbIndex = AnalyseResult.cbBlockCount[cbSameCount - 1]
			AnalyseResult.cbBlockCount[cbSameCount - 1] = AnalyseResult.cbBlockCount[cbSameCount - 1] + 1
			
			for j = 0, cbSameCount - 1 do
				AnalyseResult.cbCardData[cbSameCount - 1][cbIndex * cbSameCount + j] = cbCardData[i + j]
			end
			--这里与服务器代码不一样没有-1 因为:C++for循环结尾会根据当前的i值继续加1，
			--而lua中无法改变循环变量，所以直接+1，抵消了-1操作 也使用skipCount变量进行循环跳跃
			skipCount = i + cbSameCount
			break
		end
	end
end

function GameLogic:AnalyseCardColor(cbCardData, cbCardCount, ColorResult)
	assert(cbCardCount ~= 0)

	for i = 0, cbCardCount - 1 do
		local cbCardColor = self:GetCardColor(cbCardData[i])
		local cbCardLogicValue = self:GetCardLogicValue(cbCardData[i])

		if CardHelper.LOGIC_VALUE_2 == cbCardLogicValue then
			--常主
			ColorResult.cbConstMainData[ColorResult.cbConstMainCount] = cbCardData[i]
			ColorResult.cbConstMainCount = ColorResult.cbConstMainCount + 1
		elseif CardHelper.KING_COLOR == cbCardColor then
			--大小王
			ColorResult.cbKingCardData[ColorResult.cbKingCardCount] = cbCardData[i]
			ColorResult.cbKingCardCount = ColorResult.cbKingCardCount + 1
		else
			ColorResult.cbColorCardData[cbCardColor][ColorResult.cbColorCardCount[cbCardColor]] = cbCardData[i]
			ColorResult.cbColorCardCount[cbCardColor] = ColorResult.cbColorCardCount[cbCardColor] + 1
		end
	end

	--dump(ColorResult)
end

function GameLogic:AnalysePlane(cbCardData, cbCardCount, PlaneResult)
	-- body
	if cbCardCount < 3 then return end
	--构造临时变量，存储扑克
	local cbCardDataTemp = Create1Array(cbCardCount);
	local cbCardCountTemp = cbCardCount;
	CopyMemory(cbCardDataTemp, cbCardData, cbCardCount);
	local AnalyseResult = self:CreateTagAnalyseResult()
	self:AnalyseCardData(cbCardDataTemp, cbCardCountTemp, AnalyseResult)

	local threeTab = {}
	local bSerial = false
	local nThreeCount = 0
	for i = 2, SAME_CARD_MAX - 1 do
		for j = 0, AnalyseResult.cbBlockCount[i] - 1 do
			local logic_value = self:GetCardLogicValue(AnalyseResult.cbCardData[i][j * (i + 1)])

			if cbCardCount > 5 then
				if logic_value ~= 15 then
					nThreeCount = nThreeCount + 1
					threeTab[nThreeCount] = logic_value
				end
			else
				nThreeCount = nThreeCount + 1
				threeTab[nThreeCount] = logic_value
			end

			-- if logic_value ~= 15 then
			-- 	nThreeCount = nThreeCount + 1
			-- 	threeTab[nThreeCount] = logic_value
			-- end
		end
	end
	
	--print("nThreeCount = ", nThreeCount)
	if nThreeCount == 0 then return end
	if cbCardCount > nThreeCount * 5 then
		return
	end

	--从大到小排序
	table.sort(threeTab, function (a, b)
		-- body
		return a > b
	end)
	-- dump(cbCardDataTemp)
	--dump(threeTab)

	local bodyTab = {}
	local startIndex = 1
	local endIndex = 1
	local nCountinuousCount = 1

	for i = 1, #threeTab do
		for j = i + 1, #threeTab do
			if threeTab[i] - threeTab[j] == j - i then
				nCountinuousCount = nCountinuousCount + 1
				if j == #threeTab then

					if endIndex - startIndex + 1 < nCountinuousCount then
						startIndex = i
						endIndex = j
					end
					nCountinuousCount = 1
				end
			else
				if nCountinuousCount > endIndex - startIndex + 1 then
					startIndex = i
					endIndex = j - 1
				end
				nCountinuousCount = 1

				break
			end
		end
	end

	for i = startIndex, endIndex do
		table.insert(bodyTab, threeTab[i])
	end
	--dump(bodyTab)
	--local normal_count = #bodyTab * 5	--正常飞机数目
	-- self.cbBodyCount = 0					--飞机数目
	-- self.cbBodyData = Create1Array(27)		--飞机数据
	-- self.cbWingCount = 0					--翅膀数目
	-- self.cbWingData = Create1Array(10)		--翅膀数据
	-- self.cbCardType = 1 					--飞机类型	三连  三带一 三带二
	--PlaneResult.cbBodyCount = 0
	
	local recordTab = {}
	local index = 0
	--机身
	for i = 1, #bodyTab do
		recordTab[bodyTab[i]] = 0
		print("	i = ", i)
		for j = 0, cbCardCount - 1 do
			--print("		cbCardDataTemp[j] = ", cbCardDataTemp[j])
			if self:GetCardLogicValue(cbCardDataTemp[j]) == bodyTab[i] then
				PlaneResult.cbBodyData[index] = cbCardDataTemp[j]
				recordTab[bodyTab[i]] = recordTab[bodyTab[i]] + 1
				cbCardDataTemp[j] = 0
				index = index + 1
				if recordTab[bodyTab[i]] == 3 then
					PlaneResult.cbBodyCount = PlaneResult.cbBodyCount  + 1
					break
				end
			end
		end
	end
	--翅膀
	for i = 0, cbCardCount - 1 do
		if cbCardDataTemp[i] ~= 0 then
			PlaneResult.cbWingData[PlaneResult.cbWingCount] = cbCardDataTemp[i]
			PlaneResult.cbWingCount = PlaneResult.cbWingCount + 1
		end
	end 
end

function GameLogic:MakeCardData(cbValueIndex, cbColorIndex)
	return bit._or(cbColorIndex * 16, cbValueIndex + 1)
end

--排列扑克
function GameLogic:SortHandCardList(cbCardData, cbCardCount)

	--排序过虑
	if cbCardCount == 0 then return end

	--转换数值
	local cbSortValue = Create1Array(MAX_COUNT)
	for i = 0, cbCardCount - 1 do
		cbSortValue[i] = self:GetSortCardValue(cbCardData[i])
	end

	--排序操作
	local bSorted = true
	local cbSwitchData = 0
	local cbLast = cbCardCount - 1
	repeat
		bSorted = true
		for i = 0, cbLast - 1 do
			if (cbSortValue[i] < cbSortValue[i + 1]) or (cbSortValue[i] == cbSortValue[i + 1] and cbCardData[i] < cbCardData[i + 1]) then
				--设置标志
				bSorted = false

				--扑克数据
				cbSwitchData = cbCardData[i]
				cbCardData[i] = cbCardData[i + 1]
				cbCardData[i + 1] = cbSwitchData

				--排序权位
				cbSwitchData = cbSortValue[i]
				cbSortValue[i] = cbSortValue[i + 1]
				cbSortValue[i + 1] = cbSwitchData
			end	
		end
		cbLast = cbLast - 1
	until (bSorted == true)

	return
end

--获取排序数值
function GameLogic:GetSortCardValue(cbCardData)
	return CardHelper:getCardLogicValue(cbCardData)
end

function GameLogic:CompareCard(cbFirstCard, cbNextCard, cbFirstCount, cbNextCount, bFirstLast, bNextLast)
	-- body
	local cbNextType = self:GetCardType(cbNextCard, cbNextCount, bNextLast)
	local cbFirstType = self:GetCardType(cbFirstCard, cbFirstCount, bFirstLast)

	if cbNextType == CT_ERROR then
		assert(false, "GameLogic:CompareCard()  cbNextType == CT_ERROR!!!") 
		return false 
	end

	--1. 不同类型
	--炸弹判断
	if cbFirstType >= CT_WU_SHI_K and cbNextType < CT_WU_SHI_K then return false end
	if cbFirstType < CT_WU_SHI_K and cbNextType >= CT_WU_SHI_K then return true end

	if cbFirstType >= CT_WU_SHI_K and cbNextType >= CT_WU_SHI_K and cbFirstType ~= cbNextType then
		return cbNextType > cbFirstType
	end

	if cbFirstType == CT_THREE_LINE_TAKE_XXX and cbNextType == CT_THREE_LINE_TAKE_XXX then
		local FirstPlaneResult = self:CreateTagPlaneResult()
		local NextPlaneResult = self:CreateTagPlaneResult()
		self:AnalysePlane(cbFirstCard, cbFirstCount, FirstPlaneResult, bFirstLast)
		self:AnalysePlane(cbNextCard, cbNextCount, NextPlaneResult, bNextLast)
		dump(FirstPlaneResult, "FirstPlaneResult")
		dump(NextPlaneResult, "NextPlaneResult")
		local first_plane_count = 0
		if bFirstLast then
			-- 1 最后一手牌
			first_plane_count = FirstPlaneResult.cbBodyCount
		else
			first_plane_count = cbFirstCount / 5
		end
		local first_logic_value = self:GetCardLogicValue(FirstPlaneResult.cbBodyData[1])
		local next_logic_value = self:GetCardLogicValue(NextPlaneResult.cbBodyData[1])
		return first_plane_count == NextPlaneResult.cbBodyCount and first_logic_value < next_logic_value
	end
	--2.相同类型
	if cbFirstType ~= cbNextType or cbFirstCount ~= cbNextCount then return false end

	if cbNextType == CT_SINGLE or cbNextType == CT_DOUBLE or cbNextType == CT_THREE or cbNextType == CT_SINGLE_LINE or 
		cbNextType == CT_DOUBLE_LINE or cbNextType == CT_THREE_LINE or cbNextType == CT_BOMB_FOUR or cbNextType == CT_BOMB_FIVE or
		cbNextType == CT_BOMB_SIX or cbNextType == CT_BOMB_SEVEN or cbNextType == CT_BOMB_EIGHT then
		local cbNextLogicValue = self:GetCardLogicValue(cbNextCard[0])
		local cbFirstLogicValue = self:GetCardLogicValue(cbFirstCard[0])

		return cbNextLogicValue > cbFirstLogicValue
	-- elseif cbNextType == CT_THREE_LINE_TAKE_XXX then
	-- 	local NextResult = tagAnalyseResult.new()
	-- 	local FirstResult = tagAnalyseResult.new()
	-- 	self:AnalyseCardData(cbFirstCard, cbFirstCount, FirstResult)
	-- 	self:AnalyseCardData(cbNextCard, cbNextCount, NextResult)

	-- 	local cbNextLogicValue = self:GetCardLogicValue(NextResult.cbCardData[2][0])
	-- 	local cbFirstLogicValue = self:GetCardLogicValue(FirstResult.cbCardData[2][0])

	-- 	return cbNextLogicValue > cbFirstLogicValue
	elseif cbNextType == CT_WU_SHI_K then
		return false
	elseif cbNextType == CT_FLUSH_WU_SHI_K then
		local cbNextColor = self:GetCardColor(cbNextCard[0])
		local cbFirstColor = self:GetCardColor(cbFirstCard[0])

		return cbNextLogicColor > cbFirstLogicColor
	end


	assert(false, "GameLogic:CompareCard() ERROR!!!")
	return false
end

function GameLogic:IsValidCallCard(cbHandCardData, cbHandCardCount, cbCallCardData)
	if cbCallCardData == 0 then return false end

	local nCount = 0
	for i = 0, cbHandCardCount - 1 do
		if cbHandCardData[i] == cbCallCardData then
			nCount = nCount + 1
		end
	end

	if nCount >= 2 or nCount < 1 then return false end

	return true
end

--搜索王牌个数
function GameLogic:SearchKingCount(cbHandCardData, cbHandCardCount, OutCardKingResult)

	--构造临时变量，存储扑克
	local cbCardData = Create1Array(MAX_COUNT);
	local cbCardCount = cbHandCardCount;
	CopyMemory(cbCardData, cbHandCardData, cbHandCardCount);

	for i = 0, cbCardCount - 1 do
		--小王
		if CardHelper:getCardValue(cbCardData[i]) == 14 then
			if CardHelper:getCardColor(cbCardData[i]) == 4 then 
				OutCardKingResult.cbKingCount[1] = OutCardKingResult.cbKingCount[1] + 1
			end
		end
		--大王
		if CardHelper:getCardValue(cbCardData[i]) == 15 then 
			if CardHelper:getCardColor(cbCardData[i]) == 4 then 
				OutCardKingResult.cbKingCount[0] = OutCardKingResult.cbKingCount[0] + 1
			end
		end
	end
	return OutCardKingResult.cbKingCount[0] + OutCardKingResult.cbKingCount[1]
end

function GameLogic:SearchWuShiK(cbHandCardData, cbHandCardCount, OutCardWSKResult, bSorted)
	local cbCardData = Create1Array(MAX_COUNT)
	local cbCardCount = cbHandCardCount
	CopyMemory(cbCardData, cbHandCardData, cbHandCardCount)

	--查找五十K的,每种颜色的个数
	local tempFiveCount = Create1Array(4)
	local tempTenCount  = Create1Array(4)
	local tempKCount    = Create1Array(4)

	for i = 0, cbCardCount - 1 do
		local card_value = CardHelper:getCardValue(cbCardData[i])
		local card_color = CardHelper:getCardColor(cbCardData[i])
		--1. 查找五
		if card_value == 5 then 
			tempFiveCount[card_color] = tempFiveCount[card_color] + 1
		end

		--2. 查找十
		if card_value == 10 then
			tempTenCount[card_color] = tempTenCount[card_color] + 1
		end

		--2. 查找K
		if card_value == 13 then
			tempKCount[card_color] = tempKCount[card_color] + 1
		end
	end

	--1. 添加纯色的牌到数组的前几个文件中
	--i 四种花色
	for i = 0, 3 do
		local tempCount = 0
		--取最小数目 确保5 10 K 都有
		if tempFiveCount[i] > 0 and tempTenCount[i] > 0 and tempKCount[i] > 0 then
			tempCount = tempFiveCount[i]

			if tempCount > tempTenCount[i] then tempCount = tempTenCount[i] end
			if tempCount > tempKCount[i] then tempCount = tempKCount[i] end
		end

		--t该花色的数目
		for t = 0, tempCount - 1 do		
			if i == 0 then
				OutCardWSKResult.cbResultCard[ OutCardWSKResult.cbTempCount[0] ][0] = 0x05; 
				OutCardWSKResult.cbResultCard[ OutCardWSKResult.cbTempCount[0] ][1] = 0x0A;
				OutCardWSKResult.cbResultCard[ OutCardWSKResult.cbTempCount[0] ][2] = 0x0D;
			elseif i == 1 then
				OutCardWSKResult.cbResultCard[ OutCardWSKResult.cbTempCount[0] ][0] = 0x15; 
				OutCardWSKResult.cbResultCard[ OutCardWSKResult.cbTempCount[0] ][1] = 0x1A;
				OutCardWSKResult.cbResultCard[ OutCardWSKResult.cbTempCount[0] ][2] = 0x1D;
			elseif i == 2 then
				OutCardWSKResult.cbResultCard[ OutCardWSKResult.cbTempCount[0] ][0] = 0x25; 
				OutCardWSKResult.cbResultCard[ OutCardWSKResult.cbTempCount[0] ][1] = 0x2A;
				OutCardWSKResult.cbResultCard[ OutCardWSKResult.cbTempCount[0] ][2] = 0x2D;
			elseif i == 3 then
				OutCardWSKResult.cbResultCard[ OutCardWSKResult.cbTempCount[0] ][0] = 0x35; 
				OutCardWSKResult.cbResultCard[ OutCardWSKResult.cbTempCount[0] ][1] = 0x3A;
				OutCardWSKResult.cbResultCard[ OutCardWSKResult.cbTempCount[0] ][2] = 0x3D;
			end

			tempFiveCount[i] = tempFiveCount[i] - 1
			tempTenCount[i] = tempTenCount[i] - 1
			tempKCount[i] 	= tempKCount[i] - 1
			OutCardWSKResult.cbTempCount[0] = OutCardWSKResult.cbTempCount[0] + 1
		end
	end

	-- 取杂色50K
	local iFiveSum = tempFiveCount[0] + tempFiveCount[1] + tempFiveCount[2] + tempFiveCount[3]
	local iTenSum = tempTenCount[0] + tempTenCount[1] + tempTenCount[2] + tempTenCount[3]
	local iKSum = tempKCount[0] + tempKCount[1] + tempKCount[2] + tempKCount[3]

	if iFiveSum > 0 and iTenSum > 0 and iKSum > 0 then
		for i = 0, 3 do
			if tempFiveCount[i] > 0 and tempTenCount[i] > 0 and iKSum - tempKCount[i] > 0 then
				OutCardWSKResult.cbResultCard[OutCardWSKResult.cbTempCount[0] + OutCardWSKResult.cbTempCount[1]][0] = self:MakeCardData(0x05 - 1, i)
				OutCardWSKResult.cbResultCard[OutCardWSKResult.cbTempCount[0] + OutCardWSKResult.cbTempCount[1]][1] = self:MakeCardData(0x0A - 1, i)
				for j = 0, 3 do
					if j ~= i and tempKCount[j] > 0 then
						OutCardWSKResult.cbResultCard[OutCardWSKResult.cbTempCount[0] + OutCardWSKResult.cbTempCount[1]][2] = self:MakeCardData(0x0D - 1, j)
						break
					end
				end
				break
			elseif tempFiveCount[i] > 0 and iTenSum - tempTenCount[i] > 0 and tempKCount[i] > 0 then
				OutCardWSKResult.cbResultCard[OutCardWSKResult.cbTempCount[0] + OutCardWSKResult.cbTempCount[1]][0] = self:MakeCardData(0x05 - 1, i)
				OutCardWSKResult.cbResultCard[OutCardWSKResult.cbTempCount[0] + OutCardWSKResult.cbTempCount[1]][2] = self:MakeCardData(0x0D - 1, i)
				for j = 0, 3 do
					if j ~= i and tempTenCount[j] > 0 then
						OutCardWSKResult.cbResultCard[OutCardWSKResult.cbTempCount[0] + OutCardWSKResult.cbTempCount[1]][1] = self:MakeCardData(0x0A - 1, j)
						break
					end
				end
				break
			elseif tempFiveCount[i] > 0 and iTenSum - tempTenCount[i] > 0 and iKSum - tempKCount[i] then
				OutCardWSKResult.cbResultCard[OutCardWSKResult.cbTempCount[0] + OutCardWSKResult.cbTempCount[1]][0] = self:MakeCardData(0x05 - 1, i)
				for j = 0, 3 do
					local iCount = 0
					if j ~= i then
						if tempTenCount[j] > 0 then
							OutCardWSKResult.cbResultCard[OutCardWSKResult.cbTempCount[0] + OutCardWSKResult.cbTempCount[1]][1] = self:MakeCardData(0x0A - 1, j)
							iCount = iCount + 1
						end
						if tempKCount[j] > 0 then
							OutCardWSKResult.cbResultCard[OutCardWSKResult.cbTempCount[0] + OutCardWSKResult.cbTempCount[1]][2] = self:MakeCardData(0x0D - 1, j)
							iCount = iCount + 1
						end
						if iCount == 2 then break end
					end
				end
				break	
			end
		end
		OutCardWSKResult.cbTempCount[1] = OutCardWSKResult.cbTempCount[1] + 1
	end

	if bSorted then
		--提取50K
		local cbCardPos = 0
		for i = 0, OutCardWSKResult.cbTempCount[0] + OutCardWSKResult.cbTempCount[1] - 1 do
			for j = 0, 2 do
				local card_value = OutCardWSKResult.cbResultCard[i][j]
				cbHandCardData[cbCardPos] = card_value 
				cbCardPos = cbCardPos + 1
				for k = 0, cbCardCount - 1 do
					if card_value == cbCardData[k] then
						cbCardData[k] = 0
						break
					end
				end
			end
		end

		for i = 0, cbHandCardCount - 1 do
			if cbCardData[i] ~= 0 then
				cbHandCardData[cbCardPos] = cbCardData[i]
				cbCardPos = cbCardPos + 1
			end
		end
	end
	--如果没有得到组合则返回0
	if OutCardWSKResult.cbTempCount[0] + OutCardWSKResult.cbTempCount[1] > 0 then return true end

	return false
end

function GameLogic:IsThreeTakeXXX(cbCardData, cbCardCount, bLast)
	-- body
	local PlaneResult = self:CreateTagPlaneResult()
	self:AnalysePlane(cbCardData, cbCardCount, PlaneResult, bLast)
	--dump(PlaneResult)
	if bLast then
		print("【最后一手牌!!!!!】")
		if PlaneResult.cbBodyCount * 5 >= cbCardCount then
			return true
		end
	else
		print("【非最后一手牌!!!!!】")
		if cbCardCount % 5 == 0 and PlaneResult.cbBodyCount * 3 + PlaneResult.cbWingCount == cbCardCount then
			return true
		end
	end

	return false
end

--搜索连牌
function GameLogic:SearchLinkCard(cbHandCardData, cbHandCardCount, cbReferCard, cbCardType, cbTurnCardCount, OutCardResult)
	--A封顶,直接返回
	if self:GetCardValue(cbReferCard) == 1 then return false end

	--确定单元数据,连牌数目
	local byCellCount
	local byLinkCount

	if cbCardType == CT_SINGLE_LINK then
		byCellCount = 1
		byLinkCount = cbTurnCardCount
	elseif cbCardType == CT_DOUBLE_LINK then
		byCellCount = 2
		byLinkCount = cbTurnCardCount / 2
	else
		return false
	end

	if byLinkCount == 0 then byLinkCount = 3 end
	if cbHandCardCount < byCellCount * byLinkCount then return false end

	--确定搜索开始位置 byReferIndex = 2 是因为数组从0 开始 【2】 其实映射的是3
	local byReferIndex = 0
	if cbReferCard ~= 0 then
		byReferIndex = self:GetCardValue(cbReferCard) - byLinkCount + 1
	else byReferIndex = 2 end

	--分析扑克
	local Distribute = tagDistributing.new()
	self:AnalyseDistributing( cbHandCardData,cbHandCardCount,Distribute )

	--搜索常规顺子
	local byTempLinkCount = 0
	--同理 K对应的是12, K的逻辑值13-1
	--3 ~ K
	for i = byReferIndex, 12 do

		while true do
			--todo
			if Distribute.cbDistributing[i][cbIndexCount] < byCellCount then
				byTempLinkCount = 0
				break
			end

			--搜索到
			byTempLinkCount = byTempLinkCount + 1
			if byTempLinkCount == byLinkCount then
				--构造数据
				OutCardResult.cbCardCount = 0
				for j = i, i - byLinkCount + 1, -1 do
					local byCount = 0
					for k = 0, 3 do --四种花色
						if Distribute.cbDistributing[j][k] > 0 then 	--花色个数
							for n = 0, Distribute.cbDistributing[j][k] - 1 do
								OutCardResult.cbResultCard[OutCardResult.cbCardCount] = self:MakeCardData(j,k)
								OutCardResult.cbCardCount = OutCardResult.cbCardCount + 1
								byCount = byCount + 1
								if byCount == byCellCount then break end
							end
							if byCount == byCellCount then break end
						end
					end
					if byCount ~= byCellCount then
						--//AWASSERT(FALSE);
						return false
					end
				end
				return true
			end
			break
		end
	end

	--搜索到A的顺子
	if byTempLinkCount == byLinkCount - 1 and Distribute.cbDistributing[0][cbIndexCount] >= byCellCount then
		--构造数据
		OutCardResult.cbCardCount = 0
		local byCount = 0
		--放入A
		for k = 0, 3 do
			if Distribute.cbDistributing[0][k] > 0 then
				for n = 0, Distribute.cbDistributing[0][k] - 1 do
					OutCardResult.cbResultCard[OutCardResult.cbCardCount] = self:MakeCardData(0,k)
					OutCardResult.cbCardCount = OutCardResult.cbCardCount + 1
					byCount = byCount + 1
					if byCount == byCellCount then break end
				end
				if byCount == byCellCount then break end
			end
		end
		if byCount ~= byCellCount then
			return false;
		end
		--放入其他牌
		-- 14 - byLinkCount = 12 -(byTempLinkCount) + 1 = 12  - byLinkCount + 1 + 1 = 14 - byLinkCount 
		for i = 12, 14 - byLinkCount, -1 do
			byCount = 0
			for k = 0, 3 do
				if Distribute.cbDistributing[i][k] > 0 then
					for n = 0, Distribute.cbDistributing[i][k] - 1 do
						OutCardResult.cbResultCard[OutCardResult.cbCardCount] = self:MakeCardData(i,k)
						OutCardResult.cbCardCount = OutCardResult.cbCardCount + 1
						byCount = byCount + 1
						if byCount == byCellCount then break end
					end
					if byCount == byCellCount then break end
				end
			end
			if byCount ~= byCellCount then 
				--//AWASSERT(FALSE);
				return false
			end
		end
		return true
	end

	return false
end

-- 竖牌:单张 对子 
-- 横牌:顺子 连对
-- 混牌:三带二 三带一对
-- 炸弹
function GameLogic:GetOutCardTip(cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount, bTurnLast)
	local tipsTab = {}
	local tipsIndex = 1

	local cbTurnCardType = self:GetCardType(cbTurnCardData, cbTurnCardCount)

	if cbTurnCardType == CT_SINGLE or cbTurnCardType == CT_DOUBLE or cbTurnCardType == CT_THREE then
		tipsTab = self:SearchShuCard(cbTurnCardType, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
	elseif cbTurnCardType == CT_SINGLE_LINE or cbTurnCardType == CT_DOUBLE_LINE or cbTurnCardType == CT_THREE_LINE then
		tipsTab = self:SearchHengCard(cbTurnCardType, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
	elseif cbTurnCardType == CT_THREE_LINE_TAKE_XXX then
		tipsTab = self:SearchPlane(cbTurnCardType, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount, bTurnLast)
	-- elseif cbTurnCardType == CT_THREE_LINE_TAKE_ONE or cbTurnCardType == CT_THREE_LINE_TAKE_TWO then
	-- 	tipsTab = self:SearchMixture(cbTurnCardType, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
	elseif cbTurnCardType == CT_WU_SHI_K or cbTurnCardType == CT_FLUSH_WU_SHI_K then
		local temp1 = self:Search50K(cbTurnCardType, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
		table.insertto(tipsTab, temp1)
	elseif cbTurnCardType >= CT_BOMB_FOUR then
		local temp1 = self:SearchBomb(cbTurnCardType, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
		table.insertto(tipsTab, temp1)
	end

	return tipsTab
end

function GameLogic:SearchShuCard(cbOutCardType, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
	local AnalyseResult = self:CreateTagAnalyseResult()
	self:AnalyseCardData(cbHandCardData, cbHandCardCount, AnalyseResult)

	local tipsTab = {}
	local tipsIndex = 1
	--单元个数
	local cellCount = cbOutCardType
	--出牌值
	local outValue = self:GetCardLogicValue(cbTurnCardData[0])

	print("cellCount = ", cellCount)
	print("outValue = ", outValue)
	if AnalyseResult.cbBlockCount[cellCount - 1] > 0 then
		--有零散牌
		for i = AnalyseResult.cbBlockCount[cellCount - 1] - 1, 0, -1 do
			local card_data = AnalyseResult.cbCardData[cellCount - 1][i * cellCount]
			if self:GetCardLogicValue(card_data) > outValue then
				tipsTab[tipsIndex] = {}
				for j = 0, cellCount - 1 do
					tipsTab[tipsIndex][j + 1] = AnalyseResult.cbCardData[cellCount - 1][i * cellCount + j]
				end
				tipsIndex = tipsIndex + 1
			end
		end
	end

	local temp1 = self:Search50K(cbOutCardType, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
	table.insertto(tipsTab, temp1)

	local temp2 = self:SearchBomb(cbOutCardType, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
	table.insertto(tipsTab, temp2)

	--如果为空 再查找 同牌中的竖牌是否满足条件
	if #tipsTab == 0 then
		for i = cellCount + 1, 4 do
			for j = AnalyseResult.cbBlockCount[i - 1] - 1 , 0, -1 do
				local card_data = AnalyseResult.cbCardData[i - 1][j * i]
				local logic_data = self:GetCardLogicValue(card_data)
				if logic_data > outValue then
					tipsTab[tipsIndex] = {}
					for k = 0, cellCount - 1 do
						tipsTab[tipsIndex][k + 1] = AnalyseResult.cbCardData[i - 1][j * i + i - k - 1] --从右向左开始取
					end
					tipsIndex = tipsIndex + 1
				end
			end
		end
	end

	return tipsTab
end

function GameLogic:SearchHengCard(cbOutCardType, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
	--单元个数
	local cellCount = 1
	local linkCount = 1
	if cbOutCardType == CT_SINGLE_LINE then
		cellCount = 1
	elseif cbOutCardType == CT_DOUBLE_LINE then
		cellCount = 2
	elseif cbOutCardType == CT_THREE_LINE then
		cellCount = 3
	end
	linkCount = cbTurnCardCount / cellCount

	print("cellCount = ", cellCount)
	print("linkCount = ", linkCount)
	local tipsTab = {}
	local tipsIndex = 1

	local Distributing = self:CreateTagDistributing()
	self:AnalyseDistributing(cbHandCardData, cbHandCardCount, Distributing)

	local OutCardDistributing = self:CreateTagDistributing()
	self:AnalyseDistributing(cbTurnCardData, cbTurnCardCount, OutCardDistributing)

	--如果出牌顺子到A 或 K 则不提取
	if OutCardDistributing.cbDistributing[0][cbIndexCount] == 0 or OutCardDistributing.cbDistributing[12][cbIndexCount] == 0 then
		local startIndex = -1
		local endIndex = -1
		-- 3~9
		for i = 2, 12 - linkCount + 1 do
			local iOutCardNum = OutCardDistributing.cbDistributing[i][cbIndexCount]
			local iHandCardNum = Distributing.cbDistributing[i + 1][cbIndexCount]

			--找到了出牌顺子 起始位
			if iOutCardNum > 0 then
				if startIndex == -1 then 
					startIndex = i 
					break
				end
			end
		end

		startIndex = startIndex + 1
		--12 搜索到K 13 搜索到A
		while startIndex <= 13 - linkCount + 1 do
			--todo
			local bFind = false
			for j = 0, linkCount - 1 do
				local tempIndex = startIndex + j == 13 and 0 or startIndex + j

				local iHandCardNum = Distributing.cbDistributing[tempIndex][cbIndexCount]
				bFind = iHandCardNum >= cellCount
				if not bFind then break end

			end
			if bFind then
				--找到 提取
				tipsTab[tipsIndex] = {}
				local addCount = 0
				for inc = 0, linkCount - 1 do

					local valueIndex = startIndex + inc
					valueIndex = valueIndex == 13 and 0 or valueIndex
					local cellNum = 0
					--i 花色
					for i = 0, 3 do
						--j花色数目 
						for j = 1, Distributing.cbDistributing[valueIndex][i] do
							cellNum = cellNum + 1
							addCount = addCount + 1
							tipsTab[tipsIndex][addCount] = self:MakeCardData(valueIndex, i)
							if cellNum == cellCount then break end
						end
						if cellNum == cellCount then break end
					end
				end
				tipsIndex = tipsIndex + 1
			end
			startIndex = startIndex + 1
		end
	end

	local temp1 = self:Search50K(cbOutCardType, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
	table.insertto(tipsTab, temp1)

	local temp2 = self:SearchBomb(cbOutCardType, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
	table.insertto(tipsTab, temp2)

	return tipsTab
end

function GameLogic:SearchPlane(cbOutCardType, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount, bTurnLast)
	-- body
	local tipsTab = {}
	local tipsIndex = 1
	local PlaneResult = self:CreateTagPlaneResult()
	self:AnalysePlane(cbTurnCardData, cbTurnCardCount, PlaneResult)

	local AnalyseResult = self:CreateTagAnalyseResult()
	self:AnalyseCardData(cbHandCardData, cbHandCardCount, AnalyseResult)

	local cbReferBodyCount = 0 --出牌机身数目
	local cbReferWingCount = 0 --参考翅膀数目
	local cbReferCardData = 0  --飞机标识值

	if bTurnLast then
		cbReferBodyCount = PlaneResult.cbBodyCount
	else
		cbReferBodyCount = cbTurnCardCount / 5
	end
	cbReferWingCount = cbReferBodyCount * 2
	cbReferCardData = self:GetCardLogicValue(PlaneResult.cbBodyData[(cbReferBodyCount - 1) * 3])
	--print("参考翅膀数目:", cbReferWingCount)
	--print("参考飞机值:", cbReferCardData)
	--找三张
	local cbThreeCount = AnalyseResult.cbBlockCount[2]
	--print("自身三张数目:", cbThreeCount)
	if cbThreeCount >= cbReferBodyCount then
		for i = 0, cbThreeCount - 1  do
			local cbReferCardTemp = self:GetCardLogicValue(AnalyseResult.cbCardData[2][i * 3])
			--print("当前比较值:", cbReferCardTemp)
			if cbReferCardTemp > cbReferCardData then
				local planeTab = {}
				local planeIndex = 0

				--判断相邻三张
				for j = 0, cbReferBodyCount - 1 do
					--飞机排除2
					local cbNextCardTemp = self:GetCardLogicValue(AnalyseResult.cbCardData[2][(i + j) * 3])

					--三连数大于1时 三张不能有2
					if cbReferBodyCount > 1 and cbNextCardTemp == 15 then
						planeTab = {}
						planeIndex = 0
						break
					end

					if i + j >= cbThreeCount or cbReferCardTemp - j ~= cbNextCardTemp then
						planeTab = {}
						planeIndex = 0
						break
					end

					planeTab[planeIndex + 1] = AnalyseResult.cbCardData[2][(i + j) * 3]
					planeTab[planeIndex + 2] = AnalyseResult.cbCardData[2][(i + j) * 3 + 1]
					planeTab[planeIndex + 3] = AnalyseResult.cbCardData[2][(i + j) * 3 + 2]
					planeIndex = planeIndex + 3
				end

				--找翅膀
				if planeIndex ~= 0 then
			    	local cbHandCardDataTemp = clone(cbHandCardData)
			    	local cbHandCardCountTemp = cbHandCardCount

			    	local tabTemp = ConvertTableToArray(planeTab, planeIndex)
				    self:RemoveCard(tabTemp, planeIndex, cbHandCardDataTemp, cbHandCardCountTemp)
				    cbHandCardCountTemp = cbHandCardCountTemp - planeIndex
				    --print("cbHandCardCountTemp = ", cbHandCardCountTemp)
				    if cbHandCardCountTemp < cbReferWingCount then
				    	for i = 0, cbHandCardCountTemp - 1 do
				    		planeIndex = planeIndex + 1
				    		planeTab[planeIndex] = cbHandCardDataTemp[i]
				    	end
				    else
				    	for i = cbHandCardCountTemp - cbReferWingCount,  cbHandCardCountTemp - 1 do
				    		planeIndex = planeIndex + 1
				    		planeTab[planeIndex] = cbHandCardDataTemp[i]
				    	end
				    end

				    tipsTab[tipsIndex] = {} or tipsTab[tipsIndex]
				    table.insertto(tipsTab[tipsIndex], planeTab)
					tipsIndex = tipsIndex + 1

				end
			end
		end
	end

	local temp1 = self:Search50K(cbOutCardType, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
	table.insertto(tipsTab, temp1)

	local temp2 = self:SearchBomb(cbOutCardType, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
	table.insertto(tipsTab, temp2)

	return tipsTab

end

--搜索正规三带类型
function GameLogic:SearchMixture(cbOutCardType, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
	local AnalyseResult = self:CreateTagAnalyseResult()
	self:AnalyseCardData(cbHandCardData, cbHandCardCount, AnalyseResult)

	local tipsTab = {}
	local tipsIndex = 1

	--分析出牌玩家扑克
	local AnalyseOutCardResult = tagAnalyseResult.new()
	self:AnalyseCardData(cbTurnCardData, cbTurnCardCount, AnalyseOutCardResult)
	--起始牌
	local cbTurnThreeCount = AnalyseOutCardResult.cbBlockCount[2]
	local cbReferCard = self:GetCardLogicValue(AnalyseOutCardResult.cbCardData[2][(cbTurnThreeCount - 1) * 3])

	local linkCount = 1
	local wingCount = 1
	if cbOutCardType == CT_THREE_LINE_TAKE_ONE then
		linkCount = cbTurnCardCount / 4
		wingCount = lineCount
	elseif cbOutCardType == CT_THREE_LINE_TAKE_TWO then
		linkCount = cbTurnCardCount / 5
		wingCount = linkCount * 2
	end

	print("linkCount = ", linkCount)
	print("wingCount = ", wingCount)
	--找三张
	local cbThreeCount = AnalyseResult.cbBlockCount[2]

	if cbThreeCount >= linkCount and cbHandCardCount >= cbTurnCardCount then
		for i = 0, cbThreeCount - 1  do
			local cbReferCardTemp = self:GetCardLogicValue(AnalyseResult.cbCardData[2][i * 3])

			if cbReferCardTemp > cbReferCard then
				local planeTab = {}
				local planeIndex = 0
			
				--判断相邻三张
				for j = 0, linkCount - 1 do
					--飞机排除2
					local cbNextCardTemp = self:GetCardLogicValue(AnalyseResult.cbCardData[2][(i + j) * 3])

					--三连数大于1时 三张不能有2
					if linkCount > 1 and cbNextCardTemp == 15 then
						planeTab = {}
						planeIndex = 0
						break
					end

					if i + j >= cbThreeCount or cbReferCardTemp - j ~= cbNextCardTemp then
						planeTab = {}
						planeIndex = 0
						break
					end

					planeTab[planeIndex + 1] = AnalyseResult.cbCardData[2][(i + j) * 3]
					planeTab[planeIndex + 2] = AnalyseResult.cbCardData[2][(i + j) * 3 + 1]
					planeTab[planeIndex + 3] = AnalyseResult.cbCardData[2][(i + j) * 3 + 2]
					planeIndex = planeIndex + 3
				end
				--找翅膀
				if planeIndex ~= 0 then
					local wingTab = {}
					local nCount = 0
					if cbOutCardType == CT_THREE_LINE_TAKE_ONE then

					elseif cbOutCardType == CT_THREE_LINE_TAKE_TWO then
						--单张足够
						if AnalyseResult.cbBlockCount[0] >= wingCount then
							print("	Step 1 !!!")
							for k = AnalyseResult.cbBlockCount[0] - 1, 0, -1 do
								nCount = nCount + 1
								wingTab[nCount] = AnalyseResult.cbCardData[0][k]

								if nCount == wingCount then break end
							end
						elseif AnalyseResult.cbBlockCount[1] >= wingCount / 2 then
							print("	Step 2 !!!")
							for k = AnalyseResult.cbBlockCount[1] - 1, 0, -1 do
								wingTab[nCount + 1] = AnalyseResult.cbCardData[1][k * 2]
								wingTab[nCount + 2] = AnalyseResult.cbCardData[1][k * 2 + 1]
								nCount = nCount + 2

								if nCount == wingCount then break end
							end
						else
							print("	Step 3 !!!")
							--删除飞机 搜索翅膀
							--翅膀不能是飞机中的数字
							--翅膀不能有三个相同的Logic值
					    	local cbHandCardDataTemp = clone(cbHandCardData)
					    	local cbHandCardCountTemp = cbHandCardCount

					    	local tabTemp = ConvertTableToArray(planeTab, planeIndex)
						    self:RemoveCard(tabTemp, planeIndex, cbHandCardDataTemp, cbHandCardCountTemp)
						    cbHandCardCountTemp = cbHandCardCountTemp - planeIndex


							local AnalyseResultTemp = tagAnalyseResult.new()
							self:AnalyseCardData(cbHandCardDataTemp, cbHandCardCountTemp, AnalyseResultTemp)

							local lookup_table = {}
					    	local i = cbHandCardCountTemp - 1
					    	while i >= 0 do
					    		local card_data = cbHandCardDataTemp[i]
					    		local card_logic_value = self:GetCardValue(cbHandCardDataTemp[i])

					    		local bIn = false
					    		--翅膀不能是飞机中的数字
					    		for i, v in ipairs(planeTab) do
					    			if card_logic_value == self:GetCardValue(v) then
					    				bIn = true
					    				break
					    			end
					    		end

					    		if not bIn then
					    			--翅膀不能有三个相同的Logic值
					    			lookup_table[card_logic_value] = lookup_table[card_logic_value] or 0
					    			if lookup_table[card_logic_value] < 2 then
					    				lookup_table[card_logic_value] = lookup_table[card_logic_value] + 1
					    				nCount = nCount + 1
					    				wingTab[nCount] = card_data
					    			end
					    		end
					    		if nCount == wingCount then break end
					    		i = i - 1
					    	end
						end
					end

					
					tipsTab[tipsIndex] = tipsTab[tipsIndex] or {}
					table.insertto(planeTab, wingTab)
					table.insertto(tipsTab[tipsIndex], planeTab)
					tipsIndex = tipsIndex + 1
				end
			end
		end
	end

	if cbOutCardType == CT_THREE_LINE_TAKE_ONE then
		--找单张
	elseif cbOutCardType == CT_THREE_LINE_TAKE_TWO then

	end

	local temp1 = self:Search50K(cbOutCardType, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
	table.insertto(tipsTab, temp1)

	return tipsTab
end

function GameLogic:SearchKing(cbOutCardType, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
	--搜索王炸
	local tipsTab = {}
	local tipsIndex = 1

	local OutCardKingResult = self:CreateTagKingCount()
	self:SearchKingCount(cbHandCardData, cbHandCardCount, OutCardKingResult)

	local bFind = false

	if cbOutCardType < CT_BOMB_KING then
		bFind = OutCardKingResult.cbKingCount[0] + OutCardKingResult.cbKingCount[1] == 4
	elseif cbOutCardType == CT_BOMB_EIGHT then
		return tipsTab
	end

	if not bFind then
		return tipsTab
	end

	if OutCardKingResult.cbKingCount[0] > 1 or OutCardKingResult.cbKingCount[1] > 1 
		or OutCardKingResult.cbKingCount[0] > 0 and OutCardKingResult.cbKingCount[1] > 0 then
		tipsTab[tipsIndex] = {}
		for i = 1, OutCardKingResult.cbKingCount[0] do
			tipsTab[tipsIndex][i] = 0x4F
		end
		for i = 1, OutCardKingResult.cbKingCount[1] do
			tipsTab[tipsIndex][i + OutCardKingResult.cbKingCount[0]] = 0x4E
		end
	end

	return tipsTab
end

function GameLogic:SearchBomb(cbOutCardType, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
	local tipsTab = {}
	local tipsIndex = 1

	local AnalyseResult = self:CreateTagAnalyseResult()
	self:AnalyseCardData(cbHandCardData, cbHandCardCount, AnalyseResult)
	--比较值
	local byCount = 4
	local byValue = 0

	print("GameLogic:SearchBomb =========> cbOutCardType = ", cbOutCardType)
	if cbOutCardType < CT_BOMB_FOUR then
		byCount = 4
	elseif cbOutCardType == CT_BOMB_KING then
		byCount = 8
	else
		--炸弹类型
		byCount = cbTurnCardCount
		byValue = CardHelper:getCardLogicValue(cbTurnCardData[0])
	end

	--搜索炸弹 	i 张数 j 该张数炸弹的个数 k 炸弹具体组成值
	for i = byCount, 8 do
		for j = AnalyseResult.cbBlockCount[i - 1] - 1, 0, -1 do
			if i == byCount and CardHelper:getCardLogicValue(AnalyseResult.cbCardData[i - 1][j * i]) > byValue or 
				i > byCount then
				tipsTab[tipsIndex] = tipsTab[tipsIndex] or {}
				for k = 0, i - 1 do
					tipsTab[tipsIndex][k + 1] = AnalyseResult.cbCardData[i - 1][j * i + k]
				end
				tipsIndex = tipsIndex + 1
			end
		end
	end

	if cbOutCardType < CT_BOMB_KING then
		local temp3 = self:SearchKing(cbOutCardType, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
		table.insertto(tipsTab, temp3)
	end

	return tipsTab
end

function GameLogic:Search50K(cbOutCardType, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
	--搜索50k
	local tipsTab = {}
	local tipsIndex = 1
	local byCount = 0
	local byColor = -1

	local OutCardWSKResult = self:CreateTagWSKOutCardResult()
	self:SearchWuShiK(cbHandCardData, cbHandCardCount, OutCardWSKResult)

	if cbOutCardType < CT_WU_SHI_K then
		byCount = OutCardWSKResult.cbTempCount[0] + OutCardWSKResult.cbTempCount[1]
	elseif cbOutCardType == CT_WU_SHI_K then
		byCount = OutCardWSKResult.cbTempCount[0]	
	elseif cbOutCardType == CT_FLUSH_WU_SHI_K then
		byCount = OutCardWSKResult.cbTempCount[0]
		byColor = CardHelper:getCardColor(cbTurnCardData[0])
	else
		return tipsTab
	end

	for i = 0, byCount - 1 do
		if CardHelper:getCardColor(OutCardWSKResult.cbResultCard[i][0]) > byColor then
			tipsTab[tipsIndex] = tipsTab[tipsIndex] or {}
			tipsTab[tipsIndex][1] = OutCardWSKResult.cbResultCard[i][0]
			tipsTab[tipsIndex][2] = OutCardWSKResult.cbResultCard[i][1]
			tipsTab[tipsIndex][3] = OutCardWSKResult.cbResultCard[i][2]
			tipsIndex = tipsIndex + 1
		end
	end

	local temp2 = self:SearchBomb(cbOutCardType, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
	table.insertto(tipsTab, temp2)

	return tipsTab
end

function GameLogic:typeDebug(cardType)
	-- body
	print("--------------------------GameLogic:typeDebug---------------------")

	if cardType == CT_ERROR then
		print("出牌类型:错误")
	elseif cardType == CT_SINGLE then
		print("出牌类型:单张")
	elseif cardType == CT_DOUBLE then
		print("出牌类型:对子")
	elseif cardType == CT_THREE then
		print("出牌类型:三条")
	elseif cardType == CT_SINGLE_LINE then
		print("出牌类型:单顺")
	elseif cardType == CT_DOUBLE_LINE then
		print("出牌类型:双顺")
	elseif cardType == CT_THREE_LINE then
		print("出牌类型:三连")
	-- elseif cardType == CT_THREE_LINE_TAKE_ONE then
	-- 	print("出牌类型:三带一")
	-- elseif cardType == CT_THREE_LINE_TAKE_TWO then
	-- 	print("出牌类型:三带二")
	elseif cardType == CT_THREE_LINE_TAKE_XXX then
		print("出牌类型:三带类型")
	-- elseif cardType == CT_OLD_PLANE then
	-- 	print("出牌类型:残飞机")
	-- elseif cardType == CT_NEW_PLANE then
	-- 	print("出牌类型:全飞机")
	elseif cardType == CT_WU_SHI_K then
		print("出牌类型:50K")
	elseif cardType == CT_FLUSH_WU_SHI_K then
		print("出牌类型:同花50K")
	elseif cardType == CT_BOMB_FOUR then
		print("出牌类型:四炸")
	elseif cardType == CT_BOMB_FIVE then
		print("出牌类型:五炸")
	elseif cardType == CT_BOMB_SIX then
		print("出牌类型:六炸")
	elseif cardType == CT_BOMB_SEVEN then
		print("出牌类型:七炸")
	elseif cardType == CT_BOMB_EIGHT then
		print("出牌类型:八炸")
	end									
end

return GameLogic
--------------------------------------------------------------------------------------------------------------------------------------