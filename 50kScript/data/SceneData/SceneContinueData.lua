--
-- Author: GFun
-- Date: 2016-11-04 11:36:55
--

local SceneContinueData = class("SceneContinueData")

--与服务端对应的数据结构
local SceneContinueDataStruct = {
		{cbReadyPlayer = {}},
		{lHistoryScore = {}},
	}

function SceneContinueData:ctor(data)
	-- body
	dump(data)
	local dataIndex = 3		--var3开始
	for _, tab in ipairs(SceneContinueDataStruct) do
		for name, value in pairs(tab) do
			if type(value) == "table" then
				self[name] = clone(data[dataIndex])
			else
				self[name] = data[dataIndex]
			end
			dataIndex = dataIndex + 1
		end
	end
	dump(self)
end

return SceneContinueData