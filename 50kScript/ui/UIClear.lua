--
-- Author: GFun
-- Date: 2016-12-26 17:09:16
--
--

local UIBase = require("script.50kScript.ui.UIBase")
local UIClear = class("UIClear", UIBase)

UIClear.CLICK_EXIT_BTN 					= "CLICK_EXIT_BTN"
UIClear.CLICK_CONTINUE_GAME_BTN 		= "CLICK_CONTINUE_GAME_BTN"
UIClear.CLICK_LOOK_TOTAL_ACCOUNT_BTN 	= "CLICK_LOOK_TOTAL_ACCOUNT_BTN"

function UIClear:ctor()
	self.maskLayer_ = display.newColorLayer(ccc4(0, 0, 0, 0))--ccc4
	self.maskLayer_:addTo(self)
    UIClear.super.ctor(self) 
end

function UIClear:onShow()
	cc.uiloader:seekNodeByName(self.UINode_, "sub_bg_1"):getTexture():setAliasTexParameters()
	cc.uiloader:seekNodeByName(self.UINode_, "sub_bg_2"):getTexture():setAliasTexParameters()

	local nameTab = {"name_", "card_score_", "total_score_", "type_node_"}

	for i, v in ipairs(nameTab) do
		for j = 1, 4 do
			self[v .. j] = cc.uiloader:seekNodeByName(self.UINode_, v .. j)
		end
	end

	--牌型
	for i = 1, 4 do
		for j = 1, 8 do
			local prevName = "N" .. i .. "_"
			local itemName = "type_item_" .. j
			self[prevName .. itemName] = cc.uiloader:seekNodeByName(self["type_node_" .. i], itemName)
			--print("节点名称:" .. prevName .. itemName)
		end
	end

	local winOrderTab = DataCenter:getWinnerOrderTab()	--{3, 2, 1, 0}--DataCenter:getOverCardUserOrder()
	local cardScoreTab = DataCenter:getCardScoreTab()	    --{1,2, 3, 4}--DataCenter:getCardScoreTab()
	local totalScoreTab = DataCenter:getGameScoreTab()      --{1990, 1991, 1992, 1993}--DataCenter:getGameScoreTab()
	
	dump(winOrderTab)
	dump(cardScoreTab)
	dump(totalScoreTab)
	--倍数分析
	local typeTab, multipleTab = self:AnalyseTypeAndMultiple()

	for i = 1, 4 do
		local iChairId = winOrderTab[i]
		local pUserData = DataCenter:getUserDataTab(iChairId + 1)
		local name = FGameDC:getDC():UnicodeToUtf8(pUserData.szAccount[0])
		local iCardScore = cardScoreTab[iChairId + 1]
		local iTotalScore = tonumber(totalScoreTab[iChairId + 1])
		local prev = ""
		if iTotalScore >= 0 then
			prev = "."
		else
			prev = "/"
		end
		self["name_" .. i]:setString(name)
		self["card_score_" .. i]:setString(iCardScore)
		self["total_score_" .. i]:setString(prev .. math.abs(iTotalScore))

		for j = 1, 8 do
			local prevName = "N" .. i .. "_"
			local itemName = "type_item_" .. j
			local img_type = cc.uiloader:seekNodeByName(self[prevName .. itemName], "img_type")
			local type_num = cc.uiloader:seekNodeByName(self[prevName .. itemName], "type_num")

			if typeTab[iChairId + 1][j] then
				local iPng = typeTab[iChairId + 1][j]
				local iMultiple = multipleTab[iChairId + 1][j]

				local iSprite = display.newSprite("#" .. iPng)
				img_type:setSpriteFrame(iSprite:getSpriteFrame()) 
				type_num:setString("/" .. iMultiple)
			else
				img_type:setVisible(false)
				type_num:setVisible(false)
			end
		end
	end
	local btnTab = {"Btn_continue", "Btn_exit"}
	for i,v in ipairs(btnTab) do
		self[v] = cc.uiloader:seekNodeByName(self.UINode_, v)
	end
	self["Btn_exit"]:onButtonClicked(handler(self, self.clickExitBtn))
    self["Btn_continue"]:onButtonClicked(handler(self, self.clickContinueGameBtn))
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

function UIClear:AnalyseTypeAndMultiple()
	local isMyFriendTab = DataCenter:getMyFriendTab()
	local isAnJiao 		= DataCenter:getAnJiaoTab()
	local isHou 		= DataCenter:getHouTab()
	local isBang 		= DataCenter:getBangTab()
	local isQing 		= DataCenter:getQingTab()
	local bWuShiK 		= DataCenter:get50KTab()
	local b6Bomb 		= DataCenter:get6BombTab()
	local b7Bomb 		= DataCenter:get7BombTab()
	local bDoubleKing 	= DataCenter:getDoubleKingTab()
	local bWushiTHK 	= DataCenter:get50THKTab()
	local bTianZha 		= DataCenter:getTianBombTab()
	local bWudiZha 		= DataCenter:getWudiBombTab()

	local winOrderTab 	= DataCenter:getWinnerOrderTab()--{3, 2, 1, 0}--DataCenter:getOverCardUserOrder()

	local typeTab = {{}, {}, {}, {}}
	local multipleTab = {{}, {}, {}, {}}
	for i = 1, 4 do
		local index = 1
		local iChairId = winOrderTab[i]
		-- typeTab[iChairId + 1] = typeTab[i] or {}
		-- multipleTab[iChairId + 1] = multipleTab[i] or {}

		if isMyFriendTab[iChairId + 1] then
			typeTab[iChairId + 1][index] = "clear_findfriend.png"
			multipleTab[iChairId + 1][index] = 1
			index = index + 1
		end

		if isAnJiao[iChairId + 1] then
			typeTab[iChairId + 1][index] = "clear_an_jiao.png"
			multipleTab[iChairId + 1][index] = 3
			index = index + 1
		end

		if isHou[iChairId + 1] then
			typeTab[iChairId + 1][index] = "clear_hou.png"
			multipleTab[iChairId + 1][index] = 4
			index = index + 1
		end

		if isBang[iChairId + 1] then
			typeTab[iChairId + 1][index] = "clear_bang.png"
			multipleTab[iChairId + 1][index] = 2
			index = index + 1
		end

		if isQing[iChairId + 1] then
			typeTab[iChairId + 1][index] = "clear_qing.png"
			multipleTab[iChairId + 1][index] = 4
			index = index + 1
		end

		if bWuShiK[iChairId + 1] > 0 then
			typeTab[iChairId + 1][index] = "img_type_8.png"
			multipleTab[iChairId + 1][index] = 2 * bWuShiK[iChairId + 1]
			index = index + 1		
		end

		if b6Bomb[iChairId + 1] > 0 then
			typeTab[iChairId + 1][index] = "img_type_9.png"
			multipleTab[iChairId + 1][index] = 2 * b6Bomb[iChairId + 1]
			index = index + 1
		end

		if b7Bomb[iChairId + 1] > 0 then
			typeTab[iChairId + 1][index] = "img_type_11.png"
			multipleTab[iChairId + 1][index] = 2 * b7Bomb[iChairId + 1]
			index = index + 1
		end

		if bDoubleKing[iChairId + 1] > 0 then
			typeTab[iChairId + 1][index] = "img_type_13.png"
			multipleTab[iChairId + 1][index] = 2 * bDoubleKing[iChairId + 1]
			index = index + 1
		end

		if bWushiTHK[iChairId + 1] > 0 then 
			typeTab[iChairId + 1][index] = "img_type_10.png"
			multipleTab[iChairId + 1][index] = 4 * bWushiTHK[iChairId + 1]
			index = index + 1
		end

		if bTianZha[iChairId + 1] > 0 then
			typeTab[iChairId + 1][index] = "img_type_17.png"
			multipleTab[iChairId + 1][index] = 4 * bTianZha[iChairId + 1]
			index = index + 1
		end

		if bWudiZha[iChairId + 1] > 0 then
			typeTab[iChairId + 1][index] = "img_type_18.png"
			multipleTab[iChairId + 1][index] = 4 * bWudiZha[iChairId + 1]
			index = index + 1
		end
		-- print("-------------------------------------------------------")
		-- print("ChairID = " .. iChairId)
		-- dump(typeTab[iChairId + 1])
		-- dump(multipleTab[iChairId + 1])
	end

	print("类型表:")
	dump(typeTab, nil , 4)

	print("倍数表:")
	dump(multipleTab, nil , 4)
	return typeTab, multipleTab
end

function UIClear:clickContinueGameBtn(event)
	-- body
	print("点击继续游戏")
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