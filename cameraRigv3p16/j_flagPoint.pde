/*
Map flag points to 3D visualization and make sure they're kept in bounds
 --- Press the back button to move flagOne to the current load point
 --- Move flagOne through space using the coolie pad and left trigger and bumper 
 --- Move flagTwo through space by holding down right trigger with coolie pad and left trigger and bumper 
 -------- Coolie pad moves flag points along width / length
 -------- Left trigger and bumper moves flag points up / down
 --- Also contains snippet of code for individual motor control 
 -------- If a motor is selected, coolie pad Y axis buttons are used to spool / reel in string
 */

//int rb, rt;
float flagOneguix, flagOneguiy, flagOneguiz; //flag one location values
float flagTwoguix, flagTwoguiy, flagTwoguiz; //flag two location values

float faTwo, faOne, fa;
float fbTwo, fbOne, fb;

boolean moveTarget; //when right bottom button is pressed, switch between which target can be moved. 

boolean[] letterPressed = {  //tests to see if a letter is pressed
  false, false, false, false
};

float[] progA = { //array to hold values for progress sliders (flagOne)
  0, 0, 0
};

float[] progB = { //array to hold values for progress sliders (flagTwo)
  0, 0, 0
};

//--------------------------------------    MAP FLAG POINTS TO ROOM VISUALIZATION    --------------------------------------

void constrainFlagPoint() {
  fill(255, 0, 0);

  // get progress % of flag points across space -- this is used to determine maximum height in that area
  progA[0] = map(flagOne.x, 0, roomWidth, 0, 100); //width progress
  progA[1] = map(flagOne.y, 0, roomLength, 0, 100); //length progress
  progA[2] = map(flagOne.z, 0, roomHeight, 0, 100);//height progress

  progB[0] = map(flagTwo.x, 0, roomWidth, 0, 100); //width progress
  progB[1] = map(flagTwo.y, 0, roomLength, 0, 100); //length progress
  progB[2] = map(flagTwo.z, 0, roomHeight, 0, 100);//height progress

  //keep flag points within mapped values of 3D room visualization
  flagOneguix = map(flagOne.x, 0, roomWidth, minWidth, maxWidth);
  flagOneguiy = map(flagOne.y, 0, roomLength, minLength, maxLength);
  flagOneguiz = map(flagOne.z, 0, roomHeight, 0, maxHeight);

  flagTwoguix = map(flagTwo.x, 0, roomWidth, minWidth, maxWidth);
  flagTwoguiy = map(flagTwo.y, 0, roomLength, minLength, maxLength);
  flagTwoguiz = map(flagTwo.z, 0, roomHeight, 0, maxHeight);

  //if towers are all the same height, maximum height value is set to room height, 
  //otherwise calculate maximum height based on load point location
  if ( (tower1.zrel==tower2.zrel) && (tower2.zrel == tower3.zrel) && (tower3.zrel == tower4.zrel)) { 
    fa = roomHeight;
    fb = roomHeight;
  } else {
    //determine maximum height value for flag points if the ceiling is uneven --> maybe only call this if towers are uneven, otherwise set as roomheight
    if (tower1.zrel<=tower4.zrel) {
      faOne = ((progA[1]/100)*towerDistOne) + minOne;
      fbOne = ((progB[1]/100)*towerDistOne) + minOne;
    } else {    
      faOne = ((1-(progA[1]/100))*towerDistOne) + minOne;
      fbOne = ((1-(progA[1]/100))*towerDistOne) + minOne;
    }
    if (tower2.zrel<=tower3.zrel) {
      faTwo = ((progA[1]/100)*towerDistTwo) + minTwo;
      fbTwo = ((progB[1]/100)*towerDistTwo) + minTwo;
    } else {
      faTwo = ((1-(progA[1]/100))*towerDistTwo) + minTwo;
      fbTwo = ((1-(progB[1]/100))*towerDistTwo) + minTwo;
    }
    fa = ((faOne * (1-(progA[0]/100))) + (faTwo *(progA[0]/100))); //the strength of each hitTop value depends on width value of load point
    fb = ((fbOne * (1-(progB[0]/100))) + (fbTwo *(progB[0]/100))); //the strength of each hitTop value depends on width value of load point
  }

  //-------------Keep flagOne in Bounds------------------------
  if (flagOne.x <= minWidSafe) {
    flagOne.x = minWidSafe;
  } 
  if (flagOne.x >= roomWidth - maxWidSafe) {
    flagOne.x = roomWidth - maxWidSafe;
  }
  if (flagOne.y <= minLenSafe) {
    flagOne.y = minLenSafe;
  }
  if (flagOne.y >= roomLength - maxLenSafe) {
    flagOne.y = roomLength - maxLenSafe;
  }
  if (flagOne.z <= cameraSafeZone) {  //stop camera from hitting ground
    flagOne.z = cameraSafeZone;
  }
  if (flagOne.z >= fa ) { //keep within ceiling constraints 
    flagOne.z = fa;
  } 

  //--------------Keep flagTwo in Bounds----------
  if (flagTwo.x <= minWidSafe) {
    flagTwo.x = minWidSafe;
  } 
  if (flagTwo.x >= roomWidth - maxWidSafe) {
    flagTwo.x = roomWidth - maxWidSafe;
  }
  if (flagTwo.y <= minLenSafe) {
    flagTwo.y = minLenSafe;
  }
  if (flagTwo.y >= roomLength - maxLenSafe) {
    flagTwo.y = roomLength - maxLenSafe;
  }
  if (flagTwo.z <= cameraSafeZone) {  //stop camera from hitting ground
    flagTwo.z = cameraSafeZone;
  }
  if (flagTwo.z >= fb) { //keep within ceiling constraints
    flagTwo.z = fb;
  }
}

//--------------------------------------    PLACE FLAG POINTS IN 3D RECTANGLE    --------------------------------------

void displayFlagPoints() {

  pushMatrix(); //push so translations can be applied without effecting everything else
  //try to centre everything on location map
  translate((map.getWidth()/2)+map.getX(), (map.getHeight()/2)+map.getY(), pushZ);     //move rotation point to middle of screen
  rotateX(rotx); 
  rotateY(roty);

  //--------------------------------------    translation for flagOne   --------------------------------------
  pushMatrix();
  translate(flagOneguix-map.getX()-boxWidth/2, -flagOneguiz+boxHeight/2, flagOneguiy-map.getY()-boxLength/2);
  if (testOne == false) {
    fill(triangleColor); //active and inactive colours -- adjust transparency to show which one is next. different colours to indicate flag 1 and flag2
  } else {
    fill(lightPink);
  }
  sphere(3);
  popMatrix();

  //--------------------------------------    translation for flagTwo   --------------------------------------
  pushMatrix();
  //Sphere has already been translated to the middle of the GUI screen earlier --> add translation so that it moves with flagOne
  translate(flagTwoguix-map.getX()-boxWidth/2, -flagTwoguiz+boxHeight/2, flagTwoguiy-map.getY()-boxLength/2);
  if (testTwo == false) {
    fill(radioColorActive); //active and inactive colours -- adjust transparency to show which one is next. different colours to indicate flag 1 and flag2
  } else {
    fill(color(249, 197, 17, 20));
  }
  sphere(3);
  popMatrix();
  popMatrix();
}

//--------------------------------------    SET FLAG POINT TO CURRENT LOCATION OF LOAD POINT WHEN BACK BUTTON IS PRESSED   --------------------------------------
void selectPress() { //run when select button is pressed
  //Press select button to move flagOne to current load point position
  // if (playing == false) {
  //if flag one is active, then move flag 1 to location of load point
  if (testOne == false) {
    flagOne.x = load.x;
    flagOne.y = load.y;
    flagOne.z =  load.z;
    testOne = true; //switch active flag
    testTwo = false; //switch active flag
  } else { //else if flag two is active, move flag 2 to location of load point
    flagTwo.x = load.x;
    flagTwo.y = load.y;
    flagTwo.z = load.z;
    testOne = false; //switch active flag
    testTwo = true; //switch active flag
  }
  // }
}

//--------------------------------------    MOVE FLAG POINTS WITH CONTROLLER    --------------------------------------
//-------------------------    contains individual button functions for triggers and bumpers    ----------------------

//top right button pressed
//toggle between which flag point is able to be moved. 
void RBPress() {
  fillRB = barColorActive; 
  if (moveTarget == true) {
    moveTarget = false;
    flag.getItem(0).getCaptionLabel().hide();
    flag.getItem(1).getCaptionLabel().show();
  } else {
    moveTarget = true;
    flag.getItem(0).getCaptionLabel().show();
    flag.getItem(1).getCaptionLabel().hide();
  }
}

void RBRelease() {
  fillRB = barColor;
}

//while left trigger is being held down, move flag points DOWN
void LTHold() { 
  if (moveTarget == true) {
    flagOne.z-=2;
  } else {
    flagTwo.z-=2;
  }
}

void LBPress() {
  fillLB = barColorActive;
}

//while left Bumper is being held down, move flag points UP
void LBHold() { 
  if (moveTarget == true) {
    flagOne.z+=2;
  } else {
    flagTwo.z+=2;
  }
}

void LBRelease() {
  fillLB = barColor;
}

void LTPress() {
  fillLT = barColorActive;
}

void LTRelease() {
  fillLT = barColor;
}

//--------------------------------------    MOVE FLAG POINTS ALONG LENGTH / WIDTH    --------------------------------------
//-----------------------------------    USE COOLIE BUTTONS TO SPOOL / REEL THREAD    -------------------------------------


void coolieLeftPress() { //move flag points left (along length) when left button is pressed
  if (moveTarget == true && letterPressed[0] == false && letterPressed[1] == false && letterPressed[2] == false && letterPressed[3] == false) {
    flagOne.y -= 1;
  } else  if (moveTarget == false && letterPressed[0] == false && letterPressed[1] == false && letterPressed[2] == false && letterPressed[3] == false) {
    flagTwo.y -= 1;
  }
}

void coolieRightPress() { //move flag points right (along length) when right button is pressed
  if (moveTarget == true && letterPressed[0] == false && letterPressed[1] == false && letterPressed[2] == false && letterPressed[3] == false) {
    flagOne.y += 1;
  } else  if (moveTarget == false && letterPressed[0] == false && letterPressed[1] == false && letterPressed[2] == false && letterPressed[3] == false) {
    flagTwo.y += 1;
  }
}

void coolieUpPress() { // move flag point along width when up button is pressed // or spool thread when letter button is also held down
  if (moveTarget == true && letterPressed[0] == false && letterPressed[1] == false && letterPressed[2] == false && letterPressed[3] == false) {
    flagOne.x += 1;
  } else  if (moveTarget == false && letterPressed[0] == false && letterPressed[1] == false && letterPressed[2] == false && letterPressed[3] == false) {
    flagTwo.x += 1;
  }
  for (int i=0; i<4; i++) { //iterate through motors
    if (eachMotor[i] == true) { //if a motor is selected
      coolie[i] += indiSpeed; //send to sendValues() to individually adjust motors
    }
  }
}

void coolieDownPress() {// move flag point along width when up button is pressed // or spool thread when letter button is also held down
  if (moveTarget == true && letterPressed[0] == false && letterPressed[1] == false && letterPressed[2] == false && letterPressed[3] == false) {
    flagOne.x -= 1;
  } else  if (moveTarget == false && letterPressed[0] == false && letterPressed[1] == false && letterPressed[2] == false && letterPressed[3] == false) {
    flagTwo.x -= 1;
  }
  for (int i=0; i<4; i++) { //iterate through motors
    if (eachMotor[i] == true) { //if a motor is selected
      coolie[i] -= indiSpeed; //send to sendValues() to individually adjust motors
    }
  }
}

