--
-- Author: GFun
-- Date: 2017-05-04 11:12:43
--
local BaseData = require("script.fightbombScript.data.BaseData")
local MsgOutJiaoCardData = class("MsgOutJiaoCardData", BaseData)

local MsgOutJiaoCardDataStruct = {

}

function MsgOutJiaoCardData:ctor()
	MsgOutJiaoCardData.super.ctor(self)

	self:SetDataType(self.class.MSG_DATA_TYPE)
	self:SetDataStructParams(MsgOutJiaoCardDataStruct)
end

function MsgOutJiaoCardData:ExtendData(data_center)
	data_center.m_bOutCallCard_ = true
end

function MsgOutJiaoCardData:DispatchEvent(data_center)
	print("------------------------------MsgOutJiaoCardData:DispatchEvent------------------------")
	data_center:dispatchEvent({name = data_center.MSG_OUT_JIAO_CARD_EVENT})
end

return MsgOutJiaoCardData