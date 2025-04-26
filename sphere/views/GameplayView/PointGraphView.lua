local gfx_util = require("gfx_util")
local class = require("class")

---@class sphere.PointGraphView
---@operator call: sphere.PointGraphView
local PointGraphView = class()

local vertexformat = {
    {"VertexPosition", "float", 2},
    {"VertexColor", "byte", 4}
}

function PointGraphView:reload()
	self.drawnPoints = 0
	self.vertices = {}
	self.mesh = nil
	self:chechMesh(1)
end

---@param i number
function PointGraphView:chechMesh(i)
	if not self.mesh then
		self.mesh = love.graphics.newMesh(vertexformat, 1, "points", "dynamic")
		return
	end
	local po2 = 2 ^ math.ceil(math.log(i, 2))
	if po2 > self.mesh:getVertexCount() then
		self.mesh = love.graphics.newMesh(vertexformat, po2, "points", "dynamic")
		self.mesh:setVertices(self.vertices)
	end
end

---@param w number
---@param h number
function PointGraphView:draw(w, h)
	if self.show and not self.show(self) then
		return
	end

	local points = self.game.rhythmModel.scoreEngine.sequence
	if self.points ~= points then
		self.points = points
		points = self.points
		self:reload()
	end
	if not self.points then
		return
	end

	for i = self.drawnPoints + 1, #points do
		self:drawPoint(i, points[i])
	end
	self.drawnPoints = #points

	self.mesh:setDrawRange(1, self.drawnPoints)
	if self.backgroundRadius then
		local shader = love.graphics.getShader()
		gfx_util.setPixelColor(self.backgroundColor)
		love.graphics.setPointSize(self.backgroundRadius)
		love.graphics.draw(self.mesh, 0, 0, 0, w, h)
		love.graphics.setShader(shader)
	end

	love.graphics.setPointSize(self.radius)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(self.mesh, 0, 0, 0, w, h)

	love.graphics.setPointSize(1)
end

---@param i number
---@param point table
function PointGraphView:drawPoint(i, point)
	local y, r, g, b, a = self:point(point)
	if not y then
		return
	end

	local timeEngine = self.game.rhythmModel.timeEngine
	local startTime = timeEngine.minTime
	local endTime = timeEngine.maxTime
	local x = (point.base.currentTime - startTime) / (endTime - startTime)

	x = math.min(math.max(x, 0), 1)
	y = math.min(math.max(y, 0), 1)

	self:chechMesh(i)
	local vertex = {x, y, r, g, b, a}
	self.mesh:setVertex(i, vertex)
	table.insert(self.vertices, vertex)
end

return PointGraphView
