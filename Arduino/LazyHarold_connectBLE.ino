/* HM-10 and PmodBLE connection script
 * Katie Christiansen
 * 4/11/24
*/
#include <stdio.h>
// Library to make a Software UART
#include <SoftwareSerial.h>


#define BAUDRATE 9600

// defines bluetooth communication pins
const int TXpin = 1;
const int RXpin = 0;

char c = ' ';
boolean new_line = true;

// initialize SoftwareSerial struct for bluetooth communication with the RFSoC board
SoftwareSerial BLEserial(RXpin, TXpin); // RX, TX
 
void setup() {
  // initialize the serial port at 9600 bps
  Serial.begin(BAUDRATE);

  // HM-10 default speed in AT command mode
  BLEserial.begin(BAUDRATE);
  
  Serial.println("Enter AT commands:");
}

void loop() {
  // Keep reading from HM-10 and send to Arduino Serial Monitor
  if (BLEserial.available())
    Serial.write(BLESerial.read());

  // Keep reading from Arduino Serial Monitor and send to HM-10
  if (Serial.available()) {

    // Read from the Serial buffer (from the user input)
    c = Serial.read();

    // Do not send newline ('\n') nor carriage return ('\r') characters
    if(c != 10 && c != 13)
      BLEserial.write(c);

    // If a newline ('\n') is true; print newline + prompt symbol; toggle
    if (new_line) { 
      Serial.print("\r\n>");
      new_line = false;
    }

    // Write to the Serial Monitor the bluetooth's response
    Serial.write(c);
    
    // If a newline ('\n') is read, toggle
    if (c == 10)
      new_line 
}
