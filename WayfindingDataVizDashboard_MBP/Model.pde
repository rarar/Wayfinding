class Model {
  final int INTERVALS = 14;
  ArrayList<String> timeStamps = new ArrayList<String>();
  ArrayList<Float> northVals = new ArrayList<Float>();
  ArrayList<Float> eastVals = new ArrayList<Float>();
  ArrayList<Float> southVals = new ArrayList<Float>();
  ArrayList<Float> westVals = new ArrayList<Float>();
  int day, hour, min, sec;
  float northVal, eastVal, southVal, westVal = 200.0; 
  float runningAverage, currentOrientation = 0.00;
  String currentDirection = "N";
  Table data;
  boolean sensorMode = true;
  Model(int d, int h, int m, int s) {

    day = d;
    hour = h;
    min = m;
    sec = s;
    for (int i = 0; i < 14; i++) {
      timeStamps.add(hour+":"+nf(min, 1)+":"+nf(sec, 1));
      northVals.add(200.0);
      eastVals.add(200.0);
      southVals.add(200.0);
      westVals.add(200.0);
    }
    readVals();
  }

  void readVals() {
    if (!sensorMode) {
      northVal = random(0, 300);
      eastVal = random(0, 300);
      southVal = random(0, 300);
      westVal = random(0, 300);
    }
    runningAverage = (northVal + eastVal + southVal + westVal)/4;

    println("[N:" + northVal + "]" + "[E:" + eastVal + "]" + "[S:" + southVal + "]" + "[W:" + westVal + "]" + "Current Average:" + runningAverage +"]");
    float yCoor = northVal - southVal;
    float xCoor = eastVal - westVal;
    PVector sensorPoint = new PVector(xCoor, yCoor);
    //PVector sensorPoint = new PVector(-300, 0);
    PVector originPoint = new PVector(0, 300);
    currentOrientation = degrees(PVector.angleBetween(originPoint, sensorPoint));
    if (xCoor < 0) currentOrientation = 360 - currentOrientation;
    //currentOrientation = 360 - currentOrientation;
    println("x,y: (" + xCoor + "," + yCoor + ") and Angle is " + currentOrientation + "°");
    if (currentOrientation >= 23 && currentOrientation<=67) {
      println("NE");
      currentDirection = "NE";
    } else if (currentOrientation >= 68 && currentOrientation <= 112) {
      println("E");
      currentDirection = "E";
    } else if (currentOrientation >= 113 && currentOrientation <= 156) {
      println("SE");
      currentDirection = "SE";
    } else if (currentOrientation >= 157 && currentOrientation <= 201) {
      println("S");
      currentDirection = "S";
    } else if (currentOrientation >= 202 && currentOrientation <= 246) {
      println("SW");
      currentDirection = "SW";
    } else if (currentOrientation >= 247 && currentOrientation <= 291) {
      println("W");
      currentDirection = "W";
    } else if (currentOrientation >= 292 && currentOrientation <= 336) {
      println("NW");
      currentDirection = "NW";
    } else {
      println("N");
      currentDirection = "N";
    }
    // 23° - 67° NE
    // 68° - 112° E
    // 113° - 156° SE
    // 157° - 201° S
    // 202° - 246° SW
    // 247° - 291° W
    // 292° - 336° NW
    // 337° - 22° N
  }

  void updateTimeStamps() {
    // Update North Values
    northVals.add(northVal);
    northVals.remove(0);

    // Update East Values
    eastVals.add(eastVal);
    eastVals.remove(0);

    // Update South Values
    southVals.add(southVal);
    southVals.remove(0);

    // Update West Values
    westVals.add(westVal);
    westVals.remove(0);
    timeStamps.add(nf(hour(), 2)+":"+nf(minute(), 2)+":"+nf(second(), 2));
    timeStamps.remove(0);
    printArray(timeStamps);
  }

  void setVals(float n, float e, float s, float w) {
    northVal = n;
    eastVal = e;
    southVal = s;
    westVal = w;
  }

  String getTimeStamp(int i) {
    return timeStamps.get(i);
  }

  float getNorthVal() {
    return northVal;
  }

  float getEastVal() {
    return eastVal;
  }

  float getSouthVal() {
    return southVal;
  }

  float getWestVal() {
    return westVal;
  }

  float getAverage() {
    return runningAverage;
  }

  int getCurrentOrientation() {
    return (int)currentOrientation;
  }

  String getCurrentDirection() {
    return currentDirection;
  }

  float getHeatMapValue(int d, int i) {
    float val = 0;
    switch(d) {
    case 0:
      val = northVals.get(i);
      break;
    case 1:
      val = eastVals.get(i);
      break;
    case 2:
      val = southVals.get(i);
      break;
    case 3:
      val = westVals.get(i);
      break;
    }

    return val;
  }

  void setSensorMode(boolean m) {
    sensorMode = m;
  }
}