--[[

]]--

Audio = {};

local backgroundMusic = audio.loadStream( "sounds/main.mp3" );

local sounds = {
	fire= audio.loadSound( "sounds/fire.mp3" ),
	water= audio.loadSound( "sounds/water.mp3" ),
	grass= audio.loadSound( "sounds/grass.mp3" ),
	electric= audio.loadSound( "sounds/electric.mp3" ),
	normal= audio.loadSound( "sounds/normal.mp3" )
}

function Audio:playBackgroundMusic()
	audio.play( backgroundMusic, { loops=-1} );
end

function Audio:playEffectSound(type)
	audio.play(sounds[type]);
end