PFont stdFont;
PFont checkboxFont;
final int EVENT_BUTTON1=1;
final int EVENT_BUTTON2=2;
final int EVENT_BUTTON3=3;
final int EVENT_SCREEN_FORWARD = 4;
final int EVENT_SCREEN_BACKWARD = 5;
final int SCREEN_1 = 1, SCREEN_2 = 2, SCREEN_3 = 3;
final int EVENT_NULL=0;
boolean draw;
Widget widget1, widget2, widget3;
Slider test, test2;
RadioButton screenSelect;

color c;
Screen[] screens;
Screen currentScreen;

void setup(){
  stdFont=loadFont("LeelawadeeUI-30.vlw");
  checkboxFont = loadFont("LeelawadeeUI-15.vlw");
  textFont(stdFont);
  
  c = color(255,255,255);
  
  screens = new Screen[3];
  
  screens[0] = new Screen(400, 400, color(200));
  
  screens[0].addWidget(new Widget(100, 100, 180, 40,
                                  "Screen 1", color(100),
                                  stdFont, EVENT_BUTTON1));
  screens[0].addWidget(new Widget(100, 200, 180, 40,
                                  "Forward", color(100),
                                  stdFont, EVENT_SCREEN_FORWARD));
  
  screens[1] = new Screen(400, 400, color(255));
  
  screens[1].addWidget(new Widget(100, 100, 180, 40,
                                  "Screen 2", color(100),
                                  stdFont, EVENT_BUTTON2));
  screens[1].addWidget(new Widget(100, 200, 180, 40,
                                  "Backward", color(100),
                                  stdFont, EVENT_SCREEN_BACKWARD));
                                  
  screens[2] = new Screen(400, 400, color(100));
  
  currentScreen = screens[0];
  screenSelect = new RadioButton(10, 10, 15, checkboxFont, 3, new String[]{"Screen 1","Screen 2","Screen 3"}, new int[]{SCREEN_1, SCREEN_2, SCREEN_3});
  screenSelect.set(0);
  
  draw = false;
  
  size(400, 400);
  
  test = new Slider(100, 300, 200, 20, 10);
  test2 = new Slider(100, 250, 200, 20, 10);
}

void draw(){
  currentScreen.draw();
  screenSelect.draw();
  test.draw();
  test2.draw();
}

void mousePressed(){
  int event = currentScreen.getEvent();
   switch(event) {
     case EVENT_SCREEN_FORWARD:
       currentScreen = screens[1];
       break;
     case EVENT_SCREEN_BACKWARD:
       currentScreen = screens[0];
       break;
   }
   event = screenSelect.getEvent(mouseX, mouseY);
   switch(event) {
     case SCREEN_1:
       currentScreen = screens[0];
       screenSelect.set(0);
       break;
     case  SCREEN_2:
       currentScreen = screens[1];
       screenSelect.set(1);
       break;
     case  SCREEN_3:
       currentScreen = screens[2];
       break;
   }
   test.move(mouseX, mouseY);
   test2.move(mouseX, mouseY);
}

void mouseDragged(){
  test.move(mouseX, mouseY); 
  test2.move(mouseX, mouseY);
}

void mouseMoved(){
  currentScreen.updateWidgetStroke();
  screenSelect.changeStroke(mouseX, mouseY);
}

void mouseReleased(){
  test.getIntValue(); 
  test2.getIntValue(); 
}
