

local UIRegistry = class("UIRegistry")

local UIRegistryNameTab = {
	"UIBackground",
	"UIIcon",
	"UIReady",
	"UIHou",
	"UIOutCard",
	"UITopInfo",
	"UIOverCard",
	"UIClear",
	-- "UIClearZhuang",
	-- "UIClearBao",
	-- "UICreateRoom",
	-- "UIDismiss",
	-- "UITotalClear",
	"UICountDown",
	"UITip",
	"UIChat",
	"UIScrollMsg",
	"UIMusicChat",
	"UIChatBubble",
	"UITrusteeship"
}

local UI_PATH = "script.50kScript.ui."
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