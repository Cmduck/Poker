--
-- Author: GFun
-- Date: 2017-03-28 19:43:05
--
local BaseData = require("script.fightbombScript.data.BaseData")
local SceneCallData = class("SceneCallData", BaseData)

--与服务端对应的数据结构
local SceneCallDataStruct = {
		{m_lCellScore_			= 1},
		{m_wServerType_			= GAME_GENRE_GOLD},
		{m_wBankerUser_ 		= -1},
		{m_wCurrentUser_ 		= -1},

		{m_cbMyHandCardData_ 	= {}},
		{m_cbHandCardCountTab_	= {}},
		
		{m_lTotalScore_		  = {}},
		{m_bDealDismiss_ 		= false},
		{m_cbRequestLeaveUser_  = -1},
		{m_szRequestLeaveReason_ = ""},
	}

function SceneCallData:ctor()
	-- body
	SceneCallData.super.ctor(self)

	self:SetDataType(self.class.SCENE_DATA_TYPE)
	self:SetDataStructParams(SceneCallDataStruct)
end

function SceneCallData:ExtendData(data_center)
	data_center.m_wServerStatus_ = GS_UG_CALL
	data_center.m_cbSelfChairID_ = FGameDC:getDC():GetMeChairID()
	data_center.m_bReConnect_ = true
	data_center.m_cbMyHandCardCount_ = data_center.m_cbHandCardCountTab_[data_center.m_cbSelfChairID_ + 1]
	data_center.m_cbMyHandCardData_ = ConvertTableToArray(data_center.m_cbMyHandCardData_, data_center.m_cbMyHandCardCount_)

	data_center:saveUserInfo()
end

function SceneCallData:DispatchEvent(data_center)
	print("------------------------- > SceneCallData:DispatchEvent(data_center)")
	data_center:dispatchEvent({name = data_center.SCENE_CALL_EVENT})
end
return SceneCallData