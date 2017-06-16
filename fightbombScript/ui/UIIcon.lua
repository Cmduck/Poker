local UIBase = require("script.fightbombScript.ui.UIBase")
local UIIcon = class("UIIcon", UIBase)
local CardClass = require("script.fightbombScript.card.CardClass")

function UIIcon:ctor()
    UIIcon.super.ctor(self)
end

function UIIcon:onShow()
    -- body
    local nodeNameTab = {"node_down", "node_right", "node_up", "node_left"}
    local nodeShowControllTab = {"head", "duanxian", "name", "remain_num", "zhuang", "bao", "xi_score", "gold_num",
     "catch_score", "huoban", "img_shengyu", "xi", "jinbi", "zhua"}

	for i, v in ipairs(nodeNameTab) do
		self[v] = cc.uiloader:seekNodeByName(self.UINode_, v)
		--dump(self[v])
		for j, subName in ipairs(nodeShowControllTab) do
			--print(subName)
			self[v .. subName] = cc.uiloader:seekNodeByName(self[v], subName)
			self[v .. subName]:setVisible(false)
		end 		
	end
	--self["coin_num"]:setString("0")
	self.initShowIpData_ = {}
	self.userIconTab_ = {}
	self.bInitGotye_ = false
	self.gotyeDirectionTab_ = {}
	self.bandkerNodeName_ = ""
	self:InitVoice()
end

function UIIcon:onHide()
    -- body
end

function UIIcon:onUpdate()
    -- body
    --print(self.__cname ..":onUpdate()")
    local nodeNameTab = {"node_down", "node_right", "node_up", "node_left"}
    local my_chairId = DataCenter:getSelfChairID()
    local factionTab = DataCenter:getFaction()
    local my_faction = factionTab[my_chairId + 1]
	for i = 0, GAME_PLAYER - 1 do
		local pUserData = FGameDC:getDC():GetUserInfo(i) --or DataCenter:getUserInfo(i)
		local nodeName = nodeNameTab[GetDirection(i) + 1]
		self[nodeName .. "name"]:setVisible(pUserData ~= nil)
		self[nodeName .. "head"]:setVisible(pUserData ~= nil)
		self[nodeName .. "duanxian"]:setVisible(pUserData and pUserData.cbUserStatus == US_OFFLINE)

		if pUserData and DataCenter:getSysTrusteeshipStatus()[i + 1] then
			print("玩家【" .. FGameDC:getDC():UnicodeToUtf8(pUserData.szAccount[0]) .. "】" .. "处于托管状态！")
		end
		if pUserData == nil or pUserData == 0 then

		else
			self[nodeName .. "name"]:setString(FGameDC:getDC():UnicodeToUtf8(pUserData.szAccount[0]))

			if DataCenter:getServerType() == GAME_GENRE_SCORE then
				--积分场
				local score_tab = DataCenter:getTotalScore()
				local score = checknumber(score_tab[i + 1])
				local prev = score < 0 and "-" or "+"
				print("用户积分:" .. score)
				self[nodeName .. "gold_num"]:setString(prev .. math.abs(score))
			elseif DataCenter:getServerType() == GAME_GENRE_GOLD then
				--金币场
				print("用户金币:" .. pUserData.lGold)
				self[nodeName .. "gold_num"]:setString(pUserData.lGold or "0")
			end

			local face_id = pUserData.cbFaceID
			if face_id ~= -1 then
				local pImgHead = CreateFaceByIDEx(pUserData)
				local width = pImgHead:getContentSize().width
				local height = pImgHead:getContentSize().height
				self[nodeName .. "head"]:setSpriteFrame(pImgHead:getSpriteFrame())
				self[nodeName .. "head"]:setScale(88/width, 88/height)
			end

			if StateManager:GetCurStateID() == GAME_STATE_PLAYING then
				local show_tab = {"img_shengyu", "xi", "jinbi", "zhua", "remain_num", "xi_score", "gold_num", "catch_score"}

				for i, v in ipairs(show_tab) do
					self[nodeName .. v]:setVisible(true)
				end

				local game_model = DataCenter:getGameModel()
				local banker_user = DataCenter:getBankerUser()
				local catch_score_tab = DataCenter:getCatchScore()
				local xi_score_tab = DataCenter:getXiScore()
				local score_tab = DataCenter:getTotalScore()
				local remain_tab = DataCenter:getHandCardCountTab()
				self[nodeName .. "catch_score"]:setString(catch_score_tab[i + 1])
				self[nodeName .. "xi_score"]:setString(xi_score_tab[i + 1])
				self[nodeName .. "gold_num"]:setString(score_tab[i + 1])
				self[nodeName .. "remain_num"]:setString(remain_tab[i + 1])
				self[nodeName .. "bao"]:setVisible(game_model == GAME_MODEL_BAO and banker_user == i)
				self[nodeName .. "zhuang"]:setVisible(game_model == GAME_MODEL_CALL and banker_user == i)

				--显示伙伴
				if i ~= my_chairId and game_model == GAME_MODEL_CALL then
					local iFaction = factionTab[i + 1]
					local bShowFriend = DataCenter:getIsOutCallCard()
					self[nodeName .. "huoban"]:setVisible(iFaction and iFaction == my_faction and bShowFriend)
				end
			end
			--显示IP
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
		self.userIconTab_[i + 1] = cc.uiloader:seekNodeByName(self[nodeName], "kuang")
		self.gotyeDirectionTab_[i + 1] = nodeName    	
    end
    dump(self.gotyeDirectionTab_)
   	self:InitGotye()	
end

function UIIcon:onRemove()
    -- body
    self.m_pGotye:getNoticeButton():setVisible(false)
    self.m_pGotye:GotyeAPISetRecMsgHandler(nil)

    self:removeSelf()
end

function UIIcon:InitGotye()
	print("初始化语音:")
    local pNode = display.newNode()
    pNode:addTo(GameScene):align(display.CENTER, display.cx, display.cy)
    pNode:setLocalZOrder(1)
    dump(self.userIconTab_, "self.userIconTab_")
    self.m_pGotye = require("script.public.gotyeapi").create(pNode, self.userIconTab_)

    local Temp = self.m_pGotye:getNoticeButton()        --获取语音按钮
    Temp:setPosition(cc.p(550, -25))
    Temp:setVisible(true)

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
	local nodeNameTab = {"node_down", "node_right", "node_up", "node_left"}
	local banker_user = DataCenter:getBankerUser()
	local nodeName = nodeNameTab[GetDirection(banker_user) + 1]
	
	
	local bao_img = self[nodeName .. "bao"]
	local bao_pos = cc.p(bao_img:getPositionX(), bao_img:getPositionY())
	dump(bao_pos)
	local iconNode =  self[nodeName]
	local world_pos = iconNode:convertToWorldSpace(bao_pos)
	return node:convertToNodeSpace(world_pos)
end

function UIIcon:showBaoGaf()
	-- body
	if not self.baoGaf_ then
		local gaf_path = "ccbResources/fightbombRes/animation/touxiangguang/touxiangguang.gaf"
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