module(..., package.seeall) 

--------------------------------------------------------------------------
--  游戏管理
--------------------------------------------------------------------------

--头文件
local GlobalVariablePath = "script.50kScript.common.GameDefine"
local GlobalFuncPath = "script.50kScript.common.Func"

require(GlobalVariablePath)
require(GlobalFuncPath)

local EventProxyEx      = require("script.50kScript.common.EventProxyEx")
local MusicCenter       = require("script.50kScript.music.MusicCenter")

local room              = require("script.plaza.room")
local room_match        = require("script.plaza.room_match")

-- 游戏管理场景

local w = display.sizeInPixels.width
local h = display.sizeInPixels.height

local GameScene = class("GameScene", function()
        -- body
    return display.newNode()
    end)

function GameScene:ctor()
    --MusicCenter:LoadBGMuisc()
    self:setContentSize(display.width, display.height)
    self:setNodeEventEnabled(true)
end

function GameScene:onCleanup()
    self:DestroyGlobalVariable()
end

function GameScene:InitGlobalVariable()
    -- body
    if _G.DataCenter == nil then
        _G.DataCenter = require("script.50kScript.data.DataCenter").new()
        print("初始化DataCenter")
    else
        print("DataCenter未清理")
    end
    if _G.StateManager == nil then
        _G.StateManager = require("script.50kScript.state.stateManager").new()
        print("初始化StateManager")
    else
        print("StateManager未清理")
    end

    if _G.UIManager == nil then
        _G.UIManager = require("script.50kScript.ui.UIManager").new()
        print("初始化UIManager")
    else
        print("UIManager未清理")
    end

    if _G.InternetManager == nil then
        _G.InternetManager =  require("script.50kScript.Internet.InternetManager").new()
        print("初始化InternetManager")
    else
        print("InternetManager未清理")
    end
end

function GameScene:DestroyGlobalVariable()
    -- body
    _G.DataCenter:Destroy()
    _G.DataCenter = nil
    _G.StateManager:Destroy()
    _G.StateManager = nil
    _G.UIManager:Destroy()
    _G.UIManager = nil
    _G.InternetManager:NetEnd()
    _G.InternetManager = nil

    package.loaded[GlobalVariablePath] = nil 
    package.loaded[GlobalFuncPath] = nil
end

-- 游戏入口
function GameScene:EnterGame()
    print("-----------------------------GameScene:EnterGame()---------------------------------")
    
    self:InitGlobalVariable()
    local scene = cc.Director:getInstance():getRunningScene() -- 添加到场景
    scene:addChild(self)
    UIManager:InitUiManager(self)
    StateManager:InitStateManager(self)
    self:setTag(TAG_GAME)
    --MusicCenter:PlayBGMusic()
    self:BindEvent()
    self:LoadUIComponent()
    self:RegisterUIEvent()

    StateManager:SetState(GAME_STATE_WAIT)--StateManager:SetState(GAME_STATE_PLAYING)--StateManager:SetState(GAME_STATE_WAIT)
end

-- 游戏出口
function GameScene:ExitGame(event)
    if event ~= nil then
        print("从点击了UIbackground的退出按钮!")
    end
    --MusicCenter:StopBGMusic()
    self:removeSelf()
    --self:DestroyGlobalVariable()

    --显示房间
    if(self.m_wServerType == GAME_GENRE_MATCH)then
        local str=FGameDC:getDC():IsCanQuit()
        if(self.m_nReturnNum ~= 0 and str=="") then -- 不为零表示网络断开
            room_match.OnExitUI(true)
        else
            room_match.OnReturnFuc()
        end
    else
        room.OnReturnFuc()
    end
    _G.GameScene = nil
end

function GameScene:LoadUIComponent()
    -- body
    UIManager:ShowUI("UIBackground")
    --UIManager:ShowUI("UITopInfo")
    --UIManager:ShowUI("UICreateRoom"):onHide()   
end

function GameScene:RegisterUIEvent()
    -- body
    local UIBackground = UIManager:GetUI("UIBackground")
    EventProxyEx.new(UIBackground, self):addEventListener(UIBackground.class.CLICK_EXIT_BTN_EVENET, handler(self, self.ExitGame))

    -- local UICreateRoom = UIManager:GetUI("UICreateRoom")
    -- EventProxyEx.new(UICreateRoom, self):addEventListener(UICreateRoom.class.CLICK_CLOSE_BTN, handler(self, self.ExitGame))
    -- UICreateRoom:setLocalZOrder(100)
end

function GameScene:BindEvent()
    EventProxyEx.new(DataCenter, self)
        :addEventListener(DataCenter.class.SCENE_FREE_EVENT, handler(self, self.onNetSceneFree_))
        :addEventListener(DataCenter.class.SCENE_HOU_EVENT, handler(self, self.onNetSceneHou_))
        :addEventListener(DataCenter.class.SCENE_PALYING_EVENT, handler(self, self.onNetScenePlaying_))
        :addEventListener(DataCenter.class.SCENE_CONTINUE_EVENT, handler(self, self.onNetSceneCountinue_))  
end

function GameScene:onNetSceneFree_()
    StateManager:SetState(GAME_STATE_WAIT)
    UIManager:GetUI("UIBackground"):UpdateGameInfo()
    UIManager:UpdateUI("UIReady")
end

function GameScene:onNetSceneHou_()
    print("-------------------------------------- > GameScene:onNetSceneHou_()")
    StateManager:SetState(GAME_STATE_PLAYING)
    UIManager:UpdateUI("UIBackground")
    UIManager:UpdateUI("UITopInfo")
    UIManager:UpdateUI("UIHou")
    UIManager:UpdateUI("UICountDown")
end

function GameScene:onNetScenePlaying_()
    print("-------------------------------------- > GameScene:onNetScenePlaying_()")
    StateManager:SetState(GAME_STATE_PLAYING)
    StateManager:GetCurState():showOtherPlayerOutCard()
    UIManager:UpdateUI("UIBackground")
    UIManager:UpdateUI("UITopInfo")
    UIManager:UpdateUI("UIIcon")
    UIManager:UpdateUI("UIOutCard")
    UIManager:UpdateUI("UIOverCard")
    UIManager:UpdateUI("UICountDown")
end

function GameScene:onNetSceneCountinue_()

end

-- 回退按钮回调
function GameScene:CBClickBack()
    if StateManager:GetCurStateID() == GAME_STATE_WAIT then
        print("空闲状态点手机返回键")
        self:ExitGame()
    else

    end
end

return GameScene