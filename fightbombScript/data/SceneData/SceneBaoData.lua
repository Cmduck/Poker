
local BaseData = require("script.fightbombScript.data.BaseData")
local SceneBaoData = class("SceneBaoData", BaseData)

--与服务端对应的数据结构
local SceneBaoDataStruct = {
		{m_lCellScore_			= 1},
		{m_wServerType_			= GAME_GENRE_GOLD},
		{m_wBankerUser_ 		= -1},
		{m_wCurrentUser_ 		= -1},

		{m_cbMyHandCardData_ 	= {}},
		{m_cbHandCardCountTab_	= {}},
		{m_cbBaoCardInfo_		= {}},

		{m_lTotalScore_ 		= {}},
		{m_bDealDismiss_ 		= false},
		{m_cbRequestLeaveUser_  = -1},
		{m_szRequestLeaveReason_ = ""},
	}

function SceneBaoData:ctor()
	-- body
	SceneBaoData.super.ctor(self)

	self:SetDataType(self.class.SCENE_DATA_TYPE)
	self:SetDataStructParams(SceneBaoDataStruct)
end

function SceneBaoData:ExtendData(data_center)
	data_center.m_wServerStatus_ = GS_UG_BAO
	data_center.m_cbSelfChairID_ = FGameDC:getDC():GetMeChairID()
	data_center.m_bReConnect_ = true
	data_center.m_cbMyHandCardCount_ = data_center.m_cbHandCardCountTab_[data_center.m_cbSelfChairID_ + 1]
	data_center.m_cbMyHandCardData_ = ConvertTableToArray(data_center.m_cbMyHandCardData_, data_center.m_cbMyHandCardCount_)

	data_center:saveUserInfo()
end

function SceneBaoData:DispatchEvent(data_center)
	print("------------------------- > SceneBaoData:DispatchEvent(data_center)")
	data_center:dispatchEvent({name = data_center.SCENE_BAO_EVENT})
end
return SceneBaoData