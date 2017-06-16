local EventProxyEx = require("script.fightbombScript.common.EventProxyEx")
local CardClass = require("script.fightbombScript.card.CardClass")
local CardHelper = require("script.fightbombScript.card.CardHelper")
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
    self.bPick_ = false
    self.cardClass_ = CardClass.new(cardData)

    EventProxyEx.new(self.cardClass_, self)
        :addEventListener(CardClass.CHANGE_CARD_DATA_EVENT, handler(self, self.updateView))

    -- self:setTouchEnabled(true)
    -- self:setTouchSwallowEnabled(true)
    -- --注册触摸事件
    -- self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch_))

    --创建扑克图片
    self:createCardSprite(self.cardClass_)
end

function CardView:createCardSprite(CardClass)
    -- body
    local color = CardClass:getCardColor()
    local value = CardClass:getCardValue()

    --整图
    self.cardBg_ = display.newSprite("#card_" .. color .. "_" .. value .. ".png")
    self.cardBg_:addTo(self):align(display.CENTER, 0, 0)
    --扑克背景
    --[[自己拼图
    self.cardBg_ = display.newSprite("#bottom.png")
    self.cardBg_:addTo(self):align(display.CENTER, 0, 0)
    if value < 11 then
        local value_name = string.format("#%d_%d.png", color % 2, value)
        local valueSprite = display.newSprite(value_name):align(display.CENTER, 25, 145):addTo(self.cardBg_)
        local small_color_name = string.format("#small_%d.png", color)
        local smallColorSprite = display.newSprite(small_color_name):align(display.CENTER, 25, 95):addTo(self.cardBg_)
    elseif value >= 11 and value <= 13 then
        local value_name = string.format("#%d_%d.png", color % 2, value)
        local valueSprite = display.newSprite(value_name):align(display.CENTER, 25, 145):addTo(self.cardBg_)
        local small_color_name = string.format("#small_%d.png", color)
        local smallColorSprite = display.newSprite(small_color_name):align(display.CENTER, 25, 95):addTo(self.cardBg_)
        local big_color_name = string.format("#big_%d_%d.png", color, value)
        local height = 0
        if value == 11 then height = 80 end
        if value == 12 then height = 76 end
        if value == 13 then height = 77 end
        local bigColorSprite = display.newSprite(big_color_name):align(display.CENTER, 68, height):addTo(self.cardBg_)
    else
        local value_name = string.format("#4_%d.png", value)
        local valueSprite = display.newSprite(value_name):align(display.CENTER, 20, 100):addTo(self.cardBg_)
        local big_color_name = string.format("#big_%d_%d.png", color, value)
        local bigColorSprite = display.newSprite(big_color_name):align(display.CENTER, 85, 50):addTo(self.cardBg_)
    end
    --]]
end

function CardView:showCallCardMark()
    -- body
    local show_cards_data = DataCenter:getShowCardsData()
    local show_cards_num = #show_cards_data
    local game_type = DataCenter:getGameType()
    if game_type == 0 and show_cards_num ~= 0 and self.cardClass_:getCardData() == show_cards_data[show_cards_num] then
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
    return self.cardClass_:getCardData()
end

function CardView:SetClickedColor(bClicked)
    local color
    if bClicked then
        color = cc.c3b(119,136,153)
    else
        color = cc.c3b(255, 255, 255)
    end
    self.cardBg_:setColor(color)
    self.bPick_ = true
end

function CardView:getIsPick()
    return self.bPick_
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

function CardView:updateView(event)
    -- body
    --更新视图
    if self.cardBg_ then
        self.cardBg_:removeSelf()
    end

    self:createCardSprite(self.cardClass_)
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

function CardView:isContainPointMove(beginPoint, endPoint, bLast)
    -- body
    local nspBegin = self.cardBg_:convertToNodeSpace(beginPoint)
    local nspEnd   = self.cardBg_:convertToNodeSpace(endPoint)

    local rect

    rect = self.cardBg_:getBoundingBox()
    rect.width = bLast and CARD_WIDTH or CARD_CLICK_WIDTH
    --print("是否是最后一张牌:" .. tostring(bLast))
    rect.height = CARD_HEIGHT
    rect.x = 1
    rect.y = 0
    if beginPoint.x >= endPoint.x then   --点击移动 从右向左
        if (nspBegin.y >= rect.y) and (nspBegin.y <= rect.y + rect.height) and 
            (nspEnd.y >= rect.y) and (nspEnd.y <= rect.y + rect.height) and 
            nspBegin.x >= rect.x and nspEnd.x < rect.x + rect.width then
            return true
        end
    else
        if (nspBegin.y >= rect.y) and (nspBegin.y <= rect.y + rect.height) and 
            (nspEnd.y >= rect.y) and (nspEnd.y <= rect.y + rect.height) and 
            nspBegin.x < rect.x + rect.width and nspEnd.x > rect.x then
            return true
        end
    end

    return false
end

return CardView
