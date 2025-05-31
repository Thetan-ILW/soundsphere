local ListView = require("sphere.views.ListView")
local just = require("just")
local TextCellImView = require("ui.imviews.TextCellImView")
local Format = require("sphere.views.Format")
local time_util = require("time_util")

local ScoreListView = ListView()

ScoreListView.rows = 5

function ScoreListView:reloadItems()
	self.stateCounter = self.game.selectModel.scoreStateCounter
	self.items = self.game.selectModel.scoreLibrary.items
end

---@return number
function ScoreListView:getItemIndex()
	return self.game.selectModel.scoreItemIndex
end

---@param delta number
function ScoreListView:scroll(delta)
	self.game.selectModel:scrollScore(delta)
end

---@param i number
---@param w number
---@param h number
function ScoreListView:drawItem(i, w, h)
	local item = self.items[i]

	local scoreEngine = self.game.rhythmModel.scoreEngine
	local chartplay = self.game.computeContext.chartplay
	local loaded = chartplay and chartplay.replay_hash == item.replay_hash

	if just.button(item, just.is_over(w, h)) then
		self.screenView:loadScore(i)
	end

	if loaded then
		love.graphics.circle("fill", 44, 36, 7)
		love.graphics.circle("line", 44, 36, 7)
	end

	local rating = item.rating
	local timeRate = item.rate
	local inputMode = item.inputmode
	local rhythmModel = self.game.rhythmModel

	if loaded then
		local erfunc = require("libchart.erfunc")
		local ratingHitTimingWindow = self.game.configModel.configs.settings.gameplay.ratingHitTimingWindow
		local normalscore = scoreEngine.scores.normalscore
		local s = erfunc.erf(ratingHitTimingWindow / (normalscore.accuracyAdjusted * math.sqrt(2)))
		rating = s * rhythmModel.chartdiff.enps_diff

		timeRate = self.game.rhythmModel.timeEngine.baseTimeRate or timeRate
		inputMode = tostring(self.game.rhythmModel.chart.inputMode) or inputMode
	end

	if rating ~= rating then
		rating = "nan"
	end

	local cw = (w - 44) / 5

	local time = item.created_at or 0

	local sea_client = self.game.seaClient
	local username = sea_client.user and sea_client.user.name or "username"

	just.row(true)
	just.indent(22)
	-- TextCellImView(cw, h, "right", i == 1 and "rank" or "", i, true)
	-- TextCellImView(cw, h, "right", i == 1 and "rating" or "", Format.difficulty(rating), true)
	-- TextCellImView(cw, h, "right", i == 1 and "time rate" or "", Format.timeRate(timeRate), true)
	-- TextCellImView(cw * 2, h, "right", time ~= 0 and time_util.time_ago_in_words(time) or "never", Format.inputMode(inputMode))
	-- TextCellImView(w * 3, h, "right", time ~= 0 and time_util.time_ago_in_words(time) or "never", item.user_name or "username")

	TextCellImView(cw * 2.25, h, "right", time ~= 0 and time_util.time_ago_in_words(time) or "never", item.user_name or username)
	TextCellImView(cw / 2, h, "right", i == 1 and "rank" or "", i)
	TextCellImView(cw * 0.75, h, "right", i == 1 and "rating" or "", Format.difficulty(item.rating))
	TextCellImView(cw * 0.75, h, "right", i == 1 and "rate" or "", Format.timeRate(item.rate))
	TextCellImView(cw * 0.75, h, "right", i == 1 and "keys" or "", Format.inputMode(item.inputmode))

	just.row()
end


return ScoreListView
