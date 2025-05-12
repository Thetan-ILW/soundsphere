local pkg = require("aqua.pkg")

pkg.addc()
pkg.addc("3rd-deps/lib")
pkg.addc("bin/lib")
pkg.addc("tree/lib/lua/5.1")
pkg.add()
pkg.add("3rd-deps/lua")
pkg.add("aqua")
pkg.add("ncdk")
pkg.add("chartbase")
pkg.add("libchart")
pkg.add("tree/share/lua/5.1")

pkg.add(os.getenv("OR_ROOT") .. "/lualib")

pkg.export_lua()

-- lua-nginx-module bug fix
coroutine.wrap = require("icc.co").wrap

local luacov_runner
local ok, err = pcall(require, "luacov.runner")
if ok then
	luacov_runner = err
	luacov_runner.init()
end

pkg.export_lua()

require("preload")

local Testing = require("testing.Testing")
local BaseTestingIO = require("testing.BaseTestingIO")

local tio = BaseTestingIO()
tio.blacklist = {
	".git",
	"3rd-deps",
	"tree",
	"userdata",
}

local testing = Testing(tio)

local file_pattern, method_pattern = arg[1], arg[2]
testing:test(file_pattern, method_pattern)

if luacov_runner then
	debug.sethook(nil)
	luacov_runner.save_stats()
	require("luacov.reporter.lcov").report()
end

os.exit()
