module(..., package.seeall) 

--------------------------------------------------------------------------
--  游戏入口
--------------------------------------------------------------------------
function CreateGameFun()
	package.loaded["script.50kScript.game.GameScene"] = nil
    --创建游戏窗口
    _G.GameScene = require("script.50kScript.game.GameScene").new()
	GameScene:EnterGame()

    -- 监听按键 back
    local FunHandle = handler(GameScene, GameScene.CBClickBack)
    setKeybackAndMenuListener(FunHandle, nil, GameScene)
 
    -- 返回退出接口
    return handler(GameScene, GameScene.ExitGame) --, handler(_G.InternetManager, _G.InternetManager.MsgProcessGameMsgData), 4 
end