local UIBase = require("script.50kScript.ui.UIBase")
local UIIcon = class("UIIcon", UIBase)
local CardClass = require("script.50kScript.card.CardClass")

function UIIcon:ctor()
    UIIcon.super.ctor(self)
    --display.addSpriteFrames("ccbResources/touxiang.plist", "ccbResources/touxiang.png")  
end

function UIIcon:onShow()
    -- body
    local nodeNameTab = {"node_down", "node_right", "node_up", "node_left"}
    local nodeShowControllTab = {"head", "duanxian", "coin_bg", "coin", "coin_num", "remain_bg", "remain_num", "name", "zhuang",
	"hou", "score_bg", "jifen", "score_num", "trustee"}
    local bShow = StateManager:GetCurStateID() ~= GAME_STATE_WAIT

	for i, v in ipairs(nodeNameTab) do
		self[v] = cc.uiloader:seekNodeByName(self.UINode_, v)
		--dump(self[v])
		for j, subName in ipairs(nodeShowControllTab) do
			--print(subName)
			self[v .. subName] = cc.uiloader:seekNodeByName(self[v], subName)
			self[v .. subName]:setVisible(bShow)
		end 		
	end

	self.initShowIpData_ = {}
	self.userIconTab_ = {}
	self.bInitGotye_ = false
	self.gotyeDirectionTab_ = {}
	self.bandkerNodeName_ = ""
	--self:InitVoice()
end

function UIIcon:onHide()
    -- body
end

function UIIcon:onUpdate()
    -- body
    --print(self.__cname ..":onUpdate()")
    local nodeNameTab = {"node_down", "node_right", "node_up", "node_left"}
	for i = 0, GAME_PLAYER - 1 do
		local pUserData = FGameDC:getDC():GetUserInfo(i) or DataCenter:getUserInfo(i)
		local nodeName = nodeNameTab[GetDirection(i) + 1]
		print("[nodeName]:" .. nodeName)
		--dump(pUserData)
		self[nodeName .. "name"]:setVisible(pUserData ~= nil)
		self[nodeName .. "coin"]:setVisible(pUserData ~= nil)
		self[nodeName .. "coin_num"]:setVisible(pUserData ~= nil)
		self[nodeName .. "jifen"]:setVisible(pUserData ~= nil)
		self[nodeName .. "coin_bg"]:setVisible(pUserData ~= nil)
		self[nodeName .. "score_bg"]:setVisible(pUserData ~= nil)
		self[nodeName .. "score_num"]:setVisible(pUserData ~= nil)
		self[nodeName .. "head"]:setVisible(pUserData ~= nil)
		self[nodeName .. "duanxian"]:setVisible(pUserData and pUserData.cbUserStatus == US_OFFLINE)
		self[nodeName .. "trustee"]:setVisible(pUserData and DataCenter:getSysTrusteeshipStatus()[i + 1])
		if pUserData and DataCenter:getSysTrusteeshipStatus()[i + 1] then
			print("玩家【" .. FGameDC:getDC():UnicodeToUtf8(pUserData.szAccount[0]) .. "】" .. "处于托管状态！")
		end
		if pUserData == nil or pUserData == 0 then

		else
			self[nodeName .. "name"]:setString(FGameDC:getDC():UnicodeToUtf8(pUserData.szAccount[0]))

			if DataCenter:getServerType() == 0x0001 then
				--积分场
				--print("历史得分：")
				--dump(DataCenter:getHistoryScore())
				local historyScore = DataCenter:getHistoryScore()[i + 1]
				self[nodeName .. "coin_num"]:setString(historyScore)
			elseif DataCenter:getServerType() == 0x0002 then
				--金币场
				--print("用户金币:" .. pUserData.lGold)
				self[nodeName .. "coin_num"]:setString(pUserData.lGold or "0")
			end

			self[nodeName .. "score_num"]:setString(DataCenter:getCardScoreTab()[i + 1])
			local face_id = pUserData.cbFaceID
			if face_id ~= -1 then
				local pImgHead = CreateFaceByID(face_id)
				local width = pImgHead:getContentSize().width
				local height = pImgHead:getContentSize().height
				self[nodeName .. "head"]:setSpriteFrame(pImgHead:getSpriteFrame())
				self[nodeName .. "head"]:setScale(88/width, 88/height)
			end
			--显示IP
			--[[
			do
			    if self.initShowIpData_[i] == nil then
			    	--print("当前IP: " .. i)
			        self.initShowIpData_[i] = true
			    
			        local GameUserInfo = require("script.public.GameUserInfo")


			        local pImgTemp = cc.Sprite:createWithSpriteFrameName("qipaitouxiang/duanxian.png")
			        local nScale = 66.0 / pImgTemp:getContentSize().width


		            local pBtnShowIP = cc.ui.UIPushButton.new({normal = "#qipaitouxiang/duanxian.png", pressed = "#qipaitouxiang/duanxian.png"})
		            pBtnShowIP:setScale(nScale)
		            pBtnShowIP:setOpacity(0)
		            local nIndex = (i + 2) % 4
		            --self.m_tblHeadUnit[nIndex] = self[nodeName .. "head"]
		            local pNode = display.newNode()
		            pNode:addChild(pBtnShowIP)

		            self[nodeName]:addChild(pNode)
		            --就是把传进去的按钮和用户的椅子号对应起来 而传入的椅子号又必须使用该接口指定的格式
		            local pUserIPInfo = GameUserInfo:create(pBtnShowIP, FGameDC:getDC():SwitchViewChairID(i) + 1)
		            --pUserIPInfo:align(display.CENTER, display.cx, display.cy)
		            pUserIPInfo:addTo(GameScene)
			    end
			end
			--]]
		end
		--print("UIIcon 当前的ServerStatus:" .. DataCenter:getServerStatus())
		--print("UIIcon 当前的StateId: " .. StateManager:GetCurStateID())
		if StateManager:GetCurStateID() == GAME_STATE_PLAYING and DataCenter:getServerStatus() == GS_UG_PLAYING then

			local remainCardsTab = DataCenter:getRemainingCardTab()
			self[nodeName .. "remain_num"]:setString(tostring(remainCardsTab[i + 1]))
			self[nodeName .. "remain_num"]:setVisible(true)
			self[nodeName .. "remain_bg"]:setVisible(true)
			--庄家显示
			--print("庄家显示")
			self[nodeName .. "zhuang"]:setVisible(i == DataCenter:getBankerUser())
			--吼牌显示
			self[nodeName .. "hou"]:setVisible(i == DataCenter:getHouCardUser())

			-- if DataCenter:getGameType() == 0 and i == DataCenter:getBankerFriend() then
			--     local show_cards_data 	= DataCenter:getShowCardsData()
			--     local show_cards_num 	= #show_cards_data
			--     --显示叫牌
			--     dump(show_cards_data)
			--     if #show_cards_data ~= 0 and DataCenter:getIsOutShowCard() then
			--     	self[nodeName .. "jiao_card_bg"]:setVisible(true)
			--     	self:createSmallCard(show_cards_data[show_cards_num], self[nodeName .. "jiao_card_bg"])
			--     else
			--         self[nodeName .. "jiao_card_bg"]:removeAllChildren()
			--         self[nodeName .. "jiao_card_bg"]:setVisible(false)
			--     end
			-- end
		end
	end
end

function UIIcon:InitVoice()
    local nodeNameTab = {"node_up", "node_left", "node_down", "node_right"}
    for i = 0, GAME_PLAYER - 1 do
		local nodeName = nodeNameTab[i + 1]
		-- print("自身椅子号:" .. GetSelfChairID())
		-- print("当前椅子号:" .. i)
		-- print("视图位置:" .. FGameDC:getDC():SwitchViewChairID(i))
		-- print("位置:" .. nodeName)
		self.userIconTab_[i + 1] = cc.uiloader:seekNodeByName(self[nodeName], "icon_bg")
		self.gotyeDirectionTab_[i + 1] = nodeName    	
    end
    dump(self.gotyeDirectionTab_)
    --self:InitGotye()	
end

function UIIcon:createSmallCard(data, node)
	-- body
	self.cardClass_ = CardClass.new(data)
    local color = self.cardClass_:getColor()
    local actualValue = self.cardClass_:getActualValue()
    local x = node:getContentSize().width / 2
    local y = node:getContentSize().height / 2
    local cardBg = display.newSprite("#card_small_bottom.png")
        :align(display.CENTER, x, y)
        :addTo(node)
        :setScale(0.85)
    if actualValue > 15 then
        local cardNum = display.newSprite("#card_small_" .. color .. actualValue .. ".png")
        :align(display.CENTER, 8, 30)
        :addTo(cardBg)
        local colorImg = display.newSprite("#card_small_joker_" .. actualValue .. ".png")
        :align(display.CENTER, 30, 15)  
        :addTo(cardBg)
    else
        local colorIndex = color % 2
        -- local cardBg = display.newSprite("#bottom.png")
        --     :align(display.CENTER, display.cx, display.cy)
        --     :addTo(self)
        local cardNum = display.newSprite("#card_small_" .. colorIndex .. actualValue .. ".png")
            :align(display.CENTER, 11, 45)
            :addTo(cardBg)

        local colorImg = display.newSprite("#card_small_" .. color .. ".png")
            :align(display.CENTER, 30, 15)
            :addTo(cardBg)
    end
end

function UIIcon:onRemove()
    -- body
    --self.m_pGotye:getNoticeButton():setVisible(false)
    --self.m_pGotye:GotyeAPISetRecMsgHandler(nil)
	--display.removeSpriteFramesWithFile("ccbResources/touxiang.plist", "ccbResources/touxiang.png")
    self:removeSelf()
end

function UIIcon:InitGotye()
	print("初始化语音:")
    local pNode = display.newNode()
    pNode:addTo(GameScene):align(display.CENTER, display.cx, display.cy)
    pNode:setLocalZOrder(88)
    dump(self.userIconTab_, "self.userIconTab_")
    self.m_pGotye = require("script.public.gotyeapi").create(pNode, self.userIconTab_)

    local Temp = self.m_pGotye:getNoticeButton()        --获取语音按钮
    Temp:setPosition(cc.p(500, -100))
    Temp:setVisible(false)

    for i = 1, GAME_PLAYER do
    	local pos
    	if self.gotyeDirectionTab_[i] == "node_down" then
    		pos = cc.p(175, 90)
		elseif self.gotyeDirectionTab_[i] == "node_right" then
			--todo
    		pos = cc.p(175, 90)
		elseif self.gotyeDirectionTab_[i] == "node_up" then
			--todo
    		pos = cc.p(175, 90)
		elseif self.gotyeDirectionTab_[i] == "node_left" then
			--todo
    		pos = cc.p(175, 90)
		end
        self.m_pGotye:getNoticeAnimate(i):setPos(pos)
        self.m_pGotye:getNoticeAnimate(i):setFlippedX(self.gotyeDirectionTab_[i] == "node_right")

        --测试代码 发布时要去掉
        -- self.m_pGotye:getNoticeAnimate(i):setVisible(self.gotyeDirectionTab_[i] == "node_right")
        -- self.m_pGotye:getNoticeAnimate(i):setLooped(true);
        -- self.m_pGotye:getNoticeAnimate(i):start()--stopPlay
    end
end

function UIIcon:RecMsgGotyeapiHandlerEx(...)
    self.m_pGotye:RecMsgGotyeapiHandler(...);
end

function UIIcon:getCurBaoUserPos(node)
	-- body
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print(self.bandkerNodeName_)
	local bao_img = self[self.bandkerNodeName_ .. "bao"]
	local bao_pos = cc.p(bao_img:getPositionX(), bao_img:getPositionY())
	dump(bao_pos)
	local iconNode =  self[self.bandkerNodeName_]
	local world_pos = iconNode:convertToWorldSpace(bao_pos)
	return node:convertToNodeSpace(world_pos)
end

function UIIcon:showBaoGaf()
	-- body
	if not self.baoGaf_ then
		local gaf_path = "ccbResources/sparrowyhRes/animation/touxiangguang/touxiangguang.gaf"
		local FlashSprite = require("script.public.FlashSprite")
		self.baoGaf_ = FlashSprite.new(gaf_path)
		self.baoGaf_:addTo(self[self.bandkerNodeName_])
	end
	self.baoGaf_:stop()
	self.baoGaf_:setVisible(true)
	self.baoGaf_:setPos(0, 0)
	self.baoGaf_:start()
	self.baoGaf_:setAnimationFinishedPlayDelegate(function()
		-- body
		self.baoGaf_:stop()
		self.baoGaf_:setVisible(false)
	end)
end

return UIIcon