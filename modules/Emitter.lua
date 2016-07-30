--[[
	type - fire, water, electrical, grass, etc.
]]--
module(...,package.seeall);
-- Require the JSON library for decoding purposes
local json = require( "json" );

function new(type)
	-- Read the exported Particle Designer file (JSON) into a string
	local filePath = system.pathForFile( type..".rg" )
	local f = io.open( filePath, "r" )
	local fileData = f:read( "*a" )
	f:close()
	 
	-- Decode the string
	local emitterParams = json.decode( fileData );
	emitterParams.duration = 0.5;

	local emitter = display.newEmitter( emitterParams );
	emitter:stop();

	return emitter;
end