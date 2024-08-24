---@class sphere.SelectConfig
local _select = {
	collection = nil,
	location_id = nil,
	chartmeta_id = 1,
	chartfile_id = 1,
	chartfile_set_id = 1,
	score_id = 1,
	searchMode = "filter",
	judgements = "soundsphere",
	scoreFilterName = "No filter",
	scoreSourceName = "local",
	filterName = "No filter",
	filterString = "",
	lampString = "",
	sortFunction = "title",
	selected_filters = {},
}

return _select
