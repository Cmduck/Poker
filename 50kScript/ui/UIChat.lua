--
-- Author: GFun
-- Date: 2016-10-31 09:47:24
--

local UIBase = require("script.50kScript.ui.UIBase")
local UIChat = class("UIChat", UIBase)

function UIChat:ctor()
    UIChat.super.ctor(self)
end

function UIChat:onShow()
	-- body
    --聊天控件
    local GameChat = import("script.public.GameChat")  

    self.m_ChatFrame = GameChat:create(handler(self, self.OnChatFuc), handler(self, self.SendChatMsg) ,true)
    self:addChild(self.m_ChatFrame, 100, 100)
    self.m_ChatFrame:ShowWin(true)

    --喇叭接口
    self.m_ChatFrame:SetLabaSend(handler(self, self.SendBugleMeg))
end

function UIChat:onHide()
    -- body
end

function UIChat:onUpdate()

end

function UIChat:onRemove()
    -- body
    self:removeSelf()
end

function UIChat:OnChatFuc()
    -- --显示判断
    -- self.m_ChatFrame:ShowWin(not self.m_ChatFrame:isVisible())

    -- if self.m_ChatFrame:isVisible() == false then
    --     CUIManager:getInstance():HideUI(UIID_CHAT)
    -- end
    self:setVisible(false)
end

function UIChat:SendChatMsg()
    --发送信息
    local Str = FGameDC:getDC():SendChatMessage(0, self.m_ChatFrame:getSendChat(), 0)
        
    --聊天
    if(Str~="")then
        -- CUIManager:getInstance():ShowUI(UIID_TIP)
        -- CUIManager:getInstance():GetUI(UIID_TIP):ShowTip(Str, nil)
        UIManager:ShowUI("UITip"):ShowTip(Str, nil)
    end
end

--发送喇叭
function UIChat:SendBugleMeg()      
    --发送信息
    local Str=FGameDC:getDC():SendBugleMessage(self.m_ChatFrame:getSendChat());
        
    --聊天
    if(Str~="")then
        -- CUIManager:getInstance():ShowUI(UIID_TIP)
        -- CUIManager:getInstance():GetUI(UIID_TIP):ShowTip(Str, nil)
        UIManager:ShowUI("UITip"):ShowTip(Str, nil)
    end
end

function UIChat:AddChat(str, rgb)
    self.m_ChatFrame:addChat(str, rgb)   -- 喇叭信息
end

function UIChat:AddRichChat(tb, rgb)
    self.m_ChatFrame:addRichChat(tb, rgb)   -- 喇叭信息
end

return UIChat