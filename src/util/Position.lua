local Position = {}

--[[
--	Creates a new Position.
--	Takes in x and y, both are an optional number
--]]
function Position.New(x, y)
	if type(x) ~= "number" and type(x) ~= "nil" then
		error("Expected a number or nil, instead found: "..type(x))
	end

	if type(y) ~= "number" and type(y) ~= "nil" then
		error("Expected a number or nil, instead found: "..type(y))
	end

	local self = {
		x = x or 0,
		y = y or 0,
	}

	--[[ Returns Position.y ]]--
	function self.Line()
		return self.y
	end

	--[[ Returns Position.x ]]--
	function self.Char()
		return self.x
	end

	return self
end

return Position
