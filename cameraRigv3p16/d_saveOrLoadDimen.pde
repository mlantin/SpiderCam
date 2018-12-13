// save room dimensions to JSON file. When 'save' it pressed, window will pop up to input file name

ScrollableList loadOptions;
File folder;
File folderTwo;
String [] filenames;
String [] filenamesTwo;

String[] dimensionNames = {
};

int fileNumber;
int fileNumberTwo;


//hidden menu items that will appear when dimensions are to be saved or loaded 
void hiddenGroups() {

  //------------------------------------------HIDDEN SAVE MENU------------------------------------------
  //STUFF FOR SAVING FILES BY NAME -- HIDDEN @ STARTUP 
  cp5.addTextfield("fileName")    //text field to input file name
    .setPosition(485, 300)
      .setSize(300, 40)
        .setFont(headingFont)
          .setColorBackground(itemColor)
            .setColor(textColor)
              .setColorCursor(0) 
                .setAutoClear(false)
                  ;

  cp5.addBang("save_dimensions") //save button
    .setPosition(485, 350)
      .setSize(300, 20)
        .setLabel("save dimensions")
          .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
            ;  

  cp5.addBang("closebutton") //close button to hide menu and bring 3D visualization back
    .setPosition(765, 270)
      .setSize(20, 20)
        .setLabel("X")
          .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
            ;  


  //hide so they don't appear unless prompted
  cp5.getController("save_dimensions").hide();
  cp5.getController("fileName").hide();
  cp5.getController("closebutton").hide();


  //------------------------------------------HIDDEN LOAD MENU------------------------------------------

  loadOptions =  cp5.addScrollableList("LoadOpt")
    .setPosition(485, 300)
      .setSize(300, 110)
        .setBarHeight(20)
          .setItemHeight(20)
            .setColorBackground(itemColor)
              .setColorValue(textColor)
                .setColorLabel(textColor)
                  .setColorActive(radioColorActive)
                    .setColorForeground(radioColor)
                      .setType(ScrollableList.LIST)//supports dropdown and list
                        .setCaptionLabel("Select File to Open: ")
                          ;

  cp5.getController("LoadOpt").hide();

  loadOptions.getCaptionLabel().toUpperCase(false);
  loadOptions.getValueLabel().toUpperCase(false); //this adjusts item label

  java.io.File folder = new java.io.File(sketchPath("")); //set folder to root folder of sketch
  filenames = folder.list(); //create list of files from root folder

  //iterate through all files in folder -- select only those that contain word "dimensions-"

  fileNumber = filenames.length-1;
  println(fileNumber + " = fileNumber");
  for (int i = 0; i <= filenames.length-1; i++) {
    if ( filenames[i].contains("dimensions-")) { 
      dimensionNames = append(dimensionNames, filenames[i]); //String array to hold all files that contain dimension data
      loadOptions.addItem(filenames[i], i); //add file to menu list
    }
  }
}

//this is the 'save' button in the room dimensions accordion
void b1(float v) {
  loadWidth = roomWidth*in; //converted to cm later, so keep this value in inches
  loadLength = roomLength*in;//converted to cm later, so keep this value in inches

  pushZ = -1000; //adjust z translation on 3D box visualization (otherwise it appears on this screen due to z translation)
  rectMode(CENTER);

  //display menu to save file by name
  cp5.getController("save_dimensions").show();
  cp5.getController("fileName").show();
  cp5.getController("closebutton").show();
  cp5.getController("LoadOpt").hide();

  displayHelp = false;  //when save button is pressed, don't allow help tab to be triggered by 'h' press
}

public void save_dimensions() {

  String savedName = cp5.get(Textfield.class, "fileName").getText();
  cp5.getProperties().addSet("dimensions-"+cp5.get(Textfield.class, "fileName").getText()); //add properties group based on name entered into text field

  //SAVE ALL DIMENSIONS TO INDIVIDUALLY NAMED FOLDER
  // the 3 parameters read like this: move controller(1) from set(2) to set(3) 
  //saves all values to file when "save dimensions" is clicked
  cp5.getProperties().move(cp5.getController("roomWidth"), "default", "dimensions-"+cp5.get(Textfield.class, "fileName").getText());
  cp5.getProperties().move(cp5.getController("roomLength"), "default", "dimensions-"+cp5.get(Textfield.class, "fileName").getText());
  cp5.getProperties().move(cp5.getController("cHeight"), "default", "dimensions-"+cp5.get(Textfield.class, "fileName").getText());

  for (int i=0; i<4; i++) {
    cp5.getProperties().move(cp5.getController("heightTower" + (i+1)), "default", "dimensions-"+cp5.get(Textfield.class, "fileName").getText()); //save tower heights to setDimen file
  }

  cp5.saveProperties("dimensions-"+cp5.get(Textfield.class, "fileName").getText(), "dimensions-"+cp5.get(Textfield.class, "fileName").getText()); //save room dimensions

  //SAVE LATEST DIMENSIONS TO BE USED NEXT TIME PROGRAM IS LAUNCHED 
  // the 3 parameters read like this: move controller(1) from set(2) to set(3) 
  //saves all values to file when "save dimensions" is clicked
  cp5.getProperties().move(cp5.getController("roomWidth"), "default", "setDimen");
  cp5.getProperties().move(cp5.getController("roomLength"), "default", "setDimen");
  cp5.getProperties().move(cp5.getController("cHeight"), "default", "setDimen");

  for (int i=0; i<4; i++) {
    cp5.getProperties().move(cp5.getController("heightTower" + (i+1)), "default", "setDimen"); //save tower heights to setDimen file
  }

  cp5.saveProperties("setDimen", "setDimen"); //save room dimensions
  cp5.getController("save_dimensions").hide(); //hide menu items
  cp5.getController("fileName").hide();
  cp5.getController("closebutton").hide();

  //when a new room is saved, reset bumper values around the walls to their default value
  cp5.getController("maxZSafe").setValue(2);
  cp5.getController("minXSafe").setValue(5);
  cp5.getController("maxXSafe").setValue(5);
  cp5.getController("minYSafe").setValue(5);
  cp5.getController("maxYSafe").setValue(5);

  pushZ = 188; //adjust z translation on 3D box visualization (otherwise it appears on this screen due to z translation)
  println("Properties have been saved to " + "dimension-" +savedName);
  displayHelp = true; //help tab may now be accessed when 'h' is pressed
}

void load(float v) {
  println("Select file to open.");
  pushZ = -1000; //adjust z translation on 3D box visualization (otherwise it appears on this screen due to z translation)
  cp5.getController("LoadOpt").show();
  cp5.getController("closebutton").show();
  cp5.getController("save_dimensions").hide();
  cp5.getController("fileName").hide();
}


void LoadOpt(int n) {
  cp5.loadProperties(dimensionNames[n]);
  cp5.getController("LoadOpt").hide();
  cp5.getController("closebutton").hide();

  pushZ = 188; //adjust z translation on 3D box visualization (otherwise it appears on this screen due to z translation)
}

void closebutton(int a) {
  cp5.getController("LoadOpt").hide();
  cp5.getController("closebutton").hide();
  cp5.getController("save_dimensions").hide();
  cp5.getController("fileName").hide();
  pushZ = 188; //adjust z translation on 3D box visualization (otherwise it appears on this screen due to z translation)
  displayHelp = true;
}

