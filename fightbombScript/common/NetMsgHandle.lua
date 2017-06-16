--
-- Author: GFun
-- Date: 2017-02-28 16:00:41
--
--TODO
local Queue = require("script.common.Queue")
local NetMsgHandle = class("NetMsgHandle")


function NetMsgHandle:ctor()
	self.queue_ = Queue.new()
end

function NetMsgHandle:Receive(co)
	local status, value = coroutine.resume(co)
	print("status = ", status)
	print("value = ", value)
	return status and value or nil 
end

function NetMsgHandle:Send(x)
	coroutine.yield(x)
end