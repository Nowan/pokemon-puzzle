--[[

]]--
local m_Pokemon = require("modules.Pokemon");

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

	-- pre-declarations
	Puzzle.tile = {}; -- endpoint for tile listener functions (drag & drop)
	Puzzle.tile.onPress = nil; -- initialized in main.lua by student
	Puzzle.tile.onRelease = nil; -- initialized in main.lua by student

	-- constants & declarations
	Puzzle.size = math.floor(size); -- grid size (number of rows/columns)
	Puzzle.tileSize = content.width / Puzzle.size; -- tile size (pixels)

	Puzzle.tiles = {}; -- tiles matrix
	for r=1,Puzzle.size do 
		Puzzle.tiles[r] = {} 
	end

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
	-- generate tiles and store them in the Puzzle.tiles array
	for r=1,Puzzle.size do
		for c=1,Puzzle.size do
			-- fill only empty tiles
			if Puzzle.tiles[r][c] == nil then
				local pokemon = m_Pokemon.random();
				pokemon.x = (c-1)*Puzzle.tileSize;
				pokemon.y = (r-1)*Puzzle.tileSize;

				-- add listeners
				pokemon:addEventListener( "touch", function(event) 
					if(event.phase=="began") then
						if(Puzzle.pokemonPressed) then 
							Puzzle.pokemonPressed(pokemon); 
						end
					elseif(event.phase=="moved") then
						if(Puzzle.pokemonMoved) then 
							Puzzle.pokemonMoved(pokemon); 
						end
					elseif(event.phase=="ended" or event.phase=="cancelled") then
						if(Puzzle.pokemonReleased) then
							Puzzle.pokemonReleased(pokemon);
						end
					end
				end );

				Puzzle:insert( pokemon );
				Puzzle.tiles[r][c] = pokemon;
			end
		end
	end
end