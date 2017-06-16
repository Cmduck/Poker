
--结束亮牌
local ShowCards = class("ShowCards", function()
    return display.newNode()
end)

local CardHelper = require("script.fightbombScript.card.CardHelper")
local CardView = require("script.fightbombScript.card.CardView")
-- local GameLogic = require("script.fightbombScript.game.GameLogic")
 --display.addSpriteFramesWithFile("card.plist","card.png")
ShowCards.CARD_DISTANCE = 36	--扑克间距

ShowCards.ROW_NUM = 9			--一行扑克数
function ShowCards:ctor(cardsData, cardsCount, bSelf)
	-- body
	self.cardsData_ = cardsData
	self.ComboCardsList_ = {}
	self.cardsNum_ = 0
	self.bSelf_ = bSelf
	--GameLogic:sortCardsData(self.cardsData_)
	self:createCards(self.cardsData_, cardsCount)
	self:setScale(0.6)
end

function ShowCards:createCards(cardsData, cardsCount)
	-- body
	for i = 1, cardsCount do
		self.ComboCardsList_[i] = CardView.new(self.cardsData_[i])
		self.ComboCardsList_[i]:addTo(self)
		if self.bSelf_ then
			self.ComboCardsList_[i]:align(display.CENTER, 0 + (i - 1) * ShowCards.CARD_DISTANCE, 0)
		else
			local row = math.floor((i - 1) / ShowCards.ROW_NUM)
			local column = (i - 1) % ShowCards.ROW_NUM
			self.ComboCardsList_[i]:align(display.CENTER, 0 + column * ShowCards.CARD_DISTANCE, 0 - row * 50)
		end
	end	
end

return ShowCards