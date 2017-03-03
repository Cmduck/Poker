--
-- Author: GFun
-- Date: 2016-12-10 09:28:52
--
local BaseData = require("script.50kScript.data.BaseData")
local MsgGameStartData = class("MsgGameStartData", BaseData)

local MsgGameStartDataStruct = {
	{m_wBankerUser_ = -1},
	{m_wCurrentUser_ = -1},
	{m_cbMyHandCardData_ = {}},	
}

function MsgGameStartData:ctor()
	MsgGameStartData.super.ctor(self)

	self:SetDataType(self.class.MSG_DATA_TYPE)
	self:SetDataStructParams(MsgGameStartDataStruct)
end

function MsgGameStartData:ExtendData(data_center)
	data_center.m_cbMyHandCardData_ = ConvertTableToArray(data_center.m_cbMyHandCardData_, 27)
	data_center.m_wServerStatus_ = GS_UG_HOU
	if data_center.m_wServerType_ == GAME_GENRE_GOLD then
		--金币场保存用户数据
		data_center:backupUserInfoTab()
	end
end

function MsgGameStartData:DispatchEvent(data_center)
	--print("------------------------------MsgGameStartData:DispatchEvent------------------------")
	data_center:dispatchEvent({name = data_center.MSG_GAME_START_EVENT})
end

return MsgGameStartData