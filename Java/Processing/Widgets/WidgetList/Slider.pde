class Slider{
   
   float x, y, sliderX, width, height, sliderWidth;
   boolean moving;
   
   Slider(float x, float y, float width, float height, float sliderWidth){
     this.x = x; this.y = y; this.width = width; this.height = height; this.sliderWidth = sliderWidth;
     sliderX = x + width/2;
     moving = false;
   }
   
   void draw(){
     noStroke();
     fill(50);
     rect(x, y + (height/2) - 2, width,4);
     stroke(0);
     rectMode(CENTER);
     fill((moving)?220:250);
     rect(sliderX, y + height/2, sliderWidth, height);
     noStroke();
     fill((moving)?200:220);
     triangle(sliderX-sliderWidth/2,y+height, sliderX+sliderWidth/2, y, sliderX+sliderWidth/2, y+height);
     fill((moving)?220:250);
     rect(sliderX, y+height/2, sliderWidth/1.8, height/1.8);
     rectMode(CORNER);
   }
   
   void move(float mX, float mY){
     if(mX > x && mX < x+width && ((mY > y && mY < y+height)||moving)){
       sliderX = mX;
       moving = true;
     }
   }
   
   int getIntValue(){
     moving = false;
     return round(sliderX);
   }
   
   float getFloatValue(){
     moving = false;
     return sliderX;
   }  
}
