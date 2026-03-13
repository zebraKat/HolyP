--[[
--	If you are using this on PolyToria,
--	you may need to change these imports to fit PolyToria's style.
--]]
local Span
local Position
local Diagnostic
local Token

--[[
--	This is the lexer for HolyP.
--	The lexer splits the source code into tokens that the parser can go through.
--]]
local Lexer = {}

--[[
--	Source - https://stackoverflow.com/a/641993
--	Posted by Doub, modified by community.
--	Retrieved 2026-02-11, License - CC BY-SA 3.0
--]]
local function ShallowCopy(t)
	local t2 = {}
	for k,v in pairs(t) do
		t2[k] = v
	end
	return t2
end

--[[ Returns whether or not the input char is alphabetic ]]--
local function IsAlphabetic(s)
	return string.match(s, "%a") ~= nil
end

--[[ Returns whether or not the input char is numeric ]]--
local function IsNumeric(s)
	return string.match(s, "%d") ~= nil
end

--[[ Returns whether or not the input char is whitespace ]]--
local function IsSpace(s)
	return string.match(s, "%s") ~= nil
end

--[[ Returns the escaped character from the given code. ]]--
local function EscapeChar(c)
	if c == 'n' then
		return '\n' elseif
	c == 't' then
		return '\t' elseif
	c == '\\' then
		return '\\' end
	return c
end

--[[ Requires the neccessary scripts to run the lexer. ]]--
function Lexer.Require(polytoria)
	if polytoria then
		Span = require(script.Parent["Util"]["Span"])
		Position = require(script.Parent["Util"]["Position"])
		Diagnostic = require(script.Parent["Util"]["Diagnostic"])
		Token = require(script.Parent["Token"])
		return
	end

	Span = require("src/util/Span")
	Position = require("src/util/Position")
	Diagnostic = require("src/util/Diagnostic")
	Token = require("src/holyp-token")
end

--[[
--	Creates a new Lexer object.
--	This takes in the sourcecode which is a string and an array for storing diagnostics
--	Note that this expects the diagnostics list length to be 0.
--]]
function Lexer.New(source, diagnostics)
	if type(diagnostics) ~= "table" or #diagnostics ~= 0 then
		error("Expected diagnostics to be a table of length 0.") end

	if type(source) ~= "string" then
		table.insert(
			diagnostics,
			Diagnostic.New(
				"Expected sourcecode to be a string, instead found "..type(source),
				Diagnostic.Mode.Error,
				Position.New()
			)
		)
	end

	local self = {
		Index = 1,
		Source = source,
		Diagnostics = diagnostics,
		Position = Position.New()
	}

	--[[
	--	Returns the character at the current index.
	--	Note that if the index is beyond the length of the string, then it will return "EOF".
	--]]
	local function At()
		if #self.Source < self.Index then
			return "EOF" end
		return string.sub(self.Source, self.Index, self.Index)
	end
	
	--[[
	--	Returns the character at the current index, then increases the index by one.
	--	Note that if the index is beyond the length of the string, then it will return "EOF".
	--]]
	local function Eat()
		local c = At()
		self.Index = self.Index + 1
		self.Position.x = self.Position.x + 1
		if c == '\n' then
			self.Position.y = self.Position.y + 1
			self.Position.x = 1
		end
		return c
	end

	--[[ Converts the characters into an identifier until it finds a space. ]]--
	local function TokenizeIdentifier()
		local StartIndex = self.Index
		local StartPosition = ShallowCopy(self.Position)
		local TokenType = Token.Types.Identifier
		local String = Eat()

		while 
			At() ~= "EOF" and
			(At() == '_' or (IsAlphabetic(At()) or IsNumeric(At())))
		do
			String = String..Eat() end

		local FoundKeyword = Token.IsKeyword(String)
		if FoundKeyword ~= nil then
			TokenType = FoundKeyword
		end

		return Token.New(
			TokenType,
			string.sub(self.Source, StartIndex, self.Index -1),
			Span.New(StartPosition, ShallowCopy(self.Position)),
			String
		)
	end

	--[[
	--	Converts continuous numbers into a token.
	--	Keep in mind that it will handle floats.
	--]]
	local function TokenizeNumber()
		local StartIndex = self.Index
		local StartPosition = ShallowCopy(self.Position)
		local NumberString = Eat()
		local IsFloat = false
		
		local Continue = false
		while IsNumeric(At()) or At() == '.' or At() == '_' do
			Continue = false
			if At() == '_' then
				_ = Eat()
				Continue = true
			end
			if not Continue then
				if At() == '.' then
					if IsFloat then break end
					IsFloat = true
				end
				NumberString = NumberString..Eat()
			end
		end

		return Token.New(
			IsFloat and Token.Types.Float or Token.Types.Int,
			string.sub(self.Source, StartIndex, self.Index -1),
			Span.New(StartPosition, ShallowCopy(self.Position)),
			tonumber(NumberString)
		)
	end

	--[[
	--	Converts characters between "s into a token.
	--	Keep in mind that it will error if it encounters a newline or eof.
	--]]
	local function TokenizeString()
		local StartIndex = self.Index
		local StartPosition = ShallowCopy(self.Position)
		local String = ""
		_ = Eat()
		if At() ~= '"' then
			while At() ~= 'EOF' and At() ~= '\n' and At() ~= '"' do
				local Char = Eat()
				if Char == '\\' then
					Char = EscapeChar(Eat()) end
				String = String..Char
			end
			if At() ~= '"' then
				table.insert(
					self.Diagnostics,
					Diagnostic.New(
						"Expected \" to close string, instead found: "..At(),
						Diatnostic.Mode.Error,
						ShallowCopy(self.Position)
					)
				)
			end
			_ = Eat()
		end

		return Token.New(
			Token.Types.String,
			string.sub(self.Source, StartIndex, self.Index -1),
			Span.New(StartPosition, ShallowCopy(self.Position)),
			String
		)
	end

	--[[
	--	Converts the character between ' into a token.
	--	Keep in mind that it will error if it encounters a newline or eof.
	--	It will also error if it encounters more than one character between the single quotes.
	--]]
	local function TokenizeChar()
		local StartIndex = self.Index
		local StartPosition = ShallowCopy(self.Position)
		_ = Eat()
		local Char = Eat()
		if Char == '\\' then
			Char = Eat()
			Char = EscapeChar(Char)
		end
			
		if At() ~= "'" then
			table.insert(
				self.Diagnostics,
				Diagnostic.New(
					"Expected ' to close char, instead found: "..At(),
					Diagnostic.Mode.Error,
					ShallowCopy(self.Position)
				)
			)
		end
		_ = Eat()
		
		return Token.New(
			Token.Types.Char,
			string.sub(self.Source, StartIndex, self.Index - 1),
			Span.New(StartPosition, ShallowCopy(self.Position)),
			Char
		)

	end

	function TokenizeSymbol()
		local StartPosition = ShallowCopy(self.Position)
		local StartIndex = self.Index
		local Symbol = Eat()
		local BaseToken = Token.New(
			Token.Types.Unknown,
			string.sub(self.Source, StartIndex, self.Index - 1),
			Span.New(StartPosition, ShallowCopy(self.Position)),
			Symbol
		)

		if Symbol == '{' then
			BaseToken.Type = Token.Types.LCurly
		elseif Symbol == '}' then
			BaseToken.Type = Token.Types.RCurly
		elseif Symbol == '[' then
			BaseToken.Type = Token.Types.LBracket
		elseif Symbol == ']' then
			BaseToken.Type = Token.Types.RBracket
		elseif Symbol == '(' then
			BaseToken.Type = Token.Types.LParen
		elseif Symbol == ')' then
			BaseToken.Type = Token.Types.RParen
		elseif Symbol == '.' then
			BaseToken.Type = Token.Types.Dot
		elseif Symbol == ',' then
			BaseToken.Type = Token.Types.Comma
		elseif Symbol == ';' then
			BaseToken.Type = Token.Types.Semi
		elseif Symbol == ':' then
			BaseToken.Type = Token.Types.Colon
		elseif Symbol == '+' then
			BaseToken.Type = Token.Types.Plus
			if At() == '=' then
				_ = Eat()
				BaseToken.Type = Token.Types.PlEq
			end
		elseif Symbol == '-' then
			BaseToken.Type = Token.Types.Minus
			if At() == '=' then
				_ = Eat()
				BaseToken.Type = Token.Types.MiEq
			elseif At() == '>' then
				_ = Eat()
				BaseToken.Type = Token.Types.DerefVal
			end
		elseif Symbol == '*' then
			BaseToken.Type = Token.Types.Star
			if At() == '=' then
				_ = Eat()
				BaseToken.Type = Token.Types.StEq
			end
		elseif Symbol == '/' then
			BaseToken.Type = Token.Types.Slash
			if At() == '=' then
				_ = Eat()
				BaseToken.Type = Token.Types.SlEq
			end
		elseif Symbol == '%' then
			BaseToken.Type = Token.Types.Modulo
		elseif Symbol == '=' then
			BaseToken.Type = Token.Types.Equal
			if At() == '=' then
				_ = Eat()
				BaseToken.Type = Token.Types.EqEq
			end
		elseif Symbol == '<' then
			BaseToken.Type = Token.Types.Less
			if At() == '=' then
				_ = Eat()
				BaseToken.Type = Token.Types.LEq
			end
		elseif Symbol == '>' then
			BaseToken.Type = Token.Types.Greater
			if At() == '=' then
				_ = Eat()
				BaseToken.Type = Token.Types.GEq
			end
		end

		BaseToken.Span.To = ShallowCopy(self.Position)
		BaseToken.Lexeme = string.sub(self.Source, StartIndex, self.Index - 1)
		if BaseToken.Type == Token.Types.Unknown  then
			table.insert(
				self.Diagnostics,
				Diagnostic.New(
					"Unknown symbol found. "..Symbol,
					Diagnostic.Mode.Error,
					StartPosition
				)
			)
		end

		return BaseToken
	end

	--[[ Clears continuous whitespace ]]--
	function ClearWhitespace()
		while true do
			if At() == "EOF" or not IsSpace(At()) then
				break end
			_ = Eat()
		end
	end

	--[[ Attempts to form the next token and returns it. ]]--
	function AsToken()
		ClearWhitespace()
		if At() == '/' and Next() == '/' then
			while At() ~= "EOF" and At() ~= '\n' do
				_ = Eat() end	
			_ = Eat()
		end

		if At() == '/' and Next() == '*' then
			local StartPosition = ShallowCopy(self.Position)
			_ = Eat()
			_ = Eat()
			while At() ~= "EOF" and At() ~= '\n' do
				if At() == '*' and Next() == '/' then
					break end
				_ = Eat()
			end	
			if At() == "EOF" then
				table.insert(
					self.diagnostics,
					Diagnostic.New(
						"Unclosed multiline comment.",
						Diagnostic.Mode.Error,
						StartPosition
					)
				)
			end
			_ = Eat()
		end


		local c = At()
		if c == "EOF" then
			return nil, true end
		if IsNumeric(c) then
			return TokenizeNumber(), false end
		if IsAlphabetic(c) or c == '_' then
			return TokenizeIdentifier(), false end
		if c == '"' then
			return TokenizeString(), false end
		if c == '\'' then
			return TokenizeChar(), false end
		return TokenizeSymbol(), false
	end

	--[[
	--	This tokenizes the lexer's source and returns list tokens.
	--	Any errors encountered will be put in Lexer.Diagnostics.
	--]]
	function self.Tokenize()
		self.Index = 1
		self.Position.x = 1
		self.Position.y = 1

		local TokenList = {}
		while true do
			if At() == "EOF" then
				break end
			local Token, Ignore = AsToken()
			Token = Token or {}
			if Ignore == false then
				table.insert(TokenList, Token) end
		end
		return TokenList
	end
	return self
end

return Lexer
