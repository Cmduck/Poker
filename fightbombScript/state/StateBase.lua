
local StateBase = class("StateBase", 
	function()
        return display.newNode()
    end)

StateBase.GAME_RES = {

}

function StateBase:ctor(scene)
	-- body
    --cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)
	self.StateID_ = 0
	self.scene_ = scene
	self:BindEvent()
	self:LoadGameRes()
	self:LoadUIComponent()
	self:RegisterUIEvent()
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

--加载UI控件
function StateBase:LoadUIComponent()
end

--注册控件事件
function StateBase:RegisterUIEvent()

end  

--注册网络事件
function StateBase:BindEvent()

end

--加载资源
function StateBase:LoadGameRes()
	for k, v in pairs(self.GAME_RES) do
		print("Loading Res---------------------->" .. k .. ".plist, " .. k .. ".png")
		display.addSpriteFrames(v.plist, v.png)
	end
end

--释放资源
function StateBase:RemoveGameRes()
	for k, v in pairs(self.GAME_RES) do
		print("Remove Res---------------------->" .. k .. ".plist, " .. k .. ".png")
		display.removeSpriteFramesWithFile(v.plist, v.png)
	end
end

function StateBase:onCleanup()  
    -- body
    self:RemoveGameRes()
end

return StateBase
