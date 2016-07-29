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

Puzzle.pokemonPressed = function(pokemon)
	pokemon:shake();
end

Puzzle.pokemonMoved = function(pokemon)

end

Puzzle.pokemonReleased = function(pokemon)

end