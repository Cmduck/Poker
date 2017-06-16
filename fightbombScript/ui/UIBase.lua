
module(..., package.seeall) 

--------------------------------------------------------------------------
-- UI -- UI基类
--------------------------------------------------------------------------
local ResCenter = require("script.fightbombScript.ui.ResCenter").new()
local UIBase = class("UIBase", 
    function()
        return display.newNode()
    end)

function UIBase:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:LoadUIConfig()
    self:setNodeEventEnabled(true)
    -- self:addNodeEventListener(cc.NODE_EVENT, function(event)
    --     -- body
    --     if event.name == "cleanup" then
    --         self.removeUIConfig()
    --     end
    -- end)
end

function UIBase:LoadUIConfig()
    -- body
    self.uiConfigTab = ResCenter:getUIConfig(self.__cname)
    dump(self.uiConfigTab)
    if self.uiConfigTab and self.uiConfigTab.plist and self.uiConfigTab.png then
        print("加载" .. self.uiConfigTab.plist)
        print("加载" .. self.uiConfigTab.png)
        display.addSpriteFrames(self.uiConfigTab.plist, self.uiConfigTab.png) 
    end
    if self.uiConfigTab and self.uiConfigTab.json then
        print("加载" .. self.uiConfigTab.json)
        local UINode = cc.uiloader:load(self.uiConfigTab.json)
        self:addChild(UINode)
        self.UINode_ = UINode  
    end

    if self.uiConfigTab and self.uiConfigTab.zorder then
        self:setLocalZOrder(self.uiConfigTab.zorder)
    end  
end

function UIBase:removeUIConfig()
    -- body
    print("--------------------------------".. self.__cname ..":removeUIConfig()----------------------------------")
    if self.uiConfigTab and self.uiConfigTab.plist and self.uiConfigTab.png then
        print("释放" .. self.uiConfigTab.plist)
        print("释放" .. self.uiConfigTab.png)
        display.removeSpriteFramesWithFile(self.uiConfigTab.plist, self.uiConfigTab.png)
    end
    self.uiConfigTab = nil
end

function UIBase:onCleanup()  
    -- body
    self:removeUIConfig()
    -- self:removeAllEventListeners()
    -- self:dumpAllEventListeners()
end

function UIBase:onShow()
    -- body
    print(self.__cname .. ":onShow()")
end


function UIBase:onHide()
    print(self.__cname .. ":onHide()")
end

function UIBase:onUpdate()
    -- body
    print(self.__cname .. ":onUpdate()")
end

function UIBase:onRemove()
    -- body
    print(self.__cname .. ":onRemove()")
end

return UIBase