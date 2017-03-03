local EventProxyEx = require("script.50kScript.common.EventProxyEx")
local CardClass = require("script.50kScript.card.CardClass")
local CardHelper = require("script.50kScript.card.CardHelper")
local CardView = class("CardView", function()
    return display.newNode()
end)

CardView.CLICK_CARD_EVENT = "CLICK_CARD_EVENT"


local CARD_WIDTH        = 124               --扑克宽度
local CARD_HEIGHT       = 176               --扑克高度
local CARD_CLICK_WIDTH  = 40                --扑克点击宽度

function CardView:ctor(cardData)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self.bTop_ = false   --是否上升
    self.cardClass_ = CardClass.new(cardData)

    EventProxyEx.new(self.cardClass_, self)
        :addEventListener(CardClass.CHANGE_CARD_DATA_EVENT, handler(self, self.onCardDataChange_))

    -- self:setTouchEnabled(true)
    -- self:setTouchSwallowEnabled(true)
    -- --注册触摸事件
    -- self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch_))

    --创建扑克图片
    self:createCardSprite(self.cardClass_)
end

function CardView:createCardSprite(CardClass)
    -- body
    local color = CardClass:getColor()
    local value = CardClass:getFaceValue()
    --print("CardView:createCardSprite:-> ~~~~~~~~~~~~~~~~~~~ color = " .. color)
    --print("CardView:createCardSprite:-> ~~~~~~~~~~~~~~~~~~~ actualValue = " .. actualValue)
    --扑克背景
    self.cardBg_ = display.newSprite("#card_" .. color .. "_" .. value .. ".png")
    self.cardBg_:addTo(self):align(display.CENTER, 0, 0)
end

function CardView:showCallCardMark()
    -- body
    local show_cards_data = DataCenter:getShowCardsData()
    local show_cards_num = #show_cards_data
    local game_type = DataCenter:getGameType()
    if game_type == 0 and show_cards_num ~= 0 and self.cardClass_:getHexData() == show_cards_data[show_cards_num] then
        local callMark = display.newSprite("#jiaopai_biaoji.png")
        :align(display.CENTER, 20, 20)  
        :addTo(self.cardBg_)
    end
end

function CardView:getCardBg()
    -- body
    return self.cardBg_
end

function CardView:getCardData()
    -- body
    return self.cardClass_:getHexData()
end

function CardView:SetClickedColor(bClicked)
    local color
    if bClicked then
        color = cc.c3b(119,136,153)
    else
        color = cc.c3b(255, 255, 255)
    end
    self.cardBg_:setColor(color)
end

function CardView:setBgOpacity(num)
    -- body
    self.cardBg_:setOpacity(num)
end

function CardView:onTouch_(event)
    -- body
    --print("CardView ------------------ > onTouch_")
    self.bTop_ = not self.bTop_
    self:dispatchEvent({name = CardView.CLICK_CARD_EVENT})
end

function CardView:isTop()
    -- body
    return self.bTop_
end

function CardView:resetCardView(data)
    -- body
    self.cardClass_:setCardData(data)
end

function CardView:onCardDataChange_(event)
    -- body
end

function CardView:updateView(event)
    -- body
    --更新视图
end

function CardView:isContainPoint( point, bLast)
    -- body
    local nsp = self.cardBg_:convertToNodeSpace(point)
    local rect

    rect = self.cardBg_:getBoundingBox()
    rect.width = bLast and CARD_WIDTH or CARD_CLICK_WIDTH
    --print("是否是最后一张牌:" .. tostring(bLast))
    rect.height = CARD_HEIGHT
    rect.x = 1
    rect.y = 0

    if cc.rectContainsPoint(rect, nsp) then
        return true
    end
    return false
end

return CardView
