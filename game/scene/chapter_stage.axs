; =============================================================================
; 《Axolotl 演示 · 主角 Sion》 — 舞台演出席（画面演出与图鉴）
;
; 本章展示的特性：
;   · unlockCg / unlockBgm   图鉴解锁（CG 鉴赏 / BGM 鉴赏占位注册）
;   · intro                  全屏定格字幕（无 -hold，自动收起）
;   · playVideo              视频播放（当前运行时降级为日志，不崩溃）
;   · getUserInput           自由文本输入（同上，降级占位）
;   · showVars               调试变量覆盖层
;   · playEffect（SE）       一次性音效
;   · if + jumpLabel         线性巡礼 / 自由参观分流
; =============================================================================

bgm:bgm/wonderful_life.mp3 -volume=50 -enter=600;
changeBg:background/bg_bedroom_night.png;
Sion:这一章是舞台演出席，重点看图鉴与演出指令。 -Vbeep_heroine.wav;

changeBg:background/bg_blood_draw.png;
unlockCg:background/bg_blood_draw.png -name=枫山回忆;
unlockCg:background/bg_classroom_lunch.png -name=文学部的午餐;
Sion:两张 CG 已登记解锁，稍后可到「鉴赏（图鉴占位）」查看。 -Vbeep_heroine.wav;

unlockBgm:bgm/wonderful_life.mp3 -name=美好生活 Wonderful Life;
Sion:BGM 图鉴也记录了解锁曲目。 -Vbeep_heroine.wav;

playEffect:bgm/wonderful_life.mp3 -volume=15;
:这一段使用了 SE（一次性音效）通道，可以同时叠加多实例。;

intro:本章还会演示几条「尚未进入可玩状态」的指令——它们会被引擎优雅降级为日志，绝不导致崩溃。;
wait:200;
Sion:例如 playVideo 视频播放、getUserInput 文本输入，当前运行时先记入日志，后续 Phase 补齐。 -Vbeep_heroine.wav;
playVideo:video/demo.webm;
getUserInput:player_name -title=输入你的名字 -buttonText=确定;

showVars;
Sion:showVars 会在屏幕一角叠加变量表，供剧本作者现场排错。 -Vbeep_heroine.wav;

:再来一个不带 hold 的 intro，展示自动收起的舞台化字幕。;
intro:演出到此告一段落。;

if:tour==1|jumpLabel:to_audio;
Sion:舞台演出席完成，我们回大厅继续。 -Vbeep_heroine.wav;
changeScene:start.axs;
label:to_audio;
Sion:下一站：音频演播室「分轨混音台」。 -Vbeep_heroine.wav;
changeScene:chapter_audio.axs;