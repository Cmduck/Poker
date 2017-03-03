
--------------------------------------------------------------------------
-- 资源目录
--------------------------------------------------------------------------

local ResCenter = class("ResCenter")
local GAME_ROOT_RES_PATH = "ccbResources/50kRes/"
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
	UIReady = {
		json  = GAME_ROOT_RES_PATH .. "ready/ready.json",
		plist = GAME_ROOT_RES_PATH .. "ready/ready.plist",
		png   = GAME_ROOT_RES_PATH .. "ready/ready.png",		
	},
	UIHou = {
		json  = GAME_ROOT_RES_PATH .. "hou/hou.json",
		plist = GAME_ROOT_RES_PATH .. "hou/hou.plist",
		png   = GAME_ROOT_RES_PATH .. "hou/hou.png",			
	},
	UIOutCard = {
		json  = GAME_ROOT_RES_PATH .. "out_card/out_card.json",
		plist = GAME_ROOT_RES_PATH .. "out_card/out_card.plist",
		png   = GAME_ROOT_RES_PATH .. "out_card/out_card.png",			
	},
	UITopInfo = {
		json  = GAME_ROOT_RES_PATH .. "top_info/top_info.json",
		plist = GAME_ROOT_RES_PATH .. "top_info/top_info.plist",
		png   = GAME_ROOT_RES_PATH .. "top_info/top_info.png",
	},
	UIOverCard = {
		json  = GAME_ROOT_RES_PATH .. "over_card/over_card.json",
		plist = GAME_ROOT_RES_PATH .. "over_card/over_card.plist",
		png   = GAME_ROOT_RES_PATH .. "over_card/over_card.png",		
	},
	UIClear = {
		json  = GAME_ROOT_RES_PATH .. "clear/clear.json",
		plist = GAME_ROOT_RES_PATH .. "clear/clear.plist",
		png   = GAME_ROOT_RES_PATH .. "clear/clear.png",
	},
	-- UICreateRoom = {
	-- 	json = "ccbResources/sparrowyhRes/create_room/create_room.json",
	-- 	plist = "ccbResources/sparrowyhRes/create_room/create_room.plist",
	-- 	png = "ccbResources/sparrowyhRes/create_room/create_room.png",
	-- },
	-- UIDismiss = {
	-- 	json = "ccbResources/sparrowyhRes/dismiss/dismiss.json",
	-- 	plist = "ccbResources/sparrowyhRes/dismiss/dismiss.plist",
	-- 	png = "ccbResources/sparrowyhRes/dismiss/dismiss.png",
	-- },
	-- UITotalClear = {
	-- 	json = "ccbResources/sparrowyhRes/total_clear/total_clear.json",
	-- 	plist = "ccbResources/sparrowyhRes/total_clear/total_clear.plist",
	-- 	png = "ccbResources/sparrowyhRes/total_clear/total_clear.png",
	-- },
	UICountDown = {
		json = GAME_ROOT_RES_PATH .. "count_down/count_down.json"
	},
	UITip = {

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
