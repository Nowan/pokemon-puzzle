--[[

	

]]--
Gameboard = display.newGroup( );

function Gameboard:show()
	print("Show gameboard!");
	local skyBackground = display.newImage( Gameboard, TEXTURES_DIR.."sky.png" );
	skyBackground.anchorY = 0;
	skyBackground.x = content.centerX;
	skyBackground.y = content.upperEdge;

	local puzzleBackground = display.newImage( Gameboard,TEXTURES_DIR.."puzzle-background.png" );
	puzzleBackground.anchorY = 1;
	puzzleBackground.x = content.centerX;
	puzzleBackground.y = content.lowerEdge;

	local panel = display.newImage( Gameboard, TEXTURES_DIR.."panel.png" );
	panel.anchorY = 1;
	panel.x = content.centerX;
	panel.y = content.lowerEdge - content.width;

	local panelShadow = display.newImage( Gameboard, TEXTURES_DIR.."panel-shadow.png" );
	panelShadow.anchorY = 0;
	panelShadow.x = content.centerX;
	panelShadow.y = panel.y;

	local logo = display.newImage( Gameboard, TEXTURES_DIR.."logo.png" );
	logo.x = content.centerX-10;
	logo.y = -130
end

function Gameboard:hide()

end