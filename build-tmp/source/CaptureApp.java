import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.video.*; 
import controlP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class CaptureApp extends PApplet {




final int WIDTH = 640;
final int HEIGHT = 480;
final float SCRUB_STEP = 0.02f;

Movie mov;
ControlP5 cp5;
Slider abc;

float video_position = 0;

boolean bPlay = false;;
boolean bMousePressed = false;

public void setup() {
  size(WIDTH, HEIGHT + 60);
}

public void draw() {
  background(80);
  if (mov != null) {
    if (mov.available()) {
      mov.read();
      if (!bMousePressed) {
        cp5.getController("video_position").setValue(mov.time());
      }
    }  
    image(mov, 0, 0);

    text("duration: " + mov.duration(), 20, HEIGHT + 30);
    text("time    : " + mov.time(), 20, HEIGHT + 46);
  }
}

public void keyPressed() {
  if (key == CODED) {
    if (keyCode == LEFT)  previousTime(SCRUB_STEP);
    if (keyCode == RIGHT) nextTime(SCRUB_STEP);
  } else {
    switch (key) {
      case 'l': 
      if (mov == null) {
        selectInput("Select a file to process:", "fileSelected");
      } else {
        println("Already loaded, please restart app");
      }
      break;

      case ' ':
      if (isVideoEnded()) {
        mov.jump(0);
        mov.play();
        bPlay = true;
      } else {
        if (bPlay) {
          mov.pause();
          bPlay = false;
        } else {
          mov.play();
          bPlay = true;
        }
      }
      break;
    }
  }
}

public void mousePressed(){
  bMousePressed = true;
  if (mov != null && bPlay) {
    mov.pause();
  }
}

public void mouseReleased() {
  bMousePressed = false;
  if (mov != null) {
    mov.jump(video_position);
    if (bPlay) {
      mov.play();
    } else {
      mov.play();
      mov.pause();
    }
  }  
}

public void fileSelected(File file) {
  if (file == null) return;
  println(file);
  mov = new Movie(this, file.getPath());
  mov.play();
  mov.noLoop();
  bPlay = true;

  cp5 = new ControlP5(this);
  cp5.addSlider("video_position")
    .setPosition(10, HEIGHT+10)
    .setWidth(WIDTH-120)
    .setRange(0, mov.duration())
    ;
}

public boolean isVideoEnded() {
  if (mov == null) {
    println("null");
    return false;
  }
  if (mov.duration() == mov.time()) {
    return true;
  } else return false;
}

public void previousTime(float t) {
  if (mov == null) return;
  if (!bPlay) {
    float current = mov.time();
    mov.play();
    mov.jump(current - t);
    mov.pause();
  }
}

public void nextTime(float t) {
  if (mov == null) return;
  if (!bPlay) {
    float current = mov.time();
    mov.play();
    mov.jump(current + t);
    mov.pause();
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "CaptureApp" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
