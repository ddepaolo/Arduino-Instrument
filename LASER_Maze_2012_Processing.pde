import ddf.minim.*;  // audio library
import processing.serial.*; // serial communication library

Minim minim;        // set up audio 
AudioSnippet alarmSound;
AudioSnippet woopSound;
AudioSnippet alertSound;
AudioSnippet shockSound;

Serial myPort; // The serial port
int graphHeight;  // individual height of all 4 graphs
int graphWidth;  // individual width of all 4 graphs
int graphYPos;  // top Y axis position of all 4 graphs
int graphXPos;  // X value varies depending on which graph is being updated
int graph0XPos;  // X axis alignment for graph 0
int graph1XPos;  // X axis alignment for graph 1
int graph2XPos;  // X axis alignment for graph 2
int graph3XPos;  // X axis alignment for graph 3
int alarmXPos; // X axis alignment for alarm servo indicator and text
int graph0Alarm = 0; // value that must be crossed to trigger alarm for graph 0
int graph1Alarm = 0; // value that must be crossed to trigger alarm for graph 1
int graph2Alarm = 0; // value that must be crossed to trigger alarm for graph 2
int graph3Alarm = 0; // value that must be crossed to trigger alarm for graph 3
boolean alarm = false;  // is the alarm servo on or off
int soundSelect = 1;  // determines which sound effect to play for alarm
long lastSound = 0;  // time when last sound was played

void setup () {
  // set the window size:
  size(1000, 500);
  graphHeight = int(0.8*height);
  graphWidth =  int(0.1*width);
  graphYPos = int(0.05*height);
  graphXPos = 0;  // X position varies depending on which graph is being updated
  graph0XPos = int(0.05*width); 
  graph1XPos = int(0.20*width);
  graph2XPos = int(0.35*width);
  graph3XPos = int(0.50*width);
  alarmXPos = int(0.65*width);
  
  // set inital background:
  background(#505050);
  
  textAlign(LEFT, TOP);
  textSize(50);
  fill(#DDDDDD);  // green
  text("LASER MAZE", alarmXPos, graphYPos);
  fill(#DDDDDD);  // green
  textSize(20);
  text("Alarm", alarmXPos+100, graphYPos + graphHeight/2);
  text("Sensor 1", graph0XPos, graphHeight*1.1);
  text("Sensor 2", graph1XPos, graphHeight*1.1);
  text("Sensor 3", graph2XPos, graphHeight*1.1);
  text("Sensor 4", graph3XPos, graphHeight*1.1);
  
  // List all the available serial ports
  println(Serial.list());
  // COM4 is my Arduino, so I open Serial.list()[1].
  // Open whatever port your Arduino is using.
  myPort = new Serial(this, Serial.list()[1], 9600);
  // don't generate a serialEvent() unless you get a newline character:
  myPort.bufferUntil('\n');

  // load sounds
  minim = new Minim(this);  // new audio object
  alarmSound = minim.loadSnippet("c:/alarm.mp3");  // load sound effects
  woopSound = minim.loadSnippet("c:/woopwoop.mp3");
  alertSound = minim.loadSnippet("c:/alert.mp3");
  shockSound = minim.loadSnippet("c:/shock.mp3");
}

void draw () {
// everything happens in the serialEvent()
}

void serialEvent (Serial myPort) {

  boolean graphData = false;  // we do not currently have data to graph
  char switchValue ='x';
  float inValue;
  String inString = myPort.readStringUntil('\n');    // get the ASCII string

  println();
  print("alarm is "); println(alarm);

  if (inString != null) {
    // trim off any whitespace:
    inString = trim(inString);
    print("inString = "); println(inString);

    // last character in the string tells us what kind of data we recieved
    switchValue = inString.charAt(inString.length()-1);
    print("switchVal = "); println(switchValue);    
  }
 
    switch(switchValue) {
      case '0':  // Recieved data for graph 0 (Analog Input 0 from Arduino)
        graphData = true;
        graphXPos = graph0XPos;
        break;
      case '1':  // Recieved data for graph 1 (Analog Input 1 from Arduino)
        graphData = true;
        graphXPos = graph1XPos;
        break;
      case '2':  // Recieved data for graph 2 (Analog Input 2 from Arduino)
        graphData = true;
        graphXPos = graph2XPos;
        break;
      case '3':  // Recieved data for graph 3 (Analog Input 3 from Arduino)
        graphData = true;
        graphXPos = graph3XPos;
        break;
      case '4':  // Recieved alarm trigger value for graph 0
        inValue = float(inString);  //convert to float
        inValue = floor(inValue/10);  // remove the ones position
        print("alarm trig 0 = "); println(inValue);    
        graph0Alarm = floor(map(inValue, 0, 1200, 0, graphHeight));  // map the input value to fit within the graph - change the 2nd number to change sensitivity
        print("alarm trig 0 map = "); println(graph0Alarm);    
        break;
      case '5':  // Recieved alarm trigger value for graph 1
        inValue = float(inString);  //convert to float
        inValue = floor(inValue/10);  // remove the ones position
        print("alarm trig 1 = "); println(inValue);    
        graph1Alarm = floor(map(inValue, 0, 1200, 0, graphHeight));  // map the input value to fit within the graph - change the 2nd number to change sensitivity
        print("alarm trig 1 map = "); println(graph1Alarm);    
        break;
      case '6':  // Recieved alarm trigger value for graph 2
        inValue = float(inString);  //convert to float
        inValue = floor(inValue/10);  // remove the ones position
        print("alarm trig 2 = "); println(inValue);    
        graph2Alarm = floor(map(inValue, 0, 1200, 0, graphHeight));  // map the input value to fit within the graph - change the 2nd number to change sensitivity
        print("alarm trig 2 map = "); println(graph2Alarm);    
        break;
      case '7':  // Recieved alarm trigger value for graph 3
        inValue = float(inString);  //convert to float
        inValue = floor(inValue/10);  // remove the ones position
        print("alarm trig 3 = "); println(inValue);    
        graph3Alarm = floor(map(inValue, 0, 1023, 0, graphHeight));  // map the input value to fit within the graph - change the 2nd number to change sensitivity
        print("alarm trig 3 map = "); println(graph3Alarm);    
        break;
      case '8':  // alarm servo ON
        // minimum 3 second delay from start of one sound to start of next
        if (millis() > lastSound + 3000) {  
          // play different alarm sounds  
          if (soundSelect == 1) {
            alertSound.play(1500);
            //soundSelect = 2;
            lastSound = millis();
            }
          else if (soundSelect == 2) {
            woopSound.play(0);
            soundSelect = 3;
            lastSound = millis();
            }
          else if (soundSelect == 3) {
            alarmSound.play(820);
            soundSelect = 4;
            lastSound = millis();
            }
          else if (soundSelect == 4) {
            shockSound.play(0);
            soundSelect = 1;
            lastSound = millis();
            }
          else {
            soundSelect = 1;
            lastSound = millis();
            }
        }
        alarm = true;
        fill(#FF0000);
        stroke(#303030);  // dark grey
        rect(alarmXPos+100, graphYPos + graphHeight/2 + 30, 70, 50);
        fill(#303030);  // grey
        textSize(20);
        text("ON", alarmXPos+110, graphYPos + graphHeight/2+40);
        break;
      case '9':  // alarm servo OFF
        alarm = false;
        fill(#00FF00);  // green
        stroke(#303030);  // dark grey
        rect(alarmXPos+100, graphYPos + graphHeight/2 + 30, 70, 50);
        fill(#303030);  // grey
        textSize(20);
        text("OFF", alarmXPos+110, graphYPos + graphHeight/2+40);
        break;
      default:  // Default executes if the case labels
        println("switch statement default");   // don't match the switch parameter
        break;
    }
    
    // draw the graphs
    if (graphData) {
      graphData = false;
      
      // prepare the value we recieved from serial in
      inValue = float(inString);
      inValue = floor(inValue/10);  // remove the ones position
      print("inValue = "); println(inValue);
      inValue = floor(map(inValue, 0, 1023, 0, graphHeight));  // map the input value to fit within the graph
      print("inValue map = "); println(inValue);
      
      //draw the grey background for the graph
      stroke(#303030);  // dark grey
      strokeWeight(2);
      fill(#707070);  // grey
      rect(graphXPos, graphYPos, graphWidth, graphHeight);
      
      // draw the green bar to represent our in value
      fill(#00CC00);  // light green
      rect(graphXPos, graphYPos + (graphHeight - inValue), graphWidth, inValue); 
    }
    
    // draw lines for alarm trigger values
    stroke(#FF0000);
    strokeCap(SQUARE);
    strokeWeight(2);
    if(graph0Alarm != 0){line(graph0XPos, graphYPos + (graphHeight - graph0Alarm), graph0XPos + graphWidth, graphYPos + (graphHeight - graph0Alarm));}
    if(graph1Alarm != 0){line(graph1XPos, graphYPos + (graphHeight - graph1Alarm), graph1XPos + graphWidth, graphYPos + (graphHeight - graph1Alarm));}
    if(graph2Alarm != 0){line(graph2XPos, graphYPos + (graphHeight - graph2Alarm), graph2XPos + graphWidth, graphYPos + (graphHeight - graph2Alarm));}
    if(graph3Alarm != 0){line(graph3XPos, graphYPos + (graphHeight - graph3Alarm), graph3XPos + graphWidth, graphYPos + (graphHeight - graph3Alarm));}
}

void stop() {
  alarmSound.close();  // always close Minim audio classes
  woopSound.close();
  alertSound.close();
  shockSound.close();
  minim.stop();   // always stop Minim before exiting
  myPort.stop();  // stop serial com
  super.stop();  // allow normal clean up routing to run after stop()
}

