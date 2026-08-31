; =============================================================================
; 《主角 Sion》 — Live2D 角色演出（Inochi2D）（chapter_inochi.axs）
;
; 引擎的 Live2D 兼容层：Inochi2D（.inp）木偶 —— 骨骼形变、表情、口型全部
; 由数据驱动的解算器与动画播放器完成。本章展示的指令：
;
;   · playInochi:<actor> -model=puppet/aka.inp
;       把木偶装配到角色槽位（actor 名即槽位 id；与 changeFigure 的 -id=
;       自由槽同语义）。装配后角色立即以作者默认姿态上台。
;   · playInochi:<actor> -motion=<动画名>
;       播放木偶自带的循环「运动」动画（Idle 待机 / Wave 挥手 / Talk 说话），
;       新运动接管舞台参数（旧片段淡出，避免双倍叠加）。
;   · playInochi:<actor> -expression=<表情名>
;       混合木偶自带的「表情」动画（Blink 眨眼 / Surprise 惊讶 / Sad 沮丧），
;       慢速淡入并在片段播完后淡出。
;   · changeFigure:none -id=<actor> 离场。
;
; 木偶本体 generator 见 scripts/gen_sion_puppet.py —— 它是「开放脚本」的
; 一部分：骨骼（左臂两层：ArmLift 抬大臂、ElbowBend 弯小臂）、表情
; （EyeOpen / MouthOpen / MouthSmile / BrowLift）、待机律动（BodyBob /
; HairSway）全部可被 -motion / -expression 指名播放。
; =============================================================================

bgm:bgm/fairy_dance.ogg -volume=45 -enter=600;
changeBg:background/bg_classroom.png;
Sion:这一章，我换一个形态来见你——不是静态立绘，而是数据驱动的 Live2D 木偶。 -Vbeep_heroine.wav;
:（片源：game/puppet/aka.inp，Inochi2D 规范；骨骼 / 表情 / 口型由解算器每帧求解。）;

playInochi:sion -model=puppet/aka.inp;
wait:600;
Sion:这是我在引擎里的第一帧：playInochi 把 .inp 木偶装配上舞台。 -Vbeep_heroine.wav;
wait:200;

playInochi:sion -motion=Idle;
Sion:Idle 待机循环——身体微浮、发丝轻摆、还会自动眨眼（动画面板驱动参数）。 -Vbeep_heroine.wav;
wait:400;

playInochi:sion -motion=Wave;
Sion:这是「骨骼」：我的左臂是两层骨骼（大臂 Composite + 小臂 Part）。 -Vbeep_heroine.wav;
Sion:Wave 动画同时驱动 ArmLift 抬大臂、ElbowBend 弯小臂——挥手就是骨骼链的旋转。 -Vbeep_heroine.wav;

playInochi:sion -expression=Surprise;
Sion:这是「表情」：眼睛瞪大、眉毛上扬、嘴张开——一个惊讶混入动画。 -Vbeep_heroine.wav;

playInochi:sion -motion=Talk;
Sion:这是「口型」：Talk 循环驱动 MouthOpen 与 MouthSmile，说话时嘴巴一张一合。 -Vbeep_heroine.wav;
Sion:与对白的 -V 语音配合后，可以进一步做音量驱动唇形同步（voice_level 接入嘴唇参数）。 -Vbeep_heroine.wav;

playInochi:sion -expression=Blink;
wait:300;
playInochi:sion -expression=Sad;
Sion:Blink 眨眼是一个短表达式；Sad 沮丧则垂眉、抿嘴、低头。 -Vbeep_heroine.wav;

playInochi:sion -motion=Idle;
Sion:回到待机。上述所有演出都来自同一个 .inp 文件——换一个木偶就是换一个角色。 -Vbeep_heroine.wav;

changeFigure:none -id=sion;
Sion:离场与静态立绘同一套槽位语义。下一站是 3D。 -Vbeep_heroine.wav;

if:tour==1|jumpLabel:to_3d;
Sion:Live2D 章节完成，我们回大厅继续。 -Vbeep_heroine.wav;
changeScene:start.axs;
label:to_3d;
Sion:下一站：3D 场景演示。 -Vbeep_heroine.wav;
changeScene:chapter_3d.axs;