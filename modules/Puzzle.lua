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

	-- constants
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

local function getOverlappingPokemon(point)
	local columnIndex = math.ceil(point.x/Puzzle.tileSize);
	if(columnIndex>Puzzle.size or columnIndex<1) then return nil end

	local rowIndex = math.ceil((point.y-Puzzle.y+Puzzle.tileSize/2)/Puzzle.tileSize);
	if(rowIndex>Puzzle.size or rowIndex<1) then return nil end
	
	print(rowIndex,columnIndex);

	return Puzzle.tiles[rowIndex][columnIndex];
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

				pokemon.columnIndex = c;
				pokemon.rowIndex = r;

				-- add listeners
				pokemon:addEventListener( "touch", function(event) 
					if(event.phase=="began") then
						if(Puzzle.onPokemonPressed) then 
							Puzzle.onPokemonPressed(pokemon); 
						end
						display.currentStage:setFocus( pokemon );
					elseif(event.phase=="moved") then
						if(Puzzle.onPokemonDragged) then 
							local overlappingPokemon = getOverlappingPokemon(event);
							if not overlappingPokemon then overlappingPokemon=pokemon end;
							Puzzle.onPokemonDragged(pokemon, overlappingPokemon); 
						end
					elseif(event.phase=="ended" or event.phase=="cancelled") then
						if(Puzzle.onPokemonReleased) then
							Puzzle.onPokemonReleased(pokemon);
						end
						display.currentStage:setFocus( nil );
					end
				end );

				Puzzle:insert( pokemon );
				Puzzle.tiles[r][c] = pokemon;
			end
		end
	end
end

local swapTransition;
function Puzzle:swap(firstPokemon,secondPokemon)
	if swapTransition then return end;
	local targetC = secondPokemon.columnIndex;
	local targetR = secondPokemon.rowIndex;
	firstPokemon:toFront( );

	transition.to(firstPokemon,{time=500, x=secondPokemon.x, y=secondPokemon.y, easing=easing.inOutQuint  });
	swapTransition = transition.to(secondPokemon,{time=500, x=firstPokemon.x, y=firstPokemon.y, easing=easing.inOutQuint , onComplete=function()
		secondPokemon.columnIndex = firstPokemon.columnIndex;
		secondPokemon.rowIndex = firstPokemon.rowIndex;
		firstPokemon.columnIndex = targetC;
		firstPokemon.rowIndex = targetR;

		Puzzle.tiles[secondPokemon.rowIndex][secondPokemon.columnIndex] = secondPokemon;
		Puzzle.tiles[firstPokemon.rowIndex][firstPokemon.columnIndex] = firstPokemon;

		transition.cancel( swapTransition );
		swapTransition = nil;
	end});
end