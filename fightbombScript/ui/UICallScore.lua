--
-- Author: GFun
-- Date: 2017-04-07 15:38:18
--
local UIBase = require("script.fightbombScript.ui.UIBase")
local UICallScore = class("UICallScore", UIBase)
local ActionHelper = require("script.fightbombScript.common.ActionHelper")

UICallScore.CLICK_CALL_SCORE_EVENT = "CLICK_CALL_SCORE_EVENT"

function UICallScore:ctor()
    UICallScore.super.ctor(self)
    self.scoreIndex_ = 0  
end

function UICallScore:onShow()
	-- body
	local nameTab = {"btn_callscore_1", "btn_callscore_2", "btn_callscore_3", "btn_callscore_4", "btn_callscore_5"}
	local directionTab = {"call_result_down", "call_result_right", "call_result_up", "call_result_left"}
    for i, v in ipairs(nameTab) do
    	self[v] = cc.uiloader:seekNodeByName(self.UINode_, v)
    	self[v]:onButtonClicked(handler(self, self.clickCallScoreBtn))
    	self[v]:setTag(i)
    	self[v]:setVisible(false)
    end
    self["btn_nocall"] = cc.uiloader:seekNodeByName(self.UINode_, "btn_nocall")
    self["btn_nocall"]:setTag(255)
    self["btn_nocall"]:onButtonClicked(handler(self, self.clickCallScoreBtn))
    self["btn_nocall"]:setVisible(false)

    for i, v in ipairs(directionTab) do
    	self[v] = cc.uiloader:seekNodeByName(self.UINode_, v)
    	self[v]:setVisible(false)
    end

end

function UICallScore:onHide()
    -- body
    self:setVisible(false)
end

function UICallScore:onUpdate()
    self:showBtn()
    self:showScore()
end

function UICallScore:showBtn()
    local current_index = DataCenter:getCurScoreIndex()
    local limit_index = DataCenter:getLimitIndex()
    local bShow = DataCenter:getCurrentUser() == DataCenter:getSelfChairID() and DataCenter:getServerStatus() == GS_UG_CALLSCORE

    print("@@@@@@@@@@@@@@@@@@")
    print("@@@@@@@@@@@@@@@@@@")
    print("current_index = ", current_index)

    for i = 1, 5 do
        local btn_name = string.format("btn_callscore_%d", i)
        self[btn_name]:setVisible(bShow)
        if i <= current_index or i > limit_index then
            self[btn_name]:setColor(cc.c3b(96,96,96))
            self[btn_name]:setTouchEnabled(false)
        else
            self[btn_name]:setColor(cc.c3b(255,255,255))
            self[btn_name]:setTouchEnabled(true)
        end
    end
    self["btn_nocall"]:setVisible(bShow)
end

function UICallScore:showScore()
    local directionTab = {"call_result_down", "call_result_right", "call_result_up", "call_result_left"}
    local score_info = DataCenter:getCallScoreInfo()
    local current_user = DataCenter:getCurrentUser()
    local my_chairId = DataCenter:getSelfChairID()

    self["btn_nocall"]:setVisible(current_user == my_chairId)
    self["btn_callscore_1"]:setVisible(current_user == my_chairId)
    self["btn_callscore_2"]:setVisible(current_user == my_chairId)
    self["btn_callscore_3"]:setVisible(current_user == my_chairId)
    self["btn_callscore_4"]:setVisible(current_user == my_chairId)
    self["btn_callscore_5"]:setVisible(current_user == my_chairId)
    for i = 0, GAME_PLAYER - 1 do
        local directionNodeName = directionTab[GetDirection(i) + 1]
        local score_index = score_info[i + 1]
        --0为 未操作
        if score_index ~= 0 then
            local sprite_name = ""
            if score_index == 255 then
                --不叫
                sprite_name = "#bujiao.png"
            elseif score_index == 1 then
                sprite_name = "#score_1.png"
            elseif score_index == 2 then
                sprite_name = "#score_2.png"
            elseif score_index == 3 then
                sprite_name = "#score_3.png"
            elseif score_index == 4 then
                sprite_name = "#score_4.png"
            elseif score_index == 5 then
                sprite_name = "#score_5.png"
            else
                assert(false, "不存在的叫分!")
            end
            self[directionNodeName]:removeAllChildren()
            self[directionNodeName]:setVisible(true)
            local sprite = display.newSprite(sprite_name)
            sprite:addTo(self[directionNodeName])
        else
            self[directionNodeName]:setVisible(false)
        end
    end
end

function UICallScore:onRemove()
    -- body
    self:removeSelf()
end

function UICallScore:getScoreIndex()
	return self.scoreIndex_
end

function UICallScore:clickCallScoreBtn(event)
	print("Tag = ", event.target:getTag())
	self.scoreIndex_ = event.target:getTag()
	self:dispatchEvent({name = UICallScore.CLICK_CALL_SCORE_EVENT})
end

return UICallScore