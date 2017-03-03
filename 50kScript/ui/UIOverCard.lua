--
-- Author: GFun
-- Date: 2016-10-14 17:14:30
--

local UIBase = require("script.50kScript.ui.UIBase")
local UIOverCard = class("UIOverCard", UIBase)


function UIOverCard:ctor()
    UIOverCard.super.ctor(self)  
end

function UIOverCard:onShow()
	-- body
	local orderTab = DataCenter:getOverCardUserOrder()
	local nodeNameTab = {"over_card_down", "over_card_right", "over_card_up", "over_card_left"}

	for i, v in ipairs(nodeNameTab) do
		--加载节点
		self[v] = cc.uiloader:seekNodeByName(self.UINode_, v)
	end
	--test
	--[[
	for i, v in ipairs(orderTab) do
		local direction = GetDirection(v) + 1
		local node_name = nodeNameTab[direction]
		local img_name = "#over_card_" .. i .. ".png"
		local sprite = display.newSprite(img_name)
		sprite:addTo(self[node_name])
	end
	--]]
end 

function UIOverCard:onHide()
    -- body
end

function UIOverCard:onUpdate()
	local orderTab = DataCenter:getOverCardUserOrder()
	local orderCount = DataCenter:getOverCardCount()
	--dump(orderTab)
	local nodeNameTab = {"over_card_down", "over_card_right", "over_card_up", "over_card_left"}

	for i = 1, orderCount do
		local direction = GetDirection(orderTab[i]) + 1
		local node_name = nodeNameTab[direction]
		local img_name = "#over_card_" .. i .. ".png"
		local sprite = display.newSprite(img_name)
		self[node_name]:removeAllChildren()
		sprite:addTo(self[node_name])
	end

	-- for i, v in ipairs(orderTab) do
	-- 	local direction = GetDirection(v) + 1
	-- 	local node_name = nodeNameTab[direction]
	-- 	local img_name = "#over_card_" .. i .. ".png"
	-- 	local sprite = display.newSprite(img_name)
	-- 	self[node_name]:removeAllChildren()
	-- 	sprite:addTo(self[node_name])
	-- end
end

function UIOverCard:onRemove()
    -- body
    self:removeSelf()
end



return UIOverCard