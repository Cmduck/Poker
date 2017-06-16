--
-- Author: GFun
-- Date: 2016-10-21 09:57:29
--
local MusicCenter = class("MusicCenter")

local MUSIC_BASE_PATH = "ccbResources/fightbombRes/sound/music/"
local Language_Name_1 = "Mandarin"	--普通话
local Language_Name_2 = "Localism"	--方言 

local BG_MUSIC = MUSIC_BASE_PATH .. "YH_BACKGROUND.mp3"

local musicBaseTab = {
	GameEnd         = MUSIC_BASE_PATH .. "GAME_END.mp3",
	GameLost        = MUSIC_BASE_PATH .. "GAME_LOST.mp3",
	GameStart       = MUSIC_BASE_PATH .. "GAME_START.mp3",
	GameWarn        = MUSIC_BASE_PATH .. "GAME_WARN.mp3",
	GameWin         = MUSIC_BASE_PATH .. "GAME_WIN.mp3",
	GameBtn         = MUSIC_BASE_PATH .. "KeypressStandard.mp3",
	GameClickCard   = MUSIC_BASE_PATH .. "Snd_HitCard.mp3",
	GameDispathCard = MUSIC_BASE_PATH .. "Special_Dispatch.mp3",
	GameTimeOut     = MUSIC_BASE_PATH .. "timeout.mp3",
	GameCardLess    = MUSIC_BASE_PATH .. "GAME_CARD_LESS.mp3",
	GameFindFriend  = MUSIC_BASE_PATH .. "FindFriend.mp3"
}

local MUSIC_CARD_RES = {
	[CT_SINGLE] = {
		[1] = "S_1.mp3",
		[2] = "S_2.mp3",
		[3] = "S_3.mp3",
		[4] = "S_4.mp3",
		[5] = "S_5.mp3",
		[6] = "S_6.mp3",
		[7] = "S_7.mp3",
		[8] = "S_8.mp3",
		[9] = "S_9.mp3",
		[10] = "S_10.mp3",
		[11] = "S_11.mp3",
		[12] = "S_12.mp3",
		[13] = "S_13.mp3",
		[14] = "S_14.mp3",
		[15] = "S_15.mp3"
	},
	[CT_DOUBLE] = {
		[1] = "D_1.mp3",
		[2] = "D_2.mp3",
		[3] = "D_3.mp3",
		[4] = "D_4.mp3",
		[5] = "D_5.mp3",
		[6] = "D_6.mp3",
		[7] = "D_7.mp3",
		[8] = "D_8.mp3",
		[9] = "D_9.mp3",
		[10] = "D_10.mp3",
		[11] = "D_11.mp3",
		[12] = "D_12.mp3",
		[13] = "D_13.mp3",
		[14] = "D_14.mp3",
		[15] = "D_15.mp3"
	},
	[CT_SINGLE_LINE] = {
		sound = "Type_ShunZi.mp3",
		effect = "single_line_effect.mp3"
	},
	[CT_DOUBLE_LINE] = {
		sound = "Type_LianDui.mp3",
		effect = "double_line_effect.mp3"
	},
	[CT_THREE_LINE_TAKE_XXX] = {
		sound = "Type_FeiJi.mp3",
	},
	[CT_WU_SHI_K] = {

	},
	[CT_FLUSH_WU_SHI_K] = {

	},
	[CT_BOMB_FOUR] = {
		sound = "Type_ZhaDan.mp3",
	},
	[CT_BOMB_FIVE] = {
		sound = "Type_ZhaDan.mp3",
	},
	[CT_BOMB_SIX] = {
		sound = "Type_ZhaDan.mp3",
	},
	[CT_BOMB_SEVEN] = {
		sound = "Type_ZhaDan.mp3",
	},
	[CT_BOMB_KING] = {
		sound = "Type_ZhaDan.mp3",
	},
	[CT_BOMB_EIGHT] = {
		sound = "Type_ZhaDan.mp3",
	}
}

local MUSIC_BAO_RES = {
	[0] = "BuBao.mp3",
	[1] = "BaoCard.mp3"
}

local MUSIC_PASS_RES = {
		[0] = "PASS_A.mp3",
		[1] = "PASS_B.mp3",
		[2] = "PASS_C.mp3",
		[3] = "PASS_D.mp3",
}

local musicFollowCardTab = {
	Man = {
		[0] = "ccbResources/fightbombRes/sound/music/Male/OutCard1.mp3",
		[1] = "ccbResources/fightbombRes/sound/music/Male/OutCard2.mp3",
		[2] = "ccbResources/fightbombRes/sound/music/Male/OutCard3.mp3",
	},
	Women = {
		[0] = "ccbResources/fightbombRes/sound/music/Female/OutCard1.mp3",
		[1] = "ccbResources/fightbombRes/sound/music/Female/OutCard2.mp3",
		[2] = "ccbResources/fightbombRes/sound/music/Female/OutCard3.mp3"
	}
}

function MusicCenter:ctor()
	-- body
	--默认语言
	self.m_cbLanguage_ = Language_Name_1
end

function MusicCenter:SetLanguage(index)
	-- body
	self.m_cbLanguage_ = index == 1 and Language_Name_1 or Language_Name_2
	print("当前语音:", self.m_cbLanguage_)
end

function MusicCenter:LoadAllEffect()
	-- body
	self:preLoadEffect(musicBaseTab)
	self:preLoadEffect(musicOutCardTab)
	self:preLoadEffect(musicPassCardTab)
end

function MusicCenter:unLoadAllEffect()
	-- body
	self:unLoadEffect(musicBaseTab)
	self:unLoadEffect(musicBaseTab)
	self:unLoadEffect(musicBaseTab)
end

function MusicCenter:preLoadEffect(tab)
	-- body
    for k, v in pairs(tab) do
        if type(v) == "table" then
            self:preLoadEffect(v)
        else
        	audio.preloadSound(v)
        end
    end
end

function MusicCenter:unLoadEffect(tab)
	-- body
    for k, v in pairs(tab) do
        if type(v) == "table" then
            self:unLoadEffect(v)
        else
            audio.unloadSound(v)
        end
    end
end

function MusicCenter:LoadBGMuisc()
	-- body
	audio.preloadMusic(BG_MUSIC)
end

function MusicCenter:PlayBGMusic()
	-- body
	audio.playMusic(BG_MUSIC, true)
end

function MusicCenter:StopBGMusic()
	-- body
	audio.stopMusic(true)
end

function MusicCenter:PlayWarnEffect()
	-- body
	audio.playSound(musicBaseTab.GameWarn, false)
end

function MusicCenter:PlayStartEffect()
	-- body
	audio.playSound(musicBaseTab.GameStart, false)
end

function MusicCenter:PlayWinEffect()
	-- body
	audio.playSound(musicBaseTab.GameWin, false)
end

function MusicCenter:PlayLostEffect()
	-- body
	audio.playSound(musicBaseTab.GameLost, false)
end

function MusicCenter:PlayEndEffect()
	-- body
	audio.playSound(musicBaseTab.GameEnd, false)
end

function MusicCenter:PlayBtnEffect()
	-- body
	audio.playSound(musicBaseTab.GameBtn, false)
end

function MusicCenter:PlayClickCardEffect()
	-- body
	audio.playSound(musicBaseTab.GameClickCard, false)
end

function MusicCenter:PlayTimeOutEffect()
	-- body
	audio.playSound(musicBaseTab.GameTimeOut, false)
end

function MusicCenter:PlayCardLessEffect()
	-- body
	audio.playSound(musicBaseTab.GameCardLess, false)
end

function MusicCenter:PlayBaoCardSound(sex, index)
	-- body
	local strGender = sex == 2 and "/Man/" or "/Woman/"
	local path = MUSIC_BASE_PATH .. "/" .. self.m_cbLanguage_ .. strGender .. MUSIC_BAO_RES[index]
	print(path)
	audio.playSound(path)

end

function MusicCenter:PlayBaoDanSound(sex)
	local strGender = sex == 2 and "/Man/" or "/Woman/"
	local path = MUSIC_BASE_PATH .. "/" .. self.m_cbLanguage_ .. strGender .. "Type_Baodan.mp3"
	audio.playSound(path)
end

function MusicCenter:PlayThreeTakeTwoSound(sex)
	local strGender = sex == 2 and "/Man/" or "/Woman/"
	local path = MUSIC_BASE_PATH .. "/" .. self.m_cbLanguage_ .. strGender .. "Type_ThreeTakeDouble.mp3"
	audio.playSound(path)
end

function MusicCenter:PlayOutCardEffect(sex, cardType, value)
	-- body
	print("sex = ", sex)
	print("cardType = ", cardType)
	print("value = ", value)
	local strGender = sex == 2 and "/Man/" or "/Woman/"
	local path = MUSIC_BASE_PATH .. "/" .. self.m_cbLanguage_ .. strGender

	if cardType == CT_SINGLE or cardType == CT_DOUBLE then
		if MUSIC_CARD_RES[cardType][value] then
			print("当前播放音效的路径:", path .. MUSIC_CARD_RES[cardType][value])
			audio.playSound(path .. MUSIC_CARD_RES[cardType][value])
		end
	else
		for k, v in pairs(MUSIC_CARD_RES[cardType]) do
			if k == "effect" then
				print("当前播放Effect的路径:", MUSIC_BASE_PATH .. v)
				audio.playSound(MUSIC_BASE_PATH .. v)
			else
				print("当前播放Sound的路径:", path .. v)
				audio.playSound(path .. v)
			end
		end
	end
end

function MusicCenter:PlayPassCardEffect(chairId)
	-- body
	local user_data = FGameDC:getDC():GetUserInfo(chairId)
	local sex = user_data.cbGender
	local t = {}
	local strGender = sex == 2 and "/Man/" or "/Woman/"

	local path = MUSIC_BASE_PATH .. "/" .. self.m_cbLanguage_ .. strGender .. MUSIC_PASS_RES[chairId]
	audio.playSound(path)
end

function MusicCenter:PlayDispathCardEffect()
	-- body
	audio.playSound(musicBaseTab.GameDispathCard, true)
end

function MusicCenter:PlayFollowCardEffect(sex)
	-- body
	math.randomseed(tostring(os.time()):reverse():sub(1, 6)); --加随机数种子
	local rand_num = math.random(1, 99999) % 3
	local t = {}
	if sex == 2 then
		t = musicFollowCardTab.Man
	else
		t = musicFollowCardTab.Women
	end
	audio.playSound(t[rand_num])
end

function MusicCenter:PlayFindFriend()
	audio.playSound(musicBaseTab.GameFindFriend, false)
end

return MusicCenter