# Axolotl 演示 · 主角 Sion — Axolotl-demo

> CubeGardenCosmos 组织下的 **Axolotl 引擎公开演示作品**。
> 本仓库只包含**剧本脚本与演示素材**（音乐 / 图片 / 占位语音 / Inochi2D 木偶），
> **不包含任何 Axolotl 引擎二进制**（可执行文件、`.axb` 字节码、`assets.pak` 等一概不提交）。

《Axolotl 演示 · 主角 Sion》是一位深夜宿舍的女主角 **Sion** 带领观众
参观引擎能力的演示作品：她用一段 2～3 分钟的线性巡礼串起引擎几乎全部能力——
**舞台演出、多通道音频、Live2D（Inochi2D）、内置 3D 场景、LUA 小游戏、逻辑控制流**。

演示项目同时也是**开放脚本**：每一章 `.axs` 都以注释驱动教学（测试用例即教程
源码），`game/lua/snake.lua` 是全量注释的 LUA API 活教程，`scripts/gen_sion_puppet.py`
则是 Sion 木偶的生成器（一个可直接学习的 Inochi2D `.inp` 建模示例）。

## 能力清单（按章节）

| 章节 | 剧本文件 | 主要特性 |
| :--- | :--- | :--- |
| 入口大厅 | `game/scene/start.axs` | Sion 登场、intro 定格、BGM、分支菜单、`visited` 门控、`end` |
| 序章 · 深夜来电 | `game/scene/prologue.axs` | 背景轮换（Crossfade）、三槽立绘、BGS/SE、wait、filmMode、setTextbox |
| 舞台演出席 | `game/scene/chapter_stage.axs` | 图鉴解锁、intro、playVideo/getUserInput 降级、showVars |
| 音乐混音台 | `game/scene/chapter_audio.axs` | `.axaudiomix` 分轨编曲：全轨齐响 / `-track=` 选轨 / `-track 1` 独奏 / **换轨不重播** / `bgm:none` 唯一停播 / 单声道素材 |
| **Live2D 角色演出** | `game/scene/chapter_inochi.axs` | **Inochi2D `.inp` 木偶**：`playInochi -model=` 装配；`-motion=` 循环运动（Idle / Wave / Talk）；`-expression=` 表情（Blink / Surprise / Sad）；骨骼（左臂两层）/ 表情 / 口型全由数据驱动 |
| **3D 场景演示** | `game/scene/chapter_3d.axs` | **内置 3D 舞台**：`show3d:city` 夜间微缩都市 / `show3d:orbit` 太阳系玩具；`-spin` 自转；`show3d:none` 收起 |
| **LUA 贪吃蛇小游戏** | `game/scene/chapter_snake.axs` | **LUA 脚本层**：`game/lua/snake.lua` 随 VFS 加载，只许调 `axolotl.*` API；输入→步进→覆盖层渲染→`snake_score` 变量写回 axs；无头超时兜底保证 CI 整场可跑 |
| 逻辑与控制流 | `game/scene/chapter_logic.axs` | 变量（全局/局部）、if、`-when` 门槛、带 show/enable 门槛的 choose、callScene/return |
| 子场景 | `game/scene/subscene_quiz.axs` | callScene 参数注入与 `return:prize*2` 返回值 |

大厅提供两种参观模式：
- **线性巡礼**（默认）：Sion 全程导游，按 序章 → 舞台 → 混音台 → Live2D → 3D →
  贪吃蛇 → 逻辑 的顺序自动衔接，最终 `end` 回到标题；
- **自由参观**：进入大厅**章节菜单**（上述全部章节直达），每章结束回到同一菜单；
  回大厅时开场白只在首访播放（`visited` 门控）。

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

### 最近一次无头验收快照（Phase 5 · Sion demo）

```
headless run complete — steps=118 lines=97 choices=2 entry="start.axs" script ended
axolotlc check <game/scene>  →  checked 9 scene files: 0 errors, 0 warnings
axolotlc lua check <game/lua>→  1 script(s), 0 error(s) — snake boots in the sandbox
axolotlc doctor <game>       →  22 notes, 1 warning(缺入口 exe，引擎仓库构建才有), 0 errors
三后端 parity（loose / assets.pak / 内容寻址 store）：steps=118 lines=97 choices=2 完全一致
```
> 混音台素材：`game/bgm/fairy_dance_{pno,harp,violin}.wav` 为 Fairy Dance 三声部
> stem（146318ms，IEEE Float 双声道 44.1kHz）；`fairy_dance_mono.wav` 为派生
> 单声道剪辑（45s）。Live2D 木偶 `game/puppet/sion.inp`（21KB）由
> `scripts/gen_sion_puppet.py` 生成：10 个部件纹理 + 6 条动画（Idle / Blink /
> Talk / Wave / Surprise / Sad）。

## 目录结构

```
game/
├── config.txt            # 引擎启动配置（Game_name「Axolotl 演示 · 主角 Sion」…）
├── scene/*.axs           # 剧本脚本（本仓库的“灵魂”，注释驱动教学）
├── lua/snake.lua         # LUA 贪吃蛇（Phase 4 引擎示例的 demo 落地，全量注释）
├── puppet/sion.inp       # Sion 的 Inochi2D 木偶（骨骼/表情/口型，生成器见 scripts/）
├── bgm/                  # 混音台三声部 stem + 单曲（mp3/ogg/wav）
├── background/*.png      # 背景图（JPG→PNG 转换，引擎图片管线解码 PNG/TGA）
├── figure/*.png          # 立绘与小头像（舞台演出席）
├── vocal/                # 占位嘟嘟声（共享 / zh_CN / en_US 三层语音路由）
└── video/demo.webm       # 占位（playVideo 演示引用；运行时仅降级记录）
docs/
└── i18n/dialogues.sample.zh_CN.json   # axolotlc i18n extract 提取的字典样例
scripts/
├── gen_sion_puppet.py    # Sion 木偶生成器（Inochi2D 规范建模示例，纯标准库）
├── prepare_assets.py     # 一键准备素材（音乐转码/图片转换/生成嘟嘟声）
└── gen_beeps.py          # 占位语音生成器（纯标准库）
```

## 素材说明

- **Sion 木偶**：`game/puppet/sion.inp` 由本仓库脚本生成（Inochi2D v2 容器，
  10 枚程序化 PNG 纹理）。骨骼（左臂两层）、表情（EyeOpen/MouthOpen/
  MouthSmile/BrowLift）、待机律动（BodyBob/HairSway）与六条动画全部可被
  `playInochi` 指名播放；生成器源码即建模教程。
- **音乐**：`Fairy Dance` 三声部 stem（用户指定源）；引擎当前音频管线启用
  WAV/Vorbis，故仓库同时提供 `fairy_dance.ogg` 等内容的单曲版本。
- **图片**：取自 `BR`（Believed. Relieved.）项目（用户指定），背景图按引擎
  当前 PNG/TGA 图片管线做了 JPG→PNG 转换；立绘为原 PNG。
- **语音**：占位**嘟嘟声**，由 `scripts/gen_beeps.py` 生成（正弦波短音）；
  三个语音层（共享 / zh_CN / en_US）用不同音型区分，方便在设置里演示语音包热切换。
- 素材的原始版权归其来源项目所有；本仓库仅作演示用途。参见 `NOTICE.md`。

## 重新生成素材

```bash
python3 scripts/gen_sion_puppet.py   # 重新生成 game/puppet/sion.inp（纯标准库）
pip3 install miniaudio               # prepare_assets 依赖之一（MP3→PCM 解码）
python3 scripts/prepare_assets.py    # 需要 BR 的 game/ 目录与 GStreamer(gst-launch-1.0)
```

## 许可

本仓库为公开演示仓库，未包含任何 Axolotl 引擎源码/二进制（引擎与 BR 属私有项目，
受其自身许可约束）。详见 `NOTICE.md`。