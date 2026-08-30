; =============================================================================
; 《Axolotl 美西螈引擎特性巡礼》 — 音乐混音台（.axaudiomix 分轨编曲）
;
; 本章展示的特性（Packaging Phase 3）：
;   · bgm:<mix>.axaudiomix        全轨齐响（无 -track）
;   · -track=1,2 / -track=1,3 / -track=2,3  任意两轨组合（其余静音）
;   · -track 1 / -track 2 / -track 3        仅一轨独奏
;   · bgm:none                   停止整个混音台（整体淡出）
;   · 单声道素材可作普通单曲 BGM（混音台轨道仍要求双声道，
;     axolotlc check / doctor 会拒绝单声道混音轨道）
;   · 混音台整体视作一个 BGM 资源：跨场景 Fade、Voice Ducking 整体生效
;   · 同步机制：同混音台轨道时长强制一致（±50ms）→ 各轨天然同步循环
;
; 编曲：bgm/fairy_dance_mix.axaudiomix
;    track 1 = 钢琴（fairy_dance_pno.wav）    —— chord 骨架
;    track 2 = 竖琴（fairy_dance_harp.wav）   —— 琶音织体
;    track 3 = 小提琴（fairy_dance_violin.wav）—— 主旋律声部
; =============================================================================

changeBg:background/bg_blood_draw.png;
:—— 音频演播室 · 分轨混音台 ——;
:这一站展示「一次分轨，任意调用」：同一首编曲，无需导出任何混音母带。;

:『场景一』钢琴 + 竖琴（旋律暂歇，伴奏织体先行）。;
bgm:bgm/fairy_dance_mix.axaudiomix -track=1,2;
雪乃:钢琴和弦打底，竖琴琶音铺开——只有 1、2 号轨在响。 -Vbeep_heroine.wav;

:『场景二』竖琴 + 小提琴（钢琴收掉）。;
bgm:bgm/fairy_dance_mix.axaudiomix -track=2,3;
雪乃:竖琴继续织体，小提琴旋律进入——2、3 号轨。 -Vbeep_heroine.wav;

:『场景三』钢琴 + 小提琴（竖琴静音，主旋律明暗交替）。;
bgm:bgm/fairy_dance_mix.axaudiomix -track=1,3;
雪乃:再来一组配器变化：钢琴 + 小提琴，1、3 号轨。 -Vbeep_heroine.wav;

:『返回画面』收束混音台，回到常规单曲 BGM。;
bgm:none;
bgm:bgm/fairy_dance.ogg -volume=55 -enter=800;
雪乃:bgm:none 让整个混音台一起淡出，回到平时听的单曲 BGM。 -Vbeep_heroine.wav;

:『单声道素材』普通单曲可放单声道；混音台轨道仍要求双声道。;
bgm:bgm/fairy_dance_mono.wav -volume=55 -enter=800;
雪乃:这是从钢琴 stem 下混的 45 秒单声道剪辑——作为普通 BGM 一切照常。 -Vbeep_heroine.wav;
:（若把它写进 .axaudiomix 轨道，axolotlc check / doctor 会报「仅双声道」并拒绝。）;

:『独奏·钢琴』仅 1 号轨。;
bgm:bgm/fairy_dance_mix.axaudiomix -track 1;
雪乃:只剩钢琴自己了。 -Vbeep_heroine.wav;

:『独奏·竖琴』仅 2 号轨（空格写法 -track 2）。;
bgm:bgm/fairy_dance_mix.axaudiomix -track 2;
雪乃:竖琴独奏——换一种配器情绪，无需任何新母带。 -Vbeep_heroine.wav;

:『独奏·小提琴』仅 3 号轨。;
bgm:bgm/fairy_dance_mix.axaudiomix -track=3;
雪乃:旋律声部单独登场。 -Vbeep_heroine.wav;

:混音台演示完毕——三种调用（齐响 / 选轨 / 独奏）就是三种配器情绪。;
bgm:none;

if:tour==1|jumpLabel:to_logic;
雪乃:音频巡礼到此为止，我们回大厅继续。 -Vbeep_heroine.wav;
changeScene:start.axs;
label:to_logic;
雪乃:混音台展示结束，自动进入下一章「逻辑与控制流」。 -Vbeep_heroine.wav;
changeScene:chapter_logic.axs;