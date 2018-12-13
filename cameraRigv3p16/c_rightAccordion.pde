/*
All accordion menus that appear on the RIGHT side of the screen
 --- Button to close program
 --- Button to save current camera position so it'll re-open there the next time the program is launched
 --- Area to display important values
 -------- tower rope values
 -------- current position of camera within space
 -------- percentage of progress of camera across width/length/height
 -------- ability to toggle between moveable flag points
 --- View 3D visualization of space from different angle
 --- Indicators to show if individual motor is being controlled/active
 --- Console
 --- Button to clear console 
 */

Accordion accordionTwo;
Println console;  //Send console to on-screen console

RadioButton r1; //radio button for different view options
RadioButton r2; //radio button to control individual motors
RadioButton rSpeed; // select fast / medium speed for individual motor control
RadioButton flag;

Textarea valuesText; // tower values text
Textarea serialText; // serial message when scrollable list is hidden
Textarea otherValuesText; //current xyz
Textarea flagHeader;

//serial stuff
Serial myPort;
String portName;
int serialDeviceNumber;

Slider[] slider = new Slider[3]; //width, length and height progress sliders
ScrollableList serialMenu;
boolean setFirst = false;//to test to see if a serialPort has been selected
boolean connected = false; //test to see if a serial port is connected
boolean[] view = { //lengthView, widthView, topView, cornerView
  false, false, false, false
}; 

int accWid = 270; //standard width of accordion
int indiSpeed = 40; //individual motor speed

float[] prog = { //array to hold values for progress sliders
  0, 0, 0
};


void rightAccordionGroup() {
  //--------------------------------------   buttons at top right  --------------------------------------

  // create a 'close' button
  cp5.addButton("X")
    .setOff()
      //.setPosition(width- accWid/2 -17, 50)
      .setPosition(width- accWid - 20, 50)
        .setSize(accWid, 20)
          .setLabel("Close")
            .setColorBackground(buttonTwo)
              .setColorForeground(buttonTwoActive)
                ;         

  //--------------------------------------   status group  --------------------------------------

  Group status = cp5.addGroup("Current Status")
    .setPosition(width-260, 20)
      .setWidth(accWid)
        .setBarHeight(barHeight)
          .setColorBackground(barColor)
            .setBackgroundColor(backgroundColor)
              .setColorForeground(barColorActive)
                .setBackgroundHeight(150)
                  ;

  status.getCaptionLabel().setFont(headingFont).toUpperCase(false).align(cp5.CENTER, cp5.CENTER);

  // reads in values text from tab one drawTEXT() function
  valuesText = cp5.addTextarea("txt2") //tower rope values
    .setPosition(150, 10)
      .setSize(accWid/2, 60)
        .setColor(textColor)
          .setLineHeight(12)
            .moveTo(status)
              .hideScrollbar()
                ;

  otherValuesText = cp5.addTextarea("txt4") //current xyz position
    .setPosition(150, 65)
      .setSize(accWid/2, 40)
        .setColor(textColor)
          .setLineHeight(12)
            .moveTo(status)
              .hideScrollbar()
                ;

  //--------------------------------------   sliders  --------------------------------------

  //Bar Chart showing where cam is within space-- width, length, height

  for ( int i=0; i<3; i++) {
    slider[i] = cp5.addSlider("slider" + (i+1)) //add 3 sliders for each dimension 
      .setPosition(10, 10+(i*25))
        .setSize(120, 20)
          .setRange(0, 100)  
            .setColorForeground(sliderTop)                 
              .setColorBackground(itemColor) 
                .setLock(true) //prevents the sliders from behing changed on click
                  .moveTo(status);

    cp5.getController("slider" + (i+1)).getCaptionLabel().toUpperCase(false).setColor(textColor);
    cp5.getController("slider" + (i+1)).getCaptionLabel().align(cp5.CENTER, cp5.CENTER);
    cp5.getController("slider" + (i+1)).getValueLabel().hide();
  }

  cp5.getController("slider" + 1).setCaptionLabel("Width Progress");
  cp5.getController("slider" + 2).setCaptionLabel("Length Progress");
  cp5.getController("slider" + 3).setCaptionLabel("Height Progress");

  //--------------------------------------   flag colour indicator  --------------------------------------

  flagHeader = cp5.addTextarea("txt6") //tower rope values
    .setPosition(20, 95)
      .setSize(accWid/2, 20)
        .setColor(textColor)
          .setLineHeight(12)
            .moveTo(status)
              .hideScrollbar()
                ;

  flagHeader.setText("Select Flag Point:"); //text to appear above flag point radio buttons

  flag = cp5.addRadioButton("flag")
    .setPosition(10, 115)
      .setSize(55, 20)
        .setItemsPerRow(2)
          .setSpacingColumn(10)
            .addItem("f1", 1)
              .addItem("f2", 2)
                .setColorLabel(entireBackground)
                  .moveTo(status);

  //format flag radio buttons
  flag.getItem(0).setCaptionLabel("✓");
  flag.getItem(0).getCaptionLabel().toUpperCase(true).align(cp5.CENTER, cp5.CENTER);
  flag.getItem(0).setColorBackground(triangleColor).setColorActive(triangleColor).setColorForeground(triangleColor);

  flag.getItem(1).setCaptionLabel("✓");
  flag.getItem(1).getCaptionLabel().toUpperCase(true).align(cp5.CENTER, cp5.CENTER);
  flag.getItem(1).setColorBackground(radioColorActive).setColorActive(radioColorActive).setColorForeground(radioColorActive);

  flag(1); //activate radio box 1 by running function

  //press this button and the load point will move to the middle of the space
  cp5.addButton("middle")
    .setPosition(140, 115)
      .setSize(120, 20)
        .setCaptionLabel("Middle")
          .setColorBackground(buttonOne)
            .setColorForeground(buttonOneActive)
              .moveTo(status);

  //--------------------------------------   view options  --------------------------------------


  Group viewGroup = cp5.addGroup("View Options")
    .setBackgroundColor(backgroundColor)
      .setColorBackground(barColor)
        .setColorForeground(barColorActive)
          .setSize(accWid, 50)
            .setBarHeight(barHeight)
              .setBackgroundHeight(100)
                ; 

  //adjust roomDimension lable
  viewGroup.getCaptionLabel().setFont(headingFont).toUpperCase(false).align(cp5.CENTER, cp5.CENTER);

  r1 = cp5.addRadioButton("viewAngle")
    .setPosition(10, 20)
      .setSize(120, 25)
        .setItemsPerRow(2)
          .setSpacingColumn(10)
            .setSpacingRow(10)
              .addItem("Corner", 1)
                .addItem("Length", 2)
                  .addItem("Width", 3)
                    .addItem("Top", 4)
                      .setColorBackground(itemColor)
                        .setColorActive(radioColorActive)
                          .setColorForeground(radioColor)
                            .setColorLabel(textColor)
                              .moveTo(viewGroup);


  for (int i=0; i<4; i++) { //iterate through view buttons and place label ontop of button
    r1.getItem(i).getCaptionLabel().toUpperCase(false).align(cp5.CENTER, cp5.CENTER);
  }


  //--------------------------------------   target individual motor group  --------------------------------------

  //buttons to target individual motors   
  Group targetMotor = cp5.addGroup("Target Individual Motor")
    .setBackgroundColor(backgroundColor)
      .setColorForeground(barColorActive)
        .setColorBackground(barColor)
          .setPosition(20, 390)
            .setSize(accWid, 75)
              .setBarHeight(barHeight)
                ; 

  targetMotor.getCaptionLabel().setFont(headingFont).toUpperCase(false).align(cp5.CENTER, cp5.CENTER);

  r2 = cp5.addRadioButton("targetMotor")
    .setPosition(10, 15)
      .setSize(55, 20)
        .setItemsPerRow(4)
          .setSpacingColumn(10)
            .addItem("Motor 1", 1)
              .addItem("Motor 2", 2)
                .addItem("Motor 3", 3)
                  .addItem("Motor 4", 4)
                    .setColorBackground(itemColor)
                      .setColorLabel(textColor)
                        .setColorActive(radioColorActive)
                          .setColorForeground(sliderTop)
                            .moveTo(targetMotor);

  rSpeed = cp5.addRadioButton("mediumOrFastMode")
    .setPosition(10, 45)
      .setSize(120, 20)
        .setItemsPerRow(2)
          .setSpacingColumn(10)
            .addItem("Medium Speed", 1)
              .addItem("Fast Speed", 2)
                .setColorBackground(itemColor)
                  .setColorLabel(textColor)
                    .setColorActive(radioColorActive)
                      .setColorForeground(radioColor)
                        .setNoneSelectedAllowed(false)
                          .moveTo(targetMotor);

  for (int i=0; i<4; i++) { //iterate through motor boxes and place label ontop of box
    r2.getItem(i).getCaptionLabel().toUpperCase(false).align(cp5.CENTER, cp5.CENTER);
  }

  //set individual motor speed text so that it's ontop of radio button
  for (int i=0; i<2; i++) { //iterate through motor boxes and place label ontop of box
    rSpeed.getItem(i).getCaptionLabel().toUpperCase(false).align(cp5.CENTER, cp5.CENTER);
  }

  rSpeed.activate(0); //start with medium speed selected 

  //--------------------------------------   console  --------------------------------------

  //console background area
  Group consoleArea = cp5.addGroup("Console")
    .setBackgroundColor(backgroundColor)
      .setColorForeground(barColorActive)
        .setColorBackground(barColor)
          .setBackgroundHeight(190)
            .setBarHeight(barHeight);

  consoleArea.getCaptionLabel().setFont(headingFont).toUpperCase(false).align(cp5.CENTER, cp5.CENTER);

  //Console
  Textarea consoleText = cp5.addTextarea("txt")
    .setPosition(10, 10)
      .setSize(accWid-10, 160)
        .setColor(textColor)
          .moveTo(consoleArea)
            ;        

  console = cp5.addConsole(consoleText);

  //ADD A CLEAR CONSOLE BUTTON
  cp5.addButton("clearConsole", 0, 0, 175, accWid, 20)
    .setCaptionLabel("Clear Console")
      .setColorBackground(buttonTwo)
        .setColorForeground(buttonTwoActive) 
          .moveTo(consoleArea)
            ;

  //--------------------------------------   put right accordion groups together  --------------------------------------

  //Create control accordion, add each section to list -- right side
  accordionTwo = cp5.addAccordion("accT")
    .setMinItemHeight(50)
      .setPosition(width- accWid - 20, 75)
        .setWidth(accWid)
          .addItem(status)
            .addItem(viewGroup)
              .addItem(targetMotor)
                .addItem(consoleArea)
                  ;

  accordionTwo.open();  //Which accordion groups are open on load 
  accordionTwo.setCollapseMode(Accordion.MULTI);  //Collapse mode, MULTI or SINGLE
}

//--------------------------------------   FUNCTIONS TO BE CALLED WHEN ACCORDION EVENTS OCCUR  --------------------------------------

//when clear console button is pressed, clear console text
void clearConsole(float v) { 
  console.clear();
}

public void X(int theValue) {
  println("Exiting Program");
  exit();
}
//--------------------------------------    DRAW TEXT TO RIGHT ACCORDION    --------------------------------------

void drawTEXT() {
  // sends values to text accordion group -- these values are updated
  valuesText.setText("Tower 1 Rope: " + int(dT[0]) + "\nTower 2 Rope: " + int(dT[1]) + "\nTower 3 Rope: " + int(dT[2]) + "\nTower 4 Rope: " + int(dT[3]));
  otherValuesText.setText("Current X:   " +  round((load.x)*in) + "\nCurrent Y:   " + round((load.y)*in) + "\nCurrent Z:   " + round((load.z)*in));

  serialText.setText("connected to: " + portName    + "\n\nTower values must equal 0 before port can be changed"); //text to appear when serial selection is disabled
}

//--------------------------------------   UPDATE SLIDERS SHOWING % PROGRESS ACROSS WIDTH, LENGTH AND HEIGHT  --------------------------------------

void updateSlider() {
  // map load point value to progress bar
  prog[0] = round(map(load.x, 0+minWidSafe, roomWidth-maxWidSafe, 0, 100)); //width progress
  prog[1] = round(map(load.y, 0+minLenSafe, roomLength-maxLenSafe, 0, 100)); //length progress
  prog[2] = round(map(load.z, 0+cameraSafeZone, hitTop, 0, 100));//height progress

  for ( int i=0; i<3; i++) {
    cp5.getController("slider" + (i+1)).setValue(prog[i]); //assign value to each progress slider
  }

  /*  cp5.getController("loadX").setValue(load.x);
   cp5.getController("loadY").setValue(load.y);
   cp5.getController("loadZ").setValue(load.z);*/
}

void viewAngle(int a) { 
  //if viewAngle radio button is pressed, change rotation so box can be viewed from selected angle
  // view are made true/false so that load point can be dragged to new location depending on angle
  for (int i=0; i<4; i++) {
    //if radio view button isn't selected or is set to corner mode -- width, length and top views are false
    if (a<=1 ) {
      view[i] = false;
    }
    if (a == i+1) {
      view[i] = true; //set view to true if it matches which button is selected
    } else {
      if ( a != i+1) {
        view[i] = false; //this makes sure only one view is true at any given time
      }
    }
  }

  if (a == 1) { // corner view
    rotx = -0.9;
    roty = 0.5;
  }
  if (a == 2) { //length view
    rotx = 0.09739848;
    roty = 1.5733969;
    println("Able to drag load point");
  }
  if (a == 3) { //width view
    rotx = 0.09739848;
    roty = 0.0013984288;
    println("Able to drag load point");
  }

  if (a == 4) { //birds eye view
    rotx = -1.6146007;
    roty = -0.014660139;
    println("Able to drag load point");
  }
}

void flag (int a) {
  if ( a ==1) { //if flag radio box 1 is selected, show an x and set move target to true --> effects which flag point can be moved. 
    flag.getItem(0).getCaptionLabel().show();
    flag.getItem(1).getCaptionLabel().hide();
    moveTarget = true;
  } else if (a==2) {
    flag.getItem(0).getCaptionLabel().hide();
    flag.getItem(1).getCaptionLabel().show();
    moveTarget = false;
  }
}

//Medium or Fast speed when spooling from individual motor
void mediumOrFastMode(int a) { 
  if (a == 1) {
    indiSpeed = 40; //run individual motors at medium speed
  } else {
    indiSpeed = 60; //run at fast speed
  }
}

