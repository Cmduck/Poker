require("script.50kScript.common.GameDefine")
local CardHelper = require("script.50kScript.card.CardHelper")
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

local tagOutCardResult = class("tagOutCardResult")
function tagOutCardResult:ctor()
	self.cbCardCount = 0												--扑克数目
	self.cbResultCard = Create1Array(MAX_COUNT)							--结果扑克	
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

function GameLogic:CreateTagAnalyseResult()
	return tagAnalyseResult.new()
end

function GameLogic:CreateTagOutCardResult()
	return tagOutCardResult.new()
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

function GameLogic:ctor()
	-- body
end

function GameLogic:GetCardType(cbCardData, cbCardCount)
	--简单类型
	if cbCardCount == 0 then 	--空牌
		return CT_ERROR
	elseif cbCardCount == 1 then --单牌
		--todo
		return CT_SINGLE
	elseif cbCardCount == 2 then 	--对牌
		--对大王
		if cbCardData[0] == 0x4F and cbCardData[1] == 0x4F then
			return CT_BIG_KING
		end
		--对大小王
		if cbCardData[0] == 0x4F and cbCardData[1] == 0x4E then
			return CT_DOUBLE_KING
		end

		--对小王
		if cbCardData[0] == 0x4E and cbCardData[1] == 0x4E then
			return CT_SMALL_KING
		end

		--2张普通的牌
		if CardHelper:getCardValue(cbCardData[0]) == CardHelper:getCardValue(cbCardData[1]) then
			return CT_DOUBLE
		end
		return CT_ERROR		
	end
	--分析扑克
	print("--------------------------构造数据--------------------")
	local AnalyseResult = self:CreateTagAnalyseResult()
	self:AnalyseCardData(cbCardData, cbCardCount, AnalyseResult)
	--dump(AnalyseResult, nil, 4)
	--炸弹类型
	--18. 无敌炸
	if cbCardCount == 4 and cbCardData[0] == 0x4F and cbCardData[3] == 0x4E then
		return CT_UNMATCHED_BOMB
	end

	--对3张到8张牌的判断
	if cbCardCount >= 3 and cbCardCount <= 8 then 
	
		if cbCardCount==3 then
			--5. 3张炸弹
			if AnalyseResult.cbBlockCount[cbCardCount-1] == 1 then  
				return CT_BOMB_THREE
			end
			--进入五时K的两中判断 
			if CardHelper:getCardValue(AnalyseResult.cbCardData[0][0]) == CardHelper.CARD_K and 
				CardHelper:getCardValue(AnalyseResult.cbCardData[0][1]) == CardHelper.CARD_10 and 
				CardHelper:getCardValue(AnalyseResult.cbCardData[0][2]) == CardHelper.CARD_5 then

				--10. 同化花五十K=======颜色相同
				if CardHelper:getCardColor(cbCardData[0]) == CardHelper:getCardColor(cbCardData[1]) and 
					CardHelper:getCardColor(cbCardData[0]) == CardHelper:getCardColor(cbCardData[2]) then
					return CT_WU_SHI_THK
				end

				--8. 杂五十K============颜色不相同
				return CT_WU_SHI_K			
				
			end
			--14. 左对王（两小王一大王）
			if cbCardData[0] == 0x4F and cbCardData[1] == 0x4E and cbCardData[2] == 0x4E then
				return CT_LEFT_KING
			end
			--15. 右对王（两大王一小王）
			if cbCardData[0] == 0x4F and cbCardData[1] == 0x4F and cbCardData[2] == 0x4E then
				return CT_RIGHT_KING
			end
		end

		if cbCardCount == 4 and AnalyseResult.cbBlockCount[cbCardCount-1] == 1 then return CT_BOMB_FOUR end   --6. 4张炸弹
		if cbCardCount == 5 and AnalyseResult.cbBlockCount[cbCardCount-1] == 1 then return CT_BOMB_FIVE end   --7. 5张炸弹
		if cbCardCount == 6 and AnalyseResult.cbBlockCount[cbCardCount-1] == 1 then return CT_BOMB_SIX end    --9. 6张炸弹
		if cbCardCount == 7 and AnalyseResult.cbBlockCount[cbCardCount-1] == 1 then return CT_BOMB_SEVEN end  --11. 7张炸弹
		if cbCardCount == 8 and AnalyseResult.cbBlockCount[cbCardCount-1] == 1 then return CT_HEAVEN_BOMB end --17. 天炸
	end

	--3. CT_SINGLE_LINK 顺子类型===========相邻的三张即可做顺子牌出
	if cbCardCount >= 3 and AnalyseResult.cbBlockCount[0] == cbCardCount then
		--进入五时K的两中判断 
		if cbCardCount == 3 and CardHelper:getCardValue(AnalyseResult.cbCardData[0][0]) == 0x0D and 
			CardHelper:getCardValue(AnalyseResult.cbCardData[0][1]) == 0x0A and 
			CardHelper:getCardValue(AnalyseResult.cbCardData[0][2]) == 0x05 then
			--10. 同化花五十K=======颜色相同
			if CardHelper:getCardColor(cbCardData[0]) == CardHelper:getCardColor(cbCardData[1]) and 
				CardHelper:getCardColor(cbCardData[0]) == CardHelper:getCardColor(cbCardData[2]) then
				return CT_WU_SHI_THK
			end
			--8. 杂五十K============颜色不相同
			return CT_WU_SHI_K		
			
		end

		--变量定义
		local cbTempCardData = AnalyseResult.cbCardData[0][0]
		local cbFirstLogicValue = CardHelper:getCardLogicValue(cbTempCardData)

		--当最大的那张牌(>=2)的时候……
		if cbFirstLogicValue >= 15 then return CT_ERROR end

		local cbSignedCount = AnalyseResult.cbBlockCount[0]
		local bStructureLink = self:IsStructureLink(AnalyseResult.cbCardData[0],cbSignedCount,1)
		
		--类型判断
		if bStructureLink == true then return CT_SINGLE_LINK end
	end

	--对连类型
	if cbCardCount >=6 and AnalyseResult.cbBlockCount[1]*2 == cbCardCount then
		--变量定义
		local cbTempCardData = AnalyseResult.cbCardData[1][0];
		local cbFirstLogicValue = CardHelper:getCardLogicValue(cbTempCardData)

		--错误过虑
		if cbFirstLogicValue >= 15 then return CT_ERROR end

		local cbDoubleCount = AnalyseResult.cbBlockCount[1] * 2
		if self:IsStructureLink(AnalyseResult.cbCardData[1],cbDoubleCount,2) == true then return CT_DOUBLE_LINK end

		
	end	
	return CT_ERROR
end

--获取花色
function GameLogic:GetCardColor(cbCardData, cbCardCount)
	if cbCardCount == 0 then return 0xF0 end

	local cbCardColor = CardHelper:getCardColor(cbCardData[0])

	for i = 0, cbCardCount - 1 do
		if CardHelper:getCardColor(cbCardData[i]) ~= cbCardColor then
			return 0xF0
		end
	end

	return cbCardColor
end

--排列扑克
function GameLogic:SortCardList(cbCardData, cbCardCount, cbSortType)
	if cbCardCount == 0 then return end
	if cbSortType == ST_CUSTOM then return end

	local cbSortValue = Create1Array(MAX_COUNT)

	for i = 0, cbCardCount - 1 do
		if cbSortType == ST_COUNT or cbSortType == ST_ORDER then
			cbSortValue[i] = CardHelper:getCardLogicValue(cbCardData[i])
		elseif cbSortType == ST_VALUE then
			cbSortValue[i] = CardHelper:getCardValue(cbCardData[i])
		elseif cbSortType == ST_COLOR then
			cbSortValue[i] = CardHelper:getCardColor(cbCardData[i]) * 16 + CardHelper:getCardLogicValue(cbCardData[i])		
		end
	end

	--排序操作
	local bSorted = true
	local cbSwitchData = 0
	local cbLast = cbCardCount - 1
	repeat
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
			local iRealValue = CardHelper:getCardLogicValue(key)
			local j = i - k
			while j >= 0 and (iRealValue < CardHelper:getCardLogicValue(cbCardsData[j]) or iRealValue == CardHelper:getCardLogicValue(cbCardsData[j]) and cbCardsData[i] < cbCardsData[j]) do
				cbCardsData[j + k] = cbCardsData[j]
				j = j - k
			end
			cbCardsData[j + k] = key
		end
		k  = math.floor(k / 2)
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
	-- print("移除手牌:")
	-- dump(cbRemoveCard)
	-- print("移除个数:")
	-- print(cbRemoveCount)

	-- print("我的手牌:")
	-- dump(cbTempCardData)
	-- print("我的个数:")
	-- print(cbCardCount)
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

--逻辑数值
function GameLogic:GetCardLogicValue(cbCardData)
	--扑克属性
	local cbCardValue = CardHelper:getCardValue(cbCardData)

	--逻辑数值
	if cbCardValue == 0x01 then
		return 14
	elseif cbCardValue == 0x02 then
		return 15
	elseif cbCardValue == 0x0E then
		return 16
	elseif cbCardValue == 0x0F then
		return 17
	end

	--转换数值
	return cbCardValue
end

--对比扑克
function GameLogic:CompareCard(cbFirstCard, cbNextCard, cbFirstCount, cbNextCount)
	--类型判断
	print("对比扑克___上家扑克数据:")
	dump(cbFirstCard)
	print("对比扑克___上家扑克数目:" .. cbFirstCount)
	print("对比扑克___我的扑克数据:")
	dump(cbNextCard)
	print("对比扑克___我的扑克数目:" .. cbNextCount)
	local cbNextType = self:GetCardType(cbNextCard,cbNextCount)
	local cbFirstType = self:GetCardType(cbFirstCard,cbFirstCount)

	--1. 不同类型
	if cbFirstType ~= cbNextType then
		--对王==左对王==右对王
		if cbFirstType >= CT_DOUBLE_KING and cbFirstType <= CT_RIGHT_KING then
			if cbNextType >= CT_DOUBLE_KING and cbNextType <= CT_RIGHT_KING then return false end

			return cbNextType > cbFirstType
		end

		--单牌、双牌、单连、双连
		if cbFirstType >= CT_SINGLE and cbFirstType <= CT_DOUBLE_LINK then
			if cbNextType >= CT_BOMB_THREE then return true end

			return false
		end

		return cbNextType > cbFirstType
	end

	--2. 相同类型
	if cbFirstType == CT_SINGLE or cbFirstType == CT_DOUBLE then
		do
			local cbConsultNext = CardHelper:getCardLogicValue(cbNextCard[0])
			local cbConsultFirst = CardHelper:getCardLogicValue(cbFirstCard[0])

			return cbConsultNext > cbConsultFirst
		end
	elseif cbFirstType == CT_SINGLE_LINK or cbFirstType == CT_DOUBLE_LINK then
		return self:CompareCardByValue(cbFirstCard, cbNextCard, cbFirstCount, cbNextCount)
	elseif cbFirstType == CT_BOMB_THREE or cbFirstType == CT_BOMB_FOUR or cbFirstType == CT_BOMB_FIVE or 
		cbFirstType == CT_BOMB_SIX or cbFirstType == CT_BOMB_SEVEN or cbFirstType == CT_HEAVEN_BOMB then
		do
			local cbNextLogicValue = CardHelper:getCardLogicValue(cbNextCard[0])
			local cbFirstLogicValue = CardHelper:getCardLogicValue(cbFirstCard[0])

			return cbNextLogicValue > cbFirstLogicValue
		end
	elseif cbFirstType == CT_WU_SHI_THK then
		do
			local cbNextLogicColor = CardHelper:getCardColor(cbNextCard[0])
			local cbFirstLogicColor = CardHelper:getCardColor(cbFirstCard[0])

			return cbNextLogicColor > cbFirstLogicColor
		end
	elseif cbFirstType == CT_WU_SHI_K then
		return false
	elseif cbFirstType == CT_SMALL_KING then
		return false
	elseif cbFirstType == CT_DOUBLE_KING then
		return false
	elseif cbFirstType == CT_LEFT_KING then
		return false
	elseif cbFirstType == CT_RIGHT_KING then
		return false
	elseif cbFirstType == CT_BIG_KING then
		return false
	elseif cbFirstType == CT_UNMATCHED_BOMB then
		return false
	end							

	--错误断言
	assert(false)
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

--分析分布
function GameLogic:AnalyseDistributing(cbCardData, cbCardCount, Distributing)
	--设置变量
	for i = 0, cbCardCount - 1 do
		while true do
			--todo
			if cbCardData[i] == 0 then break end
			--获取属性
			local cbCardColor = CardHelper:getCardColor(cbCardData[i])
			local cbCardValue = CardHelper:getCardValue(cbCardData[i])

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
	-- if OutCardKingResult.cbKingCount[0] + OutCardKingResult.cbKingCount[1] > 0 then return 1 end

	-- return 0
end

function GameLogic:SearchWuShiK(cbHandCardData, cbHandCardCount, OutCardWSKResult)
	local cbCardData = Create1Array(MAX_COUNT)
	local cbCardCount = cbHandCardCount
	CopyMemory(cbCardData, cbHandCardData, cbHandCardCount)

	--查找五十K的,每种颜色的个数
	local tempFiveCount = Create1Array(4)
	local tempTenCount = Create1Array(4)
	local tempKCount = Create1Array(4)

	for i = 0, cbCardCount - 1 do
		--1. 查找五
		if CardHelper:getCardValue(cbCardData[i]) == 5 then 
			if CardHelper:getCardColor(cbCardData[i]) == 0 then tempFiveCount[0] = tempFiveCount[0] + 1 end
			if CardHelper:getCardColor(cbCardData[i]) == 1 then tempFiveCount[1] = tempFiveCount[1] + 1 end
			if CardHelper:getCardColor(cbCardData[i]) == 2 then tempFiveCount[2] = tempFiveCount[2] + 1 end
			if CardHelper:getCardColor(cbCardData[i]) == 3 then tempFiveCount[3] = tempFiveCount[3] + 1 end
		end

		--2. 查找十
		if CardHelper:getCardValue(cbCardData[i]) == 10 then
			if CardHelper:getCardColor(cbCardData[i]) == 0 then tempTenCount[0] = tempTenCount[0] + 1 end
			if CardHelper:getCardColor(cbCardData[i]) == 1 then tempTenCount[1] = tempTenCount[1] + 1 end
			if CardHelper:getCardColor(cbCardData[i]) == 2 then tempTenCount[2] = tempTenCount[2] + 1 end
			if CardHelper:getCardColor(cbCardData[i]) == 3 then tempTenCount[3] = tempTenCount[3] + 1 end
		end

		--2. 查找K
		if CardHelper:getCardValue(cbCardData[i]) == 13 then
			if CardHelper:getCardColor(cbCardData[i]) == 0 then tempKCount[0] = tempKCount[0] + 1 end
			if CardHelper:getCardColor(cbCardData[i]) == 1 then tempKCount[1] = tempKCount[1] + 1 end
			if CardHelper:getCardColor(cbCardData[i]) == 2 then tempKCount[2] = tempKCount[2] + 1 end
			if CardHelper:getCardColor(cbCardData[i]) == 3 then tempKCount[3] = tempKCount[3] + 1 end
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
				OutCardWSKResult.cbResultCard[OutCardWSKResult.cbTempCount[0]][0] = 0x0D; 
				OutCardWSKResult.cbResultCard[OutCardWSKResult.cbTempCount[0]][1] = 0x0A;
				OutCardWSKResult.cbResultCard[OutCardWSKResult.cbTempCount[0]][2] = 0x05;
			elseif i == 1 then
				OutCardWSKResult.cbResultCard[OutCardWSKResult.cbTempCount[0]][0] = 0x1D; 
				OutCardWSKResult.cbResultCard[OutCardWSKResult.cbTempCount[0]][1] = 0x1A;
				OutCardWSKResult.cbResultCard[OutCardWSKResult.cbTempCount[0]][2] = 0x15;
			elseif i == 2 then
				OutCardWSKResult.cbResultCard[OutCardWSKResult.cbTempCount[0]][0] = 0x2D; 
				OutCardWSKResult.cbResultCard[OutCardWSKResult.cbTempCount[0]][1] = 0x2A;
				OutCardWSKResult.cbResultCard[OutCardWSKResult.cbTempCount[0]][2] = 0x25;
			elseif i == 3 then
				OutCardWSKResult.cbResultCard[OutCardWSKResult.cbTempCount[0]][0] = 0x3D; 
				OutCardWSKResult.cbResultCard[OutCardWSKResult.cbTempCount[0]][1] = 0x3A;
				OutCardWSKResult.cbResultCard[OutCardWSKResult.cbTempCount[0]][2] = 0x35;
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
	-- print("5的个数:" .. iFiveSum)
	-- print("10的个数:" .. iTenSum)
	-- print("K的个数:" .. iKSum)
	-- dump(tempFiveCount)
	-- dump(tempTenCount)
	-- dump(tempKCount)
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
				OutCardWSKResult.cbResultCard[OutCardWSKResult.cbTempCount[0] + OutCardWSKResult.cbTempCount[1]][1] = self:MakeCardData(0x0D - 1, i)
				for j = 0, 3 do
					if j ~= i and tempTenCount[j] > 0 then
						OutCardWSKResult.cbResultCard[OutCardWSKResult.cbTempCount[0] + OutCardWSKResult.cbTempCount[1]][2] = self:MakeCardData(0x0A - 1, j)
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
	--如果没有得到组合则返回0
	if OutCardWSKResult.cbTempCount[0] + OutCardWSKResult.cbTempCount[1] > 0 then return 1 end

	return 0
end

--出牌搜索
function GameLogic:SearchOutCard(cbHandCardData, cbHandCardCount, cbTurnCardData, cbTurnCardCount, OutCardResult)

	--构造临时变量，存储扑克
	local cbCardData = Create1Array(MAX_COUNT)
	local cbCardCount = cbHandCardCount
	CopyMemory(cbCardData, cbHandCardData, cbHandCardCount)

	print("cbCardCount = " .. cbCardCount)
	--排列扑克
	self:SortCardList(cbCardData,cbCardCount,ST_ORDER)

	--获取当前的出牌类型
	local cbTurnOutType = self:GetCardType(cbTurnCardData, cbTurnCardCount)
	print("当前出牌类型:" .. cbTurnOutType)
	local AnalyseResult = tagAnalyseResult.new()
	self:AnalyseCardData(cbCardData, cbCardCount, AnalyseResult)

	if cbTurnOutType == CT_ERROR then
		--. 选择最小的个数最少的对牌
		for i = 0, 7 do
			if AnalyseResult.cbBlockCount[i] > 0 then
				OutCardResult.cbCardCount = i + 1

				for j = AnalyseResult.cbBlockCount[i] - 1, 0 , -1 do
					--CopyMemory(OutCardResult.cbResultCard, AnalyseResult.cbCardData[i][(i + 1) * j], i + 1)
					CopyMemoryAtIndex(OutCardResult.cbResultCard, 0, AnalyseResult.cbCardData[i], (i + 1) * j, i + 1)
					return true
				end					
			end
		end
		return true
	end

	--获取手中存在的五十K
	local OutCardWSKResult = self:CreateTagWSKOutCardResult()
	print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	dump(cbHandCardData)
	local tempWuShiK = self:SearchWuShiK( cbHandCardData, cbHandCardCount, OutCardWSKResult)
	print("获取手中存在的五十K:")
	dump(tempWuShiK)
	--构造临时变量，存储扑克
	local cbTempCardData = Create1Array(MAX_COUNT)
	local cbTempCardCount = cbHandCardCount
	CopyMemory(cbTempCardData, cbHandCardData, cbHandCardCount)

	if tempWuShiK ~= 0 and OutCardWSKResult.cbTempCount[0] + OutCardWSKResult.cbTempCount[1] > 0 then
		for i = 0, tempWuShiK - 1 do 
			self:RemoveCard(OutCardWSKResult.cbResultCard[i], 3, cbTempCardData, cbTempCardCount)
			cbTempCardCount = cbTempCardCount - 3
		end				
	end

	--排列扑克
	self:SortCardList(cbTempCardData, cbTempCardCount, ST_ORDER)

	--分析除去五十K后手中的牌的情况
	local AnalyseTempResult = tagAnalyseResult.new()
	self:AnalyseCardData(cbTempCardData,cbTempCardCount,AnalyseTempResult);	

	local OutCardKingResult = tagKingCount.new()
	local tempKing = self:SearchKingCount( cbHandCardData, cbHandCardCount, OutCardKingResult)
	print("获取手中存在的王:")
	dump(OutCardKingResult)
	--单牌 对牌
	if cbTurnOutType == CT_SINGLE or cbTurnOutType == CT_DOUBLE then
		for i = cbTurnCardCount - 1, 1 do
			if AnalyseTempResult.cbBlockCount[i] > 0 then
				for j = AnalyseTempResult.cbBlockCount[i] - 1, 0, -1 do
					--比较扑克
					local next_card_data = GetTableByInterval(AnalyseTempResult.cbCardData[i], (i + 1) * j, cbTurnCardCount)
					if self:CompareCard(cbTurnCardData, next_card_data, cbTurnCardCount,cbTurnCardCount) then
						--构造数据
						OutCardResult.cbCardCount = cbTurnCardCount;
						--CopyMemory(OutCardResult.cbResultCard,&AnalyseTempResult.cbCardData[i][(i+1)*j],sizeof(BYTE)*cbTurnCardCount);
						CopyMemoryAtIndex(OutCardResult.cbResultCard, 0, AnalyseResult.cbCardData[i], (i + 1) * j, i + 1)
						return true
					end
				end
			end
		end
	--单连 双连
	elseif cbTurnOutType == CT_SINGLE_LINK or cbTurnOutType == CT_DOUBLE_LINK then
		--只有出牌牌型对应,才搜索
		if cbTurnOutType >= CT_SINGLE_LINK then
			--寻找对比牌
			local byReferCard = cbTurnCardData[0]
			
			if self:SearchLinkCard(cbTempCardData, cbTempCardCount, byReferCard, cbTurnOutType, cbTurnCardCount, OutCardResult) then
				return true
			end
		end
	--三张炸弹
	elseif cbTurnOutType == CT_BOMB_THREE then
		if AnalyseTempResult.cbBlockCount[2] > 0 then
			local cbTempCount = 3

			for j = AnalyseTempResult.cbBlockCount[2] - 1, 0, -1 do
				--比较扑克
				local next_card_data = GetTableByInterval(AnalyseTempResult.cbCardData[2], 3 * j, cbTempCount)
				if self:CompareCard(cbTurnCardData, next_card_data, cbTurnCardCount, cbTempCount) then
					--构造数据
					OutCardResult.cbCardCount = cbTempCount
					CopyMemory(OutCardResult.cbResultCard, next_card_data, cbTempCount)
					return true
				end
			end
		end
	--四张炸弹
	elseif cbTurnOutType == CT_BOMB_FOUR then
		if AnalyseTempResult.cbBlockCount[3] > 0 then
			local cbTempCount = 4

			for j = AnalyseTempResult.cbBlockCount[3] - 1, 0, -1 do
				--比较扑克
				local next_card_data = GetTableByInterval(AnalyseTempResult.cbCardData[3], 4 * j, cbTempCount)
				if self:CompareCard(cbTurnCardData, next_card_data, cbTurnCardCount, cbTempCount) then
					--构造数据
					OutCardResult.cbCardCount = cbTempCount
					CopyMemory(OutCardResult.cbResultCard, next_card_data, cbTempCount)
					return true
				end
			end
		end
	--五张炸弹
	elseif cbTurnOutType == CT_BOMB_FIVE then
		if AnalyseTempResult.cbBlockCount[4] > 0 then
			local cbTempCount = 5

			for j = AnalyseTempResult.cbBlockCount[4] - 1, 0, -1 do
				--比较扑克
				local next_card_data = GetTableByInterval(AnalyseTempResult.cbCardData[4], 5 * j, cbTempCount)
				if self:CompareCard(cbTurnCardData, next_card_data, cbTurnCardCount, cbTempCount) then
					--构造数据
					OutCardResult.cbCardCount = cbTempCount
					CopyMemory(OutCardResult.cbResultCard, next_card_data, cbTempCount)
					return true
				end
			end
		end
	--杂50K
	elseif cbTurnOutType == CT_WU_SHI_K then
		--进入杂花色的五十K判断
		if cbTurnOutType ~= CT_WU_SHI_K and tempWuShiK ~= 0 and OutCardWSKResult.cbTempCount[1] > 0 then
			local cbTempCount = 3
			--去第一个五十K的杂色组合
			local next_card_data = GetTableByInterval(OutCardWSKResult.cbResultCard[OutCardWSKResult.cbTempCount[0]], 0, cbTempCount)
			if self:CompareCard(cbTurnCardData, next_card_data, cbTurnCardCount, cbTempCount) then						
				--构造数据
				OutCardResult.cbCardCount = cbTempCount;
				CopyMemory(OutCardResult.cbResultCard, next_card_data,cbTempCount)
				return true				
			end
		end
	--六张炸
	elseif cbTurnOutType == CT_BOMB_SIX then
		if AnalyseTempResult.cbBlockCount[5] > 0 then
			local cbTempCount = 6

			for j = AnalyseTempResult.cbBlockCount[5] - 1, 0, -1 do		
				--比较扑克
				local next_card_data = GetTableByInterval(AnalyseTempResult.cbCardData[5], 6 * 7, cbTempCount)
				if self:CompareCard(cbTurnCardData, next_card_data, cbTurnCardCount, cbTempCount) then
					--构造数据
					OutCardResult.cbCardCount = cbTempCount;
					CopyMemory(OutCardResult.cbResultCard, next_card_data, cbTempCount);
					return true
				end
			end
		end
	--同花50K
	elseif cbTurnOutType == CT_WU_SHI_THK then
		--进入杂花色的五十K判断
		if tempWuShiK ~= 0 and OutCardWSKResult.cbTempCount[0] > 0 then
			local cbTempCount = 3
			for i = 0, OutCardWSKResult.cbTempCount[0] - 1 do
				--从最小花色的50K开始比较
				local next_card_data = GetTableByInterval(OutCardWSKResult.cbResultCard[i], 0, cbTempCount)
				if self:CompareCard(cbTurnCardData, next_card_data, cbTurnCardCount, cbTempCount) then
					--构造数据
					OutCardResult.cbCardCount = cbTempCount
					CopyMemory(OutCardResult.cbResultCard, next_card_data, cbTempCount)
					return true				
				end
			end
		end
	--七张炸
	elseif cbTurnOutType == CT_BOMB_SEVEN then
		if AnalyseResult.cbBlockCount[6] > 0 then
			local cbTempCount = 7

			for j = AnalyseResult.cbBlockCount[6] - 1, 0, -1 do
				--比较扑克
				local next_card_data = GetTableByInterval(AnalyseResult.cbCardData[6], 7 * j, cbTempCount)
				if self:CompareCard(cbTurnCardData, next_card_data, cbTurnCardCount, cbTempCount) then
					--构造数据
					OutCardResult.cbCardCount = cbTempCount
					CopyMemory(OutCardResult.cbResultCard, next_card_data, cbTempCount);
					return true
				end
			end
		end
	elseif cbTurnOutType == CT_SMALL_KING then
		--判断大王的个数是否是有两个
		if tempKing ~= 0 and OutCardKingResult.cbKingCount[0] == 2 then
			local cbTempCount = 2
			local cbKingTempCard = Create1Array(2)
			cbKingTempCard[0] = 0x4F
			cbKingTempCard[1] = 0x4F

			--进行组合比较
			if self:CompareCard(cbTurnCardData, cbKingTempCard,cbTurnCardCount,cbTempCount) then
				--构造数据
				OutCardResult.cbCardCount = cbTempCount;
				--CopyMemory(OutCardResult.cbResultCard,&cbKingTempCard[0],sizeof(BYTE)*(cbTempCount));
				CopyMemory(OutCardResult.cbResultCard, cbKingTempCard, cbTempCount)
				return true		
			end
		end
	--对王	
	elseif cbTurnOutType == CT_DOUBLE_KING then
		--判断小王的个数是否是有两个
		if tempKing ~= 0 and OutCardKingResult.cbKingCount[0] > 0 and OutCardKingResult.cbKingCount[1] > 0 then
			local cbTempCount = 2;
			local cbKingTempCard = Create1Array(2)
			cbKingTempCard[0] = 0x4F
			cbKingTempCard[1] = 0x4E

			--进行组合比较
			if self:CompareCard(cbTurnCardData, cbKingTempCard,cbTurnCardCount,cbTempCount) then					
				--构造数据
				OutCardResult.cbCardCount = cbTempCount
				CopyMemory(OutCardResult.cbResultCard, cbKingTempCard,cbTempCount)
				return true					
			end
		end
	--左对王	
	elseif cbTurnOutType == CT_LEFT_KING then
		if tempKing ~= 0 and OutCardKingResult.cbKingCount[0] > 0 and OutCardKingResult.cbKingCount[1] == 2 then			
			local cbTempCount = 3
			local cbKingTempCard = Create1Array(3)
			cbKingTempCard[0] = 0x4F
			cbKingTempCard[1] = 0x4E
			cbKingTempCard[2] = 0x4E	

			--进行组合比较
			if self:CompareCard(cbTurnCardData, cbKingTempCard, cbTurnCardCount, cbTempCount) then					
				--构造数据
				OutCardResult.cbCardCount = cbTempCount
				CopyMemory(OutCardResult.cbResultCard, cbKingTempCard, cbTempCount)
				return true					
			end
		end
	--右对王
	elseif cbTurnOutType == CT_RIGHT_KING then
		if tempKing ~= 0 and OutCardKingResult.cbKingCount[0] == 2 and OutCardKingResult.cbKingCount[1] > 0 then				
			local cbTempCount = 3
			local cbKingTempCard = Create1Array(3)
			cbKingTempCard[0] = 0x4F
			cbKingTempCard[1] = 0x4F
			cbKingTempCard[2] = 0x4E		

			--进行组合比较
			if self:CompareCard(cbTurnCardData, cbKingTempCard,cbTurnCardCount,cbTempCount) then					
				--构造数据
				OutCardResult.cbCardCount = cbTempCount
				CopyMemory(OutCardResult.cbResultCard, cbKingTempCard, cbTempCount)
				return true					
			end
		end
	--对大王	
	elseif cbTurnOutType == CT_BIG_KING then
		if tempKing ~= 0 and OutCardKingResult.cbKingCount[0] == 2 then		
			local cbTempCount = 2
			local cbKingTempCard = Create1Array(2)
			cbKingTempCard[0] = 0x4F
			cbKingTempCard[1] = 0x4F	

			--进行组合比较
			if self:CompareCard(cbTurnCardData, cbKingTempCard, cbTurnCardCount, cbTempCount) then					
				--构造数据
				OutCardResult.cbCardCount = cbTempCount
				CopyMemory(OutCardResult.cbResultCard, cbKingTempCard, cbTempCount)
				return true					
			end
		end
	--天炸	
	elseif cbTurnOutType == CT_HEAVEN_BOMB then
		if AnalyseResult.cbBlockCount[7] > 0 then
			local cbTempCount = 8
			for j = AnalyseResult.cbBlockCount[7] - 1, 0, -1 do
				--比较扑克
				local next_card_data = GetTableByInterval(AnalyseResult.cbCardData[7], 8 * j, cbTempCount)
				if self:CompareCard(cbTurnCardData, next_card_data, cbTurnCardCount, cbTempCount) then
					--构造数据
					OutCardResult.cbCardCount = cbTempCount
					CopyMemory(OutCardResult.cbResultCard, next_card_data, cbTempCount)
					return true
				end
			end
		end
	--无敌炸
	elseif cbTurnOutType == CT_UNMATCHED_BOMB then
		local OutCardKingResult = tagKingCount.new()
		local tempKing = self:SearchKingCount(cbHandCardData, cbHandCardCount, OutCardKingResult)

		if tempKing ~= 0 and OutCardKingResult.cbKingCount[0] == 2 and OutCardKingResult.cbKingCount[1] == 2 then		
			local cbTempCount = 4
			local cbKingTempCard = Create1Array(4)
			cbKingTempCard[0] = 0x4F
			cbKingTempCard[1] = 0x4F	
			cbKingTempCard[2] = 0x4E	
			cbKingTempCard[3] = 0x4E	

			--进行组合比较
			if CompareCard(cbTurnCardData, cbKingTempCard, cbTurnCardCount,cbTempCount) then					
				--构造数据
				OutCardResult.cbCardCount = cbTempCount
				CopyMemory(OutCardResult.cbResultCard, cbKingTempCard, cbTempCount)
				return true					
			end
		end
	end

	return false
end

function GameLogic:MakeCardData(cbValueIndex, cbColorIndex)
	return bit._or(cbColorIndex * 16, cbValueIndex + 1)
end

--是否连牌============连牌牌判断
function GameLogic:IsStructureLink(cbCardData, cbCardCount, cbCellCount)
	--数目判断

	if cbCardCount % cbCellCount ~= 0 then return false end
	
	--构造扑克
	local cbCardDataTemp = Create1Array(MAX_COUNT)
	CopyMemory(cbCardDataTemp, cbCardData, cbCardCount)

	--扑克排序============按照当前的花色索引排序
	self:SortCardList(cbCardDataTemp, cbCardCount, ST_VALUE)

	--变量定义
	local cbBlockCount = cbCardCount / cbCellCount
	--cbFirstValue存储的是最大的牌的值
	local cbFirstValue = CardHelper:getCardValue(cbCardDataTemp[0])

	--无效过虑===14 15 此时是王牌
	if cbFirstValue >= 14 then return false end

	--扑克搜索
	for i = 1, cbBlockCount - 1 do
		--扑克数值
		local cbCardValue = CardHelper:getCardValue(cbCardDataTemp[i * cbCellCount])

		--特殊过虑=================cbFirstValue==13为K
		--=========================cbCardValue====1为A
		while true do
			--todo
			if cbCardValue == 1 and cbFirstValue == 13 then break end
			--连牌判断
			if cbFirstValue ~= cbCardValue + i then return false end
			break
		end
	end

	--结果判断
	return true
end

--搜索连牌
function GameLogic:SearchLinkCard(cbHandCardData, cbHandCardCount, cbReferCard, cbCardType, cbTurnCardCount, OutCardResult)

	--A封顶,直接返回
	if CardHelper:getCardValue(cbReferCard) == 1 then return false end


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
		byReferIndex = CardHelper:getCardValue(cbReferCard) - byLinkCount + 1
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

--对比扑克
function GameLogic:CompareCardByValue(cbFirstCard, cbNextCard, cbFirstCount, cbNextCount)
	--[[
	if cbFirstCount ~= cbNextCount then return false end

	return CardHelper:getCardLogicValue(cbNextCard[0]) > CardHelper:getCardLogicValue(cbFirstCard[0])
	--]]

	--变量定义
	local bHaveTwoNext = false
	local cbConsultNext = {0x00, 0x00}

	if cbFirstCount ~= cbNextCount then return false end

	--参照扑克
	for i = 0, cbNextCount - 1 do
		--获取数值
		local cbConsultValue = CardHelper:getCardValue(cbNextCard[i])

		--设置变量
		if bHaveTwoNext == false and cbConsultValue == 0x02 then bHaveTwoNext = true end

		--设置扑克
		if cbConsultValue == 0x01 then
			if 14 > cbConsultNext[1] then cbConsultNext[1] = 14 end
			if cbConsultValue > cbConsultNext[2] then cbConsultNext[2] = cbConsultValue end
		else
			if cbConsultValue > cbConsultNext[1] then cbConsultNext[1] = cbConsultValue end
			if cbConsultValue>cbConsultNext[2] then cbConsultNext[2] = cbConsultValue end
		end
	end

	--变量定义
	local bHaveTwoFirst = false
	local cbConsultFirst = {0x00, 0x00}

	--参照扑克
	for i = 0, cbFirstCount - 1 do
		--获取数值
		local cbConsultValue = CardHelper:getCardValue(cbFirstCard[i])

		--设置变量
		if bHaveTwoFirst == false and cbConsultValue == 0x02 then bHaveTwoFirst = true end

		--设置扑克
		if cbConsultValue == 0x01 then
			if 14 > cbConsultFirst[1] then cbConsultFirst[1] = 14 end
			if cbConsultValue > cbConsultFirst[2] then cbConsultFirst[2] = cbConsultValue end
		else
			if cbConsultValue > cbConsultFirst[1] then cbConsultFirst[1] = cbConsultValue end
			if cbConsultValue > cbConsultFirst[2] then cbConsultFirst[2] = cbConsultValue end
		end
	end

	--对比扑克
	local cbResultNext = (bHaveTwoNext==false) and cbConsultNext[1] or cbConsultNext[2]
	local cbResultFirst = (bHaveTwoFirst==false) and cbConsultFirst[1] or cbConsultFirst[2]

	return cbResultNext > cbResultFirst
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
	local cardValue = CardHelper:getCardLogicValue(cbCardData)
	if cardValue == 5 then cardValue = 18 end
	if cardValue == 10 then cardValue = 19 end
	if cardValue == 13 then cardValue = 20 end

	return cardValue
end

--搜索牌型
function GameLogic:SearchCard(cbHandCardData, cbHandCardCount, cbTurnCardData, cbTurnCardCount, cbSearchCardType, OutCardResult)
	if cbSearchCardType == CT_ERROR then return false end
 
	--构造临时变量，存储扑克
	local cbTempCardData = Create1Array(MAX_COUNT)
	local cbTempCardCount = cbHandCardCount
	CopyMemory(cbTempCardData, cbHandCardData, cbHandCardCount);

	--获取手中存在的五十K
	local OutCardWSKResult = tagWSKOutCardResult.new()
	local tempWuShiK = self:SearchWuShiK(cbHandCardData, cbHandCardCount, OutCardWSKResult)

	--排列扑克
	self:SortCardList(cbTempCardData, cbTempCardCount, ST_ORDER)

	--分析手中的牌的情况
	local AnalyseTempResult = tagAnalyseResult.new()
	self:AnalyseCardData(cbTempCardData,cbTempCardCount,AnalyseTempResult);	

	local OutCardKingResult = tagKingCount.new()
	local tempKing = self:SearchKingCount(cbHandCardData, cbHandCardCount, OutCardKingResult)

	if cbSearchCardType == CT_SINGLE or cbSearchCardType == CT_DOUBLE then
		local i = CT_DOUBLE == cbSearchCardType and 1 or 0
		if AnalyseTempResult.cbBlockCount[i] > 0 then
			for j = AnalyseTempResult.cbBlockCount[i] - 1, 0, -1 do
				--比较扑克
				local next_card_data = GetTableByInterval(AnalyseTempResult.cbCardData[i], (i + 1) * j, i + 1)
				if cbTurnCardCount == 0 or self:CompareCard(cbTurnCardData, next_card_data, cbTurnCardCount, i + 1) then
					--构造数据
					OutCardResult.cbCardCount = i + 1
					CopyMemory(OutCardResult.cbResultCard, next_card_data, i + 1)
					return true
				end
			end
		end

		return false
	elseif cbSearchCardType == CT_SINGLE_LINK or cbSearchCardType == CT_DOUBLE_LINK then
		--寻找对比牌
		local byReferCard = cbTurnCardCount == 0 and 0 or cbTurnCardData[0]

		if self:SearchLinkCard(cbTempCardData, cbTempCardCount, byReferCard, cbSearchCardType, cbTurnCardCount, OutCardResult) then
			return true
		end

		return false
	elseif cbSearchCardType == CT_BOMB_THREE then
		if AnalyseTempResult.cbBlockCount[2] > 0 then
			local cbTempCount = 3

			for j = AnalyseTempResult.cbBlockCount[2] - 1, 0, -1 do
				--比较扑克
				local next_card_data = GetTableByInterval(AnalyseTempResult.cbCardData[2], 3 * j, cbTempCount)
				if cbTurnCardCount == 0 or CompareCard(cbTurnCardData, next_card_data, cbTurnCardCount, cbTempCount) then
					--构造数据
					OutCardResult.cbCardCount = cbTempCount
					CopyMemory(OutCardResult.cbResultCard, next_card_data, cbTempCount)
					return true
				end
			end
		end
	elseif cbSearchCardType == CT_BOMB_FOUR then
		if AnalyseTempResult.cbBlockCount[3] > 0 then
			local cbTempCount = 4

			for j = AnalyseTempResult.cbBlockCount[3] - 1, 0, -1 do
				--比较扑克
				local next_card_data = GetTableByInterval(AnalyseTempResult.cbCardData[3], 4 * j, cbTempCount)
				if cbTurnCardCount == 0 or self:CompareCard(cbTurnCardData, next_card_data, cbTurnCardCount, cbTempCount) then
					--构造数据
					OutCardResult.cbCardCount = cbTempCount
					CopyMemory(OutCardResult.cbResultCard, next_card_data, cbTempCount)
					return true
				end
			end
		end
	elseif cbSearchCardType == CT_BOMB_FIVE then
		if AnalyseTempResult.cbBlockCount[4] > 0 then
			local cbTempCount = 5

			for j = AnalyseTempResult.cbBlockCount[4] - 1, 0, -1 do
				--比较扑克
				local next_card_data = GetTableByInterval(AnalyseTempResult.cbCardData[4], 5 * j, cbTempCount)
				if cbTurnCardCount == 0 or self:CompareCard(cbTurnCardData, next_card_data, cbTurnCardCount, cbTempCount) then
					--构造数据
					OutCardResult.cbCardCount = cbTempCount
					CopyMemory(OutCardResult.cbResultCard, next_card_data, cbTempCount)
					return true
				end
			end
		end
	elseif cbSearchCardType == CT_BOMB_SIX then
		if AnalyseTempResult.cbBlockCount[5] > 0 then
			local cbTempCount = 6

			for j = AnalyseTempResult.cbBlockCount[5] - 1, 0, -1 do
				--比较扑克
				local next_card_data = GetTableByInterval(AnalyseTempResult.cbCardData[5], 6 * j, cbTempCount)
				if cbTurnCardCount == 0 or self:CompareCard(cbTurnCardData, next_card_data, cbTurnCardCount, cbTempCount) then
					--构造数据
					OutCardResult.cbCardCount = cbTempCount
					CopyMemory(OutCardResult.cbResultCard, next_card_data, cbTempCount)
					return true
				end
			end
		end
	elseif cbSearchCardType == CT_BOMB_SEVEN then
		if AnalyseTempResult.cbBlockCount[6] > 0 then
			local cbTempCount = 7

			for j = AnalyseTempResult.cbBlockCount[6] - 1, 0, -1 do
			
				--比较扑克
				local next_card_data = GetTableByInterval(AnalyseTempResult.cbCardData[6], 7 * j, cbTempCount)
				if cbTurnCardCount == 0 or self:CompareCard(cbTurnCardData, next_card_data, cbTurnCardCount, cbTempCount) then
					--构造数据
					OutCardResult.cbCardCount = cbTempCount
					CopyMemory(OutCardResult.cbResultCard, next_card_data, cbTempCount)
					return true
				end
			end
		end
	elseif cbSearchCardType == CT_HEAVEN_BOMB then
		if AnalyseTempResult.cbBlockCount[7] > 0 then
			local cbTempCount = 8
			for j = AnalyseTempResult.cbBlockCount[7] - 1, 0, -1 do
				--比较扑克
				local next_card_data = GetTableByInterval(AnalyseTempResult.cbCardData[7], 8 * j, cbTempCount)
				if cbTurnCardCount == 0 or self:CompareCard(cbTurnCardData, next_card_data, cbTurnCardCount, cbTempCount) then
					--构造数据
					OutCardResult.cbCardCount = cbTempCount
					CopyMemory(OutCardResult.cbResultCard, next_card_data, cbTempCount)
					return true
				end
			end
		end

		return false
	elseif cbSearchCardType == CT_WU_SHI_K then
		--进入杂花色的五十K判断
		if tempWuShiK ~= 0 and OutCardWSKResult.cbTempCount[1] > 0 then
			local cbTempCount = 3
			--去第一个五十K的杂色组合
			local next_card_data = GetTableByInterval(OutCardWSKResult.cbResultCard[OutCardWSKResult.cbTempCount[0]], 0, cbTempCount)
			if cbTurnCardCount == 0 or self:CompareCard(cbTurnCardData, next_card_data, cbTurnCardCount, cbTempCount) then
				--构造数据
				OutCardResult.cbCardCount = cbTempCount
				CopyMemory(OutCardResult.cbResultCard, next_card_data, cbTempCount)
				return true					
			end

		end
	elseif cbSearchCardType == CT_WU_SHI_THK then
		--进入杂花色的五十K判断
		if tempWuShiK ~= 0 and OutCardWSKResult.cbTempCount[0] > 0 then
			local cbTempCount = 3
			for i = 0, OutCardWSKResult.cbTempCount[0] - 1 do
				--从最小花色的50K开始比较
				local next_card_data = GetTableByInterval(OutCardWSKResult.cbResultCard[i], 0, cbTempCount)
				if cbTurnCardCount == 0 or self:CompareCard(cbTurnCardData, next_card_data, cbTurnCardCount, cbTempCount) then
					--构造数据
					OutCardResult.cbCardCount = cbTempCount
					CopyMemory(OutCardResult.cbResultCard, next_card_data, cbTempCount)
					return true					
				end
			end
		end

		return false
	elseif cbSearchCardType == CT_SMALL_KING then
		--判断小王的个数是否是有两个
		if tempKing ~= 0 and OutCardKingResult.cbKingCount[1] == 2 then
			local cbTempCount = 2
			local cbKingTempCard = Create1Array(2)
			cbKingTempCard[0] = 0x4E
			cbKingTempCard[1] = 0x4E

			--进行组合比较
			if cbTurnCardCount == 0 or self:CompareCard(cbTurnCardData, cbKingTempCard, cbTurnCardCount, cbTempCount) then
				--构造数据
				OutCardResult.cbCardCount = cbTempCount
				CopyMemory(OutCardResult.cbResultCard, cbKingTempCard, cbTempCount)
				return true			
			end
		end
	elseif cbSearchCardType == CT_DOUBLE_KING then
		--判断小王的个数是否是有两个
		if tempKing ~= 0 and OutCardKingResult.cbKingCount[0] > 0 and OutCardKingResult.cbKingCount[1] > 0 then
			local cbTempCount = 2
			local cbKingTempCard = Create1Array(2)
			cbKingTempCard[0] = 0x4F
			cbKingTempCard[1] = 0x4E

			--进行组合比较
			if cbTurnCardCount == 0 or self:CompareCard(cbTurnCardData, cbKingTempCard,cbTurnCardCount,cbTempCount) then
				--构造数据
				OutCardResult.cbCardCount = cbTempCount
				CopyMemory(OutCardResult.cbResultCard, cbKingTempCard, cbTempCount)
				return true
			end
		end
	elseif cbSearchCardType == CT_LEFT_KING then
		if tempKing ~= 0 and OutCardKingResult.cbKingCount[0] > 0 and OutCardKingResult.cbKingCount[1] == 2 then	
			local cbTempCount = 3
			local cbKingTempCard = Create1Array(3)
			cbKingTempCard[0] = 0x4F
			cbKingTempCard[1] = 0x4E
			cbKingTempCard[2] = 0x4E		

			--进行组合比较
			if cbTurnCardCount == 0 or self:CompareCard(cbTurnCardData, cbKingTempCard, cbTurnCardCount, cbTempCount) then
				--构造数据
				OutCardResult.cbCardCount = cbTempCount
				CopyMemory(OutCardResult.cbResultCard, cbKingTempCard, cbTempCount)
				return true				
			end
		end
	elseif cbSearchCardType == CT_RIGHT_KING then
		if tempKing ~= 0 and OutCardKingResult.cbKingCount[0] == 2 and OutCardKingResult.cbKingCount[1] > 0 then
			local cbTempCount = 3
			local cbKingTempCard = Create1Array(3)
			cbKingTempCard[0] = 0x4F
			cbKingTempCard[1] = 0x4F
			cbKingTempCard[2] = 0x4E		

			--进行组合比较
			if cbTurnCardCount == 0 or self:CompareCard(cbTurnCardData, cbKingTempCard, cbTurnCardCount, cbTempCount) then						
				--构造数据
				OutCardResult.cbCardCount = cbTempCount
				CopyMemory(OutCardResult.cbResultCard, cbKingTempCard, cbTempCount)
				return true				
			end
		end
	elseif cbSearchCardType == CT_BIG_KING then
		if tempKing ~= 0 and OutCardKingResult.cbKingCount[0] == 2 then
			local cbTempCount = 2
			local cbKingTempCard = Create1Array(2)
			cbKingTempCard[0] = 0x4F
			cbKingTempCard[1] = 0x4F	

			--进行组合比较
			if cbTurnCardCount == 0 or self:CompareCard(cbTurnCardData, cbKingTempCard, cbTurnCardCount, cbTempCount) then
				--构造数据
				OutCardResult.cbCardCount = cbTempCount
				CopyMemory(OutCardResult.cbResultCard, cbKingTempCard, cbTempCount)
				return true			
			end
		end
	elseif cbSearchCardType == CT_UNMATCHED_BOMB then
		if tempKing ~= 0 and OutCardKingResult.cbKingCount[0] == 2 and OutCardKingResult.cbKingCount[1] == 2 then		
			local cbTempCount = 4
			local cbKingTempCard = Create1Array(4)
			cbKingTempCard[0] = 0x4F
			cbKingTempCard[1] = 0x4F	
			cbKingTempCard[2] = 0x4E	
			cbKingTempCard[3] = 0x4E	

			--进行组合比较
			if cbTurnCardCount == 0 or self:CompareCard(cbTurnCardData, cbKingTempCard, cbTurnCardCount, cbTempCount) then
				--构造数据
				OutCardResult.cbCardCount = cbTempCount
				CopyMemory(OutCardResult.cbResultCard, cbKingTempCard, cbTempCount)
				return true					
			end
		end	
	end

	return false
end

-- 竖牌:单张 对子 
-- 横牌:顺子 连对
-- 普通炸弹:八张以下同牌
-- 特殊炸弹:50K
-- 王炸:
-- 天炸:八张同牌
-- 无敌炸：四王
function GameLogic:GetOutCardTip(cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
	local out_card_type = self:GetCardType(cbTurnCardData, cbTurnCardCount)
	if out_card_type == CT_ERROR or out_card_type == CT_UNMATCHED_BOMB then return nil end 
	--所有数据从小到大排序
	--self:SortCardList(cbHandCardData, cbHandCardCount, ST_ORDER)

	local tipsTab = {}
	if out_card_type == CT_SINGLE or out_card_type == CT_DOUBLE then
		tipsTab = self:SearchShuCard(out_card_type, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
	elseif out_card_type == CT_SINGLE_LINK or out_card_type == CT_DOUBLE_LINK then
		tipsTab = self:SearchHengCard(out_card_type, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
	else
		local temp1 = self:SearchBomb(out_card_type, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
		print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&")
		dump(temp1)
		table.insertto(tipsTab, temp1)
		dump(tipsTab)
		local temp2 = self:Search50K(out_card_type, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
		table.insertto(tipsTab, temp2)

		local temp3 = self:SearchKing(out_card_type, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
		table.insertto(tipsTab, temp3)
	end

	return tipsTab
end

function GameLogic:SearchShuCard(cbOutCardType, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount, bSameTypeTip)
	local AnalyseResult = GameLogic:CreateTagAnalyseResult()
	self:AnalyseCardData(cbHandCardData, cbHandCardCount, AnalyseResult)
	dump(AnalyseResult)
	local tipsTab = {}
	local tipsIndex = 1
	--单元个数
	local cellCount = cbOutCardType
	--出牌值
	local outValue = self:GetCardLogicValue(cbTurnCardData[0])

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
	if bSameTypeTip then return tipsIndex end
	local temp1 = self:SearchBomb(cbOutCardType, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
	--print("搜索到的炸弹:")
	--dump(temp1)
	table.insertto(tipsTab, temp1)

	local temp2 = self:Search50K(cbOutCardType, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
	-- print("搜索到的50K:")
	-- dump(temp2)
	table.insertto(tipsTab, temp2)

	local temp3 = self:SearchKing(cbOutCardType, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
	-- print("搜索到的王:")
	-- dump(temp3)
	table.insertto(tipsTab, temp3)

	--如果为空 再查找 同牌中的竖牌是否满足条件
	dump(AnalyseResult.cbBlockCount)
	if CT_SINGLE == cbOutCardType and #tipsTab == 0 then
		--如果对子总数大于0
		if AnalyseResult.cbBlockCount[1] > 0 then
			for i = AnalyseResult.cbBlockCount[1] - 1, 0, -1 do --从小到大找
				local card_data = AnalyseResult.cbCardData[1][i * 2]
				if self:GetCardLogicValue(card_data) > outValue then
					tipsTab[tipsIndex] = {card_data}
					tipsIndex = tipsIndex + 1
				end
			end
		end
	end

	return tipsTab
end

function GameLogic:SearchHengCard(cbOutCardType, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount, bSameTypeTip)
	--单元个数
	local cellCount = math.floor(cbOutCardType / 2)
	local linkCount = cellCount == 1 and cbTurnCardCount or cbTurnCardCount / 2
	local tipsTab = {}
	local tipsIndex = 1

	local Distributing = self:CreateTagDistributing()
	self:AnalyseDistributing(cbHandCardData, cbHandCardCount, Distributing)

	local OutCardDistributing = self:CreateTagDistributing()
	self:AnalyseDistributing(cbTurnCardData, cbTurnCardCount, OutCardDistributing)

	--如果出牌顺子到A 则不提取
	if OutCardDistributing.cbDistributing[0][cbIndexCount] == 0 then
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
		-- print("22222222222222222222222222")
		-- dump(Distributing)

		startIndex = startIndex + 1
		while startIndex <= 13 - linkCount + 1 do
			--todo
			--print("起始值:" .. startIndex + 1)
			local bFind = false
			for j = 0, linkCount - 1 do
				local tempIndex = startIndex + j == 13 and 0 or startIndex + j
				--print("		跟踪值:" .. tempIndex + 1)
				local iHandCardNum = Distributing.cbDistributing[tempIndex][cbIndexCount]
				bFind = iHandCardNum >= cellCount
				if not bFind then break end
				--print("value  = " .. startIndex + j + 1 .. ":" .. tostring(bFind))
			end
			if bFind then
				--找到 提取
				tipsTab[tipsIndex] = {}
				local addCount = 0
				for inc = 0, linkCount - 1 do
					--print("inc = " .. inc)
					local valueIndex = startIndex + inc
					valueIndex = valueIndex == 13 and 0 or valueIndex
					local cellNum = 0
					--i 花色
					for i = 0, 3 do
						--print("		color = " .. i)
						--j花色数目 
						for j = 1, Distributing.cbDistributing[valueIndex][i] do
							--print("				value = " .. valueIndex + 1)
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
	if bSameTypeTip then return tipsTab end

	local temp1 = self:SearchBomb(cbOutCardType, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
	--print("搜索到的炸弹:")
	--dump(temp1)
	table.insertto(tipsTab, temp1)

	local temp2 = self:Search50K(cbOutCardType, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
	-- print("搜索到的50K:")
	-- dump(temp2)
	table.insertto(tipsTab, temp2)

	local temp3 = self:SearchKing(cbOutCardType, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
	print("搜索到的王:")
	dump(temp3)
	table.insertto(tipsTab, temp3)

	return tipsTab
end

function GameLogic:SearchBomb(cbOutCardType, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
	local AnalyseResult = GameLogic:CreateTagAnalyseResult()
	self:AnalyseCardData(cbHandCardData, cbHandCardCount, AnalyseResult)

	local tipsTab = {}
	local tipsIndex = 1

	--比较值
	local byCount = 0
	local byValue = 0

	if cbOutCardType < CT_BOMB_THREE then
		byCount = 3
	elseif cbOutCardType == CT_WU_SHI_K then
		byCount = 6
	elseif cbOutCardType == CT_WU_SHI_THK then
		byCount = 7
	elseif cbOutCardType == CT_UNMATCHED_BOMB then
		return tipsTab
	elseif cbOutCardType > CT_BOMB_SEVEN and cbOutCardType < CT_UNMATCHED_BOMB then
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

	dump(OutCardWSKResult)

	if cbOutCardType < CT_WU_SHI_K then
		byCount = OutCardWSKResult.cbTempCount[0] + OutCardWSKResult.cbTempCount[1]
	elseif cbOutCardType == CT_WU_SHI_K then
		byCount = OutCardWSKResult.cbTempCount[0]	
	elseif CT_BOMB_SIX == cbOutCardType then
		byCount = OutCardWSKResult.cbTempCount[0]
	elseif CT_WU_SHI_THK == cbOutCardType then
		byCount = OutCardWSKResult.cbTempCount[0]
		byColor = CardHelper:getCardColor(cbTurnCardData[0])
	else
		return tipsTab
	end

	-- local OutCardWSKResult = self:CreateTagWSKOutCardResult()
	-- self:SearchWuShiK(cbHandCardData, cbHandCardCount, OutCardWSKResult)
	-- dump(OutCardWSKResult)
	for i = 0, byCount - 1 do
		if CardHelper:getCardColor(OutCardWSKResult.cbResultCard[i][0]) > byColor then
			tipsTab[tipsIndex] = tipsTab[tipsIndex] or {}
			tipsTab[tipsIndex][1] = OutCardWSKResult.cbResultCard[i][0]
			tipsTab[tipsIndex][2] = OutCardWSKResult.cbResultCard[i][1]
			tipsTab[tipsIndex][3] = OutCardWSKResult.cbResultCard[i][2]
			tipsIndex = tipsIndex + 1
		end
	end

	return tipsTab
end

function GameLogic:SearchKing(cbOutCardType, cbTurnCardData, cbTurnCardCount, cbHandCardData, cbHandCardCount)
	--搜索王炸
	local tipsTab = {}
	local tipsIndex = 1

	local OutCardKingResult = self:CreateTagKingCount()
	self:SearchKingCount(cbHandCardData, cbHandCardCount, OutCardKingResult)

	local bFind = false

	if cbOutCardType == CT_HEAVEN_BOMB then
		bFind = OutCardKingResult.cbKingCount[0] + OutCardKingResult.cbKingCount[1] == 4
	elseif cbOutCardType == CT_SMALL_KING then
		bFind = OutCardKingResult.cbKingCount[0] == 2
	elseif cbOutCardType > CT_SMALL_KING then
		return tipsTab
	else
		bFind = OutCardKingResult.cbKingCount[0] + OutCardKingResult.cbKingCount[1] >= 2
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


function GameLogic:typeDebug(cardType)
	-- body
	print("--------------------------GameLogic:typeDebug---------------------")

	if cardType == CT_ERROR then
		print("出牌类型:错误")
	elseif cardType == CT_SINGLE then
		print("出牌类型:单张")
	elseif cardType == CT_DOUBLE then
		print("出牌类型:对子")
	elseif cardType == CT_SINGLE_LINK then
		print("出牌类型:单顺")
	elseif cardType == CT_DOUBLE_LINK then
		print("出牌类型:双顺")
	elseif cardType == CT_BOMB_THREE then
		print("出牌类型:三炸")
	elseif cardType == CT_BOMB_FOUR then
		print("出牌类型:四炸")
	elseif cardType == CT_BOMB_FIVE then
		print("出牌类型:五炸")
	elseif cardType == CT_WU_SHI_K then
		print("出牌类型:五十K")
	elseif cardType == CT_BOMB_SIX then
		print("出牌类型:六炸")
	elseif cardType == CT_WU_SHI_THK then
		print("出牌类型:同花50K")
	elseif cardType == CT_BOMB_SEVEN then
		print("出牌类型:七炸")
	elseif cardType == CT_SMALL_KING then
		print("出牌类型:对小王")
	elseif cardType == CT_DOUBLE_KING then
		print("出牌类型:双王")
	elseif cardType == CT_LEFT_KING then
		print("出牌类型:两小王一大王")
	elseif cardType == CT_RIGHT_KING then
		print("出牌类型:两大王一小王")
	elseif cardType == CT_BIG_KING then
		print("出牌类型:对大王")
	elseif cardType == CT_HEAVEN_BOMB then
		print("出牌类型:天炸")
	elseif cardType == CT_UNMATCHED_BOMB then
		print("出牌类型:无敌炸")
	end									
end

return GameLogic
--------------------------------------------------------------------------------------------------------------------------------------