local Span = {}

--[[ Creates a span from two Positions ]]--
function Span.New(from, to)
	if type(from) ~= "table" or type(from.x) ~= "number" or type(from.y) ~= "number" then
		error("Expected a valid Position to create a span. (from)")
	end

	if type(to) ~= "table" or type(to.x) ~= "number" or type(to.y) ~= "number" then
		error("Expected a valid Position to create a span. (to)")
	end

	local self = {}

	self.From = from
	self.To = to
	
	return self
end

return Span
