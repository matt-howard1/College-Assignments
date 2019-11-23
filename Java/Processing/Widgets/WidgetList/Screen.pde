class Screen{
  ArrayList<Widget> widgetList;
  int width, height;
  color background;
  
  Screen(int width, int height, color backgroundColour){
    this.width = width;
    this.height = height;
    background = backgroundColour;
    widgetList = new ArrayList<Widget>();
  }
  
  void draw(){
    background(background);
    for(Widget widget : widgetList){
        widget.draw();
    }
  }
  
  void addWidget(Widget widget){
    widgetList.add(widget);
  }
  
  int getEvent(){
    for(Widget widget : widgetList){
       int event = widget.getEvent(mouseX,mouseY);
       if(event != EVENT_NULL) return event;
    }
    return EVENT_NULL;
  }
  
  void updateWidgetStroke(){
    for(Widget widget : widgetList){
      widget.changeStroke(mouseX, mouseY);
    }
  }
}
