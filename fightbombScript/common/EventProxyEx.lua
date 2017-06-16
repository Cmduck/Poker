
local EventProxyEx = class("EventProxyEx")

function EventProxyEx:ctor(eventDispatcher, view)
    self.eventDispatcher_ = eventDispatcher
    self.handles_ = {}

    if view then
        cc(view):addNodeEventListener(cc.NODE_EVENT, function(event)
            if event.name == "exit" then
                self:removeAllEventListeners()
            end
        end)
    end
end

function EventProxyEx:addEventListener(eventName, listener, data)
    local handle = self.eventDispatcher_:addEventListener(eventName, listener, data)
    self.handles_[#self.handles_ + 1] = {eventName, handle}
    return self, handle
end

function EventProxyEx:removeEventListener(eventHandle)
    self.eventDispatcher_:removeEventListener(eventHandle)
    for index, handle in pairs(self.handles_) do
        if handle[2] == eventHandle then
            table.remove(self.handles_, index)
            break
        end
    end
    return self
end

function EventProxyEx:removeAllEventListenersForEvent(eventName)
    for key, handle in pairs(self.handles_) do
        if handle[1] == eventName then
            self.eventDispatcher_:removeEventListenersByEvent(eventName)
            self.handles_[key] = nil
        end
    end
    return self
end

function EventProxyEx:getEventHandle(eventName)
    for key, handle in pairs(self.handles_) do
        if handle[1] == eventName then
            return handle[2]
        end
    end
end

function EventProxyEx:removeAllEventListeners()
    for _, handle in pairs(self.handles_) do
        if self.eventDispatcher_ and self.eventDispatcher_.removeEventListener then
            self.eventDispatcher_:removeEventListener(handle[2])
        end
    end
    self.handles_ = {}
    return self
end

return EventProxyEx
