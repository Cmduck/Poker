--
-- Author: GFun
-- Date: 2016-10-21 09:57:29
--
local MusicCenter = class("MusicCenter")
--"ccbResources/50kRes/sound/music/BACKGROUND.mp3"
local BG_MUSIC = "ccbResources/50kRes/sound/music/YH_BACKGROUND.mp3"

local musicBaseTab = {
	GameEnd = "ccbResources/50kRes/sound/music/GAME_END.mp3",
	GameLost = "ccbResources/50kRes/sound/music/GAME_LOST.mp3",
	GameStart = "ccbResources/50kRes/sound/music/GAME_START.mp3",
	GameWarn = "ccbResources/50kRes/sound/music/GAME_WARN.mp3",
	GameWin = "ccbResources/50kRes/sound/music/GAME_WIN.mp3",
	GameBtn = "ccbResources/50kRes/sound/music/KeypressStandard.mp3",
	GameClickCard = "ccbResources/50kRes/sound/music/Snd_HitCard.mp3",
	GameDispathCard = "ccbResources/50kRes/sound/music/Special_Dispatch.mp3",
	GameTimeOut = "ccbResources/50kRes/sound/music/timeout.mp3",
	GameCardLess = "ccbResources/50kRes/sound/music/GAME_CARD_LESS.mp3"
}

local musicOutCardTab = {
	Man = {
		[CT_SINGLE] = {
			[1] = "ccbResources/50kRes/sound/music/Male/MALE_1.mp3",
			[2] = "ccbResources/50kRes/sound/music/Male/MALE_2.mp3",
			[3] = "ccbResources/50kRes/sound/music/Male/MALE_3.mp3",
			[4] = "ccbResources/50kRes/sound/music/Male/MALE_4.mp3",
			[5] = "ccbResources/50kRes/sound/music/Male/MALE_5.mp3",
			[6] = "ccbResources/50kRes/sound/music/Male/MALE_6.mp3",
			[7] = "ccbResources/50kRes/sound/music/Male/MALE_7.mp3",
			[8] = "ccbResources/50kRes/sound/music/Male/MALE_8.mp3",
			[9] = "ccbResources/50kRes/sound/music/Male/MALE_9.mp3",
			[10] = "ccbResources/50kRes/sound/music/Male/MALE_10.mp3",
			[11] = "ccbResources/50kRes/sound/music/Male/MALE_11.mp3",
			[12] = "ccbResources/50kRes/sound/music/Male/MALE_12.mp3",
			[13] = "ccbResources/50kRes/sound/music/Male/MALE_13.mp3",
			[14] = "ccbResources/50kRes/sound/music/Male/MALE_14.mp3",
			[15] = "ccbResources/50kRes/sound/music/Male/MALE_15.mp3",
		},
		[CT_DOUBLE] = {
			[1] = "ccbResources/50kRes/sound/music/Male/MALE_DB_1.mp3",
			[2] = "ccbResources/50kRes/sound/music/Male/MALE_DB_2.mp3",
			[3] = "ccbResources/50kRes/sound/music/Male/MALE_DB_3.mp3",
			[4] = "ccbResources/50kRes/sound/music/Male/MALE_DB_4.mp3",
			[5] = "ccbResources/50kRes/sound/music/Male/MALE_DB_5.mp3",
			[6] = "ccbResources/50kRes/sound/music/Male/MALE_DB_6.mp3",
			[7] = "ccbResources/50kRes/sound/music/Male/MALE_DB_7.mp3",
			[8] = "ccbResources/50kRes/sound/music/Male/MALE_DB_8.mp3",
			[9] = "ccbResources/50kRes/sound/music/Male/MALE_DB_9.mp3",
			[10] = "ccbResources/50kRes/sound/music/Male/MALE_DB_10.mp3",
			[11] = "ccbResources/50kRes/sound/music/Male/MALE_DB_11.mp3",
			[12] = "ccbResources/50kRes/sound/music/Male/MALE_DB_12.mp3",
			[13] = "ccbResources/50kRes/sound/music/Male/MALE_DB_13.mp3",
			[14] = "ccbResources/50kRes/sound/music/Male/MALE_DB_14.mp3",
			[15] = "ccbResources/50kRes/sound/music/Male/MALE_DB_15.mp3",
		},
		[CT_SINGLE_LINK] = {
			sound = "ccbResources/50kRes/sound/music/Male/MALE_LINE.mp3",
			effect = "ccbResources/50kRes/sound/music/LINE_CARD.mp3"
		},
		[CT_DOUBLE_LINK] = {
			sound = "ccbResources/50kRes/sound/music/Male/MALE_DB_LINE.mp3",
			effect = "ccbResources/50kRes/sound/music/LINE_CARD.mp3"
		},
		[CT_BOMB_THREE]	= {
			sound = "ccbResources/50kRes/sound/music/Male/MALE_THREE_PLUS_TWO.mp3"
		},	
		[CT_BOMB_FOUR] = {
			effect = "ccbResources/50kRes/sound/music/PLANE.mp3"
		},
		[CT_BOMB_FIVE] = {
			sound = "ccbResources/50kRes/sound/music/Male/BombSound.mp3",
			effect = "ccbResources/50kRes/sound/music/BOMB.mp3"
		},
		[CT_WU_SHI_K] = {
			effect = "ccbResources/50kRes/sound/music/dao.mp3"
		},
		[CT_BOMB_SIX] = {
			effect = "ccbResources/50kRes/sound/music/dao.mp3"
		},
		[CT_WU_SHI_THK] = {
			effect = "ccbResources/50kRes/sound/music/dao.mp3"
		},
		[CT_BOMB_SEVEN] = {
			effect = "ccbResources/50kRes/sound/music/dao.mp3"
		},
		[CT_SMALL_KING] = {
			effect = "ccbResources/50kRes/sound/music/dao.mp3"
		},
		[CT_DOUBLE_KING] = {
			effect = "ccbResources/50kRes/sound/music/dao.mp3"
		}
	},
	Women = {
		[CT_SINGLE] = {
			[1] = "ccbResources/50kRes/sound/music/Female/FEMALE_1.mp3",
			[2] = "ccbResources/50kRes/sound/music/Female/FEMALE_2.mp3",
			[3] = "ccbResources/50kRes/sound/music/Female/FEMALE_3.mp3",
			[4] = "ccbResources/50kRes/sound/music/Female/FEMALE_4.mp3",
			[5] = "ccbResources/50kRes/sound/music/Female/FEMALE_5.mp3",
			[6] = "ccbResources/50kRes/sound/music/Female/FEMALE_6.mp3",
			[7] = "ccbResources/50kRes/sound/music/Female/FEMALE_7.mp3",
			[8] = "ccbResources/50kRes/sound/music/Female/FEMALE_8.mp3",
			[9] = "ccbResources/50kRes/sound/music/Female/FEMALE_9.mp3",
			[10] = "ccbResources/50kRes/sound/music/Female/FEMALE_10.mp3",
			[11] = "ccbResources/50kRes/sound/music/Female/FEMALE_11.mp3",
			[12] = "ccbResources/50kRes/sound/music/Female/FEMALE_12.mp3",
			[13] = "ccbResources/50kRes/sound/music/Female/FEMALE_13.mp3",
			[14] = "ccbResources/50kRes/sound/music/Female/FEMALE_14.mp3",
			[15] = "ccbResources/50kRes/sound/music/Female/FEMALE_15.mp3",
		},
		[CT_DOUBLE] = {
			[1] = "ccbResources/50kRes/sound/music/Female/FEMALE_DB_1.mp3",
			[2] = "ccbResources/50kRes/sound/music/Female/FEMALE_DB_2.mp3",
			[3] = "ccbResources/50kRes/sound/music/Female/FEMALE_DB_3.mp3",
			[4] = "ccbResources/50kRes/sound/music/Female/FEMALE_DB_4.mp3",
			[5] = "ccbResources/50kRes/sound/music/Female/FEMALE_DB_5.mp3",
			[6] = "ccbResources/50kRes/sound/music/Female/FEMALE_DB_6.mp3",
			[7] = "ccbResources/50kRes/sound/music/Female/FEMALE_DB_7.mp3",
			[8] = "ccbResources/50kRes/sound/music/Female/FEMALE_DB_8.mp3",
			[9] = "ccbResources/50kRes/sound/music/Female/FEMALE_DB_9.mp3",
			[10] = "ccbResources/50kRes/sound/music/Female/FEMALE_DB_10.mp3",
			[11] = "ccbResources/50kRes/sound/music/Female/FEMALE_DB_11.mp3",
			[12] = "ccbResources/50kRes/sound/music/Female/FEMALE_DB_12.mp3",
			[13] = "ccbResources/50kRes/sound/music/Female/FEMALE_DB_13.mp3",
			[14] = "ccbResources/50kRes/sound/music/Female/FEMALE_DB_14.mp3",
			[15] = "ccbResources/50kRes/sound/music/Female/FEMALE_DB_15.mp3",
		},
		[CT_SINGLE_LINK] = {
			sound = "ccbResources/50kRes/sound/music/Female/FEMALE_LINE.mp3",
			effect = "ccbResources/50kRes/sound/music/LINE_CARD.mp3"
		},
		[CT_DOUBLE_LINK] = {
			sound = "ccbResources/50kRes/sound/music/Female/FEMALE_DB_LINE.mp3",
			effect = "ccbResources/50kRes/sound/music/LINE_CARD.mp3"
		},
		[CT_BOMB_THREE]	= {
			sound = "ccbResources/50kRes/sound/music/Female/FEMALE_THREE_PLUS_TWO.mp3"
		},	
		[CT_BOMB_FOUR] = {
			effect = "ccbResources/50kRes/sound/music/PLANE.mp3"
		},
		[CT_BOMB_FIVE] = {
			sound = "ccbResources/50kRes/sound/music/Female/BombSound.mp3",
			effect = "ccbResources/50kRes/sound/music/BOMB.mp3"
		},
		[CT_WU_SHI_K] = {
			effect = "ccbResources/50kRes/sound/music/dao.mp3"
		},
		[CT_BOMB_SIX] = {
			effect = "ccbResources/50kRes/sound/music/dao.mp3"
		},
		[CT_WU_SHI_THK] = {
			effect = "ccbResources/50kRes/sound/music/dao.mp3"
		},
		[CT_BOMB_SEVEN] = {
			effect = "ccbResources/50kRes/sound/music/dao.mp3"
		},
		[CT_SMALL_KING] = {
			effect = "ccbResources/50kRes/sound/music/dao.mp3"
		},
		[CT_DOUBLE_KING] = {
			effect = "ccbResources/50kRes/sound/music/dao.mp3"
		}
	}
}

local musicPassCardTab = {
	Man = {
		[0] = "ccbResources/50kRes/sound/music/Male/MALE_PASS_A.mp3",
		[1] = "ccbResources/50kRes/sound/music/Male/MALE_PASS_B.mp3",
		[2] = "ccbResources/50kRes/sound/music/Male/MALE_PASS_C.mp3",
		[3] = "ccbResources/50kRes/sound/music/Male/MALE_PASS_D.mp3",
	},
	Women = {
		[0] = "ccbResources/50kRes/sound/music/Female/FEMALE_PASS_A.mp3",
		[1] = "ccbResources/50kRes/sound/music/Female/FEMALE_PASS_B.mp3",
		[2] = "ccbResources/50kRes/sound/music/Female/FEMALE_PASS_C.mp3",
		[3] = "ccbResources/50kRes/sound/music/Female/FEMALE_PASS_D.mp3",
	}
}

local musicFollowCardTab = {
	Man = {
		[0] = "ccbResources/50kRes/sound/music/Male/OutCard1.mp3",
		[1] = "ccbResources/50kRes/sound/music/Male/OutCard2.mp3",
		[2] = "ccbResources/50kRes/sound/music/Male/OutCard3.mp3",
	},
	Women = {
		[0] = "ccbResources/50kRes/sound/music/Female/OutCard1.mp3",
		[1] = "ccbResources/50kRes/sound/music/Female/OutCard2.mp3",
		[2] = "ccbResources/50kRes/sound/music/Female/OutCard3.mp3"
	}
}

local musicBaoCardTab = {
	Man = {
		[0] = "ccbResources/50kRes/sound/music/Male/BuBao.mp3",
		[1] = "ccbResources/50kRes/sound/music/Male/BaoCard.mp3",
	},
	Women = {
		[0] = "ccbResources/50kRes/sound/music/Female/BuBao.mp3",
		[1] = "ccbResources/50kRes/sound/music/Female/BaoCard.mp3",
	}
}

local musicMaxCardTab = {
	Man = {
		sound = "ccbResources/50kRes/sound/music/Male/Male_Max_Bomb.mp3"
	},
	Women = {
		sound = "ccbResources/50kRes/sound/music/Female/Female_Max_Bomb.mp3"
	}
}

function MusicCenter:ctor()
	-- body

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
	local t = {}
	if sex == 2 then
		t = musicBaoCardTab.Man
	else
		t = musicBaoCardTab.Women
	end
	audio.playSound(t[index])

end

function MusicCenter:PlayDoubleRedFiveSound(sex)
	-- body
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("sex =" .. sex)
	local t = {}
	if sex == 2 then
		t = musicMaxCardTab.Man
	else
		t = musicMaxCardTab.Women
	end
	dump(t)
	for k, v in pairs(t) do
		print("当前播放音效的路径:" .. v)
		audio.playSound(v)
	end
end

function MusicCenter:PlayOutCardEffect(sex, cardType, value)
	-- body
	print("sex = " .. sex)
	print("cardType = " .. cardType)
	print("value = " .. value)
	local t = {}
	if sex == 2 then
		--男
		t = musicOutCardTab.Man
	else
		t = musicOutCardTab.Women
	end
	if cardType == CT_SINGLE or cardType == CT_DOUBLE then
		if t[cardType][value] then
			dump(t[cardType][value])
			audio.playSound(t[cardType][value])
		end
	else
		for k, v in pairs(t[cardType]) do
			print("当前播放音效的路径:" .. v)
			audio.playSound(v)
		end
	end
end

function MusicCenter:PlayPassCardEffect(chairId)
	-- body
	local user_data = FGameDC:getDC():GetUserInfo(chairId)
	local sex = user_data.cbGender
	local t = {}
	if sex == 2 then
		t = musicPassCardTab.Man
	else
		t = musicPassCardTab.Women
	end
	audio.playSound(t[chairId])
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

function MusicCenter:getMusicBaseTab()
	-- body
	return musicBaseTab
end

function MusicCenter:getMusicOutCardTab()
	-- body
	return musicOutCardTab
end

function MusicCenter:getMusicPassCardTab()
	-- body
	return musicPassCardTab
end


return MusicCenter