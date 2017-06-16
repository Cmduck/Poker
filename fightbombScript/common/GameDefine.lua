--牌副定义
_G.MAX_PACK 			= 2								--最大副数
_G.CELL_PACK			= 54							--单元数目
_G.FULL_COUNT  			= MAX_PACK * CELL_PACK			--全牌数目
_G.MAX_COUNT			= 27							--最大数目
_G.NORMAL_COUNT			= 12							--一般数目
_G.KING_COUNT 			= 2	* MAX_PACK					--王牌个数
_G.OUT_COUNT 			= 27 							--出牌数目
_G.INVALID_CARD			= -1							--无效扑克
_G.SAME_CARD_MAX		= 4 * MAX_PACK 					--同牌最多的张数
--属性定义
_G.GAME_PLAYER 			= 4								--玩家人数

--扑克类型
_G.CT_ERROR               = 0		--错误类型
_G.CT_SINGLE              = 1		--单牌类型
_G.CT_DOUBLE              = 2		--对牌类型
_G.CT_THREE               = 3 		--三条类型
_G.CT_SINGLE_LINE         = 4		--单连类型
_G.CT_DOUBLE_LINE         = 5		--对连类型
_G.CT_THREE_LINE          = 6 		--三连类型
-- _G.CT_THREE_LINE_TAKE_ONE = 7		--三带一单
-- _G.CT_THREE_LINE_TAKE_TWO = 8		--三带一对
_G.CT_THREE_LINE_TAKE_XXX = 7 		--三带XXX
-- _G.CT_OLD_PLANE 	  	  = 9		--残缺飞机(最后一手牌)
-- _G.CT_NEW_PLANE 	  	  = 10		--完整飞机(有三张以上)
_G.CT_WU_SHI_K            = 8		--五十K
_G.CT_FLUSH_WU_SHI_K      = 9		--同花五十K
_G.CT_BOMB_FOUR           = 10 		--4炸
_G.CT_BOMB_FIVE           = 11		--5炸
_G.CT_BOMB_SIX            = 12		--6炸(喜100)
_G.CT_BOMB_SEVEN          = 13 		--7炸(喜150)
_G.CT_BOMB_KING 		  = 14 		--王炸(喜150)
_G.CT_BOMB_EIGHT          = 15		--8炸(喜200)
----------------------------------------------------------------------------
--状态机ID(客户端)
_G.GAME_STATE_WAIT          	= 1      				-- 等待
_G.GAME_STATE_PLAYING       	= 2      				-- 正在玩过程中
_G.GAME_STATE_CLEARING      	= 3      				-- 结算

--场景状态
_G.GS_FREE						= 0						-- 空闲状态
_G.GS_PLAYING					= 100					-- 游戏状态

_G.GS_UG_FREE					= GS_FREE				-- 空闲状态
_G.GS_UG_BAO					= (GS_PLAYING + 1)		-- 包牌状态
_G.GS_UG_CALL					= (GS_PLAYING + 2)		-- 叫分状态
_G.GS_UG_PLAYING				= (GS_PLAYING + 3)		-- 游戏状态
_G.GS_UG_CONTINUE				= (GS_PLAYING + 4)		-- 继续状态	

--游戏类型
_G.GAME_GENRE_SCORE 			= 0x0001				--积分类型
_G.GAME_GENRE_GOLD				= 0x0002				--金币类型
_G.GAME_GENRE_MATCH 			= 0x0004				--比赛类型

--玩法类型
_G.GAME_MODEL_BAO				= 1						--包牌模式
_G.GAME_MODEL_CALL				= 0 					--叫牌模式
--结束类型
-- _G.GER_DISMISS 					= 1			--解散结束
-- _G.GER_NORMAL 					= 0			--正常结束
-- _G.GER_USER_LEFT 				= 2			--用户强退

---------------------------------C/S通信协议--------------------------------------
--服务器命令结构
_G.SUB_S_GAME_START 			= 100								--游戏开始
_G.SUB_S_PASS_CARD				= 101								--用户放弃
_G.SUB_S_GAME_END				= 102								--游戏结束
_G.SUB_S_OUT_CARD_START			= 104								--出牌开始
_G.SUB_S_OUT_CARD_END 			= 105								--出牌结束
_G.SUB_S_CUR_TURN_OVER			= 106								--当轮结束
_G.SUB_S_CALL_CARD				= 107								--用户叫牌
_G.SUB_S_BAO_CARD 				= 108								--用户包牌
_G.SUB_S_BAO_CARD_END			= 109 								--包牌结束
_G.SUB_S_OUT_JIAO_CARD			= 110								--打出叫牌
_G.SUB_S_OVER_CARD 				= 111								--手牌出完

_G.SUB_S_TRUSTEESHIP			= 115								--托管信息

--建桌协议
_G.SUB_S_SCORE_RULE        		= 120                   --游戏规则
_G.SUB_S_REQUEST_LEAVE     		= 121                   --离开请求
_G.SUB_S_TABLEDISMISS      		= 122                   --空闲时解散桌子
_G.SUB_S_DISMISS_RESULT   		= 123                   --解散桌子结果
_G.SUB_S_TOTAL_ACCOUNT     		= 124                   --总结算
_G.SUB_S_STARTGAME        		= 125                   --开始游戏

--客户端命令结构
_G.SUB_C_OUT_CARD				= 1						--用户出牌
_G.SUB_C_PASS_CARD 				= 2						--用户放弃
_G.SUB_C_PHRASE					= 3						--玩家发言
_G.SUB_C_TRUSTEESHIP 			= 4						--用户托管
_G.SUB_C_CALL_CARD				= 5 					--用户叫牌
_G.SUB_C_BAO_CARD 				= 6 					--用户包牌

_G.SUB_C_SCORE_RULE 			= 15					--发送建桌
_G.SUB_C_REQUEST_LEAVE 			= 16					--请求离开
_G.SUB_C_RESPONSES_LEAVE       	= 17                    --回应离开
_G.SUB_C_TABLEDISMISS			= 18                    --解散桌子请求
_G.SUB_C_STARTGAME				= 19                    --玩家点击开始
_G.SUB_C_LEAVEGAME				= 20                    --玩家手动开游戏

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