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
	local column = math.ceil(point.x/Puzzle.tileSize);
	if(column>Puzzle.size or column<1) then return nil end

	local row = math.ceil((point.y-Puzzle.y+Puzzle.tileSize/2)/Puzzle.tileSize);
	if(row>Puzzle.size or row<1) then return nil end

	return Puzzle.tiles[row][column];
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

				pokemon.column = c;
				pokemon.row = r;

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
	local targetC = secondPokemon.column;
	local targetR = secondPokemon.row;
	firstPokemon:toFront( );

	secondPokemon.column = firstPokemon.column;
	secondPokemon.row = firstPokemon.row;
	firstPokemon.column = targetC;
	firstPokemon.row = targetR;

	Puzzle.tiles[secondPokemon.row][secondPokemon.column] = secondPokemon;
	Puzzle.tiles[firstPokemon.row][firstPokemon.column] = firstPokemon;

	transition.to(firstPokemon,{time=500, x=secondPokemon.x, y=secondPokemon.y, easing=easing.inOutQuint  });
	swapTransition = transition.to(secondPokemon,{time=500, x=firstPokemon.x, y=firstPokemon.y, easing=easing.inOutQuint , onComplete=function()
		transition.cancel( swapTransition );
		swapTransition = nil;
	end});
end

function Puzzle:getPokemonInLine(lengthFilter)	
	if not lengthFilter then lengthFilter=2 end;

	local pokemonInLine = {};

	local function insertLine(row, column, orientation, length)
		local pokemonLine = {};
		pokemonLine.row = row;
		pokemonLine.column = column;
		pokemonLine.orientation = orientation;
		pokemonLine.length = length;

		pokemonInLine[#pokemonInLine+1] = pokemonLine;
	end

	for r=1,Puzzle.size do
		for c=1,Puzzle.size do
			print("CHECK ["..r..";"..c.."]")
			
			local length = 1;
			local currentPokemon = Puzzle.tiles[r][c];
			local examinedPokemon;

			-- Step 1: check, if there are any similar pokemon on the right of the current one
			if c<Puzzle.size then -- skip last column
				examinedPokemon = Puzzle.tiles[r][c+length];
				loopContinues = examinedPokemon and (examinedPokemon.data.name==currentPokemon.data.name);

				while loopContinues do
					length = length + 1;
					examinedPokemon = Puzzle.tiles[r][c+length];
					loopContinues = examinedPokemon and (examinedPokemon.data.name==currentPokemon.data.name);
				
					if not loopContinues then 
						-- when loop doesn't continue - puzzle length
						local previousPL = pokemonInLine[#pokemonInLine];

						if(previousPL) then
							if(currentPokemon.row==previousPL.row and currentPokemon.column>=previousPL.column and currentPokemon.column<previousPL.column+previousPL.length) then
								-- check, if current pokemon is in the line of the previous one
								-- if yes - update it's length
								print("Continuation of line "..previousPL.row..";"..previousPL.column);
							else
								-- if not - insert new line
								print("New line "..r..";"..c);
								insertLine(r,c,"horizontal",length);
							end
						else
							-- if there is no lines in the array - insert current one
							print("New line "..r..";"..c);
							insertLine(r,c,"horizontal",length);
						end
					end
					
			    end
			    length = 1;
			end

		end
	end

	return pokemonInLine;
end