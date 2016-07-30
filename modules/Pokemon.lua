--[[

]]--
module(...,package.seeall);

function new(pokemonData)
	local Pokemon = display.newGroup( );

	Pokemon.data = pokemonData;

	local tile = display.newImage(Pokemon, TEXTURES_DIR.."tile-"..pokemonData.type[1]..".png" );
	tile.width = Puzzle.tileSize;
	tile.height = Puzzle.tileSize;

	local preview = display.newImage(Pokemon, POKEMON_PICTURES_DIR..pokemonData.name..".png" );
	preview.width = Puzzle.tileSize * 0.9;
	preview.height = Puzzle.tileSize * 0.9;

	-- methods
	local shakeAnimation;
	function Pokemon:shake()
		if shakeAnimation then return end;
		shakeAnimation = transition.to(Pokemon,{time=50, rotation=5, onComplete = function() 
			shakeAnimation = transition.to(Pokemon,{time=100, rotation=-5, onComplete = function() 
				shakeAnimation = transition.to(Pokemon,{time=50, rotation=0, onComplete = function() 
						shakeAnimation = nil;
					end });
			end });
		end });
	end

	function Pokemon:disappear()
		transition.to(Pokemon, {time=500,width=0,height=0,Easing=easing.inCubic ,onComplete=function()
			if Pokemon and Puzzle.tiles[Pokemon.row][Pokemon.column] then
				Puzzle.tiles[Pokemon.row][Pokemon.column]:removeSelf( );
				Puzzle.tiles[Pokemon.row][Pokemon.column] = nil;
			end
			timer.performWithDelay( 1, function() 
				Puzzle:initFromQueue();
			end ,1 )
			
		end });
	end

	Pokemon:addEventListener( "touch", function(event) 
		if(event.phase=="began") then
			if(Puzzle.onPokemonPressed) then 
				Puzzle.onPokemonPressed(Pokemon); 
			end
			display.currentStage:setFocus( Pokemon );
		elseif(event.phase=="moved") then
			if(Puzzle.onPokemonDragged) then 
				local overlappingPokemon = Puzzle:getOverlappingPokemon(event);
				if not overlappingPokemon then overlappingPokemon=Pokemon end;
				Puzzle.onPokemonDragged(Pokemon, overlappingPokemon); 
			end
		elseif(event.phase=="ended" or event.phase=="cancelled") then
			if(Puzzle.onPokemonReleased) then
				Puzzle.onPokemonReleased(Pokemon);
			end
			display.currentStage:setFocus( nil );
		end
	end );

	return Pokemon;
end

function random()
	local randomIndex = math.random(1,#pokebase);
	local Pokemon = new(pokebase[randomIndex]);
	return Pokemon;
end

