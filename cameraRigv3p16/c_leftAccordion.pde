/*
All accordion menus that appear on the LEFT side of the screen
 --- Set and save room dimensions
 --- Calibration
 --- Select serial port to connect to 
 --- Control speed of movement, acceleration and easing styles between flag points 
 */

ControlP5 cp5;

Accordion accordion;  //Accordion to hold left accordion groups 

Group calibrationGroup; //group to hold buttons to toggle measure mode on/off
Group dimenGroup; //Group that holds room dimension numberboxes
Group movementGroup; //Group that controls movement of camera
Group serialChoices;

RadioButton calibrationButton;
Button smw, smxw, sml, smxl, smxh; // calibration buttons - max/min width/len/height
Button resetCalibration;

RadioButton sameHeight;
Textarea sameHeights;
Textarea blockHeight;
boolean singleHeight = false;


//room dimension number boxes
Numberbox widthNB, lengthNB, camSafe; 
Numberbox[] heightTower = new Numberbox[4]; 
Numberbox motorSpeedNB, motorAccelerationNB; 

RadioButton easingMode; //select easing mode
ScrollableList scroll;
Icon icon; //to display easing styles

boolean changing = false; //boolean to see if room dimensions are being changed

int motorSpeed = 5000;
int motorAcceleration = 2000;
int index = 0; //used to select easing style -- set to 0 to start with linear movement
int barHeight = 22; //height of accordion group bar
float spoolX, spoolY, spoolZ; //spool values previous to room size being adjusted
float offX, offY, offZ; //offset for spool values if room size is reduced

//Safety bumper around walls
float topSafe; //bumper value for ceiling
float minWidSafe, maxWidSafe, minLenSafe, maxLenSafe; //bumper value around walls

//--------------------------------------    ROOM DIMENSION ACCORDION    --------------------------------------
//Room Dimension Group to hold all the numberboxes and buttons
void roomDimensionAccordion() {   
  dimenGroup = cp5.addGroup("Room Dimensions (inches)")
    .setBackgroundColor(backgroundColor)
      .setColorBackground(barColor)        
        .setColorForeground(barColorActive)
          .setSize(accWid, 140)
            .setBarHeight(barHeight)
              ; 

  //SAVE button to save current set of room dimensions
  cp5.addButton("b1", 0, 140, 10, 55, 20)
    .setCaptionLabel("save")
      .setColorBackground(buttonOne)
        .setColorForeground(buttonOneActive)
          .moveTo(dimenGroup)
            ;

  //LOAD button to load previously saved room dimensions
  cp5.addButton("load", 0, 205, 10, 55, 20)
    .setCaptionLabel("load")
      .setColorBackground(buttonTwo)
        .setColorForeground(buttonTwoActive)
          .moveTo(dimenGroup)
            ;

  //text to accompany single height button
  sameHeights = cp5.addTextarea("sameHeights")
    .setPosition(10, 10)
      .setSize(100, 20)
        .setColor(textColor)
          .setLineHeight(12)
            .setText("single height?")
              .moveTo(dimenGroup)
                .hideScrollbar()
                  ;

  sameHeight = cp5.addRadioButton("sameHeight")
    .setPosition(100, 10)
      .setSize(30, 20)
        .setItemsPerRow(1)
          .setSpacingColumn(110)
            .addItem("✓", 0)
              .setColorBackground(itemColor)
                .setColorLabel(textColor)
                  .setColorActive(radioColorActive)
                    .setColorForeground(radioColor)
                      .deactivate(0)
                        .moveTo(dimenGroup);

  sameHeight.getItem(0).getCaptionLabel().toUpperCase(false).align(cp5.CENTER, cp5.CENTER);
  sameHeight.getItem(0).getCaptionLabel().hide();


  //Tower Height Numberboxes
  for (int i=0; i<4; i++) { 
    heightTower[i] = cp5.addNumberbox("heightTower" + (i+1))
      .setLabel("Height " + (i+1))
        .setPosition(10 +(i*65), 40)
          .setSize(55, 20)
            .setDecimalPrecision(0) 
              .setMultiplier(0) //prevent scroll functionality -- only really need to input precise values
                .setMin(30)  
                  .setColorBackground(itemColor)
                    .setColorValue(textColor)
                      .setColorActive(triangleColorActive) 
                        .setColorForeground(triangleColor)
                          .moveTo(dimenGroup);

    heightTower[i].getCaptionLabel().toUpperCase(false).align(cp5.CENTER, cp5.BOTTOM_OUTSIDE).setColor(textColor);
    makeEditable(heightTower[i]);
  }

  blockHeight = cp5.addTextarea("blockHeight")
    .setPosition(70, 40)
      .setSize(190, 20)
        .setColor(textColor)
          .setLineHeight(12)
            .setText("") //leave blank 
              .moveTo(dimenGroup)
                .hideScrollbar()
                  .hide()
                    ;

  widthNB = cp5.addNumberbox("roomWidth")
    .setLabel("Width")
      .setPosition(10, 90)
        .setSize(55, 20)
          .setDecimalPrecision(0)
            .setMultiplier(0) //prevent scroll functionality
              .setMin(30)  
                .setColorBackground(itemColor)
                  .setColorValue(textColor)
                    .setColorActive(triangleColorActive) 
                      .setColorForeground(triangleColor)
                        .moveTo(dimenGroup)
                          ;

  lengthNB =cp5.addNumberbox("roomLength")
    .setLabel("Length")
      .setPosition(75, 90)
        .setSize(55, 20)
          .setDecimalPrecision(0)
            .setMultiplier(0) //prevent scroll functionality
              .setMin(30)  
                .setColorBackground(itemColor)     
                  .setColorActive(triangleColorActive) 
                    .setColorForeground(triangleColor)
                      .setColorValue(textColor)
                        .moveTo(dimenGroup)
                          ;

  camSafe =cp5.addNumberbox("cHeight")
    .setLabel("Cam Height")
      .setPosition(140, 90)
        .setSize(55, 20)
          .setDecimalPrecision(0)
            .setMultiplier(0) //prevent scroll functionality
              .setMin(0)  
                .setColorBackground(itemColor)     
                  .setColorActive(triangleColorActive) 
                    .setColorForeground(triangleColor)
                      .setColorValue(textColor)
                        .moveTo(dimenGroup)
                          ;

  dimenGroup.getCaptionLabel().setFont(headingFont).toUpperCase(false).align(cp5.CENTER, cp5.CENTER); // room dimension group label
  widthNB.getCaptionLabel().toUpperCase(false).align(cp5.CENTER, cp5.BOTTOM_OUTSIDE).setColor(textColor); //roomWidth numberbox label
  lengthNB.getCaptionLabel().toUpperCase(false).align(cp5.CENTER, cp5.BOTTOM_OUTSIDE).setColor(textColor); //roomLength numberbox label
  camSafe.getCaptionLabel().toUpperCase(false).align(cp5.CENTER, cp5.BOTTOM_OUTSIDE).setColor(textColor); //camera height numberbox label

  // allow numberbox values to be changed with keyboard
  makeEditable( widthNB );
  makeEditable( lengthNB );
  makeEditable( camSafe );




  cp5.loadProperties("setDimen.json"); //set numberbox values to previously saved room dimensions
  assignDimensionProperties(); //assign roomWidth, length, tower heights a value based on starting properties
}

//--------------------------------------    CALIBRATE SPACE ACCORDION    --------------------------------------
void calibrationAccordion() {

  //calibration group
  calibrationGroup = cp5.addGroup("Calibrate")
    .setBackgroundColor(backgroundColor)
      .setColorBackground(barColor)        
        .setColorForeground(barColorActive)
          .setSize(accWid, 120)
            .setBarHeight(barHeight)
              ;

  calibrationButton = cp5.addRadioButton("calibrationButtons")
    .setPosition(10, 15)
      .setSize(120, 25)
        .setItemsPerRow(2)
          .setSpacingColumn(10)
            .setSpacingRow(10)
              .addItem("Set Minimum Width", 0)
                .addItem("Set Maximum Width", 1)
                  .addItem("Set Minimum Length", 2)
                    .addItem("Set Maximum Length", 3)
                      // .addItem("Set Maximum Height", 4)                   
                      .addItem("Reset Calibrations", 4)
                        .setColorBackground(itemColor)
                          .setColorLabel(textColor)
                            .setColorActive(radioColorActive)
                              .setColorForeground(sliderTop)
                                .setNoneSelectedAllowed(false)
                                  .moveTo(calibrationGroup);

  calibrationGroup.getCaptionLabel().setFont(headingFont).toUpperCase(false).align(cp5.CENTER, cp5.CENTER);   //adjust heading lable
  calibrationButton.getItem(4).setColorBackground(buttonTwo).setColorForeground(buttonTwoActive).setColorLabel(255); //make reset button blue
  calibrationButton.getItem(4).setSize(250, 25);

  for (int i=0; i<5; i++) {
    calibrationButton.getItem(i).getCaptionLabel().toUpperCase(false).align(cp5.CENTER, cp5.CENTER);
  }

  //NUMBERBOXES TO SAVE TO "setCalibration" JSON file
  //not needed to be visible, but need to be in this format to read in & save to
  cp5.addNumberbox("minXSafe").hide(); 
  cp5.addNumberbox("maxXSafe").hide(); 
  cp5.addNumberbox("minYSafe").hide(); 
  cp5.addNumberbox("maxYSafe").hide(); 
  cp5.addNumberbox("maxZSafe").hide(); 

  cp5.getProperties().addSet("setCalibration"); //property set to hold calibration values

  //add hidden numberboxes to calibration properties
  cp5.getProperties().move(cp5.getController("minXSafe"), "default", "setCalibration");
  cp5.getProperties().move(cp5.getController("maxXSafe"), "default", "setCalibration");
  cp5.getProperties().move(cp5.getController("minYSafe"), "default", "setCalibration");
  cp5.getProperties().move(cp5.getController("maxYSafe"), "default", "setCalibration");
  cp5.getProperties().move(cp5.getController("maxZSafe"), "default", "setCalibration");


  cp5.loadProperties("setCalibration.json"); //load calibration settings
  assignCalibrationValues();//make sure topSafe, minWidSafe... all have assigned values
}

//--------------------------------------    SERIAL CONNCTION ACCORDION    --------------------------------------

//serial connection group
void serialOptionsAccordion() {
  serialChoices = cp5.addGroup("Select Serial Port")
    .setSize(accWid, 40)
      .setBarHeight(barHeight)
        .setColorBackground(barColor)
          .setBackgroundColor(backgroundColor)
            .setColorForeground(barColorActive)
              //.setBackgroundHeight(105)
              ;

  List s = Arrays.asList(Serial.list()); //get list of serial ports

  //list of all possible serial connections
  serialMenu =  cp5.addScrollableList("selectArduino")
    .setPosition(10, 10)
      .setSize(accWid-20, 80)
        .setBarHeight(20)
          .setItemHeight(20)
            .addItems(s)
              .setColorBackground(itemColor)
                .setColorValue(textColor)
                  .setColorLabel(textColor)
                    .setColorActive(radioColorActive)
                      .setColorForeground(radioColor)
                        .moveTo(serialChoices)
                          .setType(ScrollableList.LIST)
                            .setCaptionLabel("Select Connection")
                              ;

  //text to appear when serial port is unable to be changed (when load isn't at initial starting point)
  serialText =  cp5.addTextarea("txt3")
    .setPosition(10, 20)
      .setSize(accWid-20, 100)
        .setColor(textColor)
          .setLineHeight(12)
            .moveTo(serialChoices)
              .hideScrollbar()
                .hide()
                  ;

  serialChoices.getCaptionLabel().setFont(headingFont).toUpperCase(false).align(cp5.CENTER, cp5.CENTER);
  serialMenu.getCaptionLabel().toUpperCase(false).getStyle().marginTop=3;    //this adjusts 'select' label
  serialMenu.getValueLabel().toUpperCase(false).getStyle().marginTop=3; //this adjusts item label
}

//--------------------------------------    SPEED & EASING ACCORDION   --------------------------------------

void movementAccordion() {  
  // move controller 'numberbox' from the default set to 'setSpeed'
  // the 3 parameters read like this: move controller(1) from set(2) to set(3) 
  cp5.getProperties().move(cp5.getController("motorSpeed"), "default", "setSpeed");
  cp5.getProperties().move(cp5.getController("motorAcceleration"), "default", "setSpeed");

  //movement & easing group
  movementGroup = cp5.addGroup("Easing")
    .setLabel("Movement & Easing")
      .setBackgroundColor(backgroundColor)
        .setColorBackground(barColor)
          .setPosition(20, 390)
            .setSize(accWid, 190)       
              .setColorForeground(barColorActive)
                .setBarHeight(barHeight)
                  ;

  //button to select 'Ani' or 'Destination' easing mode
  easingMode = cp5.addRadioButton("mode")
    .setPosition(10, 5)
      .setSize(20, 20)
        .setItemsPerRow(2)
          .setSpacingColumn(110)
            .addItem("mode1", 1)
              .addItem("mode2", 2)
                .setColorBackground(itemColor)
                  .setColorLabel(textColor)
                    .setColorActive(radioColorActive)
                      .setColorForeground(radioColor)
                        .activate(0)
                          .setNoneSelectedAllowed(false)
                            .moveTo(movementGroup);

  //motorSpeed numberbox
  motorSpeedNB = cp5.addNumberbox("motorSpeed")
    .setLabel("speed")
      .setPosition(10, 30)
        .setSize(120, 20)
          .setRange(500, 12000)
            .setMultiplier(10) 
              .setScrollSensitivity(0.1)
                .setColorBackground(itemColor)
                  .setColorValue(textColor)
                    .setColorActive(triangleColorActive) 
                      .setColorForeground(triangleColor)
                        .setValue(motorSpeed)
                          .moveTo(movementGroup)
                            ;

  motorAccelerationNB= cp5.addNumberbox("motorAcceleration")
    .setLabel("acceleration")
      .setPosition(140, 30)
        .setSize(120, 20)
          .setRange(500, 12000)
            .setMultiplier(10) 
              .setScrollSensitivity(5)
                .setColorBackground(itemColor)
                  .setColorValue(textColor)
                    .setColorActive(triangleColorActive) 
                      .setColorForeground(triangleColor)
                        .setValue(motorAcceleration)
                          .moveTo(movementGroup)
                            ;



  List l = Arrays.asList("Linear", "Sine In", "Sine Out", "Sine In Out", "Cubic In", "Cubic Out", "Cubic In Out");

  //select easing curve from scrollable list
  scroll =  cp5.addScrollableList("Select")
    .setPosition(10, 75)
      .setSize(accWid-140, 110)
        .setBarHeight(20)
          .setItemHeight(20)
            .addItems(l)
              .setColorBackground(itemColor)
                .setColorValue(textColor)
                  .setColorLabel(textColor)
                    .setColorActive(radioColorActive)
                      .setColorForeground(radioColor)
                        .moveTo(movementGroup)
                          .setType(ScrollableList.LIST)//supports dropdown and list
                            .setCaptionLabel("Select Easing")
                              ;

  //grey square background to go behind image
  cp5.addIcon("background", 10) 
    .setPosition(150, 75)
      .setSize(110, 100)
        .showBackground()
          .setColorBackground(barColor)
            .moveTo(movementGroup)
              ;

  //icon to show easing curve
  icon = cp5.addIcon("icon", 10)
    .setPosition(163, 83)
      .setSize(80, 80)
        .setImage(images[index])
          .moveTo(movementGroup)                    
            ;

  movementGroup.getCaptionLabel().setFont(headingFont).toUpperCase(false).align(cp5.CENTER, cp5.CENTER);
  motorAccelerationNB.getCaptionLabel().setFont(headingFont).toUpperCase(false).setColor(textColor);
  motorSpeedNB.getCaptionLabel().setFont(headingFont).toUpperCase(false).setColor(textColor);
  easingMode.getItem(0).setCaptionLabel("Ani Easing");
  easingMode.getItem(1).setCaptionLabel("Destination");
  scroll.getCaptionLabel().toUpperCase(false).getStyle().marginTop=3; //this adjusts 'select' label
  scroll.getValueLabel().toUpperCase(false).getStyle().marginTop=3; //this adjusts item label

  makeEditable( motorSpeedNB );
  makeEditable(motorAccelerationNB);

  //format easing mode buttons
  for (int i=0; i<2; i++) {
    easingMode.getItem(i).getCaptionLabel().toUpperCase(true).align(cp5.RIGHT_OUTSIDE, cp5.CENTER);
    easingMode.getItem(i).getCaptionLabel().setFont(headingFont).toUpperCase(false);
  }
}

//--------------------------------------   PUT LEFT ACCORDION GROUPS TOGETHER  --------------------------------------

void displayLeftAccordion() { 
  accordion = cp5.addAccordion("acc")
    .setPosition(20, 50)
      .setWidth(accWid)
        .addItem(dimenGroup)
          .addItem(calibrationGroup)
            .addItem(serialChoices)
              .addItem(movementGroup)
                ;

  accordion.open();  //Which accordion groups are open on load
  accordion.setCollapseMode(Accordion.MULTI);  //Collapse mode, MULTI or SINGLE
}

//-----------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------   FUNCTIONS TO BE CALLED WHEN ACCORDION EVENTS OCCUR  --------------------------------------

void makeEditable( Numberbox n ) {  // allows the user to click a numberbox and type in a number which is confirmed with RETURN
  final NumberboxInput nin = new NumberboxInput( n ); // custom input handler for the numberbox
  n.onClick(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      nin.setActive( true );
    }
  }
  ).onLeave(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      nin.setActive( false ); 
      nin.submit();
    }
  }
  );
}

public class NumberboxInput {
  String text = "";
  Numberbox n;
  boolean active;
  NumberboxInput(Numberbox theNumberbox) {
    n = theNumberbox;
    registerMethod("keyEvent", this );
  }

  public void keyEvent(KeyEvent k) {
    // only process key event if input is active 
    if (k.getAction()==KeyEvent.PRESS && active) {
      if (k.getKey()=='\n') { // confirm input with enter
        submit();
        return;
      } else if (k.getKeyCode()==BACKSPACE) { 
        text = text.isEmpty() ? "":text.substring(0, text.length()-1);
        //text = ""; // clear all text with backspace
      } else if (k.getKey()<255) {
        // check if the input is a valid (decimal) number
        final String regex = "\\d+([.]\\d{0,2})?";
        String s = text + k.getKey();
        if ( java.util.regex.Pattern.matches(regex, s ) ) {
          text += k.getKey();
        }
      }
      n.getValueLabel().setText(this.text);
    }
  }

  public void setActive(boolean b) {
    active = b;
    if (active) {
      n.getValueLabel().setText("");
      text = "";
    }
  }

  public void submit() {
    if (!text.isEmpty()) {
      n.setValue( float( text ) );
      text = "";
    } else {
      n.getValueLabel().setText(""+n.getValue());
    }
  }
}

//-------------------------------------------------------------------------------------------------------------------

// adjusts view of box when radio button is selected -- corner, side / birds eye view
void controlEvent(ControlEvent theEvent) {

  //Individual tower heights from set dimensions accordion
  //'changing' boolean makes sure tower values don't spool when shrunken below load point value
  if (theEvent.isFrom(widthNB)) {
    roomWidth = (theEvent.getValue())*cm;
    changing = true;
  } else if (theEvent.isFrom(lengthNB)) {
    roomLength = (theEvent.getValue())*cm;
    changing = true;
  } else if (theEvent.isFrom(heightTower[0])) {
    if (singleHeight == true) { 
      //if single height is true, 
      //then change all tower values to be the same as tower 1
      for (int i=1; i<4; i++) {
        heightTower[i].setValue(heightTower[0].getValue());
      }
    }
    t1z = theEvent.getValue()*cm;
    maxHeight();
    changing = true;
  } else if (theEvent.isFrom(camSafe)) {
    cameraHeight = int(theEvent.getValue());
    cameraSafeZone = int(cameraHeight*cm); //convert camera Height to cm
    changing = true;
  } else if (theEvent.isFrom(heightTower[1])) {
    t2z = (theEvent.getValue())*cm;
    maxHeight();
    changing = true;
  } else if (theEvent.isFrom(heightTower[2])) {
    t3z = (theEvent.getValue())*cm;
    maxHeight();
    changing = true;
  } else if (theEvent.isFrom(heightTower[3])) {
    t4z =(theEvent.getValue())*cm;
    maxHeight();
    changing = true;
  } else {
    changing = false;
  }

  //----------------if the event is from individual motor control------------------
  // targets individual motors  -- sees if they're activated or not
  if (theEvent.isFrom(r2)) {
    // println(theEvent.getValue() + "MOTOR EVENT VALUE");
    for ( int i=0; i<4; i++) {
      if (theEvent.getValue() < 1) {
        eachMotor[i] = false;
      }
      if (theEvent.getValue() == i+1) {
        eachMotor[i] = true;
        // println("hold down corresponding letter button and use UP/DOWN arrows to control");
      }
    }
  }
}

void motorSpeed(int a) { 
  //get value from motorSpeed numberbox
  //assign speed to each motor
  for (int i=0; i<4; i++) {
    speed[i] =a;
  }
}

void motorAcceleration(int a) {
  //get value from motorAcceleration numberbox
  //assign acceleration to each motor
  for (int i=0; i<4; i++) {
    acceleration[i] = a;
    // println( a);
  }
}

void Select(int n) {
  //set index based on option selected from ScrollableList named "Select"
  index= n; //set index to n -- this corresponds to number of element within easing array
  icon.setImage(images[index]); //set icon image of easing wave beside easing options
}



//--------------------------------------   PREVENT MOTORS FROM SPOOLING DURING SETUP  --------------------------------------

void dontSpool() { 
  //creates offset value if room dimensions are shunk smaller than current load point position
  //offset values make sure towers don't spool unnecessarily
  if (changing == false) {//if room size isn't being changed....
    //save position from before change so difference can be calculated and offset. 
    spoolX = load.x;
    spoolY = load.y;
    spoolZ = load.z;
  }

  if (changing == true) { //if room size is being changed...
    //originally, when room is shrunken below current x,y or z position of load point, tower values begin to spool unnecessarily  
    //this sets an offset value so that nothing goes wrong
    if (load.x != spoolX || load.y != spoolY || load.z != spoolZ) { 

      //offset value -- difference between original load point & current load point -- offset on distance to tower (dT_) values in getDistances() function on cameraRig tab
      offX += load.x - spoolX; 
      offY += load.y - spoolY;
      offZ += load.z - spoolZ;

      spoolX = load.x; //reset so that offset value compiles each time rather than resetting to 0
      spoolY = load.y;
      spoolZ = load.z;
    }
  }
}


//--------------------------------------   SERIAL CONNECTION  --------------------------------------

void selectArduino(int a) {

  if (a < 0) {
    connected = false;
    println("disconnected from port");
    myPort.stop();  //stop last serial connection
  } else {

    if (setFirst == true) {
      myPort.stop();  //stop last serial connection
    }

    portName = Serial.list()[a]; //select serial device based on which radio button was selected
    myPort = new Serial(this, portName, 115200); // Open the port you are using at the rate you want
    myPort.clear();  //Clear first message incase it's garbage

    delay(5000); //needed so communication can commence with arduino
    println("Connected to serial port: " + portName);
    connected = true;
    setFirst = true;

    //reset coolie values for individual motor controls --> prevents motors from spooling when connecting to new seial port
    for (int i=0; i<4; i++) {
      coolie[i] = 0;
    }
  }
}

void disableChange() {
  if (int(dT[0])!=0 || int(dT[1])!=0 || int(dT[2])!=0 || int(dT[3])!=0) {
    serialMenu.hide(); //prevents serial port from behing changed
    serialText.show(); //show message
  } else {
    serialMenu.show();
    serialText.hide();
  }
}

//--------------------------------------   CALIBRATIONS  --------------------------------------

void calibrationButtons (int a) {

  if (a == 0) {  //minimum width
    minWidSafe = load.x;
    cp5.getController("minXSafe").setValue(minWidSafe);
    calibrationButton.deactivate("Set Minimum Width");
    println( "saved minimum width");
  } 

  if (a == 1) {  //maximum width
    maxWidSafe = (roomWidth - load.x);
    cp5.getController("maxXSafe").setValue(maxWidSafe);
    calibrationButton.deactivate("Set Maximum Width");
    println( "saved maximum width");
  }  

  if (a == 2) {  //minimum length
    minLenSafe = load.y;
    cp5.getController("minYSafe").setValue(minLenSafe);
    calibrationButton.deactivate("Set Minimum Length");
    println( "saved minimum length");
  } 

  if (a == 3) {  //maximum length
    maxLenSafe = (roomLength - load.y);
    cp5.getController("maxYSafe").setValue(maxLenSafe);
    calibrationButton.deactivate("Set Maximum Length");
    println( "saved maximum length");
  } 

  if (a == 4) {  //maximum height

    cp5.getController("maxZSafe").setValue(2);
    cp5.getController("minXSafe").setValue(5);
    cp5.getController("maxXSafe").setValue(5);
    cp5.getController("minYSafe").setValue(5);
    cp5.getController("maxYSafe").setValue(5);
    minLenSafe =5;
    maxLenSafe =5;
    minWidSafe = 5;
    maxWidSafe = 5;
    topSafe = 2;
    calibrationButton.deactivate("Reset Calibrations");    
    println("reset calibration");
    /* topSafe = (roomHeight - load.z); //topSafe is in cm
     cp5.getController("maxZSafe").setValue(topSafe);
     calibrationButton.deactivate("Set Maximum Height");
     println( "saved maximum height");*/
  }

  /*if (a == 5) { //reset button
   cp5.getController("maxZSafe").setValue(2);
   cp5.getController("minXSafe").setValue(5);
   cp5.getController("maxXSafe").setValue(5);
   cp5.getController("minYSafe").setValue(5);
   cp5.getController("maxYSafe").setValue(5);
   minLenSafe =5;
   maxLenSafe =5;
   minWidSafe = 5;
   maxWidSafe = 5;
   topSafe = 2;
   calibrationButton.deactivate("Reset Calibrations");    
   println("reset calibration");
   }*/

  // println(topSafe + "= topSafe  " +minWidSafe+ " = minWidSafe " +maxWidSafe + " = maxWidSafe" + minLenSafe + " =min Len" + maxLenSafe+ " =maxLen");
  cp5.saveProperties("setCalibration", "setCalibration");
}



//--------------------------------------   ASSIGN STARTING VALUES FROM NUMBERBOX  --------------------------------------

//---------------------- assign room dimension values -------------------------

void assignDimensionProperties() {
  //assign starting values to dimension variables (starts in INCHES)
  cameraHeight = int(cp5.getController("cHeight").getValue());
  loadWidth = cp5.getController("roomWidth").getValue();
  loadLength = cp5.getController("roomLength").getValue();

  for (int i=0; i<4; i++) {
    tIn[i] = cp5.getController("heightTower" + (i+1)).getValue(); //get tower heights
  }

  //calculate which tower is the talest based on individual entries from numberboxes
  float[] highestHigh = {
    tIn[0], tIn[1], tIn[2], tIn[3]
  };

  //convert dimension variables to CM
  roomWidth = loadWidth*cm;
  roomLength = loadLength*cm;
  roomHeight = max(highestHigh)*cm; //set room height to height of tallest tower
  cameraSafeZone = int(cameraHeight*cm); //safe zone to floor in cm

    //define dimensions in inches based on load values
  widthIn = loadWidth;
  lengthIn = loadLength;
  heightIn = max(highestHigh);

  //these are for the getDistances function so that distances aren't falsely recalculated when room dimensions are changed in program
  //original room dimensions on program launch, --> in cm
  origWidth = roomWidth; 
  origLength = roomLength;
  origHeight = roomHeight;

  //convert individual tower heights to cm
  t1z = tIn[0]*cm;
  t2z = tIn[1]*cm;
  t3z = tIn[2]*cm;
  t4z = tIn[3]*cm;

  //these are for the getDistances function so that distances aren't falsely recalculated when room dimensions are changed in program
  //original tower height dimensions on program launch, --> in cm
  origT[0] = t1z;
  origT[1] = t2z;
  origT[2] = t3z;
  origT[3] = t4z;

  //this makes sure all tower positions are correct on program load --> only run once
  tower1.zrel = t1z;
  tower2.xrel = roomWidth;
  tower2.zrel = t2z;
  tower3.xrel = roomWidth;
  tower3.yrel = roomLength;
  tower3.zrel = t3z;
  tower4.yrel = roomLength;
  tower4.zrel = t4z;
}


//---------------------- assign calibration values -------------------------
void assignCalibrationValues() {
  topSafe= cp5.getController("maxZSafe").getValue();
  minWidSafe= cp5.getController("minXSafe").getValue();
  maxWidSafe=  cp5.getController("maxXSafe").getValue();
  minLenSafe= cp5.getController("minYSafe").getValue();
  maxLenSafe= cp5.getController("minYSafe").getValue();
}



//--------------------------------------   RE-CALCULATE ROOM HEIGHT ON DIMENSION CHANGE  --------------------------------------
void maxHeight() { //function called when tower height changes --> re-calculate roomHeight
  // calculate roomHeight based on tallest tower
  float[] calcHeight = {
    t1z, t2z, t3z, t4z
  };
  roomHeight = max(calcHeight); //set room height to height of tallest tower
}


//---------------------- if same height box is checked -------------------------
void sameHeight (int a) {

  //if all towers are the same height...
  if (a==0) {  
    singleHeight = true;  

    sameHeight.getItem(0).getCaptionLabel().show(); //show little check mark 
    blockHeight.show(); //place text box over tower heights so they can't be edited

    for (int i=0; i<4; i++) {
      //set all tower heights to value of tower1
      //this only occurs when check box is selected
      heightTower[i].setValue(heightTower[0].getValue());
    }

    //format towerw 2-4 so they don't appear editable
    for (int i=1; i<4; i++) {
      heightTower[i].getCaptionLabel().hide(); //hide tower label under numberbox
      heightTower[i].getValueLabel().hide(); //hide number value on numberbox
    }
  } 

  //different heights
  else {   
    singleHeight = false;
    sameHeight.getItem(0).getCaptionLabel().hide(); //hide little check mark label
    blockHeight.hide();

    for (int i=1; i<4; i++) {
      heightTower[i].getCaptionLabel().show(); //hide tower label under numberbox
      heightTower[i].getValueLabel().show(); //hide number value on numberbox
    }
  }
}







//---------------------- easing mode event -------------------------

void mode(int f) { //for Easing mode event
  if ( f == 1) {
    aniMode = true; 
    destinationMode = false;
    println("Ani Easing is activated");
  } else if (f == 2) {
    aniMode = false; 
    destinationMode = true;
    println("Destination Easing is activated");
  }
}

