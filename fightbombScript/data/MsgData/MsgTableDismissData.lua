--
-- Author: GFun
-- Date: 2017-03-13 09:28:59
--
local BaseData = require("script.fightbombScript.data.BaseData")
local MsgTableDismissData = class("MsgTableDismissData", BaseData)

local MsgTableDismissDataStruct = {

}

function MsgTableDismissData:ctor()
	MsgTableDismissData.super.ctor(self)

	self:SetDataType(self.class.MSG_DATA_TYPE)
	self:SetDataStructParams(MsgTableDismissDataStruct)
end

function MsgTableDismissData:ExtendData(data_center)

end

function MsgTableDismissData:DispatchEvent(data_center)
	print("------------------------------MsgTableDismissData:DispatchEvent------------------------")
	data_center:dispatchEvent({name = data_center.MSG_TABLEDISMISS_EVENT})
end

return MsgTableDismissData