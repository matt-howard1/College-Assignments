class Ball{
  float x;
  float y;
  float dX;
  float dY;
  float diameter;
  float radius;
  float speed;
  int iFrames;
  
  Ball(){
    x = 250;
    y = 250;
    dX = BALL_SPEED;
    dY = 0;
    diameter = BALL_DIAMETER;
    radius = diameter / 2;
    speed = BALL_SPEED;
    iFrames = 0;
  }
  
  void move(){
    x += dX;
    y += dY;
  }
  
  void collideWithWall(){
    if(y + radius >= 500 || y - radius < 0) dY = -dY;
  }
  
  void collideWithPlayer(Player player){
    if((abs(x - (player.x + (PADDLE_WIDTH / 2))) <= (radius + PADDLE_WIDTH / 2))
        && (y <= player.y + PADDLE_HEIGHT && y >= player.y) && iFrames == 0)
    {
        speed = -speed;
        dY += player.speed / 5;
        if(abs(dY) > abs(speed)) dY = (player.speed / abs(player.speed)) * abs(speed) * 0.8;
        dX = speed * cos(asin(dY / speed)); //<>//
        iFrames = 1;
        speed += 0.1 * speed / abs(speed);
    }
    if(iFrames > 0) iFrames++;
    if(iFrames >= 30) iFrames = 0;
  }
  
  void draw(){
    rect(x - radius, (y - radius), diameter, diameter);
  }
  
  void reset(){
    x = 250;
    y = 250;
    dX = BALL_SPEED;
    dY = 0;
    speed = BALL_SPEED;
    iFrames = 0;
  }
  
}
