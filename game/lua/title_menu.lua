-- 主菜单（左右布局）—— Axolotl LUA 场景模板示例
--
-- 由 `start.axs` 以 `runLua:title_menu.lua -result=menu_choice;` 调用：
-- 全屏画布绘制**移动端主菜单**（左侧菜单列 + 右侧角色/品牌区），触控走
-- `vpad.custom` 命中区，结果经 `axolotl.scene.exit(chapter)` 回写剧本变量
-- `menu_choice`，`start.axs` 按值跳转对应章节。
--
-- 设计约束（用户评审 2026-09-04）：
--   · 主菜单必须用**画布**实现（左右布局），不是沿用 PC 版引擎居中菜单；
--   · 交互（按钮命中/按下反馈）全部走 LUA（vpad 模板），引擎只提供
--     gui.rect/text_at 与触摸事件 API。
-- 无头（CI）：确定性自推演——直接选「线性巡礼」，保证整场 parity 复现。

if not axolotl.engine.scene_active() then
  return -- boot 层不注册（与 snake.lua 同一守卫惯例）
end

-- 无头自推演：确定性第一项（线性巡礼）；若剧本预置了
-- `menu_autochoice`（如 `setVar:menu_autochoice=ch_snake -global;`）则改选该项，
-- 供分支链的非首项路径做无头回归覆盖。
if axolotl.engine.headless() then
  local forced = axolotl.var.get("menu_autochoice")
  if forced and #forced > 0 then
    axolotl.log(string.format("title_menu: headless auto-select %s (forced)", forced))
    axolotl.scene.exit(forced)
  else
    axolotl.log("title_menu: headless auto-select begin_tour")
    axolotl.scene.exit("begin_tour")
  end
  return
end

local C = axolotl.engine.canvas() -- 640×360
local W, H = C.w, C.h

-- ---------------------------------------------------------------------------
-- 左侧菜单（与 start.axs 的章节 label 一一对应；9 项 × 32px = 288 < 360）
-- ---------------------------------------------------------------------------
local MENU = {
  { id = "begin_tour", label = "线性巡礼（Sion 全程导游）" },
  { id = "ch_prologue", label = "序章 · 深夜来电" },
  { id = "ch_stage", label = "舞台演出席" },
  { id = "ch_audio", label = "音频演播室 · 混音台" },
  { id = "ch_inochi", label = "Live2D 角色演出" },
  { id = "ch_3d", label = "3D 场景演示" },
  { id = "ch_snake", label = "LUA 贪吃蛇" },
  { id = "ch_logic", label = "逻辑与控制流" },
  { id = "quit", label = "结束演示" },
}
local MENU_X, MENU_W, MENU_H, MENU_GAP = 26, 206, 30, 2
local MENU_Y0 = 22
local C_EDGE = "#3A4154"      -- 按钮描边
local C_BTN = "#252A38"       -- 按钮底色
local C_BTN_ACTIVE = "#5B6B8F"
local C_TEXT = "#E4E8F2"
local C_PANEL = "#1B1F2B"     -- 右侧面板
local C_ACCENT = "#C89B5A"    -- 金色强调
local C_DIM = "#7A8296"

-- vpad 命中区（id = 章节 label）；无内置渲染，按钮视觉由本脚本自绘。
local zones = {}
for i, item in ipairs(MENU) do
  table.insert(zones, {
    name = item.id,
    x = MENU_X,
    y = MENU_Y0 + (i - 1) * (MENU_H + MENU_GAP),
    w = MENU_W,
    h = MENU_H,
    kind = "button",
  })
end
vpad.custom(zones)

-- 右侧角色/品牌区（占位立绘：面板 + 简单剪影 + 标题；真立绘由 demo 数据
-- 层替换，布局接口不变）。
local ART_X, ART_Y, ART_W, ART_H = 248, 22, W - 248 - 18, H - 22 - 14

local function draw_art()
  axolotl.gui.rect(ART_X, ART_Y, ART_W, ART_H, C_PANEL)
  axolotl.gui.rect(ART_X, ART_Y, ART_W, 3, C_ACCENT) -- 顶线
  -- 剪影（占位：头 + 身 + 发色块）。
  local cx = ART_X + ART_W / 2
  local cy = ART_Y + ART_H / 2 - 8
  axolotl.gui.rect(cx - 26, cy - 46, 52, 52, "#9DB4C8") -- 头
  axolotl.gui.rect(cx - 44, cy + 14, 88, 92, "#7B93B5") -- 身
  axolotl.gui.rect(cx - 44, cy - 6, 88, 26, "#E8C8A0") -- 刘海
  axolotl.gui.text_at(ART_X + 14, ART_Y + 12, "AXOLOTL", 30, C_TEXT)
  axolotl.gui.text_at(ART_X + 14, ART_Y + 46, "美西螈引擎 · 主角 Sion", 14, C_ACCENT)
  axolotl.gui.text_at(ART_X + 14, ART_Y + ART_H - 40, "Native Visual Novel Engine", 12, C_DIM)
  axolotl.gui.text_at(ART_X + 14, ART_Y + ART_H - 24, "CubeGarden Studio · 版本 0.3.1", 11, C_DIM)
end

-- 每帧：清屏 → 菜单 + 右侧 → vpad 边沿 → 结果。
local function frame(dt)
  axolotl.gui.clear()
  -- 右侧品牌区。
  draw_art()
  -- 左侧菜单按钮 + 标签。
  for i, item in ipairs(MENU) do
    local y = MENU_Y0 + (i - 1) * (MENU_H + MENU_GAP)
    local active = vpad.held(item.id)
    axolotl.gui.rect(MENU_X - 2, y - 2, MENU_W + 4, MENU_H + 4, C_EDGE)
    axolotl.gui.rect(MENU_X, y, MENU_W, MENU_H, active and C_BTN_ACTIVE or C_BTN)
    -- 金色序号点（左缘）。
    axolotl.gui.rect(MENU_X + 8, y + MENU_H / 2 - 3, 6, 6, C_ACCENT)
    axolotl.gui.text_at(MENU_X + 22, y + 6, item.label, 14, C_TEXT)
  end
  -- 触控：命中即离开场景，结果写回 -result。
  for _, name in ipairs(vpad.poll()) do
    axolotl.log(string.format("title_menu: choice %s", name))
    axolotl.scene.exit(name)
    return
  end
  local _ = dt
end
axolotl.on("frame", frame)

axolotl.log("title_menu: ready (left-right layout, touch via vpad)")