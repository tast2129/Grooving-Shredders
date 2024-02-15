#include <stdio.h>

// USER DEFINE
// time for RFSoC board to take signal intensity measurement at one step (one system position)
#define MeasureTime 300  // [milliseconds]
// microsteps (steps per "Step")
// 1    : 1.8 degrees per step
// 1/2  : 0.9 degrees per step
// 1/4  : 0.45 degrees per step
// 1/8  : 0.225 degrees per step
// 1/16 : 0.1125 degrees per step
#define Microstep 1/4

typedef struct {
  const int stepPin = 2;
  const int dirPin = 7;
  const int MS1Pin = 4;
  const int MS2Pin = 5;
  const int MS3Pin = 6;
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
 
void setup() {
  // initialize the serial port at 9600 bps
  Serial.begin(9600);

  // configuring stepper pins
  pinMode(stepper1.Pins.stepPin, OUTPUT); 
  pinMode(stepper1.Pins.dirPin, OUTPUT);
  pinMode(stepper1.Pins.MS1Pin, OUTPUT);
  pinMode(stepper1.Pins.MS2Pin, OUTPUT);
  pinMode(stepper1.Pins.MS3Pin, OUTPUT);
  MicrostepConfig(stepper1.ustep);
}

void loop() {
  // step one step at a time, delaying the amount of time needed for the RFSoC to take one signal intensity measurement
  digitalWrite(stepper1.Pins.dirPin, 1); // rotate clockwise
  while (stepper1.currentPosition != stepper1.stepsPerRev) { 
    // step one step:
    stepper1.currentPosition++;
    digitalWrite(stepper1.Pins.stepPin, 1);
    delay(MeasureTime);
    //printing the angle the stepper motor is point from start and the step # it is on
    stepper1.theta = stepper1.currentPosition * stepper1.degPerStep * stepper1.ustep;
    Serial.print("Angle from start: "); Serial.print(stepper1.theta); Serial.print("\° ");
    Serial.print("at step "); Serial.print(stepper1.currentPosition); Serial.println();
    digitalWrite(stepper1.Pins.stepPin, 0);
  }

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