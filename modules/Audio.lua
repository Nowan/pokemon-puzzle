--[[

]]--

Audio = {};

local backgroundMusic = audio.loadStream( "sounds/main.mp3" );

function Audio:playBackgroundMusic()
	audio.play( backgroundMusic, { loops=-1} );
end