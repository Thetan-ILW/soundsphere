-- SOURCE: https://github.com/Quaver/Quaver.API/blob/43e800efb079e9c099315c4b365490e357e2380c/Quaver.API/Maps/Processors/Scoring/ScoreProcessorKeys.cs

local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")
local SimpleJudgesSource = require("sphere.models.RhythmModel.ScoreEngine.SimpleJudgesSource")
local IAccuracySource = require("sphere.models.RhythmModel.ScoreEngine.IAccuracySource")
local JudgeCounter = require("sphere.models.RhythmModel.ScoreEngine.JudgeCounter")
local JudgeWindows = require("sphere.models.RhythmModel.ScoreEngine.JudgeWindows")
local JudgeAccuracy = require("sphere.models.RhythmModel.ScoreEngine.JudgeAccuracy")
local Timings = require("sea.chart.Timings")

---@class sphere.QuaverScore :sphere.ScoreSystem, sphere.IAccuracySource, sphere.SimpleJudgesSource
---@operator call: sphere.QuaverScore
local QuaverScore = ScoreSystem + IAccuracySource + SimpleJudgesSource

QuaverScore.judge_names = {"marvelous", "perfect", "great", "good", "okay", "miss"}

local stdWindows = {0.018, 0.043, 0.076, 0.106, 0.127, 0.164}
local weights = {100, 98.25, 65, 25, -100, -50}

function QuaverScore:new()
	self.timings = Timings("quaver")
	self.judge_counter = JudgeCounter(6)
	self.judge_windows = JudgeWindows(stdWindows)
	self.judge_accuracy = JudgeAccuracy(weights)
end

---@return string
function QuaverScore:getKey()
	return "quaver"
end

---@param event table
function QuaverScore:hit(event)
	local is_release = event.newState == "endPassed" or event.newState == "endMissedPassed"

	---@type number
	local delta_time = event.deltaTime
	if is_release then
		delta_time = delta_time / 1.5
	end

	local index = self.judge_windows:get(delta_time) or -1
	self.judge_counter:add(index)
end

function QuaverScore:releaseFail()
	self.judge_counter:add(4)
end

function QuaverScore:miss()
	self.judge_counter:add(-1)
end

function QuaverScore:getAccuracy()
	return self.judge_accuracy:get(self.judge_counter.judges)
end

function QuaverScore:getAccuracyString()
	return ("%0.02f%%"):format(self:getAccuracy() * 100)
end

function QuaverScore:getSlice()
	return {
		accuracy = self:getAccuracy(),
		last_judge = self:getLastJudge(),
	}
end

QuaverScore.events = {
	ShortNote = {
		clear = {
			passed = "hit",
			missed = "miss",
			clear = nil,
		},
	},
	LongNote = {
		clear = {
			startPassedPressed = "hit",
			startMissed = "miss",
			startMissedPressed = "miss",
			clear = nil,
		},
		startPassedPressed = {
			startMissed = "miss",
			endMissed = "releaseFail",
			endPassed = "hit",
		},
		startMissedPressed = {
			endMissedPassed = nil,
			startMissed = nil,
			endMissed = nil,
		},
		startMissed = {
			startMissedPressed = nil,
			endMissed = "miss",
		},
	},
}

return QuaverScore
