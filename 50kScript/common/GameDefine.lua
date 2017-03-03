--牌副定义
_G.MAX_PACK 			= 2		--最大副数
_G.CELL_PACK			= 54	--单元数目
_G.FULL_COUNT  			= 108	--全牌数目

--属性定义
_G.GAME_PLAYER 			= 4		--玩家人数
_G.MAX_COUNT			= 27	--最大数目
_G.OUT_MAX_COUNT		= 25	--出牌数目
_G.COLOR_RIGHT			= 40	--花色权位
_G.CARD_VALUE_KIND		= 15	--数值种类 2 3-K 大小王
_G.CARD_COLOR			= 4		--单牌花色 黑红梅方
_G.SAME_CARD_MAX		= 8 	--同牌最多的张数
--游戏定义
_G.WIN_DOUBLE_SCORE		= 105	--胜利翻倍分数

--扑克类型
_G.CT_ERROR				= 0		--错误类型
_G.CT_SINGLE			= 1		--单牌
_G.CT_DOUBLE			= 2		--对牌类型
_G.CT_SINGLE_LINK		= 3		--单连类型
_G.CT_DOUBLE_LINK		= 4		--对连类型
_G.CT_BOMB_THREE		= 5		--3张炸弹
_G.CT_BOMB_FOUR			= 6		--4张炸弹
_G.CT_BOMB_FIVE			= 7 	--5张炸弹
_G.CT_WU_SHI_K			= 8		--杂五十K
_G.CT_BOMB_SIX			= 9		--6张炸弹
_G.CT_WU_SHI_THK		= 10	--同花五十K
_G.CT_BOMB_SEVEN		= 11	--7张炸弹
_G.CT_SMALL_KING		= 12	--对小王
_G.CT_DOUBLE_KING		= 13	--对王 == 左对王 == 右对王
_G.CT_LEFT_KING			= 14	--左对王
_G.CT_RIGHT_KING		= 15	--右对王
_G.CT_BIG_KING			= 16	--对大王
_G.CT_HEAVEN_BOMB		= 17	--天炸
_G.CT_UNMATCHED_BOMB	= 18	--无敌炸

----------------------------------------------------------------------------
--状态机ID(客户端)
_G.GAME_STATE_WAIT          	= 1      				-- 等待
_G.GAME_STATE_PLAYING       	= 2      				-- 正在玩过程中
_G.GAME_STATE_CLEARING      	= 3      				-- 结算

--场景状态
_G.GS_FREE						= 0						-- 空闲状态
_G.GS_PLAYING					= 100					-- 游戏状态

_G.GS_UG_FREE					= GS_FREE				-- 空闲状态
_G.GS_UG_HOU					= (GS_PLAYING + 1)		-- 吼牌状态
_G.GS_UG_PLAYING				= (GS_PLAYING + 2)		-- 游戏状态
_G.GS_UG_CONTINUE				= (GS_PLAYING + 3)		-- 继续状态	
 
--游戏模式
--_G.GAME_MODE_DEFAULT 			= -1
_G.GAME_MODE_JIAO				= 0						--叫牌玩法
_G.GAME_MODE_HOU 				= 1						--吼牌玩法

--游戏类型
_G.GAME_GENRE_SCORE 			= 0x0001				--积分类型
_G.GAME_GENRE_GOLD				= 0x0002				--金币类型
_G.GAME_GENRE_MATCH 			= 0x0004				--比赛类型

--结束类型
-- _G.GER_DISMISS 					= 1			--解散结束
-- _G.GER_NORMAL 					= 0			--正常结束
-- _G.GER_USER_LEFT 				= 2			--用户强退

---------------------------------C/S通信协议--------------------------------------

--服务器命令结构
_G.SUB_S_GAME_START				= 100					--游戏开始
-- _G.SUB_S_OUT_CARD				= 101					--用户出牌
_G.SUB_S_PASS_CARD				= 102					--用户放弃
_G.SUB_S_GAME_END				= 103					--游戏结束
_G.SUB_S_HOUSTATE_CARD			= 104					--返回吼牌结束信息
_G.SUB_S_PHRASE					= 105					--玩家发言
_G.SUB_S_CALL_CARD				= 106					--玩家叫牌
_G.SUB_S_HOU_CARD_END			= 107					--吼牌结束
_G.SUB_S_OUT_CARD_START			= 108					--出牌开始
_G.SUB_S_OUT_CARD_END			= 109					--出牌结束
_G.SUB_S_CUR_TURN_OVER			= 110					--当轮结束  
_G.SUB_S_OVER_CARD 				= 111					--手牌出完


--建桌协议
_G.SUB_S_SCORE_RULE        		= 111                   --游戏规则
_G.SUB_S_REQUEST_LEAVE     		= 112                   --离开请求
_G.SUB_S_TABLEDISMISS      		= 113                   --空闲时解散桌子
_G.SUB_S_DISMISS_RESULT   		= 115                   --解散桌子结果
_G.SUB_S_TOTAL_ACCOUNT     		= 116                   --总结算
_G.SUB_S_STARTGAME        		= 118                   --开始游戏
_G.SUB_S_OUT_SHOW_CARD			= 119					--打出叫牌

--客户端命令结构
_G.SUB_C_OUT_CARD				= 1						--用户出牌
_G.SUB_C_PASS_CARD				= 2						--用户放弃
_G.SUB_C_CALL_CARD				= 3						--叫牌通知服务端
_G.SUB_C_HOU_CARD				= 4                     --吼牌通知服务端
_G.SUB_C_PHRASE         		= 5                     --玩家发言
_G.SUB_C_TRUSTEESHIP			= 6						--玩家托管

_G.SUB_C_RESPONSES_LEAVE       	= 6                     --回应离开
_G.SUB_C_TABLEDISMISS			= 7                     --解散桌子请求
_G.SUB_C_STARTGAME				= 8                     --玩家点击开始
_G.SUB_C_LEAVEGAME				= 9                     --玩家手动开游戏
_G.SUB_C_REQUEST_TOTAL_ACCOUNT	= 10					--请求发送总结算


--排序类型
_G.ST_ORDER						= 0						--大小排序
_G.ST_COUNT						= 1						--数目排序
_G.ST_VALUE						= 2						--数值排序
_G.ST_COLOR						= 3						--花色排序
_G.ST_CUSTOM					= 4						--自定排序

--用户状态定义
-- US_NULL           =              0x00                                --没有状态
-- US_FREE           =              0x01                                --站立状态
-- US_SIT            =              0x02                                --坐下状态
-- US_READY          =              0x03                                --同意状态
-- US_LOOKON         =              0x04                                --旁观状态
-- US_PLAY           =              0x05                                --游戏状态
-- US_OFFLINE        =              0x06                                --断线状态