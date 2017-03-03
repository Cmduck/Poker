--
-- Author: GFun
-- Date: 2016-12-15 10:20:17
--
local BaseData = require("script.50kScript.data.BaseData")
local MsgOutCardStartData = class("MsgOutCardStartData", BaseData)

local MsgOutCardStartDataStruct = {
	{m_wCurrentUser_ = -1}
}

function MsgOutCardStartData:ctor()
	MsgOutCardStartData.super.ctor(self)

	self:SetDataType(self.class.MSG_DATA_TYPE)
	self:SetDataStructParams(MsgOutCardStartDataStruct)
end

function MsgOutCardStartData:ExtendData(data_center)
	--将准备出牌玩家的pass信息重置
	data_center.m_cbPassCardInfo_[data_center.m_wCurrentUser_ + 1] = 0
end

function MsgOutCardStartData:DispatchEvent(data_center)
	print("------------------------------MsgOutCardStartData:DispatchEvent------------------------")
	data_center:dispatchEvent({name = data_center.MSG_OUT_CARD_START_EVENT})
end

return MsgOutCardStartData