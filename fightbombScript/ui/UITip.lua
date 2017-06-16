--
-- Author: GFun
-- Date: 2016-10-31 09:57:40
--

local UIBase = require("script.fightbombScript.ui.UIBase")
local UITip = class("UITip", UIBase)

function UITip:ctor()
    UITip.super.ctor(self)
end

function UITip:onShow()
	-- body
    self.m_pTipUI = require("script.plaza.tip_ui")

    self.m_pCBFun = nil
end

function UITip:onHide()
    -- body
end

function UITip:onUpdate()

end

function UITip:onRemove()
    -- body
    self:removeSelf()
end

function UITip:ShowTip(strPrompt, pCBFun)
    self.m_pCBFun = pCBFun
    self.m_pTipUI.PopupTipUI(strPrompt, 1, 
        function(__, bOK)
        self:setVisible(false)
        if self.m_pCBFun then
            self.m_pCBFun(bOK)
        end
    end)
end

return UITip