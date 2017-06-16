--
-- Author: GFun
-- Date: 2016-12-21 09:48:05
--
local BaseData = require("script.fightbombScript.data.BaseData")
local MsgGameEndData = class("MsgGameEndData", BaseData)

local MsgGameEndDataStruct = {
	{m_lTotalScore_ 	   = 0},
	{m_lGameScoreTab_	   = {}},
	{m_cbCatchScore_	   = {}},
	{m_nExtraScore_ 	   = {}},
	{m_nXiScore_ 		   = {}},

	{m_cbGameEndType_      = 0},
	{m_cbHandCardCountTab_ = {}},
	{m_cbHandCardDataTab_  = {}},
	{m_cbUserOrder_ 	   = {}},
}

function MsgGameEndData:ctor()
	MsgGameEndData.super.ctor(self)

	self:SetDataType(self.class.MSG_DATA_TYPE)
	self:SetDataStructParams(MsgGameEndDataStruct)
end

function MsgGameEndData:ExtendData(data_center)
	data_center.m_cbUserOrderNum_ = GAME_PLAYER

	local score = tonumber(data_center.m_lGameScoreTab_[data_center.m_cbSelfChairID_ + 1])
	if score > 0 then
		data_center.m_cbGameResult_ = 1
	elseif score == 0 then
		data_center.m_cbGameResult_ = 2
	else
		data_center.m_cbGameResult_ = 0
	end

	if data_center.m_wServerType_ == GAME_GENRE_GOLD then
		data_center.m_bGameOver_ = true
	elseif data_center.m_wServerType_ == GAME_GENRE_SCORE then
		data_center:addCurInningNum()
		data_center.m_wServerStatus_ = GS_UG_CONTINUE

		-- for i = 1, GAME_PLAYER do
		-- 	data_center.m_lTotalScore_[i] = data_center.m_lTotalScore_[i] + data_center.m_lGameScoreTab_[i]
		-- end
	end

	-- local t = {}
	-- for i = 1, GAME_PLAYER do
	-- 	t[i] = t[i] or {}
	-- 	-- local count = data_center.m_cbHandCardCountTab_[i]
	-- 	for j = 1, MAX_COUNT do
	-- 		local index = (i - 1) * MAX_COUNT + j
	-- 		t[i][j] = data_center.m_cbHandCardDataTab_[index]
	-- 	end
	-- end
	-- data_center.m_cbHandCardDataTab_ = t
	self:disposalPlayersHandCardData(data_center)
end

function MsgGameEndData:disposalPlayersHandCardData(data_center)
	local t = {}
	for i = 1, GAME_PLAYER do
		t[i] = t[i] or {}
		for j = 1, data_center.m_cbHandCardCountTab_[i] do
			local index = (i - 1) * MAX_COUNT + j
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