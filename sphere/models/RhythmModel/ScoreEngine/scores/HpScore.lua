local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")
local IHealthsSource = require("sphere.models.RhythmModel.ScoreEngine.IHealthsSource")

---@class sphere.HpScore: sphere.ScoreSystem, sphere.IHealthsSource
---@operator call: sphere.HpScore
local HpScore = ScoreSystem + IHealthsSource

HpScore.max = 1000

---@return string
function HpScore:getKey()
	return "hp"
end

---@param notes integer
function HpScore:insertCounter(notes)
	table.insert(self, {
		notes = notes,
		value = self.max / 2,
	})
end

-- TODO: return back hp configuration

function HpScore:new()
	local notes = 20
	local shift = false

	for i in ipairs(self) do
		self[i] = nil
	end

	if not shift then
		self:insertCounter(notes)
		return
	end

	for i = 0, math.min(notes, 9) do
		self:insertCounter(i)
	end
	for i = 10, notes, 5 do
		self:insertCounter(i)
	end
end

---@return table
function HpScore:getSlice()
	-- local slice = {}
	-- for _, v in ipairs(self) do
	-- 	table.insert(slice, {
	-- 		notes = v.notes,
	-- 		value = v.value,
	-- 	})
	-- end
	-- return slice
	return {
		healths = self:getHealths(),
		max_healths = self:getMaxHealths(),
	}
end

---@return number
---@return number
function HpScore:getCurrent()
	for _, h in ipairs(self) do
		if h.value > 0 then
			return h.value, h.notes
		end
	end
	return 0, 1
end

---@return number
function HpScore:getHealths()
	return (self:getCurrent())
end

---@return number
function HpScore:getMaxHealths()
	return self.max
end

---@return boolean
function HpScore:isFailed()
	local _h
	for _, h in ipairs(self) do
		if h.value > 0 then
			_h = h
			break
		end
	end
	return not _h
end

---@param event table
function HpScore:increase(event)
	for _, h in ipairs(self) do
		if h.value > 0 then
			h.value = math.min(h.value + 1, self.max)
		end
	end
end

---@param event table
function HpScore:decrease(event)
	for _, h in ipairs(self) do
		if h.value > 0 then
			h.value = math.min(h.value - self.max / h.notes, self.max)
		end
		if h.value < 1e-3 then
			h.value = 0
		end
	end
end

HpScore.events = {
	ShortNote = {
		clear = {
			passed = "increase",
			missed = "decrease",
			clear = nil,
		},
	},
	LongNote = {
		clear = {
			startPassedPressed = "increase",
			startMissed = "decrease",
			startMissedPressed = "decrease",
			clear = nil,
		},
		startPassedPressed = {
			startMissed = nil,
			endMissed = "decrease",
			endPassed = "increase",
		},
		startMissedPressed = {
			endMissedPassed = "increase",
			startMissed = nil,
			endMissed = "decrease",
		},
		startMissed = {
			startMissedPressed = nil,
			endMissed = "decrease",
		},
	},
}

return HpScore
