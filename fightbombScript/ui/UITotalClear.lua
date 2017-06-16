--
-- Author: GFun
-- Date: 2016-10-26 15:39:02
--
local UIBase = require("script.fightbombScript.ui.UIBase")
local UITotalClear = class("UITotalClear", UIBase)


function UITotalClear:ctor()
	self.maskLayer_ = display.newColorLayer(ccc4(0, 0, 0, 0))--ccc4
	self.maskLayer_:addTo(self)
    UITotalClear.super.ctor(self)
end

function UITotalClear:onShow()
	-- body
	local xi_count_tab	 = DataCenter:getXiScoreCount()
	local order_count_tab = DataCenter:getOrderCount()
	local total_score = DataCenter:getTotalScore()
	local win_score	= DataCenter:getMaxScore() 

	dump(total_score)
	print("冠军得分:" .. tonumber(win_score))
	--print("冠军索引:" .. winnerIndex)
	local rand_id = DataCenter:getRandID()
	for i = 1, GAME_PLAYER do
		local node_name = "Node_" .. i
		self[node_name] = cc.uiloader:seekNodeByName(self.UINode_, node_name)
		local pUserData = DataCenter:getUserInfo(i - 1)
		local user_name = pUserData.szAccount
		local user_id = pUserData.dwUserID
		local bShow = tonumber(win_score) == tonumber(total_score[i])
		if bShow then
			local frame = display.newSpriteFrame("total_clear_dizj.png")
			cc.uiloader:seekNodeByName(self[node_name], "item_bg"):setSpriteFrame(frame)
		end
		local icon = cc.uiloader:seekNodeByName(self[node_name], "icon")
		--print("房主椅子号:" .. DataCenter:getUserChairId())
		cc.uiloader:seekNodeByName(self[node_name], "fangzhu"):setVisible(i - 1 == DataCenter:getTableUser())
		cc.uiloader:seekNodeByName(self[node_name], "name"):setString(user_name)
		cc.uiloader:seekNodeByName(self[node_name], "ID"):setString("ID:" .. user_id)
		cc.uiloader:seekNodeByName(self[node_name], "num_order_1"):setString(order_count_tab[i][1])
		cc.uiloader:seekNodeByName(self[node_name], "num_order_2"):setString(order_count_tab[i][2])
		cc.uiloader:seekNodeByName(self[node_name], "num_order_3"):setString(order_count_tab[i][3])
		cc.uiloader:seekNodeByName(self[node_name], "num_order_4"):setString(order_count_tab[i][4])
		cc.uiloader:seekNodeByName(self[node_name], "num_xi"):setString(xi_count_tab[i])
		
		cc.uiloader:seekNodeByName(self[node_name], "total_num"):setString(total_score[i])
		cc.uiloader:seekNodeByName(self[node_name], "winner_cup"):setVisible(bShow)
		local face_id = pUserData.cbFaceID
		
		if face_id ~= -1 then
			local pImgHead = CreateFaceByIDEx(pUserData)
			local sx, sy = AdjustSpriteScale(icon, pImgHead)
			local x = icon:getContentSize().width / 2
			local y = icon:getContentSize().height / 2
			--print("sx = " .. sx .. ", sy = " .. sy)
			pImgHead:addTo(icon)
					:align(display.CENTER, 40, 40)
			pImgHead:setScale(0.35)
		end
	end
	cc.uiloader:seekNodeByName(self.UINode_, "room_num"):setString("房间号:" .. rand_id)
	--绑定事件
	cc.uiloader:seekNodeByName(self.UINode_, "Btn_return"):onButtonClicked(handler(self, self.clickReturnBtn))
	cc.uiloader:seekNodeByName(self.UINode_, "Btn_share"):onButtonClicked(handler(self, self.clickShareBtn))
end

function UITotalClear:onHide()
    -- body
    self:setVisible(false)
end

function UITotalClear:onUpdate()

end

function UITotalClear:onRemove()
    -- body
    self:removeSelf()
end

function UITotalClear:clickReturnBtn()
	-- body
	GameScene:ExitGame()
end

function UITotalClear:clickShareBtn()
	-- body
	print("点击了炫耀一下")
	local share_wx = require("script.public.share_wx")
	share_wx.captureScreenShareEx(true)
end

return UITotalClear
