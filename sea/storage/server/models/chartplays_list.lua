local table_util = require("table_util")
local chartplays = require("sea.storage.server.models.chartplays")

---@type rdb.ModelOptions
local chartplays_list = table_util.copy(chartplays)

chartplays_list.subquery = [[
SELECT
	chartplays.id AS chartplay_id,
	chartplays.*,
	chartdiffs.enps_diff AS difficulty,
	chartdiffs.inputmode
FROM chartplays
LEFT JOIN chartdiffs ON
	chartplays.hash = chartdiffs.hash AND
	chartplays.`index` = chartdiffs.`index` AND
	chartplays.modifiers = chartdiffs.modifiers AND
	chartplays.rate = chartdiffs.rate
LEFT JOIN chartmetas ON
	chartplays.hash = chartmetas.hash AND
	chartplays.`index` = chartmetas.`index`
]]

return chartplays_list
