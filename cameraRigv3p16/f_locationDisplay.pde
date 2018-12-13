//The module displaying current location in space
//holds tower variables

boolean mouseOver = false;

class locationDisplay {

  int y, x, wide, high, mx, my;
  color darkColor = color(10, 10, 100);
  color lightColor = color(10, 150, 230);

  locationDisplay(int xPos, int yPos, int xLength, int yLength) {
    y = yPos;  // distance of area from top of window
    x = xPos;  //distance of area from left side of sindow
    wide = xLength;  //width of area
    high = yLength;  //length of area
  }

  void update() {
    updateMouse(); //is mouse over location area? 

    //don't show outline of visualization area if help page is visible
    if (helpPage == false) {
      colorGUI(); //if mouse is over location area, respond by changing stroke on GUI background
    }

    tower1.update();
    tower2.update();
    tower3.update();
    tower4.update();
  }

  void colorGUI() {

    fill(backgroundColor);
    if (mouseOver == true) { 
      stroke(lightColor);
    } else { 
      stroke(barColor);
    }

    rectMode(CORNER);
    rect(x, y, wide, high);
  }

  void updateMouse() {
    mx = mouseX - x;
    my = mouseY - y;

    //Boolean true if mouse is over area
    if (mx > 0 && mx < wide && my > 0 && my < high) {
      mouseOver = true;
    } else {
      mouseOver = false;
    }
  }

  public int getWidth() {
    return wide - 20;
  }

  public int getHeight() {
    return high - 20;
  }

  public int getX() {
    return x + 10;
  }

  public int getY() {
    return y + 10;
  }
}

