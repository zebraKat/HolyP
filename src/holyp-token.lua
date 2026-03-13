-- Tokens make up the result of the Lexer.
-- The parser uses tokens to make sure the syntax is correct.
local Token = {}

Token.Types = {
	--[[ +----MISC----+ ]]--
	Identifier = "TK_IDENTIFIER",
	Unknown    = "TK_UNKNOWN",
	Eof        = "TK_EOF", -- End of file

	--[[ +----LITERALS----+ ]]--
	Int    = "TK_INT",    -- 0
	Float  = "TK_FLOAT",  -- 0.0
	String = "TK_STRING", -- "x"
	Char   = "TK_CHAR",   -- 'x'

	--[[ +----PUNCTUATION----+ ]]--
	LCurly   = "TK_LEFT_CURLY",    -- {
	RCurly   = "TK_RIGHT_CURLY",   -- }
	LBracket = "TK_LEFT_BRACKET",  -- [
	RBracket = "TK_RIGHT_BRACKET", -- ]
	LParen   = "TK_LEFT_PAREN",    -- (
	RParen   = "TK_RIGHT_PAREN",   -- )
	Dot      = "TK_DOT",           -- .
	Comma    = "TK_COMMA",         -- ,
	DerefVal = "TK_DEREF_VAL",     -- ->
	Semi     = "TK_SEMICOLON",     -- ;
	Colon    = "TK_COLON",         -- :
	Plus     = "TK_PLUS",          -- +
	Minus    = "TK_MINUS",         -- -
	Star     = "TK_STAR",          -- *
	Slash    = "TK_SLASH",         -- /
	Modulo   = "TK_MODULO",        -- %
	Equal    = "TK_EQUAL",         -- =
	EqEq     = "TK_EQEQ",          -- ==
	PlEq     = "TK_PLEQ",          -- +=
	MiEq     = "TK_MIEQ",          -- -=
	StEq     = "TK_STEQ",          -- *=
	SlEq     = "TK_SLEQ",          -- /=
	Less     = "TK_LESS",          -- <
	Greater  = "TK_GREATER",       -- <
	LEq      = "TK_LEQ",           -- <=
	GEq      = "TK_GEQ",           -- >=

	--[[ +----TYPES----+ ]]--
	TypeU0     = "TK_TYPE_U0",     -- U0 / Void
	TypeInt    = "TK_TYPE_INT",    -- Int
	TypeFloat  = "TK_TYPE_FLOAT",  -- Float
	TypeString = "TK_TYPE_STRING", -- String

	--[[
	--	Introducing these for later.
	--	Currently, since we aren't on Luau, we can't choose the size of intergers.
	--]]
	TypeU8  = "TK_TYPE_U8",  -- U8
	TypeI8  = "TK_TYPE_I8",  -- I8
	TypeU16 = "TK_TYPE_U16", -- U16
	TypeI16 = "TK_TYPE_I16", -- I16
	TypeU32 = "TK_TYPE_U32", -- U32
	TypeF64 = "TK_TYPE_F64", -- F64

	--[[ +----KEYWORDS----+ ]]--
	KeywordIf      = "TK_KEYWORD_IF",      -- if
	KeywordElse    = "TK_KEYWORD_ELSE",    -- else
	KeywordSwitch  = "TK_KEYWORD_SWITCH",  -- switch
	KeywordCase    = "TK_KEYWORD_CASE",    -- case
	KeywordDefault = "TK_KEYWORD_DEFAULT", -- default
	KeywordFor     = "TK_KEYWORD_FOR",     -- for
	KeywordWhile   = "TK_KEYWORD_WHILE",   -- while
	KeywordDo      = "TK_KEYWORD_DO",      -- do
	KeywordBreak   = "TK_KEYWORD_BREAK",   -- break
	KeywordGoto    = "TK_KEYWORD_GOTO",    -- goto
	KeywordReturn  = "TK_KEYWORD_RETURN",  -- return
	KeywordConst   = "TK_KEYWORD_CONST",   -- const
	KeywordClass   = "TK_KEYWORD_CLASS",   -- class
	KeywordUnion   = "TK_KEYWORD_UNION",   -- union

	--[[
	--	We need to remove the stuff below this and add a preprocessor.
	--	The lexer shouldn't handle preproccessor stuff.
	--]]
	--[[ +----PREPROCCESSOR----+ ]]--
	PreProcInclude   = "TK_PREPROC_INCLUDE", -- #include
	PreProcDefine    = "TK_PREPROC_DEFINE",  -- #def
	PreProcUndefine    = "TK_PREPROC_UNDEFINE",  -- #undef

	--[[ +----DIRECTIVES----+ ]]--
	DirDate = "TK_DIRECTIVE_DATE", -- __DATE__
	DirTime = "TK_DIRECTIVE_TIME", -- __TIME__
	DirLine = "TK_DIRECTIVE_LINE", -- __LINE__
	DirFile = "TK_DIRECTIVE_FILE", -- __FILE__
}

--[[ This is a hashmap indexed by Keyword as Text to the TokenType of it. ]]--
Token.Keywords = {
	["if"]      = Token.Types.KeywordIf,
	["else"]    = Token.Types.KeywordElse,
	["switch"]  = Token.Types.KeywordSwitch,
	["case"]    = Token.Types.KeywordCase,
	["default"] = Token.Types.KeywordDefault,
	["for"]     = Token.Types.KeywordFor,
	["while"]   = Token.Types.KeywordWhile,
	["do"]      = Token.Types.KeywordDo,
	["break"]   = Token.Types.KeywordBreak,
	["goto"]    = Token.Types.KeywordGoto,
	["return"]  = Token.Types.KeywordReturn,
	["const"]   = Token.Types.KeywordConst,
	["class"]   = Token.Types.KeywordClass,
	["union"]   = Token.Types.KeywordUnion,

	["Int"]    = Token.Types.TypeInt,
	["Float"]  = Token.Types.TypeFloat,
	["String"] = Token.Types.TypeString,
	 --[[ Since we currently have no sizing control, Void fits better than U0. ]]--
	["Void"]   = Token.Types.TypeU0,
	["U0"]     = Token.Types.TypeU0,
	["U8"]     = Token.Types.TypeU8,
	["I8"]     = Token.Types.TypeI8,
	["U16"]    = Token.Types.TypeU16,
	["I16"]    = Token.Types.TypeI16,
	["U32"]    = Token.Types.TypeU32,
	["I32"]    = Token.Types.TypeI32,
	["F64"]    = Token.Types.TypeF64,
	
}
--[[ Looks for the Keyword in the table and returns the TokenType if found ]]--
function Token.IsKeyword(s)
	for Index, TType in pairs(Token.Keywords) do
		if Index == s then
			return TType end
	end
	return nil
end

--[[ Returns whether the input is a valid token type ]]--
function Token.IsValidTokenType(t)
	if type(t) ~= "string" then return false end
	return true
end

--[[ Creates a new token. Takes in a type, lexeme, span, and optionally a value. ]]--
function Token.New(_type, lexeme, span, value)
	if type(lexeme) ~= "string" then error("Expected a valid lexeme (string) when creating a token.") end
	if type(_type) ~= "string" or not Token.IsValidTokenType(_type) then
		print(_type)
		error("Expected a valid tokentype when creating token.")
	end
	if type(span) ~= "table" or span.From == nil or span.To == nil then
		error("Expected a valid span when creating token.")
	end


	local self = {
		Type = _type,
		Lexeme = lexeme,
		Span = span,
		Value = value or 0 --[[ We do not care about the type of `value` as the type is dependent on the tokentype. ]]--
	}

	--[[ Returns whether or not the token's type is equal to the passed in type. ]]--
	function self.Is(type)
		return self.Type == type1
	end

	return self
end

return Token
