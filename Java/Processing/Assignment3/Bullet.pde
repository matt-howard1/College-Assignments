class Bullet{
 
 float x;
 float y; 
 int type;
 int laserTime;
 float w;
 float h;
  
 Bullet(float xPos, int bulletType){
   x = xPos;
   y = SCREEN_HEIGHT - Y_MARGIN - player.h - 20;
   type = bulletType;
   laserTime = 0;
   w = bulletSprite.width;
   h = bulletSprite.height;
 }
 
 void move(){
   if(type != 1)
     y -= BULLET_SPEED;
   else{
     if(laserTime < 30)
       x = player.x() + player.width() / 2 - 5;
     else player.move = false;
     laserTime++;
   }
 }
 
 void draw(){
   if(type != 1){
     image(bulletSprite, x - 2.5, y);
   }
   else{
     if(laserTime < 30){
       image(laser[laserTime / 3], x - 5, y + 5);
     }
     else{
       println(millis() - time);
       for(int i = 0; i < y + 10; i += 10){
          if(i < y){
            fill(0, 255, 255);
            rect(x + 5 + (12 * cos((((float)laserTime  + i)/ 30) * PI)), i, 1, 5);
            image(laser[11], x, i);
          }
          else
            image(laser[10], x, i);
       }
     }
   }
 }
 
 void collide(Alien[] aliens){
   for(int i = 0; i < aliens.length; i++){
     if(type != 1){
       if((x >= aliens[i].xPos && x <= (aliens[i].xPos + aliens[i].w))
           && (y >= aliens[i].yPos && y <= (aliens[i].yPos + aliens[i].h)) && aliens[i].status == ALIVE){
           aliens[i].explode();
           score++;
           return;
       }
     }
     else if(laserTime > 30 && aliens[i].yPos >= 0  && aliens[i].status == ALIVE && ((aliens[i].xPos >= x && aliens[i].xPos <= x + 20)
             ||(aliens[i].xPos + aliens[i].w >= x && aliens[i].xPos + aliens[i].w <= x + 20))){
       aliens[i].explode();
       score++;
     }
   }
 }
 
 float x(){
    return x; 
 }
 
 float y(){
    return y; 
 }
 
 float width(){
    return w; 
 }
 
 float height(){
    return h; 
 }
}
