
//for reading in file names when loading saved dimensions
import java.io.*;
import java.io.File; 
import java.util.Date; 

///for video game controller
import procontroll.*;
import java.io.*;
import processing.serial.*;

//for accordion and gui objects
import controlP5.*; 
import java.util.*;

//for easing between 2 points
import de.looksgood.ani.*; 
import de.looksgood.ani.easing.*;
import processing.serial.Serial; // serial library

color textColor = color(77, 79, 92);
color backgroundColor = color(255, 255, 255, 200);
color itemColor = color(237, 239, 245);
color barColor = color(187, 192, 208);
color barColorActive = color(164, 168, 182);
color buttonColor = color(158, 165, 191);
color entireBackground = color(237, 239, 245);
color buttonOne = color(80, 194, 79); //green
color buttonOneActive = color(85, 207, 84); //green
color buttonTwo = color(80, 148, 227);//blue button
color buttonTwoActive = color(84, 156, 240);//blue button
color triangleColor = color( 244, 81, 119); //magenta 
color triangleColorActive = color( 255, 110, 144);
color radioColorActive = color(249, 197, 17);
color radioColor = color(223, 177, 15);
color fillCol =  color(10, 70, 150); //start with mid colour
color fillLT = barColor;
color fillLB = barColor;
color fillRT = barColor;
color fillRB = barColor;
color sliderTop = color(217, 219, 224); //progress slider forground colour
color lightPink = color(244, 81, 119, 20);
PFont pfont;
PFont headingFont;
PFont boundaryFont;

float roomWidth, roomLength, roomHeight; //room dimensions --> in cm
float loadWidth, loadLength;//initial length and width of room --> in inches
float widthIn, lengthIn, heightIn; // room dimensions --> in inches

int cameraHeight;//read-in value in inches 
int cameraSafeZone; // cameraHeight value converted to cm-- closest distance camera can come to hitting the floor

//original room dimensions on program launch, --> in cm
//used to calculate distances without throwing anything off 
//origHeight = largest original tower height
float origWidth, origLength, origHeight; 
float[] origT = new float[4]; //original height of each tower
float t1z, t2z, t3z, t4z; //individual tower heights --> in cm
float[] tIn = new float [4]; //initial tower heights

float minOne, minTwo; // minimum tower values from set --> used in checkBounds()
float towerDistOne, towerDistTwo; // distance between tower sets --> used in checkBounds()



//values to keep load point within ceiling constraints
float hitTop; //top value for load point
float hitTopOne, hitTopTwo;  //top value for flag one and flag two

PImage[] images = new PImage[7]; //icon images for easing curves

//declare vectors for components in 3D space
PVector t1, t2, t3, t4, load, flagOne, flagTwo;

float[] dT = new float[4];

float idT1, idT2, idT3, idT4;  //Startup distances

locationDisplay map = new locationDisplay(305, 50, 640, 640); //background area behind 3D rectangle

towerClass tower1 = new towerClass(1, 0, 0, roomHeight);  //tempid, temp x relative, temp y relative, temp z relative
towerClass tower2 = new towerClass(2, roomWidth, 0, roomHeight);
towerClass tower3 = new towerClass(3, roomWidth, roomLength, roomHeight);
towerClass tower4 = new towerClass(4, 0, roomLength, roomHeight);

float in = 0.393701; //conversion from cm to inches
float cm = 2.54; //conversion from inches to cm

int endMillis; //value in milliseconds once setup finishes running

//--------------------------------------    SETUP    --------------------------------------

void setup() {
  size(1250, 750, P3D);

  frameRate(30);
  pfont = createFont("Helvetica-11.vlw", 11);
  headingFont = createFont("HelveticaNeue-Bold-12.vlw", 12);
  boundaryFont = createFont("Helvetica-8.vlw", 8);
  textFont(pfont);
  imageMode(CORNER);

  //load easing icon images
  for ( int i = 0; i< images.length; i++ ) {
    images[i] = loadImage("ease" + i + ".png");
  }

  Ani.init(this); 
  Ani.noAutostart();
  cp5 = new ControlP5(this); 
  cp5.setFont(pfont); 

  roomDimensionAccordion();
  rightAccordionGroup();
  calibrationAccordion();
  hiddenGroups(); //save & load menus
  serialOptionsAccordion();
  movementAccordion(); //set easing and movement speed 
  displayLeftAccordion(); 
  helpTab(); //screen that pops up when 'h' is pressed 

  maxHeight(); //calculates room height based on height of tallest tower (left accordion tab)
  getController(); //connect to controller and assign buttons, sticks and sliders

  //Set start to middle of space on floor
  load = new PVector(roomWidth/2, roomLength/2, cameraSafeZone); //read in from JSON file -- reads in cm
  flagOne = new PVector(2*(roomWidth/3), roomLength/2, cameraSafeZone); //flag point #1
  flagTwo = new PVector(roomWidth/3, roomLength/2, cameraSafeZone); //flag point #2

  getDistances(); //distances between individual towers and load point

  //set id to starting distance between tower & load point -- this value doesn't change
  idT1 = dT[0];  
  idT2 = dT[1];
  idT3 = dT[2];
  idT4 = dT[3];

  endMillis = millis(); // used to prevent motors from spooling during setup
  console.clear(); //start with an empty console

  for (int i=0; i<4; i++) {
    speed[i] = motorSpeed;
    acceleration[i] = motorAcceleration;
  }

  if (deviceConnected == false) {
    closeProgram();
    noLoop();
  }
}

//-------------------------------------------------    DRAW    ------------------------------------------------

void draw() {
  if (deviceConnected == true) {
    background(entireBackground);
    moveTarget(); //updates load point position when sticks are pushed
    checkBounds(); //keeps load point within room boundaries 
    if (millis()>=endMillis+1000) {// makes sure this doesn't calculate anything while values are being setup
      dontSpool();
    }
    updateSlider(); //updates width,length & height bars showing progress % across space
    getDistances(); //calculates dist between towers and load point
    sendValues(); //send values to arduino
    drawTEXT();//text for right accordion group
    testPlaying(); //test if ani is playing
    testMotors(); //test to see if letter is held down, if not de-activate individual motors
    disableChange(); //don't allow serial port to switch unless tower rope values all == 0
    map.update();//update 3D visualization
    helpLines(); //lines to appear when help tab is open
  }
}


//--------------------------------------    IF CONTROLLER ISN'T CONNECTED    --------------------------------------

void closeProgram() {

  Group hideBackground = cp5.addGroup("hideBackground")
    .setPosition(0, 0)
      .setWidth(width)
        .setBackgroundColor(color(251, 252, 253))
          .setBackgroundHeight(height)
            .hideBar()
              ;

  Textarea warningMessage = cp5.addTextarea("warningMessage") 
    .setPosition(width/2-80, height/2)
      .setSize(400, 160)
        .setColor(textColor)
          .setText("PS3 controller not detected,")
            .setLineHeight(lineHeight)
              .hideScrollbar()
                ;

  Textarea warningMessageTwo = cp5.addTextarea("warningMessageTwo") 
    .setPosition(width/2-120, height/2+20)
      .setSize(400, 160)
        .setColor(textColor)
          .setText("close program and check bluetooth connection")
            .setLineHeight(lineHeight)
              .hideScrollbar()
                ;
}

//--------------------------------------    CALC DISTANCES BETWEEN TOWERS AND LOAD    --------------------------------------

void getDistances() {

  //load point coordinates with event offsets applied
  float newLoadX = (load.x-offX)-dragX - midOffx; 
  float newLoadY = (load.y-offY)-dragY - midOffy;
  float newLoadZ = (load.z-offZ)-dragZ + midOffz;

  dT[0] = dist(newLoadX, newLoadY, newLoadZ, 0, 0, origHeight);  
  dT[1] = dist(newLoadX, newLoadY, newLoadZ, origWidth, 0, origHeight);
  dT[2] = dist(newLoadX, newLoadY, newLoadZ, origWidth, origLength, origHeight);
  dT[3] = dist(newLoadX, newLoadY, newLoadZ, 0, origLength, origHeight);
}

//--------------------------------------    SEND DISTANCES TO ARDUINO    --------------------------------------

void sendValues() {  
  //Distance calculations take place here, converting distance to steps
  float stepspercm = 170;

  dT[0] -= idT1;
  dT[1] -= idT2;
  dT[2] -= idT3;
  dT[3] -= idT4;

  int[] stepsT = new int[4]; //distance from towers to floatOne
  int[] motorSpeedT = new int[4]; //speed for each motor
  int[] motorAccelerationT = new int[4];  //acceleration for each motor

  for ( int i=0; i<4; i++) {
    stepsT[i] = int((dT[i]*stepspercm) + coolie[i]);
    motorSpeedT[i] = speed[i];
    motorAccelerationT[i] = acceleration[i];
  }

  if (connected == true) { //if connected to a port - send values
    myPort.write(stepsT[0] + "," + stepsT[1] + "," + stepsT[3] + "," + stepsT[2] + "," + motorSpeedT[0] + ","  + motorSpeedT[1] + ","  + motorSpeedT[2] + ","  + motorSpeedT[3] + "," + motorAccelerationT[0] + "," + motorAccelerationT[1] + "," + motorAccelerationT[2] + "," + motorAccelerationT[3] + "," + "1,0" + "\n");
  }

  delay(2); //delay to communicate with arduino & so frame rate seems consistent
}

