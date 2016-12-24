import processing.serial.*;

Serial myPort;                       // The serial port
int[] serialInArray = new int[4];    // Where we'll put what we receive
int serialCount = 0;                 // A count of how many bytes we receive
boolean firstContact = false;        // Whether we've heard from the microcontroller
int n, e, s, w;

PFont titles;
PFont orientationDisplay;
PFont orientationDisplayNumerals;
PFont latLonText;
PFont display12pt;
PFont gaugeNumerals;
String[] heatMapLabels = {"N", "E", "S", "W"};
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
final boolean SENSOR_MODE = false;

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
  println(width, height);
  smooth(3);
  colorMode(HSB);


  titles = createFont("helvetica-neue-bold.ttf", 20, true);
  orientationDisplay = createFont("helvetica-neue-bold.ttf", 40, true);
  orientationDisplayNumerals = createFont("helvetica-neue-light.ttf", 60, true);
  latLonText = createFont("helvetica-neue-roman.ttf", 16, true);
  gaugeNumerals = createFont("helvetica-neue-roman.ttf", 36, true);
  display12pt = createFont("helvetica-neue-roman.ttf", 12, true);

  renderDisplay();
  displayOrientation();
  displayHeatMap();
  displayProximities();
  displaySpatialProximityAnalysis();
}

void draw() {
  noStroke();
  boolean hasRun = false;
  if (frameCount % 300 == 0) {
    m.updateTimeStamps();
    m.readVals();
    renderDisplay();
    displayHeatMap();
    displayOrientation();
    displayProximities();
    displaySpatialProximityAnalysis();
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
  float currentAvgPulseVal = map(m.getAverage(), 0, MAX_DISTANCE, 5, 30);

  stroke(YELLOW);
  strokeWeight(4);
  strokeCap(SQUARE);
  noFill();
  arc(width*GAUGE_X_PROP + (width*0.1944444444)/2, height*Y_MARGIN_PROP + 70, 180, 180, -PI, 0);
  strokeWeight(15);
  arc(width*GAUGE_X_PROP + (width*0.1944444444)/2, height*Y_MARGIN_PROP + 70, 180, 180, -PI/currentAvgPiVal, 0);
  strokeWeight(2);
  line(width*GAUGE_X_PROP + (width*0.3138888889)/1.92, height*Y_MARGIN_PROP + (height*0.265625)/2 + 40, 
    width*GAUGE_X_PROP + (width*0.3138888889)/1.92 + cos(-PI/currentAvgPiVal) * 60, 
    height*Y_MARGIN_PROP + (height*0.265625)/2 + 60 + sin(-PI/currentAvgPiVal) * 90); 

  strokeWeight(4);
  stroke(PURPLE);
  arc(width*GAUGE_X_PROP + (width*0.1944444444)/2, height*AGGREGATE_Y_PROP + 70, 180, 180, -PI, 0);
  strokeWeight(15);
  arc(width*GAUGE_X_PROP + (width*0.1944444444)/2, height*AGGREGATE_Y_PROP + 70, 180, 180, -PI/5, 0);
  strokeWeight(2);
  line(width*GAUGE_X_PROP + (width*0.3138888889)/1.92, height*AGGREGATE_Y_PROP + (height*0.265625)/2 + 40, 
    width*GAUGE_X_PROP + (width*0.3138888889)/1.92 + cos(-PI/5) * 60, 
    height*AGGREGATE_Y_PROP + (height*0.265625)/2 + 60 + sin(-PI/5) * 90); 

  noStroke();
  ellipseMode(CENTER);
  fill(YELLOW);
  ellipse(width*GAUGE_X_PROP + (width*0.3138888889)/1.92, height*Y_MARGIN_PROP + (height*0.265625)/2 + 40, 8, 8);
  fill(PURPLE);
  ellipse(width*GAUGE_X_PROP + (width*0.3138888889)/1.92, height*AGGREGATE_Y_PROP + (height*0.265625)/2 + 40, 8, 8);


  fill(255);
  textFont(gaugeNumerals, 36);
  textAlign(CENTER);
  text(""+nf(m.getAverage(), 0, 2)+" cm", width*GAUGE_X_PROP + (width*0.3138888889)/1.92, height*Y_MARGIN_PROP + (height*0.265625)/2 + 80);
  text("310.25 FT", width*GAUGE_X_PROP + (width*0.3138888889)/1.92, height*AGGREGATE_Y_PROP + (height*0.265625)/2 + 80);
  textFont(display12pt, 12);
  text(nf(currentAvgPulseVal, 0, 2) + " Second Pulse", width*GAUGE_X_PROP + (width*0.3138888889)/1.92, height*Y_MARGIN_PROP + (height*0.265625)/2 + 100);
  text("15.25 Second Pulse", width*GAUGE_X_PROP + (width*0.3138888889)/1.92, height*AGGREGATE_Y_PROP + (height*0.265625)/2 + 100);
}

void displayOrientation() {
  textAlign(CENTER);
  textFont(orientationDisplay, 40);

  fill(YELLOW);
  ellipseMode(CORNER);
  ellipse(width*ORIENTATION_X_PROP + 20, height*Y_MARGIN_PROP + 72, 73, 73);

  fill(PURPLE);
  ellipseMode(CORNER);
  ellipse(width*ORIENTATION_X_PROP + 20, height*AGGREGATE_Y_PROP + 72, 73, 73);

  fill(0);
  text(m.getCurrentDirection(), width*ORIENTATION_X_PROP + 20 + (73/2), height*Y_MARGIN_PROP + 70 + (73/1.35));
  text("E", width*ORIENTATION_X_PROP + 20 + (73/2), height*AGGREGATE_Y_PROP + 70 + (73/1.35));

  fill(255);
  textAlign(LEFT);
  textFont(latLonText, 16);
  text("37°12’41” N 121°48’31” W", width*ORIENTATION_X_PROP + 20, height*Y_MARGIN_PROP + 70 + 110);
  text("37°09’17” N 121°46’28” W", width*ORIENTATION_X_PROP + 20, height*AGGREGATE_Y_PROP + 70 + 110);
  textFont(display12pt, 12);
  text("San Jose, CA", width*ORIENTATION_X_PROP + 20, height*Y_MARGIN_PROP + 70 + 130);
  text("San Jose, CA", width*ORIENTATION_X_PROP + 20, height*AGGREGATE_Y_PROP + 70 + 130);
  fill(155);
  text("Updated 5 seconds ago", width*ORIENTATION_X_PROP + 20, height*Y_MARGIN_PROP + 70 + 148);
  text("48 hours logged", width*ORIENTATION_X_PROP + 20, height*AGGREGATE_Y_PROP + 70 + 148);


  textFont(orientationDisplayNumerals, 60);
  fill(YELLOW);
  text(m.getCurrentOrientation()+"°", width*ORIENTATION_X_PROP + 20 + 90, height*Y_MARGIN_PROP + 128);

  fill(PURPLE);
  text("80°", width*ORIENTATION_X_PROP + 20 + 90, height*AGGREGATE_Y_PROP + 128);
}

void displayHeatMap() {
  fill(BLUE);
  rectMode(CORNER);

  textFont(display12pt, 12);
  textAlign(CENTER);

  float rx = 35;
  float cx = 80;

  float px=width*X_MARGIN_PROP + 50, py=height*HEATMAP_Y_PROP + 55;

  for (int i=0; i< 4; i++)
  {
    for (int j=0; j< 14; j++)
    {
      println("i = " + i + ", j = " + j);
      fill(BLUE, m.getHeatMapValue(i, j));
      rect(px + 15, py + 20, 80, 30);
      px += cx + 10;
      fill(255);
      text(m.getTimeStamp(j), px - cx/2.1, 845);
    }
    px =  width*X_MARGIN_PROP + 50;
    py += rx + 10;
    fill(255);
    println(py);
    text(heatMapLabels[i], width*X_MARGIN_PROP + 40, py);
  }
}

void displaySpatialProximityAnalysis() {
  noFill();
  strokeWeight(0.5);
  stroke(255, 40);
  ellipseMode(CENTER);
  for (int i = 0; i < 20; i++) {
    //ellipse(width*X_MARGIN_PROP + (width*SP_WIDTH_PROP/2), height*Y_MARGIN_PROP + (height*SP_HEIGHT_PROP/2) + 20, 360 - (i*20), 360 - (i*20));
  }
  noStroke();

  // EAST
  fill(TEAL, map(m.getEastVal(), 0, MAX_DISTANCE, 50, 255));
  int eastValArcSize = int(map(m.getEastVal(), 0, MAX_DISTANCE, 50, 360));
  arc(width*X_MARGIN_PROP + (width*SP_WIDTH_PROP/2), height*Y_MARGIN_PROP + (height*SP_HEIGHT_PROP/2) + 20, eastValArcSize, eastValArcSize, -PI/4, PI/4);
  //fill(TEAL, 120);
  //arc(width*X_MARGIN_PROP + (width*SP_WIDTH_PROP/2), height*Y_MARGIN_PROP + (height*SP_HEIGHT_PROP/2) + 20, 360, 360, -PI/4, PI/4);


  // SOUTH
  fill(TEAL, map(m.getSouthVal(), 0, MAX_DISTANCE, 50, 255));
  int southValArcSize = int(map(m.getSouthVal(), 0, MAX_DISTANCE, 50, 360));
  arc(width*X_MARGIN_PROP + (width*SP_WIDTH_PROP/2), height*Y_MARGIN_PROP + (height*SP_HEIGHT_PROP/2) + 20, southValArcSize, southValArcSize, PI/4, PI-PI/4);
  //fill(TEAL, 160);
  //arc(width*X_MARGIN_PROP + (width*SP_WIDTH_PROP/2), height*Y_MARGIN_PROP + (height*SP_HEIGHT_PROP/2) + 20, 300, 300, PI/4, PI-PI/4);


  // WEST
  fill(TEAL, map(m.getWestVal(), 0, MAX_DISTANCE, 50, 255));
  int westValArcSize = int(map(m.getWestVal(), 0, MAX_DISTANCE, 50, 360));
  arc(width*X_MARGIN_PROP + (width*SP_WIDTH_PROP/2), height*Y_MARGIN_PROP + (height*SP_HEIGHT_PROP/2) + 20, westValArcSize, westValArcSize, PI-PI/4, (TWO_PI-PI)+PI/4);
  //fill(TEAL, 70);
  //arc(width*X_MARGIN_PROP + (width*SP_WIDTH_PROP/2), height*Y_MARGIN_PROP + (height*SP_HEIGHT_PROP/2) + 20, 160, 160, PI-PI/4, (TWO_PI-PI)+PI/4);

  // NORTH
  fill(TEAL, map(m.getNorthVal(), 0, MAX_DISTANCE, 50, 255));
  int northValArcSize = int(map(m.getNorthVal(), 0, MAX_DISTANCE, 50, 360));
  arc(width*X_MARGIN_PROP + (width*SP_WIDTH_PROP/2), height*Y_MARGIN_PROP + (height*SP_HEIGHT_PROP/2) + 20, northValArcSize, northValArcSize, -PI/2-PI/4, -PI/4);
  //fill(TEAL, 130);
  //arc(width*X_MARGIN_PROP + (width*SP_WIDTH_PROP/2), height*Y_MARGIN_PROP + (height*SP_HEIGHT_PROP/2) + 20, 220, 220, TWO_PI-PI/2, TWO_PI);

  textFont(display12pt, 12);
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
      n = serialInArray[0];
      e = serialInArray[1];
      s = serialInArray[2];
      w = serialInArray[3];
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