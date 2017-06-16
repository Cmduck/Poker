--
-- Author: GFun
-- Date: 2016-12-26 17:09:16
--
--
local CardClass = require("script.fightbombScript.card.CardClass")
local UIBase = require("script.fightbombScript.ui.UIBase")
local UIClear = class("UIClear", UIBase)

--结算结果 0 失败 1 胜利 2 平局

UIClear.CLICK_EXIT_BTN 					= "CLICK_EXIT_BTN"
UIClear.CLICK_CONTINUE_GAME_BTN 		= "CLICK_CONTINUE_GAME_BTN"
UIClear.CLICK_LOOK_TOTAL_ACCOUNT_BTN 	= "CLICK_LOOK_TOTAL_ACCOUNT_BTN"

function UIClear:ctor()
	self.maskLayer_ = display.newColorLayer(ccc4(0, 0, 0, 200))--ccc4
	self.maskLayer_:addTo(self)
    UIClear.super.ctor(self) 
end

function UIClear:onShow()
	print("结算界面")

	local result = DataCenter:getGameResult()
	print("result = ", result)
	self:ShowTitle(result)

	self["Btn_continue"] = cc.uiloader:seekNodeByName(self.UINode_, "Btn_continue")
	self["Btn_total"]     = cc.uiloader:seekNodeByName(self.UINode_, "Btn_total")

    self["Btn_continue"]:onButtonClicked(handler(self, self.clickContinueGameBtn))
    self["Btn_total"]:onButtonClicked(handler(self, self.clickLookTotalAccountBtn))

	for i = 0, GAME_PLAYER - 1 do
		local index = i + 1
		local chairId = DataCenter:getUserOrder()[index]
		local iFaction = DataCenter:getFaction()[chairId + 1]
		local pUserData   = DataCenter:getUserInfo(chairId)

		local item        = cc.uiloader:seekNodeByName(self.UINode_, "item_bg_" .. index)

		if iFaction == 1 then 
			local frame = display.newSpriteFrame("js_lanse.png")
			item:setSpriteFrame(frame)
		end

		local total_score = cc.uiloader:seekNodeByName(item, "total_score")
		local name        = cc.uiloader:seekNodeByName(item, "name")
		local icon        = cc.uiloader:seekNodeByName(item, "icon")
		local catch_score = cc.uiloader:seekNodeByName(item, "catch_score")
		local node_xi_score    = cc.uiloader:seekNodeByName(item, "xi_score")
		local node_extra_score = cc.uiloader:seekNodeByName(item, "extra_score")
		local node_cur_score = cc.uiloader:seekNodeByName(item, "cur_score")

		local face_id = pUserData.cbFaceID
		if face_id ~= -1 then
		--设置头像
			local pImgHead = CreateFaceByIDEx(pUserData)
			local sx, sy   = AdjustSpriteScale(icon, pImgHead)
			icon:setSpriteFrame(pImgHead:getSpriteFrame())
			icon:setScale(sx, sy)
		end

		--设置名字
		name:setString(pUserData.szAccount)
		--分数设置
		local total_socre_num = tonumber(DataCenter:getTotalScore()[chairId + 1])
		local catch_score_num = DataCenter:getCatchScore()[chairId + 1]
		local xi_score_num = DataCenter:getXiScore()[chairId + 1]
		local extra_score_num = DataCenter:getExtraScore()[chairId + 1]
		local cur_score_num = tonumber(DataCenter:getGameScoreTab()[chairId + 1])

		local prevChar = ""
		if total_socre_num >= 0 then
			prevChar = "/"
		else
			prevChar = "."
		end
		total_score:setString(prevChar .. tostring(math.abs(total_socre_num)))
		catch_score:setString("/" .. tostring(math.abs(catch_score_num)))

		prevChar = "/"
		local num_path = ""

		print("加载喜分分数")
		if xi_score_num >= 0 then
			num_path = "ccbResources/fightbombRes/clear/js_shuzi.png"
		else
			num_path = "ccbResources/fightbombRes/clear/js_shuzi2.png"
		end
		local t1 = {stringValue = prevChar .. tostring(math.abs(xi_score_num)), path = num_path, itemWidth = 20, itemHeight = 27, startCharMap = '/'}
		local labelAtlas1 = self:createLabelAtlas(t1)
		labelAtlas1:addTo(node_xi_score)

		print("加载奖惩分数")
		if extra_score_num >= 0 then
			num_path = "ccbResources/fightbombRes/clear/js_shuzi.png"
		else
			num_path = "ccbResources/fightbombRes/clear/js_shuzi2.png"
		end 
		local t2 = {stringValue = prevChar .. tostring(math.abs(extra_score_num)), path = num_path, itemWidth = 20, itemHeight = 27, startCharMap = '/'}
		local labelAtlas2 = self:createLabelAtlas(t2)
		labelAtlas2:addTo(node_extra_score)

		print("加载当轮分数")
		if cur_score_num >= 0 then
			num_path = "ccbResources/fightbombRes/clear/js_shuzi.png"
		else
			num_path = "ccbResources/fightbombRes/clear/js_shuzi2.png"
		end

		local t3 = {stringValue = prevChar .. tostring(math.abs(cur_score_num)), path = num_path, itemWidth = 20, itemHeight = 27, startCharMap = '/'}
		local labelAtlas3 = self:createLabelAtlas(t3)
		labelAtlas3:addTo(node_cur_score)
	end

    local serverType = DataCenter:getServerType()
    if serverType == GAME_GENRE_SCORE then
    	local bGameOver = DataCenter:getIsGameOver()
    	self["Btn_continue"]:setVisible(not bGameOver)
    	self["Btn_total"]:setVisible(bGameOver)
    elseif serverType == GAME_GENRE_GOLD then
    	self["Btn_total"]:setVisible(false)
    end
end

function UIClear:onHide()
    -- body
end

function UIClear:onUpdate()

end

function UIClear:onRemove()
    -- body
    self:removeSelf()
end


function UIClear:ShowTitle(result)
	-- body
	for i = 0 , 2 do
		self["result_" .. i] = cc.uiloader:seekNodeByName(self.UINode_, "result_" .. i)
		self["result_" .. i]:setVisible(false)
	end

	self["result_" .. result]:setVisible(true)
end

function UIClear:clickContinueGameBtn(event)
	-- body
	self:dispatchEvent({name = UIClear.CLICK_CONTINUE_GAME_BTN})
end

function UIClear:clickExitBtn(event)
	-- body
	self:dispatchEvent({name = UIClear.CLICK_EXIT_BTN}) 
end

function UIClear:clickLookTotalAccountBtn(event)
	-- body
	self:dispatchEvent({name = UIClear.CLICK_LOOK_TOTAL_ACCOUNT_BTN}) 
end

function UIClear:ShowPoker(node, cbCardData, cbCardCount)
	if cbCardCount == 0 then return end

	for i = 1, cbCardCount do
		local Card = self:createSmallCard(cbCardData[i])
		Card:align(display.CENTER, 0 + (i - 1) * 21, 0):addTo(node)
		if i ~= 1 then
			local x = node:getPositionX()
			node:setPositionX(x - 21 * 0.5)
		end
	end
end

function UIClear:createSmallCard(data)
	-- body
	self.cardClass_ = CardClass.new(data)

    local color = self.cardClass_:getCardColor()
    local faceValue = self.cardClass_:getCardValue()

    local Card = display.newSprite("#card_small_bottom.png")
        :align(display.CENTER, 0, 0)

    if faceValue > 13 then
        local cardNum = display.newSprite("#card_small_" .. color .. faceValue .. ".png")
        :align(display.CENTER, 8, 30)
        :addTo(Card)
        local colorImg = display.newSprite("#card_small_joker_" .. faceValue .. ".png")
        :align(display.CENTER, 30, 15)  
        :addTo(Card)
    else
        local colorIndex = color % 2
        local cardNum = display.newSprite("#card_small_" .. colorIndex .. faceValue .. ".png")
            :align(display.CENTER, 11, 45)
            :addTo(Card)

        local colorImg = display.newSprite("#card_small_" .. color .. ".png")
            :align(display.CENTER, 11, 15)
            :addTo(Card)
    end

    return Card
end

function UIClear:createLabelAtlas(options)
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
return UIClear