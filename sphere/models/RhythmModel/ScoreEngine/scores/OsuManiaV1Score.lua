-- SOURCE: https://osu.ppy.sh/wiki/en/Gameplay/Judgement/osu!mania

local math_util = require("math_util")

local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")
local IAccuracySource = require("sphere.models.RhythmModel.ScoreEngine.IAccuracySource")
local IScoreSource = require("sphere.models.RhythmModel.ScoreEngine.IScoreSource")
local SimpleJudgesSource = require("sphere.models.RhythmModel.ScoreEngine.SimpleJudgesSource")
local JudgeAccuracy = require("sphere.models.RhythmModel.ScoreEngine.JudgeAccuracy")
local JudgeCounter = require("sphere.models.RhythmModel.ScoreEngine.JudgeCounter")
local JudgeWindows = require("sphere.models.RhythmModel.ScoreEngine.JudgeWindows")
local Timings = require("sea.chart.Timings")
local Subtimings = require("sea.chart.Subtimings")

---@class sphere.OsuManiaV1Score: sphere.ScoreSystem, sphere.IAccuracySource, sphere.IScoreSource, sphere.SimpleJudgesSource
---@operator call: sphere.OsuManiaV1Score
local OsuManiaV1Score = ScoreSystem + IAccuracySource + IScoreSource + SimpleJudgesSource

OsuManiaV1Score.accuracy_multiplier = 100
OsuManiaV1Score.judge_names = {"perfect", "great", "good", "ok", "meh", "miss"}

local hitBonus = {2, 1, -8, -24, -44, -100}
local hitValue = {320, 300, 200, 100, 50, 0}
local hitBonusValue = {32, 32, 16, 8, 4, 0}
local weights = {300, 300, 200, 100, 50, 0}

---@param od number
function OsuManiaV1Score:new(od)
	self.timings = Timings("osuod", od)
	self.subtimings = Subtimings("scorev", 1)

	self.od = od

	self.judge_accuracy = JudgeAccuracy(weights)
	self.judge_counter = JudgeCounter(6)

	local od3 = 3 * od

	self.windows = {
		16 / 1000,
		(64 - od3) / 1000,
		(97 - od3) / 1000,
		(127 - od3) / 1000,
		(151 - od3) / 1000,
		(188 - od3) / 1000,
	}
	self.note_judge_windows = JudgeWindows(self.windows)
	self.judge_windows = self.note_judge_windows

	local w = self.windows

	self.headWindows = {
		w[1] * 1.2,
		w[2] * 1.1,
		w[3],
		w[4],
		w[5],
		w[6],
	}
	self.head_judge_windows = JudgeWindows(self.headWindows)

	self.tailWindows = {
		w[1] * 2.4,
		w[2] * 2.2,
		w[3] * 2,
		w[4] * 2,
		w[5],
		w[6],
	}
	self.tail_judge_windows = JudgeWindows(self.tailWindows)

	---@type {[string]: integer}
	self.pressedLongNotes = {}

	self.baseScore = 0
	self.bonusScore = 0
	self.score = 0

	self.bonus = 100
	self.hitValue = 0
	self.totalBonus = 0
end

---@return string
function OsuManiaV1Score:getKey()
	return "osu_mania_v1_od" .. self.od
end

---@param event table
function OsuManiaV1Score:before(event)
	---@type integer
	self.notes = event.notesCount
end

---@param index integer
function OsuManiaV1Score:addCounter(index)
	self.judge_counter:add(index)

	self.hitValue = self.hitValue + hitValue[index]
	self.bonus = math_util.clamp(self.bonus + hitBonus[index], 0, 100)

	self.totalBonus = self.totalBonus + (hitBonusValue[index] * math.sqrt(self.bonus) / 320)

	self.baseScore = (500000 / self.notes) * (self.hitValue / 320)
	self.bonusScore = (500000 / self.notes) * self.totalBonus

	self.score = self.baseScore + self.bonusScore
end

---@param event table
---@return integer?
function OsuManiaV1Score:getStartCounter(event)
	return self.pressedLongNotes[event.noteIndexType]
end

function OsuManiaV1Score:setStartCounter(event, counter_name)
	self.pressedLongNotes[event.noteIndexType] = counter_name
end

---@param event table
function OsuManiaV1Score:miss(event)
	self:addCounter(6)
	if event.noteType == "LongNote" then
		self:setStartCounter(event, nil)
	end
end

---@param event table
function OsuManiaV1Score:shortNoteHit(event)
	local index = self.note_judge_windows:get(event.deltaTime) or 6
	self:addCounter(index)
end

---@param event table
function OsuManiaV1Score:longNoteStartHit(event)
	local index = self.head_judge_windows:get(event.deltaTime) or 6
	self.judge_counter:add(index)
	self:setStartCounter(event, index)
end

---@param event table
function OsuManiaV1Score:didntReleased(event)
	local index = self:getStartCounter(event) or 5
	index = math.min(index + 2, 5)
	self:addCounter(index)
	self:setStartCounter(event, nil)
end

function OsuManiaV1Score:longNoteFail(event)
	self:setStartCounter(event, 5)
end

function OsuManiaV1Score:longNoteRelease(event)
	---@type number
	local delta_time = event.deltaTime

	local tail = self.tail_judge_windows:get(delta_time)
	if not tail or tail == 6 then
		self:addCounter(6)
		return
	end

	local head = self:getStartCounter(event)
	if not head then
		self:addCounter(5)
		return
	end

	self:addCounter(math.max(head, tail))

	self:setStartCounter(event, nil)
end

function OsuManiaV1Score:getScore()
	return self.score
end

function OsuManiaV1Score:getScoreString()
	return ("%07d"):format(self:getScore())
end

function OsuManiaV1Score:getAccuracy()
	return self.judge_accuracy:get(self.judge_counter.judges)
end

function OsuManiaV1Score:getAccuracyString()
	return ("%0.02f%%"):format(self:getAccuracy() * self.accuracy_multiplier)
end

function OsuManiaV1Score:getSlice()
	return {
		accuracy = self:getAccuracy(),
		last_judge = self:getLastJudge(),
		score = self:getScore(),
	}
end

OsuManiaV1Score.events = {
	ShortNote = {
		clear = {
			passed = "shortNoteHit",
			missed = "miss",
			clear = nil,
		},
	},
	LongNote = {
		clear = {
			startPassedPressed = "longNoteStartHit",
			startMissed = "longNoteFail",
			startMissedPressed = "longNoteFail",
			clear = nil,
		},
		startPassedPressed = {
			startMissed = "longNoteFail",
			endMissed = "didntReleased",
			endPassed = "longNoteRelease",
		},
		startMissedPressed = {
			endMissedPassed = "longNoteRelease",
			startMissed = "longNoteFail",
			endMissed = "didntReleased",
		},
		startMissed = {
			startMissedPressed = "longNoteFail",
			endMissed = "miss",
		},
	},
}

return OsuManiaV1Score
