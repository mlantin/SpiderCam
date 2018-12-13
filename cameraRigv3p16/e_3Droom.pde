/*
MAPS values and DRAWS 3D box in middle of screen
 */

float boxWidth, boxLength, boxHeight;
float maxWidth, minWidth, maxLength, minLength, maxHeight, minHeight;
int ground = 0; //set ground
int pushZ = 188; //z value of translation on 3D box

class towerClass {
  float xrel, yrel, zrel, guix, guiy, guiz;
  int size = 20, id;
  int dx, dy;
  boolean locked = false, mouseOver = false;
  float tempGuiz;
  float tempGuix;
  float tempGuiy;

  towerClass(int tempid, float tempxrel, float tempyrel, float tempzrel) {
    xrel = tempxrel; 
    yrel = tempyrel; 
    zrel = tempzrel;
    id = tempid;
    tempGuiz = tempzrel;
  }

  void update() {

    //individual tower heights are adjusted in set dimen box
    tower1.zrel = t1z;
    tower2.zrel = t2z;
    tower3.zrel = t3z;
    tower4.zrel = t4z;

    //if x or y position of tower is greater than 0, 
    //set to roomWidth or length so it updates with accordion number boxes
    if (xrel>0) {
      xrel = roomWidth;
    } 
    if (yrel>0) {
      yrel = roomLength;
    }

    rotateBox(); //if arrow keys are pressed, 3D box will rotate in appropriate direction
    placePoint(); //place load point in 3D box
    displayFlagPoints();//place flag points in 3D box
    drawCube(); //3D representation of cube
    constrainFlagPoint(); //keep flag points within 3D cube
  }//close update

  //--------------------------------------    DRAW CUBE    --------------------------------------

  void drawCube() {

    //------------------    scale room dimensions so they're proportionately mapped to locationDisplay    ------------------
    //-----------------------------    if room height is larger than width or length   -------------------------------------

    if (roomHeight>=roomLength && roomHeight>=roomWidth) {
      float mappedHeight = map(roomHeight, 0, roomHeight, 0, 3*(map.getHeight()/8));  //map x position to be 3/8 width of GUI -- makes sure it fits.
      float difference =  mappedHeight/roomHeight; //calculates the % difference between original height and scaled height
      //set values to be proportionate to mapped size --> add map.get_ so that it's positioned on locationDisplay
      guix = (xrel*difference)+map.getX(); 
      guiy = (yrel*difference)+map.getY();
      guiz = zrel*difference;
    }

    //-----------------------------    length or width is greater than height   -------------------------------------

    else {
      //map room dimensions to GUI space so it's proportionate, 
      //and so that a room size larger than the GUI will always be scaled. 
      if (roomWidth>roomLength) {
        float w = roomLength/roomWidth; //calculate % difference
        if (w<=0.75) { //if length is less than 75% of room width, fit to 1/2 of background square
          guix = map(xrel, 0, roomWidth, 0, 7*(map.getWidth())/16) + map.getX();  //map x position to be 7/16 width of GUI
          guiy = map(yrel, 0, roomLength, 0, 7*(map.getHeight()*w)/16) + map.getY(); //y mapped proportionately
        } else {          //if length is more than 75% of room width, fit to 3/8 of background squaremake
          guix = map(xrel, 0, roomWidth, 0, 3*(map.getWidth()/8)) + map.getX();  //map x position to be 3/8 width of GUI
          guiy = map(yrel, 0, roomLength, 0, 3*(map.getHeight()*w)/8) + map.getY(); //y mapped proportionately
        }
      } else {
        float l = roomWidth/roomLength; //calculate % difference
        if (l<=0.75) { //if width is less than 75% of room length, fit to 7/16 of background square
          guix = map(xrel, 0, roomWidth, 0, 7*(map.getWidth()*l)/16) + map.getX(); 
          guiy = map(yrel, 0, roomLength, 0, 7*(map.getHeight())/16) + map.getY();
        } else { //if width is more than 75% of room length, fit to 3/8 of background squaremake
          guix = map(xrel, 0, roomWidth, 0, 3*(map.getWidth()*l)/8) + map.getX(); 
          guiy = map(yrel, 0, roomLength, 0, 3*map.getHeight()/8) + map.getY();
        }
      }

      float newL = tower3.guiy-tower2.guiy; //new roomLength
      guiz = (newL/roomLength)*zrel; //scale height of tower so it's proportionate with length and width
    }

    //--------------------------------------    set maximum and minimum mapped dimension values   --------------------------------------

    maxWidth = tower2.guix; //get widest width point --> rectangle so tower2.x == tower3.x
    minWidth = tower1.guix; //get lowest width point --> rectangle so tower1.x == tower4.x
    maxLength = tower4.guiy; //get largest length point --> rectangle so tower3.x == tower4.x
    minLength = tower1.guiy; //get lowest length point --> rectangle so tower1.x == tower2.x

    float[] heightValues = {
      tower1.guiz, tower2.guiz, tower3.guiz, tower4.guiz
    };

    maxHeight = max(heightValues); //get tallest tower
    minHeight = min(heightValues);  //get shortest tower

    //calculate dimensions of 3D box now that its size is relative to gui space
    boxWidth = maxWidth-map.getX();
    boxLength = maxLength-map.getY();
    boxHeight = maxHeight;


    //--------------------------------------    1st translation - set rotation point, draw box, draw strings to load   --------------------------------------

    pushMatrix(); //push so translations can be applied without effecting everything else
    //try to centre box on location map -- z value pushes the box beyond the grey background, otherwise 1/2 is hidden. Z value is approximation. 
    translate((map.getWidth()/2)+map.getX(), (map.getHeight()/2)+map.getY(), pushZ);     //move rotation point to middle of screen
    rotateX(rotx); 
    rotateY(roty);

    noFill();
    stroke(barColor);
    //draw a line to represent each tower -- move to middle of space  **guiz was multiplied by -1 so tower height is at top of rectangle
    line(guix-map.getX()-(boxWidth/2), (guiz-boxHeight/2)*-1, guiy-map.getY()-boxLength/2, guix-map.getX()-(boxWidth/2), maxHeight-boxHeight/2, guiy-map.getY()-boxLength/2);

    //draw lines to connect towers to one another --> this creates roof perimeter 
    line(tower1.guix-map.getX()-(boxWidth/2), (tower1.guiz-boxHeight/2)*-1, tower1.guiy-map.getY()-boxLength/2, tower2.guix-map.getX()-(boxWidth/2), (tower2.guiz-boxHeight/2)*-1, tower2.guiy-map.getY()-boxLength/2); 
    line(tower1.guix-map.getX()-(boxWidth/2), (tower1.guiz-boxHeight/2)*-1, tower1.guiy-map.getY()-boxLength/2, tower4.guix-map.getX()-(boxWidth/2), (tower4.guiz-boxHeight/2)*-1, tower4.guiy-map.getY()-boxLength/2); 
    line(tower3.guix-map.getX()-(boxWidth/2), (tower3.guiz-boxHeight/2)*-1, tower3.guiy-map.getY()-boxLength/2, tower2.guix-map.getX()-(boxWidth/2), (tower2.guiz-boxHeight/2)*-1, tower2.guiy-map.getY()-boxLength/2); 
    line(tower3.guix-map.getX()-(boxWidth/2), (tower3.guiz-boxHeight/2)*-1, tower3.guiy-map.getY()-boxLength/2, tower4.guix-map.getX()-(boxWidth/2), (tower4.guiz-boxHeight/2)*-1, tower4.guiy-map.getY()-boxLength/2); 

    fill(0);
    stroke(textColor);
    //represents strings connecting top of tower to load point
    line(guix-map.getX()-(boxWidth/2), (guiz-boxHeight/2)*-1, guiy-map.getY()-boxLength/2, loadguix-map.getX()-boxWidth/2, -loadguiz+boxHeight/2, loadguiy-map.getY()-boxLength/2);

    //--------------------------------------    translation for box floor & max min text indicator   --------------------------------------
    stroke(barColor);
    fill(77, 79, 92); //textColour
    textFont(boundaryFont);
    textAlign(CENTER);

    pushMatrix();
    translate(-boxWidth/2, maxHeight/2, -boxLength/2);
    rotateX(-80); //rotate text so it's flat along box bottom
    text("maximum length", boxWidth/2, boxLength+7, -map.getY()/2);
    text("minimum length", boxWidth/2, -5, 0);

    rotateZ(7.85); //don't know why this has to be a decimal
    rotateY(0.09);//rotate text so it's flat along bottom of box
    text("maximum width", boxLength/2, -boxWidth-5, 0);
    text("minimum width", boxLength/2, 10, 0);

    //shape(maxWidthText, boxLength/2, -boxWidth-25, 75, 13.875);
    //text("maximum width", 0, 0, 0);

    rotateY(-0.09); //undo previous rotation
    rotateZ(-7.85); //undo previous rotation
    rotateX(80); //undo previous rotation

    rotateX(89.535); //rotate so rectangle is flat --> box floor rotation
    fill(237, 239, 245, 200); //same colour as entire background but slightly transparent
    rect(0, 0, boxWidth, boxLength);

    popMatrix();

    //--------------------------------------    translation for tower1 indicator   --------------------------------------

    pushMatrix();
    fill(buttonOne);
    textAlign(LEFT);
    noStroke();
    translate(tower1.guix-boxWidth/2-map.getX(), 0+boxHeight/2, tower1.guiy-boxLength/2 -map.getY());
    sphere(2);
    popMatrix();
    popMatrix();// close first push to centre on location map
  }// close drawCube
}//close tower class

