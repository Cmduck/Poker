module(..., package.seeall) 
--------------------------------------------------------------------------
-- 包含文件
local UIRegistry = require("script.50kScript.ui.UIRegistry").new()

-- UI管理
local UIManager = class("UIManager")

function UIManager:ctor()
    UIRegistry:RegisterAllUI()
    self.m_tabUI = {}
    self.m_tabShowUI = {}
end

function UIManager:InitUiManager(scene)
    -- body
    self.scene_ = scene
end

function UIManager:LoadUI(uiname)
    -- body
    if self.m_tabUI[uiname] == nil then
        self.m_tabUI[uiname] = UIRegistry:getUIClassTab(uiname).new()  
    end
    self.m_tabUI[uiname]:setVisible(false)
    self.m_tabUI[uiname]:addTo(self.scene_)
    self.m_tabShowUI[uiname] = false 
end

function UIManager:ShowUI(uiname, ...)
    if self.m_tabUI[uiname] then
        self.m_tabUI[uiname]:setVisible(true)
        return self.m_tabUI[uiname] 
    end
    if self.m_tabUI[uiname] == nil then
        self.m_tabUI[uiname] = UIRegistry:getUIClassTab(uiname).new()  
    end
    self.m_tabUI[uiname]:addTo(self.scene_)
    self.m_tabShowUI[uiname] = true
    print("UIManager:-> ---------------------------------" .. uiname .. ":onShow()")
    self.m_tabUI[uiname]:onShow(...)    

    return self.m_tabUI[uiname]   
end

function UIManager:HideUI(uiname)
    if self.m_tabShowUI[uiname] ~= nil then
        self.m_tabShowUI[uiname] = false
        print("UIManager:-> ---------------------------------" .. uiname .. ":onHide()")
        self.m_tabUI[uiname]:onHide()
    else
        print("None UI -> " .. uiname .. ":onHide()")
    end
    return self.m_tabUI[uiname] 
end

function UIManager:GetUI(uiname)
    -- body
    if self.m_tabUI[uiname] == nil then
        print("None UI! ->" .. uiname)
    end
    return self.m_tabUI[uiname]
end

function UIManager:RemoveUI(uiname)
    -- body
    if self.m_tabUI[uiname] ~= nil then
        self.m_tabUI[uiname]:onRemove()
        self.m_tabUI[uiname] = nil
        self.m_tabShowUI[uiname] = nil
    else
        print("UIManager:-> ---------------------------------" .. uiname .. ":onRemove()")
    end
end

function UIManager:UpdateUI(uiname, ...)
    -- body
    if self.m_tabUI[uiname] ~= nil then
        print("UIManager:-> ---------------------------------" .. uiname .. ":onUpdate()")
        self.m_tabUI[uiname]:onUpdate(...)
    else
        print("None UI -> " .. uiname .. ":onUpdate()")
    end
end

function UIManager:Destroy()
    -- body
    self.m_tabUI = {}
    self.m_tabShowUI = {}
end

return UIManager