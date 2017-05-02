// ECE491 Practice DC motor speed control, and implement encoder RPM

// Motor 1 pin assignment
int ENA = 9;  // PWM
int IN1 = 6;  // H-Bridge input 1
int IN2 = 7;  // H-Bridge input 2

// Global control variable initialization
boolean logActive = 0;
int setPoint = 0;
long serialVal = 0;
char k = 0;
float rpm = 0;
unsigned long currentTime = 0;
unsigned long lastTime = 0;
int watchdog = 0;
int ledPin = 13;

// PID Parameters
boolean controllerActive = false;
int u = 0;
int uVal = 0;
int e = 0;
int previousError = 0;
//int derivative = 0;
float Kp = 0;
float Ki = 0;
//float Kd = 0;
float integral = 0;
int t = 0;
int tLast = 0;
int dt = 0;

void setup()
  {
    attachInterrupt(0, encoderPulse, RISING);
    pinMode(ENA, OUTPUT);
    pinMode(IN1, OUTPUT);
    pinMode(IN2, OUTPUT);
    setDirection(1);
    analogWrite(ENA, setPoint);
    
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
    if (Serial.available() > 0)
      {
        serialVal = Serial.parseInt();
        switch (serialVal)
          {
            case 9998:  // Start set speed command
              Serial.println(9998);
              logActive = 1;
              break;
            case 9999:  // Stop stream command
              logActive = 0;
              break;
            default:  // Check for speed value
              if (serialVal >= 0 and serialVal <= 3748)
                {
                  setPoint = preScaler(serialVal);
                  integral = 0;
                  //previousError = 0;
                  controllerActive = !controllerActive;
                }
              break;
          }    
      }
      
    speedController();
      
    if (logActive)
      {
        sendRpm();
      }
    
    watchdog = watchdog + 1;
    
    if (watchdog == 32)
      {
        rpm = 0;
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
      rpm = calculateRpm();
      watchdog = 0;
    }
  
float calculateRpm()
    {
      float result;
      currentTime = millis();
      
      result = 60000/16/(currentTime - lastTime);
      
      lastTime = currentTime;
      return result;
    }

void sendRpm()
  {
    Serial.println(rpm);
  }

int preScaler(int val)
  {
    return (val/4);
  }
  
void speedController()
  {
    if (!controllerActive)
      {
        controllerActive = !controllerActive;
        tLast = millis();
      }
      
    e = setPoint - rpm;
    Kp = 4.75;
    Ki = 23.74;
    //Kd = 0; 
    
    t = millis();
    dt = (t - tLast);
    //derivative = (e - previousError)/dt;
    integral = integral + ((e*dt)/1000);
    uVal = (Kp*e)+(Ki*integral);//+(Kd*derivative);
    
    if (uVal > 937)
      {
        uVal = 937;
      }
    else if (uVal < -937)
      {
        uVal = -937;
      }
      
    if (uVal > 0)
      {
        u = map(uVal, 1, 937, 110, 255);
      }
    else if (uVal < 0)
      {
        u = map(uVal, -937, -1, 0, 110);
      }

    analogWrite(ENA, u);
    
    tLast = t;
    //previousError = e;
    
  }
