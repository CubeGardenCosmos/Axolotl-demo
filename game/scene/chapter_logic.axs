; =============================================================================
; 《Axolotl 演示 · 主角 Sion》 — 逻辑与控制流（变量 / 分支 / 子场景调用）
;
; 本章展示的特性：
;   · setVar      变量赋值（-global 全局作用域 / 默认普通 / -local 局部）
;   · if          条件动作（expr|动作）
;   · jumpLabel   -when= 条件跳转
;   · choose      选择支：show 显示门槛 + enable 可选门槛（表达式驱动）
;   · callScene   子场景调用：传参数，-writeReturnTo= 接收返回值
;   · return      子场景内返回并携带表达式结果
;   · changeScene 跨场景跳转
; =============================================================================

bgm:bgm/fairy_dance.ogg -volume=45 -enter=600;
changeBg:background/bg_home_livingroom.png;
setVar:fav=6;
setVar:hasKey=false;
setVar:quest=1 -global;
Sion:这一章是引擎的「大脑」：变量、表达式与流程控制。 -Vbeep_heroine.wav;
Sion:先设定变量：fav=6、hasKey=false、quest=1（全局）。 -Vbeep_heroine.wav;

if:fav>=5|jumpLabel:good;
Sion:（好感度不足，这一句不会显示——它被 if 跳过了。） -Vbeep_heroine.wav;
jumpLabel:after_check;
label:good;
Sion:if 条件成立，跳到了 good 标签。 -Vbeep_heroine.wav;
label:after_check;

jumpLabel:skip_me -when=fav>10;
Sion:jumpLabel 带 -when 门槛：fav=6 不足 10，所以这一步不会跳过。 -Vbeep_heroine.wav;
label:skip_me;

:现在是一个带条件门槛的选择支。;
choose:(hasKey==true)->打开宝箱:open_box|继续前进:go_on;
label:open_box;
Sion:hasKey 为 false，宝箱选项被引擎禁用——玩家只能选「继续前进」。 -Vbeep_heroine.wav;
jumpLabel:next_branch;
label:go_on;
Sion:这就是选择支的引擎侧实现：show 门槛、enable 门槛都由表达式驱动。 -Vbeep_heroine.wav;
label:next_branch;

Sion:接下来是 callScene：携带参数调用另一个场景，子场景执行后 return 返回值。 -Vbeep_heroine.wav;
callScene:subscene_quiz.axs -difficulty=2 -prize=100 -writeReturnTo=result;
Sion:返回值已写入变量 result，由 if 分支消费。 -Vbeep_heroine.wav;
if:result>=200|jumpLabel:bonus;
Sion:奖金不足 200，没有额外奖励。 -Vbeep_heroine.wav;
jumpLabel:logic_end;
label:bonus;
Sion:奖金达到 200，触发奖励分支！ -Vbeep_heroine.wav;
label:logic_end;

setVar:quest=2 -global;
Sion:全局变量 quest 已更新——跨场景依然保留。 -Vbeep_heroine.wav;
:本次巡礼的全部能力章节都已经走完：舞台、音频、Live2D、3D、LUA、逻辑。;

if:tour==1|jumpLabel:to_end;
Sion:逻辑章完成，我们回大厅继续。 -Vbeep_heroine.wav;
changeScene:start.axs;
label:to_end;
Sion:全部章节巡礼完成！本次演示到此结束，感谢游玩。 -Vbeep_heroine.wav;
:（end 指令结束剧本。）;
end;