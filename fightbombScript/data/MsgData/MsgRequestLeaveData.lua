--
-- Author: GFun
-- Date: 2017-03-13 09:25:05
--
local BaseData = require("script.fightbombScript.data.BaseData")
local MsgRequestLeaveData = class("MsgRequestLeaveData", BaseData)

local MsgRequestLeaveDataStruct = {
	{m_cbRequestLeaveUser_ = -1},
	{m_szRequestLeaveReason_ = ""},
}

function MsgRequestLeaveData:ctor()
	MsgRequestLeaveData.super.ctor(self)

	self:SetDataType(self.class.MSG_DATA_TYPE)
	self:SetDataStructParams(MsgRequestLeaveDataStruct)
end

function MsgRequestLeaveData:ExtendData(data_center)

end

function MsgRequestLeaveData:DispatchEvent(data_center)
	--print("------------------------------MsgRequestLeaveData:DispatchEvent------------------------")
	data_center:dispatchEvent({name = data_center.MSG_REQUEST_LEAVE_EVENT})
end

return MsgRequestLeaveData