--
-- Author: GFun
-- Date: 2016-12-10 09:16:10
--

local BaseData = class("BaseData")

BaseData.SCENE_DATA_TYPE = "SCENE_DATA"
BaseData.MSG_DATA_TYPE   = "MSG_DATA"
BaseData.SYSTEM_MSG_TYPE = "SYSTEM_MSG"

function BaseData:ctor()
	self.dataIndex_ = -1
	self.dataStructParams_ = {}
end

--设置需要解析的数据类型
function BaseData:SetDataType(str)
	if str == self.class.SCENE_DATA_TYPE then
		self.dataIndex_ = 3
	elseif str == self.class.MSG_DATA_TYPE then
		self.dataIndex_ = 2
	elseif str == self.class.SYSTEM_MSG_TYPE then
		self.dataIndex_ = 1
	else
		error("None Data Type!!!!")
	end
end

--设置解析结构
function BaseData:SetDataStructParams(tab)
	self.dataStructParams_ = tab
end

--GameMsg从2开始  SceneMsg从3 开始
--SystemMsg须自己实现
--处理数据
function BaseData:ProcessMsg(data, data_center)
	--print("原始网络数据:")
	--dump(data)
	for _, tab in ipairs(self.dataStructParams_) do
		for name, value in pairs(tab) do
			if type(value) == "table" then
				self[name] = clone(data[self.dataIndex_])
				data_center[name] = clone(data[self.dataIndex_])
			else
				self[name] = data[self.dataIndex_]
				data_center[name] = data[self.dataIndex_]
			end
			self.dataIndex_ = self.dataIndex_ + 1
		end
	end
	self:ExtendData(data_center)
	--print("当前解析的协议数据:  ------------------------- > [ " .. self.__cname .. " ]")
	--dump(self)
	--dump(data_center)
	self:DispatchEvent(data_center)
end

--数据扩展处理
function BaseData:ExtendData(data_center)

end

--事件分发
function BaseData:DispatchEvent(data_center)

end

return BaseData