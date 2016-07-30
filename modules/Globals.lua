--[[

	Stores global values

]]--

local json = require "json"; -- module for parsing json text

--package.path = package.path..";/modules/?.lua" -- include all modules to the path

content = {};
content.width = display.contentWidth;
content.height = display.contentHeight;
content.centerX = display.contentCenterX;
content.centerY = display.contentCenterY;
content.screenHeight = display.pixelHeight*(content.width/display.pixelWidth);
content.upperEdge = content.height - content.screenHeight;
content.lowerEdge = content.height;

TEXTURES_DIR = "textures/"
POKEMON_PICTURES_DIR = "textures/pokemon/"
POKEMON_DATA_PATH = system.pathForFile( "data/pokemon.json" );

pokebase = json.decode( io.open( POKEMON_DATA_PATH, "r" ):read( "*a" ) );

-- assign name indexes to the array, to be able to get pokemon like pokebase.pikachu
for i=1,#pokebase do
	local pokemonData = pokebase[i];
	pokebase[pokemonData.name] = pokebase[i];
end