/*
Uses Ani library to move load point to location of active flag point
 --- When start button is pressed, commence / pause movement of load point towards target
 --- Hold down right bumper to seek loadpoint towards active flag point
 --- Calculate duration of animation based on distance to target
 */

Easing[] easings = { 
  Ani.LINEAR, Ani.SINE_IN, Ani.SINE_OUT, Ani.SINE_IN_OUT, Ani.CUBIC_IN, Ani.CUBIC_OUT, Ani.CUBIC_IN_OUT
};
String[] easingsVariableNames = {
  "Ani.LINEAR", "Ani.SINE_IN", "Ani.SINE_OUT", "Ani.SINE_IN_OUT", "Ani.CUBIC_IN", "Ani.CUBIC_OUT", "Ani.CUBIC_IN_OUT"
};

Easing currentEasing = easings[index];

boolean aniMode = true;
boolean destinationMode = false;

float durationCalc; //duration of ani animation
float howFar; //used to show distance between load and flag points

boolean testOne = true; //switch between which flag points are active -- determines next destination
boolean testTwo = false;
boolean playing = false; //to see if ani is playing
boolean paused = false; //test if animation is paused so correct text can be printed to console

float[] dF = new float[4]; //distance from towers to floatOne
float[] dFT = new float[4]; //distance from towers to floatTwo

int[] speed = new int[4]; //individual speeds for each tower while moving towards a point
int[] acceleration = new int[4]; //individual acceleration values

Ani[] ani = new Ani[3]; //for ani X Y and Z
float[] where = new float[3]; //holds load point coordinates for ani destination
String[] coor = {
  "x", "y", "z"
};

//offset values for when 'middle' button is pressed
float midOffx; 
float midOffy; 
float midOffz;


//--------------------------------------    SEE IF ANIMATION IS PLAYING, OR END POINT IS REACHED   --------------------------------------
void testPlaying() { 

  if (playing == true) {

    if (testOne == true) {
      testTwo = false;
    } else {
      testOne = false;
    }

    //test if animation has ended
    if (ani[0].isEnded() || ani[1].isEnded() || ani[2].isEnded()) {
      println("reached end point");
      paused = false;
      playing = false; // if animation has ended, then playing is false
      //switch which flag points are active -- load point has reached target
      if (testOne == true) {
        testOne = false;
        testTwo = true;
      } else if (testTwo == true) {
        testOne = true;
        testTwo = false;
      }
    }
  } //close playing true
}


//--------------------------------------    PLAY/PAUSE ANIMATION WHEN START BUTTON IS PRESSED   --------------------------------------

void startPress() {
  //press the start button to play / pause animation
  //playing =true;
  // when start is pressed, move camera to flag point

  //-------------ANI MODE-------------------
  if (aniMode == true) {
    if (testOne == false) {
      getFlagDist(); //calculates duration of ani based on distance/speed.
    } else {
      getFlagTwoDist();
    }

    for (int i=0; i<3; i++) {
      ani[i] = Ani.to(load, durationCalc, coor[i], where[i], easings[index]);   //declare ani destination and duration, and start animation

      if (ani[i].isPlaying()) { //if animation is playing, then pause
        ani[i].pause();
        paused = true;
        playing = false;
      } else { //otherwise start animation
        ani[i].start();
        paused = false;
        playing = true;
      }
    }

    if (playing == true) {
      println("starting animation");
    } else if (paused == true) {
      println("animation is paused");
    }
  } 

  //-------------DESTINATION MODE-------------------


  else if (destinationMode == true) { 
    if (testOne == true) {
      getFlagDistDestination();
      load.x = flagOne.x;
      load.y = flagOne.y;
      load.z = flagOne.z;
      //next calculate distance differences for each tower and set individual speeds so they all reach their endpoint at the same time.
    } else if (testTwo == true) {
      getFlagTwoDistDestination();
      load.x = flagTwo.x;
      load.y = flagTwo.y;
      load.z = flagTwo.z;
    }

    if (testOne == true) {
      testOne = false ;
      testTwo = true;
    } else if (testTwo == true) {
      testTwo = false;
      testOne = true;
    }

    sendValues();
  }
}//close startPress

//--------------------------------------    WHEN RIGHT TRIGGER IS PRESSED, START SEEKING TOWARDS ANI TARGET  --------------------------------------

void RTPress() { 

  easingMode.activate(0);
  aniMode = true;
  destinationMode = false;

  fillRT = barColorActive; //color for gui on tab 1

  if (testOne == false) {
    getFlagDist(); //calculates duration of ani based on distance/speed.
  } else {
    getFlagTwoDist();
  }

  for (int i=0; i<3; i++) {
    ani[i] = Ani.to(load, durationCalc, coor[i], where[i], easings[index]);   //declare ani destination and duration, and start animation


    if (ani[i].isPlaying()) { //if animation is playing, then pause
    } else { //otherwise start animation
      ani[i].start();
      playing = true;
    }
  }
  println("starting animation");
}
//--------------------------------------    PAUSE ANIMATION WHEN RIGHT BUMPER IS RELEASED   --------------------------------------

void RTRelease() {
  fillRT = barColor; //colour for right bumper pressed gui on tab 1 (seen in top left corner of screen)

  for (int i=0; i<3; i++) {

    if (ani[i].isPlaying()) { //if animation is playing, then pause
      ani[i].pause();
      playing = false;
    }
  }
}

//--------------------------------------    MOVE virtual CAMERA TO MIDDLE WHEN BUTTON IS PRESSED   --------------------------------------

void middle(float v) { 

  println("Reset virtual point to middle");

  midOffx+= (roomWidth/2) - load.x; //create offset so camera IRL doesn't move
  midOffy+= (roomLength/2) - load.y; 
  midOffz+= load.z - cameraSafeZone;

  //move virtual point but not actual camera
  load.x = roomWidth/2;
  load.y = roomLength/2;
  load.z = cameraSafeZone;
}


//-------------------------------------------------------------DESTINATION MODE----------------------------------
//--------------------------------------    speed and acceleration values while easing to flag point #1  --------------------------------------

void getFlagDistDestination() {


  //this gets distance of string from flag point to height corner --> we need difference in these values between load point and corners, and flag point and corners
  dF[0] = abs(dist(flagOne.x, flagOne.y, flagOne.z, 0, 0, origHeight) - dist(load.x, load.y, load.z, 0, 0, origHeight));  
  dF[1] = abs(dist(flagOne.x, flagOne.y, flagOne.z, origWidth, 0, origHeight) - dist(load.x, load.y, load.z, origWidth, 0, origHeight));
  dF[2] = abs(dist(flagOne.x, flagOne.y, flagOne.z, origWidth, origLength, origHeight)- dist(load.x, load.y, load.z, origWidth, origLength, origHeight));
  dF[3] = abs(dist(flagOne.x, flagOne.y, flagOne.z, 0, origLength, origHeight)- dist(load.x, load.y, load.z, 0, origLength, origHeight));

  float[] flagValues = {
    dF[0], dF[1], dF[2], dF[3]
  };

  // println( dF[0], dF[1], dF[2], dF[3]);

  float greatestDist = max(flagValues); //get the greatest distance

  //speeds are relative based on distance to travel --> ensures all motors reach end point at the same time
  for ( int i=0; i<4; i++) { 
    speed[i] = int(motorSpeed/5 * (dF[i]/greatestDist)); 
    acceleration[i] = int((motorAcceleration) * (dF[i]/greatestDist));

    // println("#" + i + " -- distance: " + dF[i] + " speed: " + speed[i] + " acceleration: " + acceleration[i]);
  }
}

//--------------------------------------    speed and acceleration values while easing to flag point #2  --------------------------------------

void getFlagTwoDistDestination() {

  //this gets distance of string from flag point to height corner --> we need difference in these values between load point and corners, and flag point and corners
  dFT[0] = abs(dist(flagTwo.x, flagTwo.y, flagTwo.z, 0, 0, origHeight) - dist(load.x, load.y, load.z, 0, 0, origHeight));  
  dFT[1] = abs(dist(flagTwo.x, flagTwo.y, flagTwo.z, origWidth, 0, origHeight) - dist(load.x, load.y, load.z, origWidth, 0, origHeight));
  dFT[2] = abs(dist(flagTwo.x, flagTwo.y, flagTwo.z, origWidth, origLength, origHeight)- dist(load.x, load.y, load.z, origWidth, origLength, origHeight));
  dFT[3] = abs(dist(flagTwo.x, flagTwo.y, flagTwo.z, 0, origLength, origHeight)- dist(load.x, load.y, load.z, 0, origLength, origHeight));

  float[] flagValues = {
    dFT[0], dFT[1], dFT[2], dFT[3]
  };

  float greatestDist = max(flagValues);

  //speeds are relative based on distance to travel --> ensures all motors reach end point at the same time 
  for ( int i=0; i<4; i++) {
    speed[i] = int(motorSpeed/5 * (dFT[i]/greatestDist)); 
    acceleration[i] = int(motorAcceleration * (dFT[i]/greatestDist));
    // println("#" + i + " -- distance: " + dFT[i] + " speed: " + speed[i] + " acceleration: " + acceleration[i]);
  }
}

//--------------------------------------------------------------------MODE--------------------------------
//--------------------------------------    CALCULATE DURATION OF ANI EASING BASED ON DISTANCE/SPEED - to flag1  --------------------------------------

void getFlagDist() {
  howFar = dist(load.x, load.y, load.z, flagOne.x, flagOne.y, flagOne.z);
  durationCalc = int((howFar/motorSpeed)*400);
  if (durationCalc<1) { //prevents crashing when value =0
    durationCalc = 1;
  }

  where[0] = flagOne.x;
  where[1] = flagOne.y;
  where[2] = flagOne.z;

  println(durationCalc + " to reach flag point");
}

//--------------------------------------    CALCULATE DURATION OF ANI EASING BASED ON DISTANCE/SPEED - to flag2  --------------------------------------

void getFlagTwoDist() {
  howFar = dist(load.x, load.y, load.z, flagTwo.x, flagTwo.y, flagTwo.z);
  durationCalc = int((howFar/motorSpeed)*400);
  if (durationCalc<1) {//prevents crashing when value =0
    durationCalc = 1;
  }

  where[0] = flagTwo.x;
  where[1] = flagTwo.y;
  where[2] = flagTwo.z;

  println(durationCalc + " to reach flag point");
}

