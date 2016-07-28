--[[

]]--

CoinCounter = display.newGroup( );



function CoinCounter:init()
	local containerImage = display.newImage( CoinCounter, TEXTURES_DIR.."counter-container.png" );

	local shadowImage = display.newImage( CoinCounter, TEXTURES_DIR.."counter-shadow.png" );
	shadowImage.x = -15;
	shadowImage.y = 22;

	local coinImage = display.newImage( CoinCounter, TEXTURES_DIR.."counter-coin.png" );
	coinImage.x = -42;
	coinImage.y = 1;

	local indicator = display.newText( CoinCounter, "0", 30, 3, "Arial", 40);
	indicator:setTextColor( 1, 0, 0 );

end