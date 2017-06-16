--
-- Author: GFun
-- Date: 2017-02-09 17:57:22
--

--动作标识
local ActionTag = {
	YaoBuQi = 100,
	ErrorType = 101,
	CallCardError = 102,
	HandShake = 103,
}

local ActionHelper = class("ActionHelper")

function ActionHelper:ctor()

end

----出牌动作  渐入缩放
--@param
--@return
function ActionHelper:OutCardAction(parentNode, endScale)
	local endScale = endScale or 1
    parentNode:runAction(cc.FadeOut:create(0))
    parentNode:setScale(endScale * 1.5)
    local fadeInAction = cc.FadeIn:create(0.1)
    local scaleAction = cc.ScaleTo:create(0.1,0.9 * endScale)
    parentNode:runAction(cc.Sequence:create(cc.Spawn:create(fadeInAction,scaleAction),cc.ScaleTo:create(0.05,1 * endScale)))
end

--播放警报器 所播放界面须先加载plist文件
function ActionHelper:ShowWarn(parentNode, pos)
	-- body
	local node = display.newNode()
	node:addTo(parentNode):align(display.CENTER, pos.x, pos.y)
	local light = display.newSprite("ccbResources/fightbombRes/animation/jingbaoq.png")
	light:addTo(node):align(display.CENTER, 0, 0)
	local sp = display.newSprite("#light_00.png", 0, 0)
	sp:addTo(node):align(display.CENTER, 0, 0)
	local frames = display.newFrames("light_%02d.png", 0, 11)
	local animation = display.newAnimation(frames, 0.05)
	sp:playAnimationForever(animation)
end

--显示要不起提示
function ActionHelper:ShowYaoBuQiTips(parentNode, pos)
	-- body
	parentNode:removeChildByTag(ActionTag["YaoBuQi"], true)

	local animate_node = display.newSprite("ccbResources/fightbombRes/out_card/yaobuqi.png")
	animate_node:addTo(parentNode):align(display.CENTER, pos.x, pos.y)
	animate_node:setTag(ActionTag["YaoBuQi"])	
	animate_node:setOpacity(255)

	local sequence = transition.sequence({
		--cc.FadeIn:create(0.2),
		cc.DelayTime:create(0.5),
		cc.FadeOut:create(1),
		-- cc.CallFunc:create(function()
  --       	self.bInYaoBuQiAni_ = false
		-- end)		
		})
	animate_node:runAction(sequence)
end

function ActionHelper:ShowErrorTypeTips(parentNode, pos)
	-- body
	parentNode:removeChildByTag(ActionTag["ErrorType"], true)

	local animate_node = display.newSprite("ccbResources/fightbombRes/out_card/error_type_tips.png")
	animate_node:addTo(parentNode):align(display.CENTER, pos.x, pos.y)
	animate_node:setTag(ActionTag["ErrorType"])	
	animate_node:setOpacity(255)

	local sequence = transition.sequence({
		--cc.FadeIn:create(0.2),
		cc.DelayTime:create(0.5),
		cc.FadeOut:create(1),
		-- cc.CallFunc:create(function()
  --       	self.bInYaoBuQiAni_ = false
		-- end)		
		})
	animate_node:runAction(sequence)
end

function ActionHelper:ShowCallCardErrorTips(parentNode, pos)
	-- body
	parentNode:removeChildByTag(ActionTag["CallCardError"], true)

	local animate_node = display.newSprite("ccbResources/fightbombRes/out_card/call_card_error.png")
	animate_node:addTo(parentNode):align(display.CENTER, pos.x, pos.y)
	animate_node:setTag(ActionTag["CallCardError"])	
	animate_node:setOpacity(255)

	local sequence = transition.sequence({
		--cc.FadeIn:create(0.2),
		cc.DelayTime:create(0.5),
		cc.FadeOut:create(1),
		-- cc.CallFunc:create(function()
  --       	self.bInYaoBuQiAni_ = false
		-- end)		
		})
	animate_node:runAction(sequence)
end

function ActionHelper:ShowHandShake(parentNode, pos)
	-- body
	parentNode:removeChildByTag(ActionTag["HandShake"], true)

	local animate_node = display.newNode()
	animate_node:addTo(parentNode):align(display.CENTER, pos.x, pos.y)
	animate_node:setTag(ActionTag["HandShake"])

	local sp = display.newSprite("#handshake_01.png", 0, 0)
	sp:addTo(animate_node)
	local frames = display.newFrames("handshake_%02d.png", 1, 3)
	local animation = display.newAnimation(frames, 0.2)
	--sp:playAnimationForever(animation)
	sp:playAnimationOnce(animation, false, function ()
		-- body
		local sequence = transition.sequence({
		    cc.MoveTo:create(0.2, cc.p(display.cx, pos.y + 20)),
		    cc.MoveTo:create(0.2, cc.p(display.cx, pos.y- 20)),
		    cc.DelayTime:create(0.3),
			cc.CallFunc:create(function()
            	sp:removeSelf()
    		end)
		})

		animate_node:runAction(sequence)
	end)
end

return ActionHelper 