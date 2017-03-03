module(..., package.seeall) 
--------------------------------------------------------------------------
-- 网络管理
--------------------------------------------------------------------------
local InternetManager = class("InternetManager")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

function InternetManager:ctor()
    --网络初始化
    self:NetBegin()

    -- 消息ID - 对应处理函数 对照表
    self.m_tblMsgProcessFun = {
            [G_CLOSE_GAME_FRAME]    = handler(self, self.MsgProcessCloseGame),      
            [G_MATCH_INFO]          = handler(self, self.MsgProcessMatchInfo),
            [G_SYSTEM_STRING]       = handler(self, self.MsgProcessSystemString),
            [G_USER_STRING]         = handler(self, self.MsgProcessUserString),
            [G_MATCH_PRIZE]         = handler(self, self.MsgProcessMatchPrize),
            [G_RESET_VIEW]          = handler(self, self.MsgProcessResetView),
            [G_MATCH_CONTINUE]      = handler(self, self.MsgProcessMatchContinue),
            [G_USER_TRUSTEESHIP]    = handler(self, self.MsgProcessTrusteeShip),
            [G_BUGLE_STRING]        = handler(self, self.MsgProcessBugleString),
            [G_GAME_SCENE_STURCT]   = handler(self, self.MsgProcessSceneStruct),
            [G_GAME_SCENE_DATA]     = handler(self, self.MsgProcessSceneData),
            [G_GAME_MSG_STURCT]     = handler(self, self.MsgProcessGameMsgStruct),
            [G_GAME_MSG_DATA]       = handler(self, self.MsgProcessGameMsgData),
            [G_GAME_LOOKON]         = handler(self, self.MsgProcessLookon),
            [G_GAME_INOUT]          = handler(self, self.MsgProcessInOut),
            [G_GAME_USER_SCORE]     = handler(self, self.MsgProcessUserScore),
            [G_GAME_USER_STATUS]    = handler(self, self.MsgProcessUserStatus),
            [G_GAME_ORDER]          = handler(self, self.MsgProcessOrder),
            [G_GAME_UPDATE]         = handler(self, self.MsgProcessUpdate),
            [32]                    = handler(self, self.MsgProcessMusicChat),
    }

end

function InternetManager:NetBegin()
    -- body
    FGameDC:getDC():SetRecMsgGameHandler(handler(self, self.RecInternetMsg))            -- 注册网络事件
end

function InternetManager:NetEnd()
    -- body
    FGameDC:getDC():SetRecMsgGameHandler(handler(self, self.RecInternetMsg), false)     -- 移除网络事件
end

--接收到网络消息
function InternetManager:RecInternetMsg(wCmdID, ...)
    print("InternetManager_RecInternetMsg:")
    print("wCmdID:" .. wCmdID)

    if self.m_tblMsgProcessFun[wCmdID] ~= nil then
        self.m_tblMsgProcessFun[wCmdID](wCmdID, ...)
    else
        log("error, InternetManager:RecInternetMsg unknow wCmdID!!!!!!!!!!!!!!!!!!!!!!!!!")
    end

    return true
end

-- 消息处理 - 关闭游戏
function InternetManager:MsgProcessCloseGame(wCmdID,Var1,Var2,Var3,Var4,Var5,Var6,Var7,Var8,...)
    print("NET【G_CLOSE_GAME_FRAME】")
    --提示关闭 3手动 2被T出 1网络数据处理失败
    local nTypeClose=Var1;
    cclog("nTypeClose:::"..nTypeClose);
        
    --被T出原因
    if(nTypeClose==2)then
        local szResultDescribe=Var2;       
        --显示消息
        if(szResultDescribe~="")then
           UIManager:ShowUI("UITip"):ShowTip(szResultDescribe, function()
               -- body
               GameScene:ExitGame()
           end)
        end

    --1网络数据处理失败
    elseif(nTypeClose==1)then
        UIManager:ShowUI("UITip"):ShowTip("由于网络数据处理失败,断开连接!", function()
               -- body
            GameScene:ExitGame()
       end)
    else
        GameScene:ExitGame() 
    end
end

-- 消息处理 - 比赛信息
function InternetManager:MsgProcessMatchInfo(wCmdID,Var1,Var2,Var3,Var4,Var5,Var6,Var7,Var8,...)
    print("NET【G_MATCH_INFO】")

end

-- 消息处理 - 系统信息
function InternetManager:MsgProcessSystemString(wCmdID,Var1,Var2,Var3,Var4,Var5,Var6,Var7,Var8,...)
    print("NET【G_SYSTEM_STRING】")
    local pszString=Var1;
    print("G_SYSTEM_STRING: " .. pszString)
 
    --定义参数
    local pszString=Var1;
    local FontSize=Var2;
    local wMessageType=Var3;

    -- 聊天对话框消息
    -- UIManager:ShowUI("UIChat"):AddChat(pszString, cc.c3b(255,0,0))
    -- --弹出判断
    if (bit.band(wMessageType,SMT_EJECT)~=0)then 
        UIManager:ShowUI("UITip"):ShowTip(pszString, nil)
    end
    print("【系统消息】类型 = " .. wMessageType)
    if wMessageType == SMT_INFO or wMessageType == SMT_SCROLL then
        local SCOLL_LABEL_TYPE_SYSTEM = 1
        UIManager:ShowUI("UIScrollMsg"):InsertScollLabel(SCOLL_LABEL_TYPE_SYSTEM,pszString,25,cc.c3b(255,148,22),cc.p(400,20))
    end
end

-- 消息处理 - 聊天信息
function InternetManager:MsgProcessUserString(wCmdID,Var1,Var2,Var3,Var4,Var5,Var6,Var7,Var8,...)
    print("NET【G_USER_STRING】")
    --定义参数
    local pszSendName=Var1;
    local pszRecvName=Var2;
    local pszString=Var3;
    local crColor=Var4;
    local uSize=Var5;
    local bManager=Var6;
    local bMember=Var7;
        
    --自己名字
    local GlobalUserData=FGameDC:getDC():GetUserDataPlaza();
    local strName=FGameDC:getDC():UnicodeToUtf8(GlobalUserData.szAccounts[0]);
    
    --信息整理
    local tb = {};
    local Colc3b=cc.c3b(186,186,186);
    if(bManager)then
        tb[1]="[管理员]"
        Colc3b=cc.c3b(255,0,0);
    elseif(bMember)then
        tb[1]="[会员]"
    elseif(strName==pszSendName)then
        tb[1]="";
        Colc3b=cc.c3b(0,223,243);
    else
        tb[1]=""
    end
        
    --交谈目标
    tb[2]="["..pszSendName.."]说:"
    if(pszRecvName~="")then
        tb[2]="["..pszSendName.."]对["..wMessageType.."]说:"
    end
        
    --交谈内容
    tb[3]=pszString
    --插入信息 
    -- UIManager:ShowUI("UIChat"):AddRichChat(tb, Colc3b)
    -- UIManager:ShowUI("UISysScroll"):InsertScollLabel(SCOLL_LABEL_TYPE_HORN,pszString,25,cc.c3b(244,255,123),cc.p(400,20)) 
end

-- 消息处理 - 奖励信息
function InternetManager:MsgProcessMatchPrize(wCmdID,Var1,Var2,Var3,Var4,Var5,Var6,Var7,Var8,...)
    print("NET【G_MATCH_PRIZE】")
    --房间信息
    local ServerTag=FGameDC:getDC():GetCurServerItem()
    local strServerName=FGameDC:getDC():UnicodeToUtf8(ServerTag.szServerName[0]);
    local pUserData=FGameDC:getDC():GetUserInfo(self:GetMeChairIDEx());
    local strName=FGameDC:getDC():UnicodeToUtf8(pUserData.szAccount[0]);

    --奖励数据处理
    local matchPrizeMs = {}
    matchPrizeMs.wOrder         = Var1 --比赛名次
    matchPrizeMs.lMedalCount    = Var2 --奖牌数目
    matchPrizeMs.lGold          = Var3 --游戏币数目
    matchPrizeMs.lExperience    = Var4 --经验数目
    matchPrizeMs.wChampionCount = Var5 --总冠军次数(包含当前)
    matchPrizeMs.szTipMessage   = Var6 --获奖信息
    matchPrizeMs.szServerName   = strServerName --房间名称
    matchPrizeMs.pUserName      = strName

    local gameRewardClass = require("script.public.GameRewardLayer")
    local gameReward = gameRewardClass.create()
    gameReward:ShowMatchPrize(matchPrizeMs) -- 显示奖状信息
end

-- 消息处理 - 清理信息
function InternetManager:MsgProcessResetView(wCmdID, ...)
    print("NET【G_RESET_VIEW】")
    --UIManager:GetUI("UIIcon"):UpdateUI()
end

-- 消息处理 - 比赛继续
function InternetManager:MsgProcessMatchContinue(wCmdID, ...)
    print("NET【G_MATCH_CONTINUE】")
end

-- 消息处理 - 托管信息
function InternetManager:MsgProcessTrusteeShip(wCmdID, ...)
    print("NET【G_USER_TRUSTEESHIP】")
    local argEx = {...}
    dump(argEx, "托管数据")
    DataCenter:initSystemMsgData(wCmdID, argEx)
end

-- 消息处理 - 啦叭信息
function InternetManager:MsgProcessBugleString(wCmdID,Var1,Var2,Var3,Var4,Var5,Var6,Var7,Var8,...)
    print("NET【G_BUGLE_STRING】")
    --定义参数
    local pszSendName=Var1;
    local pszString=Var2;
    local crColor=Var3;
    local uSize=Var4;
    local bManager=Var5;
        
    --自己名字
    local GlobalUserData=FGameDC:getDC():GetUserDataPlaza();
    local strName=FGameDC:getDC():UnicodeToUtf8(GlobalUserData.szAccounts[0]);
    
    --信息整理
    local tb = {};
    local Colc3b=cc.c3b(186,186,186);
    tb[1]=display.newSprite("#dating/huodong.png");
    if(strName==pszSendName)then
        Colc3b=cc.c3b(0,223,243);
    end
        
    --交谈目标
    tb[2]="["..pszSendName.."]:"
        
    --交谈内容
    tb[3]=pszString
        
    --插入信息
    --聊天控件
    --UIManager:ShowUI("UIChat"):AddRichChat(tb, Colc3b)
end

-- 消息处理 - 场景结构体
function InternetManager:MsgProcessSceneStruct(wCmdID, ...)
    print("NET【G_GAME_SCENE_STURCT】")
    print("wCmdID:" .. wCmdID)
    local argEx={...}
    -- local pStrParse = DataCenter:getSceneMsgParseStr(argEx[1])
    -- FGameDC:getDC():SetStructData(pStrParse)

    local pStrParse = DataCenter:getSceneMsgParseStr(argEx[1])
    FGameDC:getDC():SetStructData(pStrParse)
end

-- 消息处理 - 场景数据
function InternetManager:MsgProcessSceneData(wCmdID, ...) 
    print("NET【G_GAME_SCENE_DATA】")
    print("wCmdID:" .. wCmdID)
    local argEx={...}
    DataCenter:initSceneData(argEx)
end

-- 消息处理 - 游戏信息结构体
function InternetManager:MsgProcessGameMsgStruct(wCmdID, ...)
    print("NET【G_GAME_MSG_STURCT】")
    print("wCmdID:" .. wCmdID)
    local argEx={...}
    local pStrParse = DataCenter:getGameMsgParseStr(argEx[1])
    FGameDC:getDC():SetStructData(pStrParse)
end

-- 消息处理 - 游戏信息结果
function InternetManager:MsgProcessGameMsgData(wCmdID, ...)
    print("NET【G_GAME_MSG_DATA】")
    print("wCmdID:" .. wCmdID)

    local argEx={...}
    DataCenter:initGameMsgData(argEx)
end

-- 消息处理 - 旁观信息
function InternetManager:MsgProcessLookon(wCmdID, ...)
    print("NET【G_GAME_LOOKON】")
end

-- 消息处理 - 进出信息
function InternetManager:MsgProcessInOut(...)
    print("NET【G_GAME_INOUT】")
    print("玩家进出消息")

    if StateManager:GetCurStateID() ~= GAME_STATE_CLEARING then
        UIManager:UpdateUI("UIIcon")
        --UIManager:GetUI("UIIcon"):RecMsgGotyeapiHandlerEx(...)
    end
end

-- 消息处理 - 分数信息
function InternetManager:MsgProcessUserScore(wCmdID, ...)
    print("NET【G_GAME_USER_SCORE】")
end

-- 消息处理 - 状态信息
function InternetManager:MsgProcessUserStatus(wCmdID, ...)  
    print("NET【G_GAME_USER_STATUS】")
    print("玩家状态消息")
    --dump(FGameDC:getDC():GetUserInfo(GetSelfChairID()).cbUserStatus)
    if StateManager:GetCurStateID() ~= GAME_STATE_CLEARING then
        UIManager:UpdateUI("UIIcon")
    end
    if StateManager:GetCurStateID() == GAME_STATE_WAIT then
        UIManager:UpdateUI("UIReady")
    end
end

-- 消息处理 - 排名信息
function InternetManager:MsgProcessOrder(wCmdID, ...)
    print("NET【G_GAME_ORDER】")
end

-- 消息处理 - 更新信息
function InternetManager:MsgProcessUpdate(wCmdID, ...)
    print("NET【G_GAME_UPDATE】")
end

-- 消息处理 - 音乐聊天
function InternetManager:MsgProcessMusicChat(...)
    print("系统聊天消息:")
    local paramsAll = {...}

    local params = {}
    for i = 2 , #paramsAll do
        params[i-1] = paramsAll[i]
    end

    print("声音dwUserID.........."..params[1])
    print("声音dwTargetUserID.........."..params[2])
    print("声音dwUserID.........."..params[3])

    -- 声音
    local pUIMusic = UIManager:GetUI("UIMusicChat")
    local nChairID = GetChairIdByUserId(params[1])
    pUIMusic:playSound(params[3], SexIsMan(nChairID))

    local pStr = pUIMusic:GetContentById(params[3])

    -- 气泡
    UIManager:ShowUI("UIChatBubble")
    local pUIBubble = UIManager:GetUI("UIChatBubble")
    pUIBubble:SetShow(GetDirection(nChairID), pStr)
end

-- 发送准备消息
function InternetManager:SendUserReady(nScore)
    FGameDC:getDC():SendUserReady(nil, 0)
end

--点继续游戏后的准备
function InternetManager:SendContinueGameReady()
    -- body
    FGameDC:getDC():SendGameMsg(SUB_C_STARTGAME, "")
end

--发送叫牌
function InternetManager:sendCallCard(cardData)
    local strMsg = "BYTE, 1, " .. cardData[1] .. ","
    FGameDC:getDC():SendGameMsg(SUB_C_CALL_CARD, strMsg)
end

--发送吼牌
function InternetManager:sendHouCard(bHouCard)
    -- body
    local strMsg = "bool, 1, " .. (bHouCard and 1 or 0) .. ","
    FGameDC:getDC():SendGameMsg(SUB_C_HOU_CARD, strMsg)
end

--发送pass消息
function InternetManager:sendPassCard()
    -- body
    FGameDC:getDC():SendGameMsg(SUB_C_PASS_CARD, "")
end

--发送出牌消息
function InternetManager:sendOutCard(cardsData, cardsCount)
    -- body
    --local cbCardCount = #cardsData
    local strMsg = "BYTE, 1," .. cardsCount .. ","
    for i = 0, cardsCount - 1 do
        strMsg = strMsg .. "BYTE, 1," .. cardsData[i] .. ","
    end
    print("InternetManager:sendOutCard:->~~~~~~~~~~~ strMsg = " .. strMsg)
    FGameDC:getDC():SendGameMsg(SUB_C_OUT_CARD, strMsg)
end

function InternetManager:SetTrusteeship(bTrusteeship)
    local strMsg = "bool, 1, " .. (bTrusteeship and 1 or 0) .. ","
    FGameDC:getDC():SendGameMsg(SUB_C_TRUSTEESHIP, strMsg)
end

--发送规则设置
function InternetManager:sendScoreRule(inningNum, planeNum)
    -- body
    local str = "BYTE, 1, " .. inningNum .. ", BYTE, 1," .. planeNum .. ","
    FGameDC:getDC():SendGameMsg(SUB_C_SCORE_RULE, str)
end

--发送解散消息
function InternetManager:sendDismissTable(chairId)
    -- body
    local str = "BYTE, 1," .. chairId .. ","
    FGameDC:getDC():SendGameMsg(SUB_C_TABLEDISMISS, str)
end

--发送请求离开消息
function InternetManager:sendRequestLeave(strPrompt)
    -- body
    local nLen=string.len(strPrompt)
    FGameDC:getDC():SendGameMsg(SUB_C_REQUEST_LEAVE,"wchar,"..nLen..","..strPrompt..",");
end

--发送确认解散消息
function InternetManager:SendConfirmDismiss(bConfirm, nDismissUserID)
    -- body
    local nConfirm = bConfirm == true and 1 or 0
    FGameDC:getDC():SendGameMsg(SUB_C_RESPONSES_LEAVE, "WORD,1," .. nDismissUserID .. ",BYTE,1," .. nConfirm .. ",")
end

--发送用户手动退出消息
function InternetManager:SendUserHandExit()
    FGameDC:getDC():SendGameMsg(SUB_C_LEAVEGAME, "")
end

function InternetManager:SendRequestTotalAccount()
    -- body
    FGameDC:getDC():SendGameMsg(SUB_C_REQUEST_TOTAL_ACCOUNT, "")
end

return InternetManager