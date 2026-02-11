--[[
--	Tester keeps track and runs the tests.
--	It is a simple minimalistic test module I made specifically for this project.
--]]
local Tester = {
	__TestList   = {},
	__BeforeList = {},
	__AfterList  = {},
}

--[[
--	Spawns a new thread to run a test on.
--	Takes the test.
--	Returns whether or not the test failed along with the error message.
--	If the test succeeds, it will come with the time it took to run the test.
--]]
local function RunTest(t)
	if type(t) ~= "table" or type(t.Callback) ~= "function" then
		error("Expected a valid test to run.")
	end

	for _, f in ipairs(Tester.__BeforeList) do f() end

	local s, e = coroutine.resume(coroutine.create(function()
		local start_time = os.time()
		local s, e = pcall(t.Callback)
		if not s then return e end
		return os.time() - start_time
	end))

	for _, f in ipairs(Tester.__AfterList) do f() end
	
	return s, e
end

--[[ Runs the setup tests ]]--
function Tester.Run()
	for n, test in pairs(Tester.__TestList) do
		local s, e = RunTest(test)
		local Char = "S"
		if not s then Char = "F" end
		print("["..Char.."]: "..n.." | "..tostring(e))
	end
end

--[[ Clears all the data from the Tester ]]--
function Tester.Reset()
	Tester.__TestList   = {}
	Tester.__BeforeList = {}
	Tester.__AfterList  = {}
end

--[[
--	Describes a test.
--	Takes in a name and a callback.
--]]
function Tester.Test(name, callback)
	if Tester.__TestList[name] ~= nil then error("Duplicate test name found. "..name) end
	local Test = { Callback = callback }
	Tester.__TestList[name] = Test
end

--[[
--	Runs the callback everytime before calling the test.
--	Warning, using this could result in tests stepping on eachother and having race conditions.
--]]
function Tester.Before(callback)
	if type(callback) ~= "function" then error("Expected a function to run before test. Instead found: "..type(callback)) end
	table.insert(Tester.__BeforeList, callback)
end

--[[
--	Runs the callback everytime after calling the test.
--	Warning, using this could result in tests stepping on eachother and having race conditions.
--]]
function Tester.After(callback)
	if type(callback) ~= "function" then error("Expected a function to run after test. Instead found: "..type(callback)) end
	table.insert(Tester.__AfterList, callback)
end

return Tester
