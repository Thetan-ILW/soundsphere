local ITimingValuesPreset = require("sea.timings.ITimingValuesPreset")
local TimingValues = require("sea.chart.TimingValues")
local Timings = require("sea.chart.Timings")
local Subtimings = require("sea.chart.Subtimings")

-- https://github.com/semyon422/soundsphere/pull/17

---@class sea.OsuManiaV1Timings_v2: sea.ITimingValuesPreset
---@operator call: sea.OsuManiaV1Timings_v2
local OsuManiaV1Timings = ITimingValuesPreset + {}

---@param od number
function OsuManiaV1Timings:getBaseIntWindows(od)
	-- only integer OD supported
	assert(od == math.floor(od))
	local od3 = od * 3
	return {
		perfect = 16,
		great = 64 - od3,
		good = 97 - od3,
		ok = 127 - od3,
		meh = 151 - od3,
		miss = 188 - od3,
	}
end

---@param od number
function OsuManiaV1Timings:getNoteWindows(od)
	local w = self:getBaseIntWindows(od)
	return {
		perfect = w.perfect / 1000,
		great = w.great / 1000,
		good = w.good / 1000,
		ok = w.ok / 1000,
		meh = w.meh / 1000,
		miss = w.miss / 1000,
	}
end

---@param od number
function OsuManiaV1Timings:getHeadWindows(od)
	local w = self:getBaseIntWindows(od)
	return {
		perfect = w.perfect / 1000,
		great = w.great / 1000,
		good = w.good / 1000,
		ok = w.ok / 1000,
		meh = w.meh / 1000,
		miss = w.miss / 1000,
	}
end

---@param od number
function OsuManiaV1Timings:getTailWindows(od)
	local w = self:getBaseIntWindows(od)
	local mul = 1.5
	return {
		perfect = w.perfect * mul / 1000,
		great = w.great * mul / 1000,
		good = w.good * mul / 1000,
		ok = w.ok * mul / 1000,
		meh = w.meh * mul / 1000,
		miss = w.miss * mul / 1000,
	}
end

---@param od number
---@return sea.TimingValues
function OsuManiaV1Timings:getTimingValues(od)
	local w = self:getNoteWindows(od)

	local a, b, c, d = -w.miss, -w.meh, w.meh, w.miss
	local mul = 1.5

	local tvs = TimingValues()
	tvs.ShortNote = {hit = {b, c}, miss = {a, d}}
	tvs.LongNoteStart = {hit = {b, c}, miss = {a, d}}
	tvs.LongNoteEnd = {hit = {b * mul, c * mul}, miss = {a * mul, d * mul}}

	return tvs
end

---@param tvs sea.TimingValues
---@return sea.Timings?
---@return sea.Subtimings?
function OsuManiaV1Timings:match(tvs)
	local od = (tvs.ShortNote.miss[1] * 1000 + 188) / 3

	if od ~= math.floor(od) then
		return
	end

	local _tvs = self:getTimingValues(od)
	if not _tvs:equals(tvs) then
		return
	end

	return Timings("osuod", od), Subtimings("scorev", 1)
end

return OsuManiaV1Timings
