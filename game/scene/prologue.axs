; =============================================================================
; 《主角 Sion》 — 序章 · 深夜来电（prologue.axs）
;
; 本章以 Sion 的第一人称开场，展示引擎的核心舞台能力——
;   · changeBg        背景切换（Crossfade 过渡；三张夜间/室内背景轮换）
;   · changeFigure    三槽立绘（-left / -center / -right，-id= 自由槽）
;   · bgm / playEffect 音乐与循环环境音（BGS，-id= 通道管理）
;   · wait            演出节奏停顿（毫秒）
;   · filmMode       电影遮幅（-position= 对白位置，进出带 Crossfade）
;   · setTextbox      对白框显隐
;   · -V             对白挂载占位语音
;   · if + jumpLabel  线性巡礼 / 自由参观分流
; =============================================================================

bgm:bgm/wonderful_life.mp3 -volume=50 -enter=800;
changeBg:background/bg_bedroom_night.png;
:深夜的宿舍，台灯还亮着。窗外是安静的校园。;
Sion:……我是 Sion，这栋宿舍里唯一还醒着的人。 -Vbeep_heroine.wav;
Sion:引擎的第一个能力：changeBg 换背景，自带 Crossfade 过渡。 -Vbeep_heroine.wav;

bgm:bgm/wonderful_life.mp3 -volume=42;
playEffect:bgm/fairy_dance_mono.wav -id=rain -volume=18;
Sion:bgm 播放音乐；playEffect 循环环境音走独立通道（BGS）。 -Vbeep_heroine.wav;
wait:400;

changeBg:background/bg_home_livingroom.png;
changeFigure:figure/figure_heroine.png -center;
Sion:changeFigure 把角色立绘放到中间槽位——三槽立绘（左/中/右）都由它管理。 -Vbeep_heroine.wav;

changeFigure:figure/figure_classmate_a.png -left;
Sion:左侧来了同学，右侧再放一位——立绘支持同时多人在场。 -Vbeep_heroine.wav;
changeFigure:figure/figure_teacher.png -right;
wait:300;
Sion:三槽立绘齐了：changeFigure 就是舞台的出场管理。 -Vbeep_heroine.wav;

changeFigure:none -left;
changeFigure:none -right;
Sion:角色离场同样简单：-left / -right 指定槽位移除。 -Vbeep_heroine.wav;

changeBg:background/bg_classroom.png;
Sion:背景切到教室——画面在这一瞬完成交叉淡化。 -Vbeep_heroine.wav;
changeFigure:none -center;
:（立绘离场后，字幕继续以小字展示。）;

filmMode:on -position=bottom;
:电影遮幅开启——对白默认落在下方黑辐居中。;
Sion:位置可定义：上方居中、四角对齐都行，进出遮幅带 Crossfade。 -Vbeep_heroine.wav;
filmMode:on -position=topright;
:右上角，向右对齐。;
filmMode:on -position=topleft;
:左上角，向左对齐。;
Sion:退出遮幅时，上下黑边会平滑淡出。 -Vbeep_heroine.wav -volume=80;
filmMode:none;

setTextbox:hide;
:文本框也可以暂时隐藏。;
setTextbox:on;
Sion:setTextbox 控制对白框显隐，配合演出使用。 -Vbeep_heroine.wav;
playEffect:none -id=rain;
:（BGS 循环已停止。）;

if:tour==1|jumpLabel:to_stage;
Sion:序章巡礼到此为止，我们回大厅继续。 -Vbeep_heroine.wav;
changeScene:start.axs;
label:to_stage;
Sion:序章结束，自动进入下一章「舞台演出」。 -Vbeep_heroine.wav;
changeScene:chapter_stage.axs;