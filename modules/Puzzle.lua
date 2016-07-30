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

function Puzzle:swap(firstPokemon,secondPokemon)
	if Puzzle.swapTransition then return end;
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
	Puzzle.swapTransition = transition.to(secondPokemon,{time=500, x=firstPokemon.x, y=firstPokemon.y, easing=easing.inOutQuint , onComplete=function()
		transition.cancel( Puzzle.swapTransition );
		Puzzle.swapTransition = nil;
	end});
end

local function evolve(pokemonLine)
	if(pokemonLine.orientation=="horizontal") then
		for i=0,pokemonLine.length-1 do
			if Puzzle.tiles[pokemonLine.row][pokemonLine.column+i] then
				Puzzle.tiles[pokemonLine.row][pokemonLine.column+i]:disappear();
			end
		end
	elseif(pokemonLine.orientation=="vertical") then
		for i=0,pokemonLine.length-1 do
			if Puzzle.tiles[pokemonLine.row+i][pokemonLine.column] then
				Puzzle.tiles[pokemonLine.row+i][pokemonLine.column]:disappear();
			end
		end
	end
end

function Puzzle:getPokemonInLine(lengthFilter)	
	if not lengthFilter then lengthFilter=2 end;

	local horizontalLines = {};
	local verticalLines = {};

	local function newPokemonLine(row, column, orientation, length)
		local pokemonLine = {};
		pokemonLine.row = row;
		pokemonLine.column = column;
		pokemonLine.orientation = orientation;
		pokemonLine.length = length;

		function pokemonLine:evolve()
			evolve(pokemonLine);
		end

		return pokemonLine;
	end

	for r=1,Puzzle.size do
		for c=1,Puzzle.size do

			local length = 1;
			local currentPokemon = Puzzle.tiles[r][c];

			if currentPokemon then

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
							-- when loop doesn't continue - line length is correct
							local previousPL = horizontalLines[#horizontalLines];

							if(previousPL) then
								if(currentPokemon.row==previousPL.row and currentPokemon.column>=previousPL.column and currentPokemon.column<previousPL.column+previousPL.length) then
									-- check, if current pokemon is in the line of the previous one
								else
									-- if not - insert new line
									horizontalLines[#horizontalLines+1] = newPokemonLine(r,c,"horizontal",length);
								end
							else
								-- if there is no lines in the array - insert current one
								horizontalLines[#horizontalLines+1] = newPokemonLine(r,c,"horizontal",length);
							end
						end
						
				    end
				    length = 1;
				end

				-- Step 2: check, if there are any similar pokemon below the current one
				if r<Puzzle.size then -- skip last row
					examinedPokemon = Puzzle.tiles[r+length][c];
					loopContinues = examinedPokemon and (examinedPokemon.data.name==currentPokemon.data.name);

					while loopContinues do
						length = length + 1;
						examinedPokemon = (r+length)<=Puzzle.size and Puzzle.tiles[r+length][c] or nil;
						loopContinues = examinedPokemon and (examinedPokemon.data.name==currentPokemon.data.name);
					
						if not loopContinues then 
							-- when loop doesn't continue - line length is correct
							local previousPL = verticalLines[#verticalLines];

							if(previousPL) then
								if(currentPokemon.column==previousPL.column and currentPokemon.row>=previousPL.row and currentPokemon.row<previousPL.row+previousPL.length) then
									-- check, if current pokemon is in the line of the previous one
								else
									-- if not - insert new line
									verticalLines[#verticalLines+1] = newPokemonLine(r,c,"vertical",length);
								end
							else
								-- if there are no lines in the array - insert the first one
								verticalLines[#verticalLines+1] = newPokemonLine(r,c,"vertical",length);
							end
						end
						
				    end
				    length = 1;
				end
			end
		end
	end

	local pokemonInLine = {};

	for i=1,#horizontalLines do pokemonInLine[#pokemonInLine+1] = horizontalLines[i] end;
	for i=1,#verticalLines do pokemonInLine[#pokemonInLine+1] = verticalLines[i] end;

	return pokemonInLine;
end