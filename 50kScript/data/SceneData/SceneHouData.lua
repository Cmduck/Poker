
local BaseData = require("script.50kScript.data.BaseData")
local SceneHouData = class("SceneHouData", BaseData)

--与服务端对应的数据结构
local SceneHouDataStruct = {
		{m_wBankerUser_ 		= -1},
		{m_wCurrentUser_ 		= -1},
		{m_cbCallCardData_ 		= 0},
		{m_cbMyHandCardData_ 	= {}},
		{m_cbHouCardInfo_ 		= {}},
		{m_lCellScore_			= 1},
		{m_wServerType_			= GAME_GENRE_GOLD},
	}

function SceneHouData:ctor()
	-- body
	SceneHouData.super.ctor(self)

	self:SetDataType(self.class.SCENE_DATA_TYPE)
	self:SetDataStructParams(SceneHouDataStruct)
end

function SceneHouData:ExtendData(data_center)
	data_center.m_cbMyHandCardData_ = ConvertTableToArray(data_center.m_cbMyHandCardData_, 27)
	data_center.m_wServerStatus_ = GS_UG_HOU
	data_center.m_cbSelfChairID_ = FGameDC:getDC():GetMeChairID()
	data_center.m_bReConnect_ = true
	if data_center.m_wServerType_ == GAME_GENRE_GOLD then
		--金币场保存用户数据
		data_center:backupUserInfoTab()
	end
end

function SceneHouData:DispatchEvent(data_center)
	print("------------------------- > SceneHouData:DispatchEvent(data_center)")
	data_center:dispatchEvent({name = data_center.SCENE_HOU_EVENT})
end
return SceneHouData