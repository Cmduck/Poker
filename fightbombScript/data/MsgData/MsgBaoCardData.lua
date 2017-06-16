--
-- Author: GFun
-- Date: 2017-05-04 11:03:22
--
local BaseData = require("script.fightbombScript.data.BaseData")
local MsgBaoCardData = class("MsgBaoCardData", BaseData)

local MsgBaoCardDataStruct = {
	{m_wCurrentUser_ = -1},
	{m_wPrevOperationUser_ = -1},
}

function MsgBaoCardData:ctor()
	MsgBaoCardData.super.ctor(self)

	self:SetDataType(self.class.MSG_DATA_TYPE)
	self:SetDataStructParams(MsgBaoCardDataStruct)
end

function MsgBaoCardData:ExtendData(data_center)
	data_center.m_cbBaoCardInfo_[data_center.m_wPrevOperationUser_ + 1] = 2
end

function MsgBaoCardData:DispatchEvent(data_center)
	print("------------------------------MsgBaoCardData:DispatchEvent------------------------")
	data_center:dispatchEvent({name = data_center.MSG_BAO_CARD_EVENT})
end

return MsgBaoCardData