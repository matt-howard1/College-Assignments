Ball ball;
Player player1;
Player player2;
boolean paused;
PFont scoreFont, dataFont;
boolean newGame;
boolean newRound;
int wins;

void settings(){
  size(SCREEN_WIDTH, SCREEN_HEIGHT);
}

void setup(){
  noStroke();
  frameRate(120);
  ball = new Ball();
  player1 = new Player(PLAYER, MARGIN, MOUSE);
  player2 = new Player(COMPUTER, SCREEN_WIDTH - (MARGIN + PADDLE_WIDTH), MOUSE);
  scoreFont = loadFont("scoreFont.vlw");
  dataFont = loadFont("data.vlw");
  paused = true;
  newGame = true;
  newRound = false;
  textAlign(CENTER);
}

void draw(){
  if(newGame){
    drawStartMenu();
  }
  else if (newRound){
     drawRoundMenu();
  }
  else if(!paused)
  {  
    background(0);
    fill(50);
    rect(248, 0, 4, 500);
    fill(255);
    ball.move();
    if(ball.x < 250)
      ball.collideWithPlayer(player1);
    else if(ball.x > 250)
      ball.collideWithPlayer(player2); //<>//
    ball.collideWithWall();
    ball.draw();
    player1.move(mouseY);
    player2.move(mouseY);
    player1.draw();
    player2.draw();
    logData();
    checkScore();
  }
}

void mousePressed(){
  if(newGame){
    if((mouseX >= 130 && mouseX <= 370) && (mouseY >= 100 && mouseY <= 200)){
      newGame = false;
      paused = false;
      newRound = false;
      noCursor();
      ball.reset();
      player1.reset();
      player2.reset();
      player1.score = 0;
      player2.score = 0;
    }
    else if((mouseX >= 130 && mouseX <= 370) && (mouseY >= 250 && mouseY <= 350)){
      newGame = false;
      paused = false;
      newRound = false;
      noCursor();
      player1 = new Player(PLAYER, MARGIN, KEYBOARD, PLAYER_1_CONTROLS);
      player2 = new Player(PLAYER, SCREEN_WIDTH - (MARGIN + PADDLE_WIDTH), KEYBOARD, PLAYER_2_CONTROLS);
      ball.reset();
      player1.score = 0;
      player2.score = 0;
    }
  }
  else if(newRound){
      if((mouseX >= 60 && mouseX <= 220) && (mouseY >= 250 && mouseY <= 330)){
      float difficulty = player2.aiDifficulty;
      newGame = false;
      paused = false;
      newRound = false;
      noCursor();
      ball.reset();
      player1.reset();
      player2.reset();
      player1.score = 0;
      player2.score = 0;
      player2.aiDifficulty = difficulty - 0.5;
    }
    else if((mouseX >= 280 && mouseX <= 460) && (mouseY >= 250 && mouseY <= 330)){
      newGame = false;
      paused = false;
      newRound = false;
      noCursor();
      player1 = new Player(PLAYER, MARGIN, KEYBOARD, PLAYER_1_CONTROLS);
      player2 = new Player(PLAYER, SCREEN_WIDTH - (MARGIN + PADDLE_WIDTH), KEYBOARD, PLAYER_2_CONTROLS);
      ball.reset();
      player1.score = 0;
      player2.score = 0;
    }
  }
  else if(paused){
    ball.reset();
    player1.reset();
    player2.reset();
    paused = false;
  }
}

void logData(){
    textAlign(LEFT);
    textFont(scoreFont);
    text(player1.score, 125, 40);
    text(player2.score, 375, 40);
    textFont(dataFont);
    text("Player Speed: " + player1.speed, 10, 20);
    text("Ball Speed: " + ball.speed, 10, 30);
    text("Ball X: " + ball.x, 10, 40);
    text("Ball Y: " + ball.y, 10, 50);
    text("Ball dX: " + ball.dX, 10, 60);
    text("Ball dY: " + ball.dY, 10, 70);
    text("Difficulty: " + player2.aiDifficulty, 10, 80);
    textAlign(CENTER);
}

void checkScore(){
    if(ball.x <= -ball.radius){
      paused = true;
      player2.score++;
    }
    else if(ball.x >= SCREEN_WIDTH + ball.radius){
      paused = true;
      player1.score++;
      player2.aiDifficulty += 0.5;
    }
    if(player1.score >= 3 || player2.score >= 3){
      if(player1.score >= 3) wins++;
      if(player2.score >= 3) wins = 0;
      newRound = true;
      paused = true;
      cursor();
    }
}

void drawStartMenu(){
    textFont(scoreFont);
    background(0);
    fill(100);
    rect(130, 100, 240, 100);
    rect(130, 250, 240, 100);
    fill(255);
    text("VS Computer", 250, 160);
    text("VS Player", 250, 310);
}

void drawRoundMenu(){
    textFont(scoreFont);
    background(0);
    fill(100);
    rect(60, 250, 160, 80);
    rect(280, 250, 160, 80);
    fill(255);
    text((wins > 0)?"You win":"You lose", 250, 100);
    textSize(20);
    String newGameCount = "New Game";
    for(int i = 0; i < wins; i++) newGameCount += '+';
    text(newGameCount, 140, 297);
    text("VS Player", 360, 297);
}
