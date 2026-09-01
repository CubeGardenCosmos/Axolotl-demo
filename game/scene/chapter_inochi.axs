; =============================================================================
; 《主角 Sion》 — Live2D 角色演出（Inochi2D）（chapter_inochi.axs）
;
; 引擎的 Live2D 兼容层：Inochi2D（.inp）木偶 —— 骨骼形变、表情、口型全部
; 由数据驱动的解算器与动画播放器完成。本章展示的指令：
;
;   · playInochi:<actor> -model=puppet/sion.inp -motion=<name>
;       同一事件里把木偶装配到角色槽位（actor 名即槽位 id；与 changeFigure
;       的 -id= 自由槽同语义）并启动具名循环动画——首帧即有运动。
;   · playInochi:<actor> -motion=<name> / -expression=<name>
;       控制已上台角色：-motion 播放循环运动，-expression 混入具名表情后淡出。
;   · changeFigure:none -id=<actor> 离场。
;
; puppet/sion.inp（生成器 scripts/gen_sion_puppet.py）提供六个具名动画：
;   Idle（BodyBob / HairSway 待机律动 + 眨眼）、Blink、Talk（MouthOpen /
;   MouthSmile 口型振荡）、Wave（ArmLift / ElbowBend 挥手）为循环运动；
;   Surprise / Sad（EyeOpen / BrowLift）为具名表情。全部经 -motion /
;   -expression 按名字指名播放。
; =============================================================================

bgm:bgm/wonderful_life.mp3 -volume=45 -enter=600;
changeBg:background/bg_classroom.png;
Sion:这一章，我换一个形态来见你——不是静态立绘，而是数据驱动的 Live2D 木偶。 -Vbeep_heroine.wav;
:（片源：game/puppet/sion.inp，Inochi2D 规范；骨骼 / 表情 / 口型由解算器每帧求解。）;

playInochi:sion -model=puppet/sion.inp -motion=Idle;
wait:600;
Sion:这是我在引擎里的第一帧：playInochi 在同一事件里装配木偶并启动 Idle 循环。 -Vbeep_heroine.wav;
wait:200;

Sion:Idle 由 BodyBob 与 HairSway 的待机律动驱动，并周期性眨眼——木偶一上台就在动。 -Vbeep_heroine.wav;
wait:400;

playInochi:sion -motion=Wave;
wait:200;
Sion:Wave 驱动左臂的两层骨骼（ArmLift / ElbowBend）抬起挥手——不需要换模型。 -Vbeep_heroine.wav;
wait:400;

playInochi:sion -motion=Talk;
Sion:Talk 让 MouthOpen 沿关键帧振荡，做出说话的口型；与对白的 -V 语音配合，就是唇形演出。 -Vbeep_heroine.wav;

playInochi:sion -expression=Surprise;
wait:200;
Sion:Surprise 是具名表情：EyeOpen 撑大、BrowLift 上扬，惊讶写在脸上。 -Vbeep_heroine.wav;
wait:400;

playInochi:sion -expression=Sad;
wait:200;
Sion:Sad 让眉梢与嘴角一起沉下来——同一个木偶，换一个表情就是另一种心情。 -Vbeep_heroine.wav;
wait:400;

playInochi:sion -motion=Idle;
Sion:回到 Idle 后，待机律动与 SimplePhysics 继续每帧解算——衣摆、发丝保持自然的轻微摆动。 -Vbeep_heroine.wav;
Sion:这些 motion 与 expression 都装在同一个 .inp 里，按名字指名播放；换一个木偶就是换一个角色。 -Vbeep_heroine.wav;

changeFigure:none -id=sion;
Sion:离场与静态立绘同一套槽位语义。下一站是 3D。 -Vbeep_heroine.wav;

if:tour==1|jumpLabel:to_3d;
Sion:Live2D 章节完成，我们回大厅继续。 -Vbeep_heroine.wav;
changeScene:start.axs;
label:to_3d;
Sion:下一站：3D 场景演示。 -Vbeep_heroine.wav;
changeScene:chapter_3d.axs;
