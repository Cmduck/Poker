--
-- Author: GFun
-- Date: 2016-12-10 09:28:52
--
local BaseData = require("script.fightbombScript.data.BaseData")
local MsgGameStartData = class("MsgGameStartData", BaseData)

local MsgGameStartDataStruct = {
	{m_wBankerUser_       = -1},
	{m_wCurrentUser_      = -1},
	{m_cbMyHandCardData_  = {}},
	{m_cbMyHandCardCount_ = 0},	
}

function MsgGameStartData:ctor()
	MsgGameStartData.super.ctor(self)

	self:SetDataType(self.class.MSG_DATA_TYPE)
	self:SetDataStructParams(MsgGameStartDataStruct)
end

function MsgGameStartData:ExtendData(data_center)
	data_center.m_cbMyHandCardData_ = ConvertTableToArray(data_center.m_cbMyHandCardData_, data_center.m_cbMyHandCardCount_)
	dump(data_center.m_cbMyHandCardData_, "手牌数组")
	if data_center.m_b1V3_ then
		data_center.m_wServerStatus_ = GS_UG_BAO
		data_center.m_cbGameModel_ = GAME_MODEL_BAO
	else
		data_center.m_wServerStatus_ = GS_UG_CALL
		data_center.m_cbGameModel_ = GAME_MODEL_CALL
	end
	data_center.m_bFirstOutCard_      = true
	--保存用户数据
	data_center:saveUserInfo()
end

function MsgGameStartData:DispatchEvent(data_center)
	print("------------------------------MsgGameStartData:DispatchEvent------------------------")
	data_center:dispatchEvent({name = data_center.MSG_GAME_START_EVENT})
end

return MsgGameStartData