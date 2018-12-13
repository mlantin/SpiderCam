/*
Locate connected controller and setup buttons
 --- Assign buttons, sticks and sliders
 --- Buttons vary depending on controller, this setup is for Logitec Dual Action
 */

ControllIO controll; //abstraction of the controller object
ControllDevice device; //abstraction of the entire controller
ControllStick stickL; //left stick on controller
ControllStick stickR;//right stick on controller

//declare buttons on controller 
ControllButton A;
ControllButton B;
ControllButton Y; 
ControllButton X; 
ControllButton LB;
ControllButton L2;
ControllButton backButton;
ControllButton RB;
ControllButton R2;
ControllButton startButton;
ControllButton LP;
ControllButton RP;
ControllButton RT;
ControllButton LT;

ControllButton coolieUp;
ControllButton coolieDown;
ControllButton coolieLeft;
ControllButton coolieRight;

boolean deviceConnected = false;

float stickRX;
float stickRY;
float stickLY;

//Controller deadzone
float deadZ = 0.1;

void getController() {

  controll = ControllIO.getInstance(this);

  //ControllDevice device = controll.getDevice("PLAYSTATION(R)3 Controller");

  for (int i = 0; i < controll.getNumberOfDevices (); i++) {

    ControllDevice device = controll.getDevice(i); //get all of the connected devices

    if (device.getNumberOfSliders()==4 && device.getNumberOfButtons()==19) { //make sure it's the right controller-- this gives conditional to decide if connection's true/false
      deviceConnected = true;

      device.setTolerance(0.05f);

      // declare control sliders and sticks
      ControllSlider sliderX = device.getSlider("x");
      ControllSlider sliderY = device.getSlider("y");
      ControllSlider sliderRZ = device.getSlider("rz");
      ControllSlider sliderZ = device.getSlider("z");

      stickL = new ControllStick(sliderX, sliderY);
      stickR = new ControllStick(sliderRZ, sliderZ);

      //--------------BUTTON NUMBER VALUES CHANGE DEPENDING ON CONTROLLER---------------

      //letter buttons to control individual motors
      X = device.getButton(15);
      A = device.getButton(14);
      B = device.getButton(13);
      Y = device.getButton(12);

      //bumpers and triggers
      LB = device.getButton(10);
      RB = device.getButton(11);
      LT = device.getButton(8);
      RT = device.getButton(9);

      backButton = device.getButton(0);
      startButton = device.getButton(3);

      coolieUp = device.getButton(4);
      coolieDown = device.getButton(6);
      coolieLeft = device.getButton(7);
      coolieRight = device.getButton(5);

      //-------------- functions to be called on controller events ---------------
      device.plug(this, "LBPress", ControllIO.ON_PRESS, 10);
      device.plug(this, "LBHold", ControllIO.WHILE_PRESS, 10);
      device.plug(this, "LBRelease", ControllIO.ON_RELEASE, 10);
      device.plug(this, "RBPress", ControllIO.ON_PRESS, 11);
      device.plug(this, "RBRelease", ControllIO.ON_RELEASE, 11);
      device.plug(this, "LTPress", ControllIO.ON_PRESS, 8);
      device.plug(this, "LTHold", ControllIO.WHILE_PRESS, 8);
      device.plug(this, "LTRelease", ControllIO.ON_RELEASE, 8);
      device.plug(this, "RTPress", ControllIO.ON_PRESS, 9);
      device.plug(this, "RTRelease", ControllIO.ON_RELEASE, 9);
      device.plug(this, "startPress", ControllIO.ON_RELEASE, 3);
      device.plug(this, "selectPress", ControllIO.ON_RELEASE, 0);
      device.plug(this, "xHold", ControllIO.WHILE_PRESS, 15);
      device.plug(this, "xRelease", ControllIO.ON_RELEASE, 15);
      device.plug(this, "yHold", ControllIO.WHILE_PRESS, 12);
      device.plug(this, "yRelease", ControllIO.ON_RELEASE, 12);
      device.plug(this, "aHold", ControllIO.WHILE_PRESS, 14);
      device.plug(this, "aRelease", ControllIO.ON_RELEASE, 14);
      device.plug(this, "bHold", ControllIO.WHILE_PRESS, 13);
      device.plug(this, "bRelease", ControllIO.ON_RELEASE, 13);
      device.plug(this, "coolieUpPress", ControllIO.WHILE_PRESS, 4);
      device.plug(this, "coolieDownPress", ControllIO.WHILE_PRESS, 6);
      device.plug(this, "coolieLeftPress", ControllIO.WHILE_PRESS, 7);
      device.plug(this, "coolieRightPress", ControllIO.WHILE_PRESS, 5);
    } else {
      deviceConnected = false; //if device is false, program is closed after displaying warning screen
    }
  }
}

//--------------------------------------    MOVE LOAD POINT WITH CONTROLLER    --------------------------------------

void moveTarget() {

  //if all 4 motor speeds aren't the same (because easing is operating), and stick is pressed, set all motor speeds & acceleration to the same
  //this mainly concerns 'Destination Easing' mode 
  if (speed[0] != speed[1] || speed[0] != speed[2] || speed[0] != speed[3]) { 
    if (stickR.getX() !=stickRX || stickR.getY() != stickRY || stickL.getY() != stickLY) {
      for (int i=0; i<4; i++) {
        speed[i] = motorSpeed;
        acceleration[i] = motorAcceleration;
      }
    }
  }

  //get stick values
  stickRX = stickR.getX();
  stickRY = stickR.getY();
  stickLY = stickL.getY();

  float pressVal = map(motorSpeed, 0, 15000, 0, 2.5); //sensitivity of stick -- range of speed

  //Deadzone calibration
  stickRX = map(constrain(abs(stickRX), deadZ, 1), deadZ, 1, 0, pressVal)*stickRX;
  stickRY = map(constrain(abs(stickRY), deadZ, 1), deadZ, 1, 0, pressVal)*stickRY;
  stickLY = map(constrain(abs(stickLY), deadZ, 1), deadZ, 1, 0, pressVal)*stickLY;

  //prevent load point from being moved with controller if ani library is already moving it
  if (playing == false) {
    load.x -= stickRX;
    load.y += stickRY;
    load.z -= stickLY;
  }
}

