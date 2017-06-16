--
-- Author: GFun
-- Date: 2016-11-17 10:26:37
--
local UIBase = require("script.fightbombScript.ui.UIBase")
local UIChatBubble = class("UIChatBubble", UIBase)

function UIChatBubble:ctor()
    UIChatBubble.super.ctor(self)
end

function UIChatBubble:onShow()
	-- body
    --聊天气泡控件
    self.m_tblBubble = {}

    self.m_tblBubble[eUp] = cc.uiloader:seekNodeByName(self.UINode_, "node_up")
    self.m_tblBubble[eUp]:setVisible(false)
    self.m_tblBubble[eDown] = cc.uiloader:seekNodeByName(self.UINode_, "node_down")
    self.m_tblBubble[eDown]:setVisible(false)
    self.m_tblBubble[eLeft] = cc.uiloader:seekNodeByName(self.UINode_, "node_left")
    self.m_tblBubble[eLeft]:setVisible(false)
    self.m_tblBubble[eRight] = cc.uiloader:seekNodeByName(self.UINode_, "node_right")
    self.m_tblBubble[eRight]:setVisible(false)
    self.m_tblIsShow = {}
    for i = 0, eDirectionMax - 1 do
        self.m_tblIsShow[i] = false
    end
end

function UIChatBubble:onHide()
    -- body
    self:setVisible(false)
end

function UIChatBubble:onUpdate()

end

function UIChatBubble:onRemove()
    -- body
    self:removeSelf()
end

-- 设置显示
function UIChatBubble:SetShow(eDirection, strChat)
    if self.m_tblIsShow[eDirection] == true then
    	if self.prevUser == eDirection then
    		self.m_tblBubble[eDirection]:stopAllActions()
    	end
    end

    self.m_tblBubble[eDirection]:setVisible(true)
    cc.uiloader:seekNodeByName(self.m_tblBubble[eDirection], "text_bubble"):setString(strChat)

    local pAction1 = cc.DelayTime:create(5)
    local pAction2 = cc.Hide:create()
    local pAction3 = cc.CallFunc:create(
        function()
            self.m_tblBubble[eDirection]:setVisible(false)
        end
        )
    self.m_tblBubble[eDirection]:runAction(cc.Sequence:create(pAction1, pAction2, pAction3))
end

-- 显示完成回调
function UIChatBubble:CBShowFinish(eDirection)

    self.m_tblIsShow[eDirection] = false

    local bHaveShow = false

    for i = 0, eDirectionMax - 1 do
        if self.m_tblIsShow[i] == true then
            bHaveShow = true
            break
        end
    end

    if bHaveShow ~= true then
    	self:onHide()
    end
end

return UIChatBubble