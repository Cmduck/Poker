--
-- Author: GFun
-- Date: 2017-03-13 09:32:52
--
local BaseData = require("script.fightbombScript.data.BaseData")
local MsgDismissResultData = class("MsgDismissResultData", BaseData)

local MsgDismissResultDataStruct = {
	{m_cbDismissResult_ = -1},	-- 0:失败 1:成功
}

function MsgDismissResultData:ctor()
	MsgDismissResultData.super.ctor(self)

	self:SetDataType(self.class.MSG_DATA_TYPE)
	self:SetDataStructParams(MsgDismissResultDataStruct)
end

function MsgDismissResultData:ExtendData(data_center)

end

function MsgDismissResultData:DispatchEvent(data_center)
	--print("------------------------------MsgDismissResultData:DispatchEvent------------------------")
	data_center:dispatchEvent({name = data_center.MSG_DISMISS_RESULT_EVENT})
end

return MsgDismissResultData