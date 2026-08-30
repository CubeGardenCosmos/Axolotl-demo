; =============================================================================
; subscene_quiz.axs — callScene 的子场景目标
;
; 调用方（chapter_logic.axs）：
;   callScene:subscene_quiz.axs -difficulty=2 -prize=100 -writeReturnTo=result;
;
; 演示：场景参数以局部变量注入（difficulty / prize），
;       return 表达式把计算结果交还给调用方（写入 result）。
; =============================================================================

:（子场景开始：参数 difficulty、prize 已作为局部变量注入，BGM 与舞台状态保持调用方现场。）;

if:difficulty>=2|jumpLabel:hard;
Sion:难度不足 2，只回馈基础奖金。 -Vbeep_heroine.wav;
return:prize;

label:hard;
Sion:高难度挑战成功！奖金翻倍。 -Vbeep_heroine.wav;
return:prize*2;