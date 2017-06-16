--
-- Author: GFun
-- Date: 2016-12-09 16:41:30
--

local DataParse = class("DataParse")

function DataParse:ctor()
	-- body
end

function DataParse:getSceneMsgParseStr(status)
	local str = ""
	if status == GS_UG_FREE then
		str = "LONG, 1, WORD, 1, BYTE, 2, BYTE, 2, BYTE, 2, bool, 2, bool, 1, bool, 1,"
	elseif status == GS_UG_BAO then
		str = "LONG,1, WORD,1, WORD,1, WORD,1, BYTE,27, BYTE,4, BYTE,4, LONGLONG,4, bool,1, BYTE,1, WCHAR,128,"
	elseif status == GS_UG_CALL then
		str = "LONG,1, WORD,1, WORD,1, WORD,1, BYTE,27, BYTE,4, LONGLONG,4, bool,1, BYTE,1, WCHAR,128,"
	elseif status == GS_UG_PLAYING then
		str = "LONG,1, WORD,1, WORD,1, WORD,1, WORD,1, BYTE,1, BYTE,1, BYTE,1, int,4, int,4, BYTE,1, BYTE,4, BYTE,1, BYTE,27, BYTE,4, BYTE,1,BYTE,1,BYTE,27, BYTE,4, LONGLONG,4, BYTE,4, bool,1, bool,1, BYTE,1, WCHAR,128,BYTE,24,BYTE,1,"
	elseif status == GS_UG_CONTINUE then
		str = "LONG,1, WORD,1, BYTE,4, LONGLONG,4, bool,1, BYTE,1, WCHAR,128,"
	end
	return str
end

function DataParse:getGameMsgParseStr(status)
	-- body
	local str = ""
	if status == SUB_S_GAME_START then
		str = "WORD, 1, WORD, 1, BYTE, 27, BYTE, 1,BYTE,4,"
	elseif status == SUB_S_PASS_CARD then
		str = "WORD,1, BYTE,1, WORD,1, BYTE,1, BYTE,1,"
	elseif status == SUB_S_GAME_END then
		str = "LONGLONG,4, LONGLONG,4, int,4, int,4, int,4, BYTE,1, BYTE,4, BYTE,108, BYTE,4,"
	elseif status == SUB_S_OUT_CARD_START then
		str = "WORD, 1,"
	elseif status == SUB_S_CUR_TURN_OVER then
		str = "WORD, 1, BYTE, 1, BYTE,1,"
	elseif status == SUB_S_OUT_CARD_END then
		str = "BYTE, 1, BYTE, 27, BYTE, 1, BYTE,1, BYTE,1,"
	elseif status == SUB_S_CALL_CARD then
		str = "BYTE,1,BYTE,4,"
	elseif status == SUB_S_BAO_CARD then
		str = "BYTE,1, BYTE,1,"
	elseif status == SUB_S_BAO_CARD_END then
		str = "BYTE,1,BYTE,4,"
	elseif status == SUB_S_OVER_CARD then
		str = "WORD,1, BYTE,1,"
	elseif status == SUB_S_SCORE_RULE then
		str = "BYTE,1, BYTE,1, bool,1, bool,1, int, 1, int, 1, int, 1,"
	elseif status == SUB_S_REQUEST_LEAVE then
		str = "WORD, 1,WCHAR, 128,"
	elseif status == SUB_S_TABLEDISMISS then
		str = ""
	elseif status == SUB_S_DISMISS_RESULT then
		str = "BYTE , 1, "
	elseif status == SUB_S_TOTAL_ACCOUNT then
		str = "int,4, BYTE,16, LONGLONG,4, BYTE,1,"
	elseif status == SUB_S_STARTGAME then
		str = "BYTE, 4,"
	end
	return str
end 

return DataParse