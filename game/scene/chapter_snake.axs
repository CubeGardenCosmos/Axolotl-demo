; =============================================================================
; 《主角 Sion》 — LUA 贪吃蛇小游戏（chapter_snake.axs）
;
; 引擎把 sandbox 化的 LUA 脚本层（crates/axolotl-lua）暴露给剧本：
; lua/*.lua 随 VFS 清单加载，脚本只许碰 axolotl.* API（输入 / 渲染覆盖层 /
; 变量写回 / 事件桥）。贪吃蛇 full source 见 game/lua/snake.lua。
;
; 本章演示：
;   · 游戏循环        script 的 axolotl.on("frame", fn) 每帧驱动：
;                     输入（方向键 / WASD）→ 步进 → 渲染棋盘（覆盖层）
;   · 变量桥          snake_score / snake_state 由 LUA 写回 axs 变量，
;                     剧本用 if 读取 —— 小游戏结果可以被剧情消费
;   · 无头回归        CI 不注入按键：蛇停在起点（state=ready）；剧本用
;                     超时计数兜底，保证无头整场仍能跑到 end
; =============================================================================

bgm:bgm/fairy_dance.ogg -volume=35 -enter=600;
changeBg:background/bg_classroom.png;
Sion:最后一站——不是看演出，是「玩」。这段贪吃蛇完全是 LUA 脚本写的。 -Vbeep_heroine.wav;
Sion:游戏已经在你屏幕上了：方向键 / WASD 移动，R 重开棋盘，撞墙或咬到自己就结束。 -Vbeep_heroine.wav;
voiceBlips:sfx/blip.wav -speaker=Sion;
Sion:棋盘渲染在 GUI 覆盖层，输入走 axolotl.input，计分写回 axs 变量——脚本不碰任何引擎底层。 -Vbeep_heroine.wav;
voiceBlips:none;
:（LUA 层随剧加载：lua/snake.lua ready: 22x14。样例源码全量注释，是 LUA API 的活教程。）;

; —— 等待玩家游玩：轮询 snake_state（over=撞墙/咬自己），并用超时兜底 ——
setVar:snake_rounds=0;
label:snake_loop;
if:snake_state==over|jumpLabel:snake_done;
setVar:snake_rounds=snake_rounds+1 -local;
if:snake_rounds>=10|jumpLabel:snake_done;
wait:1000;
jumpLabel:snake_loop;

label:snake_done;
if:snake_score>=5|jumpLabel:score_high;
if:snake_score>=1|jumpLabel:score_low;
Sion:一条都没吃到……没关系，游戏循环本身已经完整跑通：输入 → 步进 → 渲染 → 计分。 -Vbeep_heroine.wav;
jumpLabel:after_score;
label:score_low;
Sion:有得分！如果窗口在前台，你现在应该已经玩过一小会儿了。 -Vbeep_heroine.wav;
jumpLabel:after_score;
label:score_high;
Sion:高手！得分超过 5——这套 LUA 层完全可以驱动正式的迷你玩法。 -Vbeep_heroine.wav;
label:after_score;

Sion:snake_score 与 snake_state 都是 LUA 写回的变量——剧情与玩法可以互相读取。 -Vbeep_heroine.wav;
if:tour==1|jumpLabel:to_logic;
Sion:贪吃蛇章节完成，我们回大厅继续。 -Vbeep_heroine.wav;
changeScene:start.axs;
label:to_logic;
Sion:下一站（也是巡礼的收官）：逻辑与控制流。 -Vbeep_heroine.wav;
changeScene:chapter_logic.axs;