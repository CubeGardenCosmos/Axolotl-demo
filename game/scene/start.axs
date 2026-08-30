; =============================================================================
; 《Axolotl 演示 · 主角 Sion》 — 入口场景 start.axs
;
; 本文件是 demo 的「大厅」：Sion 登场、选参观路线。作为 Phase 5 的教程式
; 开放脚本，每一行都在注释里解释对应的引擎能力——
;
;   · setVar      -global 全局变量访问门控（visited：首访播放开场白）
;   · intro       全屏定格字幕（-hold 等待玩家点击）
;   · bgm         BGM 播放（-volume 音量 / -enter 淡入毫秒）
;   · changeBg    背景切换（Crossfade 过渡）
;   · 对白语法    说话人:Sion 「续句对白」省略说话人沿用上一位；
;                 -V 挂载语音（占位嘟嘟声，经 VocalRouter 路由）
;   · voiceBlips  打字机音效（-speaker= 限定角色）
;   · choose      分支菜单（show 门槛演示；无头模式自动选第一项）
;   · changeScene 跨场景跳转
;   · end         结束剧本回到标题画面
; =============================================================================

; —— 首访门控：再次回到大厅时跳过开场白与 intro 定格，直接落入章节菜单 ——
if:visited==1|jumpLabel:chapter_menu;
setVar:visited=1 -global;

intro:《Axolotl 演示 · 主角 Sion》|Native Visual Novel Engine Demo|Live2D Inochi · 3D 舞台 · LUA 小游戏 -hold;

bgm:bgm/fairy_dance.ogg -volume=55 -enter=1500;
changeBg:background/bg_bedroom_night.png;

Sion:……深夜的房间里，只有屏幕的光还亮着。 -Vbeep_heroine.wav;
Sion:欢迎来到 Axolotl 引擎的演示——我是女主角 Sion，接下来的旅程由我带你参观。 -Vbeep_heroine.wav;

Sion:剧本由 .axs 原生 DSL 编写：先编译为 VN IR，再生成 .axb 字节码…
Sion:栈式虚拟机逐条执行：背景、立绘、Live2D、3D、音频、LUA……全部数据驱动。 -Vbeep_heroine.wav;
voiceBlips:sfx/blip.wav -speaker=Sion;
Sion:每条对白都能挂载语音；你现在听到的嘟嘟声就是占位语音。;
Sion:切换语言时，语音包会热切换为不同音型的嘟嘟声。 -Vbeep_heroine.wav;
voiceBlips:none;

:你想以哪种方式参观？;
choose:线性巡礼（Sion 全程导游，含新能力章节）:begin_tour|自由参观（大厅章节直达）:chapter_menu|结束演示:quit;

label:begin_tour;
setVar:tour=1 -global;
Sion:好的，以线性巡礼模式开始——每章结束自动接续下一章。 -Vbeep_heroine.wav;
changeScene:prologue.axs;

; —— 大厅章节菜单（自由参观：tour=0，各章结束回到本菜单）——
label:chapter_menu;
setVar:tour=0 -global;
Sion:自由参观模式——从这里直接选任意章节。 -Vbeep_heroine.wav;
choose:序章 · 深夜来电:ch_prologue|舞台演出席:ch_stage|音频演播室 · 分轨混音台:ch_audio|Live2D 角色演出（Inochi2D）:ch_inochi|3D 场景演示:ch_3d|LUA 贪吃蛇小游戏:ch_snake|逻辑与控制流:ch_logic|线性巡礼（Sion 全程导游）:begin_tour|结束演示:quit;

label:ch_prologue;
changeScene:prologue.axs;
label:ch_stage;
changeScene:chapter_stage.axs;
label:ch_audio;
changeScene:chapter_audio.axs;
label:ch_inochi;
changeScene:chapter_inochi.axs;
label:ch_3d;
changeScene:chapter_3d.axs;
label:ch_snake;
changeScene:chapter_snake.axs;
label:ch_logic;
changeScene:chapter_logic.axs;

label:quit;
Sion:那么，本次演示到此结束。感谢体验。 -Vbeep_heroine.wav;
:（end 指令结束剧本，返回标题画面。）;
end;