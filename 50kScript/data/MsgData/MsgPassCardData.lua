--
-- Author: GFun
-- Date: 2016-12-14 11:38:46
--

local BaseData = require("script.50kScript.data.BaseData")
local MsgPassCardData = class("MsgPassCardData", BaseData)

local MsgPassCardDataStruct = {
	{m_wPrevOperationUser_ = -1},
}

function MsgPassCardData:ctor()
	MsgPassCardData.super.ctor(self)

	self:SetDataType(self.class.MSG_DATA_TYPE)
	self:SetDataStructParams(MsgPassCardDataStruct)
end

function MsgPassCardData:ExtendData(data_center)
	data_center.m_cbPassCardInfo_[data_center.m_wPrevOperationUser_ + 1] = 1
end

function MsgPassCardData:DispatchEvent(data_center)
	print("------------------------------MsgPassCardData:DispatchEvent------------------------")
	data_center:dispatchEvent({name = data_center.MSG_PASS_CARD_EVENT})
end

return MsgPassCardData