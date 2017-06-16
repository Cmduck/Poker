--
-- Author: GFun
-- Date: 2017-02-23 17:52:29
--
local BaseData = require("script.fightbombScript.data.BaseData")
local SystemTrusteeshipData = class("SystemTrusteeshipData", BaseData)

local SystemTrusteeshipDataStruct = {
	{wChairID           = -1},			--托管用户
	{bTrusteeshipStatus = false},		--托管状态
}

function SystemTrusteeshipData:ctor()
	SystemTrusteeshipData.super.ctor(self)

	self:SetDataType(self.class.SYSTEM_MSG_TYPE)
	self:SetDataStructParams(SystemTrusteeshipDataStruct)
end

function SystemTrusteeshipData:ProcessMsg(data, data_center)
	for _, tab in ipairs(self.dataStructParams_) do
		for name, value in pairs(tab) do
			if type(value) == "table" then
				self[name] = clone(data[self.dataIndex_])
			else
				self[name] = data[self.dataIndex_]
			end
			self.dataIndex_ = self.dataIndex_ + 1
		end
	end
	self:ExtendData(data_center)
	self:DispatchEvent(data_center)
end

function SystemTrusteeshipData:ExtendData(data_center)
	data_center.m_bSysTrusteeshipTab_[self.wChairID + 1] = self.bTrusteeshipStatus
end

function SystemTrusteeshipData:DispatchEvent(data_center)
	print("------------------------------SystemTrusteeshipData:DispatchEvent------------------------")
	data_center:dispatchEvent({name = data_center.SYSTEM_G_USER_TRUSTEESHIP})
end

return SystemTrusteeshipData