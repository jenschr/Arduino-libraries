/*
 TFT Pong
 This example is for any Arduino with a ST7735 compatible TFT screen.
 It reads the value of analog inputs to move a rectangular platform
 on the x and y axes. The platform can intersect with a ball
 causing it to bounce. This code is adapted from Esplora TFT Pong.
 
 This example code is in the public domain.
 
 Created by Tom Igoe December 2012
 Modified 15 April 2013 by Scott Fitzgerald
 http://arduino.cc/en/Tutorial/EsploraTFTPong
 
 Updated for ST7735 compatible TFT's by Jens Chr Brynildsen, October 2013
 https://github.com/jenschr/Arduino-libraries
 
 Requires Adafruit's ST7735 library + GFX library
 https://github.com/adafruit/Adafruit-ST7735-Library
 https://github.com/adafruit/Adafruit-GFX-Library
 */

#include <Adafruit_GFX.h>    // Core graphics library
#include <Adafruit_ST7735.h> // Hardware-specific library
#include <SPI.h>

//#define sclk 13
//#define mosi 11
#define cs   10
#define dc   9
#define rst  8  // you can also connect this to the Arduino reset

Adafruit_ST7735 tft = Adafruit_ST7735(cs, dc, rst);

int xAxisPin = A0;
int yAxisPin = A1;
const int listSize = 10;
int avgArray [listSize] = {0,0,0,0,0,0,0,0,0,0}; // smoothing of x value

// variables for the position of the ball and paddle
int paddleX = 0;
int paddleY = 0;
int oldPaddleX, oldPaddleY;
int ballDirectionX = 1;
int ballDirectionY = 1;

int ballX, ballY, oldBallX, oldBallY;

long lastFrameTime;
long frameTimeAsMilliseconds;
long count;

void setup() {

  Serial.begin(9600);

  // initialize the display
  tft.initR(INITR_BLACKTAB);
  // set the background the black
  tft.fillScreen(ST7735_BLACK);
}

void loop() {
  // save the width and height of the screen
  int myWidth = tft.width();
  int myHeight = tft.height();
  
  Serial.println( analogRead( xAxisPin ) );
  // map the paddle's location to the joystick's position 
  paddleX = map( analogRead( xAxisPin ), 0, 1024, 0, myWidth) - 20/2; 
  paddleY = map( analogRead( yAxisPin ), 1024, 0, 0, myHeight) - 5/2; 

  // erase the previous position of the paddle if different from present
  if (oldPaddleX != paddleX || oldPaddleY != paddleY) {
    tft.fillRect(oldPaddleX, oldPaddleY, 20, 5, 0x000000);
  }

  // draw the paddle on screen, save the current position
  // as the previous.
  tft.fillRect(paddleX, paddleY, 20, 5, 0xffffff);
  oldPaddleX = paddleX;
  oldPaddleY = paddleY;

  moveBall();
  
  delayMicroseconds( count % 16383  );
  count++;
}


// this function determines the ball's position on screen
void moveBall() {
  // if the ball goes offscreen, reverse the direction:
  if (ballX > tft.width() || ballX < 0) {
    ballDirectionX = -ballDirectionX;
  }

  if (ballY > tft.height() || ballY < 0) {
    ballDirectionY = -ballDirectionY;
  }  

  // check if the ball and the paddle occupy the same space on screen
  if (inPaddle(ballX, ballY, paddleX, paddleY, 20, 5)) {
    ballDirectionY = -ballDirectionY;
  }

  // update the ball's position
  ballX += ballDirectionX;
  ballY += ballDirectionY;

  // erase the ball's previous position
  if (oldBallX != ballX || oldBallY != ballY) {
    tft.fillRect(oldBallX, oldBallY, 5, 5, 0x000000);
  }

  // draw the ball's current position
  tft.fillRect(ballX, ballY, 5, 5, 0xffff00);

  oldBallX = ballX;
  oldBallY = ballY;

}

// this function checks the position of the ball
// to see if it intersects with the paddle
boolean inPaddle(int x, int y, int rectX, int rectY, int rectWidth, int rectHeight) {
  boolean result = false;

  if ((x >= rectX && x <= (rectX + rectWidth)) && 
    (y >= rectY && y <= (rectY + rectHeight))) {
    result = true; 
  }

  return result;  
}
