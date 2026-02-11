local Tester = require("Tester")

local x = 0

Tester.Before(function()
	x = 0
end)

Tester.Test("Test1", function()
	x = x + 1
	assert(x == 1)
end)

Tester.Test("Test2", function()
	x = x + 1
	assert(x == 1)
end)

Tester.Test("Test Fail", function()
	assert(1 == 2)
end)

Tester.Run()
Tester.Reset()

Tester.Test("Test Pass", function()
	assert(1 == 1)
end)

Tester.Run()
