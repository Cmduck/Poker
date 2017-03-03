
local BaseData = require("script.50kScript.data.BaseData")
local SceneFreeData = class("SceneFreeData", BaseData)

--与服务端对应的数据结构
local SceneFreeDataStruct = {
		{m_lCellScore_ 	= 1},
		{m_wServerType_ = 2},
	}

function SceneFreeData:ctor()
	-- body
	SceneFreeData.super.ctor(self)

	self:SetDataType(self.class.SCENE_DATA_TYPE)
	self:SetDataStructParams(SceneFreeDataStruct)
end

function SceneFreeData:ExtendData(data_center)
	data_center.m_wServerStatus_ = GS_UG_FREE
	data_center.m_cbSelfChairID_ = FGameDC:getDC():GetMeChairID()
end

function SceneFreeData:DispatchEvent(data_center)
	print("------------------------- > SceneFreeData:DispatchEvent(data_center)")
	data_center:dispatchEvent({name = data_center.SCENE_FREE_EVENT})
end

return SceneFreeData