--
-- Author: GFun
-- Date: 2017-05-05 15:02:42
--
local UIBase = require("script.fightbombScript.ui.UIBase")
local CardHelper = require("script.fightbombScript.card.CardHelper")
local CardView = require("script.fightbombScript.card.CardView")
local UIScoreCard = class("UIScoreCard", UIBase)

local NUM_PATH = "ccbResources/fightbombRes/score_card/shengyufen_shuzi.png"

function UIScoreCard:ctor()
	self.maskLayer_ = display.newColorLayer(ccc4(0, 0, 0, 150))--ccc4
	self.maskLayer_:addTo(self)
    self.maskLayer_:setTouchEnabled(true)
    self.maskLayer_:setTouchSwallowEnabled(true)
    --注册触摸事件
    self.maskLayer_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch_))
    UIScoreCard.super.ctor(self)
end

function UIScoreCard:onShow()
	-- body
	local img_remain_score = display.newSprite("ccbResources/fightbombRes/score_card/shengyufen.png")
	img_remain_score:align(display.CENTER, display.cx, display.cy + 250):addTo(self)

	local card_tab = {
		[0] = {0x05, 0x05, 0x0A, 0x0A, 0x0D, 0x0D},
		[1] = {0x15, 0x15, 0x1A, 0x1A, 0x1D, 0x1D},
		[2] = {0x25, 0x25, 0x2A, 0x2A, 0x2D, 0x2D},
		[3] = {0x35, 0x35, 0x3A, 0x3A, 0x3D, 0x3D},
	}

	self.m_viewList_ = {}
	for i = 0, 3 do
		self.m_viewList_[i] = {}
		for j = 1, 6 do
			self.m_viewList_[i][j] = CardView.new(card_tab[i][j])
			if i == 0 then
				self.m_viewList_[i][j]:align(display.CENTER, display.cx - 300 + (j - 1) * 45, display.cy + 120):addTo(self)
			elseif i == 1 then
				self.m_viewList_[i][j]:align(display.CENTER, display.cx + 85 + (j - 1) * 45, display.cy + 120):addTo(self)
			elseif i == 2 then
				self.m_viewList_[i][j]:align(display.CENTER, display.cx - 300 + (j - 1) * 45, display.cy - 120):addTo(self)
			else
				self.m_viewList_[i][j]:align(display.CENTER, display.cx + 85 + (j - 1) * 45, display.cy - 120):addTo(self)
			end
		end
	end
	--dump(self.m_viewList_)
	self:onUpdate()
end

function UIScoreCard:onHide()
    -- body
    self:setVisible(false)
end

function UIScoreCard:onUpdate()
	local remain_score = 200

	local score_card_data = DataCenter:getScoreCardData()
	local score_card_count = DataCenter:getScoreCardCount()

	for i = 1, score_card_count do
		local color = CardHelper:getCardColor(score_card_data[i])
		if CardHelper:getCardValue(score_card_data[i]) == 0x0D then
			remain_score = remain_score - 10
		elseif CardHelper:getCardValue(score_card_data[i]) == 0x0A then
			remain_score = remain_score - 10
		else
			remain_score = remain_score - 5
		end

		for j = 1, 6 do
			local card_view = self.m_viewList_[color][j]
			if card_view:getCardData() ==  score_card_data[i] and not card_view:getIsPick() then
				self.m_viewList_[color][j]:SetClickedColor(true)
				break
			end
		end
	end

	local label_options = {stringValue = tostring(remain_score), path = NUM_PATH, itemWidth = 57, itemHeight = 76, startCharMap = '0'}
	local score_num = self:createLabelAtlas(label_options)
	score_num:align(display.CENTER, display.cx + 80, display.cy + 250):addTo(self)
end

function UIScoreCard:onRemove()
    -- body
    self:removeSelf()
end
--local t = {stringValue = prevChar .. tostring(math.abs(iScore)), path = num_path, itemWidth = 73, itemHeight = 90, startCharMap = '/'}

function UIScoreCard:createLabelAtlas(options)
	local labelAtlas
	if "function" == type(cc.LabelAtlas._create) then
		labelAtlas = cc.LabelAtlas:_create()
		labelAtlas:initWithString(options.stringValue,
			options.path,
			options.itemWidth,
			options.itemHeight,
			string.byte(options.startCharMap))
	else
		labelAtlas = cc.LabelAtlas:create(
			options.stringValue,
			options.path,
			options.itemWidth,
			options.itemHeight,
			string.byte(options.startCharMap))
	end

	labelAtlas:setAnchorPoint(
		cc.p(options.anchorPointX or 0.5, options.anchorPointY or 0.5))
	-- labelAtlas:setPosition(options.x, options.y)
	-- if not options.ignoreSize then
	-- 	labelAtlas:setContentSize(options.width, options.height)
	-- end
	return labelAtlas
end

function UIScoreCard:onTouch_(event)
    -- body
    UIManager:RemoveUI("UIScoreCard")
    --self:dispatchEvent({name = CardView.CLICK_CARD_EVENT})
end

return UIScoreCard