#include <Servo.h> 

// servo will be used to flip a switch on the red beacon light 
Servo myservo;  

// constants to set up pins  
int mySensors[] = {A0, A1, A2, A3, A4, A5};    // analog pins with CDS cells to detect laser beam
const int numSensors = 4;   // total number of CDS cells used ###MODIFY IF NEEDED###

// variables to handle analog values from CDS cells
int curValue;               // stores the value of the CDS cell that is currently being read
int prevValue[numSensors];  // stores the previous value of each CDS cell
int baseValue[numSensors];  // stores a baseline value for each CDS cell when the laser beam is not broken
int shouldAlarm[numSensors];// flag to decide if alarm signal should be sent
int sensitivity = 35;       // an offset from the baseValue to determine if laser beam is broken ###MODIFY IF NEEDED###
int sendAlarm = 0;          // determines if we should send the alarm signal to the COM port

// variables to control red beacon light
int alarmLength = 3000; // how long red light should remain on in milliseconds - synch with mp3 played by processing ###MODIFY IF NEEDED###
unsigned long alarmTime;// time alarm was activated
int onPos = 50;          // on position for servo ###MODIFY IF NEEDED###  
int offPos = 110;        // off position for servo ###MODIFY IF NEEDED###

void setup() {
  // initialize the serial communication to PC
  Serial.begin(9600);
  // Serial messages sent to processing. The digit in the ones place tells us what kind of data we have.
  // ####0 - data from A0, where #### is the data and 0 is the code telling where the data belongs
  // ####1 - data from A1  
  // ####2 - data from A2
  // ####3 - data from A3  
  // ####4 - alarm trigger value for A0, where #### is the value and 4 is the code telling where the data belongs
  // ####5 - alarm trigger value for A1  
  // ####6 - alarm trigger value for A2
  // ####7 - alarm trigger value for A3  
  // 8 - alarm servo on
  // 9 - alarm servo off
  
  // attach the servo to pin 9
  myservo.attach(9); 
  myservo.write(offPos);
  
  // set all of the CDS cell analog pins as inputs
  for (int thisSensor = 0; thisSensor < numSensors; thisSensor++)  {
    pinMode(mySensors[thisSensor], INPUT);     
  }
  
  calibrate();
}

void loop() {
 
  // check each CDS cell to see if the laser beam is broken
  for (int thisSensor = 0; thisSensor < numSensors; thisSensor++)  {
    curValue = analogRead(mySensors[thisSensor]);
    Serial.println(curValue*10+thisSensor);
    
   // A broken beam is detected if the current sensor value and
   // the previous value are both less than the base value
   // minus the sensitivity. 
    if (curValue < (baseValue[thisSensor] - sensitivity) && prevValue[thisSensor] < (baseValue[thisSensor] - sensitivity) && shouldAlarm[thisSensor] == 1) {
      // laser beam has been broken, alarm should be sent
      Serial.println("8");
      shouldAlarm[thisSensor] = 0;
      // activate servo to turn on red beacon light
      myservo.write(onPos);
      delay(20);
      alarmTime = millis();
    }
    // laser beam not currently broken, so reset the alarm flag
    else if (curValue > (baseValue[thisSensor] - sensitivity) && prevValue[thisSensor] > (baseValue[thisSensor] - sensitivity)) {
      shouldAlarm[thisSensor] = 1;
    }
    prevValue[thisSensor] = curValue;  // update the previous value
  }

  // deactivate the servo if it has been more than alarmLength
  if (millis() - alarmTime > alarmLength) {
    Serial.println("9");
    myservo.write(offPos);
    delay(20);
  }
}

void calibrate() {
  Serial.println("CALIBRATING!");
  // for each CDS cell, average three readings together to 
  // calculate base value when laser beam is not broken
  for (int thisSensor = 0; thisSensor < numSensors; thisSensor++)  {
    baseValue[thisSensor] = analogRead(mySensors[thisSensor]);    // first reading
    delay(20);
    baseValue[thisSensor] += analogRead(mySensors[thisSensor]);   // plus second reading
    delay(20);
    baseValue[thisSensor] += analogRead(mySensors[thisSensor]);   // plus third reading
    baseValue[thisSensor] /= 3;                                   // divided by 3 to find average
    Serial.println((baseValue[thisSensor]-sensitivity)*10+4+thisSensor);  // last digit tells processing this is an alarm trigger value
  }
}
