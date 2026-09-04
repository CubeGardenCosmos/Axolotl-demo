-- 虚拟键盘（Virtual Pad）模板库 —— Axolotl LUA 场景共享 prelude
--
-- 用途：`runLua:` 全屏小游戏 / 交互场景的**触屏虚拟按键**。由引擎在场景
-- 脚本之前自动注入（`lua/vpad.lua` 属于场景 prelude，缺失时跳过），本文件
-- 只依赖公开 LUA API（`axolotl.gui.rect/text_at`、`axolotl.on("touch_*")`），
-- 因此**开发者可以在自己的脚本里按同样的思路写自定义触控信号** —— 这里是
-- 模板不是框架。
--
-- 内置两套布局（类似模拟器）：
--   · vpad.enable("dpad") —— 十字键 + A/B 双键（左手十字 + 右手 AB）
--   · vpad.enable("stick") —— 摇杆 + ABXY 四键（左手模拟摇杆 + 右手 ABXY）
--
-- API：
--   vpad.enable(layout) / vpad.disable()
--   vpad.poll()  -> {name,...} 按下边沿（消费式；名字 = 方向/按键）
--   vpad.held(name) -> bool    按住状态（可用于长按/连发）
--   vpad.axis()  -> {dx, dy, mag}  摇杆偏移（画布像素；非摇杆时为 {0,0,0}）
--   vpad.press(name)           合成一个按下边沿（键盘透传可走这里）
--   vpad.draw()                渲染当前布局（每帧调用；内部做了清屏后追加）
--
-- 坐标约定：画布 640×360（与 `axolotl.engine.canvas()` 一致）；触控事件
-- 归一化 (0..1) → 画布坐标 = ×640 / ×360（画布按窗口等比拉伸由引擎处理）。
-- 按键名字与 `axolotl.input.poll()` 的键盘语义一致：up/down/left/right/
-- a/b/x/y（外加 stick 方向边沿也用同一组名字）。

local vpad = {
  _enabled = false,
  _layout = nil,
  _zones = {},
  _held = {},
  _edges = {},
  _captured = {},   -- pointer id -> zone name | "stick"
  _stick = nil,     -- { ox, oy, dx, dy, last_dir }
  _keyboard_map = nil, -- (预留：按键名 → 动作；模板保持简单)
}

local CANVAS_W, CANVAS_H = 640, 360
local STICK_THRESHOLD = 14      -- 摇杆转向边沿阈值（画布像素，≈ 28dp）
local STICK_RADIUS = 40         -- 摇杆最大偏移（画布像素）
local ZONE_C = "#272B38"        -- 按键底色
local ZONE_EDGE = "#3A4154"     -- 按键描边（无描边 API：用外扩暗底模拟）
local ZONE_ACTIVE = "#5B6B8F"   -- 按住高亮
local ZONE_BASE = "#20242F"     -- 摇杆底座
local ZONE_KNOB = "#4A5268"     -- 摇杆帽
local LABEL = "#D8DCE8"
local LABEL_DIM = "#6A7288"

-- ---------------------------------------------------------------------------
-- 布局定义（画布坐标矩形；名字 = 语义键名）
-- ---------------------------------------------------------------------------

local function key_zone(name, x, y, w, h)
  return { name = name, x = x, y = y, w = w, h = h, kind = "button" }
end

local function dpad_layout()
  return {
    key = 46,
    zones = {
      key_zone("up", 80, 118, 46, 46),
      key_zone("down", 80, 210, 46, 46),
      key_zone("left", 34, 164, 46, 46),
      key_zone("right", 126, 164, 46, 46),
      key_zone("b", 462, 196, 46, 46),
      key_zone("a", 520, 254, 46, 46),
    },
    labels = {
      { key = "up", glyph = "^" },
      { key = "down", glyph = "v" },
      { key = "left", glyph = "<" },
      { key = "right", glyph = ">" },
      { key = "b", glyph = "B" },
      { key = "a", glyph = "A" },
    },
  }
end

local function stick_layout()
  return {
    stick = key_zone("stick", 30, 150, 140, 140), -- 触控区域（底座外扩）
    stick_center = { x = 100, y = 220 },
    zones = {
      key_zone("x", 516, 178, 40, 40),
      key_zone("y", 464, 236, 40, 40),
      key_zone("b", 516, 294, 40, 40),
      key_zone("a", 568, 236, 40, 40),
    },
    labels = {
      { key = "x", glyph = "X" },
      { key = "y", glyph = "Y" },
      { key = "b", glyph = "B" },
      { key = "a", glyph = "A" },
    },
  }
end

-- ---------------------------------------------------------------------------
-- 命中 / 状态
-- ---------------------------------------------------------------------------

local function hit(cx, cy)
  if vpad._layout and vpad._layout.stick then
    local s = vpad._layout.stick
    if cx >= s.x and cx <= s.x + s.w and cy >= s.y and cy <= s.y + s.h then
      return "stick"
    end
  end
  for _, z in ipairs(vpad._zones) do
    if cx >= z.x and cx <= z.x + z.w and cy >= z.y and cy <= z.y + z.h then
      return z.name
    end
  end
  return nil
end

local function push_edge(name)
  if name then
    for _, existing in ipairs(vpad._edges) do
      if existing == name then return end
    end
    table.insert(vpad._edges, name)
  end
end

local function stick_direction(dx, dy, mag)
  if mag < STICK_THRESHOLD then return nil end
  if math.abs(dx) > math.abs(dy) then
    return dx > 0 and "right" or "left"
  end
  return dy > 0 and "down" or "up"
end

local function stick_updated(dx, dy)
  local mag = math.sqrt(dx * dx + dy * dy)
  if mag > STICK_RADIUS then
    dx, dy = dx / mag * STICK_RADIUS, dy / mag * STICK_RADIUS
    mag = STICK_RADIUS
  end
  vpad._stick.dx, vpad._stick.dy, vpad._stick.mag = dx, dy, mag
  local dir = stick_direction(dx, dy, mag)
  if dir and dir ~= vpad._stick.last_dir then
    push_edge(dir) -- 摇杆拨过阈值 → 方向边沿（蛇每步读一次足够）
  end
  if not dir then
    vpad._stick.last_dir = nil -- 回中后允许同一方向再次触发
  else
    vpad._stick.last_dir = dir
  end
end

-- ---------------------------------------------------------------------------
-- 触控事件（prelude 注册；坐标：归一化 → 画布）
-- ---------------------------------------------------------------------------

local function to_canvas(nx, ny)
  return nx * CANVAS_W, ny * CANVAS_H
end

local function on_pressed(id, nx, ny)
  -- 设备端诊断（每次按下 1 行）：确认触控确实到达场景沙箱。
  axolotl.log(string.format("vpad: touch_pressed id=%s x=%.3f y=%.3f", id, nx, ny))
  local cx, cy = to_canvas(nx, ny)
  local name = hit(cx, cy)
  if name == "stick" then
    vpad._stick = { ox = cx, oy = cy, dx = 0, dy = 0, mag = 0, last_dir = nil }
    vpad._captured[id] = "stick"
  elseif name then
    vpad._captured[id] = name
    vpad._held[name] = true
    push_edge(name)
    axolotl.log(string.format("vpad: press %s", name))
  end
end

local function on_moved(id, nx, ny)
  local cx, cy = to_canvas(nx, ny)
  if vpad._captured[id] == "stick" and vpad._stick then
    stick_updated(cx - vpad._stick.ox, cy - vpad._stick.oy)
  end
end

local function on_released(id, nx, ny)
  local captured = vpad._captured[id]
  vpad._captured[id] = nil
  if captured == "stick" and vpad._stick then
    -- 抬起时若仍有足够偏移 → 再补一次方向边沿（快速拨动不落空）。
    local dir = stick_direction(vpad._stick.dx, vpad._stick.dy, vpad._stick.mag)
    if dir then
      push_edge(dir)
      axolotl.log(string.format("vpad: stick %s", dir))
    end
    vpad._stick = nil
  elseif captured then
    vpad._held[captured] = false
  end
end

pcall(function()
  axolotl.on("touch_pressed", on_pressed)
  axolotl.on("touch_moved", on_moved)
  axolotl.on("touch_released", on_released)
end)

-- ---------------------------------------------------------------------------
-- 公开 API
-- ---------------------------------------------------------------------------

--- 自定义触控区（只命中、不内置渲染）：供脚本自绘菜单/按钮使用。
--- zones = {{name=.., x=.., y=.., w=.., h=.., kind="button"}, ...}
function vpad.custom(zones)
  vpad._enabled = true
  vpad._layout = nil
  vpad._zones = {}
  if zones then
    for _, z in ipairs(zones) do table.insert(vpad._zones, z) end
  end
  vpad._held = {}
  vpad._edges = {}
  vpad._captured = {}
  vpad._stick = nil
end

--- 启用某套布局；重复调用幂等（先清空再重建）。
function vpad.enable(layout)
  vpad._enabled = true
  vpad._layout = layout == "stick" and stick_layout() or dpad_layout()
  vpad._zones = {}
  for _, z in ipairs(vpad._layout.zones) do table.insert(vpad._zones, z) end
  vpad._held = {}
  vpad._edges = {}
  vpad._captured = {}
  vpad._stick = nil
end

function vpad.disable()
  vpad._enabled = false
  vpad._layout = nil
  vpad._zones = {}
  vpad._held = {}
  vpad._captured = {}
  vpad._stick = nil
end

--- 消费所有按下边沿（返回表；名字见上）。
function vpad.poll()
  local out = vpad._edges
  vpad._edges = {}
  return out
end

--- 按住状态查询。
function vpad.held(name)
  return vpad._held[name] == true
end

--- 摇杆偏移（画布像素；非摇杆布局恒 {0,0,0}）。
function vpad.axis()
  if not vpad._stick then return { dx = 0, dy = 0, mag = 0 } end
  return { dx = vpad._stick.dx, dy = vpad._stick.dy, mag = vpad._stick.mag }
end

--- 合成一个按下边沿（键盘透传：把 `input.poll()` 的键喂进来再统一消费）。
function vpad.press(name)
  push_edge(name)
end

--- 渲染当前布局（需在 `axolotl.gui.clear()` 之后、帧末调用；头/widget
--- 画布模式自动忽略定位文本以外的元素 —— 本函数只画色块/定位文本）。
function vpad.draw()
  if not vpad._enabled or not vpad._layout then return end
  local layout = vpad._layout
  for _, z in ipairs(layout.zones) do
    local active = vpad._held[z.name] == true
    -- 外扩暗底（描边感）+ 主底色。
    axolotl.gui.rect(z.x - 2, z.y - 2, z.w + 4, z.h + 4, ZONE_EDGE)
    axolotl.gui.rect(z.x, z.y, z.w, z.h, active and ZONE_ACTIVE or ZONE_C)
  end
  if layout.stick then
    local s = layout.stick
    axolotl.gui.rect(s.x - 2, s.y - 2, s.w + 4, s.h + 4, ZONE_EDGE)
    axolotl.gui.rect(s.x, s.y, s.w, s.h, ZONE_BASE)
    local kx, ky = layout.stick_center.x, layout.stick_center.y
    if vpad._stick then
      kx = math.max(s.x + 6, math.min(s.x + s.w - 40, kx + vpad._stick.dx))
      ky = math.max(s.y + 6, math.min(s.y + s.h - 40, ky + vpad._stick.dy))
    end
    axolotl.gui.rect(kx, ky, 40, 40, ZONE_KNOB)
    axolotl.gui.text_at(layout.stick_center.x + 10, layout.stick_center.y + 2, "S", 18, LABEL_DIM)
  end
  for _, lb in ipairs(layout.labels) do
    local z = nil
    for _, zz in ipairs(layout.zones) do
      if zz.name == lb.key then z = zz break end
    end
    if z then
      -- 字符居中近似（等宽 ASCII 语义足够）：向右 1/3、向下 1/4。
      axolotl.gui.text_at(z.x + z.w * 0.28, z.y + z.h * 0.22, lb.glyph, 24, LABEL)
    end
  end
end

-- 暴露为全局（场景脚本使用 `vpad.*`）。
_G.vpad = vpad
return vpad