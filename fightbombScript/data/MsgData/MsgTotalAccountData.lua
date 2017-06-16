--
-- Author: GFun
-- Date: 2017-03-13 09:35:21
--
local BaseData = require("script.fightbombScript.data.BaseData")
local MsgTotalAccountData = class("MsgTotalAccountData", BaseData)

local MsgTotalAccountDataStruct = {
	{m_dwXiScoreCount_  = {}},
	{m_cbOrderCount_ = {}},
	{m_lTotalScore_ = {}},
	{m_cbGameEndType_ = 0},
}

function MsgTotalAccountData:ctor()
	MsgTotalAccountData.super.ctor(self)

	self:SetDataType(self.class.MSG_DATA_TYPE)
	self:SetDataStructParams(MsgTotalAccountDataStruct)
end

function MsgTotalAccountData:ExtendData(data_center)
	local iScore = 0
	for i, v in ipairs(data_center.m_lTotalScore_) do
		if tonumber(v) > iScore then
			iScore = tonumber(v)
		end
	end
	data_center.m_lMaxScore_ = iScore

	local t = {}
	for i = 1, GAME_PLAYER do
		t[i] = t[i] or {}
		for j = 1, 4 do
			local index = (i - 1) * 4 + j
			table.insert(t[i], data_center.m_cbOrderCount_[index])
		end
	end
	data_center.m_cbOrderCount_ = t

	dump(data_center.m_cbOrderCount_)
end

function MsgTotalAccountData:DispatchEvent(data_center)
	--print("------------------------------MsgTotalAccountData:DispatchEvent------------------------")
	data_center:dispatchEvent({name = data_center.MSG_TOTAL_ACCOUNT_EVENT})
end

return MsgTotalAccountData