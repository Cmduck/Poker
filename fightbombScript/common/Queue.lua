--
-- Author: GFun
-- Date: 2017-02-28 15:38:10
--
local Queue = class("Queue")

function Queue:ctor()
	self.num_ = 0
	self.tab_ = {}
end

function Queue:IsQueueEmpty()
	return self.num_ == 0
end

function Queue:GetSize()
	return self.num_
end

function Queue:Enqueue(data)
	self.num_ = self.num_ + 1
	self.tab_[self.num_] = data
end

function Queue:Dequeue()
	local data = self.tab_[1]
	for i = 1, self.num_ do
		self.tab_[i] = self.tab_[i + 1]
	end
	self.num_ = self.num_ - 1
	return data
end