

---

# FIN Control Rocket and Ground Control Software - Version 1

Welcome to the first version of the Ground Control Software. This version introduces enhanced functionalities and improvements for real-time control and monitoring of rocket flight dynamics. This document provides a comprehensive overview and detailed explanation of the code, installation instructions, and usage guidelines.

## Table of Contents
1. [Overview](#overview)
2. [Key Features](#key-features)
3. [Detailed Code Explanation](#detailed-code-explanation)
    - [Imports and Dependencies](#imports-and-dependencies)
    - [Global Variables](#global-variables)
    - [Setup Function](#setup-function)
    - [Camera Control Functions](#camera-control-functions)
    - [Draw Function](#draw-function)
    - [Event Handling](#event-handling)
    - [Time Display Function](#time-display-function)
    - [Utility Functions](#utility-functions)
4. [Installation and Usage](#installation-and-usage)
    - [Prerequisites](#prerequisites)
    - [Setup](#setup)
5. [Contributions](#contributions)
6. [License](#license)
7. [Contact](#contact)

## Overview

This software is designed to monitor and control the roll, pitch, and yaw of a rocket using serial communication with a microcontroller. It provides real-time data visualization from accelerometers and gyroscopes, along with an integrated camera control interface for comprehensive monitoring of the rocket's orientation and stability.

## Key Features
- Real-time visualization of roll, pitch, and yaw angles.
- Monitoring of accelerometer and gyroscope data.
- Integrated camera control for visual monitoring.
- Interactive buttons for starting and stopping the camera.
- Graphical representation of historical data for better analysis.

## Detailed Code Explanation

### Imports and Dependencies

```java
import processing.serial.*;
import java.util.ArrayList;
import controlP5.*;
import processing.video.*;
import java.util.Calendar;
```

- **`processing.serial.*`**: Handles serial communication between the software and the microcontroller.
- **`java.util.ArrayList`**: Manages dynamic arrays to store historical data for various sensors.
- **`controlP5.*`**: Provides a GUI library for creating interactive elements like buttons.
- **`processing.video.*`**: Manages video capture from an attached camera.
- **`java.util.Calendar`**: Retrieves and displays the current date and time.

### Global Variables

```java
Serial SerialPort;
String SerialPortName = "COM6";

float Roll, Pitch, Yaw;
float AccX, AccY, AccZ;
float GyroX, GyroY, GyroZ;

ControlP5 cp5;
Capture cam;
boolean cameraOn = false;
int camWidth = 590;
int camHeight = 380;
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

int HistoryLength = 200;
float StartTime;
```

- **Serial Communication**: `SerialPort` and `SerialPortName` manage the serial port communication.
- **Orientation Data**: Variables like `Roll`, `Pitch`, `Yaw`, `AccX`, `AccY`, `AccZ`, `GyroX`, `GyroY`, `GyroZ` store real-time data from the sensors.
- **GUI and Camera**: `cp5` for ControlP5 GUI elements, `cam` for camera capture, `cameraOn` to track camera status, `camWidth` and `camHeight` for camera dimensions, `pfont` for custom fonts.
- **Historical Data**: Arrays like `RollHistory`, `PitchHistory`, `YawHistory`, `AccXHistory`, `AccYHistory`, `AccZHistory`, `GyroXHistory`, `GyroYHistory`, `GyroZHistory` store historical sensor data.
- **Miscellaneous**: `HistoryLength` limits the data history size, `StartTime` tracks the program's start time.

### Setup Function

```java
void setup(){
    size(1900, 980);
    background(0);
    surface.setTitle("FIN CONTROL ROCKET SOFTWARE V3");
    SerialPort = new Serial(this, SerialPortName, 230400);
    noStroke();
    StartTime = millis() / 1000.0;
    textFont(createFont("Arial", 16));

    pfont = createFont("Arial", 20);

    cp5 = new ControlP5(this);

    cp5.addButton("startCamera")
       .setPosition(350, 350)
       .setSize(200, 50)
       .setLabel("Start Camera")
       .setColorBackground(color(0, 255, 0))
       .setColorForeground(color(0, 200, 0))
       .setColorActive(color(0, 150, 0))
       .getCaptionLabel().setFont(pfont).setSize(20).setColor(color(255, 255, 255));

    cp5.addButton("stopCamera")
       .setPosition(720, 350)
       .setSize(200, 50)
       .setLabel("Stop Camera")
       .setColorBackground(color(255, 0, 0))
       .setColorForeground(color(200, 0, 0))
       .setColorActive(color(150, 0, 0))
       .getCaptionLabel().setFont(pfont).setSize(20).setColor(color(255, 255, 255));
}
```

- **Window Setup**: Sets the window size and background color, and initializes the serial port.
- **Font and GUI Initialization**: Creates a font and initializes ControlP5 GUI elements.
- **Button Configuration**: Configures buttons for starting and stopping the camera with custom styles.

### Camera Control Functions

```java
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
```

- **`startCamera()`**: Starts the camera if it is not already on, checking available cameras and initializing the capture.
- **`stopCamera()`**: Stops the camera if it is currently on.

### Draw Function

```java
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

                if (RollHistory.size() > HistoryLength) {
                    RollHistory.remove(0);
                    PitchHistory.remove(0);
                    YawHistory.remove(0);
                }

                if (AccXHistory.size() > HistoryLength) {
                    AccXHistory.remove(0);
                    AccYHistory.remove(0);
                    AccZHistory.remove(0);
                }

                if (GyroXHistory.size() > HistoryLength) {
                    GyroXHistory.remove(0);
                    GyroYHistory.remove(0);
                    GyroZHistory.remove(0);
                }
            }
        }
    }

    showTime();
    Draw_Heading();
    drawGraph(RollHistory, color(255, 0, 0), 20, 65, "Body Orientation X");
    drawGraph(PitchHistory, color(0, 255, 0), 330, 65, "Body Orientation Y");
    drawGraph(YawHistory, color(0, 0, 255), 640, 65, "Body Orientation Z");
    DrawMeter(Roll, 1100, 190, "Roll");
    DrawMeter(Pitch, 1410, 190, "Pitch");
    DrawMeter(Yaw, 1720, 450, "Yaw");
    AccelerometerGraph();
    GyroGraph();
    FrameOne();
    FrameTwo();

    if (cameraOn) {
        if (cam.available() == true) {
            cam.read();
        }
        image(cam,

 20, 450, camWidth, camHeight);
    }
}
```

- **Background**: Clears the background for each frame.
- **Serial Data Processing**: Reads and parses serial data, updating orientation, accelerometer, and gyroscope values.
- **Historical Data Management**: Maintains history arrays for plotting graphs.
- **Display Elements**: Calls various functions to display time, headings, graphs, meters, and frames.
- **Camera Display**: Displays the camera feed if the camera is on.

### Event Handling

```java
void keyPressed() {
    if (key == 'q' || key == 'Q') {
        exit();
    }
}
```

- **`keyPressed()`**: Exits the program when the 'q' key is pressed.

### Time Display Function

```java
void showTime() {
    Calendar now = Calendar.getInstance();
    String Time = String.format("%02d:%02d:%02d", now.get(Calendar.HOUR_OF_DAY), now.get(Calendar.MINUTE), now.get(Calendar.SECOND));
    String Date = String.format("%02d/%02d/%04d", now.get(Calendar.DAY_OF_MONTH), now.get(Calendar.MONTH) + 1, now.get(Calendar.YEAR));
    textFont(pfont);
    textSize(40);
    fill(255);
    textAlign(CENTER, CENTER);
    text("Date: " + Date, 1590, 100);
    text("Time: " + Time, 1590, 200);
}
```

- **`showTime()`**: Retrieves and displays the current date and time.

### Utility Functions

- **`Draw_Heading()`**, **`drawGraph()`**, **`DrawMeter()`**, **`AccelerometerGraph()`**, **`GyroGraph()`**, **`FrameOne()`**, **`FrameTwo()`**: Functions to draw headings, graphs, meters, and frames on the screen.

## Installation and Usage

### Prerequisites
- Processing IDE
- ControlP5 library
- Processing Video library
- Compatible camera for video capture
- Microcontroller for serial data transmission

### Setup
1. **Clone this repository**:
   ```bash
   git clone https://github.com/PIEspace/FIN-Control-Rocket-Software-V1.git
   ```
2. **Open the project** in the Processing IDE.
3. **Install necessary libraries** via the Processing Library Manager.
4. **Connect your microcontroller** and set the correct serial port in the code:
   ```java
   String SerialPortName = "COM7"; // Update with your serial port
   ```
5. **Run the program**.

## Contributions

We welcome contributions to this project! Feel free to submit issues or pull requests. All contributions are appreciated and will help improve the software.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

For any inquiries or support, please contact [your.pie.space12@gmail.com](mailto:your.pie.space12@gmail.com).

---

This `README.md` file is now more detailed and professional, providing clear instructions and explanations for users to understand, install, and use the software effectively.
