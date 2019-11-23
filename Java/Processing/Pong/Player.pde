class Player{
   float x;
   float y;
   boolean computer;
   int score;
   float speed;
   boolean control;
   float aiDifficulty;
   int up;
   int down;
  
   Player(boolean isComputer, float xPos, boolean controlType){
     x = xPos;
     y = 225;
     computer = isComputer;
     score = 0;
     control = controlType;
     aiDifficulty = 0;  
 }
 
   Player(boolean isComputer, float xPos, boolean controlType, int[] controls){
     x = xPos;
     y = 225;
     computer = isComputer;
     score = 0;
     control = controlType;
     aiDifficulty = 0;
     down = controls[0];
     up = controls[1];
 }
   
   void move(int yPos){
     if(!computer){
       if(control == MOUSE){
         speed = y;
         if (yPos + PADDLE_HEIGHT < SCREEN_HEIGHT)
           y = yPos;
         speed = y - speed;
       }
       else{
         speed = y;
         if((keyPressed && (keyCode == down || key == down)) && (y + PADDLE_HEIGHT < SCREEN_HEIGHT)){
             y += 4;
         }
         if((keyPressed && (keyCode == up || key == up)) && (y > 0)){
             y -= 4;
         }
         speed = y - speed;
       }
     }
     else{
         if ((y + PADDLE_HEIGHT < SCREEN_HEIGHT) && (y + PADDLE_HEIGHT / 2 <= ball.y)) y += COMPUTER_SPEED + aiDifficulty;
         if ((y > 0) && (y + PADDLE_HEIGHT / 2 >= ball.y)) y -= COMPUTER_SPEED + aiDifficulty;
     }
   }
   
   void draw(){
      rect(x, y, PADDLE_WIDTH, PADDLE_HEIGHT);
   }
   
   void reset(){
      y = 225;
   }
}
