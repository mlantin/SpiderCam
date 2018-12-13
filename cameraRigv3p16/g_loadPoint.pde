/*
Displays load point and flag points within 3D space
 --- Tests if a view mode is active, if so load point can be moved with the mouse
 -------- this helps to realign load point if its position is slightly off
 -------- doesn't effect tower rope values, more of a visual change
 */

int mouseDragX, mouseDragY, mouseDragZ;
float maxDragY;
float minDragY;
float dragX;
float dragY;
float dragZ;
float largeDimen;

float loadguix, loadguiy, loadguiz;
float prop;

float[] startingVal =  new float[3];//before point is dragged

float[] endingVal = new float[3]; //value of load point while being dragged
float[] afterVal = new float[3];//saved endingValue of load point after being dragged


//--------------------------------------    KEEP LOAD POINT IN BOUNDS    --------------------------------------

void checkBounds() {

  //println("Hit Top = " + hitTop + " topSafe = " + topSafe);



  //compare heights of towers -- if towers are different heights then adjust maximum height constraint of load point depending on where it is in space
  //compare the height differences between the length towers on each side
  minOne = min(tower1.zrel, tower4.zrel);
  minTwo = min(tower2.zrel, tower3.zrel);

  towerDistOne = dist(tower1.zrel, 0, tower4.zrel, 0); //calculate height difference between tower 1 and tower 4
  towerDistTwo = dist(tower2.zrel, 0, tower3.zrel, 0); //calculate height difference between tower 2 and tower 3

  //if towers are all the same height, hitTop value is set to room height, 
  //otherwise calculate maximum height based on load point location
  if ( (tower1.zrel==tower2.zrel) && (tower2.zrel == tower3.zrel) && (tower3.zrel == tower4.zrel)) { 
    hitTop = roomHeight;
  } else {
    if (tower1.zrel<=tower4.zrel) {
      hitTopOne = ((prog[1]/100)*towerDistOne) + minOne;
    } else {
      hitTopOne = ((1-(prog[1]/100))*towerDistOne) + minOne;
    }
    if (tower2.zrel<=tower3.zrel) {
      hitTopTwo = ((prog[1]/100)*towerDistTwo) + minTwo;
    } else {
      hitTopTwo = ((1-(prog[1]/100))*towerDistTwo) + minTwo;
    }
    hitTop = ((hitTopOne * (1-(prog[0]/100))) + (hitTopTwo *(prog[0]/100))); //the strength of each hitTop value depends on width value of load point
  }

  //Keep in bounds
  if (load.x <= minWidSafe) {
    load.x = minWidSafe;
  }
  if (load.x >= roomWidth - maxWidSafe) {
    load.x = roomWidth - maxWidSafe;
  }
  if (load.y <= minLenSafe) {
    load.y = minLenSafe;
  }
  if (load.y >= roomLength - maxLenSafe) {
    load.y = roomLength - maxLenSafe;
  }
  if (load.z <= cameraSafeZone) {  //don't let camera touch ground
    load.z = cameraSafeZone;
  }
  if (load.z >= hitTop) { //keep camera away from ceiling -- if ropes pull too tight box will lift off ground 
    load.z = hitTop;
  }
}
//--------------------------------------    PLACE LOAD POINT IN 3D RECTANGLE    --------------------------------------

void placePoint() {

  // map load point to 3D space visualization 
  loadguix = map(load.x, 0, roomWidth, minWidth, maxWidth);
  loadguiy = map(load.y, 0, roomLength, minLength, maxLength);
  loadguiz = map(load.z, 0, roomHeight, 0, maxHeight);

  pushMatrix(); //push so translations can be applied without effecting everything else
  //centre everything on location map
  translate((map.getWidth()/2)+map.getX(), (map.getHeight()/2)+map.getY(), pushZ); //move rotation point to middle of screen
  rotateX(rotx); 
  rotateY(roty);

  //--------------------------------------    translation for load point   --------------------------------------

  //push to translate sphere that represents 360 cam to middle of space
  pushMatrix();
  fill(buttonTwo);
  noStroke();
  //Sphere has already been translated to the middle of the GUI screen earlier --> add translation so that it moves with load point
  translate(loadguix-map.getX()-boxWidth/2, -loadguiz+boxHeight/2, loadguiy-map.getY()-boxLength/2);
  sphere(3);//camera/loadPoint
  popMatrix();
  popMatrix(); // close first push to centre on location map
}

//--------------------------------------   MOUSE EVENTS FOR DRAGGING LOAD POINT    --------------------------------------

void mousePressed() {
  //get values of load point before point is dragged
  startingVal[0] = load.x;
  startingVal[1] = load.y;
  startingVal[2] = load.z;
}

void mouseDragged() {

  //reset values to 0 after
  mouseDragX = 0;
  mouseDragY = 0;
  mouseDragZ = 0;

  // all inBounds statements prevent load point  from locking 
  if (view[3]==true && mouseOver == true) { //TOP
    mouseDragX += (mouseX - pmouseX); //drag is distance between mouse and previous mouse location
    mouseDragY += (mouseY - pmouseY);
    mouseDragZ = mouseDragZ;
  } 

  if (view[2] == true && mouseOver == true) { //WIDTH
    mouseDragX += (mouseX - pmouseX); 
    mouseDragY = mouseDragY;
    mouseDragZ +=(mouseY - pmouseY);
  }

  if (view[1]==true && mouseOver == true) { //LENGTH
    mouseDragX = mouseDragX;
    mouseDragY += (mouseX - pmouseX);
    mouseDragZ +=(mouseY - pmouseY);
  }

  //determine prop value -- used to match mouseDrag distance to visual distance of load point within space
  largeDimen = max(roomLength, roomWidth);
  prop = largeDimen*(0.0025);

  if (view[1]==true || view[2] == true || view[3] == true) {
    //only move load point if it's within safe zone
    if ((load.x+(mouseDragX*prop))>=minWidSafe && (load.x +(mouseDragX*prop)) < (roomWidth - maxWidSafe) && (load.y +(mouseDragY*prop)) >= minLenSafe && (load.y +(mouseDragY*prop))<= (roomLength-maxLenSafe) && (load.z - (mouseDragZ*prop))>= cameraSafeZone && (load.z- (mouseDragZ*prop))<= (hitTop)) {
      load.x +=(mouseDragX*prop);
      load.y +=(mouseDragY*prop);
      load.z -=(mouseDragZ*prop);
    }
  }
  //calculate difference between current z value of load point and starting value
  //this is subtracted from value in getDistances() so the motors don't spool thread to make up for change in location
  endingVal[0] = load.x-startingVal[0];
  endingVal[1] = load.y-startingVal[1];
  endingVal[2] = load.z-startingVal[2];

  //this is the value that's subtracted from load coordinate in distance calculation
  //subtracted offset because when mouse drags room dimension number boxes to change them, drag values would also change unnecessariy 
  dragX = (afterVal[0]+endingVal[0]) - offX; 
  dragY = (afterVal[1]+endingVal[1]) - offY;
  dragZ = (afterVal[2]+endingVal[2]) - offZ;
}

void mouseReleased() {  
  if (view[1]==true || view[2] == true || view[3] == true) {

    //these are used to show offset between load point & dragged loadpoint
    //stops motors from running unnecessarily if load point is dragged out of space. 

    for (int i=0; i<3; i++) {
      afterVal[i] += endingVal[i];
      endingVal[i] = 0;
    }
  }
}

