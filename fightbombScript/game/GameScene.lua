module(..., package.seeall) 

--------------------------------------------------------------------------
--  游戏管理
--------------------------------------------------------------------------

--头文件
local GlobalVariablePath = "script.fightbombScript.common.GameDefine"
local GlobalFuncPath = "script.fightbombScript.common.Func"

require(GlobalVariablePath)
require(GlobalFuncPath)

local EventProxyEx      = require("script.fightbombScript.common.EventProxyEx")

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
        _G.DataCenter = require("script.fightbombScript.data.DataCenter").new()
        print("初始化DataCenter")
    else
        print("DataCenter未清理")
    end

    if _G.MusicCenter == nil then
        _G.MusicCenter = require("script.fightbombScript.music.MusicCenter").new()
        print("初始化MusicCenter")
    else
        print("MusicCenter未清理")
    end

    if _G.GameLogic == nil then
        _G.GameLogic = require("script.fightbombScript.game.GameLogic").new()
        print("初始化GameLogic")
    else
        print("GameLogic未清理")
    end

    if _G.StateManager == nil then
        _G.StateManager = require("script.fightbombScript.state.stateManager").new()
        print("初始化StateManager")
    else
        print("StateManager未清理")
    end

    if _G.UIManager == nil then
        _G.UIManager = require("script.fightbombScript.ui.UIManager").new()
        print("初始化UIManager")
    else
        print("UIManager未清理")
    end

    if _G.InternetManager == nil then
        _G.InternetManager =  require("script.fightbombScript.Internet.InternetManager").new()
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
    _G.GameLogic = nil
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
    self:ShowVersion()
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
    UIManager:ShowUI("UITopInfo"):onHide()
    UIManager:ShowUI("UIIcon"):setLocalZOrder(1)
end

function GameScene:RegisterUIEvent()
    -- body
    local UIBackground = UIManager:GetUI("UIBackground")
    EventProxyEx.new(UIBackground, self):addEventListener(UIBackground.class.CLICK_EXIT_BTN_EVENET, handler(self, self.ExitGame))
end

function GameScene:BindEvent()
    EventProxyEx.new(DataCenter, self)
        :addEventListener(DataCenter.class.MSG_SCORE_RULE_EVENT, handler(self, self.onNetScoreRule_))       --下发建桌规则
        :addEventListener(DataCenter.class.SCENE_FREE_EVENT, handler(self, self.onNetSceneFree_))
        :addEventListener(DataCenter.class.SCENE_BAO_EVENT, handler(self, self.onNetSceneBao_))
        :addEventListener(DataCenter.class.SCENE_CALL_EVENT, handler(self, self.onNetSceneCall_))
        :addEventListener(DataCenter.class.SCENE_PALYING_EVENT, handler(self, self.onNetScenePlaying_))
        :addEventListener(DataCenter.class.SCENE_CONTINUE_EVENT, handler(self, self.onNetSceneCountinue_))  
end

function GameScene:onNetScoreRule_()
    --如果是房主
    print("TableUser = " .. DataCenter:getTableUser())
    print("MyChairID = " .. DataCenter:getSelfChairID())
    if DataCenter:getTableUser() == DataCenter:getSelfChairID() then
        UIManager:RemoveUI("UICreateRoom")
        UIManager:UpdateUI("UIReady")
    end
    UIManager:UpdateUI("UIBackground")
    UIManager:UpdateUI("UITopInfo")
end

function GameScene:onNetSceneFree_()
    StateManager:SetState(GAME_STATE_WAIT)
    UIManager:UpdateUI("UIBackground")
    local serverType = DataCenter:getServerType()
    if serverType == GAME_GENRE_SCORE then
        print("【建桌模式】")
        --如果没有设置规则
        if not DataCenter:getIsAlreadySetRule() then
            print("【建桌模式__还没有设置规则】")
            local UICreateRoom = UIManager:ShowUI("UICreateRoom")
            EventProxyEx.new(UICreateRoom, self):addEventListener(UICreateRoom.class.CLICK_CLOSE_BTN, handler(self, self.ExitGame))
        else
            UIManager:UpdateUI("UIReady")
        end
    elseif serverType == GAME_GENRE_GOLD then
        UIManager:UpdateUI("UIReady")
    end
    UIManager:UpdateUI("UIIcon")
end

function GameScene:onNetSceneBao_(event)
    StateManager:SetState(GAME_STATE_PLAYING)

    local serverType = DataCenter:getServerType()
    if serverType == GAME_GENRE_SCORE then
        UIManager:UpdateUI("UITopInfo")
    end

    UIManager:UpdateUI("UIBackground")
    UIManager:UpdateUI("UIIcon")
    UIManager:UpdateUI("UIBaoCard")
    UIManager:UpdateUI("UICountDown")

    if DataCenter:getIsDealDismiss() and DataCenter:getSelfChairID() ~= DataCenter:getRequestLeaveUser() then
        UIManager:UpdateUI("UIDismiss", 0)
    end
end

function GameScene:onNetSceneCall_(event)
    StateManager:SetState(GAME_STATE_PLAYING)

    local serverType = DataCenter:getServerType()
    if serverType == GAME_GENRE_SCORE then
        UIManager:UpdateUI("UITopInfo")
    end
    UIManager:UpdateUI("UIBackground")
    UIManager:UpdateUI("UICallCard")
    UIManager:UpdateUI("UIIcon")
    UIManager:UpdateUI("UICountDown")

    if DataCenter:getIsDealDismiss() and DataCenter:getSelfChairID() ~= DataCenter:getRequestLeaveUser() then
        UIManager:UpdateUI("UIDismiss", 0)
    end
end

function GameScene:onNetScenePlaying_(event)
    print("-------------------------------------- > GameScene:onNetScenePlaying_()")
    StateManager:SetState(GAME_STATE_PLAYING)

    local cbTurnCardCount = DataCenter:getPrevOutCardCount()
    local cbTurnCardData = DataCenter:getPrevOutCardData()
    local cbTurnCardUser = DataCenter:getPrevOutUser()
    local bTurnLast = DataCenter:getHandCardCountTab()[cbTurnCardUser + 1] == 0
    
    StateManager:GetCurState():showOtherPlayerOutCard(cbTurnCardData, cbTurnCardCount, cbTurnCardUser, bTurnLast)

    local serverType = DataCenter:getServerType()
    if serverType == GAME_GENRE_SCORE then
        UIManager:UpdateUI("UITopInfo")
    end
    UIManager:UpdateUI("UIIcon")
    UIManager:UpdateUI("UIOutCard")
    UIManager:UpdateUI("UICountDown")
    UIManager:UpdateUI("UIBackground")
    UIManager:UpdateUI("UIOverCard")
    if DataCenter:getIsDealDismiss() and DataCenter:getSelfChairID() ~= DataCenter:getRequestLeaveUser() then
        UIManager:UpdateUI("UIDismiss", 0)
    end
end

function GameScene:onNetSceneCountinue_()
    StateManager:SetState(GAME_STATE_WAIT)
    UIManager:UpdateUI("UIBackground")
    UIManager:GetUI("UIReady"):UpdateReadyStatus()
    UIManager:UpdateUI("UIIcon")

    if DataCenter:getIsDealDismiss() and DataCenter:getSelfChairID() ~= DataCenter:getRequestLeaveUser() then
        UIManager:ShowUI("UIDismiss")
        UIManager:UpdateUI("UIDismiss", 0)
    end
end

-- 回退按钮回调
function GameScene:CBClickBack()
    if StateManager:GetCurStateID() == GAME_STATE_WAIT then
        print("空闲状态点手机返回键")
        local serverType = DataCenter:getServerType()
        if serverType == GAME_GENRE_SCORE then
            --InternetManager:sendDismissTable()
        elseif serverType == GAME_GENRE_GOLD then
            self:ExitGame()
        end
    else
        -- UIManager:ShowUI("UITip"):ShowTip("是否确定退出游戏?", function(bOk)
        --     if bOk == true then
        --         if DataCenter:isCreateTable() then
        --             if DataCenter:getServerStatus() == 0 then
        --                 InternetManager:SendUserHandExit()
        --                 self:dispatchEvent({name = UIBackground.CLICK_EXIT_BTN_EVENET})
        --             else
        --                 UIManager:ShowUI("UIDismiss", 1)
        --             end
        --         else
        --             print(UIBackground.CLICK_EXIT_BTN_EVENET)
        --             self:dispatchEvent({name = UIBackground.CLICK_EXIT_BTN_EVENET})
        --         end 
        --     end
        -- end)
    end
end

function GameScene:ShowVersion()
    local DebugVersion = "2017-5-18"
    local label = display.newTTFLabel({
        text = "version:" .. DebugVersion,
        font = "Arial",
        size = 18,
        color = cc.c3b(255, 255, 255), 
        align = cc.ui.TEXT_ALIGN_LEFT,
        valign = cc.ui.TEXT_VALIGN_TOP,
        dimensions = cc.size(200, 100)
    })
    label:align(display.CENTER, display.width - 80, -10):addTo(self):setLocalZOrder(1000)
end

return GameScene