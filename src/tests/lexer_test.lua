local Tester = require("Tester")
local Lexer = require("src/holyp-lex")
local Token = require("src/holyp-token")

Lexer.Require(false)
local l = Lexer.New("", {})

Tester.Before(function()
	l.Diagnostics = {}
end)

Tester.Test("Tokenize Strings", function()
	l.Source = [["this is a test string"]]

	local Result = l.Tokenize()
	assert(#l.Diagnostics == 0, "Diagnostics > 0")
	assert(Result[1].Type == Token.Types.String, "Expected TokenType String. "..Result[1].Type)
	assert(Result[1].Value == "this is a test string", "Result value unexpected. "..Result[1].Value)
end)

Tester.Test("Tokenize Chars", function()
	l.Source = [['a']]

	local Result = l.Tokenize()
	for _, Diag in ipairs(l.Diagnostics) do
		print(Diag.String())
	end
	assert(#l.Diagnostics == 0, "Diagnostics > 0")
	assert(Result[1].Type == Token.Types.Char, "Expected TokenType Char. "..Result[1].Type)
	assert(Result[1].Value == 'a', "Result value unexpected. "..Result[1].Value)
end)

Tester.Test("Tokenize Ints", function()
	l.Source = [[12]]

	local Result = l.Tokenize()
	assert(#l.Diagnostics == 0, "Diagnostics > 0")
	assert(Result[1].Type == Token.Types.Int, "Expected TokenType Int. "..Result[1].Type)
	assert(Result[1].Value == 12, "Result value unexpected. "..Result[1].Value)
end)

Tester.Test("Tokenize Floats", function()
	l.Source = [[12.5]]

	local Result = l.Tokenize()
	assert(#l.Diagnostics == 0, "Diagnostics > 0")
	assert(Result[1].Type == Token.Types.Float, "Expected TokenType Float. "..Result[1].Type)
	assert(Result[1].Value == 12.5, "Result value unexpected. "..Result[1].Value)
end)

Tester.Run()
Tester.Reset()
