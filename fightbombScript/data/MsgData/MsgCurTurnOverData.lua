--
-- Author: GFun
-- Date: 2016-12-15 19:12:54
--

local BaseData = require("script.fightbombScript.data.BaseData")
local MsgCurTurnOverData = class("MsgCurTurnOverData", BaseData)

local MsgCurTurnOverDataStruct = {
	{m_wCurTurnWinner_ = -1},
	{m_cbCurTurnScore_ = 0},
	{m_cbCurXiScore_	= 0},
}

function MsgCurTurnOverData:ctor()
	MsgCurTurnOverData.super.ctor(self)

	self:SetDataType(self.class.MSG_DATA_TYPE)
	self:SetDataStructParams(MsgCurTurnOverDataStruct)
end

function MsgCurTurnOverData:ExtendData(data_center)
	local index = data_center.m_wCurTurnWinner_ + 1
	data_center.m_cbCatchScore_[index] = data_center.m_cbCatchScore_[index] + data_center.m_cbCurTurnScore_
	-- data_center.m_nXiScore_[index] = data_center.m_nXiScore_[index] + data_center.m_cbCurXiScore_

	for i = 0, GAME_PLAYER - 1 do
		if i == data_center.m_wCurTurnWinner_ then
			data_center.m_nXiScore_[i + 1] = data_center.m_nXiScore_[i + 1] + data_center.m_cbCurXiScore_ * 3
		else
			data_center.m_nXiScore_[i + 1] = data_center.m_nXiScore_[i + 1] - data_center.m_cbCurXiScore_
		end
	end

	--重置pass信息
	data_center.m_cbPassCardInfo_ = {0, 0, 0, 0}
	--重置上个出牌玩家数据
	data_center.m_wPrevOutCardUser_   = -1
	data_center.m_cbPrevOutCardData_  = -1
	data_center.m_cbPrevOutCardCount_ = 0
	data_center.m_wPrevOperationUser_ = -1
	data_center.m_bFirstOutCard_      = true
end

function MsgCurTurnOverData:DispatchEvent(data_center)
	--print("------------------------------MsgCurTurnOverData:DispatchEvent------------------------")
	data_center:dispatchEvent({name = data_center.MSG_CUR_TURN_OVER_EVENT})
end

return MsgCurTurnOverData