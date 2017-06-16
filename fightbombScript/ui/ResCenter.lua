
--------------------------------------------------------------------------
-- 资源目录
--------------------------------------------------------------------------

local ResCenter = class("ResCenter")
local GAME_ROOT_RES_PATH = "ccbResources/fightbombRes/"
local resTab = {
	UIBackground = {
		json  = GAME_ROOT_RES_PATH .. "background/background.json",
		plist = GAME_ROOT_RES_PATH .. "background/background.plist",
		png   = GAME_ROOT_RES_PATH .. "background/background.png",
	},
	UIIcon = {
		json  = GAME_ROOT_RES_PATH .. "icon/icon.json",
		plist = GAME_ROOT_RES_PATH .. "icon/icon.plist",
		png   = GAME_ROOT_RES_PATH .. "icon/icon.png",
	},
	UIBaoCard = {
		json  = GAME_ROOT_RES_PATH .. "bao_card/bao_card.json",
		plist = GAME_ROOT_RES_PATH .. "bao_card/bao_card.plist",
		png   = GAME_ROOT_RES_PATH .. "bao_card/bao_card.png",
	},
	UICallCard = {
		json  = GAME_ROOT_RES_PATH .. "call_card/call_card.json",
	},
	UIReady = {
		json  = GAME_ROOT_RES_PATH .. "ready/ready.json",
		plist = GAME_ROOT_RES_PATH .. "ready/ready.plist",
		png   = GAME_ROOT_RES_PATH .. "ready/ready.png",		
	},
	UIOutCard = {
		json  = GAME_ROOT_RES_PATH .. "out_card/out_card.json",
		plist = GAME_ROOT_RES_PATH .. "out_card/out_card.plist",
		png   = GAME_ROOT_RES_PATH .. "out_card/out_card.png",			
	},
	UIOverCard = {
		json  = GAME_ROOT_RES_PATH .. "over_card/over_card.json",
		plist = GAME_ROOT_RES_PATH .. "over_card/over_card.plist",
		png   = GAME_ROOT_RES_PATH .. "over_card/over_card.png",		
	},
	UITopInfo = {
		json  = GAME_ROOT_RES_PATH .. "top_info/top_info.json",
		plist = GAME_ROOT_RES_PATH .. "top_info/top_info.plist",
		png   = GAME_ROOT_RES_PATH .. "top_info/top_info.png",
	},
	UIClear = {
		json  = GAME_ROOT_RES_PATH .. "clear/clear.json",
		plist = GAME_ROOT_RES_PATH .. "clear/clear.plist",
		png   = GAME_ROOT_RES_PATH .. "clear/clear.png",
		zorder = 3
	},
	UICreateRoom = {
		json  = GAME_ROOT_RES_PATH .. "create_room/create_room.json",
		plist = GAME_ROOT_RES_PATH .. "create_room/create_room.plist",
		png   = GAME_ROOT_RES_PATH .. "create_room/create_room.png",
		zorder = 2
	},
	UIDismiss = {
		json  = GAME_ROOT_RES_PATH .. "dismiss/dismiss.json",
		plist = GAME_ROOT_RES_PATH .. "dismiss/dismiss.plist",
		png   = GAME_ROOT_RES_PATH .. "dismiss/dismiss.png",
	},
	UITotalClear = {
		json  = GAME_ROOT_RES_PATH .. "total_clear/total_clear.json",
		plist = GAME_ROOT_RES_PATH .. "total_clear/total_clear.plist",
		png   = GAME_ROOT_RES_PATH .. "total_clear/total_clear.png",
		zorder = 4
	},
	UICountDown = {
		json = GAME_ROOT_RES_PATH .. "count_down/count_down.json"
	},
	UITip = {

	},
	UIMsgBox = {
		json  = GAME_ROOT_RES_PATH .. "msg_box/msg_box.json",
		plist = GAME_ROOT_RES_PATH .. "msg_box/msg_box.plist",
		png   = GAME_ROOT_RES_PATH .. "msg_box/msg_box.png",
	},
	UIChat = {

	},
	UIScrollMsg = {

	},
	UIMusicChat = {

	},
	UIChatBubble = {
		json = GAME_ROOT_RES_PATH .. "chat_bubble/chat_bubble.json"	
	},
	UITrusteeship = {
		json = GAME_ROOT_RES_PATH .. "trusteeship/trusteeship.json"
	},
	UIScoreCard = {
		zorder = 2
	},
}

function ResCenter:ctor()
	-- body
end

function ResCenter:getUIConfig(classname)
	-- body
	return resTab[classname]
end

function ResCenter:getGameRootResPath()
	return GAME_ROOT_RES_PATH
end

return ResCenter
