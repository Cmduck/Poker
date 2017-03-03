--
-- Author: GFun
-- Date: 2016-12-14 20:00:53
--
local BaseData = require("script.50kScript.data.BaseData")
local MsgHouCardEndData = class("MsgHouCardEndData", BaseData)

local MsgHouCardEndDataStruct = {
	{m_cbGameModel_ = 0},	
	{m_wCurrentUser_ = -1},
}

function MsgHouCardEndData:ctor()
	MsgHouCardEndData.super.ctor(self)

	self:SetDataType(self.class.MSG_DATA_TYPE)
	self:SetDataStructParams(MsgHouCardEndDataStruct)
end

function MsgHouCardEndData:ExtendData(data_center)
	--吼牌为庄
	--data_center.m_wBankerUser_ = data_center.m_wCurrentUser_
	data_center.m_wServerStatus_ = GS_UG_PLAYING

	--设置吼牌用户 清空叫牌数据
	if data_center.m_cbGameModel_ == GAME_MODE_HOU then
		data_center.m_wHouCardUser_ = data_center.m_wCurrentUser_
		data_center.m_cbCallCardData_ = 0
	else
		data_center.m_wHouCardUser_ = -1
	end
end

function MsgHouCardEndData:DispatchEvent(data_center)
	--print("------------------------------MsgHouCardEndData:DispatchEvent------------------------")
	data_center:dispatchEvent({name = data_center.MSG_HOU_CARD_END_EVENT})
end

return MsgHouCardEndData