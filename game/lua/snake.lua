-- 贪吃蛇示例小游戏（Axolotl LUA 脚本层 · Phase 4）
--
-- 目的：证明 LUA 脚本「只许碰 Axolotl API」即可驱动一个完整可玩的小游戏
-- 循环 —— 输入（axolotl.input）、棋盘渲染（axolotl.gui）、计分（axolotl.var
-- 写回 axs 变量）、胜负状态与重开。脚本不接触任何引擎底层；Phase 5 demo
-- 直接复用本文件（并入 game/lua/ 随清单打包）。
--
-- API 一览：
--   axolotl.on("frame", fn(dt))   每帧回调（游戏主循环挂在这里）
--   axolotl.input.poll()          消费式按键队列（方向 / wasd / r）
--   axolotl.gui.title(str)        覆盖层标题行
--   axolotl.gui.text(str)         覆盖层正文（棋盘）
--   axolotl.var.set(name, value, scope)  写回 axs 变量（存读档语义下可见）
--   axolotl.log(str)              安全日志
--
-- 确定性：固定随机种子 —— 食物序列可复现，供无头整流程回归测试驱动。

math.randomseed(20260830) -- 固定种子：同输入必得同棋盘（确定性验收）

-- 棋盘内区尺寸（外圈还有一圈 # 边框）。
local W, H = 22, 14
local MOVE_INTERVAL = 0.10 -- 每步间隔（秒）
local STATE_READY, STATE_RUNNING, STATE_OVER = "ready", "running", "over"

local snake   -- {{x,y}, ...} 头在前
local dir     -- 当前方向 {dx, dy}
local queued  -- 本步待消费的方向（防一步两转）
local grow    -- 待增长节数
local food    -- 食物 {x, y}
local score   -- 得分
local state   -- ready / running / over
local timer   -- 步进计时器

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
  if #free == 0 then return end -- 棋盘被蛇占满：没有再生成（理论胜利）
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

local function cell(x, y)
  if x < 1 or x > W or y < 1 or y > H then return "#" end
  if food and x == food[1] and y == food[2] then return "$" end
  for i = 2, #snake do
    local s = snake[i]
    if s[1] == x and s[2] == y then return "o" end
  end
  local head = snake[1]
  if head[1] == x and head[2] == y then return "@" end
  return " "
end

local function render()
  local lines = {}
  -- 上边框
  lines[#lines + 1] = string.rep("#", W + 2)
  for y = 1, H do
    local row = "#"
    for x = 1, W do
      row = row .. cell(x, y)
    end
    lines[#lines + 1] = row .. "#"
  end
  lines[#lines + 1] = string.rep("#", W + 2)
  axolotl.gui.title(string.format("贪吃蛇 · 得分 %d (%s)", score, state))
  axolotl.gui.text(table.concat(lines, "\n"))
  -- 计分写回 axs 变量：脚本外（axs / 存档 / 演出）可读。
  axolotl.var.set("snake_score", score, "normal")
  axolotl.var.set("snake_state", state, "normal")
end

local DIRS = {
  up    = { 0, -1 },
  down  = { 0, 1 },
  left  = { -1, 0 },
  right = { 1, 0 },
}

local function consume_input()
  local keys = axolotl.input.poll()
  if keys then
    for _, key in ipairs(keys) do
      local wanted = DIRS[key] or (key == "w" and DIRS.up) or (key == "s" and DIRS.down)
        or (key == "a" and DIRS.left) or (key == "d" and DIRS.right)
      if key == "r" and state == STATE_OVER then
        new_board()
        return
      end
      if wanted then
        -- 禁止一步内 180° 掉头（撞自己）。
        if queued then break end
        local rx, ry = wanted[1], wanted[2]
        if rx == -dir[1] and ry == -dir[2] then
          -- 反向输入被忽略（但回车起步允许）。
          if state == STATE_READY then
            dir = wanted
            state = STATE_RUNNING
            queued = wanted
          end
        else
          queued = wanted
          if state == STATE_READY then state = STATE_RUNNING end
        end
      end
    end
  end
end

local function step()
  if state ~= STATE_RUNNING then return end
  if queued then
    dir = queued
    queued = nil
  end
  local head = snake[1]
  local nx, ny = head[1] + dir[1], head[2] + dir[2]
  -- 撞墙。
  if nx < 1 or nx > W or ny < 1 or ny > H then
    state = STATE_OVER
    return
  end
  -- 撞自己（尾巴即将移开时不算撞）。
  local tail_clears = grow == 0 and #snake > 0
  for i = 1, #snake do
    local s = snake[i]
    if s[1] == nx and s[2] == ny then
      if tail_clears and i == #snake then
        -- 头进尾格：尾巴移走，安全（边界情况）。
      else
        state = STATE_OVER
        return
      end
    end
  end
  -- 前插头。
  table.insert(snake, 1, { nx, ny })
  if food and nx == food[1] and ny == food[2] then
    score = score + 1
    grow = grow + 1
    spawn_food()
  end
  -- 尾巴：不生长则收缩。
  if grow > 0 then
    grow = grow - 1
  else
    table.remove(snake)
  end
end

-- 帧回调：计时步进 + 渲染。
axolotl.on("frame", function(dt)
  consume_input()
  timer = timer + dt
  while timer >= MOVE_INTERVAL do
    timer = timer - MOVE_INTERVAL
    step()
  end
  render()
end)

new_board()
render()
axolotl.log("snake.lua ready: " .. W .. "x" .. H .. ", score=" .. score)