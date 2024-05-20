---------------------------------
-- soundTable.lua
---------------------------------


local soundTable = {
    pcShoot = audio.loadSound( "shoot.wav" ), -- when the pc shoots
    enemyHitBullet = audio.loadSound( "hit.wav" ), -- when the enemy is hit by a bullet
    bossShoot = audio.loadSound( "explode.wav" ), -- when the boss shoots
    pcHitBoss = audio.loadSound( "vine-boom.mp3"), -- when the pc is hit by the boss
}

return soundTable;
