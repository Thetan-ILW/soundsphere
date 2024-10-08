local transform = require("gfx_util").transform
local map = require("math_util").map
local class = require("class")
local inside = require("table_util").inside

---@class sphere.HitErrorView
---@operator call: sphere.HitErrorView
local HitErrorView = class()

HitErrorView.colors = {
	soundsphere = {
		perfect = { 1, 1, 1, 1 },
		["not perfect"] = { 1, 0.6, 0.4, 1 },
	},
	osuMania = {
		perfect = { 0.6, 0.8, 1, 1 },
		great = { 0.95, 0.796, 0.188, 1 },
		good = { 0.07, 0.8, 0.56, 1 },
		ok = { 0.1, 0.39, 1, 1 },
		meh = { 0.42, 0.48, 0.51, 1 },
	},
	osuLegacy = {
		perfect = { 0.6, 0.8, 1, 1 },
		great = { 0.95, 0.796, 0.188, 1 },
		good = { 0.07, 0.8, 0.56, 1 },
		ok = { 0.1, 0.39, 1, 1 },
		meh = { 0.42, 0.48, 0.51, 1 },
	},
	etterna = {
		marvelous = { 0.6, 0.8, 1, 1 },
		perfect = { 0.95, 0.796, 0.188, 1 },
		great = { 0.07, 0.8, 0.56, 1 },
		bad = { 0.1, 0.7, 1, 1 },
		boo = { 1, 0.1, 0.7, 1 },
	},
	quaver = {
		marvelous = { 1, 1, 0.71, 1 },
		perfect = { 1, 0.91, 0.44, 1 },
		great = { 0.38, 0.96, 0.47, 1 },
		good = { 0.25, 0.7, 0.75, 1 },
		okay = { 0.72, 0.46, 0.65, 1 },
	},
	lr2 = {
		pgreat = { 0.6, 0.8, 1, 1 },
		great = { 0.95, 0.796, 0.188, 1 },
		good = { 1, 0.69, 0.24, 1 },
		bad = { 1, 0.5, 0.24, 1 },
	},
}

function HitErrorView:load()
	local score_engine = self.game.rhythmModel.scoreEngine
	if not score_engine.loaded then
		return
	end

	self.judge = score_engine:getJudge()
	self.sequence = score_engine.scoreSystem.sequence
end

local miss = { 1, 0, 0, 1 }
function HitErrorView.color(value, unit, judge)
	local counter = judge:getCounter(value, judge.windows)
	return HitErrorView.colors[judge.scoreSystemName][counter] or miss
end

function HitErrorView:draw()
	if self.show and not self.show(self) then
		return
	end

	local tf = transform(self.transform):translate(self.x, self.y)
	love.graphics.replaceTransform(tf)

	if self.background then
		self:drawBackground()
	end

	local points = self.sequence
	local fade = 0
	for i = #points, #points - self.count, -1 do
		if not points[i] then
			break
		end
		self:drawPoint(points[i], fade)
		fade = fade + 1
	end

	if self.origin then
		self:drawOrigin()
	end
end

function HitErrorView:drawBackground()
	love.graphics.setColor(self.background.color)
	love.graphics.rectangle(
		"fill",
		-self.w / 2,
		0,
		self.w,
		self.h
	)
end

function HitErrorView:drawOrigin()
	local origin = self.origin

	love.graphics.setColor(origin.color)
	love.graphics.rectangle(
		"fill",
		-origin.w / 2,
		-(origin.h - self.h) / 2,
		origin.w,
		origin.h
	)
end

---@param point table
---@param fade number
function HitErrorView:drawPoint(point, fade)
	local color = self.color
	local radius = self.radius

	local value = point.misc.deltaTime
	local unit = inside(point, self.unit)
	if type(value) == "nil" then
		value = tonumber(self.value) or 0
	end
	if type(unit) == "nil" then
		unit = tonumber(self.unit) or 1
	end

	if type(color) == "function" then
		color = color(value, unit, self.judge)
	end
	local alpha = color[4]
	color[4] = color[4] * map(fade, 0, self.count, 1, 0)
	love.graphics.setColor(color)
	color[4] = alpha

	local x = map(value, 0, unit, 0, self.w / 2)
	love.graphics.rectangle("fill", x - radius, 0, radius * 2, self.h)
end

return HitErrorView
