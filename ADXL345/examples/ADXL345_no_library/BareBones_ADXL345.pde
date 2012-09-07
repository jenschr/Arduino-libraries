/************************************************************************
* This program is free software; you can redistribute it and/or modify *
* it under the terms of the GNU License V2.                            *
* This program is distributed in the hope that it will be useful,      *
* but WITHOUT ANY WARRANTY; without even the implied warranty of       *
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        *
* GNU General Public License, version 2 for more details               *
*                                                                      *
* Bare bones ADXL345 i2c example for Arduino 1.0                       *
* by Jens C Brynildsen <http://www.flashgamer.com>                     *
* This version is not reliant of any external lib                      *
* (Adapted for Arduino 1.0 from http://code.google.com/p/adxl345driver)*
*                                                                      *
* Demonstrates use of ADXL345 (using the Sparkfun ADXL345 breakout)    *
* with i2c communication. Datasheet:                                   *
* http://www.sparkfun.com/datasheets/Sensors/Accelerometer/ADXL345.pdf *
* If you need more advanced features such as freefall and tap          *
* detection, check out:                                                *
* https://github.com/jenschr/Arduino-libraries                         *
***********************************************************************/

// Cabling for i2c using Sparkfun breakout with an Arduino Uno / Duemilanove:
// Arduino <-> Breakout board
// Gnd      -  GND
// 3.3v     -  VCC
// 3.3v     -  CS
// Analog 4 -  SDA
// Analog 5 -  SLC

// Cabling for i2c using Sparkfun breakout with an Arduino Mega / Mega ADK:
// Arduino <-> Breakout board
// Gnd      -  GND
// 3.3v     -  VCC
// 3.3v     -  CS
// 20       -  SDA
// 21       -  SLC

#include <Wire.h>

#define DEVICE (0x53) // Device address as specified in data sheet 

byte _buff[6];

char POWER_CTL = 0x2D;	//Power Control Register
char DATA_FORMAT = 0x31;
char DATAX0 = 0x32;	//X-Axis Data 0
char DATAX1 = 0x33;	//X-Axis Data 1
char DATAY0 = 0x34;	//Y-Axis Data 0
char DATAY1 = 0x35;	//Y-Axis Data 1
char DATAZ0 = 0x36;	//Z-Axis Data 0
char DATAZ1 = 0x37;	//Z-Axis Data 1

void setup()
{
  Wire.begin();        // join i2c bus (address optional for master)
  Serial.begin(57000);  // start serial for output. Make sure you set your Serial Monitor to the same!
  Serial.print("init");
  
  //Put the ADXL345 into +/- 4G range by writing the value 0x01 to the DATA_FORMAT register.
  writeTo(DATA_FORMAT, 0x01);
  //Put the ADXL345 into Measurement Mode by writing 0x08 to the POWER_CTL register.
  writeTo(POWER_CTL, 0x08);
}

void loop()
{
  readAccel(); // read the x/y/z tilt
  delay(500); // only read every 0,5 seconds
}

void readAccel() {
  uint8_t howManyBytesToRead = 6;
  readFrom( DATAX0, howManyBytesToRead, _buff); //read the acceleration data from the ADXL345

  // each axis reading comes in 10 bit resolution, ie 2 bytes.  Least Significat Byte first!!
  // thus we are converting both bytes in to one int
  int x = (((int)_buff[1]) << 8) | _buff[0];   
  int y = (((int)_buff[3]) << 8) | _buff[2];
  int z = (((int)_buff[5]) << 8) | _buff[4];
  Serial.print("x: ");
  Serial.print( x );
  Serial.print(" y: ");
  Serial.print( y );
  Serial.print(" z: ");
  Serial.println( z );
}

void writeTo(byte address, byte val) {
  Wire.beginTransmission(DEVICE); // start transmission to device 
  Wire.write(address);             // send register address
  Wire.write(val);                 // send value to write
  Wire.endTransmission();         // end transmission
}

// Reads num bytes starting from address register on device in to _buff array
void readFrom(byte address, int num, byte _buff[]) {
  Wire.beginTransmission(DEVICE); // start transmission to device 
  Wire.write(address);             // sends address to read from
  Wire.endTransmission();         // end transmission

  Wire.beginTransmission(DEVICE); // start transmission to device
  Wire.requestFrom(DEVICE, num);    // request 6 bytes from device

  int i = 0;
  while(Wire.available())         // device may send less than requested (abnormal)
  { 
    _buff[i] = Wire.read();    // receive a byte
    i++;
  }
  Wire.endTransmission();         // end transmission
}