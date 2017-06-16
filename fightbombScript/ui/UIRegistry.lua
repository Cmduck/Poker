

local UIRegistry = class("UIRegistry")

local UIRegistryNameTab = {
	"UIBackground",
	"UIIcon",
	"UIReady",
	"UIBaoCard",
	"UICallCard",
	"UIOutCard",
	"UIOverCard",
	"UITopInfo",
	"UIClear",
	"UICreateRoom",
	"UIDismiss",
	"UITotalClear",
	"UICountDown",
	"UITip",
	"UIMsgBox",
	"UIChat",
	"UIScrollMsg",
	"UIMusicChat",
	"UIChatBubble",
	"UITrusteeship",
	"UIScoreCard"
}

local UI_PATH = "script.fightbombScript.ui."
function UIRegistry:ctor()
	-- body
	self.UIRegistryClassTab_ = {}
end

function UIRegistry:RegisterUI(uiname)
	-- body
	self.UIRegistryClassTab_[uiname] = require(UI_PATH .. uiname)
end

function UIRegistry:RegisterAllUI()
	-- body
	for _, name in ipairs(UIRegistryNameTab) do
		self.UIRegistryClassTab_[name] = require(UI_PATH .. name)
	end
end

function UIRegistry:getUIClassTab(uiname)
	-- body
	if not self.UIRegistryClassTab_[uiname] then
		error("Please check UIRegistryNameTab!!! The " .. "【" .. uiname .. "】")
	end
	return self.UIRegistryClassTab_[uiname]
end

return UIRegistry