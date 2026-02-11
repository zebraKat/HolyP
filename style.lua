--[[
--	This document contains details about the style guide of this project!
--	The style guide, is heavily influenced by OpenBSD's Kernal Norm Format.
--	The goal of that format is to keep code consistent, maintainable, and portable.
--]]

--[[ Single line comments look like this! ]]--

--[[
--	Important single line comments look like this!
--]]

--[[
--	Multiline comments look like this! Make them real sentences.
--	Fill up the space so it looks like (a) paragraph(s)!
--]]




--[[
--	When requiring files, do files from the util folder first.
--	Then, require the other files afterwards.
--]]


--[[
--	There should be no space between function name and the arguments.
--]]

--[[
--	Do this!
--]]
function CorrectFunction(my_arg) end

--[[
--	Not this!
--]]
function IncorrectFunction (my_arg) end


--[[
--	Types shouldn't use metatables. They also must be in their own file.
--]]
local MyType = {}

--[[
--	Do this!
--]]
function MyType.New()
	local self = {}
	self.MyParameter = 0
	function self.MyMethod() end
	return self
end

--[[
--	Not this!
--]]
function MyType.New()
	return setmetatable({
		MyParameter = 0
	}, MyType)
end

--[[
--	Types must be PascalCased
--]]

--[[
--	Do this!
--]]
function MyType.New()
	local self = {}
	return self
end

--[[
--	Not this!
--]]
local mytype = {}
function mytype.New()
	local self = {}
	return self
end

--[[
--	Your code must fit PolyToria's style. PascalCased functions, variables, properties, etc.
--	The only things excluded from this style are, `self`, `arguments`, and one letter variables.
--	The exceptions must be camel_cased.
--]]

--[[
--	Do this!
--]]
local self = {}
local function MyFunction(arg1, arg2, cool_box) end

--[[
--	Not this!
--]]
local Self = {}
local function MyFunction(Arg1, Arg2, CoolBox) end

--[[
--	Prefer full names over abreviations. This helps the clairity of your code
--	As an example, instead of naming a variable `idx`, instead name it `index`
--	However, if the name is very long, then you can abbreviate it.
--]]

--[[
--	Use trailing commas on tables. This helps you comment and uncomment things from tables.
--]]

--[[
--	Ensure the types of variables in functions using the `type` function.
--]]

--[[
--	When calling something that returns a value that you want to ignore, assign it to _.
--]]
