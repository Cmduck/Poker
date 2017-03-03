--
-- Author: GFun
-- Date: 2016-12-21 09:48:05
--
local BaseData = require("script.50kScript.data.BaseData")
local MsgGameEndData = class("MsgGameEndData", BaseData)
--[[
	当前倍数
	各玩家牌面分
	玩家名次
	游戏积分

	1. 是朋友则*1
	2. 是否暗叫
	3. 是否吼牌
	4. 是否帮牌
	5. 是否清牌
	6. 杂五十K
	7. 6张炸弹
	8. 7张炸弹
	9. 双王
	10. 同花五十K
	11. 天炸
	12. 无敌炸

	扑克数
	剩余扑克列表
--]]
local MsgGameEndDataStruct = {
	{m_lMultiple_ = 0},

	{m_cbCardScoreTab_ = {}},
	{m_cbWinnerOrder_ = {}},
	{m_cbGameScoreTab_ = {}},

	{m_bIsMyFriend_ = {}},
	{m_bIsAnJiao_ = {}},
	{m_bIsHou_ = {}},
	{m_bIsBang_ = {}},
	{m_bIsQing_ = {}},

	{m_bIs50K_ = {}},
	{m_bIs6Bomb_ = {}},
	{m_bIs7Bomb_ = {}},
	{m_bIsDoubleKing_ = {}},
	{m_bIs50THK_ = {}},
	{m_bIsTianBomb_ = {}},
	{m_bIsWudiBomb_ = {}},

	{m_cbHandCardCountTab_ = {}},
	{m_cbHandCardDataTab_ = {}},
}

function MsgGameEndData:ctor()
	MsgGameEndData.super.ctor(self)

	self:SetDataType(self.class.MSG_DATA_TYPE)
	self:SetDataStructParams(MsgGameEndDataStruct)
end

function MsgGameEndData:ExtendData(data_center)

	self:disposalPlayersHandCardData(data_center)
	if data_center.m_wServerType_ == GAME_GENRE_GOLD then
		data_center.m_bGameOver_ = true
	end
end

function MsgGameEndData:disposalPlayersHandCardData(data_center)
	local t = {}
	for i = 1, GAME_PLAYER do
		t[i] = t[i] or {}
		for j = 1, data_center.m_cbHandCardCountTab_[i] do
			local index = (i - 1) * 27 + j
			table.insert(t[i], data_center.m_cbHandCardDataTab_[index])
		end
	end
	data_center.m_cbHandCardDataTab_ = t
end

function MsgGameEndData:DispatchEvent(data_center)
	--print("------------------------------MsgGameEndData:DispatchEvent------------------------")
	data_center:dispatchEvent({name = data_center.MSG_GAME_END_EVENT})
end

return MsgGameEndData