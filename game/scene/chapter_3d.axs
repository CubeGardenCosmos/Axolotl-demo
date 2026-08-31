; =============================================================================
; 《主角 Sion》 — 3D 场景演示（chapter_3d.axs）
;
; 引擎以 2D 舞台为主，同时也原生集成 3D 舞台：show3d 指令直接加载工业标准
; 的 glTF/GLB 模型（PBR 材质 + 实时光照 + GPU 渲染），不自己写死程序化几何体。
; 本章展示：
;
;   · show3d:model3d/damaged_helmet.glb -spin
;       Khronos 标准 PBR 损毁战盔：法线贴图 + 金属粗糙度 + 自发光 + 环境光照
;   · show3d:model3d/duck.glb -spin
;       CC0 经典公共领域模型：标准多边形网格与平滑旋转
;   · show3d:none       关闭 3D 演示层，回到 2D 舞台（背景恢复）
;
; 无头冒烟 / CI 下 3D 实体是惰性的（不渲染、不崩溃），窗口模式下由
; wgpu 实时渲染。
; =============================================================================

bgm:bgm/fairy_dance.ogg -volume=40 -enter=600;
changeBg:none;
Sion:先熄掉 2D 背景——接下来的画面交给一片真正的 3D 舞台。 -Vbeep_heroine.wav;

show3d:model3d/damaged_helmet.glb -spin;
Sion:这是工业标准的 3D 资产：show3d 直接加载 glTF/GLB 损毁战盔模型。 -Vbeep_heroine.wav;
Sion:PBR 材质、金属/粗糙度贴图、自发光与法线凹凸均由 Bevy/wgpu 原生渲染。 -Vbeep_heroine.wav;
Sion:-spin 参数让 3D 模型在舞台中心缓缓自转。 -Vbeep_heroine.wav;
wait:800;

show3d:model3d/duck.glb -spin;
Sion:换模型：show3d:model3d/duck.glb 是经典的 CC0 公共领域 3D 模型。 -Vbeep_heroine.wav;
Sion:任意符合标准规范的 .glb / .gltf 文件均可在剧本中随时点名载入。 -Vbeep_heroine.wav;
wait:800;

show3d:none;
changeBg:background/bg_night_street.png;
Sion:show3d:none 收起 3D 层，2D 舞台立即恢复——背景继续无缝讲述。 -Vbeep_heroine.wav;
Sion:全套 3D 流程完全基于开源标准，不手写死几何体，拥抱开放生态。 -Vbeep_heroine.wav;

if:tour==1|jumpLabel:to_snake;
Sion:3D 章节完成，我们回大厅继续。 -Vbeep_heroine.wav;
changeScene:start.axs;
label:to_snake;
Sion:下一站：LUA 驱动的贪吃蛇小游戏！ -Vbeep_heroine.wav;
changeScene:chapter_snake.axs;