; =============================================================================
; 《Axolotl 美西螈引擎特性巡礼》 — 序章 · 开场（舞台与音频协同）
;
; 本章展示的特性：
;   · changeBg     多背景轮换（Crossfade / Dissolve 过渡）
;   · changeFigure 左/中/右三槽立绘（-left / -center / -right）与移除（none）
;   · playEffect   BGS 循环音效（-id= 通道）与停止（none -id=）
;   · wait         时间停顿
;   · setTextbox   文本框显隐
;   · filmMode     电影遮幅模式（-position= 对白六档位置，进出 Crossfade）
;   · 对白语音挂载（-Vbeep_*）与音量（-volume=）
;   · if + jumpLabel 巡礼模式分流（线性 / 自由参观）
; =============================================================================

bgm:bgm/fairy_dance.ogg -volume=60 -enter=800;
changeBg:background/bg_corridor.png;
:放学后的走廊，夕阳斜照。;
雪乃:这是背景切换——引擎以 Crossfade 完成过渡，没有生硬的黑屏。 -Vbeep_heroine.wav;

changeBg:background/bg_classroom.png;
雪乃:换一个场景，背景平滑渐变，而 BGM 保持连续播放。 -Vbeep_heroine.wav;
changeFigure:figure/figure_teacher.png -right;
雪乃:立绘可以布置在左、中、右三个槽位，也可以自由命名。 -Vbeep_heroine.wav;
物理老师:我就是从右边登场的物理老师。 -Vbeep_teacher.wav -volume=80;
:（立绘淡入淡出，槽位互不干扰。移除用 changeFigure:none 即可。）;
changeFigure:none -right;

changeBg:background/bg_night_street.png;
changeFigure:figure/figure_hero.png -left;
changeFigure:figure/figure_heroine.png -center;
我:夜晚街道 + 左右双立绘，同时在场。 -Vbeep_hero.wav;
playEffect:bgm/fairy_dance.ogg -id=rain -volume=25;
雪乃:现在后台叠加了一层循环音效（BGS），独立通道、独立音量。 -Vbeep_heroine.wav;
wait:400;
雪乃:wait 指令让节奏停留 400 毫秒。 -Vbeep_heroine.wav;
playEffect:none -id=rain;
:（BGS 循环已停止。）;

filmMode:on -position=bottom;
:电影遮幅开启——对白默认落在下方黑辐居中。;
雪乃:位置可定义：上方居中、四角对齐都行，进出遮幅带 Crossfade。 -Vbeep_heroine.wav;
filmMode:on -position=topright;
:右上角，向右对齐。;
filmMode:on -position=topleft;
:左上角，向左对齐。;
雪乃:退出遮幅时，上下黑边会平滑淡出。 -Vbeep_heroine.wav -volume=80;
filmMode:none;

setTextbox:hide;
:文本框也可以暂时隐藏。;
setTextbox:on;
雪乃:setTextbox 控制对白框显隐，配合演出使用。 -Vbeep_heroine.wav;

if:tour==1|jumpLabel:to_stage;
雪乃:序章巡礼到此为止，我们回大厅继续。 -Vbeep_heroine.wav;
changeScene:start.axs;
label:to_stage;
雪乃:序章结束，自动进入下一章「舞台演出」。 -Vbeep_heroine.wav;
changeScene:chapter_stage.axs;