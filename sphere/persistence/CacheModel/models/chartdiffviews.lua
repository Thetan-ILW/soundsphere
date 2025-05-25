local path_util = require("path_util")
local int_rates = require("libchart.int_rates")
local RateType = require("sea.chart.RateType")
local ChartFormat = require("sea.chart.ChartFormat")
local Timings = require("sea.chart.Timings")
local Healths = require("sea.chart.Healths")
local Modifiers = require("sea.storage.server.Modifiers")
local Gamemode = require("sea.chart.Gamemode")
local Subtimings = require("sea.chart.Subtimings")
local IntegerArray = require("sea.storage.server.IntegerArray")
local IntegerArrayOptional = require("sea.storage.server.IntegerArrayOptional")

local chartdiffviews = {}

chartdiffviews.table_name = "chartdiffviews"

chartdiffviews.types = {
	lamp = "boolean",
	set_is_file = "boolean",
	format = ChartFormat,

	nearest = "boolean",
	pass = "boolean",
	mode = Gamemode,
	custom = "boolean",
	columns_order = IntegerArrayOptional,
	modifiers = Modifiers,
	judges = IntegerArray,
	tap_only = "boolean",
	const = "boolean",
	rate = int_rates,
	timings = Timings,
	subtimings = Subtimings,
	healths = Healths,
	rate_type = RateType,
}

chartdiffviews.relations = {}

function chartdiffviews:from_db()
	local dir = self.set_dir
	if not self.set_is_file then
		dir = path_util.join(dir, self.set_name)
	end
	self.dir = dir
	self.path = path_util.join(dir, self.chartfile_name)
end

return chartdiffviews
