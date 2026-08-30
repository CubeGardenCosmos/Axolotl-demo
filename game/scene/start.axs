; =============================================================================
; 《Axolotl 美西螈引擎特性巡礼》 — 入口场景 start.axs
;
; 本章展示的特性：
;   · intro      全屏定格字幕（-hold 等待玩家）
;   · bgm        BGM 播放（-volume 音量 / -enter 淡入时长）
;   · changeBg   背景切换（Crossfade 过渡）
;   · 旁白(:) / 带说话人的对白 / 续句对白（省略说话人沿用上一位）
;   · -V         对白挂载语音（占位嘟嘟声，VocalRouter 路由）
;   · miniAvatar 文本框旁小头像的挂载与移除
;   · choose     分支菜单（show 门槛演示）
;   · setVar     -global 全局变量（控制线性巡礼 / 自由参观两种模式）
;   · changeScene 跨场景跳转
;   · end        结束剧本回到标题画面
; =============================================================================

intro:《Axolotl 美西螈引擎特性巡礼》|Native Visual Novel Engine Demo|—— 占位配音全程嘟嘟声 —— -hold;

bgm:bgm/fairy_dance.ogg -volume=55 -enter=1500;
changeBg:background/bg_home_livingroom.png;

:欢迎来到 Axolotl 引擎的特性演示。;
:每一场戏，都对应引擎的一项能力。;

Engine:剧本由 .axs 原生 DSL 编写：先编译为 VN IR，再生成 .axb 字节码。 -Vbeep_system.wav;
Engine:栈式虚拟机逐条执行：背景、立绘、音频、分支、存档……全部数据驱动。 -Vbeep_system.wav;

miniAvatar:figure/avatar_heroine.png;
雪乃:你好，我是本场演示的向导「雪乃」。 -Vbeep_heroine.wav;
雪乃:每条对白都能挂载语音；你现在听到的嘟嘟声就是占位语音。 -Vbeep_heroine.wav;
雪乃:重复出现的语音文件会被 VFS 缓存复用，不会重复读取磁盘。 -Vbeep_heroine.wav;
miniAvatar:none;
:在「设置」里切换语言时，语音包会热切换为不同音型的嘟嘟声。;

:你想以哪种方式参观？;
choose:一键巡礼（顺序播放全部章节）:begin_tour|自由参观（每章后回大厅）:free_tour|结束演示:quit;

label:begin_tour;
setVar:tour=1 -global;
雪乃:好的，以线性巡礼模式开始——看完一个章节会自动进入下一章。 -Vbeep_heroine.wav;
changeScene:prologue.axs;

label:free_tour;
setVar:tour=0 -global;
雪乃:自由参观模式——每章结束后会回到本大厅菜单。 -Vbeep_heroine.wav;
changeScene:prologue.axs;

label:quit;
雪乃:那么，本次特性巡礼到此结束。感谢体验。 -Vbeep_heroine.wav;
:（end 指令结束剧本，返回标题画面。）;
end;