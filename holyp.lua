--[[ Whether or not this is on Polytoria. ]]--
local POLYTORIA = false
local RUN_TESTS = true

--[[ The tests were made to only run off Polytoria. ]]--
if RUN_TESTS and not POLYTORIA then
	require("src/tests/lexer_test")
end

local Lexer = require("src/holyp-lex")
Lexer.Require(POLYTORIA)
