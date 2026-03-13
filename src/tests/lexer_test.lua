local Tester = require("Tester")
local Lexer = require("src/holyp-lex")
local Token = require("src/holyp-token")

Lexer.Require(false)
local l = Lexer.New("", {})

Tester.Before(function()
	l.Diagnostics = {}
end)

Tester.Test("Tokenize Keywords", function()
	l.Source = [[U0 if]]

	local Result = l.Tokenize()
	assert(#l.Diagnostics == 0, "Diagnostics > 0")
	assert(Result[1].Type == Token.Types.TypeU0, "Expected TokenType TypeU0. "..Result[1].Type)
	assert(Result[2].Type == Token.Types.KeywordIf, "Expected TokenType KeywordIf. "..Result[1].Type)
end)

Tester.Test("Tokenize Identifiers", function()
	l.Source = [[_identifier]]

	local Result = l.Tokenize()
	assert(#l.Diagnostics == 0, "Diagnostics > 0")
	assert(Result[1].Type == Token.Types.Identifier, "Expected TokenType Identifier. "..Result[1].Type)
	assert(Result[1].Lexeme == "_identifier", "Result Lexeme unexpected. "..Result[1].Lexeme)
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

Tester.Test("Tokenize Underscore Numbers", function()
	l.Source = [[1_200]]

	local Result = l.Tokenize()
	assert(#l.Diagnostics == 0, "Diagnostics > 0")
	assert(Result[1].Type == Token.Types.Int, "Expected TokenType Int. "..Result[1].Type)
	assert(Result[1].Value == 1200, "Result value unexpected. "..Result[1].Value)
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
