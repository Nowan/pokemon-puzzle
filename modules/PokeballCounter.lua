--[[

]]--

PokeballCounter = display.newGroup( );

PokeballCounter.value = 0;

function PokeballCounter:init()
	local containerImage = display.newImage( PokeballCounter, TEXTURES_DIR.."counter-container.png" );

	local shadowImage = display.newImage( PokeballCounter, TEXTURES_DIR.."counter-shadow.png" );
	shadowImage.xScale = -1; -- flip horizontally
	shadowImage.x = 15;
	shadowImage.y = 22;

	local pokeballImage = display.newImage( PokeballCounter, TEXTURES_DIR.."counter-pokeball.png" );
	pokeballImage.x = 42;
	pokeballImage.y = 1;

	PokeballCounter.indicator = display.newText( PokeballCounter, PokeballCounter.value, -30, 3, "Pocket Monk.otf", 50);
	PokeballCounter.indicator:setTextColor( 1, 0, 0 );

end

function PokeballCounter:setValue(value)
	PokeballCounter.value  = value;
	PokeballCounter.indicator.text = PokeballCounter.value;
end

function PokeballCounter:increase(value)
	PokeballCounter.value  = PokeballCounter.value+value;
	PokeballCounter.indicator.text = PokeballCounter.value;
end

function PokeballCounter:decrease(value)
	PokeballCounter.value  = PokeballCounter.value-value;
	PokeballCounter.indicator.text = PokeballCounter.value;
end