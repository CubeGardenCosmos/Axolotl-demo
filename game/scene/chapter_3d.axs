; =============================================================================
; 《主角 Sion》 — 3D 场景演示（chapter_3d.axs）
;
; 引擎以 2D 舞台为主，但也内建一片真正的 3D 地盘：show3d 指令放出预制
; 微缩场景（真实 Mesh3d + PBR 材质 + 相机 + 灯光，Bevy/wgpu 渲染）。本章
; 展示：
;
;   · show3d:city       夜间微缩都市：地面 + 彩色楼群 + 圆球路灯 + 发光环
;   · show3d:orbit      太阳系玩具：发光中心球 + 三道环带 + 四颗轨道球
;   · -spin             整组场景绕 Y 轴自转（相机保持俯视机位）
;   · show3d:none       关闭 3D 演示层，回到 2D 舞台（背景恢复）
;
; 无头冒烟 / CI 下 3D 实体是惰性的（不渲染、不崩溃），窗口模式下由
; wgpu 实时渲染。预制场景纯代码生成（引擎 crates/axolotl-bevy/src/threed.rs），
; 不依赖 glTF 导入。
; =============================================================================

bgm:bgm/fairy_dance.ogg -volume=40 -enter=600;
changeBg:none;
Sion:先熄掉 2D 背景——接下来的画面交给一片真正的 3D 舞台。 -Vbeep_heroine.wav;

show3d:city -spin;
Sion:这是「夜间微缩都市」：show3d:city 放出地面、楼群、路灯与发光环。 -Vbeep_heroine.wav;
Sion:-spin 让整组场景绕 Y 轴缓缓自转——相机保持俯视机位。 -Vbeep_heroine.wav;
wait:800;

show3d:orbit;
Sion:换舞台：show3d:orbit 是太阳系的玩具模型——发光中心球 + 三道环带 + 彩色轨道球。 -Vbeep_heroine.wav;
wait:400;
show3d:orbit -spin;
Sion:阳光已经足够旋转次数了……这次帮我转起来。 -Vbeep_heroine.wav;
wait:800;

show3d:none;
changeBg:background/bg_night_street.png;
Sion:show3d:none 收起 3D 层，2D 舞台立即恢复——背景继续无缝讲述。 -Vbeep_heroine.wav;
Sion:预制场景的来源是代码不是资产：任意作品都可以在脚本里直接点名使用。 -Vbeep_heroine.wav;

if:tour==1|jumpLabel:to_snake;
Sion:3D 章节完成，我们回大厅继续。 -Vbeep_heroine.wav;
changeScene:start.axs;
label:to_snake;
Sion:下一站：LUA 驱动的贪吃蛇小游戏！ -Vbeep_heroine.wav;
changeScene:chapter_snake.axs;