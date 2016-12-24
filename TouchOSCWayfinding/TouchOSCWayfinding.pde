import processing.serial.*;

import oscP5.*;
import netP5.*;
OscP5 oscP5;

float delayTime = 0.0f;
float autoToggle = 0.0f;
float manualPush = 0.0f;
float directionStart = 0.0f;
float powerOn = 1.0f;
String direction = "North";
Boolean firstRun = true;

Serial wayfindingArduino;
byte[] out = {0, 0, 0, 0};

NetAddress iPhone;
void setup() {
  size(320, 440);
  frameRate(30);
  /* start oscP5, listening for incoming messages at port 8000 */
  oscP5 = new OscP5(this, 8000);
  String portName = Serial.list()[1];
  
  // Update this based on TouchOSC
  iPhone = new NetAddress("10.0.0.7", 9000);
  wayfindingArduino = new Serial(this, portName, 9600);
}

// Our setter elements
void setInterfaceControlElements() {
  
  // If power is off, put this over all of our controls
  OscMessage bigPowerOffLabelVisibility = new OscMessage("/1/label5/visible");
  bigPowerOffLabelVisibility.add(0);
  oscP5.send(bigPowerOffLabelVisibility, iPhone);
  
  // Mini label setting for power toggle
  OscMessage smallPowerLabel = new OscMessage("/2/power");
  smallPowerLabel.add("Power On");
  oscP5.send(smallPowerLabel, iPhone);
  
  // Set label for delay fader
  OscMessage delayMessage = new OscMessage("/1/label1");
  delayMessage.add("Delay: " + nf((map(out[0], 0, 127, 2500, 30000) / 1000), 1, 2));
  oscP5.send(delayMessage, iPhone); 
  
  // Set starting direction label
  OscMessage startingDirection = new OscMessage("/1/label2");
  startingDirection.add("Starting Direction: " + direction);
  oscP5.send(startingDirection, iPhone);
  
  // Some conditional code for auto mode/manual trigger labels
  OscMessage autoModeToggle = new OscMessage("/1/label3");
  OscMessage triggerModeLabel = new OscMessage("/1/label4");
  OscMessage triggerVisibility = new OscMessage("/1/push1/visible");
  if (autoToggle==1) {
    autoModeToggle.add("Auto Mode On");
    triggerModeLabel.add("Trigger Disabled");
    triggerVisibility.add(0);
  } else {
    autoModeToggle.add("Auto Mode Off");
    triggerModeLabel.add("Trigger Enabled");
    triggerVisibility.add(1);
  }
  oscP5.send(triggerVisibility, iPhone);
  oscP5.send(autoModeToggle, iPhone);
  oscP5.send(triggerModeLabel, iPhone);
}


// Where we send stuff
void oscEvent(OscMessage theOscMessage) {
  
  firstRun = false; // We're no longer initializing
  String addr = theOscMessage.addrPattern();
  
  // We've just hit the page controls
  if (addr.equals("/1") || addr.equals("/2")) {
    return;
  };
  float  val  = theOscMessage.get(0).floatValue();

  if (addr.equals("/1/fader1")) { 
    delayTime = val; // Set the value of our delay
  } else if (addr.equals("/1/toggle1")) { 
    autoToggle = val; // Set the value of toggle on/off
  } else if (addr.equals("/1/push1")) { 
    manualPush = val; // Set the value of manual trigger
  } else if (addr.equals("/1/multitoggle1/1/1")) { 
    directionStart = 0;
    direction = "North"; // North starting point
  } else if (addr.equals("/1/multitoggle1/2/1")) { 
    directionStart = 1;
    direction = "East"; // East starting point
    println("directionStart = " + directionStart);
  } else if (addr.equals("/1/multitoggle1/3/1")) { 
    directionStart = 2;
    direction = "South"; // South starting point
    //println("directionStart = " + directionStart);
  } else if (addr.equals("/1/multitoggle1/4/1")) { 
    directionStart = 3;
    direction = "West"; // West Starting point
  } else if (addr.equals("/2/toggle2")) {
    powerOn = val; // Check if power is on
  }


  // Prep our byte array
  out[0] = byte(byte(map(delayTime, 5.0, 30.0, 0, 127))); // map to byte range
  if (out[0] < 0) {
    // Set Initial Delay to something aroun 5 seconds
    out[0] = 12;
  }
  out[1] = byte(autoToggle);
  out[2] = byte(manualPush);
  out[3] = byte(directionStart);


  if (powerOn>0) {
    setInterfaceControlElements(); // if the power is on, update the labels
  } else {
    // If the power is off, set the starting index out of bounds!!
    out[3] = 5;
    
    // Put the label over EVERYTHING so user can't interact
    OscMessage bigPowerOffLabelVisibility = new OscMessage("/1/label5/visible");
    bigPowerOffLabelVisibility.add(1);
    oscP5.send(bigPowerOffLabelVisibility, iPhone);

    OscMessage smallPowerLabel = new OscMessage("/2/power");
    smallPowerLabel.add("Power Off");
    oscP5.send(smallPowerLabel, iPhone);
  }
  
  // Send everything to the Arduino
  wayfindingArduino.write(out);
}

void draw() {
  
  // First time loop
  if (firstRun) {      
    OscMessage powerOn = new OscMessage("/2/toggle2/value");
    powerOn.add(1);
    oscP5.send(powerOn, iPhone);

    OscMessage bigPowerOffLabelVisibility = new OscMessage("/1/label5/visible");
    bigPowerOffLabelVisibility.add(0);
    oscP5.send(bigPowerOffLabelVisibility, iPhone);

    OscMessage startingDirectionValue = new OscMessage("/1/multitoggle1/" + (int)(directionStart + 1) + "/1");
    startingDirectionValue.add(1);
    oscP5.send(startingDirectionValue, iPhone);
  }
}