
local StateBase = class("StateBase", 
	function()
        return display.newNode()
    end)

function StateBase:ctor(scene)
	-- body
    --cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	self.StateID_ = 0
	self.scene_ = scene
	self:BindEvent()
end

function StateBase:getStateID()
	-- body
	return self.StateID_
end

function StateBase:StateBegin()
	-- body
end

function StateBase:StateEnd()
	-- body
end

function StateBase:LoadUIComponent()
end

function StateBase:RegisterUIEvent()
end  

function StateBase:BindEvent()

end

return StateBase
