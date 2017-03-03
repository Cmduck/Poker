--
-- Author: GFun
-- Date: 2017-02-09 16:53:07
--

local UIBase = require("script.50kScript.ui.UIBase")
local UIScrollMsg = class("UIScrollMsg", UIBase)

function UIScrollMsg:ctor()
    UIScrollMsg.super.ctor(self)
end

local SCROLL_BG_PATH = "ccbResources/50kRes/scroll_msg/tip_bg.png"
local SCROLL_LABA_PATH = "ccbResources/50kRes/scroll_msg/laba2.png"

function UIScrollMsg:onShow()
	-- body
    self.m_pImgTipBg = display.newSprite(SCROLL_BG_PATH)
    self.m_pImgTipLaba = display.newSprite(SCROLL_LABA_PATH)
    self.m_pImgTipLaba:setVisible(false)

    self.m_pImgTipBg:setPosition(display.cx, display.height - 170)
    self.m_pImgTipLaba:setPosition(display.cx - 390, display.height - 170)

    self:addChild(self.m_pImgTipBg)
    self:addChild(self.m_pImgTipLaba)

    self.m_pSysScroll = require("script.50kScript.ui.ScollMessage").create()

    self.m_pSysScroll:CreateLayout(self.m_pImgTipBg, self.m_pImgTipLaba, cc.p(270,10), cc.size(400,40))
end

function UIScrollMsg:onHide()
    -- body
end

function UIScrollMsg:onUpdate()

end

function UIScrollMsg:onRemove()
    -- body
    self:removeSelf()
end

function UIScrollMsg:InsertScollLabel(labelType,lableStr,fontSize,textColor,position)
    self.m_pSysScroll:InsertScollLabel(labelType,lableStr,fontSize,textColor,position)
end

function UIScrollMsg:ShowSysScroll(pszString)
    --创建文字
    if(nil==self.m_labelScroll)then

        self.m_labelScroll = display.newTTFLabel({
            text = pszString,
            font = "Arial",
            size = 40,
            color = cc.c3b(255, 255, 0),
            align = cc.TEXT_ALIGNMENT_CENTER,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
            dimensions = cc.size(880, 320)
        }):addTo(self)
    else
        self.m_labelScroll:setString(pszString);
    end

    --初始状态
    self.m_labelScroll:setPosition(display.cx, display.cy-200)
    self.m_labelScroll:setOpacity(0)
    self.m_labelScroll:setVisible(true);
    self.m_labelScroll:stopAllActions();

    --滚动结束
    function CUIScrollMsg:ScrollFinish()
        self.m_labelScroll:stopAllActions();
        self.m_labelScroll:setVisible(false);
    end

    --滚动动画
    local act = cca.seq({cca.fadeIn(1),cca.delay(0.5),cca.fadeOut(5)})
    local act2 = cca.seq({cca.moveBy(1, 0, 200),cca.delay(0.5),cca.moveBy(2.5, 0, 200),cca.callFunc(handler( self,self.ScrollFinish))})
    self.m_labelScroll:runAction(act)
    self.m_labelScroll:runAction(act2)
end
return UIScrollMsg