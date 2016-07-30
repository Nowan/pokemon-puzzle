--[[

]]--

require("modules.Globals");
require("modules.Gameboard");
require("modules.CoinCounter");
require("modules.PokeballCounter");
require("modules.Puzzle");

Gameboard:show();

Puzzle:init(6);

Puzzle:fill();

Puzzle.onPokemonPressed = function(pressedPokemon)
	pressedPokemon:shake();
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
	local pokemonInLine = Puzzle:getPokemonInLine();

	for i=1,#pokemonInLine do
		local pokemonLine = pokemonInLine[i];
		print(pokemonLine.row,pokemonLine.column,pokemonLine.length,pokemonLine.orientation)
		pokemonLine:evolve();
	end

end