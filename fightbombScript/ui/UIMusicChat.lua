--
-- Author: GFun
-- Date: 2016-11-17 10:10:09
--
local UIBase = require("script.fightbombScript.ui.UIBase")
local UIMusicChat = class("UIMusicChat", UIBase)

function UIMusicChat:ctor()
    UIMusicChat.super.ctor(self)
end

function UIMusicChat:onShow()
	-- body
    --聊天控件
    local ChatClass=require "script.fightbombScript.ui.MusicChat" 

    self.ChatObject=ChatClass.new("ccbResources/fightbombRes/sound")
    self.ChatObject:setPosition(display.cx, display.cy)
    self:addChild(self.ChatObject)
    self.ChatObject:setVisible(false)
end

function UIMusicChat:onHide()
    -- body
end

function UIMusicChat:onUpdate()

	self.ChatObject:setVisible(not self.ChatObject:isVisible())
end

function UIMusicChat:onRemove()
    -- body
    self:removeSelf()
end

function UIMusicChat:playSound(voiceID ,isMan)
    return self.ChatObject:playSound(voiceID ,isMan)
end

function UIMusicChat:GetContentById(voiceID)
    return self.ChatObject:GetContentById(voiceID)
end

return UIMusicChat