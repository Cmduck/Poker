--
-- Author: GFun
-- Date: 2016-12-09 17:41:07
--

local GAME_MSG_PATH   = "script.50kScript.data.MsgData."
local SCENE_MSG_PATH  = "script.50kScript.data.SceneData."
local SYSTEM_MSG_PATH = "script.50kScript.data.SystemData."

local GameMsgRegistry = {
	[SUB_S_GAME_START] 		= "MsgGameStartData",
	[SUB_S_PASS_CARD] 		= "MsgPassCardData",
	[SUB_S_GAME_END] 		= "MsgGameEndData",
	[SUB_S_HOUSTATE_CARD] 	= "MsgHouStateData",
	[SUB_S_HOU_CARD_END]	= "MsgHouCardEndData",
	[SUB_S_CALL_CARD]		= "MsgCallCardData",
	[SUB_S_OUT_CARD_START]	= "MsgOutCardStartData",
	[SUB_S_OUT_CARD_END] 	= "MsgOutCardEndData",
	[SUB_S_CUR_TURN_OVER]	= "MsgCurTurnOverData",
	[SUB_S_OVER_CARD]		= "MsgOverCardData",
}

local SceneMsgRegistry = {
	[GS_UG_FREE] 			= "SceneFreeData",
	[GS_UG_HOU]				= "SceneHouData",
	[GS_UG_PLAYING] 		= "ScenePlayData",
	[GS_UG_CONTINUE] 		= "SceneContinueData",
}

local SystemMsgRegistry = {
	[G_USER_TRUSTEESHIP] = "SystemTrusteeshipData",
}

local DataStruct = class("DataStruct")

function DataStruct:ctor()

end

function DataStruct:initSceneStructData(data, data_center)
	--eg. data[1] = GS_UG_FREE
	local gameStatusID = data[1]
	--print("场景协议ID：".. gameStatusID)
	local class_path = SCENE_MSG_PATH .. SceneMsgRegistry[gameStatusID]
	--print("协议类路径:" .. class_path)
	local scene_data_class = require(SCENE_MSG_PATH .. SceneMsgRegistry[gameStatusID]).new()
	scene_data_class:ProcessMsg(data, data_center)
end

function DataStruct:initGameMsgData(data, data_center)
	--eg. data[1] = SUB_S_GAME_START
	local protocolID = data[1]
	--print("消息协议ID: " .. protocolID)
	local class_path = GAME_MSG_PATH .. GameMsgRegistry[protocolID]
	--print("协议类路径:" .. class_path)
	local msg_data_class = require(class_path).new()
	msg_data_class:ProcessMsg(data, data_center)
end

function DataStruct:initSystemMsgData(systemID, data, data_center)
	local class_path = SYSTEM_MSG_PATH .. SystemMsgRegistry[systemID]
	--print("协议类路径:" .. class_path)
	local msg_data_class = require(class_path).new()
	msg_data_class:ProcessMsg(data, data_center)
end

return DataStruct