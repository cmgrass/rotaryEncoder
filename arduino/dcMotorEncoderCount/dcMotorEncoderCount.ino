// ECE491 Practice DC motor speed control, and implement encoder RPM

// Motor 1 pin assignment
int ENA = 9;  // PWM
int IN1 = 6;  // H-Bridge input 1
int IN2 = 7;  // H-Bridge input 2

// Global control variable initialization
int startVal = 0;
int e = 0;
int eMax = 0;
int eAdjust = 0;
int dt = 0;
int dtStart = 0;
float u = 0;
boolean logActive = 0;
int setPoint = 0;
int lastSetPoint = 0;
int tempSetPoint = 0;
long serialVal = 0;
char k = 0;
float rpm = 0;
unsigned int rpmInt = 0;
unsigned long currentTime = 0;
unsigned long lastTime = 0;
volatile int countVal = 0;

// PID Parameters
const float Kp = 0.6;
const float Ki = 0.01;
float integral = 0;

int ledPin = 13;

void setup()
  {
    attachInterrupt(0, encoderPulse, RISING);
    pinMode(ENA, OUTPUT);
    pinMode(IN1, OUTPUT);
    pinMode(IN2, OUTPUT);
    digitalWrite(IN1, LOW);
    digitalWrite(IN2, LOW);
    analogWrite(ENA, 0);
    
    // Setup serial handshake
    Serial.begin(9600);
    Serial.println('F');              
    while(k != 'F')
      {
        k = Serial.read();
      }
      
    pinMode(ledPin, OUTPUT);
  }

void loop()
  {
    digitalWrite(ledPin, HIGH);  // Visual indicator that serial connection established
    setDirection(1);  // Motor will only move in one direction
    
    if (Serial.available() > 0)
      {
        serialVal = Serial.parseInt();
        switch (serialVal)
          {
            case 1234:  // Start set speed command
              Serial.println(1234);
              logActive = 1;
              break;
            case 4321:  // Stop stream command
              logActive = 0;
              break;
            default:  // Check for speed value
              // Prescaler (quarter crankshaft speed)
              setPoint = map(serialVal,0,63,0,15);  // Map error value to PWM range

              // Initialize Control loop
              startVal = countVal;
              e = setPoint-countVal;
              eMax = e;
              eAdjust = 0;
              dt = millis();
              dtStart = dt;
              integral = 0;
              positionControl();
              analogWrite(ENA,0);
              debugData();
              break;
          }    
      }

    //positionControl();

    if (logActive)
      {
        Serial.println(countVal);
      }
  }
  
void setDirection(int direction)
  {
    switch (direction)
      {
        case 0:  // STOP
          digitalWrite(IN1, LOW);
          digitalWrite(IN2, LOW);     
        break;
        
        case 1:  // CCW
          digitalWrite(IN1, HIGH);
          digitalWrite(IN2, LOW);
        break;
        
        case 2:  // CW
          digitalWrite(IN1, LOW);
          digitalWrite(IN2, HIGH);
        break;
      }
  }
  
void encoderPulse()
  {
    countVal = countVal + 1;
    if (countVal == 16)
      {
        countVal = 0;
      }
  }

void positionControl()
  {
    Serial.println("peekaboo");
    // PID control
    // Proportional = Kp*e (the higher the error between setpoint and current value)
    // Integral = Ki*dt*e (the longer duration, the more power)
    while (countVal != setPoint)
      {
        if (countVal < setPoint)
          {
            e = setPoint - countVal;
          }
        else if (countVal > setPoint)
          {
            e = 16 - countVal + setPoint;
          }
        else
          {
            e = 0;
          }
      
        eAdjust = map(e,0,15,0,255);  // Map error value to PWM range  
        dt = (millis() - dtStart)/1000;
        integral = integral + eAdjust*dt;
        u = (Kp*eAdjust)+(Ki*integral);
         
        // Debug
        debugData();
        
        analogWrite(ENA, round(u));
      }
  }

void debugData()
  {
    Serial.print("u: ");
    Serial.print(u);
    Serial.print(", e: ");
    Serial.print(e);
    Serial.print(", set: ");
    Serial.print(setPoint);
    Serial.print(", y: ");
    Serial.println(countVal);
  }
