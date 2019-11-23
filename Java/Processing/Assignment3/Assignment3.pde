import processing.sound.*;

SinOsc sawOsc;
Env env;

float time;

float attackTime = 0.001;
float sustainTime = 0.004;
float sustainLevel = 0.3;
float releaseTime = 0.4;
Alien[] aliens;
PImage alienSprite;
PImage explodeSprite;
PImage sineAlien;
PImage playerSprite;
PImage background;
PImage[] laser;
PImage bulletSprite;
Player player;
ArrayList<Bullet> bullets;
int score;
PFont scoreFont;
PFont gameOverFont;
boolean gameOver;
PImage[] powerupSprites;
SoundFile laserSound;
SoundFile bulletSound;
Powerup powerup;
Shield[] shields;
Sound s;

void settings(){
  size(SCREEN_WIDTH, SCREEN_HEIGHT); 
}

void setup(){
  print(frameRate);
  alienSprite = loadImage("Alien.png");
  explodeSprite = loadImage("exploding.GIF");
  sineAlien = loadImage("SineAlien.png");
  playerSprite = loadImage("ship.png");
  background = loadImage("background.png");
  bulletSprite = loadImage("Bullet.png");
  scoreFont = loadFont("ScoreFont.vlw");
  gameOverFont = loadFont("Game Over.vlw");
  laserSound = new SoundFile(this, "Laser.wav");
  bulletSound = new SoundFile(this, "bullet.wav");
  gameOver = false;
  score = 0;
  laser = new PImage[12];
  for(int i = 1; i <= laser.length; i++){
    laser[i - 1] = loadImage("Laser/Laser" + i + ".png");
  }  
  aliens = new Alien[50];
  for(int i = 0; i < aliens.length; i++){
    if(i < 30) 
      aliens[i] = new SineAlien(MARGIN + (i + 1) * (alienSprite.width + 10), sineAlien, alienSprite.width, alienSprite.height, explodeSprite);
    else
      aliens[i] = new Alien(MARGIN + ((i + 1) * (alienSprite.width + 10)) % (SCREEN_WIDTH - 2 * MARGIN - alienSprite.width), (i / 10) * alienSprite.height + 5, alienSprite, explodeSprite);
  }
  player = new Player(playerSprite);
  shields = new Shield[3];
  for(int i =0; i < shields.length; i++){
     shields[i] = new Shield((SCREEN_WIDTH / 4) * (i + 1) - 50 / 2, 600); 
  }
  bullets = new ArrayList<Bullet>();
  powerupSprites = new PImage[3];
  powerupSprites[0] = loadImage("laserPU.png");
  powerupSprites[1] = loadImage("spread.png");
  powerupSprites[2] = loadImage("burst.png");
  noStroke();
  fill(0);
  colorMode(HSB);
  s = new Sound(this);
  sawOsc = new SinOsc(this); 
  env  = new Env(this); 
}

void draw(){
  image(background, 0, 0);
  if(!gameOver){ //<>//
    for(int i = 0; i < aliens.length; i++)
    {
      aliens[i].move();
      aliens[i].draw();
      aliens[i].speed += 0.005;
      Bomb bomb = aliens[i].getBomb();
      if(bomb != null)
      {
        bomb.move();
        bomb.draw();
        if(bomb.collide(player))
//          gameOver = true;
        if(bomb.offscreen())
          aliens[i].resetBomb();
         for(int j =0; j < shields.length; j++){
             shields[j].collide(bomb); 
      }
      }
      else if(aliens[i].isAlive()){
         if(aliens[i].x() + aliens[i].width() > player.x() && aliens[i].x() < player.x() + player.width() && random(200) < 1)
           aliens[i].dropBomb();
      }
      if(aliens[i].yPos > SCREEN_HEIGHT - Y_MARGIN) 
        gameOver = true;
    }
    for(int i =0; i < shields.length; i++){
     shields[i].collide(bullets);
      shields[i].draw();
    }
    player.move();
    player.draw();
    player.fire();
    for(int i = 0; i < bullets.size(); i++){
        bullets.get(i).move();
        bullets.get(i).draw();
        bullets.get(i).collide(aliens);
        if(bullets.get(i).y < 0 || bullets.get(i).laserTime >= 80){
          bullets.remove(i);
          player.move = true;
          
        }
    }
    if(powerup != null && !powerup.collected)
    {
       powerup.move();
       powerup.draw();
       player.collectPowerup(powerup);
    }
    fill(255);
    textFont(scoreFont);
    text("Score: " + score, 10, SCREEN_HEIGHT - 10);
  }
  else{
    fill(255);
    textAlign(CENTER);
    textFont(gameOverFont);
    text("Game Over", SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
    textFont(scoreFont);
    text("Score: " + score, SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 + 40);
  }
}
