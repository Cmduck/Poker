--
-- Author: GFun
-- Date: 2017-05-09 17:17:22
--
local BaseData = require("script.fightbombScript.data.BaseData")
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