; =============================================================================
; 《主角 Sion》 — LUA 贪吃蛇小游戏（chapter_snake.axs）
;
; 引擎把 sandbox 化的 LUA 脚本层（crates/axolotl-lua）暴露给剧本。与小游戏
; 的交互走 **全屏独立场景** 语义：
;
;   runLua:snake.lua -result=snake_result;
;
; · 剧本在 `runLua:` 上挂起，游戏画面被 LUA 全屏场景接管（引擎虚拟画布
;   640×360，axolotl.gui.rect/text/clear 精灵式渲染，不叠加在主线之上）；
; · 退出条件 = **失败**：脚本撞墙/咬到自己时 `axolotl.scene.end("over")`，
;   引擎把结果写进 `snake_result`（本写法），VM 随后从该指令继续；
; · 结果桥（%0/%1 语义）：LUA 还能用 `axolotl.var.set` 完全接管剧本变量
;   （snake_score / snake_state 每帧写回），剧本据此分支；
; · 无头回归：`axolotl.engine.headless()` 时脚本进入确定性自推演（固定种子
;   + 贪心 AI + 强制触壁），以失败自然结束——CI 不需要任何超时轮询。
; =============================================================================

bgm:bgm/wonderful_life.mp3 -volume=35 -enter=600;
changeBg:background/bg_classroom.png;
Sion:最后一站——不是看演出，是「玩」。这段贪吃蛇完全是 LUA 脚本写的。 -Vbeep_heroine.wav;
Sion:接下来的画面会整个交给小游戏场景：全屏棋盘、方向键 / WASD 移动、R 重开；撞墙或咬到自己就是结束，结果会回来接管剧本。 -Vbeep_heroine.wav;
voiceBlips:sfx/blip.wav -speaker=Sion;
Sion:可别小看它——渲染是精灵矩形，输入走 axolotl.input，计分用 axolotl.var 写回，退出用 axolotl.scene.end。脚本全程不碰引擎底层。 -Vbeep_heroine.wav;
voiceBlips:none;
:（剧本在此挂起——LUA 全屏场景接管游戏画布，直到“失败”返回。无头 CI 下脚本自推演并以撞墙结束。）;

runLua:snake.lua -result=snake_result;

; —— 场景返回：脚本声明的结果（snake_result）与它写回的剧本变量 ——
if:snake_state=="over"|jumpLabel:confirmed_over;
Sion:咦，不是正常失败退出的？……不管怎样，场景已经回来了。 -Vbeep_heroine.wav;
jumpLabel:after_score;
label:confirmed_over;
Sion:好——撞墙 / 咬到自己，场景按约定退出了。snake_result 拿到的是脚本声明的退出结果。 -Vbeep_heroine.wav;

; —— 按得分剧情分支（snake_score 由 LUA 完全维护）——
if:snake_score>=5|jumpLabel:score_high;
if:snake_score>=1|jumpLabel:score_low;
Sion:一条都没吃到……没关系，游戏循环本身已经完整跑通：挂起 → 全屏渲染 → 输入 → 步进 → 失败退出 → 结果桥。 -Vbeep_heroine.wav;
jumpLabel:after_score;
label:score_low;
Sion:有得分！如果你在窗口里玩过，分数就是刚才那局的——LUA 维护的变量直接变成剧情。 -Vbeep_heroine.wav;
jumpLabel:after_score;
label:score_high;
Sion:高手！得分超过 5——这套 LUA 层完全可以驱动正式的迷你玩法。 -Vbeep_heroine.wav;
label:after_score;

Sion:snake_score / snake_state / snake_result 全部来自 LUA——执行 LUA 时引擎给出返回通道，也允许脚本直接接管变量，两种姿势都能用。 -Vbeep_heroine.wav;
if:tour==1|jumpLabel:to_logic;
Sion:贪吃蛇章节完成，我们回大厅继续。 -Vbeep_heroine.wav;
changeScene:start.axs;
label:to_logic;
Sion:下一站（也是巡礼的收官）：逻辑与控制流。 -Vbeep_heroine.wav;
changeScene:chapter_logic.axs;