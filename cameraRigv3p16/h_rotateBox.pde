/* 
 Controls rotation of 3D room visualization
 --- Sets starting rotation value when program is opened
 --- Rotates 3D visualization when arrow keys on keyboard are pressed
 --- Tests if an angle was selected from 'view options' accordion
 -------- if angle was selected, but rotation was manually changed with keyboard, set to false (effects drag position of load)
 */

//starting rotation values --> corner view
float  rotx = -0.9;
float  roty = 0.5;

void rotateBox() { //CHANGE THIS TO KEY PRESSED FUNCTION

  //control with arrow buttons on keyboard 
  if (keyPressed && keyCode==UP) {
    rotx = rotx + 0.01;
  }
  if (keyPressed && keyCode==DOWN) {
    rotx = rotx - 0.01;
  }
  if (keyPressed && keyCode==LEFT) {
    roty = roty - 0.01;
  }
  if (keyPressed && keyCode==RIGHT) {
    roty = roty + 0.01;
  }



  //if anything is pressed that will change the rotation view of box, disable load point editing
  // otherwise point moves in weird direction & it's not obvious where you're moving it to. 
  if (view[0] == true || view[1] == true || view[2] == true || view[3] == true) {
    if (keyPressed && keyCode==UP || keyPressed && keyCode==DOWN || keyPressed && keyCode==LEFT || keyPressed && keyCode==RIGHT ) {
      view[0] = false;
      view[1] = false;
      view[2] = false;
      view[3] = false;

      r1.deactivateAll(); //deactivate view button
      //println("deactivated");
    }
  }
}//close rotate box

