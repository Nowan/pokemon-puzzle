--[[

]]--

require("modules.Globals");

require("Gameboard");
require("CoinCounter");
require("PokeballCounter");
require("Puzzle");

Gameboard:show();

Puzzle:init(6);

Puzzle:fill();