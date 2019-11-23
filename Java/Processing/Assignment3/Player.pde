class Player{
  
  float y;
  float x;
  int currentBullet;
  int bulletCooldown;
  int ammo;
  PImage sprite;
  float w;
  float h;
  boolean move;
  
  Player(PImage ship){
    x = SCREEN_WIDTH / 2;
    currentBullet = LASER;
    bulletCooldown = 0;
    ammo = 0;
    sprite = ship;
    w = sprite.width;
    h = sprite.height;
    y = SCREEN_HEIGHT - Y_MARGIN - h;
    move = true;
  }
  
  void move(){
    if(move)
      if(mouseX + 20 < SCREEN_WIDTH && mouseX > 0)
        x = mouseX;
  }
  
  void draw(){
    image(sprite, x, y);
  }
  
  void collectPowerup(Powerup powerup){
  if(x + w >= powerup.x && x - w <= powerup.x + 20 && y < powerup.y + 20){
      powerup.collected = true;
      currentBullet = powerup.type;
      ammo = 0;
    }
  }
  
  void fire(){
    if(currentBullet == BURST){
       if(mousePressed && bulletCooldown == 0){
         bullets.add(new Bullet(x+ w / 2, 0));
         bulletCooldown++;
         ammo += 2;
            bulletSound.play();
       }
       else if(bulletCooldown == 8 || bulletCooldown == 16){
         bullets.add(new Bullet(x+ w / 2, 0));
            bulletSound.play();
       }
    }
    else if(currentBullet == LASER){
       if(mousePressed && bulletCooldown == 0){
         laserSound.play();
         bullets.add(new Bullet(x - 5 + w / 2, 1));
         bulletCooldown++;
         ammo += 30;
         time = millis();
       }
    }
    else if(mousePressed && bulletCooldown == 0){ 
      switch(currentBullet){
         case NORMAL:
           bullets.add(new Bullet(x + w / 2, 0));
           bulletCooldown++;
           break;
         case SPREAD:
           bullets.add(new Bullet(x+ w / 2, 0));
           bullets.add(new Bullet(x - 20+ w / 2, 0));
           bullets.add(new Bullet(x + 20+ w / 2, 0));
           bulletCooldown++;
           ammo += 3;
           break;
      }
         bulletSound.play();
    }
    if(bulletCooldown != 0){
      bulletCooldown++;
      if(bulletCooldown == 30) bulletCooldown = 0;
    }
    if(ammo >= 30){
      currentBullet = NORMAL;
    }  
  }
  
  float y(){
     return y; 
  }
  
  float x(){
     return x; 
  }
  float width(){
     return w; 
  }
  void decreaseHealth(){
    
  }
}
