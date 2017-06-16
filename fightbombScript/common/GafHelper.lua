--
-- Author: GFun
-- Date: 2017-06-12 17:00:52
--

local GafConfig = {
	_510K = {
		path = "ccbResources/fightbombRes/animation/510k/510k.gaf",
		tag = 1001,
	},

	_BaoPai = {
		path = "ccbResources/fightbombRes/animation/baopai/baopai.gaf",
		tag = 1002,
	},

	_JinBi = {
		path = "ccbResources/fightbombRes/animation/jinbi/jinbi.gaf",
		tag = 1003,		
	},

	_ShengYu = {
		path = "ccbResources/fightbombRes/animation/shengyu/shengyu.gaf",
		tag = 1004,		
	},

	_ShouQian = {
		path = "ccbResources/fightbombRes/animation/shouqian/shouqian.gaf",
		tag = 1005,		
	},

	_WangZha = {
		path = "ccbResources/fightbombRes/animation/wangzha/wangzha.gaf",
		tag = 1006,	
	},

	_ZhaDan = {
		path = "ccbResources/fightbombRes/animation/zhadan/zhadan.gaf",
		tag = 1007,			
	},

	_ZhuaFen = {
		path = "ccbResources/fightbombRes/animation/zhaufen/zhaufen.gaf",
		tag = 1008,	
	},

	_LianDui = {
		path = "ccbResources/fightbombRes/animation/liandui/liandui.gaf",
		tag = 1009,	
	},

	_Plane = {
		path = {
			[eDown] = "ccbResources/fightbombRes/animation/feijixia/feijixia.gaf",
			[eRight] = "ccbResources/fightbombRes/animation/feijiyou/feijiyou.gaf",
			[eUp] = "ccbResources/fightbombRes/animation/feijishang/feijishang.gaf",
			[eLeft] = "ccbResources/fightbombRes/animation/feijizuo/feijizuo.gaf",
		},
		tag = 1010,	
	},
}


local GafHelper = class("GafHelper")

function GafHelper:ctor()

end

function GafHelper:PlayGaf(parentNode, name, pos)
	if not parentNode:getChildByTag(GafConfig[name].tag) then
		local FlashSprite = require("script.public.FlashSprite")
		local bomb_node = FlashSprite.new(GafConfig[name].path)
		bomb_node:setTag(GafConfig[name].tag)
		bomb_node:addTo(parentNode)
	end
	local node = parentNode:getChildByTag(GafConfig[name].tag)
	node:setVisible(true)
	node:setPos(pos.x, pos.y)
	node:start()
	node:setAnimationFinishedPlayDelegate(function()
		-- body
		node:stop()
		node:setVisible(false)
	end)
	--dump(node)
end

function GafHelper:PlayGafWithDirection(parentNode, name, pos, direction)
	if parentNode:getChildByTag(GafConfig[name].tag) then
		parentNode:removeChildByTag(GafConfig[name].tag, true)
	end

	local FlashSprite = require("script.public.FlashSprite")
	local animate_node = FlashSprite.new(GafConfig[name].path[direction])
	animate_node:setTag(GafConfig[name].tag)
	animate_node:addTo(parentNode)

	animate_node:setVisible(true)
	animate_node:setPos(pos.x, pos.y)
	animate_node:start()
	animate_node:setAnimationFinishedPlayDelegate(function()
		-- body
		animate_node:stop()
		animate_node:setVisible(false)
	end)
end

return GafHelper