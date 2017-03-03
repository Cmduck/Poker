
--
local CardHelper 				= require("script.50kScript.card.CardHelper")
--数据构造
local DataParse 				= require("script.50kScript.data.DataParse")
--数据解析
local DataStruct 				= require("script.50kScript.data.DataStruct")

local DataCenter = class("DataCenter", cc.mvc.ModelBase)

--[常量]
DataCenter.INVALID_CHAIR = -1
--[事件]
DataCenter.SCENE_FREE_EVENT					= "SCENE_FREE_EVENT"
DataCenter.SCENE_HOU_EVENT					= "SCENE_HOU_EVENT"
DataCenter.SCENE_PALYING_EVENT				= "SCENE_PALYING_EVENT"
DataCenter.SCENE_CONTINUE_EVENT				= "SCENE_CONTINUE_EVENT"

DataCenter.MSG_GAME_START_EVENT 			= "MSG_GAME_START_EVENT"
--DataCenter.MSG_OUT_CARD_EVENT         		 = "MSG_OUT_CARD_EVENT"
DataCenter.MSG_PASS_CARD_EVENT         		= "MSG_PASS_CARD_EVENT"
DataCenter.MSG_GAME_END_EVENT 				= "MSG_GAME_END_EVENT"
DataCenter.MSG_HOUSTATE_CARD_EVENT 			= "MSG_HOUSTATE_CARD_EVENT"
DataCenter.MSG_CALL_CARD_EVENT				= "MSG_CALL_CARD_EVENT"
DataCenter.MSG_HOU_CARD_END_EVENT			= "MSG_HOU_CARD_END_EVENT"
DataCenter.MSG_OUT_CARD_START_EVENT			= "MSG_OUT_CARD_START_EVENT"
DataCenter.MSG_OUT_CARD_END_EVENT			= "MSG_OUT_CARD_END_EVENT"
DataCenter.MSG_CUR_TURN_OVER_EVENT			= "MSG_CUR_TURN_OVER_EVENT"
DataCenter.MSG_OVER_CARD_EVENT				= "MSG_OVER_CARD_EVENT"

DataCenter.SYSTEM_G_USER_TRUSTEESHIP 		= "SYSTEM_G_USER_TRUSTEESHIP"
--[属性]
-- 定义属性
DataCenter.schema = clone(cc.mvc.ModelBase.schema)
--游戏属性
DataCenter.schema["m_wServerType"] 			= {"number", GAME_GENRE_GOLD} 				-- 服务器类型 积分 金币 比赛 
DataCenter.schema["m_wServerStatus"]    	= {"number", GS_UG_FREE} 					-- 场景状态
DataCenter.schema["m_lCellScore"]       	= {"number", 1}								-- 单元积分
DataCenter.schema["m_lMultiple"]       		= {"number", 1}								-- 游戏倍数
DataCenter.schema["m_bIsCreateTable"]       = {"bool", false}							-- 是否建桌
DataCenter.schema["m_cbGameModel"]       	= {"number", GAME_MODE_JIAO}				-- 游戏玩法 叫牌 或 吼牌
DataCenter.schema["m_cbCurTurnScore"]       = {"number", 0}								-- 本轮积分

--用户数据
DataCenter.schema["m_cbSelfChairID"]       	= {"number", DataCenter.INVALID_CHAIR}		-- 自身椅子号
DataCenter.schema["m_pAllUserDataTab"]      = {"table", {}}								-- 用户数据
DataCenter.schema["m_cbHandCardCountTab"]   = {"table", {27, 27, 27, 27}}				-- 剩余扑克
DataCenter.schema["m_cbOperationTab"]		= {"table", {}}								-- 用户操作 255 未操作 0 pass 1 出牌
DataCenter.schema["m_cbHouCardInfo"]     	= {"table", {0, 0, 0, 0}}					-- 吼牌信息 0 未操作 1 吼牌 2 不吼
DataCenter.schema["m_cbMyHandCardData"]     = {"table", {}}								-- 自己手牌
DataCenter.schema["m_cbMyHandCardCount"]    = {"number", MAX_COUNT}						-- 手牌个数

--游戏数据
DataCenter.schema["m_bReConnect"]       	= {"bool", false}							-- 是否断线重连(判断是否有发牌动画)
DataCenter.schema["m_bGameOver"]       		= {"bool", false}							-- 是否游戏结束(建桌使用)
DataCenter.schema["m_bDealOutCard"]       	= {"bool", false}							-- 正在处理出牌
DataCenter.schema["m_wBankerUser"]       	= {"number", DataCenter.INVALID_CHAIR}		-- 庄家玩家
DataCenter.schema["m_wCurrentUser"]       	= {"number", DataCenter.INVALID_CHAIR}		-- 当前玩家
DataCenter.schema["m_wHouCardUser"]     	= {"number", DataCenter.INVALID_CHAIR}		-- 吼牌用户

DataCenter.schema["m_wFriendUser"]       	= {"number", DataCenter.INVALID_CHAIR}		-- 伙伴玩家
DataCenter.schema["m_wPrevOutCardUser"]     = {"number", DataCenter.INVALID_CHAIR}		-- 上个出牌玩家
DataCenter.schema["m_cbPrevOutCardCount"]   = {"number", 0}								-- 上个玩家出牌数
DataCenter.schema["m_cbPrevOutCardData"]    = {"table", {}}								-- 上一个玩家出牌数据
DataCenter.schema["m_wPrevOperationUser"]   = {"number", DataCenter.INVALID_CHAIR}		-- 上一个操作用户
DataCenter.schema["m_cbCallCardData"]     	= {"number", 0}								-- 叫牌数据
--DataCenter.schema["m_bTurnOver"]     		= {"bool", false}							-- 一轮结束
DataCenter.schema["m_bFirstOutCard"]     	= {"bool", true}							-- 一轮首出
DataCenter.schema["m_cbPassCardInfo"]     	= {"table", {0, 0, 0, 0}}					-- 一轮pass 0 未操作 1 pass 2出牌
DataCenter.schema["m_wCurTurnWinner"]     	= {"number", DataCenter.INVALID_CHAIR}		-- 当轮赢家

DataCenter.schema["m_cbCardOverOrderTab"] 	= {"table", {}}								-- 出完牌次序
-- DataCenter.schema["m_cbOrderTemp"]			= {"number", 0} 							-- 名次
DataCenter.schema["m_cbOverCardCount"]		= {"number", 0} 							-- 完牌人数

--[[
	结算相关
--]]
DataCenter.schema["m_cbCardScoreTab"]		= {"table", {0, 0, 0, 0}}					--牌面得分

DataCenter.schema["m_bIsMyFriend"]			= {"table", {false, true, false, false}}	--是否朋友
DataCenter.schema["m_bIsAnJiao"]			= {"table", {false, true, false, false}}	--是否暗叫
DataCenter.schema["m_bIsHou"]				= {"table", {false, true, false, false}}	--是否吼牌
DataCenter.schema["m_bIsBang"]				= {"table", {false, true, false, false}}	--是否绑
DataCenter.schema["m_bIsQing"]				= {"table", {false, true, false, false}}	--是否清

DataCenter.schema["m_bIs50K"]				= {"table", {0, 1, 0, 0}}					--是否50K
DataCenter.schema["m_bIs6Bomb"]				= {"table", {0, 1, 0, 0}}					--是否6炸弹
DataCenter.schema["m_bIs7Bomb"]				= {"table", {0, 1, 0, 0}}					--是否7炸弹
DataCenter.schema["m_bIsDoubleKing"]		= {"table", {0, 1, 0, 0}}					--是否双王
DataCenter.schema["m_bIs50THK"]				= {"table", {0, 1, 0, 0}}					--是否同花50K
DataCenter.schema["m_bIsTianBomb"]			= {"table", {0, 1, 0, 0}}					--是否天炸
DataCenter.schema["m_bIsWudiBomb"]			= {"table", {0, 1, 0, 0}}					--是否无敌炸

DataCenter.schema["m_cbWinnerOrder"]		= {"table", {-1, -1, -1, -1}}				--胜利名次
DataCenter.schema["m_cbGameScoreTab"]		= {"table", {0, 0, 0, 0}}					--得分信息
DataCenter.schema["m_cbHandCardDataTab"]	= {"table", {}}								--玩家手牌
DataCenter.schema["m_cbHandCardCountTab"]	= {"table", {27, 27, 27, 27}}				--手牌数目

--[[
	系统消息相关
--]]
--托管相关
DataCenter.schema["m_bSysTrusteeshipTab"]      = {"table", {false, false, false, false}}


function DataCenter:ctor()
	-- body
    DataCenter.super.ctor(self, properties)
end
--[[
	数据操作
--]]
function DataCenter:initSceneData(data)
	-- body
	DataStruct:initSceneStructData(data, self)
end

function DataCenter:initGameMsgData(data)
	-- body
	DataStruct:initGameMsgData(data, self)
end

function DataCenter:initSystemMsgData(systemID, data)
	DataStruct:initSystemMsgData(systemID, data, self)
end

function DataCenter:getSceneMsgParseStr(status)
	-- body
	return DataParse:getSceneMsgParseStr(status)
end

function DataCenter:getGameMsgParseStr(status)
	-- body
	return DataParse:getGameMsgParseStr(status)
end

--[[
	数据获取
--]]

--单元积分
function DataCenter:getCellScore()
	return self.m_lCellScore_
end

--倍数
function DataCenter:getMultiple()
	return self.m_lMultiple_
end

--庄家
function DataCenter:getBankerUser()
	return self.m_wBankerUser_
end

--当前玩家
function DataCenter:getCurrentUser()
	return self.m_wCurrentUser_
end

function DataCenter:getHouCardUser()
	return self.m_wHouCardUser_
end

--游戏类型
function DataCenter:getServerType()
	-- body
	return self.m_wServerType_
end

function DataCenter:getServerStatus()
	-- body
	return self.m_wServerStatus_
end

function DataCenter:getGameModel()
	return self.m_cbGameModel_
end

--是否建桌
function DataCenter:isCreateTable()
	-- body
	return self.m_bIsCreateTable_
end

--当轮积分
function DataCenter:getCurTurnScore()
	return self.m_cbCurTurnScore_
end

--是否断线重连
function DataCenter:getIsReConnect()
	-- body
	return self.m_bReConnect_
end

--获取自身椅子号
function DataCenter:getSelfChairID()
	return self.m_cbSelfChairID_
end

--获取用户数据
function DataCenter:getUserDataTab(chairId)
	return self.m_pAllUserDataTab_[chairId]
end

--备份用户数据
function DataCenter:backupUserInfoTab()
	for i = 1, GAME_PLAYER do
		self.m_pAllUserDataTab_[i] = clone(FGameDC:getDC():GetUserInfo(i - 1))
	end
end

--获取用户剩余牌数
function DataCenter:getRemainingCardTab()
	return self.m_cbHandCardCountTab_
end

--获取用户操作
function DataCenter:getUserOperationTab()
	return self.m_cbOperationTab_
end

--获取吼牌状态
function DataCenter:getUserHouStateTab()
	return self.m_cbHouCardInfo_
end

--获取自身手牌
function DataCenter:getSelfHandCardData()
	return self.m_cbMyHandCardData_
end

--获取自身手牌个数
function DataCenter:getSelfHandCardCount()
	return self.m_cbHandCardCountTab_[self.m_cbSelfChairID_ + 1]
	--return self.m_cbMyHandCardCount_
end

function DataCenter:setSelfHandCardCount(minusCount)
	self.m_cbHandCardCountTab_[self.m_cbSelfChairID_ + 1] = self.m_cbHandCardCountTab_[self.m_cbSelfChairID_ + 1] - minusCount
end

--是否结束
function DataCenter:getIsGameOver()
	-- body
	return self.m_bGameOver_
end

function DataCenter:getCallCardData()
	return self.m_cbCallCardData_
end

function DataCenter:getIsFirstOutCard()
	-- body
	return self.m_bFirstOutCard_
end

function DataCenter:getUserPassCardTab()
	return self.m_cbPassCardInfo_
end

function DataCenter:getPrevOutUser()
	-- body
	return self.m_wPrevOutCardUser_
end

function DataCenter:getPrevOutCardCount()
	return self.m_cbPrevOutCardCount_
end

function DataCenter:getPrevOutCardData()
	-- body
	return self.m_cbPrevOutCardData_
end

function DataCenter:getOverCardUserOrder()
	-- body
	return self.m_cbCardOverOrderTab_
end

function DataCenter:getOverCardCount()
	return self.m_cbOverCardCount_
end

function DataCenter:getIsDealOutCard()
	return self.m_bDealOutCard_
end

function DataCenter:setIsDealOutCard(bOut)
	self.m_bDealOutCard_ = bOut
end

function DataCenter:getIsDealPassCard()
	return self.m_bDealPassCard_
end

function DataCenter:setIsDealPassCard(bPass)
	self.m_bDealPassCard_ = bPass
end

--[[
	倍数参数
--]]
function DataCenter:getMyFriendTab()
	return self.m_bIsMyFriend_
end

function DataCenter:getAnJiaoTab()
	return self.m_bIsAnJiao_
end

function DataCenter:getHouTab()
	return self.m_bIsHou_
end

function DataCenter:getBangTab()
	return self.m_bIsBang_
end

function DataCenter:getQingTab()
	return self.m_bIsQing_
end

function DataCenter:get50KTab()
	return self.m_bIs50K_
end

function DataCenter:get6BombTab()
	return self.m_bIs6Bomb_
end

function DataCenter:get7BombTab()
	return self.m_bIs7Bomb_
end

function DataCenter:getDoubleKingTab()
	return self.m_bIsDoubleKing_
end	

function DataCenter:get50THKTab()
	return self.m_bIs50THK_
end

function DataCenter:getTianBombTab()
	return self.m_bIsTianBomb_
end

function DataCenter:getWudiBombTab()
	return self.m_bIsWudiBomb_
end
--[[
	结算
--]]
function DataCenter:getCardScoreTab()
	return self.m_cbCardScoreTab_
end

function DataCenter:getWinnerOrderTab()
	return self.m_cbWinnerOrder_
end

function DataCenter:getGameScoreTab()
	return self.m_cbGameScoreTab_
end

function DataCenter:getPrevOperationUser()
	return self.m_wPrevOperationUser_
end

-------------------------------------【系统消息相关】-----------------------------------
--获取所有玩家托管状态
function DataCenter:getSysTrusteeshipStatus()
	return self.m_bSysTrusteeshipTab_
end

function DataCenter:getMyTrusteeshipStatus()
	return self.m_bSysTrusteeshipTab_[self.m_cbSelfChairID_ + 1]
end

--设置托管状态
function DataCenter:setSysTrusteeshipStatus(wChairID, bTrusteeship)
	self.m_bSysTrusteeshipTab_[wChairID + 1] = bTrusteeship
end





----------------------------------【Get建桌相关】-------------------------------------
function DataCenter:getRandId()
	-- body
	return self.randId_
end

function DataCenter:getInningOption()
	-- body
	return self.inningOption_
end

function DataCenter:getRoomCardOption()
	-- body
	return self.roomCardOption_
end

function DataCenter:getLessRoomCardTab()
	-- body
	return self.bLessRoomCardTab_
end

function DataCenter:getPlaneOption()
	-- body
	return self.planeOption_
end

function DataCenter:getPlaneNum()
	-- body
	return self.planeNum_
end

function DataCenter:getMaxInningNum()
	-- body
	return self.maxInningNum_
end

function DataCenter:getCurInningNum()
	-- body
	return self.curInningNum_
end

function DataCenter:addCurInningNum()
	-- body
	self.curInningNum_ = self.curInningNum_ + 1
end

function DataCenter:isGameOver()
	-- body
	return self.curInningNum_ >= self.maxInningNum_
end

function DataCenter:getIsAlreadySetRule()
	-- body
	return self.bIsAlreadySetRule_
end

function DataCenter:getUserChairId()
	-- body
	return self.userChairId_
end

function DataCenter:getRequestLeaveUser()
	-- body
	return self.requestLeaveUser_
end

function DataCenter:resetRequestLeaveInfo()
	-- body
	self.requestLeaveUser_ = -1
	self.szLeaveReason_ = "对不起，我有事要先离开一会"
	self.dismissResult_ = -1
end
function DataCenter:getLeaveReason()
	-- body
	return self.szLeaveReason_
end

function DataCenter:getLeaveResult()
	-- body
	return self.dismissResult_
end

function DataCenter:isDismisss()
	-- body
	return self.bDismiss_
end

function DataCenter:getIsClickContinueGame()
	-- body
	return self.bClickContinueGame_
end

function DataCenter:setClickContinueGame(bClicked)
	-- body
	self.bClickContinueGame_ = bClicked
end
function DataCenter:getUsersReady()
	-- body
	return self.usersReady_
end

function DataCenter:getHistoryScore()
	-- body
	return self.m_lHistoryScore_
end
----------------------------------【Get建桌相关END】----------------------------------------------------


------------------------------------------结算相关------------------------------------------

function DataCenter:saveUserInfo()
	-- body

	for i = 1, GAME_PLAYER do
		self.UserInfoBackups_[i] = clone(FGameDC:getDC():GetUserInfo(i - 1))
	end
end

function DataCenter:resetUserInfo()
	-- body
	self.UserInfoBackups_ = {}
end

function DataCenter:getUserInfo(chairId)
	-- body
	if self.UserInfoBackups_ and self.UserInfoBackups_[chairId + 1] then
		return self.UserInfoBackups_[chairId + 1]
	else
		return nil
	end
end

function DataCenter:RepositDataEx()
	-- body
	self.m_wServerStatus_ 		= GS_UG_FREE
	self.m_lMultiple_ 			= 1
	self.m_bIsCreateTable_ 		= false
	self.m_cbGameModel_			= GAME_MODE_JIAO
	self.m_cbCurTurnScore_ 		= 0
	self.m_pAllUserDataTab_ 	= {}
	self.m_cbHandCardCountTab_ 	= {27, 27, 27, 27}
	self.m_cbOperationTab_		= {}													-- 用户操作 255 未操作 0 pass 1 出牌
	self.m_cbHouCardInfo_		= {0, 0, 0, 0}											-- 吼牌信息 0 未操作 1 吼牌 2 不吼
	self.m_cbMyHandCardData_	= {}
	self.m_cbMyHandCardCount_	= MAX_COUNT
	self.m_bReConnect_ 			= false  												-- 是否断线重连
	self.m_bGameOver_ 			= false 												-- 是否游戏结束
	self.m_wBankerUser_			= DataCenter.INVALID_CHAIR 					
	self.m_wCurrentUser_		= DataCenter.INVALID_CHAIR 								
	self.m_wHouCardUser_ 		= DataCenter.INVALID_CHAIR 	
	self.m_wFriendUser_			= DataCenter.INVALID_CHAIR
	self.m_wPrevOutCardUser_ 	= DataCenter.INVALID_CHAIR
	self.m_cbPrevOutCardCount_	= 0
	self.m_cbPrevOutCardData_	= {}
	self.m_wPrevOperationUser_	= DataCenter.INVALID_CHAIR
	self.m_cbCallCardData_		= 0
	self.m_bFirstOutCard_		= true
	self.m_cbPassCardInfo_		= {0, 0, 0, 0}
	self.m_wCurTurnWinner_ 		= DataCenter.INVALID_CHAIR
	self.m_cbCardOverOrderTab_	= {} 													-- 出完牌次序
	self.m_cbOverCardCount_		= 0														-- 完牌人数
	self.m_bDealOutCard_ 		= false
	self.m_bDealPassCard_ 		= false
--[[
	系统消息数据
--]]
	self.m_bSysTrusteeshipTab_  = {false, false, false, false}
--[[
	结算相关
--]]
	self.m_cbCardScoreTab_		= {0, 0, 0, 0}
	self.m_bIsMyFriend_ 		= {false, false, false, false}
	self.m_bIsAnJiao_ 			= {false, false, false, false}
	self.m_bIsHou_ 				= {false, false, false, false}
	self.m_bIsBang_ 			= {false, false, false, false}
	self.m_bIsQing_				= {false, false, false, false}

	self.m_bIs50K_ 				= {0, 0, 0, 0}
	self.m_bIs6Bomb_			= {0, 0, 0, 0}
	self.m_bIs7Bomb_ 			= {0, 0, 0, 0}
	self.m_bIsDoubleKing_		= {0, 0, 0, 0}
	self.m_bIs50THK_			= {0, 0, 0, 0}
	self.m_bIsTianBomb_ 		= {0, 0, 0, 0}
	self.m_bIsWudiBomb_			= {0, 0, 0, 0}

	self.m_cbWinnerOrder_ 		= {-1, -1, -1, -1}
	self.m_cbGameScoreTab_		= {0, 0, 0, 0}
	self.m_cbHandCardDataTab_	= {}
	self.m_cbHandCardCountTab_ 	= {27, 27, 27, 27}
end

function DataCenter:Destroy()
	-- body
	self.SceneFreeData_ = nil
	self.SceneBaoData_ = nil
	self.ScenePlayData_ = nil
	self.SceneContinueData_ = nil
	self:RepositDataEx()
end

return DataCenter