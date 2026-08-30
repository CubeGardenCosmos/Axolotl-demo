; =============================================================================
; 《Axolotl 美西螈引擎特性巡礼》 — 入口场景 start.axs
;
; 本章展示的特性：
;   · intro      全屏定格字幕（-hold 等待玩家）
;   · bgm        BGM 播放（-volume 音量 / -enter 淡入时长）
;   · changeBg   背景切换（Crossfade 过渡）
;   · 旁白(:) / 带说话人的对白 / 续句对白（省略说话人沿用上一位）
;   · -V         对白挂载语音（占位嘟嘟声，VocalRouter 路由）
;   · voiceBlips 打字机音效（语音混音器发声，可随时被 -V 配音替换）
;   · choose     分支菜单（show 门槛演示）
;   · setVar     -global 全局变量（控制线性巡礼 / 自由参观两种模式）
;   · changeScene 跨场景跳转
;   · end        结束剧本回到标题画面
; =============================================================================

; —— 首访门控：自由参观回大厅时跳过开场白与 intro 定格，直接落入章节菜单 ——
if:visited==1|jumpLabel:chapter_menu;
setVar:visited=1 -global;

intro:《Axolotl 美西螈引擎特性巡礼》|Native Visual Novel Engine Demo|—— 占位配音全程嘟嘟声 —— -hold;

bgm:bgm/fairy_dance.ogg -volume=55 -enter=1500;
changeBg:background/bg_home_livingroom.png;

:欢迎来到 Axolotl 引擎的特性演示。;
:每一场戏，都对应引擎的一项能力。;

Engine:剧本由 .axs 原生 DSL 编写：先编译为 VN IR，再生成 .axb 字节码。 -Vbeep_system.wav;
Engine:栈式虚拟机逐条执行：背景、立绘、音频、分支、存档……全部数据驱动。 -Vbeep_system.wav;

雪乃:你好，我是本场演示的向导「雪乃」。 -Vbeep_heroine.wav;
雪乃:每条对白都能挂载语音；你现在听到的嘟嘟声就是占位语音。 -Vbeep_heroine.wav;
:接下来启用打字机音效：雪乃说话时会出现细碎的嘟嘟声。;
voiceBlips:sfx/blip.wav -speaker=雪乃;
雪乃:这就是打字机音效——逐字揭示时经语音混音器发出短促节拍。;
雪乃:一旦某句挂了实配音（-V 指令），打字机音效会自动让位。 -Vbeep_heroine.wav;
voiceBlips:none;
:在「设置」里切换语言时，语音包会热切换为不同音型的嘟嘟声。;

:你想以哪种方式参观？;
choose:一键巡礼（顺序播放全部章节）:begin_tour|自由参观（大厅章节菜单）:chapter_menu|结束演示:quit;

label:begin_tour;
setVar:tour=1 -global;
雪乃:好的，以线性巡礼模式开始——看完一个章节会自动进入下一章。 -Vbeep_heroine.wav;
changeScene:prologue.axs;

label:quit;
雪乃:那么，本次特性巡礼到此结束。感谢体验。 -Vbeep_heroine.wav;
:（end 指令结束剧本，返回标题画面。）;
end;

; —— 大厅章节菜单（自由参观：tour=0，每章结束后回到本菜单）——
; 首访开场白只在第一次进入大厅时播放；再次进入直接落到本菜单。
label:chapter_menu;
setVar:tour=0 -global;
雪乃:自由参观模式——从这里直接选任意章节，每章结束会回到本菜单。 -Vbeep_heroine.wav;
choose:序章 · 开场:ch_prologue|舞台演出席:ch_stage|音频演播室 · 分轨混音台:ch_audio|逻辑与控制流:ch_logic|一键巡礼（顺序播放全部章节）:begin_tour|结束演示:quit;

label:ch_prologue;
changeScene:prologue.axs;
label:ch_stage;
changeScene:chapter_stage.axs;
label:ch_audio;
changeScene:chapter_audio.axs;
label:ch_logic;
changeScene:chapter_logic.axs;