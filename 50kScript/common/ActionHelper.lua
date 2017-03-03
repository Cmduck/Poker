--
-- Author: GFun
-- Date: 2017-02-09 17:57:22
--

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

return ActionHelper