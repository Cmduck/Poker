--
-- Author: GFun
-- Date: 2016-11-04 11:36:55
--
local BaseData = require("script.fightbombScript.data.BaseData")
local SceneContinueData = class("SceneContinueData", BaseData)

--与服务端对应的数据结构
local SceneContinueDataStruct = {
		{m_lCellScore_ 	= 1},
		{m_wServerType_ = GAME_GENRE_GOLD},
		{m_cbReadyStatus_ = {}},
		{m_lTotalScore_ = {}},

		{m_bDealDismiss_         = false},
		{m_cbRequestLeaveUser_   = -1},
		{m_szRequestLeaveReason_ = ""},
	}

function SceneContinueData:ctor()
	-- body
	SceneContinueData.super.ctor(self)

	self:SetDataType(self.class.SCENE_DATA_TYPE)
	self:SetDataStructParams(SceneContinueDataStruct)
end

function SceneContinueData:ExtendData(data_center)
	data_center.m_wServerStatus_ = GS_UG_CONTINUE
	data_center.m_cbSelfChairID_ = FGameDC:getDC():GetMeChairID()

	--保存用户数据
	data_center:saveUserInfo()
end

function SceneContinueData:DispatchEvent(data_center)
	print("------------------------- > SceneContinueData:DispatchEvent(data_center)")
	data_center:dispatchEvent({name = data_center.SCENE_CONTINUE_EVENT})
end

return SceneContinueData