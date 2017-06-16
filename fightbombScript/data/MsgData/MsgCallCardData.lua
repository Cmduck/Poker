--
-- Author: GFun
-- Date: 2017-05-04 11:02:03
--
local BaseData = require("script.fightbombScript.data.BaseData")
local MsgCallCardData = class("MsgCallCardData", BaseData)

local MsgCallCardDataStruct = {
	{m_cbCallCardData_ = 0},
	{m_cbFaction_	   = {}},
}

function MsgCallCardData:ctor()
	MsgCallCardData.super.ctor(self)

	self:SetDataType(self.class.MSG_DATA_TYPE)
	self:SetDataStructParams(MsgCallCardDataStruct)
end

function MsgCallCardData:ExtendData(data_center)
	data_center.m_wServerStatus_ = GS_UG_PLAYING
	data_center.m_cbGameModel_ = GAME_MODEL_CALL
end

function MsgCallCardData:DispatchEvent(data_center)
	--print("------------------------------MsgCallCardData:DispatchEvent------------------------")
	data_center:dispatchEvent({name = data_center.MSG_CALL_CARD_EVENT})
end

return MsgCallCardData