# Axolotl 美西螈引擎特性巡礼 — Axolotl-demo

> CubeGardenCosmos 组织下的 **Axolotl 引擎公开演示作品**。
> 本仓库只包含**剧本脚本与演示素材**（音乐 / 图片 / 占位语音），
> **不包含任何 Axolotl 引擎二进制**（可执行文件、`.axb` 字节码、`assets.pak` 等一概不提交）。

《Axolotl 美西螈引擎特性巡礼》是一段用 Axolotl 原生 DSL（`.axs`）编写的特性演示，
用一场 2～3 分钟的参观串起引擎已交付的几乎全部能力：

- **多前端编译器链**：`.axs` 剧本 → VN IR → `.axb` 字节码 → 栈式虚拟机执行；
- **多场景 / 多分支**：入口大厅 + 序章 + 舞台演出席 + 逻辑控制流 + `callScene` 子场景；
- **舞台演出**：背景 Crossfade、三槽立绘、miniAvatar、电影遮幅、文本框显隐、全屏定格字幕；
- **多通道音频**：BGM 淡入/音量、对白语音（占位嘟嘟声）、BGS 循环音效、SE 一次音效；
- **纯状态机剧本逻辑**：变量（含全局/局部作用域）、`if`、`jumpLabel -when`、
  带展示门槛/可选门槛的 `choose`、子场景参数与 `return` 返回值；
- **i18n / 多语音包**：`vocal/`（共享）与 `vocal/{zh_CN,en_US}/`（分语种）三层语音路由，
  设置中切换语言可热换嘟嘟声音型；
- **图鉴与调试**：`unlockCg` / `unlockBgm` 解锁登记、`showVars` 变量覆盖层；
- **优雅降级**：`playVideo` / `getUserInput` 等尚未完成可玩渲染的指令被记录为日志，
  绝不导致崩溃（缺失资产同样优雅降级）。

## 玩法路径

| 章节 | 剧本文件 | 主要特性 |
| :--- | :--- | :--- |
| 入口大厅 | `game/scene/start.axs` | intro 定格、BGM、背景、miniAvatar、分支菜单、`end` |
| 序章 · 开场 | `game/scene/prologue.axs` | 背景轮换、三槽立绘、BGS/SE、wait、filmMode、setTextbox |
| 舞台演出席 | `game/scene/chapter_stage.axs` | 图鉴解锁、intro、playVideo/getUserInput 降级、showVars |
| 逻辑与控制流 | `game/scene/chapter_logic.axs` | 变量、if、-when、带门槛 choose、callScene/return |
| 子场景 | `game/scene/subscene_quiz.axs` | callScene 参数注入与 `return:prize*2` 返回值 |

大厅提供两种参观模式：
- **一键巡礼**（默认）：顺序播放全部章节，自动衔接，最终 `end` 回到标题；
- **自由参观**：每章结束后返回大厅菜单，可反复游玩任意章节。

## 如何运行

引擎本体为私有仓库（CubeGardenCosmos/Axolotl），本仓库为其演示内容（数据目录）。
拿到引擎工程后，将本仓库作为游戏根目录启动：

```bash
# 无头 CI 冒烟（无窗口，整场跑到 end 退出，exit 0）
AXL_HEADLESS=1 cargo run -p axolotl-app -- --game-dir /path/to/Axolotl-demo

# 窗口化演示（Windows/MSVC 或带 X11 的 Linux）
cargo run -p axolotl-app --features windowed -- --game-dir /path/to/Axolotl-demo
```

启动时引擎会对 `game/scene/` 做一次 `parse → lower → emit` 并写出 `scenes.axb`
写穿缓存（该产物不会被提交，见 `.gitignore`）。

### 最近一次无头验收快照

```
headless run complete — steps=56 lines=52 choices=2 entry="start.axs" script ended
axolotlc check <game/scene>  →  checked 5 scene files: 0 errors, 0 warnings
```

## 目录结构

```
game/
├── config.txt            # 引擎启动配置（标题图/BGM、默认语言 zh_CN、启用手册）
├── scene/*.axs           # 剧本脚本（本仓库的“灵魂”）
├── bgm/
│   ├── fairy_dance.mp3   # 指定源文件（本地路径的一份拷贝）
│   └── fairy_dance.ogg   # 引擎可播放的 Vorbis 转码（当前音频管线解码 WAV/OGG）
├── background/*.png      # BR 项目背景图（JPG→PNG 转换，引擎图片管线解码 PNG/TGA）
├── figure/*.png          # BR 项目立绘与小头像
├── vocal/                # 占位嘟嘟声（共享语音层）
│   ├── zh_CN/            # zh_CN 分语种语音层（双连嘟音型）
│   └── en_US/            # en_US 分语种语音层（下行嘟音型）
├── video/demo.webm       # 占位（playVideo 演示引用；运行时仅降级记录）
docs/
├── i18n/dialogues.sample.zh_CN.json   # axolotlc i18n extract 提取的字典样例（74 键）
scripts/
├── prepare_assets.py     # 一键准备素材（音乐转码/图片转换/生成嘟嘟声）
└── gen_beeps.py          # 占位语音生成器（纯标准库）
```

## 素材说明

- **音乐**：`Fairy Dance.mp3`（用户指定来源）。引擎当前音频管线只启用 WAV/Vorbis
  （`bevy/wav` + `bevy/vorbis`），故仓库同时提供等内容的 `fairy_dance.ogg` 供播放，
  MP3 作为源文件保留。
- **图片**：取自 `BR`（Believed. Relieved.）项目（用户指定），背景图按引擎当前
  PNG/TGA 图片管线做了 JPG→PNG 转换；立绘为原 PNG。
- **语音**：占位**嘟嘟声**，由 `scripts/gen_beeps.py` 生成（正弦波短音）；三个语音层
  （共享 / zh_CN / en_US）用不同音型区分，方便在设置里演示语音包热切换。
- 素材的原始版权归其来源项目所有；本仓库仅作演示用途。参见 `NOTICE.md`。

## 重新生成素材

```bash
pip3 install miniaudio          # 依赖之一（MP3→PCM 解码）
python3 scripts/prepare_assets.py   # 需要 BR 的 game/ 目录与 GStreamer(gst-launch-1.0)
```

## 许可

本仓库为公开演示仓库，未包含任何 Axolotl 引擎源码/二进制（引擎与 BR 属私有项目，
受其自身许可约束）。详见 `NOTICE.md`。