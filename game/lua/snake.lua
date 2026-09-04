-- 贪吃蛇示例小游戏（Axolotl LUA 脚本层 · 全屏独立场景）
--
-- 由剧本 `runLua:snake.lua -result=snake_result;` 启动：引擎以独立沙箱
-- 实例执行本脚本（`axolotl.engine.scene_active() == true`），游戏画面被
-- 全屏场景画布接管——相对引擎虚拟画布 640×360 的“精灵矩形”渲染
-- （`axolotl.gui.clear/rect/text`）。退出条件 = **失败**：撞墙或咬到
-- 自己即 `axolotl.scene.exit("over")`，剧本从 `runLua:` 后续继续。
--
-- 结果桥（用户契约的 %0/%1 语义）：
--   · `axolotl.var.set("snake_score", …)` / `snake_state` 直接维护剧本变量，
--     剧本剧情据此分支（LUA 允许完全接管脚本变量）；
--   · `-result=` 收到 `axolotl.scene.end` 的退出结果（这里是 "over"）。
--
-- 无头（CI）：`axolotl.engine.headless() == true` 时进入确定性自推演——
-- 固定随机种子 + 贪心 AI + 固定步数后强制触壁，保证同输入必得同棋盘、
-- 同得分（三后端 / 多次运行整场 parity 可复现），并以“失败”自然结束。
--
-- API 一览：
--   axolotl.engine.scene_active()/headless()/canvas()   环境信息
--   axolotl.on("frame", fn(dt))                         每帧主循环
--   axolotl.input.poll() / held()                       方向键 / WASD / R
--   axolotl.gui.clear/rect/text/title                   全屏画布渲染
--   axolotl.var.set(name, value, scope)                 写回 axs 变量
--   axolotl.scene.exit(result)（scene["end"] 等价）         结束场景并回报结果
--   axolotl.log(msg)                                    安全日志

-- 只在 `runLua:` 场景里运行本脚本（boot 层加载它时立即返回，不注册任何
-- 处理器——小游戏不叠加在主线内容上，也不在标题界面空转写变量）。
if not axolotl.engine.scene_active() then
  return
end

math.randomseed(20260830) -- 固定种子：同输入必得同棋盘（确定性验收）

local W, H = 22, 14          -- 棋盘内区尺寸（外圈各留一格边框）
local MOVE_INTERVAL = 0.10   -- 每步间隔（秒）
local STATE_READY, STATE_RUNNING, STATE_OVER = "ready", "running", "over"

local canvas = axolotl.engine.canvas()
local cell = math.floor(math.min(canvas.w / (W + 2), canvas.h / (H + 2)))
local board_w, board_h = cell * (W + 2), cell * (H + 2)
local x0 = math.floor((canvas.w - board_w) / 2)   -- 棋盘左上角（画布像素）
local y0 = math.floor((canvas.h - board_h) / 2)

-- 颜色（画布精灵）：边框 / 食物 / 蛇身 / 蛇头 / 文本
local C_BORDER, C_FOOD, C_BODY, C_HEAD, C_HINT = "#4a5a6a", "#e74c3c", "#2ecc71", "#27ae60", "#e8e2d0"

local snake, dir, queued, grow, food, score, state, timer
local headless_ai = axolotl.engine.headless()
local headless_moves = 0   -- 无头自推演的步数（强制触壁前）

local function empty_cells()
  local free = {}
  for y = 1, H do
    for x = 1, W do
      local busy = false
      for _, s in ipairs(snake) do
        if s[1] == x and s[2] == y then busy = true break end
      end
      if not busy then free[#free + 1] = { x, y } end
    end
  end
  return free
end

local function spawn_food()
  local free = empty_cells()
  if #free == 0 then return end
  local pick = free[math.random(#free)]
  food = { pick[1], pick[2] }
end

local function new_board()
  snake = { { math.floor(W / 2), math.floor(H / 2) }, { math.floor(W / 2) - 1, math.floor(H / 2) } }
  dir = { 1, 0 }
  queued = nil
  grow = 0
  score = 0
  state = STATE_READY
  timer = 0
  spawn_food()
end

local function occupied(x, y, ignore_tail)
  local length = #snake - (ignore_tail and 1 or 0)
  for i = 1, length do
    local s = snake[i]
    if s[1] == x and s[2] == y then return true end
  end
  return false
end

local function head()
  return snake[1][1], snake[1][2]
end

local function set_dir(dx, dy)
  -- 防一步两转：与当前方向同向/反向的输入本步忽略。
  if (dx == 0 and dy == 0) or (dx == dir[1] and dy == dir[2])
    or (dx == -dir[1] and dy == -dir[2]) then
    return
  end
  queued = { dx, dy }
end

local function try_move(dx, dy)
  local hx, hy = head()
  local nx, ny = hx + dx, hy + dy
  if nx < 1 or nx > W or ny < 1 or ny > H then return -1 end         -- 撞墙
  if occupied(nx, ny, false) then return -2 end                      -- 咬自己
  table.insert(snake, 1, { nx, ny })
  if food and nx == food[1] and ny == food[2] then
    score = score + 1
    grow = grow + 1
    spawn_food()
  else
    if grow > 0 then grow = grow - 1 else table.remove(snake) end
  end
  return 0
end

local function die()
  state = STATE_OVER
end

-- 无头自推演：贪心朝食物走；撞脸/无路或走到固定步数时强制触壁，保证以
-- “失败”结束且全程确定性（种子固定 → 食物序列固定 → 路径固定）。
local dirs = { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }
local function headless_step()
  headless_moves = headless_moves + 1
  if headless_moves >= 90 then
    -- 直接反向（不经过 set_dir 的反向拒绝）：下一步必撞自己 → 失败结束。
    dir = { -dir[1], -dir[2] }
    return
  end
  local hx, hy = head()
  if not food then return end
  local best, best_d = nil, nil
  for _, d in ipairs(dirs) do
    if not (d[1] == -dir[1] and d[2] == -dir[2]) then
      local nx, ny = hx + d[1], hy + d[2]
      if nx >= 1 and nx <= W and ny >= 1 and ny <= H and not occupied(nx, ny, true) then
        local dist = math.abs(nx - food[1]) + math.abs(ny - food[2])
        if not best_d or dist < best_d then
          best, best_d = d, dist
        end
      end
    end
  end
  if best then
    set_dir(best[1], best[2])
  end
end

local function step()
  if state ~= STATE_RUNNING and state ~= STATE_READY then return end
  if queued then
    dir = queued
    queued = nil
    if state == STATE_READY then state = STATE_RUNNING end
  elseif state == STATE_READY and headless_ai then
    state = STATE_RUNNING
  end
  if state ~= STATE_RUNNING then return end
  if headless_ai then headless_step() end
  local result = try_move(dir[1], dir[2])
  if result < 0 then die() end
end

local function draw()
  axolotl.gui.clear()
  -- 边框。
  axolotl.gui.rect(x0, y0, board_w, cell, C_BORDER)
  axolotl.gui.rect(x0, y0 + board_h - cell, board_w, cell, C_BORDER)
  axolotl.gui.rect(x0, y0, cell, board_h, C_BORDER)
  axolotl.gui.rect(x0 + board_w - cell, y0, cell, board_h, C_BORDER)
  -- 食物。
  if food then
    axolotl.gui.rect(
      x0 + food[1] * cell, y0 + food[2] * cell, cell, cell, C_FOOD)
  end
  -- 蛇（头在前）。
  for i, s in ipairs(snake) do
    axolotl.gui.rect(
      x0 + s[1] * cell, y0 + s[2] * cell, cell, cell,
      i == 1 and C_HEAD or C_BODY)
  end
  -- 状态行 + 操作提示。
  axolotl.gui.text(string.format("贪吃蛇 · 得分 %d · %s", score, state))
  if state == STATE_OVER then
    axolotl.gui.text("撞墙 / 咬到自己 —— 游戏结束，返回剧本。")
  elseif headless_ai then
    axolotl.gui.text("无头自推演：固定种子 + 贪心 AI（CI 确定性验收）。")
  else
    axolotl.gui.text("虚拟键盘 / 方向键 / WASD 移动；R 重开棋盘；失败即退出。")
  end
end

axolotl.on("frame", function(dt)
  if state == STATE_OVER then
    axolotl.log(string.format("snake over: score=%d state=%s", score, state))
    axolotl.scene.exit("over")
    return
  end
  -- 输入：统一走 vpad 总线（触屏虚拟键盘边沿 + 键盘透传）。
  local steps = axolotl.input.poll()
  for _, key in ipairs(steps) do
    vpad.press(key)
  end
  for _, key in ipairs(vpad.poll()) do
    if key == "up" or key == "w" then set_dir(0, -1)
    elseif key == "down" or key == "s" then set_dir(0, 1)
    elseif key == "left" or key == "a" then set_dir(-1, 0)
    elseif key == "right" or key == "d" then set_dir(1, 0)
    elseif key == "r" then new_board()
    end
  end
  -- 步进计时（无头用固定 dt，行为不随机器速度漂移）。
  timer = timer + dt
  while timer >= MOVE_INTERVAL do
    timer = timer - MOVE_INTERVAL
    step()
  end
  draw()
  if not headless_ai then
    vpad.draw()
  end
  -- 结果桥：变量由 LUA 完全维护，剧本直接读取分支。
  axolotl.var.set("snake_state", state, "normal")
  axolotl.var.set("snake_score", score, "normal")
end)

new_board()
if not headless_ai then
  -- 触屏设备默认十字键 + AB 布局（脚本作者可改 enable("stick")）。
  vpad.enable("dpad")
end
axolotl.log(string.format(
  "snake scene ready: %dx%d cell=%d headless=%s", W, H, cell, tostring(headless_ai)))