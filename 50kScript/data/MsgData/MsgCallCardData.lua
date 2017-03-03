--
-- Author: GFun
-- Date: 2016-12-14 18:05:04
--
local BaseData = require("script.50kScript.data.BaseData")
local MsgCallCardData = class("MsgCallCardData", BaseData)

local MsgCallCardDataStruct = {
	{m_cbCallCardData_ = 0},
	{m_wCurrentUser_ = -1},
}

function MsgCallCardData:ctor()
	MsgCallCardData.super.ctor(self)

	self:SetDataType(self.class.MSG_DATA_TYPE)
	self:SetDataStructParams(MsgCallCardDataStruct)
end

function MsgCallCardData:ExtendData(data_center)
	--庄家叫牌默认不吼
	data_center.m_cbHouCardInfo_[data_center.m_wBankerUser_ + 1] = 2
end

function MsgCallCardData:DispatchEvent(data_center)
	--print("------------------------------MsgCallCardData:DispatchEvent------------------------")
	data_center:dispatchEvent({name = data_center.MSG_CALL_CARD_EVENT})
end

return MsgCallCardData