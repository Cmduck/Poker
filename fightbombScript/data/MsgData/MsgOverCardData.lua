--
-- Author: GFun
-- Date: 2017-05-04 11:14:10
--
local BaseData = require("script.fightbombScript.data.BaseData")
local MsgOverCardData = class("MsgOverCardData", BaseData)

local MsgOverCardDataStruct = {
	{m_wPrevOperationUser_ = -1},
	{m_cbUserOrderNum_ = 0},
}

function MsgOverCardData:ctor()
	MsgOverCardData.super.ctor(self)

	self:SetDataType(self.class.MSG_DATA_TYPE)
	self:SetDataStructParams(MsgOverCardDataStruct)
end

function MsgOverCardData:ExtendData(data_center)
	data_center.m_cbUserOrder_[data_center.m_cbUserOrderNum_] = data_center.m_wPrevOperationUser_
end

function MsgOverCardData:DispatchEvent(data_center)
	--print("------------------------------MsgOverCardData:DispatchEvent------------------------")
	data_center:dispatchEvent({name = data_center.MSG_OVER_CARD_EVENT})
end

return MsgOverCardData