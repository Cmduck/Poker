--
-- Author: GFun
-- Date: 2016-12-14 17:03:29
--

local BaseData = require("script.50kScript.data.BaseData")
local MsgHouStateData = class("MsgHouStateData", BaseData)

local MsgHouStateDataStruct = {
	{m_wPrevOperationUser_ = -1},
	{m_wCurrentUser_ = -1},
}

function MsgHouStateData:ctor()
	MsgHouStateData.super.ctor(self)

	self:SetDataType(self.class.MSG_DATA_TYPE)
	self:SetDataStructParams(MsgHouStateDataStruct)
end

function MsgHouStateData:ExtendData(data_center)
	data_center.m_cbHouCardInfo_[data_center.m_wPrevOperationUser_ + 1] = 2
end

function MsgHouStateData:DispatchEvent(data_center)
	print("------------------------------MsgHouStateData:DispatchEvent------------------------")
	data_center:dispatchEvent({name = data_center.MSG_HOUSTATE_CARD_EVENT})
end

return MsgHouStateData