--------------------------------------------------------------------------
-- local ScollMessage = require("script.public.ScollMessage")
-- --创建函数，需要带大小 ,文字,大小,颜色,描边颜色
-- local size = cc.size(360, 50)
-- local lablestr = "创建函数，需要带大小 ,文字,大小,颜色,描边颜色111"
-- local ll = ScollMessage.new(size ,lablestr,32,display.COLOR_WHITE,display.COLOR_BLACK)
-- -- 设置速度。默认为2
-- ll:setSpeed(2)
-- ll:setPosition(cc.p(display.width/2-400,display.height/2))
-- scene:addChild(ll, 20000, 20000) 
--------------------------------------------------------------------------
--工具类定义
local ScollMessage = class("ScollMessage")

function ScollMessage.create()
    local scollMessage = ScollMessage.new()
    return scollMessage
end
----创建层容器   容器的描点是默认(0,0) setClippingEnabled 设置裁剪属性  contentSize大小外的内容不显示
--@param parentNode 父节点   
--@return
function ScollMessage:ctor()
    --初始化数据
    self.scollSysDataTable = {}         --系统公告数组
    self.scollHornDataTable = {}        --喇叭信息数组
    self.parentNode = nil               --滚动条背景父节点
    self.hornSpr = nil                  --喇叭精灵
    self.sysLabelColor = nil            --系统公告颜色
    self.hornLabelColor = nil           --喇叭信息颜色
end
----创建层容器   容器的描点是默认(0,0) setClippingEnabled 设置裁剪属性  contentSize大小外的内容不显示
--@param parentNode 父节点   
--@return
function ScollMessage:CreateLayout(parentNode,hornSpr,position,contentSize)
    if  parentNode:getChildByTag(20002)~=nil then return end
    self.parentNode = parentNode        --滚动条背景父节点
    self.hornSpr = hornSpr
    --创建容器
    self.layout = ccui.Layout:create()
    self.layout:setPosition(position)
    self.layout:setClippingEnabled(true)
    self.layout:setContentSize(contentSize)
    self.layout:setTag(20002)

    parentNode:addChild(self.layout, 20002, 20002)
end

local SCOLL_LABEL_TYPE_SYSTEM   = 1     --系统公告   
local SCOLL_LABEL_TYPE_HORN     = 2     --普通喇叭  

local MOVE_SPEED_LENTH_SECOND   = 100   --每秒移动label长度
----滚动操作
--@param
--@return
function ScollMessage:MoveScollLabel(labelType,lableStr,fontSize,textColor,position)
    --显示背景父节点
    self.parentNode:setVisible(true)
    --获取尾部数据
    local tempLabelStr = nil
    local tempLabelColor = nil
    if labelType == SCOLL_LABEL_TYPE_SYSTEM then
        tempLabelColor = self.sysLabelColor
        tempLabelStr = self.scollSysDataTable[table.getn(self.scollSysDataTable)]
    else
        tempLabelColor = self.hornLabelColor
        tempLabelStr = self.scollHornDataTable[table.getn(self.scollHornDataTable)]
    end
    --创建内容label
    local scrollLabel = display.newTTFLabel({
        text = tempLabelStr,
        size = fontSize,
        color = tempLabelColor,
        align = cc.TEXT_ALIGNMENT_LEFT
    })
    scrollLabel:setPosition(position)
    scrollLabel:setAnchorPoint(0,0.5)
    self.layout:addChild(scrollLabel)

    --计算位移时间   每秒匀速移动100长度
    local layoutWidth = self.layout:getContentSize().width
    local labelWidth = scrollLabel:getContentSize().width
    local moveTtimes = (labelWidth+layoutWidth)/MOVE_SPEED_LENTH_SECOND
    if moveTtimes<5 then moveTtimes = 5 end
    --动作回调
    local function RemoveLabelBack()
        scrollLabel:removeFromParent(true)
        --删除尾部数据
        if labelType == SCOLL_LABEL_TYPE_SYSTEM then
            table.remove(self.scollSysDataTable)
        else
            table.remove(self.scollHornDataTable)
        end
        --优先显示系统公告
        if table.getn(self.scollSysDataTable)>0 then
            self:MoveScollLabel(SCOLL_LABEL_TYPE_SYSTEM,self.scollSysDataTable[table.getn(self.scollSysDataTable)],fontSize,textColor,position)
        elseif table.getn(self.scollHornDataTable)>0 then
            self:MoveScollLabel(SCOLL_LABEL_TYPE_HORN,self.scollHornDataTable[table.getn(self.scollHornDataTable)],fontSize,textColor,position)
        else
            self.parentNode:setVisible(false)
            self:StopHornAction()
        end
    end
    local moveAction = cc.MoveTo:create(moveTtimes,cc.p(-labelWidth,20))
    local seqeune = cc.Sequence:create(moveAction,CCCallFunc:create(RemoveLabelBack))

    scrollLabel:runAction(seqeune)
end

----插入滚动条     系统公告优先显示
--@param labelType 1系统公告 2喇叭 ,lableStr 内容, fontSize字体大小 , textColor 字体颜色 , position 位置 , anchorPoint 描点
--@return
function ScollMessage:InsertScollLabel(labelType,lableStr,fontSize,textColor,position)
    ----系统公告
    if labelType==SCOLL_LABEL_TYPE_SYSTEM then
        self.sysLabelColor = textColor            --系统公告颜色
        --第一次插入
        if table.getn(self.scollHornDataTable)==0 and table.getn(self.scollSysDataTable)==0 then
            --插入新值到顶部
            table.insert(self.scollSysDataTable,1,lableStr)
            self:MoveScollLabel(labelType,lableStr,fontSize,textColor,position)
            self:StartHornAction()
        else
            --插入新值到顶部
            table.insert(self.scollSysDataTable,1,lableStr)
        end
        ----喇叭信息
    else
        self.hornLabelColor = textColor           --喇叭信息颜色
        --第一次插入
        if table.getn(self.scollHornDataTable)==0 and table.getn(self.scollSysDataTable)==0 then
            --插入新值到顶部
            table.insert(self.scollHornDataTable,1,lableStr)
            self:MoveScollLabel(labelType,lableStr,fontSize,textColor,position)
            self:StartHornAction()
        else
            --插入新值到顶部
            table.insert(self.scollHornDataTable,1,lableStr)
        end
    end
end
----开始喇叭动作
--@param
--@return
function ScollMessage:StartHornAction()
	if self.hornSpr==nil then return end
    local frames = {}
	for i = 1, 3 do
        frames[i] = cc.SpriteFrameCache:getInstance():getSpriteFrame("sparrowLZ/laba"..i..".png")
    end
    local animation = cc.Animation:createWithSpriteFrames(frames, 0.5)
    local animate = cc.Animate:create(animation);
    self.hornSpr:runAction(cc.RepeatForever:create(animate))
end
----停止喇叭动作
--@param
--@return
function ScollMessage:StopHornAction()
    if self.hornSpr==nil then return end
    self.hornSpr:stopAllActions()
end

return ScollMessage
