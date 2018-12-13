/*
A modification of "Firmata" by Jason K. Johnson and Andrew Payne for grasshopper
 For use with AccelStepper library
 
 */

#include <AccelStepper.h>
#define BAUDRATE 115200     //Set the Baud Rate to an appropriate speed
#define BUFFSIZE  256       // buffer one command at a time, 12 bytes is longer than the max length


/*
//Pin arrangement for small immersive rig
 #define A_STEP_PIN         25  //Stepper pins 
 #define A_DIR_PIN          23
 #define B_STEP_PIN         28
 #define B_DIR_PIN          29
 #define C_STEP_PIN         30
 #define C_DIR_PIN          32
 #define D_STEP_PIN         36
 #define D_DIR_PIN          34
 */



//Pin arrangement for large immersive rig
#define A_STEP_PIN         23  //Used Pins on ChipKit Max32 / Mega
#define A_DIR_PIN          25
//define A_REST_PIN        27

#define B_STEP_PIN         35 //Originally pin 26, but would not trigger steps.
#define B_DIR_PIN          28
//#define B_REST_PIN       30 

#define C_STEP_PIN         29
#define C_DIR_PIN          31
//#define C_REST_PIN       33

#define D_STEP_PIN         32
#define D_DIR_PIN          34
//#define D_REST_PIN       36

//On the big stepper drivers CP+ is Step, and CW+ is Dir


int motorPos[4] = {
  0,0,0,0};
//int motorSpeed = 100;     //Set default speed value --> steps per second
int motorSpeed[4] = {
  100,100,100,100};
//int motorAcc = 100;       //Set default acceleration value
int motorAcc[4] = {
  100,100,100,100};

int motorRun = 0;        
int motorReset = 1;

int prev1 = 0;
char *parseptr;
char buffidx;

char buffer[BUFFSIZE];    // this is the double buffer
uint16_t bufferidx = 0;
uint16_t p1, s1;   

AccelStepper stepper1(1, A_STEP_PIN, A_DIR_PIN); //define pins stepper will use
AccelStepper stepper2(1, B_STEP_PIN, B_DIR_PIN);
AccelStepper stepper3(1, C_STEP_PIN, C_DIR_PIN);
AccelStepper stepper4(1, D_STEP_PIN, D_DIR_PIN);

void setup()
{  
  stepper1.setCurrentPosition(0);  //Move steppers to default position --> positive is clockwise from 0
  stepper2.setCurrentPosition(0);
  stepper3.setCurrentPosition(0);
  stepper4.setCurrentPosition(0);  
  setStepperSpeeds();

  Serial.begin(BAUDRATE);         // Start serial communication
  delay(1000);
}


void loop()
{
  UpdateStepperValues();  //Get all the incoming values from Firefly

  if (motorReset == 1) { 
    stepper1.setCurrentPosition(motorPos[0]);
    stepper2.setCurrentPosition(motorPos[1]);
    stepper3.setCurrentPosition(motorPos[2]);
    stepper4.setCurrentPosition(motorPos[3]);
  }

  stepper1.moveTo(motorPos[0]);  
  stepper2.moveTo(motorPos[1]);
  stepper3.moveTo(motorPos[2]);
  stepper4.moveTo(motorPos[3]);

  if (motorRun == 1) {
    stepper1.run();
    stepper2.run();
    stepper3.run();
    stepper4.run();
  } 
}


void UpdateStepperValues(){

  char c;    // holds one character from the serial port
  if (Serial.available()) {
    c = Serial.read();      // read one character
    buffer[bufferidx] = c;  // add to buffer

    if (c == '\n') {  
      buffer[bufferidx+1] = 0; // terminate it
      parseptr = buffer;    // offload the buffer into temp variable

      //********************************************************

      motorPos[0] = parsedecimal(parseptr);    // parse the first number
      parseptr = strchr(parseptr, ',')+1;      // move past the ","

      motorPos[1] = parsedecimal(parseptr);    // parse the next number
      parseptr = strchr(parseptr, ',')+1;      // move past the ","

      motorPos[2] = parsedecimal(parseptr);    // parse the next number
      parseptr = strchr(parseptr, ',')+1;       // move past the ","

      motorPos[3] = parsedecimal(parseptr);    // parse the next number
      parseptr = strchr(parseptr, ',')+1;      // move past the ","

      motorSpeed[0] = parsedecimal(parseptr);     // parse the next number
      parseptr = strchr(parseptr, ',')+1;      // move past the ","

      motorSpeed[1] = parsedecimal(parseptr);     // parse the next number
      parseptr = strchr(parseptr, ',')+1;      // move past the ","

      motorSpeed[2] = parsedecimal(parseptr);     // parse the next number
      parseptr = strchr(parseptr, ',')+1;      // move past the ","

      motorSpeed[3] = parsedecimal(parseptr);     // parse the next number
      parseptr = strchr(parseptr, ',')+1;      // move past the ","

      motorAcc[0] = parsedecimal(parseptr);       // parse the next number
      parseptr = strchr(parseptr, ',')+1;      // move past the ","

      motorAcc[1] = parsedecimal(parseptr);       // parse the next number
      parseptr = strchr(parseptr, ',')+1;      // move past the ","

      motorAcc[2] = parsedecimal(parseptr);       // parse the next number
      parseptr = strchr(parseptr, ',')+1;      // move past the ","

      motorAcc[3] = parsedecimal(parseptr);       // parse the next number
      parseptr = strchr(parseptr, ',')+1;      // move past the ","

      motorRun = parsedecimal(parseptr);       // parse the next number
      parseptr = strchr(parseptr, ',')+1;      // move past the ","

      motorReset = parsedecimal(parseptr);     // parse the next number

        setStepperSpeeds();

      bufferidx = 0;       // reset the buffer for the next read
      return;              //return so that we don't trigger the index increment below
    }
    // didn't get newline, need to read more from the buffer
    bufferidx++;    // increment the index for the next character
    if (bufferidx == BUFFSIZE-1) {  //if we get to the end of the buffer reset for safety
      bufferidx = 0;
    }
  }
}

double parsedecimal(char *str)
{
  return atof(str);
}

void setStepperSpeeds() {

  stepper1.setMaxSpeed(motorSpeed[0]);
  stepper1.setAcceleration(motorAcc[0]);
  //stepper1.setSpeed(motorSpeed);

  stepper2.setMaxSpeed(motorSpeed[1]);
  stepper2.setAcceleration(motorAcc[1]);
  // stepper2.setSpeed(motorSpeed);

  stepper3.setMaxSpeed(motorSpeed[2]);
  stepper3.setAcceleration(motorAcc[2]);
  // stepper3.setSpeed(motorSpeed);

  stepper4.setMaxSpeed(motorSpeed[3]);
  stepper4.setAcceleration(motorAcc[3]);
  // stepper4.setSpeed(motorSpeed);
}






