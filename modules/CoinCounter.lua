--[[

]]--

CoinCounter = display.newGroup( );

CoinCounter.value = 0;

function CoinCounter:init()
	local containerImage = display.newImage( CoinCounter, TEXTURES_DIR.."counter-container.png" );

	local shadowImage = display.newImage( CoinCounter, TEXTURES_DIR.."counter-shadow.png" );
	shadowImage.x = -15;
	shadowImage.y = 22;

	local coinImage = display.newImage( CoinCounter, TEXTURES_DIR.."counter-coin.png" );
	coinImage.x = -42;
	coinImage.y = 1;

	CoinCounter.indicator = display.newText( CoinCounter, CoinCounter.value, 30, 3, "Pocket Monk.otf", 50);
	CoinCounter.indicator:setTextColor( 1, 0, 0 );

end

function CoinCounter:setValue(value)
	CoinCounter.value  = value;
	CoinCounter.indicator.text = CoinCounter.value;
end

function CoinCounter:increase(value)
	CoinCounter.value  = CoinCounter.value+value;
	CoinCounter.indicator.text = CoinCounter.value;
end

function CoinCounter:decrease(value)
	CoinCounter.value  = CoinCounter.value-value;
	CoinCounter.indicator.text = CoinCounter.value;
end