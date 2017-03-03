--
-- Author: GFun
-- Date: 2016-12-15 19:12:54
--

local BaseData = require("script.50kScript.data.BaseData")
local MsgCurTurnOverData = class("MsgCurTurnOverData", BaseData)

local MsgCurTurnOverDataStruct = {
	{m_wCurTurnWinner_ = -1},
	{m_cbCurTurnScore_ = 0},
}

function MsgCurTurnOverData:ctor()
	MsgCurTurnOverData.super.ctor(self)

	self:SetDataType(self.class.MSG_DATA_TYPE)
	self:SetDataStructParams(MsgCurTurnOverDataStruct)
end

function MsgCurTurnOverData:ExtendData(data_center)
	local turnWinnerIndex = data_center.m_wCurTurnWinner_ + 1
	data_center.m_cbCardScoreTab_[turnWinnerIndex] = data_center.m_cbCardScoreTab_[turnWinnerIndex] + data_center.m_cbCurTurnScore_
	data_center.m_cbCurTurnScore_ = 0
	--重置pass信息
	data_center.m_cbPassCardInfo_ = {0, 0, 0, 0}
	--重置上个出牌玩家数据
	data_center.m_wPrevOutCardUser_ = -1
	data_center.m_cbPrevOutCardData_ = {}
	data_center.m_cbPrevOutCardCount_ = 0
	data_center.m_wPrevOperationUser_ = -1
	data_center.m_bFirstOutCard_ = true
end

function MsgCurTurnOverData:DispatchEvent(data_center)
	--print("------------------------------MsgCurTurnOverData:DispatchEvent------------------------")
	data_center:dispatchEvent({name = data_center.MSG_CUR_TURN_OVER_EVENT})
end

return MsgCurTurnOverData