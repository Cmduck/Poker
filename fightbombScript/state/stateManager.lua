module(..., package.seeall) 

--------------------------------------------------------------------------
-- 状态机
--------------------------------------------------------------------------
-- 状态ID
local STATE_WAIT          = 1      -- 等待
local STATE_PLAYING       = 2      -- 正在玩过程中
local STATE_CLEARING      = 3      -- 结算

local StateWait     = require("script.fightbombScript.state.StateWait")
local StatePlaying  = require("script.fightbombScript.state.StatePlaying")
local StateClearing = require("script.fightbombScript.state.StateClearing")
-- 状态机
local StateManager  = class("StateManager")

function StateManager:ctor()
    -- 状态列表初始化
    self.curState_      = nil
    self.curStateID_    = -1
end

function StateManager:InitStateManager(scene)
    -- body
    self.scene_ = scene
end

function StateManager:SetState(stateId)
    -- body
    if stateId == self.curStateID_ then
        return 
    else
        self.curStateID_ = stateId
        if self.curState_ then
            self.curState_:StateEnd()
        end
        if self.curStateID_ == STATE_WAIT then
            self.curState_ = StateWait.new(self.scene_)
        elseif self.curStateID_ == STATE_PLAYING then
            self.curState_ = StatePlaying.new(self.scene_)
        elseif self.curStateID_ == STATE_CLEARING then
            self.curState_ = StateClearing.new(self.scene_)
        else
            error("StateManager_SetState:----------> None State!")
            return
        end
        print("当前的状态机是:" .. self.curStateID_)
        self.curState_:addTo(self.scene_)
        self.curState_:StateBegin()
    end
end

function StateManager:GetCurState()
    -- body
    return self.curState_
end

function StateManager:GetCurStateID()
    -- body
    return self.curStateID_
end

function StateManager:Destroy()
    -- body
    self.curState_ = nil
    self.curStateID_ = -1
end

return StateManager