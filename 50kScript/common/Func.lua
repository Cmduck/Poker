module(..., package.seeall) 

--------------------------------------------------------------------------
-- 通用辅助函数
--------------------------------------------------------------------------

_G.eDown            = 0
_G.eRight           = 1
_G.eUp              = 2
_G.eLeft            = 3
_G.eDirectionMax    = 4

local tblDirection = 
{
    [0] = {[0] = eDown,     [1] = eRight,  [2] = eUp,     [3] = eLeft},
    [1] = {[0] = eLeft,     [1] = eDown,   [2] = eRight,  [3] = eUp},
    [2] = {[0] = eUp,       [1] = eLeft,   [2] = eDown,   [3] = eRight},
    [3] = {[0] = eRight,    [1] = eUp,     [2] = eLeft,   [3] = eDown},
}

--  得到方位
_G.GetDirection = function(nChairID)
    return (FGameDC:getDC():SwitchViewChairID(nChairID) + 2) % 4
    -- local nSelfChairID = GetSelfChairID()
    -- --print("nSelfChairID:" .. nSelfChairID)
    -- if nSelfChairID < 0 or nSelfChairID >= GAME_PLAYER then
    --     nSelfChairID = 0
    -- end

    -- local tblRelativeDirection = tblDirection[nSelfChairID]

    -- return tblRelativeDirection[nChairID]
end

-- 得到椅子方位
_G.GetChairDirection = function(nChairID)

    local tblRelativeDirection = tblDirection[CGameData:getInstance():GetBankerUser()]

    return tblRelativeDirection[nChairID]
end

-- 得到自己所在方位
_G.GetSelfDirection = function()
    return GetDirection(GetSelfChairID())
end

-- 得到自己的ID
_G.GetSelfChairID = function()
    return FGameDC:getDC():GetMeChairID()
end

--sprite1 原始的精灵
--sprite2 替换的精灵
_G.AdjustSpriteScale = function(sprite1, sprite2)
    -- body
    local sx = sprite1:getContentSize().width / sprite2:getContentSize().width
    local sy = sprite1:getContentSize().height / sprite2:getContentSize().height
    return sx, sy
end


_G.GetChairIdByUserId = function(UserId)
    -- body
    local pUserData
    local res=0

    for i=0, GAME_PLAYER - 1 do
        pUserData=FGameDC:getDC():GetUserInfo(i);

        if pUserData~=nil and pUserData.dwUserID==UserId then
            res=i;
            break;
        end
    end

    return res
end


-- 是否为男性
_G.SexIsMan = function(nChairID)
    pUserData = FGameDC:getDC():GetUserInfo(nChairID)

    if pUserData == nil or pUserData == 0 then
        return true
    end

    return pUserData.cbGender == 2
end

_G.ZeroMemory = function(array, count)
    for i = 0, count - 1 do
        array[i] = 0
    end
end

--row
--column
--创建二维数组
_G.Create2Array = function(row, column)
    local t = {}
    for i = 0, row - 1 do
        t[i] = {}
        for j = 0, column - 1 do
            t[i][j] = 0
        end
    end
    return t 
end

--创建一维数组
_G.Create1Array = function(nCount)
    local t = {}
    for i = 0, nCount - 1 do
        t[i] = 0
    end
    return t
end

--拷贝
_G.CopyMemory = function(destination, source, length)
    for i = 0, length - 1 do
        destination[i] = source[i]
    end
end

--从指定位置拷贝数组
_G.CopyMemoryAtIndex = function(destination, dIndex, source, sIndex, length)
    if length < 1 then return end
    if type(source[sIndex]) == "table" then
        CopyMemoryAtIndex(destination, dIndex, source[sIndex], 0, length)
        return
    end

    for i = dIndex, dIndex + length - 1 do
        destination[i] = source[sIndex]
        sIndex = sIndex + 1 
    end
end

--获取指定区间的数组
_G.GetTableByInterval = function(tab, index, count)
    if count < 1 then return {} end
    if type(tab) ~= "table" then return nil end

    local t = {}
    local n = 0
    for i = index, count + index - 1 do
        t[n] = tab[i]
        n = n + 1
    end
    return t
end

_G.ConvertTableToArray = function(tab, count)
    if count == 0 then return nil end

    local t = {}

    for i = 1, count do
        t[i - 1] = tab[i]
    end
    -- for i, v in ipairs(tab) do
    --     t[i - 1] = v
    -- end
    return t
end

_G.ConvertArrayToTable = function(array, count)
    if count == 0 then return nil end

    local t = {}

    for i = 0, count - 1 do
        t[i + 1] = array[i]
    end

    return t
end

_G.RemoveArrayItemByIndex = function(table, count, index)
    for i = index, count - 1 do
        table[i] = table[i + 1]
    end
end