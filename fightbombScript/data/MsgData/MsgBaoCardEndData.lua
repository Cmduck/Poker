--
-- Author: GFun
-- Date: 2017-05-04 11:05:18
--
local BaseData = require("script.fightbombScript.data.BaseData")
local MsgBaoCardEndData = class("MsgBaoCardEndData", BaseData)

local MsgBaoCardEndDataStruct = {
	{m_wCurrentUser_ = -1},
	{m_cbFaction_	   = {}},
}

function MsgBaoCardEndData:ctor()
	MsgBaoCardEndData.super.ctor(self)

	self:SetDataType(self.class.MSG_DATA_TYPE)
	self:SetDataStructParams(MsgBaoCardEndDataStruct)
end

function MsgBaoCardEndData:ExtendData(data_center)
	--如果有玩家包牌
	if data_center.m_wCurrentUser_ ~= 255 then
		data_center.m_wBankerUser_ = data_center.m_wCurrentUser_
		data_center.m_cbGameModel_ = GAME_MODEL_BAO
		data_center.m_wServerStatus_ = GS_UG_PLAYING
	else
		data_center.m_wCurrentUser_ = data_center.m_wBankerUser_
		data_center.m_cbGameModel_ = GAME_MODEL_CALL
		data_center.m_wServerStatus_ = GS_UG_CALL
	end
end

function MsgBaoCardEndData:DispatchEvent(data_center)
	--print("------------------------------MsgBaoCardEndData:DispatchEvent------------------------")
	data_center:dispatchEvent({name = data_center.MSG_BAO_CARD_END_EVENT})
end

return MsgBaoCardEndData