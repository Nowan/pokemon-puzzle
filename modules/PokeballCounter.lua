--[[

]]--

PokeballCounter = display.newGroup( );

function PokeballCounter:init()
	local containerImage = display.newImage( PokeballCounter, TEXTURES_DIR.."counter-container.png" );

	local shadowImage = display.newImage( PokeballCounter, TEXTURES_DIR.."counter-shadow.png" );
	shadowImage.xScale = -1; -- flip horizontally
	shadowImage.x = 15;
	shadowImage.y = 22;

	local pokeballImage = display.newImage( PokeballCounter, TEXTURES_DIR.."counter-pokeball.png" );
	pokeballImage.x = 42;
	pokeballImage.y = 1;

	local indicator = display.newText( PokeballCounter, "0", -30, 3, "Pocket Monk.otf", 50);
	indicator:setTextColor( 1, 0, 0 );

end