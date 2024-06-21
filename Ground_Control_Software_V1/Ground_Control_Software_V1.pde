//HELLO EVERYONE THIS THE THIRD VERSION OF FIN CONTROL ROCKET AND GROUND CONTROL SOFTWARE 

//IN THIS SOFTWARE WE ARE DISCUSSING ABOUT THE MORE COMPLEX THING 

// define the heading 
// define the roll pitch and yaw graph


import processing.serial.*;
import java.util.ArrayList;
import controlP5.*;
import processing.video.*;
import java.util.Calendar;

//define the serial monitor 
Serial SerialPort ;
String SerialPortName = "COM6";

//define the roll , pitch and yaw values
float Roll , Pitch , Yaw ;
float AccX , AccY , AccZ ; //define the acclerometer values
float GyroX , GyroY , GyroZ; //define the gyroscope values 

//add the button 
ControlP5 cp5;
Capture cam;
boolean cameraOn = false;
int camWidth = 590; //define the camera width 
int camHeight = 380; //define the camera height 
PFont pfont;


ArrayList<Float> RollHistory = new ArrayList<>();
ArrayList<Float> PitchHistory = new ArrayList<>();
ArrayList<Float> YawHistory = new ArrayList<>();

ArrayList<Float> AccXHistory = new ArrayList<>();
ArrayList<Float> AccYHistory = new ArrayList<>();
ArrayList<Float> AccZHistory = new ArrayList<>();

ArrayList<Float> GyroXHistory = new ArrayList<>();
ArrayList<Float> GyroYHistory = new ArrayList<>();
ArrayList<Float> GyroZHistory = new ArrayList<>();


int HistoryLength = 200; //define the length of the graph 
float StartTime ;


void setup(){
  size(1900 , 980 ); //set the width is 1900px and height is 980px 
  background(0);
  surface.setTitle("FIN CONTROL ROCKET SOFTWARE V3");
  SerialPort = new Serial(this, SerialPortName, 230400);
  noStroke();
  StartTime = millis() / 1000.0;
  textFont(createFont("Arial", 16));
  
   // Load a custom font
  pfont = createFont("Arial", 20);

  // Initialize ControlP5
  cp5 = new ControlP5(this);
  
  // Create a more advanced button to start the camera
  cp5.addButton("startCamera")
     .setPosition(350, 350)
     .setSize(200, 50)
     .setLabel("Start Camera")
     .setColorBackground(color(0, 255, 0))
     .setColorForeground(color(0, 200, 0))
     .setColorActive(color(0, 150, 0))
     .getCaptionLabel().setFont(pfont).setSize(20).setColor(color(255, 255, 255));
  
  // Create a more advanced button to stop the camera
  cp5.addButton("stopCamera")
     .setPosition(720, 350)
     .setSize(200, 50)
     .setLabel("Stop Camera")
     .setColorBackground(color(255, 0, 0))
     .setColorForeground(color(200, 0, 0))
     .setColorActive(color(150, 0, 0))
     .getCaptionLabel().setFont(pfont).setSize(20).setColor(color(255, 255, 255));
  
}

void startCamera() {
  if (!cameraOn) {
    String[] cameras = Capture.list();
    if (cameras.length == 0) {
      println("There are no cameras available for capture.");
      exit();
    } else {
      cam = new Capture(this, camWidth, camHeight, cameras[0]);
      cam.start();
      cameraOn = true;
    }
  }
}

void stopCamera() {
  if (cameraOn) {
    cam.stop();
    cam = null;
    cameraOn = false;
  }
}


void draw(){
  background(0);
  
   if (SerialPort.available() > 0) {
    String data = SerialPort.readStringUntil('\n');
    if (data != null) {
      String[] angles = data.trim().split(",");
      if (angles.length == 9) {
        Roll = float(angles[0]);
        Pitch = float(angles[1]);
        Yaw = float(angles[2]);
        
        AccX = float(angles[3]);
        AccY = float(angles[4]);
        AccZ = float(angles[5]);
        
        GyroX = float(angles[6]);
        GyroY = float(angles[7]);
        GyroZ = float(angles[8]);
        
        
        RollHistory.add(Roll);
        PitchHistory.add(Pitch);
        YawHistory.add(Yaw);
        
        AccXHistory.add(AccX);
        AccYHistory.add(AccY);
        AccZHistory.add(AccZ);
        
        GyroXHistory.add(GyroX);
        GyroYHistory.add(GyroY);
        GyroZHistory.add(GyroZ);
        
        if(RollHistory.size() > HistoryLength){
          RollHistory.remove(0);
          PitchHistory.remove(0);
          YawHistory.remove(0);
        }
        
        if(AccXHistory.size() > HistoryLength){
          AccXHistory.remove(0);
          AccYHistory.remove(0);
          AccZHistory.remove(0);
          
        }
        
        if(GyroXHistory.size() > HistoryLength){
          GyroXHistory.remove(0);
          GyroYHistory.remove(0);
          GyroZHistory.remove(0);
        }
        
        
        
      }
      
    }
    
   }
  
  
  
  //calling the function 
  showTime();
  Draw_Heading();
  drawGraph(RollHistory, color(255, 0, 0), 20, 65, "Body Oriantation X");
  drawGraph(PitchHistory, color(0, 255, 0), 330, 65, "Body Oriantation Y");
  drawGraph(YawHistory, color(0, 0, 255), 640, 65, "Body Oriantation Z");
  DrawMeter(Roll, 1100, 190, "Roll");
  DrawMeter(Pitch, 1410, 190, "Pitch");
  DrawMeter(Yaw, 1720, 450, "Yaw");
  AccelerometerGraph();
  GyroGraph();
  FrameOne();
  FrameTwo();
  

  
  if(cameraOn){
    if(cam.available() == true){
      cam.read();
    }
    image(cam , 340 , 420);
  }
  
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isFrom("startCamera")) {
    startCamera();
  } else if (theEvent.isFrom("stopCamera")) {
    stopCamera();
  }
}

void showTime(){
  Calendar calendar = Calendar.getInstance();
  int year = calendar.get(Calendar.YEAR);
  int month = calendar.get(Calendar.MONTH) + 1;
  int day = calendar.get(Calendar.DAY_OF_MONTH);
  int hour = calendar.get(Calendar.HOUR_OF_DAY);
  int minute = calendar.get(Calendar.MINUTE);
  int second = calendar.get(Calendar.SECOND);
  
  //Define only date 
  String date = String.format("%02d/%02d/%d ", day , month , year);
  
  //define only ist time 
  String Time = String.format("%02d:%02d:%02d" , hour , minute , second);
  
  
  //define the logo
  fill(255);
  textSize(30);
  textAlign(LEFT , CENTER);
  text("PIE.SPACE" , 1590 , 80);
  
  //define the date
  fill(255);
  textSize(25);
  textAlign(LEFT , CENTER);
  text("Date : " + date , 1590 , 150);
  
  //define the time in IST 
  fill(255);
  textSize(25);
  textAlign(LEFT , CENTER);
  text("IST : " + Time , 1590 , 200);
  
  
}




void Draw_Heading(){
  fill(255);
  textSize(32);
  textAlign(CENTER , CENTER);
  text("FIN CONTROL ROCKET V3 " , width/2 , 20);
  stroke(255);
  line(width/2  -300, 50 , width/2 + 300 , 50);
}

void drawGraph(ArrayList<Float> data, color lineColor, int x, int y, String label) {
  stroke(255);
  strokeWeight(2);
  fill(32,32,32);
  rect(x, y, 300, 250 , 10);
  
  int graphLeft = x + 50;
  int graphRight = x + 280;
  int graphTop = y + 30;
  int graphBottom = y + 200;
  
  // Draw grid lines
  stroke(100);
  for (int i = 0; i <= 10; i++) {
    int ypos = (int)map(i, 0, 10, graphBottom, graphTop);
    line(graphLeft, ypos, graphRight, ypos);
  }
  
  // Draw axes
  stroke(255);
  line(graphLeft, graphTop, graphLeft, graphBottom);
  line(graphLeft, graphBottom, graphRight, graphBottom);

  // Draw graph data
  stroke(lineColor);
  strokeWeight(2);
  noFill();
  beginShape();
  for (int i = 0; i < data.size(); i++) {
    float xPos = map(i, 0, data.size() - 1, graphLeft, graphRight);
    float yPos = map(data.get(i), -90, 90, graphBottom, graphTop);
    vertex(xPos, yPos);
  }
  endShape();

  // Draw labels
  fill(255);
  textSize(15);
  textAlign(CENTER, CENTER);
  text(label, x + 150, y + 20);
  textAlign(CENTER, CENTER);
  text("Time (s)", x + 150, 300);

  // Draw degree labels
  textAlign(RIGHT, CENTER);
  for (int i = -90; i <= 90; i += 30) {
    float yPos = map(i, -90, 90, graphBottom, graphTop);
    pushMatrix();
    translate(graphLeft - 30, yPos);
    rotate(-HALF_PI);
    text(i + "°", 0, 0);
    popMatrix();
  }
  
  // Draw time labels
  textAlign(CENTER, CENTER);
  float currentTime = millis() / 1000.0 - StartTime;
  for (int i = 0; i <= 3; i++) {
    float timeLabel = currentTime - 3 + i;
    if (timeLabel >= 0) {
      float xPos = map(timeLabel, currentTime - 3, currentTime, graphLeft, graphRight);
      text(nf(timeLabel, 1, 1), xPos, graphBottom + 20);
    }
  }
}


void DrawMeter(float angle, int x, int y, String label) {
  int meterSize = 200;
  int boxWidth = 300;
  int boxHeight = 250;

  // Draw the rectangle box
  fill(32, 32, 32);
  stroke(255);
  strokeWeight(2);
  rect(x - boxWidth / 2, y - boxHeight / 2, boxWidth, boxHeight, 10);
  
  // Draw the gradient background
  for (int i = 0; i < boxHeight; i++) {
    stroke(32 + i * 0.5, 32 + i * 0.5, 32 + i * 0.5);
    line(x - boxWidth / 2, y - boxHeight / 2 + i, x + boxWidth / 2, y - boxHeight / 2 + i );
  }

  // Draw the artificial horizon
  pushMatrix();
  translate(x, y);
  rotate(radians(angle));
  noStroke();
  fill(100, 100, 255); // Sky color
  arc(0, 0, meterSize, meterSize, PI, TWO_PI);
  fill(150, 75, 0); // Ground color
  arc(0, 0, meterSize, meterSize, 0, PI);
  popMatrix();

  // Draw the meter inside the box with shadow
  fill(50);
  stroke(0, 0, 0, 50);
  strokeWeight(10);
  ellipse(x + 5, y + 5, meterSize, meterSize); // shadow effect
  stroke(255);
  strokeWeight(2);
  fill(50);
  ellipse(x, y, meterSize, meterSize);

  // Draw the label
  fill(255);
  textSize(20);
  textAlign(CENTER, CENTER);
  text(label + " Meter", x, y - meterSize / 2 - 20);

  // Draw the horizon line
  stroke(255, 255, 0);
  strokeWeight(2);
  line(x - meterSize / 2, y, x + meterSize / 2, y);

  // Draw the meter ticks
  noFill();
  stroke(255);
  strokeWeight(2);
  for (int i = -90; i <= 90; i += 10) {
    float tickAngle = map(i, -90, 90, PI, TWO_PI);
    float x1 = x + cos(tickAngle) * (meterSize / 2 - 20);
    float y1 = y + sin(tickAngle) * (meterSize / 2 - 20);
    float x2 = x + cos(tickAngle) * (meterSize / 2 - 10);
    float y2 = y + sin(tickAngle) * (meterSize / 2 - 10);
    line(x1, y1, x2, y2);
  }

  // Draw the degree labels
  fill(255);
  textSize(12);
  for (int i = -90; i <= 90; i += 30) {
    float labelAngle = map(i, -90, 90, PI, TWO_PI);
    float xPos = x + cos(labelAngle) * (meterSize / 2 - 30);
    float yPos = y + sin(labelAngle) * (meterSize / 2 - 30);
    text(i + "°", xPos, yPos);
  }

  // Draw the needle
  pushMatrix();
  translate(x, y);
  float meterAngle = map(angle, -90, 90, PI, TWO_PI);
  stroke(0);
  strokeWeight(6);
  line(0, 0, cos(meterAngle) * (meterSize / 2 - 20), sin(meterAngle) * (meterSize / 2 - 20));
  stroke(angle < -20 || angle > 20 ? color(255, 0, 0) : color(0, 255, 0)); // Change color based on critical angle
  strokeWeight(4);
  line(0, 0, cos(meterAngle) * (meterSize / 2 - 20), sin(meterAngle) * (meterSize / 2 - 20));
  
  // Draw the aircraft wings
  stroke(255);
  strokeWeight(3);
  line(-meterSize / 4, 0, meterSize / 4, 0);
  line(-meterSize / 4, -10, -meterSize / 4, 10);
  line(meterSize / 4, -10, meterSize / 4, 10);

  // Draw the pivot point
  fill(255, 0, 0);
  noStroke();
  ellipse(0, 0, 10, 10);
  
  popMatrix();
}


void drawCombinedAccelerometerGraph(ArrayList<Float> AccXHistory, ArrayList<Float> AccYHistory, ArrayList<Float> AccZHistory, int x, int y, String label) {
  int rectWidth = 300;
  int rectHeight = 250;

  stroke(255);
  strokeWeight(2);
  fill(32, 32, 32);
  rect(x, y, rectWidth, rectHeight, 10);

  int graphLeft = x + 40;
  int graphRight = x + 280;
  int graphTop = y + 30;
  int graphBottom = y + 200;

  // Draw grid lines
  stroke(100);
  for (int i = 0; i <= 10; i++) {
    int ypos = (int)map(i, 0, 10, graphBottom, graphTop);
    line(graphLeft, ypos, graphRight, ypos);
  }

  // Draw axes
  stroke(255);
  line(graphLeft, graphTop, graphLeft, graphBottom);
  line(graphLeft, graphBottom, graphRight, graphBottom);

  // Draw graph data for AccX
  stroke(color(255, 0, 0));
  strokeWeight(2);
  noFill();
  beginShape();
  for (int i = 0; i < AccXHistory.size(); i++) {
    float xPos = map(i, 0, AccXHistory.size() - 1, graphLeft, graphRight);
    float yPos = map(AccXHistory.get(i), -90, 90, graphBottom, graphTop);
    vertex(xPos, yPos);
  }
  endShape();

  // Draw graph data for AccY
  stroke(color(0, 255, 0));
  strokeWeight(2);
  noFill();
  beginShape();
  for (int i = 0; i < AccYHistory.size(); i++) {
    float xPos = map(i, 0, AccYHistory.size() - 1, graphLeft, graphRight);
    float yPos = map(AccYHistory.get(i), -90, 90, graphBottom, graphTop);
    vertex(xPos, yPos);
  }
  endShape();

  // Draw graph data for AccZ
  stroke(color(0, 0, 255));
  strokeWeight(2);
  noFill();
  beginShape();
  for (int i = 0; i < AccZHistory.size(); i++) {
    float xPos = map(i, 0, AccZHistory.size() - 1, graphLeft, graphRight);
    float yPos = map(AccZHistory.get(i), -90, 90, graphBottom, graphTop);
    vertex(xPos, yPos);
  }
  endShape();

  // Draw labels
  fill(255);
  textSize(15);
  textAlign(CENTER, CENTER);
  text(label, x + rectWidth / 2, y + 15);
  textAlign(CENTER, CENTER);
  text("Time (s)", x + rectWidth / 2, y + rectHeight - 10);

  // Draw degree labels
  textAlign(RIGHT, CENTER);
  for (int i = -90; i <= 90; i += 30) {
    float yPos = map(i, -90, 90, graphBottom, graphTop);
    pushMatrix();
    translate(graphLeft - 22, yPos);
    rotate(-HALF_PI);
    text(i + "°", 0, 0);
    popMatrix();
  }

  // Draw time labels
  textAlign(CENTER, CENTER);
  float currentTime = millis() / 1000.0 - StartTime;
  for (int i = 0; i <= 3; i++) {
    float timeLabel = currentTime - 3 + i;
    if (timeLabel >= 0) {
      float xPos = map(timeLabel, currentTime - 3, currentTime, graphLeft, graphRight);
      text(nf(timeLabel, 1, 1), xPos, graphBottom + 15);
    }
  }
}

void AccelerometerGraph() {
  drawCombinedAccelerometerGraph(AccXHistory, AccYHistory, AccZHistory, 20, 325, "Accelerometer (AccX, AccY, AccZ)");
}


void drawCombinedGyroscoperGraph(ArrayList<Float> GyroXHistory, ArrayList<Float> GyroYHistory, ArrayList<Float> GyroZHistory, int x, int y, String label) {
  int rectWidth = 300;
  int rectHeight = 250;

  stroke(255);
  strokeWeight(2);
  fill(32, 32, 32);
  rect(x, y, rectWidth, rectHeight, 10);

  int graphLeft = x + 40;
  int graphRight = x + 280;
  int graphTop = y + 30;
  int graphBottom = y + 200;

  // Draw grid lines
  stroke(100);
  for (int i = 0; i <= 10; i++) {
    int ypos = (int)map(i, 0, 10, graphBottom, graphTop);
    line(graphLeft, ypos, graphRight, ypos);
  }

  // Draw axes
  stroke(255);
  line(graphLeft, graphTop, graphLeft, graphBottom);
  line(graphLeft, graphBottom, graphRight, graphBottom);

  // Draw graph data for GyroX
  stroke(color(255, 0, 0));
  strokeWeight(2);
  noFill();
  beginShape();
  for (int i = 0; i < GyroXHistory.size(); i++) {
    float xPos = map(i, 0, GyroXHistory.size() - 1, graphLeft, graphRight);
    float yPos = map(GyroXHistory.get(i), -90, 90, graphBottom, graphTop);
    vertex(xPos, yPos);
  }
  endShape();

  // Draw graph data for GyroY
  stroke(color(0, 255, 0));
  strokeWeight(2);
  noFill();
  beginShape();
  for (int i = 0; i < GyroYHistory.size(); i++) {
    float xPos = map(i, 0, GyroYHistory.size() - 1, graphLeft, graphRight);
    float yPos = map(GyroYHistory.get(i), -90, 90, graphBottom, graphTop);
    vertex(xPos, yPos);
  }
  endShape();

  // Draw graph data for GyroZ
  stroke(color(0, 0, 255));
  strokeWeight(2);
  noFill();
  beginShape();
  for (int i = 0; i < GyroZHistory.size(); i++) {
    float xPos = map(i, 0, GyroZHistory.size() - 1, graphLeft, graphRight);
    float yPos = map(GyroZHistory.get(i), -90, 90, graphBottom, graphTop);
    vertex(xPos, yPos);
  }
  endShape();

  // Draw labels
  fill(255);
  textSize(15);
  textAlign(CENTER, CENTER);
  text(label, x + rectWidth / 2, y + 15);
  textAlign(CENTER, CENTER);
  text("Time (s)", x + rectWidth / 2, 825);

  // Draw degree labels
  textAlign(RIGHT, CENTER);
  for (int i = -90; i <= 90; i += 30) {
    float yPos = map(i, -90, 90, graphBottom, graphTop);
    pushMatrix();
    translate(graphLeft - 22, yPos);
    rotate(-HALF_PI);
    text(i + "°", 0, 0);
    popMatrix();
  }

  // Draw time labels
  textAlign(CENTER, CENTER);
  float currentTime = millis() / 1000.0 - StartTime;
  for (int i = 0; i <= 3; i++) {
    float timeLabel = currentTime - 3 + i;
    if (timeLabel >= 0) {
      float xPos = map(timeLabel, currentTime - 3, currentTime, graphLeft, graphRight);
      text(nf(timeLabel, 1, 1), xPos, graphBottom + 15);
    }
  }
}

void GyroGraph() {
  drawCombinedGyroscoperGraph(GyroXHistory, GyroYHistory, GyroZHistory, 20, 585, "Gyroscope (GyroX, GyroY, GyroZ)");
}


void FrameOne(){
  int RectWidth = 610;
  int RectHeight = 510;
  stroke(255);
  fill(32);
  rect(330 , 325 , RectWidth , RectHeight , 10);
}

void FrameTwo(){
  //*********************************************************************************************************************
  int RectWidth = 920 ;
  int RectHeight = 130;
  stroke(255);
  fill(32);
  rect(20 , 845 , RectWidth , RectHeight , 10);
  
  
  //*********************************************************************************************************************
  //define the roll  
  fill(255 , 0 , 0); //set the background color to red 
  int RollTextSize = 20;
  textSize(RollTextSize);
  int RollWidth = 100;
  int RollHeight = 900;
  text("Roll :- " +  Roll , RollWidth , RollHeight);
  
  //*********************************************************************************************************************
  //define the pitch values 
  fill(0,255,0); //set the background color to green 
  int PitchTextSize = 20;
  textSize(PitchTextSize);
  int PitchWidth = 100;
  int PitchHeight = 930;
  text("Pitch :- "+ Pitch , PitchWidth , PitchHeight);
  
  //*********************************************************************************************************************
  //define the yaw values 
  fill(0,0,255);
  int YawTextSize = 20;
  textSize(YawTextSize);
  int YawWidth = 100;
  int YawHeight = 960;
  text("Yaw :- " + Yaw , YawWidth , YawHeight);
  
  //*********************************************************************************************************************
  //define the label for roll , pitch and yaw 
  int SecondRectWidthOne = 200;
  int SecondRectHeightOne = 30;
  stroke(255);
  fill(0,0,255);
  rect(25 , 850 , SecondRectWidthOne , SecondRectHeightOne , 10);
  //*********************************************************************************************************************
  fill(255);
  int SecondFrameText = 20;
  textSize(SecondFrameText);
  int TextWidth = 125 ;
  int TextHeight = 865;
  text(" Roll , Pitch , Yaw " , TextWidth , TextHeight);
  
  
  //*********************************************************************************************************************
  //define the gyroscope 
  int SecondRectWidthTwo = 220;
  int SecondRectHeightTwo = 30;
  stroke(255);
  fill(0,0,255);
  rect(370 , 850 , SecondRectWidthTwo , SecondRectHeightTwo , 10);
  
  fill(255);
  int ThirdFrameText = 20;
  textSize(ThirdFrameText );
  int SecondTextWidth = 480 ;
  int SecondTextHeight = 865;
  text(" GyroX , GyroY , GyroZ " , SecondTextWidth , SecondTextHeight );
  
  //define the GyroX 
  fill(255 , 0 , 0); //fill the red color 
  int GyroXTextSize = 20;
  textSize(GyroXTextSize);
  int GyroXWidth = 450;
  int GyroXHeight = 900;
  text("GyroX :- " + GyroX , GyroXWidth , GyroXHeight);
  
  //Define the GyroY 
  fill(0,255,0); //fill the green color 
  int GyroYTextSize = 20;
  textSize(GyroYTextSize);
  int GyroYWidth = 450;
  int GyroYHeight = 930;
  text("GyroY :- " + GyroY , GyroYWidth , GyroYHeight);
  
  //define the GyroZ
  fill(0,0,255); //fill the blue color 
  int GyroZTextSize = 20;
  textSize(GyroZTextSize);
  int GyroZWidth = 450;
  int GyroZHeight = 960;
  text("GyroZ :- " + GyroZ , GyroZWidth , GyroZHeight);
  
  
  
  
  //*********************************************************************************************************************
  //define the acclerometer 
  int SecondRectWidthThree = 200;
  int SecondRectHeightThree = 30;
  stroke(255);
  fill(0,0,255);
  rect(735 , 850 , SecondRectWidthThree , SecondRectHeightThree , 10);
  
  fill(255);
  int FourthFrameText = 20;
  textSize(FourthFrameText );
  int ThirdTextWidth = 840 ;
  int ThirdTextHeight = 865;
  text(" AccX , AccY , AccZ " , ThirdTextWidth , ThirdTextHeight );
  
  //define the AccX 
  fill(255 , 0 , 0); //fill the red color 
  int AccXTextSize = 20;
  textSize(AccXTextSize);
  int AccXWidth = 820;
  int AccXHeight = 900;
  text("AccX :- " + AccX , AccXWidth , AccXHeight);
  
  //Define the AccY 
  fill(0,255,0); //fill the green color 
  int AccYTextSize = 20;
  textSize(AccYTextSize);
  int AccYWidth = 820;
  int AccYHeight = 930;
  text("AccY :- " + AccY , AccYWidth , AccYHeight);
  
  //define the AccZ
  fill(0,0,255); //fill the blue color 
  int AccZTextSize = 20;
  textSize(AccZTextSize);
  int AccZWidth = 820;
  int AccZHeight = 960;
  text("AccZ :- " + AccZ , AccZWidth , AccZHeight);
}
