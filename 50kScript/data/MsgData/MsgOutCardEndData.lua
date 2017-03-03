--
-- Author: GFun
-- Date: 2016-12-14 11:53:38
--
local BaseData = require("script.50kScript.data.BaseData")
local MsgOutCardEndData = class("MsgOutCardEndData", BaseData)

local MsgOutCardEndDataStruct = {
	{m_wPrevOutCardUser_      = -1},
	{m_cbPrevOutCardData_     = {}},
	{m_cbPrevOutCardCount_    = 0},
	-- {m_cbHandCardCountTab_ = {}},
	{m_cbCurTurnScore_        = 0},
	{m_lMultiple_             = 1},
}

function MsgOutCardEndData:ctor()
	MsgOutCardEndData.super.ctor(self)

	self:SetDataType(self.class.MSG_DATA_TYPE)
	self:SetDataStructParams(MsgOutCardEndDataStruct)
end

function MsgOutCardEndData:ExtendData(data_center)
	data_center.m_cbPrevOutCardData_ = ConvertTableToArray(data_center.m_cbPrevOutCardData_, data_center.m_cbPrevOutCardCount_)
	--print("出牌转换:")
	--dump(data_center.m_cbPrevOutCardData_)
	--只要有人出牌 便不是首出
	data_center.m_bFirstOutCard_ = false

	--将已出牌玩家的pass信息重置
	data_center.m_cbPassCardInfo_[data_center.m_wPrevOutCardUser_ + 1] = 2

	--非自己出牌 手牌减少
	if data_center.m_wPrevOutCardUser_ ~= data_center.m_cbSelfChairID_ then
		local prevIndex = data_center.m_wPrevOutCardUser_ + 1
		data_center.m_cbHandCardCountTab_[prevIndex] = data_center.m_cbHandCardCountTab_[prevIndex] - data_center.m_cbPrevOutCardCount_
	else
		print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
	end
end

function MsgOutCardEndData:DispatchEvent(data_center)
	print("------------------------------MsgOutCardEndData:DispatchEvent------------------------")
	data_center:dispatchEvent({name = data_center.MSG_OUT_CARD_END_EVENT})
end

return MsgOutCardEndData