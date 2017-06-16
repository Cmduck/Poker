--
-- Author: GFun
-- Date: 2017-04-07 16:58:48
--

local UIBase = require("script.fightbombScript.ui.UIBase")
local UISelectMain = class("UISelectMain", UIBase)
local ActionHelper = require("script.fightbombScript.common.ActionHelper")

UISelectMain.CLICK_SELECT_MAIN_EVENT = "CLICK_SELECT_MAIN_EVENT"

function UISelectMain:ctor()
    UISelectMain.super.ctor(self)
    self.colorIndex_ = 0  
end

function UISelectMain:onShow()
	-- body
	local nameTab = {"btn_color_0", "btn_color_1", "btn_color_2", "btn_color_3"}
	local directionTab = {"color_node_down", "color_node_right", "color_node_up", "color_node_left"}
    for i, v in ipairs(nameTab) do
    	self[v] = cc.uiloader:seekNodeByName(self.UINode_, v)
    	self[v]:onButtonClicked(handler(self, self.clickSelectMainBtn))
    	self[v]:setTag(i - 1)
    	self[v]:setVisible(false)
    end

    for i, v in ipairs(directionTab) do
    	self[v] = cc.uiloader:seekNodeByName(self.UINode_, v)
    	self[v]:setVisible(false)
    end

end

function UISelectMain:onHide()
    -- body
    self:setVisible(false)
end

function UISelectMain:onUpdate()
    local banker_user = DataCenter:getBankerUser()
    local bSelectColor = DataCenter:getIsSelectColor()
    local my_chairId = DataCenter:getSelfChairID()

    print("main_color = ", main_color)
    print("current_user = ", banker_user)
    self["btn_color_0"]:setVisible(not bSelectColor and my_chairId == banker_user)
    self["btn_color_1"]:setVisible(not bSelectColor and my_chairId == banker_user)
    self["btn_color_2"]:setVisible(not bSelectColor and my_chairId == banker_user)
    self["btn_color_3"]:setVisible(not bSelectColor and my_chairId == banker_user) 

    -- if main_color ~= -1 then
    --     local directionTab = {"color_node_down", "color_node_right", "color_node_up", "color_node_left"}
    --     local sprite_name = "#fangkuaizhu.png"
    --     if main_color == 0 then
    --         sprite_name = "#fangkuaizhu.png"
    --     elseif main_color == 1 then
    --         sprite_name = "#taohuazhu.png"
    --     elseif main_color == 2 then
    --         sprite_name = "#hongtaozhu.png"
    --     else
    --         sprite_name = "#heitaozhu.png"
    --     end
    --     --获取当前玩家的位置
    --     local directionNodeName = directionTab[GetDirection(banker_user) + 1]
    --     print("directionNodeName = ", directionNodeName)
    --     self[directionNodeName]:setVisible(true)
    --     local sprite = display.newSprite(sprite_name)
    --     sprite:addTo(self[directionNodeName])
    -- end
end

function UISelectMain:onRemove()
    -- body
    self:removeSelf()
end

function UISelectMain:getColorIndex()
	return self.colorIndex_
end

function UISelectMain:clickSelectMainBtn(event)
	dump(event)
	print("Tag = ", event.target:getTag())
	self.colorIndex_ = event.target:getTag()
	self:dispatchEvent({name = UISelectMain.CLICK_SELECT_MAIN_EVENT})
end

return UISelectMain