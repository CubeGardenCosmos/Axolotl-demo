-- 画布标题屏（Title Screen，左右布局）—— Axolotl Phase 4 标题屏模板
--
-- 引擎 boot 链检测到本文件（`lua/title_screen.lua`）后以**画布标题场景**
-- 启动（替代 bevy 居中覆盖层；缺失时引擎降级覆盖层）。本脚本只依赖公开
-- API：
--   · 标题动作 → `axolotl.title.action(name)`（new_game / continue / load /
--     settings / quit）汇入引擎 TitleAction 管线（复用既有 start_story /
--     restore_from_snapshot / 覆盖层 / AppExit 效果）；
--   · 「继续 / 读档」用**存档面 API** 画布内自绘（`axolotl.save.list()`
--     `read()` `load()`，字段 `index/exists/title/saved_at_unix/is_auto`）；
--   · 返回键：主菜单态**不消费**（返回 false → 引擎缺省**两击退出**，LUA
--     每帧读 `axolotl.platform.back_armed()` 自绘提示）；读档网格态消费
--     back（返回 true）→ 回主菜单。
--
-- 无头（CI）：确定性自推演（`menu_autochoice` 可强制任一路径，缺省
-- new_game）——保持与既有 headless 自动解析标题的行为 parity。
--
-- 布局（评审冻结）：左侧菜单列（新游戏/继续/读档/设置/退出）+ 右侧
-- 品牌/角色占位区；画布 640×360，触控命中 = vpad.custom 自定义区，
-- 不自建引擎 UI。

if not axolotl.engine.scene_active() then
  return -- boot 层不注册（与 snake.lua / title_menu.lua 同一守卫惯例）
end

if axolotl.engine.headless() then
  local forced = axolotl.var.get("menu_autochoice")
  if not forced or #forced == 0 then
    forced = "new_game"
  end
  axolotl.log(string.format("title_screen: headless auto action %s", forced))
  axolotl.title.action(forced)
  return
end

local C = axolotl.engine.canvas()
local W, H = C.w, C.h

-- ---------------------------------------------------------------------------
-- 视觉 token（与 title_menu.lua 同一套）
-- ---------------------------------------------------------------------------
local C_EDGE = "#3A4154"
local C_BTN = "#252A38"
local C_BTN_ACTIVE = "#5B6B8F"
local C_BTN_DISABLED = "#1C2130"
local C_TEXT = "#E4E8F2"
local C_TEXT_DIM = "#8A90A4"
local C_PANEL = "#1B1F2B"
local C_ACCENT = "#C89B5A"
local C_WARN = "#D98A48"

-- ---------------------------------------------------------------------------
-- 存档面查询（继续按钮可用性 / 读档网格数据）
-- ---------------------------------------------------------------------------
local function latest_save()
  local best = nil
  for _, row in ipairs(axolotl.save.list()) do
    if row.exists and not row.is_auto then
      if not best or (row.saved_at_unix or 0) > (best.saved_at_unix or 0) then
        best = row
      end
    end
  end
  return best
end

-- 简化公历（UTC；沙箱无 os，自己算）
local function fmt_date(u)
  if not u then return "" end
  local days = math.floor(u / 86400)
  local y = 1970
  while true do
    local leap = (y % 4 == 0 and y % 100 ~= 0) or y % 400 == 0
    local ylen = leap and 366 or 365
    if days < ylen then break end
    days = days - ylen
    y = y + 1
  end
  local leap = (y % 4 == 0 and y % 100 ~= 0) or y % 400 == 0
  local mdays = { 31, leap and 29 or 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
  local m = 1
  while days >= mdays[m] do
    days = days - mdays[m]
    m = m + 1
  end
  local d = days + 1
  local hh = math.floor((u % 86400) / 3600)
  local mm = math.floor((u % 3600) / 60)
  return string.format("%04d-%02d-%02d %02d:%02d", y, m, d, hh, mm)
end

-- ---------------------------------------------------------------------------
-- 主菜单（5 按钮；继续随存档可用性灰置）
-- ---------------------------------------------------------------------------
local MENU_X, MENU_W, MENU_H, MENU_GAP = 26, 206, 34, 4
local MENU_Y0 = 26
local ART_X, ART_Y, ART_W, ART_H = 248, 22, W - 248 - 18, H - 22 - 14

local buttons = {
  { id = "new_game", label = "新游戏" },
  { id = "continue", label = "继续" },
  { id = "load",     label = "读档" },
  { id = "settings", label = "设置" },
  { id = "quit",     label = "退出" },
}

-- 每次重建命中区（继续灰置时不给 zone —— 点了也没效果）。
local function install_menu_zones()
  local zones = {}
  for i, b in ipairs(buttons) do
    if not (b.id == "continue" and not b.enabled) then
      table.insert(zones, {
        name = b.id,
        x = MENU_X,
        y = MENU_Y0 + (i - 1) * (MENU_H + MENU_GAP),
        w = MENU_W,
        h = MENU_H,
        kind = "button",
      })
    end
  end
  vpad.custom(zones)
end

local function refresh_continue()
  local latest = latest_save()
  for _, b in ipairs(buttons) do
    if b.id == "continue" then
      b.enabled = latest ~= nil
      b.label = latest and ("继续 · " .. (latest.title or ("槽 " .. latest.index + 1)))
                or "继续"
      b.preview = latest
    end
  end
end

local function draw_art()
  axolotl.gui.rect(ART_X, ART_Y, ART_W, ART_H, C_PANEL)
  axolotl.gui.rect(ART_X, ART_Y, ART_W, 3, C_ACCENT)
  local cx = ART_X + ART_W / 2
  local cy = ART_Y + ART_H / 2 - 8
  axolotl.gui.rect(cx - 26, cy - 46, 52, 52, "#9DB4C8")
  axolotl.gui.rect(cx - 44, cy + 14, 88, 92, "#7B93B5")
  axolotl.gui.rect(cx - 44, cy - 6, 88, 26, "#E8C8A0")
  axolotl.gui.text_at(ART_X + 14, ART_Y + 12, "AXOLOTL", 30, C_TEXT)
  axolotl.gui.text_at(ART_X + 14, ART_Y + 46, "美西螈引擎 · 主角 Sion", 14, C_ACCENT)
  axolotl.gui.text_at(ART_X + 14, ART_Y + ART_H - 40, "Native Visual Novel Engine", 12, C_TEXT_DIM)
  axolotl.gui.text_at(ART_X + 14, ART_Y + ART_H - 24, "CubeGarden Studio · 版本 0.3.1", 11, C_TEXT_DIM)
  -- 退出因果（killed 时右上角提醒：上次异常退出）。
  if axolotl.platform.exit_cause() == "killed" then
    axolotl.gui.text_at(ART_X + 14, ART_Y + 66, "检测到上次异常退出", 12, C_WARN)
  end
end

local function draw_menu()
  draw_art()
  local latest = latest_save()
  for i, b in ipairs(buttons) do
    local y = MENU_Y0 + (i - 1) * (MENU_H + MENU_GAP)
    if b.id ~= "continue" or b.enabled then
      local active = vpad.held(b.id)
      axolotl.gui.rect(MENU_X - 2, y - 2, MENU_W + 4, MENU_H + 4, C_EDGE)
      axolotl.gui.rect(MENU_X, y, MENU_W, MENU_H, active and C_BTN_ACTIVE or C_BTN)
      axolotl.gui.rect(MENU_X + 8, y + MENU_H / 2 - 3, 6, 6, C_ACCENT)
      axolotl.gui.text_at(MENU_X + 22, y + 8, b.label, 15, C_TEXT)
    else
      axolotl.gui.rect(MENU_X - 2, y - 2, MENU_W + 4, MENU_H + 4, C_EDGE)
      axolotl.gui.rect(MENU_X, y, MENU_W, MENU_H, C_BTN_DISABLED)
      axolotl.gui.text_at(MENU_X + 22, y + 8, "继续（暂无存档）", 15, C_TEXT_DIM)
    end
  end
  -- 最近档预览（继续按钮下方）。
  if latest then
    local y = MENU_Y0 + 5 * (MENU_H + MENU_GAP) + 6
    axolotl.gui.text_at(MENU_X, y, "最近存档：", 12, C_TEXT_DIM)
    axolotl.gui.text_at(MENU_X, y + 20, (latest.title or "") .. " · " .. fmt_date(latest.saved_at_unix), 12, C_ACCENT)
  end
  -- back 两击退出提示（engine 缺省武装，LUA 自绘）。
  if axolotl.platform.back_armed() then
    axolotl.gui.text_at(MENU_X, H - 34, "再按一次返回键退出游戏", 14, C_WARN)
  end
end

-- ---------------------------------------------------------------------------
-- 读档画布网格（存档面自绘；选槽 → save.load(i) 引擎恢复并整体收走标题）
-- ---------------------------------------------------------------------------
local mode = "menu"

local function install_load_zones()
  local zones = {}
  local rows = axolotl.save.list()
  local x, w, hh, gap = 26, 330, 40, 4
  local y0 = 26
  for i, row in ipairs(rows) do
    if row.exists then
      table.insert(zones, {
        name = string.format("load_%d", row.index),
        x = x,
        y = y0 + (i - 1) * (hh + gap),
        w = w,
        h = hh,
        kind = "button",
      })
    end
  end
  -- 右上「返回」。
  table.insert(zones, { name = "back", x = W - 120, y = 22, w = 100, h = 30, kind = "button" })
  vpad.custom(zones)
end

local function draw_grid()
  axolotl.gui.clear()
  axolotl.gui.rect(0, 0, W, H, "#141824")
  axolotl.gui.text_at(24, 8, "读档 （画布网格 · axolotl.save.list）", 16, C_TEXT)
  axolotl.gui.rect(W - 122, 20, 104, 34, C_BTN)
  axolotl.gui.text_at(W - 104, 28, "返回", 14, C_TEXT)
  local rows = axolotl.save.list()
  local y0 = 26
  for i, row in ipairs(rows) do
    local y = y0 + (i - 1) * 44
    if row.exists then
      local active = vpad.held(string.format("load_%d", row.index))
      axolotl.gui.rect(24, y, 336, 40, active and C_BTN_ACTIVE or C_BTN)
      axolotl.gui.rect(24, y, 4, 40, C_ACCENT)
      local tag = row.is_auto and "[自动档] " or ""
      axolotl.gui.text_at(34, y + 5, tag .. (row.title or ("槽位 " .. row.index + 1)), 14, C_TEXT)
      axolotl.gui.text_at(34, y + 23, fmt_date(row.saved_at_unix), 11, C_TEXT_DIM)
    else
      axolotl.gui.rect(24, y, 336, 40, C_BTN_DISABLED)
      axolotl.gui.text_at(34, y + 12, string.format("空存档位 %d", row.index + 1), 13, C_TEXT_DIM)
    end
  end
end

-- ---------------------------------------------------------------------------
-- 命中处理（vpad.poll 边沿）
-- ---------------------------------------------------------------------------
local function on_hit(name)
  if mode == "menu" then
    if name == "new_game" then
      axolotl.log("title_screen: action new_game")
      axolotl.title.action("new_game")
    elseif name == "continue" then
      axolotl.log("title_screen: action continue")
      axolotl.title.action("continue")
    elseif name == "load" then
      mode = "loadgrid"
      install_load_zones()
    elseif name == "settings" then
      axolotl.log("title_screen: action settings")
      axolotl.title.action("settings")
    elseif name == "quit" then
      axolotl.log("title_screen: action quit")
      axolotl.title.action("quit")
    end
  elseif mode == "loadgrid" then
    if name == "back" then
      mode = "menu"
      refresh_continue()
      install_menu_zones()
      return
    end
    local idx = tonumber(name:match("^load_(%d+)$"))
    if idx then
      axolotl.log(string.format("title_screen: load slot %d", idx))
      axolotl.save.load(idx)
    end
  end
end

-- ---------------------------------------------------------------------------
-- back：读档网格态消费（返回主菜单）；主菜单态不消费 → 引擎两击退出
-- ---------------------------------------------------------------------------
axolotl.on("back", function()
  if mode == "loadgrid" then
    axolotl.log("title_screen: back consumed (grid → menu)")
    mode = "menu"
    refresh_continue()
    install_menu_zones()
    return true
  end
  return false
end)

-- ---------------------------------------------------------------------------
-- 帧循环
-- ---------------------------------------------------------------------------
local function frame(dt)
  axolotl.gui.clear()
  if mode == "menu" then
    draw_menu()
  else
    draw_grid()
  end
  for _, name in ipairs(vpad.poll()) do
    on_hit(name)
  end
  local _ = dt
end

-- 初始化：菜单可用性 + 命中区。
refresh_continue()
install_menu_zones()
axolotl.on("frame", frame)