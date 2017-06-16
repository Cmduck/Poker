
--
local CardHelper 				= require("script.fightbombScript.card.CardHelper")
--数据构造
local DataParse 				= require("script.fightbombScript.data.DataParse")
--数据解析
local DataStruct 				= require("script.fightbombScript.data.DataStruct")

local DataCenter = class("DataCenter", cc.mvc.ModelBase)

--[常量]
DataCenter.INVALID_CHAIR = -1
DataCenter.INVALID_VALUE = -1
--[场景事件]
DataCenter.SCENE_FREE_EVENT					= "SCENE_FREE_EVENT"
DataCenter.SCENE_BAO_EVENT					= "SCENE_BAO_EVENT"
DataCenter.SCENE_CALL_EVENT					= "SCENE_CALL_EVENT"
DataCenter.SCENE_PALYING_EVENT				= "SCENE_PALYING_EVENT"
DataCenter.SCENE_CONTINUE_EVENT				= "SCENE_CONTINUE_EVENT"
--[消息事件]
DataCenter.MSG_GAME_START_EVENT 			= "MSG_GAME_START_EVENT"
DataCenter.MSG_BAO_CARD_EVENT				= "MSG_BAO_CARD_EVENT"
DataCenter.MSG_BAO_CARD_END_EVENT			= "MSG_BAO_CARD_END_EVENT"
DataCenter.MSG_CALL_CARD_EVENT				= "MSG_CALL_CARD_EVENT"
DataCenter.MSG_OUT_JIAO_CARD_EVENT			= "MSG_OUT_JIAO_CARD_EVENT"
DataCenter.MSG_OUT_CARD_START_EVENT			= "MSG_OUT_CARD_START_EVENT"
DataCenter.MSG_OUT_CARD_END_EVENT			= "MSG_OUT_CARD_END_EVENT"
DataCenter.MSG_PASS_CARD_EVENT 				= "MSG_PASS_CARD_EVENT"
DataCenter.MSG_GAME_END_EVENT 				= "MSG_GAME_END_EVENT"
DataCenter.MSG_CUR_TURN_OVER_EVENT			= "MSG_CUR_TURN_OVER_EVENT"
DataCenter.MSG_OVER_CARD_EVENT				= "MSG_OVER_CARD_EVENT"
--[建桌消息]
DataCenter.MSG_SCORE_RULE_EVENT				= "MSG_SCORE_RULE_EVENT"
DataCenter.MSG_REQUEST_LEAVE_EVENT			= "MSG_REQUEST_LEAVE_EVENT"
DataCenter.MSG_TABLEDISMISS_EVENT			= "MSG_TABLEDISMISS_EVENT"
DataCenter.MSG_DISMISS_RESULT_EVENT			= "MSG_DISMISS_RESULT_EVENT"
DataCenter.MSG_TOTAL_ACCOUNT_EVENT			= "MSG_TOTAL_ACCOUNT_EVENT"
DataCenter.MSG_STARTGAME_EVENT				= "MSG_STARTGAME_EVENT"

--[系统事件]
DataCenter.SYSTEM_G_USER_TRUSTEESHIP 		= "SYSTEM_G_USER_TRUSTEESHIP"
--[属性]
-- 定义属性
DataCenter.schema = clone(cc.mvc.ModelBase.schema)
--游戏属性
--场景Free消息没有时 服务器类型的值是不确定的 影响UIIcon
--基础数据
DataCenter.schema["m_wServerType"] 			= {"number", DataCenter.INVALID_VALUE} 		-- 服务器类型 积分 金币 比赛 
DataCenter.schema["m_wServerStatus"]    	= {"number", GS_UG_FREE} 					-- 场景状态
DataCenter.schema["m_lCellScore"]       	= {"number", 1}								-- 单元积分
--游戏变量
DataCenter.schema["m_wBankerUser"]       	= {"number", DataCenter.INVALID_CHAIR}		-- 庄家玩家
DataCenter.schema["m_wBankerFriend"]       	= {"number", DataCenter.INVALID_CHAIR}		-- 庄家伙伴
DataCenter.schema["m_wCurrentUser"]       	= {"number", DataCenter.INVALID_CHAIR}		-- 当前玩家
DataCenter.schema["m_cbGameModel"]       	= {"number", GAME_MODEL_CALL}				-- 游戏模式 0 叫牌 1 吼牌
DataCenter.schema["m_cbCallCardData"]       = {"number", 0}								-- 庄家叫牌
DataCenter.schema["m_bReConnect"]       	= {"bool", false}							-- 是否断线重连(判断是否有发牌动画)
DataCenter.schema["m_bFirstOutCard"]     	= {"bool", true}							-- 一轮首出
DataCenter.schema["m_wCurTurnWinner"]     	= {"number", DataCenter.INVALID_CHAIR}		-- 当轮赢家
DataCenter.schema["m_cbPassCardInfo"]		= {"table", {0, 0, 0, 0}}					-- 一轮pass 0 未操作 1 pass 2出牌
DataCenter.schema["m_cbUserOrder"]			= {"table", {}}								-- 出完次序
DataCenter.schema["m_cbUserOrderNum"]		= {"number", 0}								-- 出完人数
DataCenter.schema["m_bOutCallCard"]			= {"bool", false}							-- 打出叫牌
DataCenter.schema["m_cbScoreCardData"]		= {"table", {}}								-- 分牌数据
DataCenter.schema["m_cbScoreCardCount"]		= {"number", 0}								-- 分牌数目
DataCenter.schema["m_cbFaction"]			= {"table", {}}								-- 阵营信息
--用户数据
DataCenter.schema["m_cbSelfChairID"]       	= {"number", DataCenter.INVALID_CHAIR}		-- 自身椅子号
DataCenter.schema["m_UserInfoBackups"]      = {"table", {}}								-- 用户数据
DataCenter.schema["m_cbMyHandCardData"]     = {"table", {}}								-- 自己手牌
DataCenter.schema["m_cbMyHandCardCount"]    = {"number", MAX_COUNT}						-- 手牌个数
--游戏积分
DataCenter.schema["m_cbCurTurnScore"]       = {"number", 0}								-- 本轮积分
DataCenter.schema["m_cbCurXiScore"]       	= {"number", 0}								-- 本轮喜分
DataCenter.schema["m_cbCatchScore"]     	= {"table", {0, 0, 0, 0}}					-- 用户抓分
DataCenter.schema["m_nXiScore"]				= {"table", {0, 0, 0, 0}}					-- 用户喜分
DataCenter.schema["m_nExtraScore"]			= {"table", {0, 0, 0, 0}}					-- 奖惩分数
--操作相关
DataCenter.schema["m_bDealUserOperation"]   = {"bool", false}							-- 正在用户操作(叫包牌、出牌或pass)
DataCenter.schema["m_wPrevOutCardUser"]     = {"number", DataCenter.INVALID_CHAIR}		-- 上个出牌玩家
DataCenter.schema["m_cbPrevOutCardCount"]   = {"number", 0}								-- 上个玩家出牌数
DataCenter.schema["m_cbPrevOutCardData"]    = {"number", -1}							-- 上一个玩家出牌数据
DataCenter.schema["m_wPrevOperationUser"]   = {"number", DataCenter.INVALID_CHAIR}		-- 上一个操作用户
DataCenter.schema["m_cbBaoCardInfo"]		= {"table", {0, 0, 0, 0}}					-- 包牌信息 0 未操作 1 包牌 2不包
--[[
	结算相关
--]]
DataCenter.schema["m_cbGameResult"]			= {"number", -1}								--自身胜负 0:失败 1:胜利 2:平局
DataCenter.schema["m_cbGameEndType"]     	= {"number", -1}								--结束原因 0:正常结束 1:游戏解散 2:用户强退
DataCenter.schema["m_cbHandCardDataTab"]	= {"table", {}}									--玩家手牌
DataCenter.schema["m_cbHandCardCountTab"]	= {"table", {MAX_COUNT, MAX_COUNT, MAX_COUNT, MAX_COUNT}}	--手牌数目
DataCenter.schema["m_lGameScoreTab"]     	= {"table", {0, 0, 0, 0}}							--游戏积分 
--[[
	系统消息相关
--]]
--托管相关
DataCenter.schema["m_bSysTrusteeshipTab"] 	= {"table", {false, false, false}}

--[[
	建桌相关
--]]
--[建桌选项]
DataCenter.schema["m_cbInningNumOption"]    = {"table", {6, 12}}				--局数选项
DataCenter.schema["m_cbRoomCardOption"]     = {"table", {1, 2}}					--房卡选项
DataCenter.schema["m_cbGamePlayTypeOption"] = {"table", {1, 2}}					--玩法选项
DataCenter.schema["m_bLessRoomCardOption"]  = {"table", {false, false}}			--房卡不足

--建桌参数
DataCenter.schema["m_bAlreadySetRule"]  	= {"bool", false}			--是否设置规则
DataCenter.schema["m_bCreateTable"]  		= {"bool", false}			--是否建桌模式
DataCenter.schema["m_cbMaxInningNum"]  		= {"number", 8}				--最大局数
DataCenter.schema["m_cbCurInningNum"]  		= {"number", 8}				--当前局数
DataCenter.schema["m_b1V3"]  				= {"bool", false}			--是否支持1V3
DataCenter.schema["m_bThreePlusTwo"]  		= {"bool", false}			--是否支持三带二
DataCenter.schema["m_dwRandID"]  			= {"number", 0}				--房号
DataCenter.schema["m_dwTableUserID"]  		= {"number", 0}				--房主ID
DataCenter.schema["m_dwTableUser"]  		= {"number", INVALID_CHAIR}	--房主椅子号
DataCenter.schema["m_cbReadyStatus"]  		= {"table", {0, 0, 0, 0}}	--准备状态
DataCenter.schema["m_lHistoryScore"]		= {"table", {0, 0, 0, 0}}	--历史积分
DataCenter.schema["m_bGameOver"]       		= {"bool", false}			--是否游戏结束(建桌使用)
DataCenter.schema["m_cbRequestLeaveUser"]	= {"number", INVALID_CHAIR}	--离开用户
DataCenter.schema["m_szRequestLeaveReason"]	= {"string", "对不起，我有事要先离开一会"}	--离开原因
DataCenter.schema["m_cbDismissResult"]		= {"number", -1}			--解散结果
DataCenter.schema["m_bDealDismiss"]			= {"bool", false}			--是否处理解散
DataCenter.schema["m_bDismiss"]				= {"bool", false}			--是否解散

--总结算
DataCenter.schema["m_dwXiScoreCount"]		= {"table", {0, 0, 0, 0}}	--喜分次数
DataCenter.schema["m_cbOrderCount"]			= {"table", {{}, {}, {}, {}}}--游数统计
DataCenter.schema["m_lTotalScore"]			= {"table", {0, 0, 0, 0}}	--总结算
DataCenter.schema["m_lMaxScore"]			= {"number", 0}				--冠军积分

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

--庄家
function DataCenter:getBankerUser()
	return self.m_wBankerUser_
end

--庄家伙伴
function DataCenter:getBankerFriend()
	return self.m_wBankerFriend_
end

--当前玩家
function DataCenter:getCurrentUser()
	return self.m_wCurrentUser_
end

function DataCenter:getGameModel()
	return self.m_cbGameModel_
end

function DataCenter:getCallCardData()
	-- body
	return self.m_cbCallCardData_
end

--服务类型
function DataCenter:getServerType()
	-- body
	return self.m_wServerType_
end

function DataCenter:getServerStatus()
	-- body
	return self.m_wServerStatus_
end

function DataCenter:setServerStatus(status)
	self.m_wServerStatus_ = status
end

--当轮积分
function DataCenter:getCurTurnScore()
	return self.m_cbCurTurnScore_
end

function DataCenter:setCurTurnScore(iScore)
	self.m_cbCurTurnScore_ = iScore
end

--当轮喜分
function DataCenter:getCurXiScore()
	return self.m_cbCurXiScore_
end

function DataCenter:setCurXiScore(iScore)
	self.m_cbCurXiScore_ = iScore
end

function DataCenter:getCurTurnWinner()
	return self.m_wCurTurnWinner_
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

--获取自身手牌
function DataCenter:getSelfHandCardData()
	return self.m_cbMyHandCardData_
end

function DataCenter:getSelfHandCardCount()
	return self.m_cbMyHandCardCount_
end

function DataCenter:reduceHandCardCount(nCount)
	self.m_cbMyHandCardCount_ = self.m_cbMyHandCardCount_ - nCount
end

function DataCenter:getIsFirstOutCard()
	-- body
	return self.m_bFirstOutCard_
end

function DataCenter:getUserPassCardTab()
	return self.m_cbPassCardInfo_
end

function DataCenter:getUserOrder()
	return self.m_cbUserOrder_
end

function DataCenter:getUserOrderNum()
	return self.m_cbUserOrderNum_
end

function DataCenter:getIsOutCallCard()
	return self.m_bOutCallCard_
end

function DataCenter:getScoreCardData()
	return self.m_cbScoreCardData_
end

function DataCenter:addScoreCardData(cbCardData)
	self.m_cbScoreCardCount_ = self.m_cbScoreCardCount_ + 1
	self.m_cbScoreCardData_[self.m_cbScoreCardCount_] = cbCardData
end

function DataCenter:getScoreCardCount()
	return self.m_cbScoreCardCount_
end

function DataCenter:getFaction()
	return self.m_cbFaction_
end

function DataCenter:getCatchScore()
	return self.m_cbCatchScore_
end

function DataCenter:getXiScore()
	return self.m_nXiScore_
end

function DataCenter:getExtraScore()
	return self.m_nExtraScore_
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

function DataCenter:getPrevOperationUser()
	return self.m_wPrevOperationUser_
end

function DataCenter:getIsDealUserOperation()
	return self.m_bDealUserOperation_
end

function DataCenter:setIsDealUserOperation(bDeal)
	self.m_bDealUserOperation_ = bDeal
end

function DataCenter:getUserBaoCardInfo()
	return self.m_cbBaoCardInfo_
end

--[[
	扑克相关
--]]

--[[
	结算
--]]
function DataCenter:getGameResult()
	return self.m_cbGameResult_
end

function DataCenter:getGameEndType()
	return self.m_cbGameEndType_
end

function DataCenter:getHandCardDataTab()
	return self.m_cbHandCardDataTab_
end

function DataCenter:getHandCardCountTab()
	return self.m_cbHandCardCountTab_
end

function DataCenter:getGameScoreTab()
	return self.m_lGameScoreTab_
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
--[建桌选项]
function DataCenter:getInningOption()
	return self.m_cbInningNumOption_
end

function DataCenter:getRoomCardOption()
	return self.m_cbRoomCardOption_
end

function DataCenter:getGamePlayTypeOption()
	return self.m_cbGamePlayTypeOption_
end

function DataCenter:getIsLessRoomCardOption()
	return self.m_bLessRoomCardOption_
end

--[建桌参数]
--是否结束
function DataCenter:getIsGameOver()
	-- body
	return self.m_bGameOver_
end

function DataCenter:getIsAlreadySetRule()
	return self.m_bAlreadySetRule_
end

function DataCenter:getIsCreateTable()
	return self.m_bCreateTable_
end

function DataCenter:getRandID()
	-- body
	return self.m_dwRandID_
end

function DataCenter:getTableUserID()
	return self.m_dwTableUserID_
end

function DataCenter:getTableUser()
	return self.m_dwTableUser_
end

function DataCenter:getMaxInningNum()
	-- body
	return self.m_cbMaxInningNum_
end

function DataCenter:getCurInningNum()
	-- body
	return self.m_cbCurInningNum_
end

function DataCenter:addCurInningNum()
	-- body
	self.m_cbCurInningNum_ = self.m_cbCurInningNum_ + 1
	if self.m_cbCurInningNum_ > self.m_cbMaxInningNum_ then
		self.m_bGameOver_ = true
	end
end

function DataCenter:getIs1V3()
	return self.m_b1V3_
end

function DataCenter:getIsThreePlusTwo()
	-- body
	return self.m_bThreePlusTwo_
end

function DataCenter:getReadyStatus()
	return self.m_cbReadyStatus_
end

function DataCenter:getRequestLeaveUser()
	return self.m_cbRequestLeaveUser_
end

function DataCenter:getRequestLeaveReason()
	return self.m_szRequestLeaveReason_
end

function DataCenter:getDismissResult()
	return self.m_cbDismissResult_
end

function DataCenter:resetRequestLeaveInfo()
	self.m_cbRequestLeaveUser_ = -1
	self.m_szRequestLeaveReason_ = "对不起，我有事要先离开一会"
	self.m_cbDismissResult_ = -1
end

function DataCenter:getIsDealDismiss()
	return self.m_bDealDismiss_
end

function DataCenter:getIsDismiss()
	return self.m_bDismiss_
end

function DataCenter:isGameOver()
	-- body
	return self.curInningNum_ >= self.maxInningNum_
end

function DataCenter:getIsClickContinueGame()
	-- body
	return self.bClickContinueGame_
end

function DataCenter:setClickContinueGame(bClicked)
	-- body
	self.bClickContinueGame_ = bClicked
end
----------------------------------【Get建桌相关END】----------------------------------------------------

--[[
	总结算
--]]
function DataCenter:getXiScoreCount()
	return self.m_dwXiScoreCount_
end

function DataCenter:getOrderCount()
	return self.m_cbOrderCount_
end

function DataCenter:getTotalScore()
	return self.m_lTotalScore_
end

function DataCenter:getMaxScore()
	return self.m_lMaxScore_
end

function DataCenter:ResetTotalData()
	self.m_dwWinCount_  = {0, 0, 0}
	self.m_lTotalScore_ = {0, 0, 0}
	self:resetUserInfo()
end

function DataCenter:saveUserInfo()
	-- body

	for i = 1, GAME_PLAYER do
		local pUserData = FGameDC:getDC():GetUserInfo(i - 1)
		self.m_UserInfoBackups_[i] = {}
		self.m_UserInfoBackups_[i].szAccount = FGameDC:getDC():UnicodeToUtf8(pUserData.szAccount[0])
		self.m_UserInfoBackups_[i].dwUserID = pUserData.dwUserID
		self.m_UserInfoBackups_[i].cbFaceID = pUserData.cbFaceID
		if pUserData and pUserData.szWxFaceAdd then
			self.m_UserInfoBackups_[i].szWxFaceAdd = pUserData.szWxFaceAdd
		end
	end
	--dump(self.m_UserInfoBackups_)
end

function DataCenter:getUserInfo(chairId)
	-- body
	if self.m_UserInfoBackups_ and self.m_UserInfoBackups_[chairId + 1] then
		return self.m_UserInfoBackups_[chairId + 1]
	else
		return nil
	end
end

function DataCenter:resetUserInfo()
	-- body
	self.m_UserInfoBackups_ = {}
end

function DataCenter:RepositDataEx()
	-- body
	self.m_wServerStatus_ 		= GS_UG_FREE
	self.m_bIsCreateTable_ 		= false

	--游戏变量
	self.m_wBankerUser_			= DataCenter.INVALID_CHAIR
	self.m_wBankerFriend_ 		= DataCenter.INVALID_CHAIR 					
	self.m_wCurrentUser_		= DataCenter.INVALID_CHAIR
	self.m_cbCallCardData_ 		= 0
	self.m_bReConnect_ 			= false  	-- 是否断线重连
	self.m_bFirstOutCard_		= true
	self.m_wCurTurnWinner_ 		= DataCenter.INVALID_CHAIR
	self.m_cbPassCardInfo_		= {0, 0, 0, 0}	
	self.m_cbScoreCardData_ 	= {}
	self.m_cbScoreCardCount_ 	= 0
	self.m_bOutCallCard_ 		= false
	self.m_cbFaction_			= {}
	self.m_cbUserOrder_ 		= {}
	self.m_cbUserOrderNum_ 		= 0
	--游戏积分
	self.m_cbCurTurnScore_ 		= 0
	self.m_cbCurXiScore_		= 0
	self.m_cbCatchScore_		= {0, 0, 0, 0}
	self.m_nXiScore_			= {0, 0, 0, 0}
	self.m_nExtraScore_	 		= {0, 0, 0, 0}
	self.m_cbBaoCardInfo_		= {0, 0, 0, 0}
	--用户数据
	self.m_cbMyHandCardData_	= {}
	self.m_cbMyHandCardCount_	= MAX_COUNT				

	--操作相关
	self.m_bDealUserOperation_ 	= false
	self.m_wPrevOutCardUser_ 	= DataCenter.INVALID_CHAIR
	self.m_cbPrevOutCardCount_	= 0
	self.m_cbPrevOutCardData_	= {}
	self.m_wPrevOperationUser_	= DataCenter.INVALID_CHAIR
--[[
	系统消息数据
--]]
	self.m_bSysTrusteeshipTab_  = {false, false, false}
--[[
	结算相关
--]]
	self.m_bGameOver_ 			= false 												-- 是否游戏结束	
	self.m_cbGameResult_ 		= -1
	self.m_cbGameEndType_ 		= -1
	self.m_lGameScoreTab_		= {0, 0, 0}

	self.m_cbHandCardDataTab_	= {}
	self.m_cbHandCardCountTab_ 	= {MAX_COUNT, MAX_COUNT, MAX_COUNT, MAX_COUNT}
end

function DataCenter:Destroy()
	-- body
	self:RepositDataEx()
	self:ResetTotalData()
end

return DataCenter