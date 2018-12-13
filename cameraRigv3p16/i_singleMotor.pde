/* 
 Activate and Deactivate individual motor radio boxes when letter button is held/ released
 */

float[] coolie = { //values to send to arduino --> amount of string to spool for each motor --> used in coolie function on flagOne tab
  0, 0, 0, 0
};

boolean eachMotor[] = {  //tests to see if individual motors radio button is activated --> used in coolie function on flagOne tab
  false, false, false, false
};

//--------------------------------------    ACTIVATE MOTOR RADIO BUTTON WHEN LETTER IS HELD DOWN    --------------------------------------

void yHold() {
  r2.activate(0);// y = motor 1
  letterPressed[0] = true; //used to test if being held down or not, effects how flag points are moved
}
void bHold() {
  r2.activate(1);// b = motor 2
  letterPressed[1] = true;
}
void aHold() {
  r2.activate(2);// a = motor 3
  letterPressed[2] = true;
}
void xHold() {
  r2.activate(3);// x = motor 4
  letterPressed[3] = true;
}

//--------------------------------------    DEACTIVATE MOTOR RADIO BUTTONS ON LETTER BUTTON RELEASE    --------------------------------------

void yRelease() {
  r2.deactivateAll();
  letterPressed[0] = false;
}
void bRelease() {
  r2.deactivateAll();
  letterPressed[1] = false;
}
void aRelease() {
  r2.deactivateAll();
  letterPressed[2] = false;
}
void xRelease() {
  r2.deactivateAll();
  letterPressed[3] = false;
}

//--------------------------------------    PREVENT MOTOR RADIO BUTTON CLICKABILITY    --------------------------------------
//test to see if letter is held down, if not de-activate individual motors --> prevents motors from being activated on mouse click
void testMotors() {
  for (int i=0; i<4; i++) { 
    if (letterPressed[0] == false && letterPressed[1] == false && letterPressed[2] == false && letterPressed[3] == false) { //used to test if being held down or not, effects how flag points are moved
      r2.deactivateAll();
    }
  }
}

