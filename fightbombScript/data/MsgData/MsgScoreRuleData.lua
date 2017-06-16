--
-- Author: GFun
-- Date: 2017-03-10 17:50:53
--
local BaseData = require("script.fightbombScript.data.BaseData")
local MsgScoreRuleData = class("MsgScoreRuleData", BaseData)

local MsgScoreRuleDataStruct = {
	{m_cbMaxInningNum_        = 0},
	{m_cbCurInningNum_        = 0},
	{m_b1V3_		      	  = false},
	{m_bThreePlusTwo_		  = false},
	{m_dwTableUser_           = -1},
	{m_dwTableUserID_         = -1},
	{m_dwRandID_              = 0},
}

function MsgScoreRuleData:ctor()
	MsgScoreRuleData.super.ctor(self)

	self:SetDataType(self.class.MSG_DATA_TYPE)
	self:SetDataStructParams(MsgScoreRuleDataStruct)
end

function MsgScoreRuleData:ExtendData(data_center)
	data_center.m_bCreateTable_ = true
end

function MsgScoreRuleData:DispatchEvent(data_center)
	--print("------------------------------MsgScoreRuleData:DispatchEvent------------------------")
	data_center:dispatchEvent({name = data_center.MSG_SCORE_RULE_EVENT})
end

return MsgScoreRuleData