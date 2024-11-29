// Main presure transducer
// This subroutine ensure pressure is within range and a delay is added to avoid nuisance signals due to transient pressure spikes  
// If ANALOG voltage to "IN" pin A0 are under 2.2 (84 PSI) and above 2.6 (105 PSI) volts for more than 1 sec 
// then OUTPUT pin 12 is turned on (HIGH), 
// IN/OUT pins, voltage and time are variables that can to be adjusted.
// The voltage is set based on the characteristics of the tranducer 
//#define A0 A0
//#define A1 A1
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <Ewma.h> // Library that contains Exponentially Weighted Moving Average filter
// variables for pressure trigger
long PressureOutOfLimitTime = 0; // Variable to keep track of the time the PressureOutOfLimit  has been on
boolean isPressureOutOfLimit  = false; // Flag to check if PressureOutOfLimit  is currently on
// variables for LCD pressure readout
int PressureSensor = 0;
int TempSensor = 0;
int LCDPSI = 0;
int A0Voltage = 0;
int RelayDelay = 0;
//variables for Thermistor
// Watch video in the following link https://www.circuitbasics.com/arduino-thermistor-temperature-sensor-tutorial/
//(https://www.thinksrs.com/downloads/programs/therm%20calc/ntccalibrator/ntccalculator.html)
Ewma adcFilter1(0.1);   // Less smoothing - faster to detect changes, but more prone to noise
//Ewma adcFilter2(0.01);  // More smoothing - less prone to noise, but slower to detect changes
int OverTempOutPin = 11; // pin to send overtem signal to out pin 11 
int ThermistorPin = A1;//input pin A1
int Vo;
float R1 = 10000;
float logR2, R2, T, Tc, Tf;
float c1 = 1.123321447e-03, c2 = 2.361026530e-04, c3 = 0.7181364528e-07;//values are from Thermosister calculator 
LiquidCrystal_I2C lcd_1(0x27,16,2);  // run ic2_scanner sketch and get the IC2 address, which is 0x27 in my case,it could be 0x3f in many cases

void setup() {
// setup for pressure trigger 
  pinMode(12, OUTPUT); // Sets the digital pin 12 as output (for the PressureOutOfLimit )
  pinMode(A0, INPUT); // Sets the analog pin A0 as input (for the Pressure transducer)
// setup for LCD pressure readout
  lcd_1.init();     
  lcd_1.backlight();
  lcd_1.begin(16, 2);
  //pinMode(A0, INPUT);
  lcd_1.setCursor(0, 0);
  lcd_1.print("PSI:");
  lcd_1.setCursor(8, 0);
  lcd_1.print("MPa:");
  lcd_1.setCursor(0, 1);
  lcd_1.print("Rtr Temp:");
 //setup for Thermistor readout (Line 35-42 are to set the LCD screen for bothtemp and press display)
  pinMode(A1, INPUT);
  pinMode(11, OUTPUT);
  lcd_1.print("C");
}


void loop() {
// loop for pressure trigger 
  int sensorValue = analogRead(A0); // Reads the value from the potentiometer
  float voltage = sensorValue * 5.0 / 1023.0; // Converts the value to voltage
  
// Check if the voltage is under 2.1 or over 2.6 volts. The || separates the voltage checking operation above and below the voltage.
  if (voltage <= 2.1 || voltage >= 2.6) {
    if (!isPressureOutOfLimit ) { // If the PressureOutOfLimit  is not already on, record the current time
      PressureOutOfLimitTime = millis();
      isPressureOutOfLimit  = true;
    } else if (millis() - PressureOutOfLimitTime >= 1500) { // PressureOutOfLimit  has been on for more than 1.5 second
      digitalWrite(12, HIGH); // Turn on the Pressure relay
    }
  } else {
    isPressureOutOfLimit  = false; // Reset the PressureOutOfLimit  on flag
    digitalWrite(12, LOW); // Turn off the pressure relay
  }
  // Loop for LCD pressure readout
PressureSensor = analogRead(A0);
  delay(500); // Wait for 500 millisecond(s)
  LCDPSI = map(PressureSensor, 102, 921, 0, 200);//converts voltage to PSI
  lcd_1.setCursor(4, 0);
  lcd_1.print (LCDPSI);
  lcd_1.setCursor(12, 0);
  lcd_1.print ((LCDPSI)*0.00689476);// converts PSI to Mpa)
 
  //Loop for Thermistor  
   int raw = analogRead(ThermistorPin); Raw reading
   float filtered1 = adcFilter1.filter(raw); // uses EWMA filter 
Vo = filtered1; //Takes the filtered value to use in the formula
 //Vo = analogRead(ThermistorPin); Old code before filter
  R2 = R1 * (1023.0 / (float)Vo - 1.0);
  logR2 = log(R2);
  T = (1.0 / (c1 + c2*logR2 + c3*logR2*logR2*logR2));
  Tc = T - 273.15;
  Tf = (Tc * 9.0)/ 5.0 + 32.0; 
  
  lcd_1.setCursor(9, 1); //temp to LCD
  //lcd_1.print("Temp = ");
  lcd_1.print(Tc);   
  //lcd_1.print(" C");

if (Tc > 48) {   // temp setting in deg C that triggers output to turn on
digitalWrite (OverTempOutPin, HIGH);
}
else {
digitalWrite (OverTempOutPin, LOW);
}
  delay(1500);            
  //lcd_1.clear();
}
