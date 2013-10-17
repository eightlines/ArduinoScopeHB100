/**
 * ArduinoScope implementation of the HB100 Doppler Motion Sensor
 * http://www.limpkin.fr/index.php?post/2013/08/09/Making-the-electronics-for-a-%247-USD-doppler-motion-sensor
 * Arduino requires Standard Firmata.ino script
 * VCC - 5V
 * GND - GND
 * FOUT - D2
 * VOUT - A0
 */

import controlP5.*;
import processing.serial.*;
import cc.arduino.*;
import arduinoscope.*;

Arduino arduino;
ControlP5 cp5;
Oscilloscope[] scopes = new Oscilloscope[2];
float[] multipliers = new float[2];

void setup() {
    size(800, 400);
    ControlP5 cp5 = new ControlP5(this);
    frame.setTitle("Arduinoscope");
  
    DropdownList com = cp5.addDropdownList("com").setPosition(110, 20).setSize(200,200);
    String[] arduinos = arduino.list();
    for (int i = 0; i < arduinos.length; i++) com.addItem(arduinos[i], i);
  
    int[] dim = {width - 130, height / scopes.length};
    
    for (int i = 0; i < scopes.length; i++) {
        int[] posv = new int[2];
        posv[0] = 0;
        posv[1] = dim[1] * i;
        scopes[i] = new Oscilloscope(this, posv, dim);
        scopes[i].setLine_color(color(255, 100, 255));
        cp5.addButton("pause" + i).setLabel("pause").setValue(0).setPosition(dim[0] + 10, posv[1] + 105).updateSize();

        if (i == 0) {
            scopes[i].setMinval(0);
            scopes[i].setMaxval(100);
            scopes[i].setMultiplier(1.0f);
        } else {
            scopes[i].setMultiplier(scopes[i].getMultiplier() / scopes[i].getResolution());
        }
    }
}

void draw() {
  background(0);
  text("arduinoscope", 20, 20);
  
  int val;
  int[] dim;
  int[] pos;
  
    for (int i = 0; i < scopes.length; i++) {
        dim = scopes[i].getDim();
        pos = scopes[i].getPos();
        scopes[i].drawBounds();
        stroke(255);
        line(0, pos[1], width, pos[1]);
        if (arduino != null) {
            val = (i == 0) ? (arduino.digitalRead(2) * 500) : arduino.analogRead(i);
            
            scopes[i].addData(val);
            scopes[i].draw();
            
            text(((i == 0) ? "digital " : "analog ") + i, dim[0] + 10, pos[1] + 30);
            text("val: " + (val * multipliers[i]) + "V", dim[0] + 10, pos[1] + 45);
            text("min: " + (scopes[i].getMinval() * multipliers[i]) + "V", dim[0] + 10, pos[1] + 60);
            text("max: " + (scopes[i].getMaxval() * multipliers[i]) + "V", dim[0] + 10, pos[1] + 75);
            text("mul: " + (scopes[i].getMultiplier()) + "f", dim[0] + 10, pos[1] + 90);
        }
    }
}

void controlEvent(ControlEvent e) {
    int val = int(e.getValue());
    println(e.getName());
    if (e.getName() == "com") {
        arduino = new Arduino(this, Arduino.list()[val], 57600);
        arduino.pinMode(2, Arduino.INPUT);
    } else {
        scopes[val].setPause(!scopes[val].isPause());
    }
}
