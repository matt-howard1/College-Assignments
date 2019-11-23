class Bomb{
   
    float y;  
    float x;
    float w;
    float h;
    int status;
    PImage sprite;
    
    Bomb(float xPos, float yPos){
      y = yPos;
      x = xPos;
      w = 20;
      h = 20;
      status = ALIVE;
    }
    
    void move(){
      if(status == ALIVE)
        y += 2;
    }
    
    void draw(){
      if(status == ALIVE){
        fill(0, 255, 255);
        rect(x, y, 20, 20);
        //image(sprite, x, y);
      }
      if(status != ALIVE && status != DEAD){
         for(int i =0; i < random((status * status * 1000)); i++){
           fill(20, 255 - (status / DEAD) * 255, 255 - random(200));
           float offset = random(20);
           rect(x - 5 + random(w + 10) +  (random(2) - 1) * offset, y - 5 + random(w + 10) + (random(2) - 1) * offset, 1, 1);  
         }
         status++;
      }
    }
    
    boolean collide(Player player){
      if(status == ALIVE){
        if(y + h > player.y() && (x + w > player.x() && x < player.x() + player.width())){
           explode();
           return true;
        }
      }
      return false;
    }
    
    boolean offscreen(){
      if(y > SCREEN_HEIGHT)
        return true;
       else
         return false;
    }
    
    void explode(){
      status++;
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
    float height(){
       return h; 
    }
}
