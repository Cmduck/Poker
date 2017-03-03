--
-- Author: GFun
-- Date: 2016-10-25 19:50:22
--

local UIBase = require("script.50kScript.ui.UIBase")
local UIDismiss = class("UIDismiss", UIBase)


function UIDismiss:ctor()
	self.maskLayer_ = display.newColorLayer(ccc4(0, 0, 0, 100))--ccc4
	self.maskLayer_:addTo(self)
    UIDismiss.super.ctor(self)
end
--params 类型1 请求 0 回应 2 结果
--result 0 失败 1 成功
function UIDismiss:onShow()
	-- body
	self:setVisible(false)
	-- print("params等于" .. params)
	-- print("result等于" .. tostring(result))
	-- self.params_ = params
	-- self.result_ = result
	self.node_request_ = cc.uiloader:seekNodeByName(self.UINode_, "node_request")
	self.node_respond_ = cc.uiloader:seekNodeByName(self.UINode_, "node_respond")
	self.TextField_ = cc.uiloader:seekNodeByName(self.UINode_, "TextField")
	self.msg_fail_ = cc.uiloader:seekNodeByName(self.UINode_, "msg_fail")
	self.msg_suc_ = cc.uiloader:seekNodeByName(self.UINode_, "msg_suc")
	self.txt_reason_ = cc.uiloader:seekNodeByName(self.UINode_, "txt_reason")

	self.Btn_sure_ = cc.uiloader:seekNodeByName(self.node_request_, "Btn_sure")
	self.Btn_cancle_ = cc.uiloader:seekNodeByName(self.node_request_, "Btn_cancle")

	self.Btn_refuse_ = cc.uiloader:seekNodeByName(self.node_respond_, "Btn_refuse")
	self.Btn_agree_ = cc.uiloader:seekNodeByName(self.node_respond_, "Btn_agree")

	self:initUIStatus()
	--1 请求 0 回应 2 结果
	-- self.node_request_:setVisible(params == 1 or params == 2)
	-- self.node_respond_:setVisible(params == 0)
	-- self.msg_fail_:setVisible(result and result == 0)
	-- self.msg_suc_:setVisible(result and result == 1)
	-- self.txt_reason_:setVisible(params == 0)
	-- self.TextField_:setVisible(params == 1)
	-- --获得离开玩家的椅子号
	-- if params == 0 then
	-- 	local chairId = DataCenter:getRequestLeaveUser()
	-- 	local pUserData = FGameDC:getDC():GetUserInfo(chairId)
	-- 	local user_name = FGameDC:getDC():UnicodeToUtf8(pUserData.szAccount[0])
	-- 	self.txt_reason_:setString("玩家【" .. user_name .."】说:" .. DataCenter:getLeaveReason())
	-- end
	-- --即将成功解散 屏蔽用户操作
	-- if result and result == 1 then
	-- 	self.node_request_:setVisible(false)
	-- end
	--绑定事件
	self.Btn_sure_:onButtonClicked(handler(self, self.clickSureBtn))
	self.Btn_cancle_:onButtonClicked(handler(self, self.clickCancleBtn))
	self.Btn_refuse_:onButtonClicked(handler(self, self.clickRefuseBtn))
	self.Btn_agree_:onButtonClicked(handler(self, self.clickAgreeBtn))
end

function UIDismiss:onHide()
    -- body
    self:setVisible(false)
end

function UIDismiss:onUpdate(params, result)
	print("params等于" .. params)
	print("result等于" .. tostring(result))
	self.params_ = params
	self.result_ = result
	self:setVisible(true)
	--1 请求 0 回应 2 结果
	self.node_request_:setVisible(params == 1 or params == 2)
	self.node_respond_:setVisible(params == 0)
	self.msg_fail_:setVisible(result and result == 0)
	self.msg_suc_:setVisible(result and result == 1)
	self.txt_reason_:setVisible(params == 0)
	self.TextField_:setVisible(params == 1)
	--获得离开玩家的椅子号
	if params == 0 then
		local chairId = DataCenter:getRequestLeaveUser()
		local pUserData = FGameDC:getDC():GetUserInfo(chairId)
		local user_name = FGameDC:getDC():UnicodeToUtf8(pUserData.szAccount[0])
		self.txt_reason_:setString("玩家【" .. user_name .."】说:" .. DataCenter:getLeaveReason())
	end
	--即将成功解散 屏蔽用户操作
	if result and result == 1 then
		self.node_request_:setVisible(false)
	end
end

function UIDismiss:onRemove()
    -- body
    self:removeSelf()
end

function UIDismiss:clickSureBtn( event )
	-- body
	print("点击了确定按钮")
	if not self.result_ then
		print("发送离开请求")
	    local str = self.TextField_:getText()
	    if string.len(str) <= 0 then
	        str = self.TextField_:getPlaceHolder()
	    end
	    dump(str)
	    InternetManager:sendRequestLeave(str)
	else
		print("重置解散数据")
		DataCenter:resetRequestLeaveInfo()
		self.params_ = nil
		self.result_ = nil
		self:initUIStatus()		
	end
    self:setVisible(false)
end

function UIDismiss:clickCancleBtn( event )
	-- body
	print("点击了取消按钮，重置解散数据")
	DataCenter:resetRequestLeaveInfo()
	self.params_ = nil
	self.result_ = nil   
    self:setVisible(false)
    self:initUIStatus()
end

function UIDismiss:clickRefuseBtn( event )
	-- body
	DataCenter:resetRequestLeaveInfo()
	InternetManager:SendConfirmDismiss(false, GetSelfChairID())
    self:setVisible(false)
end

function UIDismiss:clickAgreeBtn( event )
	-- body
	DataCenter:resetRequestLeaveInfo()
	InternetManager:SendConfirmDismiss(true, GetSelfChairID())
    self:setVisible(false)
end

--初始化UI状态
function UIDismiss:initUIStatus()
	-- body
	self.node_request_:setVisible(true)
	self.node_respond_:setVisible(false)
	self.msg_fail_:setVisible(false)
	self.msg_suc_:setVisible(false)
	self.txt_reason_:setVisible(false)
	self.TextField_:setVisible(true)	
end

return UIDismiss