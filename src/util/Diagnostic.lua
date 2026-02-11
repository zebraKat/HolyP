local Diagnostic = {}

Diagnostic.Mode = {
	Warn = 0,
	Error = 1, 
	__Max__ = 1
}

--[[
--	Creates a new Diagnostic.
--	Takes a message which is a string,
--	a mode which is an enum (Diagnostic.Mode),
--	and a position which is a Position
--]]
function Diagnostic.New(message, mode, position)
	if type(message) ~= "string" then error("Expected a string for diagnostic message.") end
	if type(mode) ~= "number" or mode > Diagnostic.Mode.__Max__ or mode < 0 then
		error("Expected a number / enum for diagnostic mode.")
	end
	if type(position) ~= "table" or position.x == nil or position.y == nil then
		error("Expected a valid Position for diagnostic.")
	end

	local self = {
		Message = message,
		Mode = mode,
		Position = position,
		
	}

	--[[
	--	Returns the Diagnostic as a string.
	--	It follows this format: `[MODE]:POSITION.Y:POSITION.X: MESSAGE`
	--]]
	function self.String()
		local StringBuilder = ""
		
		StringBuilder = StringBuilder.."["..self.Mode.."]:"
		StringBuilder = StringBuilder..self.Position.y..":"..self.Position.x..": "
		StringBuilder = StringBuilder..self.Message

		return StringBuilder
	end
	
	return self
end

return Diagnostic
