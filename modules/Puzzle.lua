--[[

]]--
local m_Pokemon = require("Pokemon");

Puzzle = display.newGroup();

function Puzzle:init(size)
	-- checking size value
	if not size then 
		print("ERROR! You must provide puzzle size!");
		return;
	elseif type(size) ~= "number" then
		print("ERROR! Puzzle size must be number!");
		return;
	elseif size<4 then 
		print("ERROR! Puzzle size must be greater or equals 4!");
		return;
	end;

	Puzzle.size = math.floor(size);
	Puzzle.tileSize = content.width / Puzzle.size;

	for i=1,Puzzle.size^2 do
		local emptyTile = display.newImage(Puzzle, TEXTURES_DIR.."tile-empty.png");
		emptyTile.width = Puzzle.tileSize;
		emptyTile.height = Puzzle.tileSize;
		emptyTile.x = (i-1)%Puzzle.size * Puzzle.tileSize;
		emptyTile.y = math.floor((i-1)/Puzzle.size) * Puzzle.tileSize;
	end

	Puzzle.x = Puzzle.tileSize/2;
	Puzzle.y = content.lowerEdge - Puzzle.height + Puzzle.tileSize/2;
end

function Puzzle:fill()
	m_Pokemon.new(pokebase.bulbasaur);
end