import processing.video.*;
import controlP5.*;

final int WIDTH = 640;
final int HEIGHT = 480;
final int WIDTH_RATIO  = 3;
final int HEIGHT_RATIO = 2;

final String OUTPUT_DIR = "data/";

final float SCRUB_STEP = 0.02;

Movie mov;
ControlP5 cp5;
Slider abc;

float video_position = 0;

boolean bPlay = false;;
boolean bMousePressed = false;

int targetX = 0;
int targetY = 0;
int targetW = 60;
int targetH = 40;

int tmpMouseX = 0;

void setup() {
  size(WIDTH, HEIGHT + 60);
  rectMode(CORNER);
}

void draw() {
  targetX = mouseX - targetW;
  targetY = mouseY - targetH;

  background(80);
  if (mov != null) {
    if (mov.available()) {
      mov.read();
      if (!bMousePressed) {
        cp5.getController("video_position").setValue(mov.time());
      }
    }  
    fill(255, 255, 255);
    image(mov, 0, 0);

    noFill();
    stroke(0, 255, 0);
    strokeWeight(1);
    rect(targetX, targetY, targetW, targetH);
    if (bMousePressed) {
      fill(255, 0, 0);
      text("W:" + targetW + "H:" + targetH, targetX + 10, targetY - 10);
    }

    fill(255, 255, 255);
    text("duration: " + mov.duration(), 20, HEIGHT + 30);
    text("time    : " + mov.time(), 20, HEIGHT + 46);
    text("[l] key: load file", 180, HEIGHT + 30);
    text("[c] key: capture and save image", 180, HEIGHT + 46);
  }
}

void setTargetRectangleByWidth(int w) {
  targetW = w;
  targetH = floor(((float)targetW / (float)WIDTH_RATIO) * HEIGHT_RATIO);
  targetW = abs(targetW);
  targetH = abs(targetH);
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == LEFT)  previousTime(SCRUB_STEP);
    if (keyCode == RIGHT) nextTime(SCRUB_STEP);
  } else {
    switch (key) {
      case 'l': fileSelectInput(); break;
      case ' ': togglePlay(); break;
      case 'c': captureImage(targetX, targetY, targetW, targetH); break;
    }
  }
}

void mousePressed(){
  bMousePressed = true;
  if (mov != null && bPlay) {
    mov.pause();
  }
  tmpMouseX = mouseX - targetW;
}

void mouseReleased() {
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

void mouseDragged() {
  if (!cp5.isMouseOver()) {
    setTargetRectangleByWidth(mouseX - tmpMouseX);
  }
}

void fileSelected(File file) {
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

void fileSelectInput() {
  if (mov == null) {
    selectInput("Select a file to process:", "fileSelected");
  } else {
    println("Already loaded, please restart app");
  }
}

String getTimestamp() {
  String s = new String();
  s += "date";
  s += String.valueOf(nf(year(), 4));
  s += String.valueOf(nf(month(), 2));
  s += String.valueOf(nf(day(), 2));
  s += "_time";
  s += String.valueOf(nf(hour(), 2));
  s += String.valueOf(nf(minute(), 2));
  s += String.valueOf(nf(second(), 2));
  s += "_";
  s += String.valueOf(nf(millis(), 4));
  return s;
}

void captureImage(int x, int y, int w, int h) {
  if (mov == null) return;
  if (targetX < 0 || targetY < 0 || targetX+targetW > WIDTH || targetY+targetH > HEIGHT) {
    println("over the window");
    return;
  }
  PImage img = createImage(w, h, RGB);
  mov.loadPixels();
  img.loadPixels();
  for (int i = 0; i < img.pixels.length; ++i) {
    int getX = (i % w) + x;
    int getY = floor((float)i / (float)w) + y;
    img.pixels[i] = mov.get(getX, getY);
  }
  img.updatePixels();
  String savePath = OUTPUT_DIR + "capture_" + getTimestamp() + ".jpg";
  img.save(savePath);
  println("capture: " + savePath);
}

boolean isVideoEnded() {
  if (mov == null) {
    println("null");
    return false;
  }
  if (mov.duration() == mov.time()) {
    return true;
  } else return false;
}

void previousTime(float t) {
  if (mov == null) return;
  if (!bPlay) {
    float current = mov.time();
    mov.play();
    mov.jump(current - t);
    mov.pause();
  }
}

void nextTime(float t) {
  if (mov == null) return;
  if (!bPlay) {
    float current = mov.time();
    mov.play();
    mov.jump(current + t);
    mov.pause();
  }
}

void togglePlay() {
  if (mov == null) {
    fileSelectInput();
    return;
  }
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
}
