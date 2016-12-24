import processing.serial.*;

Serial myPort;                       // The serial port
int[] serialInArray = new int[5];    // Where we'll put what we receive
int serialCount = 0;                 // A count of how many bytes we receive
boolean firstContact = false;        // Whether we've heard from the microcontroller
int n, e, s, w, interval;

PFont titles;
PFont orientationDisplay;
PFont orientationDisplayNumerals;
PFont latLonText;
PFont display16pt;
PFont display21pt;
PFont gaugeNumerals;
String[] heatMapLabels = {"W", "S", "E", "N"};
Model m;
float currentAverage;

final float Y_MARGIN_PROP = 0.0390625;
final float X_MARGIN_PROP = 0.02777777778;
final float SP_HEIGHT_PROP = 0.5703125;
final float SP_WIDTH_PROP = 0.3805555556;
final float GAUGE_X_PROP = 0.4361111111;
final float AGGREGATE_Y_PROP = 0.34375;
final float ORIENTATION_X_PROP = 0.7777777778;
final float HEATMAP_Y_PROP = 0.6484375;

final color YELLOW = #F0F465;
final color PURPLE = #AD79ED;
final color TEAL = #50C5B7;
final color BLUE = #6184D8;

final int MAX_DISTANCE = 200;
final boolean SENSOR_MODE = true;

void setup() {
  // Print a list of the serial ports for debugging purposes
  // if using Processing 2.1 or later, use Serial.printArray()
  //println(Serial.list());
  m = new Model(day(), hour(), minute(), second());
  if (SENSOR_MODE) {
    String portName = Serial.list()[3];
    myPort = new Serial(this, portName, 115200);
    m.setSensorMode(true);
  } else {
    m.setSensorMode(false);
  }
  fullScreen();
  smooth(3);
  colorMode(HSB);


  titles = createFont("helvetica-neue-bold.ttf", 20, true);
  orientationDisplay = createFont("helvetica-neue-bold.ttf", 72, true);
  orientationDisplayNumerals = createFont("helvetica-neue-light.ttf", 96, true);
  latLonText = createFont("helvetica-neue-roman.ttf", 30, true);
  gaugeNumerals = createFont("helvetica-neue-roman.ttf", 36, true);
  display16pt = createFont("helvetica-neue-roman.ttf", 16, true);
  display21pt = createFont("helvetica-neue-roman.ttf", 16, true);

  m.readVals();
  m.updateTimeStamps();
  renderDisplay();
  displayOrientation();
  displayHeatMap();
  displayProximities();
  displaySpatialProximityAnalysis();
}

void draw() {
  noStroke();
  boolean hasRun = false;
  renderDisplay();
  m.readVals();

  displayOrientation();
  displayProximities();
  displaySpatialProximityAnalysis();
  displayHeatMap();
  if (frameCount % 30 == 0) {

    m.updateTimeStamps();

    // displayHeatMap();
    //renderDisplay();
    //displayHeatMap();
    //displayOrientation();
    //displayProximities();
    //displaySpatialProximityAnalysis();
  }
}

void renderDisplay() {
  textAlign(LEFT);
  textFont(titles, 20);
  background(0);
  fill(255, 20);
  noStroke();
  // Draw Spaital Proximity Base
  rect(width*X_MARGIN_PROP, height*Y_MARGIN_PROP, width*SP_WIDTH_PROP, height*SP_HEIGHT_PROP);

  // Draw Currenty Proximity Base
  rect(width*GAUGE_X_PROP, height*Y_MARGIN_PROP, width*0.3138888889, height*0.265625);

  // Draw Aggregate Proximity Base
  rect(width*GAUGE_X_PROP, height*AGGREGATE_Y_PROP, width*0.3138888889, height*0.265625);

  // Draw Current Orientation Base
  rect(width*ORIENTATION_X_PROP, height*Y_MARGIN_PROP, width*0.1944444444, height*0.265625);

  // Draw Aggregate Orientation Base
  rect(width*ORIENTATION_X_PROP, height*AGGREGATE_Y_PROP, width*0.1944444444, height*0.265625);

  // Draw Heatmap Analysis Base
  rect(width*X_MARGIN_PROP, height*HEATMAP_Y_PROP, width*0.9444444444, (height - 3*(height*Y_MARGIN_PROP) - (height*SP_HEIGHT_PROP)));



  fill(255);
  text("Spatial Proximity Analysis", width*X_MARGIN_PROP + 20, height*Y_MARGIN_PROP + 40);
  text("Current Proximity", width*GAUGE_X_PROP + 20, height*Y_MARGIN_PROP + 40);
  text("Aggregate Proximity", width*GAUGE_X_PROP + 20, height*AGGREGATE_Y_PROP + 40);
  text("Current Orientation", width*ORIENTATION_X_PROP + 20, height*Y_MARGIN_PROP + 40);
  text("Aggregate Orientation", width*ORIENTATION_X_PROP + 20, height*AGGREGATE_Y_PROP + 40);
  text("Periodic Heat Map Analysis", width*X_MARGIN_PROP + 20, height*HEATMAP_Y_PROP + 40);
}

void displayProximities() {

  float currentAvgPiVal = map(m.getAverage(), 0, MAX_DISTANCE, 1, 3);
  float currentAvgPulseVal = map(m.getAverage(), 0, MAX_DISTANCE, 5, 18);

  float aggAvgPiVal = map(m.getAggregateAverage(), 0, MAX_DISTANCE, 1, 3);
  float aggAvgPulseVal = map(m.getAggregateAverage(), 0, MAX_DISTANCE, 5, 18);

  stroke(YELLOW);
  strokeWeight(4);
  strokeCap(SQUARE);
  noFill();
  arc(width*GAUGE_X_PROP + (width*0.1944444444)/2, height*Y_MARGIN_PROP + 70, 320, 320, -PI, 0);
  strokeWeight(15);
  arc(width*GAUGE_X_PROP + (width*0.1944444444)/2, height*Y_MARGIN_PROP + 70, 320, 320, -PI/currentAvgPiVal, 0);
  strokeWeight(2);
  line(width*GAUGE_X_PROP + (width*0.3138888889)/1.92, height*Y_MARGIN_PROP + (height*0.265625)/2 + 40, 
    width*GAUGE_X_PROP + (width*0.3138888889)/1.92 + cos(-PI/currentAvgPiVal) * 106, 
    height*Y_MARGIN_PROP + (height*0.265625)/2 + 60 + sin(-PI/currentAvgPiVal) * 110); 

  strokeWeight(4);
  stroke(PURPLE);
  arc(width*GAUGE_X_PROP + (width*0.1944444444)/2, height*AGGREGATE_Y_PROP + 70, 320, 320, -PI, 0);
  strokeWeight(15);
  arc(width*GAUGE_X_PROP + (width*0.1944444444)/2, height*AGGREGATE_Y_PROP + 70, 320, 320, -PI/aggAvgPiVal, 0);
  strokeWeight(2);
  line(width*GAUGE_X_PROP + (width*0.3138888889)/1.92, height*AGGREGATE_Y_PROP + (height*0.265625)/2 + 40, 
    width*GAUGE_X_PROP + (width*0.3138888889)/1.92 + cos(-PI/aggAvgPiVal) * 106, 
    height*AGGREGATE_Y_PROP + (height*0.265625)/2 + 60 + sin(-PI/aggAvgPiVal) * 110); 

  noStroke();
  ellipseMode(CENTER);
  fill(YELLOW);
  ellipse(width*GAUGE_X_PROP + (width*0.3138888889)/1.92, height*Y_MARGIN_PROP + (height*0.265625)/2 + 40, 20, 20);
  fill(PURPLE);
  ellipse(width*GAUGE_X_PROP + (width*0.3138888889)/1.92, height*AGGREGATE_Y_PROP + (height*0.265625)/2 + 40, 20, 20);


  fill(255);
  textFont(gaugeNumerals, 36);
  textAlign(CENTER);
  text(""+nf(m.getAverage(), 0, 2)+" cm", width*GAUGE_X_PROP + (width*0.3138888889)/1.92, height*Y_MARGIN_PROP + 295);
  text(""+nf(m.getAggregateAverage(), 0, 2) + " cm", width*GAUGE_X_PROP + (width*0.3138888889)/1.92, height*AGGREGATE_Y_PROP + 295);
  textFont(display21pt, 21);
  fill(155);
  text(nf(currentAvgPulseVal, 0, 2) + " Second Pulse", width*GAUGE_X_PROP + (width*0.3138888889)/1.92, height*Y_MARGIN_PROP + 330);
  text(nf(aggAvgPulseVal, 0, 2)+ " Second Pulse", width*GAUGE_X_PROP + (width*0.3138888889)/1.92, height*AGGREGATE_Y_PROP + 330);
}

void displayOrientation() {
  textAlign(CENTER);
  textFont(orientationDisplay, 72);

  fill(YELLOW);
  ellipseMode(CORNER);
  ellipse(width*ORIENTATION_X_PROP + 20, height*Y_MARGIN_PROP + 72, 180, 180);

  fill(PURPLE);
  ellipseMode(CORNER);
  ellipse(width*ORIENTATION_X_PROP + 20, height*AGGREGATE_Y_PROP + 72, 180, 180);

  fill(0);
  text(m.getCurrentDirection(), width*ORIENTATION_X_PROP + 112, height*Y_MARGIN_PROP + 190);
  text(m.getAggDirection(), width*ORIENTATION_X_PROP + 112, height*AGGREGATE_Y_PROP + 190);

  fill(255);
  textAlign(LEFT);
  textFont(latLonText, 30);
  text("37°12’41” N 121°48’23” W", width*ORIENTATION_X_PROP + 20, height*Y_MARGIN_PROP + 295);
  text("37°09’17” N 121°46’28” W", width*ORIENTATION_X_PROP + 20, height*AGGREGATE_Y_PROP + 295);
  textFont(display16pt, 16);
  text("San Jose, CA", width*ORIENTATION_X_PROP + 20, height*Y_MARGIN_PROP + 325);
  text("San Jose, CA", width*ORIENTATION_X_PROP + 20, height*AGGREGATE_Y_PROP + 325);
  fill(155);
  text("Updated 5 seconds ago", width*ORIENTATION_X_PROP + 20, height*Y_MARGIN_PROP + 345);

  int seconds = (int) (m.getTimeRunning() / 1000) % 60 ;
  int minutes = (int) ((m.getTimeRunning() / (1000*60)) % 60);
  int hours   = (int) ((m.getTimeRunning() / (1000*60*60)) % 24);
  if (hours > 0) {
    if (hours==1) {
      text("" + hours + " hour logged", width*ORIENTATION_X_PROP + 20, height*AGGREGATE_Y_PROP + 345);
    } else {
      text("" + hours + " hours logged", width*ORIENTATION_X_PROP + 20, height*AGGREGATE_Y_PROP + 345);
    }
    
  } else {
    text("" + minutes + " minutes logged", width*ORIENTATION_X_PROP + 20, height*AGGREGATE_Y_PROP + 345);
  }


  textFont(orientationDisplayNumerals, 96);
  fill(YELLOW);
  text(m.getCurrentOrientation()+"°", width*ORIENTATION_X_PROP + 240, height*Y_MARGIN_PROP + 200);

  fill(PURPLE);
  text(m.getAggOrientation() + "°", width*ORIENTATION_X_PROP + 240, height*AGGREGATE_Y_PROP + 200);
}

void displayHeatMap() {
  fill(BLUE);
  rectMode(CORNER);

  textFont(display16pt, 16);
  textAlign(CENTER);

  float rx = 70;
  float cx = 155;

  float px=width*X_MARGIN_PROP + 45, py=height*HEATMAP_Y_PROP + 55;

  for (int i=3; i >= 0; i--)
  {
    for (int j=13; j >= 0; j--)
    {
      fill(BLUE, map(m.getHeatMapValue(i, j), 0, 200, 255, 50));
      rect(px + 15, py + 15, 155, 70);
      px += cx + 10;
      fill(255);
      text(m.getTimeStamp(j), px - cx/2.1, 1350);
    }
    px =  width*X_MARGIN_PROP + 45;
    py += rx + 10;
    fill(255);
    text(heatMapLabels[i], width*X_MARGIN_PROP + 40, py-20);
  }
}

void displaySpatialProximityAnalysis() {
  noFill();
  strokeWeight(0.5);
  stroke(255, 10);
  ellipseMode(CENTER);
  for (int i = 0; i < 32; i++) {
    ellipse(width*X_MARGIN_PROP + (width*SP_WIDTH_PROP/2), height*Y_MARGIN_PROP + (height*SP_HEIGHT_PROP/2) + 20, 640 - (i*20), 640 - (i*20));
  }
  noStroke();

  // EAST
  fill(TEAL, map(m.getEastVal(), 0, MAX_DISTANCE, 50, 255));
  int eastValArcSize = int(map(m.getEastVal(), 0, MAX_DISTANCE, 50, 640));
  arc(width*X_MARGIN_PROP + (width*SP_WIDTH_PROP/2), height*Y_MARGIN_PROP + (height*SP_HEIGHT_PROP/2) + 20, eastValArcSize, eastValArcSize,  -PI/4, PI/4);


  // SOUTH
  fill(TEAL, map(m.getSouthVal(), 0, MAX_DISTANCE, 50, 255));
  int southValArcSize = int(map(m.getSouthVal(), 0, MAX_DISTANCE, 50, 640));
  arc(width*X_MARGIN_PROP + (width*SP_WIDTH_PROP/2), height*Y_MARGIN_PROP + (height*SP_HEIGHT_PROP/2) + 20, southValArcSize, southValArcSize,   PI/4, PI-PI/4);

  // WEST
  fill(TEAL, map(m.getWestVal(), 0, MAX_DISTANCE, 50, 255));
  int westValArcSize = int(map(m.getWestVal(), 0, MAX_DISTANCE, 50, 640));
  arc(width*X_MARGIN_PROP + (width*SP_WIDTH_PROP/2), height*Y_MARGIN_PROP + (height*SP_HEIGHT_PROP/2) + 20, westValArcSize, westValArcSize,   PI-PI/4, (TWO_PI-PI)+PI/4);
  
  
  // NORTH
  fill(TEAL, map(m.getNorthVal(), 0, MAX_DISTANCE, 50, 255));
  int northValArcSize = int(map(m.getNorthVal(), 0, MAX_DISTANCE, 50, 640));
  arc(width*X_MARGIN_PROP + (width*SP_WIDTH_PROP/2), height*Y_MARGIN_PROP + (height*SP_HEIGHT_PROP/2) + 20, northValArcSize, northValArcSize, -PI/2-PI/4, -PI/4);
  
  textFont(display16pt, 16);
  textAlign(CENTER);
  fill(255);
  text("South", width*X_MARGIN_PROP + (width*SP_WIDTH_PROP/2), height*Y_MARGIN_PROP + (height*SP_HEIGHT_PROP) - 30);

  pushMatrix();
  translate(width*X_MARGIN_PROP + width*SP_WIDTH_PROP - 40, height*Y_MARGIN_PROP + (height*SP_HEIGHT_PROP/2) + 20);
  rotate(HALF_PI);
  text("East", 0, 0);
  popMatrix();

  text("North", width*X_MARGIN_PROP + (width*SP_WIDTH_PROP/2), height*Y_MARGIN_PROP + 80);

  pushMatrix();
  translate(width*X_MARGIN_PROP + 40, height*Y_MARGIN_PROP + (height*SP_HEIGHT_PROP/2) + 20);
  rotate(-HALF_PI);
  text("West", 0, 0);
  popMatrix();
}

void serialEvent(Serial myPort) {
  println("we're in");
  // read a byte from the serial port:
  int inByte = myPort.read();
  // if this is the first byte received, and it's an A,
  // clear the serial buffer and note that you've
  // had first contact from the microcontroller.
  // Otherwise, add the incoming byte to the array:
  if (firstContact == false) {
    println("establishing first contact");
    if (inByte == 'A') {
      myPort.clear();          // clear the serial port buffer
      firstContact = true;     // you've had first contact from the microcontroller
      myPort.write('A');       // ask for more
    }
  } else {
    println("reading sensor vals");
    // Add the latest byte from the serial port to array:
    serialInArray[serialCount] = inByte;
    serialCount++;

    // If we have 4 bytes:
    if (serialCount > 3 ) {
      s = serialInArray[0];
      w = serialInArray[1];
      n = serialInArray[2];
      e = serialInArray[3];
      if (n==0) n = MAX_DISTANCE;
      if (e==0) e = MAX_DISTANCE;
      if (s==0) s = MAX_DISTANCE;
      if (w==0) w = MAX_DISTANCE;
      // print the values (for debugging purposes only):
      println(n + "\t" + e + "\t" + s + "\t" + w);
      m.setVals(n, e, s, w);
      // Send a capital A to request new sensor readings:
      myPort.write('A');
      // Reset serialCount:
      serialCount = 0;
    }
  }
}