class Powerup{
  
  int type;
  float x;
  float y;
  PImage sprite;
  boolean collected;
  
  Powerup(float xPos, float yPos, int powerType){
    x = xPos - 5;
    y = yPos - 5;
    type = powerType;
    collected = false;
  }
  
  void move(){
    y += 2;
  }
  
  void draw(){
    image(powerupSprites[type - 1], x, y, 30, 30);
  }
}
