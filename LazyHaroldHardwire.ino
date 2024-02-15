#include <stdio.h>

// USER DEFINE
// time for RFSoC board to take signal intensity measurement at one step (one system position)
#define MeasureTime 1000  // [milliseconds]
// microsteps (steps per "Step")
// 1    : 1.8 degrees per step
// 1/2  : 0.9 degrees per step
// 1/4  : 0.45 degrees per step
// 1/8  : 0.225 degrees per step
// 1/16 : 0.1125 degrees per step
#define Microstep 1/4

#define READY     1       // state definition, used for the arduino to tell the RFSoC that the motor is in position
#define NOT_READY 0 

// defines bluetooth communication pins
const int TXpin = 1;
const int RXpin = 0;

int appData;  
String inData = "";

typedef struct {
  const int stepPin = 2;
  const int dirPin = 3;
  const int MS1Pin = 4;
  const int MS2Pin = 5;
  const int MS3Pin = 6;
  const int SleepPin = 8;
} stepperPins;

// Define a stepper and the pins it will use
typedef struct {
  const float degPerStep = 1.8;
  const float stepsPerRev = 2 * 360 / 1.8;      // w/ 1.8 deg per step and 360 deg in one revolution. Why the factor of two? who's to say
  volatile float theta = 0;                     // current angle the motor is pointing
  volatile int currentPosition = 0;             // in steps from initial position
  const float ustep = ((float)Microstep);       // cast user define Microstep
  stepperPins Pins;
} stepper;

// initialize stepper struct
stepper stepper1;

// initialize SoftwareSerial struct for bluetooth communication with the RFSoC board
//SoftwareSerial ble (RXpin, TXpin); // RX, TX
 
void setup() {
  // initialize the serial port at 9600 bps
  Serial.begin(9600);

  // configuring input/output pins on arduino
  pinMode(RXpin, INPUT);
  pinMode(TXpin, OUTPUT);

  // configuring stepper pins
  pinMode(stepper1.Pins.stepPin, OUTPUT); 
  pinMode(stepper1.Pins.dirPin, OUTPUT);
  pinMode(stepper1.Pins.MS1Pin, OUTPUT);
  pinMode(stepper1.Pins.MS2Pin, OUTPUT);
  pinMode(stepper1.Pins.MS3Pin, OUTPUT);
  MicrostepConfig(stepper1.ustep);
}

void loop() {
  while(1) {
    appData = digitalRead(RXpin);
    //inData = String(appData);  // save the data in string format
    //Serial.println(appData);
    //Serial.println(stepper1.ustep);

    // the outer if/else loops here are used to check that the RFSoC 
    // is ready to take measurements BEFORE we start moving the motor
    if (appData == 1) {
      Serial.println("I am ready! Yay!");
      // step one step at a time, delaying the amount of time needed for the RFSoC to take one signal intensity measurement
      digitalWrite(stepper1.Pins.dirPin, 1); // rotate clockwise
      while (stepper1.currentPosition != stepper1.stepsPerRev) { 
        appData = digitalRead(RXpin); // read the RX pin on the arduino
        if (appData == 0) break; // if we receive the "RESET" signal, break out of the loop and reset the position

        // step one step:
        stepper1.currentPosition++;
        digitalWrite(stepper1.Pins.stepPin, 1);
        delay(10); // idk how long it takes for the motor to move to position, may not need this? no we need this
        // ^ We just need to know that the motor is in position before we tell the RFSoC board to start taking its measurement

        delay(MeasureTime);
        //printing the angle the stepper motor is point from start and the step # it is on
        stepper1.theta = stepper1.ustep * stepper1.currentPosition;
        Serial.print("Angle from start: "); Serial.print(stepper1.theta); Serial.print("\° ");
        Serial.print("at step "); Serial.print(stepper1.currentPosition); Serial.println();
        digitalWrite(stepper1.Pins.stepPin, 0);
      }
    } else delay (500); // if no data is available via BLE, delay for half a second

    // If one full revolution is complete, rotate CCW real fast to reset for new measurement set
    Serial.println("RESET (Measurement complete)");
    digitalWrite(stepper1.Pins.dirPin, 0);
    stepper1.theta = 0;
    while (stepper1.currentPosition != 0) {
      digitalWrite(stepper1.Pins.stepPin, 1);
      delay(10); // this can just be something fast (real fast)
      digitalWrite(stepper1.Pins.stepPin, 0);
      stepper1.currentPosition--;
    }
  }
}

// sets the microstep pins to acheive a microstep based on value of "Step"
void MicrostepConfig(float step) {
  // inital motor settings
  // Based on user-defined microstep var, configure the microstep(MS) pins with their appropriate logic levels
  // configuring MS3 Pin
  if (Microstep == (1 / 16)) {
    digitalWrite(stepper1.Pins.MS3Pin, HIGH);
  } else digitalWrite(stepper1.Pins.MS3Pin, LOW);

  // configuring MS2 pin
  if (Microstep > (1 / 4)) {
    digitalWrite(stepper1.Pins.MS2Pin, HIGH);
  } else digitalWrite(stepper1.Pins.MS2Pin, LOW);

  // configuring MS1 Pin
  if ((Microstep < (1 / 4)) || (Microstep == (1 / 2))) {
    digitalWrite(stepper1.Pins.MS1Pin, HIGH);
  } else digitalWrite(stepper1.Pins.MS1Pin, LOW);
}