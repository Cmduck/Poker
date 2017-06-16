--
-- Author: GFun
-- Date: 2017-03-13 09:51:08
--
--建桌模式继续游戏
local BaseData = require("script.fightbombScript.data.BaseData")
local MsgStartGameData = class("MsgStartGameData", BaseData)

local MsgStartGameDataStruct = {
	{m_cbReadyStatus_ = {}}
}

function MsgStartGameData:ctor()
	MsgStartGameData.super.ctor(self)

	self:SetDataType(self.class.MSG_DATA_TYPE)
	self:SetDataStructParams(MsgStartGameDataStruct)
end

function MsgStartGameData:ExtendData(data_center)

end

function MsgStartGameData:DispatchEvent(data_center)
	--print("------------------------------MsgStartGameData:DispatchEvent------------------------")
	data_center:dispatchEvent({name = data_center.MSG_STARTGAME_EVENT})
end

return MsgStartGameData