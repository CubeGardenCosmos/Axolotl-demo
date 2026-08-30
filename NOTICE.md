# NOTICE — Axolotl-demo 素材与许可声明

本仓库（`CubeGardenCosmos/Axolotl-demo`）为 **Axolotl 美西螈引擎**的公开特性演示作品，
仅包含：

1. **剧本脚本**：`game/scene/*.axs`（Axolotl 原生 DSL 演示内容）；
2. **演示素材**：音乐、图片、占位语音、i18n 字典样例；
3. **素材生成脚本**：`scripts/`。

## 不包含内容

- ❌ Axolotl 引擎源码（私有仓库 `CubeGardenCosmos/Axolotl`，CGSGL v2 许可）；
- ❌ 任何 Axolotl 引擎二进制 / 构建产物（可执行文件、`.axb` 字节码、`assets.pak` 等）。

## 素材来源与许可

| 素材 | 来源 | 说明 |
| :--- | :--- | :--- |
| `game/bgm/fairy_dance.mp3` | 外部音乐文件 Fairy Dance.mp3（用户指定） | 仅随演示分发，版权归原作者 |
| `game/bgm/fairy_dance.ogg` | 上述 MP3 的 Vorbis 转码 | 供引擎当前音频管线播放 |
| `game/background/*` `game/figure/*` | 私有项目 `BR`（Believed. Relieved.） | 按开发者指示用于演示，版权归 CubeGarden 相关方 |
| `game/vocal/*.wav` | 本仓库 `scripts/gen_beeps.py` 生成 | 占位嘟嘟声，无版权风险 |

本仓库以公开演示形式发布；若需商业使用其中任一素材，请联系 CubeGarden Studio。
## Phase 5 新增素材

| 素材 | 来源 | 说明 |
| :--- | :--- | :--- |
| `game/puppet/sion.inp` | 本仓库 `scripts/gen_sion_puppet.py` 生成 | Sion 的 Inochi2D 木偶（纯标准库程序化绘制，无外部资产），许可随本仓库演示条款 |
| `game/lua/snake.lua` | Axolotl 引擎 `crates/axolotl-lua/scripts/snake.lua`（Phase 4 示例） | 沙箱 LUA 贪吃蛇教学脚本，复用至 demo |
