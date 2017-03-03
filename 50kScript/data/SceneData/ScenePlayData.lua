
local BaseData = require("script.50kScript.data.BaseData")
local ScenePlayData = class("ScenePlayData", BaseData)

--与服务端对应的数据结构
local ScenePlayDataStruct = {
	{m_lCellScore_ = 1},
	{m_lMultiple_ = 1},
	{m_wServerType_ = GAME_GENRE_GOLD},
	{m_wBankerUser_ = -1},

	{m_wCurrentUser_ = -1},
	{m_cbGameModel_ = 0},
	{m_wFriendUser_ = -1},
	{m_cbCurTurnScore_ = 0},

	{m_cbCallCardData_ = 0},
	{m_cbCardScoreTab_ = {}},
	{m_cbMyHandCardData_ = {}},
	{m_cbHandCardCountTab_ = {}},

	{m_wPrevOutCardUser_ = -1},
	{m_cbPrevOutCardCount_ = 0},
	{m_cbPrevOutCardData_ = {}},
	{m_cbCardOverOrderTab_ = {}},
	{m_cbOverCardCount_ = 0},
	{m_cbPassCardInfo_ = {}},
}

function ScenePlayData:ctor()
	-- body
	ScenePlayData.super.ctor(self)

	self:SetDataType(self.class.SCENE_DATA_TYPE)
	self:SetDataStructParams(ScenePlayDataStruct)
end

function ScenePlayData:ExtendData(data_center)
	data_center.m_wServerStatus_ = GS_UG_PLAYING
	data_center.m_cbSelfChairID_ = FGameDC:getDC():GetMeChairID()
	data_center.m_bReConnect_ = true
	--扑克数据转成数组
	local myHandCardCount = data_center.m_cbHandCardCountTab_[data_center.m_cbSelfChairID_ + 1]
	data_center.m_cbMyHandCardData_ = ConvertTableToArray(data_center.m_cbMyHandCardData_, myHandCardCount)
	print("转换后的手牌:")
	dump(data_center.m_cbMyHandCardData_)
	data_center.m_cbPrevOutCardData_ = ConvertTableToArray(data_center.m_cbPrevOutCardData_, data_center.m_cbPrevOutCardCount_)
	print("@@@@@@@@@@@@@@@@@@@@出牌个数:")
	print(data_center.m_cbPrevOutCardCount_)
	print("@@@@@@@@@@@@@@@@@@@@出牌数据：")
	dump(data_center.m_cbPrevOutCardData_)

	data_center.m_bFirstOutCard_ = data_center.m_cbPrevOutCardCount_ == 0
	if data_center.m_wServerType_ == GAME_GENRE_GOLD then
		--金币场保存用户数据
		data_center:backupUserInfoTab()
	end
end

function ScenePlayData:DispatchEvent(data_center)
	print("------------------------- > ScenePlayData:DispatchEvent(data_center)")
	data_center:dispatchEvent({name = data_center.SCENE_PALYING_EVENT})
end
return ScenePlayData