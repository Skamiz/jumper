local SIZE = 200
local DISTORTION = 0.5
local points = {}
local sides = {}
local cells = {}

local t0 = os.clock()

local per1 = 1/SIZE
for i = 1, SIZE do
    for j = 1, SIZE do
        points[#points + 1] = {
            x = (j-0.5)/SIZE + (per1*math.random()*DISTORTION*2-per1*DISTORTION),
            y = (i-0.5)/SIZE + (per1*math.random()*DISTORTION*2-per1*DISTORTION),
            z = 0,
            exiting = {},
        }
    end
end

for i = 1, SIZE - 1 do
    for j = 1, SIZE - 1 do
        local cell = {}
        local cellN = #cells + 1

        local p1 = ((i-1)*SIZE) + j
        local p2 = p1 + 1
        local p3 = p2 + SIZE
        local p4 = p1 + SIZE

        local sideStart = #sides
        local s1, s2, s3, s4 = sideStart + 1, sideStart + 2, sideStart + 3, sideStart + 4
        sides[s1] = {from = p1, to = p2, cell = cellN, next = s2}
        sides[s2] = {from = p2, to = p3, cell = cellN, next = s3}
        sides[s3] = {from = p3, to = p4, cell = cellN, next = s4}
        sides[s4] = {from = p4, to = p1, cell = cellN, next = s1}

        table.insert(points[p1].exiting, s1)
        table.insert(points[p2].exiting, s2)
        table.insert(points[p3].exiting, s3)
        table.insert(points[p4].exiting, s4)

        cell.sides = {s1, s2, s3, s4}

        cells[cellN] = cell
    end
end
local ops = 0
for _, v in pairs(sides) do
    for _, w in pairs(points[v.to].exiting) do
        if sides[w].to == v.from then
            v.opposite = w
            ops = ops + 1
        end
    end
end

local t1 = os.clock()


print("number of points is :" .. #points)
print("number of sides is :" .. #sides)
print("number of cells is :" .. #cells)
print("number of oposites is :" .. ops)
print("time to make graph is: " .. t1 - t0)

local function getTouching(n)
    local touching = {}
    for _, v in pairs(cells[n].sides) do
        table.insert(touching, sides.opposite.cell)
    end
    return  touching
end

local function getCenter(n)
    local x, y = 0, 0
    for _, s in pairs(cells[n].sides) do
        x = x + points[sides[s].from].x
        y = y + points[sides[s].from].y
    end
    return {x = x/4, y = y/4}
end

--HEIGHT calculation
local tecRegionNumber = 3
local tecRegions = {}
for i = 1, tecRegionNumber do
    local direction = {x = math.random(100) - 50, y = math.random(100) - 50}
    tecRegions[i] = {
        color = {r = math.random(), g = math.random(), b = math.random()},
        cells = {},
        direction = direction
    }

end

for k, v in pairs(cells) do
    local r = math.random(tecRegionNumber)
    v.tecReg = r
    table.insert(tecRegions[r].cells, k)
end


--BEGINNIG OF DRAWING SECTION
local g = love.graphics
local lightDir = 0

local t2 = os.clock()

local function drawCell(n, color)
    local vertices = {}
    -- local r, g_, b, a = g.getColor()
    for _, v in pairs(cells[n].sides) do
        table.insert(vertices, points[sides[v].from].x)
        table.insert(vertices, points[sides[v].from].y)
    end
    g.setColor(color.r, color.g, color.b, color.a)
    g.polygon("fill", vertices)
    -- g.setColor(r, g_, b, a)
end

local width = g.getWidth()
local height = g.getHeight()
for _, v in pairs(points) do
    v.x = v.x * width
    v.y = v.y * height
end

local canvas = g.newCanvas()
g.setCanvas(canvas)

g.setBackgroundColor(0, 0.2, 0.8)

for k, v in pairs(cells) do
    drawCell(k, tecRegions[v.tecReg].color)
    local center = getCenter(k)
    g.setColor(1, 1, 1)
    g.line(center.x, center.y, center.x + tecRegions[v.tecReg].direction.x, center.y + tecRegions[v.tecReg].direction.y)
    g.setPointSize(3)
    g.points(center.x, center.y)
    g.setPointSize(1)
end

g.setColor(0, 0, 0)
for _, v in pairs(sides) do
    -- if not v.opposite then
        g.line(points[v.from].x, points[v.from].y, points[v.to].x, points[v.to].y)
    -- end
end

g.setColor(1, 0, 0)
g.setPointSize(3)
for _, v in pairs(points) do
    g.points(v.x, v.y)
end

g.setCanvas()
g.setColor(1, 1, 1)
function love.draw()
    g.draw(canvas)
end

local t3 = os.clock()
print("time to draw graph is: " .. t3 - t2)

function love.update(dt)
   if dt < 1/30 then
      love.timer.sleep(1/30 - dt)
   end
end
