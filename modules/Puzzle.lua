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
	Puzzle.removalQueue = {}; -- tiles that must be removed
	Puzzle.insertionQueue = {}; -- tiles that must be inserted

	-- listeners
	Puzzle.onPokemonPressed = nil;
	Puzzle.onPokemonDragged = nil;
	Puzzle.onPokemonReleased = nil;
	Puzzle.onPokemonEvolved = nil;
	Puzzle.onEvolution = nil;
	Puzzle.onFill = nil;

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

function Puzzle:getOverlappingPokemon(point)
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
				
				Puzzle:insert( pokemon );
				Puzzle.tiles[r][c] = pokemon;
			end
		end
	end

	if Puzzle.onFill then 
		timer.performWithDelay( 1, Puzzle.onFill(), 1 );
	end
end

local function cleanRemovalQueue()
	if #Puzzle.removalQueue>=1 then
		for i=1,#Puzzle.removalQueue do
			local index = Puzzle.removalQueue[i];
			if(Puzzle.tiles[index.row][index.column]) then
				Puzzle.tiles[index.row][index.column]:disappear();
			end
		end
		Puzzle.removalQueue = {};
		timer.performWithDelay( 510, function() 
			Puzzle:initFromQueue();
			timer.performWithDelay( 1, function() 
				Puzzle:fill();
			end );
			
		end ,1 )
	end
end

function Puzzle:initFromQueue()
	if #Puzzle.insertionQueue>=1 then
		for i=1,#Puzzle.insertionQueue do
			local insertion = Puzzle.insertionQueue[i];
			print("INIT "..i.." "..insertion.row..";"..insertion.column);
			local pokemon = m_Pokemon.new(insertion.data);
			pokemon.column = insertion.column;
			pokemon.row = insertion.row;
			pokemon.x = (pokemon.column-1) * Puzzle.tileSize;
			pokemon.y = (pokemon.row-1) * Puzzle.tileSize;

			--Puzzle.tiles[pokemon.row][pokemon.column] = pokemon;
			Puzzle:insert(pokemon);
			Puzzle.tiles[pokemon.row][pokemon.column] = pokemon;
		end
		Puzzle.insertionQueue = {};
	end
end

function Puzzle:swap(firstPokemon,secondPokemon)
	if Puzzle.swapTransition or evolveTimer then return end;
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
		
		-- remove pokemons from Puzzle.removalQueue
		cleanRemovalQueue();
	end});
end

local function evolve(pokemonLine)
	-- get evolution name
	local evolutionName = Puzzle.tiles[pokemonLine.row][pokemonLine.column].data.evolution;
	local pokemonName = Puzzle.tiles[pokemonLine.row][pokemonLine.column].data.name;
	if evolutionName then
		local evolutionData = pokebase[evolutionName];

		local insertionRow = pokemonLine.row;
		local insertionColumn = pokemonLine.column;

		Puzzle.insertionQueue[#Puzzle.insertionQueue+1] = {};
		Puzzle.insertionQueue[#Puzzle.insertionQueue].row = insertionRow;
		Puzzle.insertionQueue[#Puzzle.insertionQueue].column = insertionColumn;
		Puzzle.insertionQueue[#Puzzle.insertionQueue].data = evolutionData;
	else
		print("Pokemon is fully evolved");
	end

	if(pokemonLine.orientation=="horizontal") then
		for i=0,pokemonLine.length-1 do
			local pokemonToRemove = Puzzle.tiles[pokemonLine.row][pokemonLine.column+i];
			Puzzle.removalQueue[#Puzzle.removalQueue+1] = {};
			Puzzle.removalQueue[#Puzzle.removalQueue].row = pokemonToRemove.row;
			Puzzle.removalQueue[#Puzzle.removalQueue].column = pokemonToRemove.column;
		end
	elseif(pokemonLine.orientation=="vertical") then
		for i=0,pokemonLine.length-1 do
			local pokemonToRemove = Puzzle.tiles[pokemonLine.row+i][pokemonLine.column];
			Puzzle.removalQueue[#Puzzle.removalQueue+1] = {};
			Puzzle.removalQueue[#Puzzle.removalQueue].row = pokemonToRemove.row;
			Puzzle.removalQueue[#Puzzle.removalQueue].column = pokemonToRemove.column;
		end
	end
	
	-- if swap has finished - clean tiles immediately
	if not Puzzle.swapTransition then 
		if #Puzzle.removalQueue>=1 then
			cleanRemovalQueue();
		else
			-- if there are no tiles to disappear, init evolved pokemon
			initFromQueue();
		end
	end;
	-- else wait until swap transition finishes
end


function Puzzle:getPokemonInLine(lengthFilter)	
	if not lengthFilter then lengthFilter=2 end;

	-- clear removal queue
	Puzzle.removalQueue = {};

	local horizontalLines = {};
	local verticalLines = {};

	local function newPokemonLine(row, column, orientation, length, evolutionStage, canEvolve)
		local pokemonLine = {};
		pokemonLine.row = row;
		pokemonLine.column = column;
		pokemonLine.orientation = orientation;
		pokemonLine.length = length;
		pokemonLine.evolutionStage = evolutionStage;
		pokemonLine.canEvolve = canEvolve;

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
					
						if not loopContinues and length>=lengthFilter then 
							-- when loop doesn't continue - line length is correct
							local previousPL = horizontalLines[#horizontalLines];

							if(previousPL) then
								if(currentPokemon.row==previousPL.row and currentPokemon.column>=previousPL.column and currentPokemon.column<previousPL.column+previousPL.length) then
									-- check, if current pokemon is in the line of the previous one
								else
									-- if not - insert new line
									horizontalLines[#horizontalLines+1] = newPokemonLine(r,c,"horizontal",length, currentPokemon.data.stage, currentPokemon.data.evolution~=nil);
								end
							else
								-- if there is no lines in the array - insert current one
								horizontalLines[#horizontalLines+1] = newPokemonLine(r,c,"horizontal",length,currentPokemon.data.stage, currentPokemon.data.evolution~=nil);
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
					
						if not loopContinues and length>=lengthFilter then 
							-- when loop doesn't continue - line length is correct
							local previousPL = verticalLines[#verticalLines];

							if(previousPL) then
								if(currentPokemon.column==previousPL.column and currentPokemon.row>=previousPL.row and currentPokemon.row<previousPL.row+previousPL.length) then
									-- check, if current pokemon is in the line of the previous one
								else
									-- if not - insert new line
									verticalLines[#verticalLines+1] = newPokemonLine(r,c,"vertical",length,currentPokemon.data.stage, currentPokemon.data.evolution~=nil);
								end
							else
								-- if there are no lines in the array - insert the first one
								verticalLines[#verticalLines+1] = newPokemonLine(r,c,"vertical",length,currentPokemon.data.stage, currentPokemon.data.evolution~=nil);
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