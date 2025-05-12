local table_util = require("table_util")
local ChartdiffKey = require("sea.chart.ChartdiffKey")
local valid = require("valid")
local types = require("sea.shared.types")
local chart_types = require("sea.chart.types")

---@class sea.Chartdiff: sea.ChartdiffKey
---@operator call: sea.Chartdiff
--- Server managed keys
---@field id integer
---@field custom_user_id integer
---@field created_at integer
---@field computed_at integer
--- ChartdiffKey
--- COMPUTED
---@field inputmode string
---@field duration number not affected by rate
---@field start_time number not affected by rate
---@field notes_count integer total object count
---@field judges_count integer total number of judgeable QTEs (long note = 2 qte)
---@field note_types_count {[notechart.NoteType]: integer} by type, sum = notes_count
---@field density_data number[] 128 values, 4 bit per value, density of hits
---@field sv_data number[] 128 values, 4 bit per value, (visual duration) / (absoulte duration) ?
---@field enps_diff number
---@field osu_diff number
---@field msd_diff number
---@field msd_diff_data string
---@field user_diff number
---@field user_diff_data string
---@field notes_preview string
local Chartdiff = ChartdiffKey + {}

function Chartdiff:new()
	self.modifiers = {}
end

local note_types_count = valid.map(types.name, types.count, 10)

Chartdiff.struct = {
	inputmode = chart_types.inputmode,
	duration = types.number,
	start_time = types.number,
	notes_count = types.count,
	judges_count = types.count,
	note_types_count = note_types_count,
	density_data = valid.array(types.normalized, 128),
	sv_data = valid.array(types.normalized, 128),
	enps_diff = types.number,
	osu_diff = types.number,
	msd_diff = types.number,
	msd_diff_data = types.binary,
	user_diff = types.number,
	user_diff_data = types.binary,
	notes_preview = types.binary,
}

local computed_keys = table_util.keys(Chartdiff.struct)
assert(#table_util.keys(Chartdiff.struct) == 15)

---@param values sea.Chartdiff
---@return boolean?
---@return string?
function Chartdiff:equalsComputed(values)
	return valid.equals(table_util.sub(self, computed_keys), table_util.sub(values, computed_keys))
end

table_util.copy(ChartdiffKey.struct, Chartdiff.struct)

assert(#table_util.keys(Chartdiff.struct) == 20)

local validate_chartdiff = valid.struct(Chartdiff.struct)

---@return true?
---@return string|valid.Errors?
function Chartdiff:validate()
	return validate_chartdiff(self)
end

return Chartdiff
