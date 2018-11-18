import processing.serial.*;
import java.util.Scanner;
import java.util.Locale;

// Global variables
// PShape objects for loading scalable vector graphics
// The rotor of the electrical motor
PShape rotor;
// The stator of the electrical motor
PShape stator;
// The Infineon logo
PShape infineon;

// Handle the callback from the COM port and store it in this variable
String inString;

// The instances handling the magnetic sensor and the calculation of this application
TLx493D TLx493DInstance = new TLx493D();
TLx493DOutOfShaft TLx493DOutOfShaftInstance = new TLx493DOutOfShaft();
ComPortMenu portSelect = new ComPortMenu();;

// BUTTONS
int clickCount = 0; // so a button is activated only once per click
Label B0Min, B0Max, B1Min, B1Max, B0Off, B1Off, B1B0Amp, B1B0Angl, B1B0M_45, B1B0M_135, Q0Min, Q0Max, Angle;
Button  calibration, direction;

void setup(){
  // Set the locale
  Locale.setDefault(Locale.US);
  // Set up the canvas
  size(720, 720);
  frameRate(100);
  // Configure the side buttons/labels 
  setupButtons();
  // Load the vector graphics
  rotor = loadShape("rotor.svg");
  stator = loadShape("stator.svg");
  infineon = loadShape("infineon.svg");
  infineon.scale(0.2);
}

void draw(){
  background(40,40,45);
  // Position the graphics on the canvs
  shape(stator, 414, 265);
  shape(rotor, 406+rotor.width, 257+rotor.height);
  shape(infineon, 500, 50);

  // Display the interaction components and additional information
  displayButtons();
  portSelect.drawMenu();
  displayButtonLabels();
  displayTitle();
  displayButtonControlHeading();
  Serial comPort = portSelect.getComPort();
  
  // Handle the COM port selection
  if(comPort != null)
  {
    try
    {
      // Read form the serial port and transfer it into the TLx object for further processing
      // We expect here the three magnetic field values terminated by a new line character \n
      float buffer1 = 0, buffer2 = 0, buffer3 = 0;
      comPort.bufferUntil('\n');
      Scanner comInput = new Scanner(inString);
      comInput.useLocale(java.util.Locale.US);
      while(!comInput.hasNextFloat())
        comInput.next();
      buffer1  = comInput.nextFloat();     
      while(!comInput.hasNextFloat())
          comInput.next();
      buffer2 = comInput.nextFloat();
      while(!comInput.hasNextFloat())
      comInput.next();
      buffer3 = comInput.nextFloat();
      
      // Handle the TLx493DInstance
      TLx493DInstance.updateValues(buffer1, buffer2, buffer3);
      TLx493DInstance.transferValues();
      // Handle the out of shaft calculation
      if(direction.state == false){
        TLx493DOutOfShaftInstance.updateValuesAndCalculate(TLx493DInstance.getY(), TLx493DInstance.getZ());
      } else {
        TLx493DOutOfShaftInstance.updateValuesAndCalculate(TLx493DInstance.getX(), TLx493DInstance.getY());
      }
      
      // Reload the instance to reset rotation
      rotor = loadShape("rotor.svg");
      if(calibration.state == true){
        rotor.rotate(TLx493DOutOfShaftInstance.getAngleCompensated());
        // Display the angle circle with the current Angle depending on the position setting and compensation
        displayAngleCircle(TLx493DOutOfShaftInstance.getAngleCompensated());
        // Close the comInput scanner to avoid compiler troubles
      } else {
        rotor.rotate(TLx493DOutOfShaftInstance.getAngleUncompensated());
        // Display the angle circle with the current Angle depending on the position setting and compensation
        displayAngleCircle(TLx493DOutOfShaftInstance.getAngleUncompensated());
        // Close the comInput scanner to avoid compiler troubles        
      }
      comInput.close();
    }
    catch(Exception e)
    {
      System.err.print("Invalid COM input: ");
      System.err.println(inString);
      System.err.print("Original message: ");
      System.err.println(e.getMessage());
    }
  } else {
    // In case of no information, present the angle circle with phase 0
    displayAngleCircle(0);
  }
}

/*************************************************/
// Global generic functions
/*************************************************/
// When mouse gets pressed, this function will be fired
void mousePressed()
{
  portSelect.clickHandler();
}

void mouseReleased(){
  clickCount = 0;
}

// Display the labels of the buttons
void displayButtonLabels(){
  // x and y should match x and y in setupButtons();
  int x = 110;
  int y = 170;

  textSize(16);
  fill(255, 255);
  textAlign(LEFT, TOP);
  text("Calibration Parameters", x, y-30);

  stroke(255, 70);
  strokeWeight(1);
  line(x, y-9, x+220, y-9 );
}

void displayTitle(){
  int x = 110;
  int y = 50;

  textSize(30);
  textAlign(LEFT, TOP);
  fill(255, 255);
  textLeading(32);
  text("3D Magnetic Sensor\nOut of Shaft", x, y);
  fill(255, 0);
  text("3D Magnetic Sensor\nOut of Shaft", x+1, y);
  
  fill(255, 127);
  textSize(14);
  text("Infineon Technologies AG", x, y+67);
}

// Display the buttons itself
void displayButtons(){
  B0Min.parameter = nf(TLx493DOutOfShaftInstance.B0_min, 0, 2);
  B0Min.display();
  B0Max.parameter = nf(TLx493DOutOfShaftInstance.B0_max, 0, 2);
  B0Max.display();
  B1Min.parameter = nf(TLx493DOutOfShaftInstance.B1_min, 0, 2);
  B1Min.display();
  B1Max.parameter = nf(TLx493DOutOfShaftInstance.B1_max, 0, 2);
  B1Max.display();
  B0Off.parameter = nf(TLx493DOutOfShaftInstance.B0_offset, 0, 2);
  B0Off.display();
  B1Off.parameter = nf(TLx493DOutOfShaftInstance.B1_offset, 0, 2);
  B1Off.display();
  B1B0Amp.parameter = nf(TLx493DOutOfShaftInstance.B1_B0_amplitude, 0, 2);
  B1B0Amp.display();
  B1B0Angl.parameter = nf(TLx493DOutOfShaftInstance.B1_B0_angle, 0, 2);
  B1B0Angl.display();
  B1B0M_45.parameter = nf(TLx493DOutOfShaftInstance.M_45, 0, 2);
  B1B0M_45.display();
  B1B0M_135.parameter = nf(TLx493DOutOfShaftInstance.M_135, 0, 2);
  B1B0M_135.display();
  Q0Min.parameter = nf(TLx493DOutOfShaftInstance.Q0_min, 0, 2);
  Q0Min.display();
  Q0Max.parameter = nf(TLx493DOutOfShaftInstance.Q1_min, 0, 2);
  Q0Max.display();
  calibration.update();
  direction.update();
}

// Setup the buttons/labels of the canvas
void setupButtons(){
  int x = 110;
  int y = 170;
  int w = 130;
  int h = 30;
  int yGap = 32;
  int drawGap = 0;

  B0Min = new Label(x,y+yGap*0+drawGap, w, h, "B0 Minimum [mT]");
  B0Max = new Label(x, y+yGap*1+drawGap, w, h, "B0 Maximum [mT]");
  B1Min = new Label(x, y+yGap*2+drawGap, w, h, "B1 Minimum [mT]");
  B1Max = new Label(x, y+yGap*3+drawGap, w, h, "B1 Maximum [mT]");
  
  B0Off = new Label(x, y+yGap*4+drawGap, w, h, "B0 Offset [mT]");
  B1Off = new Label(x, y+yGap*5+drawGap, w, h, "B1 Offset [mT]");
  
  B1B0Amp = new Label(x, y+yGap*6+drawGap, w, h, "B1 B0 Amplitude");
  B1B0Angl = new Label(x, y+yGap*7+drawGap, w, h, "B1 B0 Angle [rad]");
  B1B0M_45 = new Label(x, y+yGap*8+drawGap, w, h, "M 45 [mT]");
  B1B0M_135 = new Label(x, y+yGap*9+drawGap, w, h, "M 135 [mT]");
  Q0Min = new Label(x, y+yGap*10+drawGap, w, h, "Q0 Minimum [mT]");
  Q0Max = new Label(x, y+yGap*11+drawGap, w, h, "Q1 Minimum [mT]");
  
  w = 50;
  
  calibration = new Button(x+300, y+yGap*14 + drawGap, w, h, "Calibration On/Off");
  calibration.state = false;
  calibration.onText = "On";
  calibration.offText = "Off";
  calibration.onOff = true;
  
  direction = new Button(x+300, y+yGap*15 + drawGap, w, h, "Direction Selection");
  direction.state = false;
  direction.onOff = true;
  direction.onText = "X-Y";
  direction.offText = "Z-X";


}

// Display the line on top of the control buttons
void displayButtonControlHeading(){
  float x = 410;
  float y = 640;
  float d = 60;
  
  textSize(16);
  textAlign(LEFT, CENTER);
  fill(255,255);
  text("Control Buttons", x, y - d/2 -35);
   
  stroke(255, 70);
  strokeWeight(1);
  line(x, y - d/2 - 24, x + 105, y - d/2 - 24); 
}

// Display a circle showing the current angle
void displayAngleCircle(float angle){
  float x = 163;
  float y = 640;
  float d = 60;
  
  textSize(16);
  textAlign(LEFT, CENTER);
  fill(255,255);
  text("Angle", 110, y - d/2 -35);
   
  stroke(255, 70);
  strokeWeight(1);
  line(110, y - d/2 - 24, 110+105, y - d/2 - 24);
  
  strokeWeight(1);
  stroke(255, 100);
  fill(255, 30);
  ellipseMode(CENTER);
  ellipse(x, y, d, d);
  
  // Tick marks
  strokeWeight(1);
  stroke(255, 100);
  float tick = 0.8;
  line(x, y-tick*d/2, x, y-d/2); // zero or two-pi (top of circle);
  line(x + tick*d/2, y, x+d/2, y); // pi/2
  line(x, y+tick*d/2, x, y+d/2);  // pi
  line(x- tick*d/2, y, x-d/2, y);  // 3pi/2
  
  textSize(12);
  fill(255, 150);
  textAlign(CENTER, CENTER);
  text("0", x+1, y -d/2 -10);
  // text("π/2", x+d/2 + 15, y-2);
  text("π", x, y + d/2 + 8);
  //text("3π/2", x-d/2-17, y-2);


  // 3pi/2 on two lines so it looks nicer
  text("3π", x-d/2-14, y-8);
  text("2", x-d/2-14, y+6);
  stroke(255, 100);
  strokeWeight(1);
  line(x-d/2-22, y, x-d/2-6, y);
  
  // pi/2 on two lines so it looks nicer
  text("π", x+d/2+12, y-8);
  text("2", x+d/2+12, y+6);
  stroke(255, 100);
  strokeWeight(1);
  line(x+d/2+18, y, x+d/2+6, y);
  
  // Indicating line...the vertical spacing will depend on how the font is rendered...can be iffy. 
  strokeWeight(2);
  stroke(255, 200);
  line(x, y, x+(d/2)*sin(angle), y-(d/2)*cos(angle));
  
  textSize(16);
  fill(255, 150);
  textAlign(CENTER, CENTER);
  text(nf(TLx493DOutOfShaftInstance.getAngleCompensated(), 0, 2) + " rad", x+d/2+80, y);
}
/*************************************************/

/*************************************************/
// Create and handle the serial communication plus selection menu
/*************************************************/
// The button of the COM port menu
class ComPortMenuButton
{
  private int mX;
  private int mY;
  private int mWidth;
  private int mHeight;
  private String mName;
  private boolean mIsActive;

  public ComPortMenuButton(int btnX, int btnY, int btnWidth, int btnHeight, String btnName)
  {
    mX = btnX;
    mY = btnY;
    mWidth = btnWidth;
    mHeight = btnHeight;
    mName = btnName;
    mIsActive = false;
  }

  boolean mouseOverBtn()
  {
    return (mouseX>mX && mouseX<mX+mWidth && mouseY>mY && mouseY<mY+mHeight);
  }

  public void drawButton()
  {
    fill(70);
    if (mIsActive)
    {
      fill(120, 80, 0);
    }
    if (mouseOverBtn())
    {
      fill(180, 120, 0);
    }
    rect(mX, mY, mWidth, mHeight);
    fill(255);
    textAlign(CENTER);
    text(mName, mX+mWidth/2, mY+mHeight/2+8);
  }

  void setInActive()
  {
    mIsActive = false;
  }

  Serial setActive()
  {
    mIsActive = true;
    return createSerial(this.mName);
  }
}

// The COM port menu presented on the top of the window
class ComPortMenu
{
  private ArrayList<ComPortMenuButton> mButtons;
  private ComPortMenuButton mActiveBtn = null;
  private Serial mComPort = null;

  public ComPortMenu()
  {
    int i = 0;
    mButtons = new ArrayList();
    for (String current : Serial.list())
    {
      int x = i % 5;
      int y = i / 5;
      mButtons.add(new ComPortMenuButton(100*x+5, 50*y+5, 90, 40, current));
      i++;
    }
  }

  public void drawMenu()
  {
    for (ComPortMenuButton current : mButtons)
    {
      current.drawButton();
    }
  }

  public void clickHandler()
  {
    for (ComPortMenuButton current : mButtons)
    {
      if (current.mouseOverBtn())
      {
        if (mActiveBtn != null)
          mActiveBtn.setInActive();
        mActiveBtn = current;
        mComPort = current.setActive();
      }
    }
  }

  public Serial getComPort()
  {
    return mComPort;
  }
}

// Serial handling class
// The serial port must communicate with 9600 Baud for a succesfull communication
Serial createSerial(String name)
{
  try
  {
    return new Serial(this, name, 9600);
  }
  catch(Exception e)
  {
    System.err.print(e.getMessage());
    return null;
  }
}
// The callback for a serial event, i.e. whenever a message arrives this function is fired
void serialEvent(Serial port)
{
  inString = port.readString();
}
/*************************************************/

/*************************************************/
// The classes handling the input of the magnetic sensor
/*************************************************/
// The generic TLx493D class
class TLx493D
{
  private float[] mMagneticFieldValues = new float[3];
  private float[] mBufferMagneticFieldValues = new float[3];
  
  TLx493D() {
  }
  
  public float getX(){
    return mMagneticFieldValues[0];
  }
  public float getY(){
    return mMagneticFieldValues[1];
  }
  public float getZ(){
    return mMagneticFieldValues[2];
  }

  void updateValues(float BxValue, float ByValue, float BzValue){
    mBufferMagneticFieldValues[0] = BxValue;
    mBufferMagneticFieldValues[1] = ByValue;
    mBufferMagneticFieldValues[2] = BzValue;
  }

  void transferValues(){
    mMagneticFieldValues[0] = mBufferMagneticFieldValues[0];
    mMagneticFieldValues[1] = mBufferMagneticFieldValues[1];
    mMagneticFieldValues[2] = mBufferMagneticFieldValues[2];
  }
}

// The class handling the calculation of the out of shaft features
class TLx493DOutOfShaft
{
  private float[] mMagneticFieldB0B1Values = new float[2];

  float B1_old = 0; 
  float B0_compensated = 0; 
  float B1_compensated = 0; 
  float B1_min = 0; 
  float B1_max = 0; 
  float B0_min = 0; 
  float B0_max = 0;   

  float B0_offset = 0;
  float B1_offset = 0;
  float B1_B0_amplitude = 1;
  float B1_B0_angle = 0;
  float angleUncompensated = 0;
  float angleCompensated = 0;
  float angle = 0;

  float M_45 = 0;
  float M_135 = 0;
  float Q0_min = 100;
  float Q1_min = 100;

  public float getB0(){
    return mMagneticFieldB0B1Values[0];
  }
  public float getB1(){
    return mMagneticFieldB0B1Values[1];
  }

  public void updateValuesAndCalculate(float B0, float B1){
    mMagneticFieldB0B1Values[0] = B0;
    mMagneticFieldB0B1Values[1] = B1;
    
    angle = atan2(B1, B0);

    if(B0_min > B0){
      B0_min = B0;
    }
    if(B0_max < B0){
      B0_max = B0;
    }
    if(B1_min > B1){
      B1_min = B1;
    }
    if(B1_max < B1){
      B1_max = B1;
    }

    B0_offset = (B0_max + B0_min) / 2;
    B1_offset = (B1_max + B1_min) / 2;
    B1_B0_amplitude = (B1_max - B1_min) / (B0_max - B0_min);

    B0_compensated = (B0 - B0_offset) * B1_B0_amplitude;
    B1_compensated = (B1 - B1_offset);

    if( (B0_compensated > 0) && (B1_compensated > 0)){
        if( abs(abs(B0_compensated) - abs(B1_compensated)) < Q0_min ){
            Q0_min = abs(abs(B0_compensated) - abs(B1_compensated));
            M_45 = sqrt(B0_compensated*B0_compensated + B1_compensated*B1_compensated);
        }
    }
    if( (B0_compensated < 0) && (B1_compensated > 0)){
        if(abs(abs(B0_compensated) - abs(B1_compensated)) < Q1_min){
            Q1_min = abs(abs(B0_compensated) - abs(B1_compensated));
            M_135 = sqrt(B0_compensated*B0_compensated + B1_compensated*B1_compensated);
        }
    }

    B1_B0_angle = 180 / PI * 2 * atan2(M_135 - M_45, M_135 + M_45);

  }
  
  public float getAngleCompensated(){
    angleCompensated = atan2(B1_compensated, B0_compensated);
    if(Float.isNaN(angleCompensated)){
      angleCompensated = 0;
  }
    return angleCompensated;
  }

  public float getAngleUncompensated(){
    angleUncompensated = atan2(mMagneticFieldB0B1Values[1], mMagneticFieldB0B1Values[0]);
    return angleUncompensated;
  }
}

class Button {
  int x, y, w, h;
  String label;
  String parameter;
  String onText;
  String offText;
  
  color onColorFore, offColorFore;
  color onColorBack, offColorBack;
  boolean state;
  boolean onOff;
  float labelWidth;
  
  Button(int x_, int y_, int w_, int h_, String label_){
    x = x_;
    y = y_;
    w = w_;
    h = h_;
    label = label_;
    state = true;
    onOff = false;
    parameter = "N/A";
    textSize(16);
    labelWidth = textWidth(label);

    onColorFore = color(255, 200);
    onColorBack = color(255, 100);

    offColorFore = color(0, 230);
    offColorBack = color(100, 180);

  }

  void update(){
   if(clickCount == 0){
    if(over()){
      if(mousePressed==true){
        state =! state;
        clickCount++;
      }
    }
  }
    display();
  }

  void display(){ 
     textAlign(CENTER, CENTER);
     textSize(16);
    if(state==true){
      noStroke();
      fill(onColorBack);
      rect(x,y,w,h);
      fill(onColorFore);
      if(onOff==true){
        text(onText, x+w/2, y+h/2);
      } else {
        text(parameter, x+w/2, y+h/2);
      }
    } else {
      noStroke();
      fill(offColorBack);
      rect(x,y,w,h);
      fill(offColorFore);
      if(onOff==true){
        text(offText, x+w/2, y+h/2);
      } else {
        text("N/A", x+w/2, y+h/2);
      }
    }
    textAlign(LEFT, CENTER);
    
   if(state){
     fill(255, 160);
   } else {
     fill(255, 80);
   }
    text(label, x+w+6, y + h/2);  
  }

  boolean over() {
     if (mouseX >= x -33 && mouseX <= x + w + 6 + labelWidth && mouseY >= y && mouseY <= y + h)
     {
        return true;
     } else {
        return false; 
     }
  }
}

class Label {
  int x, y, w, h;
  String label;
  String parameter;
  String onText;
  
  color onColorFore, offColorFore;
  color onColorBack, offColorBack;
  boolean state;
  boolean onOff;
  float labelWidth;
  
  Label(int x_, int y_, int w_, int h_, String label_){
    x = x_;
    y = y_;
    w = w_;
    h = h_;
    label = label_;
    onOff = false;
    parameter = "N/A";
    textSize(16);
    labelWidth = textWidth(label);
    onColorFore = color(255, 200);
    onColorBack = color(255, 100);
  }

  void display(){ 
    textAlign(CENTER, CENTER);
    textSize(16);
    noStroke();
    fill(onColorBack);
    rect(x,y,w,h);
    fill(onColorFore);
    text(parameter, x+w/2, y+h/2);
    textAlign(LEFT, CENTER);
    fill(255, 160);
    text(label, x+w+6, y + h/2);  
  }
}
