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
		local function dissapearingAnimation() 
			transition.to(Pokemon, {time=500,width=0,height=0,Easing=easing.inCubic ,onComplete=function()
				if Pokemon then
					Puzzle.tiles[Pokemon.row][Pokemon.column]:removeSelf( );
					Puzzle.tiles[Pokemon.row][Pokemon.column] = nil;
					Pokemon:removeSelf( );
					Pokemon = nil;
				end
			end });
		end

		if(Puzzle.swapTransition) then
			timer.performWithDelay( 400, function() dissapearingAnimation(); end, 1 )
		else
			dissapearingAnimation();
		end
	end

	return Pokemon;
end

function random()
	local randomIndex = math.random(1,#pokebase);
	local Pokemon = new(pokebase[randomIndex]);
	return Pokemon;
end

