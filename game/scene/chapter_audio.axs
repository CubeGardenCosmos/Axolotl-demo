; =============================================================================
; 《Axolotl 美西螈引擎特性巡礼》 — 音乐混音台（.axaudiomix 分轨编曲）
;
; 本章展示的特性（Packaging Phase 3）：
;   · bgm:<mix>.axaudiomix        全轨齐响（无 -track）
;   · -track=1,2 / -track=1,3 / -track=2,3  任意两轨组合（其余静音）
;   · -track 1 / -track 2 / -track 3        仅一轨独奏
;   · 换轨不重启：同一混音台的 -track 切换只动启用通道，音乐继续播放
;   · bgm:none                   唯一让混音台整体停下（淡出）的方式；
;                                 之后再次 bgm:<mix> 才会从头重新起播
;   · 单声道素材可作普通单曲 BGM（混音台轨道仍要求双声道，
;     axolotlc check / doctor 会拒绝单声道混音轨道）
;   · 混音台整体视作一个 BGM 资源：跨场景 Fade、Voice Ducking 整体生效
;   · 同步机制：同混音台轨道时长强制一致（±50ms）→ 各轨天然同步循环
;
; 路由：一键巡礼自动演示（tour==1 线性结尾衔接下一章）；
;       自由参观给「混音台测试台」——choose 选项路由，方便手动调试/试听。
;
; 编曲：bgm/fairy_dance_mix.axaudiomix
;    track 1 = 钢琴（fairy_dance_pno.wav）    —— chord 骨架
;    track 2 = 竖琴（fairy_dance_harp.wav）   —— 琶音织体
;    track 3 = 小提琴（fairy_dance_violin.wav）—— 主旋律声部
; =============================================================================

changeBg:background/bg_blood_draw.png;
:—— 音频演播室 · 分轨混音台 ——;
:这一站展示「一次分轨，任意调用」：同一首编曲，无需导出任何混音母带。;

if:tour==1|jumpLabel:tour_demo;

; ======================================================================
; 自由参观：混音台测试台（choose 路由，方便调试与试听）
; ======================================================================
雪乃:混音台测试台已就位——选一组轨道试听。换轨不会打断播放，只有 bgm:none 才让整台淡出停下。 -Vbeep_heroine.wav;

label:test_menu;
choose:返回大厅:hall|「双轨」钢琴+竖琴 1+2:t12|「双轨」竖琴+小提琴 2+3:t23|「双轨」钢琴+小提琴 1+3:t13|「独奏」钢琴 1:t1|「独奏」竖琴 2:t2|「独奏」小提琴 3:t3|「整台静音」bgm none:mute|「单声道单曲」:mono;

label:t12;
bgm:bgm/fairy_dance_mix.axaudiomix -track=1,2;
雪乃:钢琴和弦打底、竖琴琶音铺开——1、2 号轨。换轨不打断，音乐继续。 -Vbeep_heroine.wav;
jumpLabel:test_menu;

label:t23;
bgm:bgm/fairy_dance_mix.axaudiomix -track=2,3;
雪乃:竖琴织体、小提琴旋律进入——2、3 号轨。 -Vbeep_heroine.wav;
jumpLabel:test_menu;

label:t13;
bgm:bgm/fairy_dance_mix.axaudiomix -track=1,3;
雪乃:钢琴 + 小提琴、竖琴静音——1、3 号轨。 -Vbeep_heroine.wav;
jumpLabel:test_menu;

label:t1;
bgm:bgm/fairy_dance_mix.axaudiomix -track 1;
雪乃:独奏：只剩 1 号钢琴。 -Vbeep_heroine.wav;
jumpLabel:test_menu;

label:t2;
bgm:bgm/fairy_dance_mix.axaudiomix -track 2;
雪乃:独奏：2 号竖琴（空格写法 -track 2）。 -Vbeep_heroine.wav;
jumpLabel:test_menu;

label:t3;
bgm:bgm/fairy_dance_mix.axaudiomix -track=3;
雪乃:独奏：3 号小提琴。 -Vbeep_heroine.wav;
jumpLabel:test_menu;

label:mute;
bgm:none;
雪乃:bgm:none——整台一起淡出停下。这是唯一停止播放的方式；之后再起 bgm 才会重新播放。 -Vbeep_heroine.wav;
jumpLabel:test_menu;

label:mono;
bgm:bgm/fairy_dance_mono.wav -volume=55 -enter=800;
雪乃:单声道单曲：45 秒剪辑作为普通 BGM 一切照常（混音台轨道仍要求双声道）。 -Vbeep_heroine.wav;
jumpLabel:test_menu;

label:hall;
雪乃:音频巡礼到此为止，我们回大厅继续。 -Vbeep_heroine.wav;
changeScene:start.axs;

; ======================================================================
; 一键巡礼：自动演示段（线性，tour==1）
; ======================================================================
label:tour_demo;
:『场景一』钢琴 + 竖琴（旋律暂歇，伴奏织体先行）。;
bgm:bgm/fairy_dance_mix.axaudiomix -track=1,2;
雪乃:钢琴和弦打底、竖琴琶音铺开——只有 1、2 号轨在响。 -Vbeep_heroine.wav;

:『换轨』切到 2+3——注意音乐没有从头开始，只是通道切换。;
bgm:bgm/fairy_dance_mix.axaudiomix -track=2,3;
雪乃:竖琴织体、小提琴旋律进入——2、3 号轨，播放位置原样继续。 -Vbeep_heroine.wav;

:『换轨』再切 1+3——2 号轨静音、1 号轨回来，仍然不重播。;
bgm:bgm/fairy_dance_mix.axaudiomix -track=1,3;
雪乃:再来一组配器变化：钢琴 + 小提琴，1、3 号轨。 -Vbeep_heroine.wav;

:『bgm:none』整台淡出——这是唯一停止播放的方式。;
bgm:none;
雪乃:bgm:none 让整个混音台一起淡出。 -Vbeep_heroine.wav;

:『重新起播』只有 bgm:none 之后，再次 bgm:<mix> 才会从头开始。;
bgm:bgm/fairy_dance_mix.axaudiomix -track 1;
雪乃:独奏重启：钢琴从头上起——换轨不重播、bgm:none 之后才重播。 -Vbeep_heroine.wav;

:『单声道素材』普通单曲可放单声道；混音台轨道仍要求双声道。;
bgm:none;
bgm:bgm/fairy_dance_mono.wav -volume=55 -enter=800;
雪乃:这是从钢琴 stem 下混的 45 秒单声道剪辑——作为普通 BGM 一切照常。 -Vbeep_heroine.wav;
:（若把它写进 .axaudiomix 轨道，axolotlc check / doctor 会报「仅双声道」并拒绝。）;

:混音台演示完毕——三种调用（齐响 / 选轨 / 独奏）就是三种配器情绪。;
bgm:none;

label:to_logic;
雪乃:混音台展示结束，自动进入下一章「逻辑与控制流」。 -Vbeep_heroine.wav;
changeScene:chapter_logic.axs;