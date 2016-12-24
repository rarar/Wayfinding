class Model {
  final int INTERVALS = 14;
  ArrayList<String> timeStamps = new ArrayList<String>();
  ArrayList<Float> northVals = new ArrayList<Float>();
  ArrayList<Float> eastVals = new ArrayList<Float>();
  ArrayList<Float> southVals = new ArrayList<Float>();
  ArrayList<Float> westVals = new ArrayList<Float>();
  int day, hour, min, sec;
  float northVal, eastVal, southVal, westVal, avgNorth, avgEast, avgSouth, avgWest = 200.0;
  float initTime = 0.0;
  float runningAverage, currentOrientation, aggOrientation = 0.0;
  String currentDirection, aggDirection = "N";
  Table data;
  boolean sensorMode = true;
  boolean firstRun = true;

  Model(int d, int h, int m, int s) {
    data = loadTable("Wayfinding_Data_iPadPro.csv", "header");
    println(data.getRowCount() + " total rows in table");
    initTime = data.getFloat(data.getRowCount()-1, "time");
    println("time running = " + initTime);
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
      northVal = random(0, 200);
      eastVal = random(0, 200);
      southVal = random(0, 200);
      westVal = random(0, 200);
    }

    runningAverage = (northVal + eastVal + southVal + westVal)/4;

    println("[N:" + northVal + "]" + "[E:" + eastVal + "]" + "[S:" + southVal + "]" + "[W:" + westVal + "]" + "Current Average:" + runningAverage +"]");

    //float yCoor = northVal - southVal;
    //float xCoor = eastVal - westVal;
    //PVector sensorPoint = new PVector(xCoor, yCoor);
    ////PVector sensorPoint = new PVector(-300, 0);
    //PVector originPoint = new PVector(0, 300);
    //currentOrientation = degrees(PVector.angleBetween(originPoint, sensorPoint));
    //if (xCoor < 0) currentOrientation = 360 - currentOrientation;
    ////currentOrientation = 360 - currentOrientation;
    //println("x,y: (" + xCoor + "," + yCoor + ") and Angle is " + currentOrientation + "°");
    //if (currentOrientation >= 23 && currentOrientation<=67) {
    //  println("NE");
    //  currentDirection = "NE";
    //} else if (currentOrientation >= 68 && currentOrientation <= 112) {
    //  println("E");
    //  currentDirection = "E";
    //} else if (currentOrientation >= 113 && currentOrientation <= 156) {
    //  println("SE");
    //  currentDirection = "SE";
    //} else if (currentOrientation >= 157 && currentOrientation <= 201) {
    //  println("S");
    //  currentDirection = "S";
    //} else if (currentOrientation >= 202 && currentOrientation <= 246) {
    //  println("SW");
    //  currentDirection = "SW";
    //} else if (currentOrientation >= 247 && currentOrientation <= 291) {
    //  println("W");
    //  currentDirection = "W";
    //} else if (currentOrientation >= 292 && currentOrientation <= 336) {
    //  println("NW");
    //  currentDirection = "NW";
    //} else {
    //  println("N");
    //  currentDirection = "N";
    //}
    //// 23° - 67° NE
    //// 68° - 112° E
    //// 113° - 156° SE
    //// 157° - 201° S
    //// 202° - 246° SW
    //// 247° - 291° W
    //// 292° - 336° NW
    //// 337° - 22° N

    TableRow newRow = data.addRow();
    newRow.setFloat("time", initTime + millis());
    newRow.setFloat("north", northVal);
    newRow.setFloat("east", eastVal);
    newRow.setFloat("south", southVal);
    newRow.setFloat("west", westVal);
    saveTable(data, "data/Wayfinding_Data_iPadPro.csv");
    data = loadTable("Wayfinding_Data_iPadPro.csv", "header");
    float totalNorth = 0;
    float totalEast = 0;
    float totalSouth = 0;
    float totalWest = 0;
    for (TableRow row : data.rows()) {
      totalNorth+=row.getFloat("north");
      totalEast+=row.getFloat("east");
      totalSouth+=row.getFloat("south");
      totalWest+=row.getFloat("south");
    }
    avgNorth = totalNorth / data.getRowCount();
    avgEast = totalEast / data.getRowCount();
    avgSouth = totalSouth / data.getRowCount();
    avgWest = totalWest / data.getRowCount();


    currentOrientation = calculateAngle(northVal, eastVal, southVal, westVal);
    currentDirection = calculateCardinalDirection(currentOrientation);

    aggOrientation = calculateAngle(avgNorth, avgEast, avgSouth, avgWest);
    aggDirection = calculateCardinalDirection(aggOrientation);
  }

  float calculateAngle(float n, float e, float s, float w) {
    float yCoor = n - s;
    float xCoor = e - w;
    PVector sensorPoint = new PVector(xCoor, yCoor);
    //PVector sensorPoint = new PVector(-300, 0);
    PVector originPoint = new PVector(0, 300);
    float returnOrientation = degrees(PVector.angleBetween(originPoint, sensorPoint));
    if (xCoor < 0) returnOrientation = 360 - returnOrientation;
    println("x,y: (" + xCoor + "," + yCoor + ") and Angle is " + returnOrientation + "°");
    return returnOrientation;
  }


  String calculateCardinalDirection(float deg) {
    String dir = "N";
    if (deg >= 23 && deg<=67) {
      println("NE");
      dir = "NE";
    } else if (deg >= 68 && deg <= 112) {
      println("E");
      dir = "E";
    } else if (deg >= 113 && deg <= 156) {
      println("SE");
      dir = "SE";
    } else if (deg >= 157 && deg <= 201) {
      println("S");
      dir = "S";
    } else if (deg >= 202 && deg <= 246) {
      println("SW");
      dir = "SW";
    } else if (deg >= 247 && deg <= 291) {
      println("W");
      dir = "W";
    } else if (deg >= 292 && deg <= 336) {
      println("NW");
      dir = "NW";
    } else {
      println("N");
      dir = "N";
    }
    // 23° - 67° NE
    // 68° - 112° E
    // 113° - 156° SE
    // 157° - 201° S
    // 202° - 246° SW
    // 247° - 291° W
    // 292° - 336° NW
    // 337° - 22° N
    return dir;
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
    printArray(northVals);
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

  float getAggregateAverage() {

    return ((avgNorth + avgEast + avgSouth + avgWest) / 4);
  }

  int getCurrentOrientation() {
    return (int)currentOrientation;
  }

  String getCurrentDirection() {
    return currentDirection;
  }

  int getAggOrientation() {
    return (int)aggOrientation;
  }

  String getAggDirection() {
    return aggDirection;
  }


  float getTimeRunning() {
    return initTime + millis();
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