class Alien{
    
    float xPos;
    float yPos;
    int direction;
    float speed;
    PImage sprite;
    PImage explosionSprite;
    float w;
    float h;
    int status;
    float yCount;
    Bomb bomb;
    boolean bombDropped;
    
    Alien(float x, float y, PImage image, PImage explosion){
      xPos = x;
      yPos = y;
      speed = 2;
      direction = 1;
      sprite = image;
      explosionSprite = explosion;
      w = sprite.width;
      h = sprite.height;
      yCount = 0;
      bombDropped = false;
    }
    
    void move(){
      if(status == ALIVE){
        if(!(xPos + w >= SCREEN_WIDTH - MARGIN || xPos <= MARGIN) && yCount == 0)
        {
          xPos += speed * direction;
        }
        else
        {
          yCount++;
          yPos++;
          if(yCount >= h)
          {
            yCount = 0;
            direction *= -1;
            xPos += speed * direction;
          }
        }
      }
      else if(status != DEAD){
          status++;
      }
      else
      {
        status = ALIVE;
        yPos = -round(random(10)) * h + h;
        speed = 3;
      }
    }
    
    void draw(){
      if(status == ALIVE)
        image(sprite, xPos, yPos);
      else if(status != DEAD)
        image(explosionSprite, xPos - (explosionSprite.width - w), yPos - (explosionSprite.height - h));
  }
    
    void explode(){
      if(status == ALIVE){
         status++;
         int x = round(random(50));
         if(powerup == null || powerup.collected == true){
           switch(x){
              case 1:
                powerup = new Powerup(xPos, yPos, LASER);
                break;
              case 2:
              case 3:
                powerup = new Powerup(xPos, yPos, SPREAD);
                break;
              case 4:
              case 5:
                powerup = new Powerup(xPos, yPos, BURST);
                break;
              default:
                break;
           }
         }
      }
    }
    
    Bomb getBomb(){
       return bomb; 
    }
    
    void dropBomb(){
       bombDropped = true;
       bomb = new Bomb(xPos, yPos);
    }
    
    void resetBomb(){
       bomb = null;
       bombDropped = false;
    }
    
    boolean isAlive(){
       return (status == ALIVE)? true : false;
    }
    
    float x(){
       return xPos; 
    }
    
    float y(){
       return yPos; 
    }
    
    float width(){
     return w; 
    }
}
