--
-- Author: GFun
-- Date: 2016-12-27 17:19:34
--
local BaseData = require("script.50kScript.data.BaseData")
local MsgOverCardData = class("MsgOverCardData", BaseData)

local MsgOverCardDataStruct = {
	{m_wPrevOperationUser_ = -1},
	{m_cbOverCardCount_ = 0},
}

function MsgOverCardData:ctor()
	MsgOverCardData.super.ctor(self)

	self:SetDataType(self.class.MSG_DATA_TYPE)
	self:SetDataStructParams(MsgOverCardDataStruct)
end

function MsgOverCardData:ExtendData(data_center)
	data_center.m_cbCardOverOrderTab_[data_center.m_cbOverCardCount_] = data_center.m_wPrevOperationUser_
end

function MsgOverCardData:DispatchEvent(data_center)
	--print("------------------------------MsgOverCardData:DispatchEvent------------------------")
	data_center:dispatchEvent({name = data_center.MSG_OVER_CARD_EVENT})
end

return MsgOverCardData