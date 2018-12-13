/*
Help page that will pop up when 'h' button is pressed on keyboard
 --- Toggle help page on/off
 --- Display image of PS3 controller
 --- Include text about what each button does
 */

boolean helpPage = false; // don't initially show
boolean displayHelp = true; //make sure help tab isn't triggered while file name is being input
PImage ps3Img; //image of ps3 controller

Group helpGroup;
Icon controllerImg;

//text areas for help screen
Textarea helpText1;
Textarea helpText2;
Textarea helpText3;
Textarea helpText4;
Textarea helpText5;
Textarea helpText6;
Textarea helpText7;
Textarea helpText8;
Textarea helpText9;
Textarea helpText10;

Textarea helpIndicator;
Textarea helpIndicator2;

int lineHeight = 15; 
int lineZ = -20;

color lineColor = entireBackground;

void helpTab() {

  ps3Img = loadImage("ps3Img.png");

  helpGroup = cp5.addGroup("helpGroup")
    .setPosition(0, 0)
      .setWidth(width)
        .setBackgroundColor(color(251, 252, 253))
          .setBackgroundHeight(height)
            .hideBar()
              ;

  controllerImg = cp5.addIcon("controllerImg", 10) //background to go behind icon image
    .setPosition(width/2 - 300, height/2 -186)
      .hideBackground()
        .setImage(ps3Img)
          .moveTo(helpGroup)
            ;

  helpText1 = cp5.addTextarea("helpText1") 
    .setPosition(width/2-235, height/2+250)
      .setSize(200, 160)
        .setColor(textColor)
          .setText("Moves camera up and down")
            .setLineHeight(lineHeight)
              .moveTo(helpGroup)
                .hideScrollbar()
                  ;

  helpText2 = cp5.addTextarea("helpText2")
    .setPosition(width/2+80, height/2+250)
      .setSize(220, 160)
        .setColor(textColor)
          .setText("Moves camera along length and width")
            .setLineHeight(lineHeight)
              .moveTo(helpGroup)
                .hideScrollbar()
                  ;

  helpText3 = cp5.addTextarea("helpText3")
    .setPosition(width-280, height/2-185)
      .setSize(250, 160)
        .setColor(textColor)
          .setText("Hold bottom button to seek camera towards active flag point")
            .setLineHeight(lineHeight)
              .moveTo(helpGroup)
                .hideScrollbar()
                  ;

  helpText3 = cp5.addTextarea("helpText3p5")
    .setPosition(width-280, height/2-150)
      .setSize(250, 160)
        .setColor(textColor)
          .setText("Hold top button to toggle moveable flag point")
            .setLineHeight(lineHeight)
              .moveTo(helpGroup)
                .hideScrollbar()
                  ;

  helpText4 = cp5.addTextarea("helpText4")
    .setPosition(70, height/2-58)
      .setSize(250, 160)
        .setColor(textColor)
          .setText("Moves selected flag point along length and width")
            .setLineHeight(lineHeight)
              .moveTo(helpGroup)
                .hideScrollbar()
                  ;

  helpText5 = cp5.addTextarea("helpText5")
    .setPosition(300, 110)
      .setSize(300, 160)
        .setColor(textColor)
          .setText("Press to move active flag point to camera location")
            .setLineHeight(lineHeight)
              .moveTo(helpGroup)
                .hideScrollbar()
                  ;

  helpText6 = cp5.addTextarea("helpText6")
    .setPosition(665, 110)
      .setSize(350, 160)
        .setColor(textColor)
          .setText("Start / pause movement towards active flag point")
            .setLineHeight(lineHeight)
              .moveTo(helpGroup)
                .hideScrollbar()
                  ;

  helpText7 = cp5.addTextarea("helpText7")
    .setPosition(width-280, height/2-65)
      .setSize(250, 160)
        .setColor(textColor)
          .setText("Hold in combination with up / down button to turn motors individually")
            .setLineHeight(lineHeight)
              .moveTo(helpGroup)
                .hideScrollbar()
                  ;

  helpText8 = cp5.addTextarea("helpText8")
    .setPosition(96, height/2-175)
      .setSize(250, 160)
        .setColor(textColor)
          .setText("Move selected flag point up / down" )
            .setLineHeight(lineHeight)
              .moveTo(helpGroup)
                .hideScrollbar()
                  ;

  helpGroup.hide(); //hide help group during setup --> only reveal when 'h' key is pressed on keyboard

  helpIndicator = cp5.addTextarea("helpIndicator")
    .setPosition(width-120, height-28)
      .setSize(300, 20)
        .setColor(textColor)
          .setText("Press 'h' for help" )
            .hideScrollbar()
              ;

  helpIndicator2 = cp5.addTextarea("helpIndicator2")
    .setPosition(width-180, height-28)
      .setSize(300, 20)
        .setColor(textColor)
          .setText("Press 'h' to return to program" )
            .hideScrollbar()
              ;

  helpIndicator2.hide();
}

void helpLines() {
  stroke(lineColor);
  line(840, 205, lineZ, 968, 205, lineZ); //help3 line
  line(848, 240, lineZ, 968, 240, lineZ); //help3.5 line
  line(301, 328, lineZ, 372, 328, lineZ); //help4 line
  line(967, 328, lineZ, 876, 328, lineZ); //help7 line
  line(292, 210, lineZ, 403, 210, lineZ); //help8 line
  line(569, 308, lineZ, 569, 128, lineZ); //help5 line
  line(673, 308, lineZ, 673, 128, lineZ); //help6 line
  line(712, 468, lineZ, 712, 624, lineZ); //help2 line
  line(537, 468, lineZ, 537, 624, lineZ); //help1 line
  noStroke(); //reset stroke
}


void keyPressed() {
  //if 'h' key is pressed on keyboard, toggle help page on or off
  if (key == 'H' || key == 'h') {
    if (displayHelp == true) {
      if (helpPage == false) {
        helpPage = true;
        pushZ = -1000; //adjust z translation on 3D box visualization (otherwise it appears on this screen due to z translation)
        lineColor = textColor;
        lineZ = 1;
        helpGroup.show(); //show help page
        helpIndicator.hide(); //hide 'press h' prompt
        helpIndicator2.show(); //show 'press h to return' prompt
      } else {
        helpPage = false;
        pushZ = 188; //reset z translation on 3D box
        lineColor = entireBackground;
        lineZ = -20;
        helpGroup.hide(); //hide help page
        helpIndicator.show(); //show 'press h' prompt
        helpIndicator2.hide(); //hide 'press h to return' prompt
      }
    }
  }
}

