local ServerSqliteDatabase = require("sea.storage.server.ServerSqliteDatabase")
local LjsqliteDatabase = require("rdb.LjsqliteDatabase")
local TeamsRepo = require("sea.teams.repos.TeamsRepo")
local Teams = require("sea.teams.Teams")
local Team = require("sea.teams.Team")
local User = require("sea.access.User")

local function create_test_ctx()
	local db = ServerSqliteDatabase(LjsqliteDatabase())

	db.path = ":memory:"

	db:remove()
	db:open()

	-- db.orm:debug(true)

	local models = db.models

	local teams_repo = TeamsRepo(models)
	local teams = Teams(teams_repo)
	local user = User()
	user.id = 1

	local team, err = assert(teams:create(user, "Team 1", "T1"))

	return {
		db = db,
		teams_repo = teams_repo,
		user = user,
		teams = teams,
		team = team,
	}
end

local test = {}

---@param t testing.T
function test.join_after_create(t)
	local ctx = create_test_ctx()

	t:eq(ctx.team.owner_id, ctx.user.id)

	local team_users = ctx.teams:getTeamUsers(ctx.team.id)
	t:eq(#team_users, 1)
	t:eq(team_users[1].id, ctx.user.id)
end

--------------------------------------------------------------------------------
--- open teams
--------------------------------------------------------------------------------

---@param t testing.T
function test.join_open(t)
	local ctx = create_test_ctx()
	local teams = ctx.teams

	local team = Team()
	team.type = "open"
	team = teams:update(ctx.user, team)
	---@cast team -?

	local new_user = User()
	new_user.id = 2
	t:assert(teams:join(new_user, team))

	t:eq(#teams:getTeamUsers(team.id), 2)
	t:eq(#teams:getRequestTeamUsers(ctx.user, team), 0)
	t:eq(#teams:getInviteTeamUsers(ctx.user, team), 0)
	t:assert(not teams:getRequestTeamUsers(new_user, team))
	t:assert(not teams:getInviteTeamUsers(new_user, team))

	t:tdeq({teams:join(new_user, team)}, {nil, "already joined"})
	t:tdeq({teams:acceptJoinInvite(new_user, team)}, {nil, "already accepted"})
end

---@param t testing.T
function test.join_open_by_invite_1(t)
	local ctx = create_test_ctx()
	local teams = ctx.teams

	local team = Team()
	team.type = "open"
	team = teams:update(ctx.user, team)
	---@cast team -?

	local new_user = User()
	new_user.id = 2
	t:assert(teams:inviteUser(ctx.user, team, new_user.id))

	t:eq(#teams:getTeamUsers(team.id), 1)
	t:eq(#teams:getRequestTeamUsers(ctx.user, team), 0)
	t:eq(#teams:getInviteTeamUsers(ctx.user, team), 1)

	-- t:assert(teams:join(new_user, team))
	t:assert(teams:acceptJoinInvite(new_user, team))

	t:eq(#teams:getTeamUsers(team.id), 2)
	t:eq(#teams:getRequestTeamUsers(ctx.user, team), 0)
	t:eq(#teams:getInviteTeamUsers(ctx.user, team), 0)
end

---@param t testing.T
function test.join_open_by_invite_2(t)
	local ctx = create_test_ctx()
	local teams = ctx.teams

	local team = Team()
	team.type = "open"
	team = teams:update(ctx.user, team)
	---@cast team -?

	local new_user = User()
	new_user.id = 2
	t:assert(teams:inviteUser(ctx.user, team, new_user.id))

	t:eq(#teams:getTeamUsers(team.id), 1)
	t:eq(#teams:getRequestTeamUsers(ctx.user, team), 0)
	t:eq(#teams:getInviteTeamUsers(ctx.user, team), 1)

	t:assert(teams:join(new_user, team))
	-- t:assert(teams:acceptJoinInvite(new_user, team))

	t:eq(#teams:getTeamUsers(team.id), 2)
	t:eq(#teams:getRequestTeamUsers(ctx.user, team), 0)
	t:eq(#teams:getInviteTeamUsers(ctx.user, team), 0)
end

---@param t testing.T
function test.join_open_double_invite(t)
	local ctx = create_test_ctx()
	local teams = ctx.teams

	local team = Team()
	team.type = "open"
	team = teams:update(ctx.user, team)
	---@cast team -?

	local new_user = User()
	new_user.id = 2
	t:assert(teams:inviteUser(ctx.user, team, new_user.id))
	t:tdeq({teams:inviteUser(ctx.user, team, new_user.id)}, {nil, "already invited"})
end

--------------------------------------------------------------------------------
--- request teams
--------------------------------------------------------------------------------

---@param t testing.T
function test.join_request(t)
	local ctx = create_test_ctx()
	local teams = ctx.teams

	local team = Team()
	team.type = "request"
	team = teams:update(ctx.user, team)
	---@cast team -?

	local new_user = User()
	new_user.id = 2
	t:assert(teams:join(new_user, team))

	t:eq(#teams:getTeamUsers(team.id), 1)
	t:eq(#teams:getRequestTeamUsers(ctx.user, team), 1)
	t:eq(#teams:getInviteTeamUsers(ctx.user, team), 0)

	t:eq(#teams:getUserAcceptedTeamUsers(new_user.id), 0)
	t:eq(#teams:getUserUnacceptedTeamUsers(new_user), 1)

	t:assert(teams:acceptJoinRequest(ctx.user, team, new_user.id))

	t:eq(#teams:getUserAcceptedTeamUsers(new_user.id), 1)
	t:eq(#teams:getUserUnacceptedTeamUsers(new_user), 0)

	t:eq(#teams:getTeamUsers(team.id), 2)
	t:eq(#teams:getRequestTeamUsers(ctx.user, team), 0)
	t:eq(#teams:getInviteTeamUsers(ctx.user, team), 0)
end

---@param t testing.T
function test.join_request_revoke(t)
	local ctx = create_test_ctx()
	local teams = ctx.teams

	local team = Team()
	team.type = "request"
	team = teams:update(ctx.user, team)
	---@cast team -?

	local new_user = User()
	new_user.id = 2
	t:assert(teams:join(new_user, team))

	t:eq(#teams:getTeamUsers(team.id), 1)
	t:eq(#teams:getRequestTeamUsers(ctx.user, team), 1)
	t:eq(#teams:getInviteTeamUsers(ctx.user, team), 0)

	t:tdeq({teams:revokeJoinInvite(ctx.user, team, new_user.id)}, {nil, "is not invitation"})
	t:assert(teams:revokeJoinRequest(new_user, team))

	t:eq(#teams:getTeamUsers(team.id), 1)
	t:eq(#teams:getRequestTeamUsers(ctx.user, team), 0)
	t:eq(#teams:getInviteTeamUsers(ctx.user, team), 0)
end

--------------------------------------------------------------------------------
--- invite teams
--------------------------------------------------------------------------------

---@param t testing.T
function test.join_invite(t)
	local ctx = create_test_ctx()
	local teams = ctx.teams

	local team = Team()
	team.type = "invite"
	team = teams:update(ctx.user, team)
	---@cast team -?

	local new_user = User()
	new_user.id = 2
	t:assert(not teams:join(new_user, team))

	t:assert(teams:inviteUser(ctx.user, team, new_user.id))

	t:eq(#teams:getTeamUsers(team.id), 1)
	t:eq(#teams:getRequestTeamUsers(ctx.user, team), 0)
	t:eq(#teams:getInviteTeamUsers(ctx.user, team), 1)

	t:eq(#teams:getUserAcceptedTeamUsers(new_user.id), 0)
	t:eq(#teams:getUserUnacceptedTeamUsers(new_user), 1)

	t:assert(teams:acceptJoinInvite(new_user, team))

	t:eq(#teams:getUserAcceptedTeamUsers(new_user.id), 1)
	t:eq(#teams:getUserUnacceptedTeamUsers(new_user), 0)

	t:eq(#teams:getTeamUsers(team.id), 2)
	t:eq(#teams:getRequestTeamUsers(ctx.user, team), 0)
	t:eq(#teams:getInviteTeamUsers(ctx.user, team), 0)
end

---@param t testing.T
function test.join_invite_revoke(t)
	local ctx = create_test_ctx()
	local teams = ctx.teams

	local team = Team()
	team.type = "invite"
	team = teams:update(ctx.user, team)
	---@cast team -?

	local new_user = User()
	new_user.id = 2
	t:assert(not teams:join(new_user, team))

	t:assert(teams:inviteUser(ctx.user, team, new_user.id))

	t:eq(#teams:getTeamUsers(team.id), 1)
	t:eq(#teams:getRequestTeamUsers(ctx.user, team), 0)
	t:eq(#teams:getInviteTeamUsers(ctx.user, team), 1)

	t:tdeq({teams:revokeJoinRequest(new_user, team)}, {nil, "is not request"})
	t:assert(teams:revokeJoinInvite(ctx.user, team, new_user.id))

	t:eq(#teams:getTeamUsers(team.id), 1)
	t:eq(#teams:getRequestTeamUsers(ctx.user, team), 0)
	t:eq(#teams:getInviteTeamUsers(ctx.user, team), 0)
end

return test
