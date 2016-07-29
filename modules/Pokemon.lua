--[[

]]--
module(...,package.seeall);

function new(pokemonData)
	local Pokemon = display.newGroup( );

	print(pokemonData.name)
	Pokemon.data = pokemonData;

	local tile = display.newImage(Pokemon, TEXTURES_DIR.."tile-"..pokemonData.type[1]..".png" );
	tile.width = Puzzle.tileSize;
	tile.height = Puzzle.tileSize;

	local preview = display.newImage(Pokemon, POKEMON_PICTURES_DIR..pokemonData.name..".png" );
	preview.width = Puzzle.tileSize * 0.9;
	preview.height = Puzzle.tileSize * 0.9;

	-- methods
	function Pokemon:shake()
		transition.to(Pokemon,{time=50, rotation=5, onComplete = function() 
			transition.to(Pokemon,{time=100, rotation=-5, onComplete = function() 
				transition.to(Pokemon,{time=50, rotation=0, onComplete });
			end });
		end });
	end

	return Pokemon;
end

function random()
	local randomIndex = math.random(1,#pokebase);
	local Pokemon = new(pokebase[randomIndex]);
	return Pokemon;
end

