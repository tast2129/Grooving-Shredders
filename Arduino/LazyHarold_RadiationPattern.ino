// Script used for generating radiation patterns in conjunction with Integration_Test_2.ipynb ran on the RFSoC

#include <stdio.h>

// USER DEFINE
// time for RFSoC board to take signal intensity measurement at one step (one system position)
#define MeasureTime 300  // [milliseconds] update to make twitches faster/slower
// microsteps (steps per "Step")
// 1    : 1.8 degrees per step
// 1/2  : 0.9 degrees per step
// 1/4  : 0.45 degrees per step
// 1/8  : 0.225 degrees per step
// 1/16 : 0.1125 degrees per step
#define Microstep 1/2 // Keep at 1/2, other values don't work

typedef struct {
  const int stepPin = 2;
  const int dirPin = 3;
  const int MS1Pin = 4;
  const int MS2Pin = 5;
  const int MS3Pin = 6;
} stepperPins;

// Define a stepper and the pins it will use
typedef struct {
  const float degPerStep = 1.8;             // leave alone
  const float stepsPerRev = 360 / 1.8;      // leave alone
  volatile float theta = 0;                     // current angle the motor is pointing
  volatile int currentPosition = 0;             // in steps from initial position
  const float ustep = ((float)Microstep);       // cast user define Microstep
  stepperPins Pins;
} stepper;

// initialize stepper struct
stepper stepper1;

int BFG_pin = A0;
int BFG_recent_val = 0;
int BFG_current_val = 0;
int sweep_degrees = 180;
int number_of_measurements = (sweep_degrees/.9) + 1;
 
void setup() {
  // initialize the serial port at 9600 bps
  Serial.begin(9600);

  // Define RFSoC Analog in Pin
  pinMode(BFG_pin, INPUT);

  // configuring stepper pins
  pinMode(stepper1.Pins.stepPin, OUTPUT); 
  pinMode(stepper1.Pins.dirPin, OUTPUT);
  pinMode(stepper1.Pins.MS1Pin, OUTPUT);
  pinMode(stepper1.Pins.MS2Pin, OUTPUT);
  pinMode(stepper1.Pins.MS3Pin, OUTPUT);
  MicrostepConfig(stepper1.ustep);
}

void loop() {
  Serial.println("Waiting for RFSoC..."); Serial.println();
  Serial.println(""); Serial.println();
  // Wait for BFG to toggle analog pin
  while(BFG_current_val == BFG_recent_val){
    BFG_current_val = digitalRead(BFG_pin); 
  }
  if(BFG_current_val == 1){
    BFG_recent_val = 1;
  }
  else{
    BFG_recent_val = 0;
  }

  Serial.println("Twitching...");
  // Twitch:
  stepper1.currentPosition++; // increment current position (in # of steps from initial position)
  digitalWrite(stepper1.Pins.dirPin, 0); // rotate clockwise
  digitalWrite(stepper1.Pins.stepPin, 1);
  delay(MeasureTime);
  digitalWrite(stepper1.Pins.stepPin, 0);
  Serial.println("Twitch complete.");
  
  //printing the angle the stepper motor is relative to start and the measurement # it is on
  stepper1.theta = stepper1.currentPosition * stepper1.degPerStep * Microstep;
  Serial.print("Angle from start at measurement "); Serial.print(stepper1.currentPosition); Serial.print(" is: "); Serial.print(stepper1.theta); Serial.println("\° "); Serial.println();

  // If one full revolution is complete, rotate CCW real fast to reset for new measurement set
  if(stepper1.currentPosition+1 == number_of_measurements){
    Serial.println("Measurement complete. Resetting...");
    stepper1.theta = 0;
    while (stepper1.currentPosition != 0) {
      Serial.println(stepper1.currentPosition);
      digitalWrite(stepper1.Pins.dirPin, 1); // rotate counter clockwise
      digitalWrite(stepper1.Pins.stepPin, 1);
      delay(10); // this can just be something fast (real fast) this being to fast for the twitch slow down to 500 
      digitalWrite(stepper1.Pins.stepPin, 0);
      stepper1.currentPosition--;
  }
   Serial.println("Reset complete.");
 }
}

// sets the microstep pins to acheive a microstep based on value of "Step"
void MicrostepConfig(float step) {
  // inital motor settings
  // Based on user-defined microstep var, configure the microstep(MS) pins with their appropriate logic levels
  // configuring MS3 Pin // to get a faster rotation 1/8 instead of 1/16
  if (Microstep == (1 /8)) {
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
