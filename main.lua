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
end

Puzzle.onPokemonDragged = function(draggedPokemon, overlappingPokemon)
	if draggedPokemon.columnIndex ~= overlappingPokemon.columnIndex or 
	   draggedPokemon.rowIndex ~= overlappingPokemon.rowIndex then
		Puzzle:swap(draggedPokemon,overlappingPokemon);
	end
end

Puzzle.onPokemonReleased = function(releasedPokemon)

end