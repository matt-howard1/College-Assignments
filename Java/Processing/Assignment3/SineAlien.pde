class SineAlien extends Alien{
   SineAlien(float x, PImage image, float imageWidth, float imageHeight, PImage explosionSprite){
      super(SCREEN_WIDTH / 2, -x, image, explosionSprite);
      w = imageWidth;
      h = imageHeight;
    } 
    
    void move(){
      if(status == ALIVE){
        yPos += speed / 20;
        xPos = (SCREEN_WIDTH / 2) + (SCREEN_WIDTH / 2 - MARGIN) * sin(yPos / 8) - (w / 2);
      }
      else if(status != DEAD){
          status++;
      }
    }

    void draw(){
        if(status == ALIVE)
          image(sprite, xPos, yPos);
        else if(status != DEAD)
          image(explosionSprite, xPos, yPos);
    }
}
