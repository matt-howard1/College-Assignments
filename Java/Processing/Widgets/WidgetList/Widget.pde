class Widget {
  int x, y, width, height;
  String label; int event;
  color widgetColor, labelColor, stroke;
  PFont widgetFont;

  Widget(int x,int y, int width, int height, String label,
  color widgetColor, PFont widgetFont, int event){
    this.x=x; this.y=y; this.width = width; this.height= height;
    this.label=label; this.event=event; 
    this.widgetColor=widgetColor; this.widgetFont=widgetFont;
    labelColor= color(0);
    stroke = color(0);
   }
  void draw(){
    stroke(stroke);
    fill(widgetColor);
    rect(x,y,width,height);
    fill(labelColor);
    textFont(widgetFont);
    textAlign(LEFT);
    text(label, x+10, y+height-10);
  }
  int getEvent(int mX, int mY){
     if(mX>x && mX < x+width && mY >y && mY <y+height){
        return event;
     }
     return EVENT_NULL;
  }
  void changeStroke(int mX, int mY){
     if(mX>x && mX < x+width && mY >y && mY <y+height){
        stroke = color(255);
     }
     else stroke = color(0);
  }
}

class Checkbox extends Widget{
  
  boolean set;
  
  Checkbox(int x, int y, int size, PFont widgetFont, String label, int event){
    super(x, y, size, size, label, color(0), widgetFont, event);
    set = false;
  }
  
  void draw(){
     stroke(stroke);
     noFill();
     ellipse(x + width / 2, y + height / 2, width, height);
     textFont(widgetFont);
     textAlign(LEFT, CENTER);
     text(label, x + width + 5, y + height /2);
     if(set){
       fill(stroke);
       ellipse(x + width / 2, y + height / 2, width / 2, height / 2);
     }
  }
  
  int getEvent(int mX, int mY){
     if(mX>x && mX < x+width && mY >y && mY <y+height){
       set = !set;
       if(set) return event;
       else return -event;
     }
     return EVENT_NULL;
  }
  
}

class RadioButton extends Widget{
  
  int length;
  int[] eventList;
  boolean[] set;
  String[] labels;
  int[] stroke;
  
  RadioButton(int x, int y, int size, PFont widgetFont, int length, String[] labels, int[] eventList){
    super(x, y, size, size, labels[0], color(0), widgetFont, eventList[0]);
    this.length = length;
    this.eventList = eventList;
    this.labels = labels;
    set = new boolean[length];
    stroke = new int[length];
  }
  
  int getEvent(int mX, int mY){
    for(int i = 0; i < length; i++){
       if(mX>x && mX < x+width && mY >(y*(i+1))+(i*10) && mY <(y*(i+1))+height+(i*10)){
         set[i] = !set[i];
         if(set[i]){ 
           for(int j = 0; j < length; j++){
             if(j != i) set[j] = false;
           }
           return eventList[i];
         }
       }
    }
     return EVENT_NULL;
  }
  
  void draw(){
    for(int i = 0; i < length; i++){
     stroke(stroke[i]);
     noFill();
     ellipse((x) + width / 2, (y*(i+1)) + height / 2 + (i*10), width, height);
     textFont(widgetFont);
     textAlign(LEFT, CENTER);
     fill(0);
     text(labels[i], x + width + 5, (y*(i+1)) + height /2 + (i*10));
     if(set[i]){
       fill(stroke[i]);
       ellipse(x + width / 2, (y*(i+1)) + height / 2 + (i*10), width / 2, height / 2);
     }
    }
  }
  
  void changeStroke(int mX, int mY){
     for(int i = 0; i < length; i++){
       if(mX>x && mX < x+width && mY >(y*(i+1))+(i*10) && mY <(y*(i+1))+height+(i*10)){
          stroke[i] = 230;
       }
       else stroke[i] = 0;
     }
  }
  
  void set(int i){
    set[i] = true;
    for(int j = 0; j < length; j++){
        if(j != i) set[j] = false;
    }
  }
}
