--[[

]]--

require("modules.Globals");
require("modules.Gameboard");
require("modules.CoinCounter");
require("modules.PokeballCounter");
require("modules.Puzzle");
require("modules.Audio");

Gameboard:show();

Puzzle:init(6);

PokeballCounter:setValue(50);

local function checkEvolutions()
	local pokemonInLine = Puzzle:getPokemonInLine(3);

	for i=1,#pokemonInLine do
		local pokemonSet = pokemonInLine[i];
		pokemonSet:evolve();

		CoinCounter:increase(pokemonSet.length*5*pokemonSet.evolutionStage);

		if not pokemonSet.canEvolve then
			PokeballCounter:decrease(1);
		end
	end
end

Puzzle:fill();

Puzzle.onPokemonPressed = function(pressedPokemon)
	pressedPokemon:shake();
	pressedPokemon:enspell();
	originalRow = pressedPokemon.row;
	originalColumn = pressedPokemon.column;
end

Puzzle.onPokemonDragged = function(draggedPokemon, overlappingPokemon)
	if draggedPokemon ~= overlappingPokemon then
		if (overlappingPokemon.row==originalRow and originalColumn-overlappingPokemon.column<=1 and originalColumn-overlappingPokemon.column>=-1)
		or (overlappingPokemon.column==originalColumn and originalRow-overlappingPokemon.row<=1 and originalRow-overlappingPokemon.row>=-1)
		then
			Puzzle:swap(draggedPokemon,overlappingPokemon);
		end
	end
end

Puzzle.onPokemonReleased = function(releasedPokemon)
	checkEvolutions();
end

Audio:playBackgroundMusic();