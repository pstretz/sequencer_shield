/*
       Arduino Sequencer
 Learning Opertunities: 
 Analog Input Control of LED with Resistor Ladder -
 Demonstrates analog button press input on a resistor ladder by reading an 
 voltage on analog pin 0 and turning on and off a light emitting diode(LED)  
 connected to digital pins 2 and 3. The will be on or off depending on the 
 value obtained by analogRead(). 
 Managing multiple serial in parallel out shift registers -
 Using SPI to write to shift registers, managing multiple registers to
 control LEDs and trigger other devices
 EEPROM read and written to through I2C - 
 
 The circuit:
 * switches tapping off a 1K resistor ladder attached to analog input 0 and 1
 * A0 and A1 pulled low with a 1K resistor
 * LED anode (long leg) attached to digital outputs of 3 shift registers
 these are for the Sequence LEDs and trigger select LEDs
 * LED cathode (short leg) attached to ground through a 1K resistor IC
 * 5V triggers are attached to the 4th shift register.
 
 Created by Peter Stretz
 
 This example code is in the public domain.
 
 http://XXXXXXXXX
 
 */
 // constants won't change. They're used here to 
// set pin numbers and qty of pins:
 //sequence modifiers analog pin
const int seqSel=3; 
 //second analog pin 
const int modeSel=2;
 //Pin connected to ST_CP of 1st 74HC595
const int latchPin = 8;
 //Pin connected to SH_CP of 1st 74HC595
const int clockPin = 12;
 //Pin connected to DS of 1st 74HC595
const int dataPin = 11;

// the following variables are long's because the time, measured in miliseconds,
// will quickly become a bigger number than can be stored in an int.
 // the last time the output pin was toggled
long lastDebounceTime = 0; 
 // the debounce time; increase if the output flickers
long debounceDelay = 50;   

int playMode=0;
int trigcurr=1;
//used to store the reading from the watch the sequence switches
int reading0=0;
//used to store the reading from the trigger select and mode buttons
int reading1=0; 
int lastReading0=0; 
int lastReading1=0;
bool pinChange=0;
bool lastPinChange=0;
bool pinLeadingEdge=0;

//holder for information you're going to pass to shifting function
//byte data=B00000000; 
byte runSeq[]={B00000000, B00000001};
byte trigSel=B00000001;
byte trigHit[]={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
byte trig1Led[]={B01010101,B01010101};
byte trig2Led[]={0,0};
byte trig3Led[]={0,0};
byte trig4Led[]={0,0};
byte trig5Led[]={0,0};
byte trig6Led[]={0,0};
byte trig7Led[]={0,0};
byte trig8Led[]={0,0};
byte ledFlipTemp=0;

int data=0; //temp, need to remove

void setup() {
  //set pins to output because they are addressed in the main loop
  pinMode(latchPin, OUTPUT);
//  pinMode(clockPin, OUTPUT);
//  pinMode(dataPin, OUTPUT);
  Serial.begin(115200);
  Serial.println("reset");
  digitalWrite(latchPin, 0);
  myShiftOut(dataPin, clockPin, trigSel); 
  myShiftOut(dataPin, clockPin, trig1Led[1]);
  myShiftOut(dataPin, clockPin, trig1Led[0]);
  digitalWrite(latchPin, 1);

}

void loop(){
  if (playMode=1){
    digitalWrite(latchPin, 0);
    myShiftOut(dataPin, clockPin, trigSel); 
    switch (trigSel){
      case 256:
        myShiftOut(dataPin, clockPin, trig1Led[1]);
        myShiftOut(dataPin, clockPin, trig1Led[0]);
      break;
    }
    digitalWrite(latchPin, 1);  
  playMode=0;  
  }
  reading0 = analogRead(seqSel); //read from Sequence analog pin
  if (reading0 != lastReading0){
    Serial.println(reading0); //print the reading to the serial monitor
  }  
  if (reading0==0){
    pinChange=0;
  }
  if (reading0>1020 && reading0<1024){ //if the first button is pressed change the led State
    pinChange=1;
    stateFlip(0);
//     Serial.println("flip");
  } 
  if (reading0>499 && reading0<502){ //if the second button is pressed change the led State
    pinChange=1;
    stateFlip(1);
  } 
  if (reading0>326 && reading0<329){
    pinChange=1;
    stateFlip(2);
  } 
  if (reading0>242 && reading0<245){
    pinChange=1;
    stateFlip(3);
  }  
  if (reading0>190 && reading0<193){
    pinChange=1;
    stateFlip(4);
  }
  if (reading0>156 && reading0<159){
    pinChange=1;
    stateFlip(5);
  }
  if (reading0>132 && reading0<135){
    pinChange=1;
    stateFlip(6);
  }
  if (reading0>114 && reading0<117){
    pinChange=1;
    stateFlip(7);
  }
  if (reading0>100 && reading0<103){
    pinChange=1;
    stateFlip(8);
  }
  if (reading0>89 && reading0<92){
    pinChange=1;
    stateFlip(9);
  }
  if (reading0>79 && reading0<82){
    pinChange=1;
    stateFlip(10);
  }
  if (reading0>71 && reading0<74){
    pinChange=1;
    stateFlip(11);
  }
  if (reading0>63 && reading0<66){
    pinChange=1;
    stateFlip(12);
  }
  if (reading0>56 && reading0<59){
    pinChange=1;
    stateFlip(13);
  }
  if (reading0>49 && reading0<52){
    pinChange=1;
    stateFlip(14);
  }
  if (reading0>40 && reading0<44){
    pinChange=1;
    stateFlip(15);
  }
//  for (int i=0; i<maxPins; i++){ //check every cycle to update on/off of leds
//    if (ledState[i]!=oldState[i]){
//      digitalWrite(ledPins[i], ledState[i]);
//      oldState[i]=ledState[i];
//    }
//  }
  reading1 = analogRead(modeSel); //read from an analog pin
  if (reading1!=lastReading1){
    Serial.println(reading1); //print the reading to the serial monitor
  }
  if (reading0>40 && reading0<44){
    pinChange=1;
    stateFlip(15);
  }
  lastPinChange=pinChange;
  lastReading0=reading0;
  lastReading1=reading1;
}

void stateFlip(int offset){
  if (pinChange && (pinChange!=lastPinChange)){
    lastDebounceTime=millis();
    pinLeadingEdge=1;
  }
  if (offset < 8){
    if (((millis() - lastDebounceTime) > debounceDelay) && pinLeadingEdge==1) {
       //clear the temp byte in case it had any old data
      ledFlipTemp=0;
      ledFlipTemp = 1 << offset;
      trig1Led[0] = trig1Led[0] ^ ledFlipTemp;
       Serial.println(trig1Led[0]);
      pinLeadingEdge=0;
      playMode=1;
    }
  }
  if (offset > 7){
    if (((millis() - lastDebounceTime) > debounceDelay) && pinLeadingEdge==1) {
       //clear the temp byte in case it had any old data
      ledFlipTemp=0;
      offset = offset - 8;
      ledFlipTemp = 1 << offset;
      trig1Led[1] = trig1Led[1] ^ ledFlipTemp;
//       Serial.println(trig1Led[1]);   //used for troubleshooting
      pinLeadingEdge=0;
      playMode=1;
    }
  }  
}

void hitTriggers(int hitStep){
  //ground latchPin and hold low for as long as you are transmitting
  digitalWrite(latchPin, LOW);
  myShiftOut(dataPin, clockPin, (trigHit[hitStep]));
  myShiftOut(dataPin, clockPin, 0);
  myShiftOut(dataPin, clockPin, 0);
  myShiftOut(dataPin, clockPin, 0);
  //return the latch pin high to signal chip that it 
  //no longer needs to listen for information
  digitalWrite(latchPin, HIGH);
}

// the heart of the program
void myShiftOut(int myDataPin, int myClockPin, byte myDataOut) {
  // This shifts 8 bits out MSB first, 
  //on the rising edge of the clock,
  //clock idles low

  //internal function setup
  int i=0;
  int pinState;
  pinMode(myClockPin, OUTPUT);
  pinMode(myDataPin, OUTPUT);

  //clear everything out just in case to
  //prepare shift register for bit shifting
  digitalWrite(myDataPin, 0);
  digitalWrite(myClockPin, 0);

  //for each bit in the byte myDataOut…
  //NOTICE THAT WE ARE COUNTING DOWN in our for loop
  //This means that %00000001 or "1" will go through such
  //that it will be pin Q0 that lights. 
  for (i=7; i>=0; i--)  {
    digitalWrite(myClockPin, 0);

    //if the value passed to myDataOut and a bitmask result 
    // true then... so if we are at i=6 and our value is
    // %11010100 it would the code compares it to %01000000 
    // and proceeds to set pinState to 1.
    if ( myDataOut & (1<<i) ) {
      pinState= 1;
    }
    else {	
      pinState= 0;
    }

    //Sets the pin to HIGH or LOW depending on pinState
    digitalWrite(myDataPin, pinState);
    //register shifts bits on upstroke of clock pin  
    digitalWrite(myClockPin, 1);
    //zero the data pin after shift to prevent bleed through
    digitalWrite(myDataPin, 0);
  }

  //stop shifting
  digitalWrite(myClockPin, 0);
}

  
