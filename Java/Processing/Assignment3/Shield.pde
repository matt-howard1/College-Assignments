class Shield{
   int health;
   float x;
   float y;
   float animation;
   boolean destroyed;
   int w;
   int h;
   
   Shield(float xPos, float yPos){
     health = 5;
     x = xPos;
     y = yPos;
     animation = 0;
     health = 3;
     destroyed = false;
     w = 50;
     h = 10;
   }
   
   void draw(){
     if(!destroyed){
       for(int i = 0; i < h; i++){
         //125 - 200
         stroke(125 + ((((i + (animation / 2)) % 30) / 30) * 50) + (3 - health) * (50), 255, 255, 150);
         line(x, y + h - i, x + w, y + h - i);
       }
       animation++;
       animation %= 60;
       noStroke();
     }
   }
   
   void damage(){
     if(!destroyed)
       health--;
     if(health == 0)
       destroyed = true;
   }
   
   void collide(Bomb bomb){
     if(bomb.x() + bomb.width() > x && bomb.x() < x + 50 && bomb.y() < y + 10 && bomb.y() + bomb.height() > y && bomb.status == ALIVE && !destroyed){
         bomb.explode();
         damage();
     }
   }
   
   void collide(ArrayList<Bullet> bullets){
     for(int i = 0; i < bullets.size(); i++){
       Bullet bullet = bullets.get(i);
       if(bullet.x() + bullet.width() > x && bullet.x() < x + 50 && bullet.y() < y + 10 && bullet.y() + bullet.height() > y){
           damage();
       }
     }
   }
}
